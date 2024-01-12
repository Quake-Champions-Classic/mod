/*
=============================================================================
				PLAYER SPAWN FUNCTIONS
=============================================================================
*/

void() W_WeaponFrame;
void() W_SetCurrentAmmo;
void(entity attacker, float damage) player_pain;
void() player_stand;
void(vector org) spawn_tfog;
void(vector org, entity death_owner) spawn_tdeath;
float modelindex_eyes;
void(entity temp_player) horde_set_keys;

// MG1
void LoadGame() {
	dprint("\n\nLoadGame: self.classname = ");
	dprint(self.classname);
	dprint("\n\n");

	//For each player...
	entity cl = find(world, classname, "player");
	while (cl) {
		if (cl.fog_density) {
			//Restore fog
			SetFog(cl, cl.fog_density, cl.fog_color, 0.0);
		}
		cl = find(cl, classname, "player");
	}
}

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn = {
	if (coop) {
		CopyToBodyQueue (self);
		setspawnparms (self);
		PutClientInServer();
	}
	else if (deathmatch) {
		CopyToBodyQueue (self);
		SetNewParms();
		PutClientInServer();
	}
	else {
		serverflags = startingserverflags;
		// Request a reset to the parms
		reset_flag = TRUE;
		// "Change" to the same level
		localcmd ("changelevel ");
		localcmd(mapname);
		localcmd("\n");
	}
};

// MG1: When in horde coop, respawn a dead teammate with this:
void() horde_respawn_teammate = {
	CopyToBodyQueue (self);
	PutClientInServer();
};

// MG1: When in horde (coop or solo), respawn all by restarting the server:
void() horde_respawn_all = {
	serverflags = startingserverflags;
	// Request a reset to the parms
	reset_flag = TRUE;
	// "Change" to the same level
	localcmd ("changelevel ");
	localcmd(mapname);
	localcmd("\n");
};

void PlayerDie(); 

// Player entered the suicide command
void() ClientKill = {
	if (ExtSupported("EX_BPRINT"))
		bprint("$qc_suicides", self.netname);
	else {
		bprint (self.netname);
		bprint (" suicides\n");
	}
	// MG1: Horde mode behavior
	if (cvar("horde")) {
		PlayerDie();
		self.health = 0;
	}
	// Standard behavior
	else {
		set_suicide_frame();
		self.modelindex = self.modelindex_champ;
		self.frags = self.frags - 2; // Extra penalty
		respawn();
	}
};

float PlayerVisibleToSpawnPoint(entity point) {
	vector spot1, spot2;
	entity player = find(world, classname, "player");
	while (player) {
		if (player.health > 0) {
			spot1 = point.origin + player.view_ofs;
			spot2 = player.origin + player.view_ofs;
			traceline(spot1, spot2, TRUE, point);
			if (trace_fraction >= 1.0f)
				return TRUE;
		}
		player = find(player, classname, "player");
	}
	return FALSE;
}

float IDEAL_DIST_FROM_DM_SPAWN_POINT = 384;
float MIN_DIST_FROM_DM_SPAWN_POINT = 84;

// MG1
float MIN_DIST_FROM_HORDE_SPAWN_POINT = 72;
float predicate_is_active_spawnpoint(entity e) {
	return (e.state == COOP_SPAWN_ACTIVE);
}

entity SelectSpawnPoint(float forceSpawn) {
	entity spot, spots, thing, hordeSpawn;
	float numspots, totalspots, pcount;

	numspots = 0;
	totalspots = 0;

	// testinfo_player_start is only found in regioned levels
	spot = find(world, classname, "testplayerstart");
	if (spot)
		return spot;
	
	// MG1
	if (cvar("horde")) { // run simpler logic for horde - just need a spot with noone on top of it...
		hordeSpawn = find(world, classname, "info_player_coop");	
		while (hordeSpawn) {
			thing = findradius(hordeSpawn.origin, MIN_DIST_FROM_HORDE_SPAWN_POINT);	
			pcount = 0;	
			while (thing) {
				if (thing.classname == "player" && thing.health > 0)
					pcount++;
				thing = thing.chain;      
			}
			if (pcount == 0)
				return hordeSpawn;
			// Get the next spot in the chain
			hordeSpawn = find(hordeSpawn, classname, "info_player_coop");
		}
		if (coop) // fix for singleplayer
			return world; // didn't find anything....
	}

	// Choose an info_player_deathmatch point
	else if (coop) {
		lastspawn = find(lastspawn, classname, "info_player_coop");
		if (lastspawn == world)
			lastspawn = find(lastspawn, classname, "info_player_start");

		if (lastspawn != world)
			return lastspawn;
		
	}
	else if (deathmatch) {
		// Find all spots that don't have visible players nearby
		spots = world;
		spot = find(world, classname, "info_player_deathmatch");
		while (spot) {
			totalspots = totalspots + 1;
			thing = findradius(spot.origin, IDEAL_DIST_FROM_DM_SPAWN_POINT);
			pcount = 0;
			while (thing) {
				if (thing.classname == "player" && thing.health > 0)
					pcount = pcount + 1;
				thing = thing.chain;      
			}
			if (pcount == 0 && PlayerVisibleToSpawnPoint(spot))
				pcount = pcount + 1;
			if (pcount == 0) { // good spot!
				spot.goalentity = spots;
				spots = spot;
				numspots = numspots + 1;
			}
			// Get the next spot in the chain
			spot = find(spot, classname, "info_player_deathmatch");                
		}

		totalspots = totalspots - 1;

		// On small maps with few spawn points, our "ideal" spawn conditions may not be possible to meet
		// so fallback to just trying to pick a point without a player on top of it, so we don't start a spawn frag loop
		if (numspots == 0) {
			spot = find(world, classname, "info_player_deathmatch");
			while (spot) {
				thing = findradius(spot.origin, MIN_DIST_FROM_DM_SPAWN_POINT);
				pcount = 0;
				while (thing) {
					if (thing.classname == "player" && thing.health > 0)
						pcount = pcount + 1;
					thing = thing.chain;      
				}
				if (pcount == 0) { // good spot!
					spot.goalentity = spots;
					spots = spot;
					numspots = numspots + 1;
				}
				// Get the next spot in the chain
				spot = find(spot, classname, "info_player_deathmatch");                
			}
		}

		if (!numspots) {
			if (forceSpawn == FALSE)
				return world;

			// No spots available so just pick one at random
			totalspots = rint((random() * totalspots));
			spot = find(world, classname, "info_player_deathmatch");       

			while (totalspots > 0) {
				totalspots = totalspots - 1;
				spot = find(spot, classname, "info_player_deathmatch");
			}
			return spot;
		}

		numspots = numspots - 1;	
		numspots = rint((random() * numspots));
		spot = spots;
		while (numspots > 0) {
			spot = spot.goalentity;
			numspots = numspots - 1;
		}

		return spot;
	}

	// Return with a rune to start
	if (serverflags) {
		// MG1
		float lastPickup = sigil_getLastPickup();
		if (lastPickup) {
			string spname = string_null;
			if (lastPickup & SIGIL_E1)
				spname = "start_1";
			else if (lastPickup & SIGIL_E2)
				spname = "start_2";
			else if (lastPickup & SIGIL_E3)
				spname = "start_3";
			else if (lastPickup & SIGIL_E4)
				spname = "start_4";
			else if (lastPickup & SIGIL_E5)
				spname = "start_5";
			else if (lastPickup & SIGIL_E6)
				spname = "start_6";
			if (spname) {
				spot = find(world, netname, spname);
				if (spot) {
					if (spot.classname == "info_player_start_hub") {
						sigil_clearLastPickup();
						return spot;
					}
				}
			}
		}
		spot = find(world, classname, "info_player_start2");
		if (spot)
			return spot;
	}
	
	spot = find(world, classname, "info_player_start");	
	if (!spot)
		error("PutClientInServer: no info_player_start on level");	
	return spot;
};

void() DecodeLevelParms;
void() PlayerDie;
void() player_touch; // ROGUE

// MG1
void RunPostPutClientInServer() {
	entity oself = self;
	self = self.owner;
	entity spot = oself.enemy;
	
	// Yoder Sept24, 2021
	horde_set_keys(self); // reset player's key count accordingly

	// Fog settings sometimes (?) need to be set a frame after the client has spawned.
	// Not sure why, or why it sometimes works on the same frame.
	if (!FogPushSettingsFrom(self, spot, 0))
		FogPushSettingsFrom(self, world, 0);

	remove(oself);
};

// Called each time a player is spawned
void() PutClientInServer = {
	entity spot;

	self.classname = "player";
	if (skill == 3 && !deathmatch)
		self.health = 50;
	else
		self.health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	if (skill == 3 && !deathmatch)
		self.max_health = 50;
	else
		self.max_health = 100;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;	// initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;
	self.healthrot_nextcheck = 0;
	self.fired_weapon = 0; // [NDS] haleyjd
	self.took_damage = 0;  // [NDS] haleyjd
	self.team = TEAM_NONE;

	// HIP
	self.wetsuit_finished = 0;
	self.empathy_finished = 0;
	self.items2 = 0;
	self.gravity = 1.0;

    // ROGUE
    self.shield_finished = 0;
	self.antigrav_finished = 0;
	
	if (coop)
		self.team = TEAM_HUMANS;

	DecodeLevelParms();	
	W_SetCurrentAmmo();

	self.attack_finished = time;
	// QCC: use pointers for the player_run and player_stand functions so we can replace them elsewhere
	self.th_stand = player_stand;
	self.th_run = player_run;

	self.th_pain = player_pain;
	self.th_die = PlayerDie;	
	self.deadflag = DEAD_NO;
	self.pausetime = 0; // pausetime is set by teleporters to keep the player from moving a while

	float shouldTelefrag;

	if (self.spawn_deferred > 0 && time >= self.spawn_deferred) {
		dprint("forcing telefrag on this spawn\n");
		shouldTelefrag = TRUE;
	} else
		shouldTelefrag = FALSE;
	spot = SelectSpawnPoint(shouldTelefrag);
	if (spot == world) {
		self.takedamage = DAMAGE_NO;
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
		self.deadflag = DEAD_DEAD;
		setmodel(self, "");
		self.view_ofs = '0 0 1'; // not 0 because PlayerPreThink would return out
		self.velocity = '0 0 0';

		if (self.spawn_deferred == 0) {
			dprint("no spawns available! deferring\n");
			self.spawn_deferred = time + 5;
		}

		spot = FindIntermission();
		self.angles = self.v_angle = spot.mangle;
		self.fixangle = TRUE;
		self.origin = spot.origin;
		self.weaponmodel = "";
		self.weaponframe = 0;
		self.weapon = 0;

		return;
	}

	self.spawn_deferred = 0;

	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately

	// MG1
#ifdef COOP_RESPAWN_KEEP_WEAPONS
	if (coop) { 
		// In coop we want to give back the players the weapons they progressed with
		self.items |= (spot.items & IT_ALL_WEAPONS);
		if (self.items & (IT_NAILGUN | IT_SUPER_NAILGUN) && self.ammo_nails < 50)
			self.ammo_nails = 50;
		if (self.items & (IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER) && self.ammo_rockets < 10)
			self.ammo_rockets = 10;
		if (self.items & (IT_LIGHTNING | IT_EXTRA_WEAPON) && self.ammo_cells < 50)
			self.ammo_cells = 50;
	}
#endif

	self.touch = player_touch; // ROGUE uses this for Power Shield mechanics, make sure to include this in custom QCC_Touch functions

	// Oh, this is a hack!
	setmodel(self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	QCC_SpawnChampion();
	
	if (deathmatch || coop) {
		makevectorsfixed(self.angles);
		spawn_tfog(self.origin + v_forward*20);
	}

	spawn_tdeath(self.origin, self);

	// MG1
	entity postSpawn = spawn();
	postSpawn.owner = self;
	postSpawn.enemy = spot;
	postSpawn.think = RunPostPutClientInServer;
	postSpawn.nextthink = time + 0.05;
	
	stuffcmd(self, "-attack\n"); // prevent shooting after respawning
};


/*
=============================================================================
Player Spawnpoints
=============================================================================
*/
// The normal starting point for a level.
void() info_player_start = {
	self.netname = "info_player_start"; // For bot nav support.
};

// Only used on start map for the return point from an episode.
void() info_player_start2 = {
	self.netname = "info_player_start2"; // For bot nav support.
};

// MG1: Only used on start map for the return point from an episode.
void() info_player_start_hub = {};

// Saved out by quaked in region mode
void() testplayerstart = {};

// Potential spawning position for deathmatch games
void() info_player_deathmatch = {
	if (!deathmatch) {
		remove(self);
		return;
	}
	SpawnRunes(); // MG1
	self.netname = "info_player_deathmatch"; // for bot nav support.
};

// MG1
void trigger_activate_coop_spawns_use() {
	float it = 0;

#ifdef COOP_RESPAWN_KEEP_WEAPONS
	entity p = find(world, classname, "player");
	while (p != world) {
		it |= p.items;
		p = find(p, classname, "player");
	}	
	it &= IT_ALL_WEAPONS;

	dprint("Activating coop spawn \"");
	dprint(self.target);
	dprint("\": Collected ");
	dprint(ftos(it));
	dprint(" from players.\n");
#endif

	entity coop_spawn = find(world, classname, "info_player_coop");
	while (coop_spawn) {
		if (coop_spawn.targetname == self.target) {
			coop_spawn.state = COOP_SPAWN_ACTIVE;
			coop_spawn.items = it;
		}
		else {
			coop_spawn.state = 0;
			coop_spawn.items = 0;
		}
		coop_spawn = find(coop_spawn, classname, "info_player_coop");
	}
};

// Activates a set of coop spawnpoints.
void trigger_activate_coop_spawns() {
	if (!coop) {
		remove(self);
		return;
	}
	self.use = trigger_activate_coop_spawns_use;
};

const float COOP_SPAWN_START_ACTIVE = 1;

// Potential spawning position for coop games
void() info_player_coop = {
	if (!coop) {
		remove(self);
		return;
	}
	self.netname = "info_player_coop"; // For bot nav support.
	if (!self.targetname) self.state = COOP_SPAWN_ACTIVE;
	if (self.spawnflags & COOP_SPAWN_START_ACTIVE) self.state = COOP_SPAWN_ACTIVE;
};
