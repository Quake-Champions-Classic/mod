/*
=====================================
HORDE MANAGER
=====================================
*/

/*
================
HordeGetPlayersAlive

added Aug31 2021
Returns a float for the number of living players
================
*/
float() HordeGetPlayersAlive = {
	float playercount;
	entity e;
	
	// count entities
	e = find(world, classname, "player");
	while (e) {
		if (e.health > 0) {
			if (e.flags & FL_CLIENT)
				playercount++;
			else
				dprint("Player is no longer a client!\n");
		}
		e = find(e, classname, "player");
	}
	dprint("there are ");
	dprint(ftos(playercount));
	dprint(" players alive.\n");
	
	return playercount;
};

/*
================
HordeGetMonstersAlive

added Oct28 2021
Manually counts all living monsters
================
*/
float() HordeGetMonstersAlive = {
	float monstercount;
	entity e;
	
	// count monster entities
	e = find(world, category, "monster");
	while (e) {
		if ((e.health > 0) && (e.classname != "monster_zombie"))
			monstercount++;
		
		e = find(e, category, "monster");
	}
	dprint("verification count. There are ");
	dprint(ftos(monstercount));
	dprint(" monsters alive.\n");
	
	return monstercount;
};

/*
================
HordeFindTarget

added Aug31 2021
Returns a random living player
================
*/
entity() HordeFindTarget = {
	float playercount = HordeGetPlayersAlive();
	
	if (playercount == 0)
		return world;
	
	entity e;
	float rcount; // random value [0,count]
	rcount = random() * playercount;
	
	playercount = 0; // reset for new count
	e = find(world, classname, "player");
	while (e) {
		if (e.health > 0)
			playercount++;
		
		if ((rcount <= playercount) && !(e.flags & FL_NOTARGET))
			return e;
		else
			e = find(e, classname, "player");
	}
	return world;
};

void() Countdown4 = {
	if (self.wave % 3 == 0)
		centerprint_all("$qc_horde_boss_wave");
	else
		centerprint_all("$qc_horde_fight");
	SpawnWave2();
	sound(self, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NONE);
};

void() Countdown3 = {
	centerprint_all("1");
	self.think = Countdown4;
	self.nextthink = time + 1;
	sound(self, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NONE);
};

void() Countdown2 = {
	centerprint_all("2");
	self.think = Countdown3;
	self.nextthink = time + 1;
	sound(self, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NONE);
};

void() Countdown = {
	if (!SpawnWavePrep())
		return;	
	centerprint_all("3");
	self.think = Countdown2;
	self.nextthink = time + 1;	
	sound(self, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NONE);
};

void() RespawnAllPlayers = {
	entity p, oself;
	p = find(world, classname, "player");
	while (p) {
		if (p.deadflag > 0) {
			oself = self;
			self = p;
			horde_respawn_teammate();
			self = oself;
			//p.think = horde_respawn_teammate;
			//p.nextthink = time; // next frame
		}
		p = find(p, classname, "player");
	}
};


/*
When each enemy spawned by the horde manager dies, they trigger self.owner.use, which is wavecheck.
Wavecheck sees if all spawned monsters are dead, so it can determine if it needs to start a new wave.
*/
void() Wavecheck = {
	if (self.wait) // still in the process of spawning monsters, don't wavecheck
		return;
		
	self.think = Wavecheck;
	self.nextthink = time + 10;
		
	dprint("\n===============\n");
	dprint("checking kills: ");
	dprint(ftos(killed_monsters));
	dprint(" of ");
	dprint(ftos(total_monsters));
	dprint("\n");
	
	// debug checking last monster position
	if (killed_monsters + 3 >= total_monsters) {
		entity t;
		t = find(world, category, CATEGORY_MONSTER);
		while (t) {
			if (t.health > 0) {
				dprint("Position of monster: ");
				dprint(t.classname);
				dprint(" : ");
				dprint(vtos(t.origin));
				dprint("\n");
			}
			else
				t.category = string_null;
			t = find(t, category, CATEGORY_MONSTER);
		}
	}
	
	// Early exit for kill count
	if ((self.wave % 3 == 0) || (self.wave < 3)) {  // Be exact?
		dprint("check monsters killed as boss wave\n");
		if (HordeGetMonstersAlive() > 0)
			return;
	}
	else {
		dprint("check monsters killed as any other wave\n");
		if (HordeGetMonstersAlive() > 5)
			return;
	}
	
	// Made it this far, means wave completed successfully
	dprint("wavecheck looks good! Respawning players\n");
	RespawnAllPlayers();
	
	self.wait = 1;
	self.think = Countdown;
	
	if (self.wave % 3 == 0) {   // it was a boss wave
		if (!key_spawned) // key was already spawned, don't spawn another yet!
			GetKey();

		self.nextthink = time + 20; // in case the players are slow to find the key
	}
	else
		self.nextthink = time;
	dprint("wavecheck now completed.\n");
};

// setup horde rules
void() SetHorde = {
	dprint("TEST: It is September 23, 2021!\n"); // yoder sanity test
	self.think = Countdown;
	self.nextthink = time + 1;
}

// define entity 
void() horde_manager = {
	if (not_horde(self))
		return;

	// AY, Dec06 2021, auto set horde cvar
	if (!cvar("horde"))
		cvar_set("horde", "1");
	isHordeMode = cvar("horde");
	// end AY
	
    // Precaches
	HordePrecacheMonsters();
    HordePrecacheAmmo();
    HordePrecachePowerups();
    HordePrecacheItems();
    HordePrecacheKeys();
	precache_sound("horde/nyom.wav");
	
	horde_ent = self; // set global reference to the horde manager
	
	if (!self.target)
	self.target = "horde_event"; // default name

	self.targetname = "horde_manager";
	self.think = SetHorde;
	self.nextthink = time + HORDE_START_DELAY;
	self.use = Wavecheck;
	
	self.wait = 1; // waiting before next wave?
	self.delay = 9; // max number of  squads to spawn in a wave
	self.wave = 0;	
};

// remote wavecheck
// this is to trigger a wavecheck from outside of horde mode
void() remote_wavecheck = {
	if (!horde_ent || (intermission_running)) {
		dprint("no wavecheck.");
		if (!horde_ent)
			dprint(" no horde ent found.");
		if (intermission_running)
			dprint(" intermission running.");
		dprint("\n\n");
		return;
	}
	dprint("remote wavecheck from: ");
	dprint(self.classname);
	dprint("\n");
	entity stemp = self; // the entity that is triggering the remote wavecheck
	self = horde_ent;
	self.use();	
	self = stemp; // set self back to whatever it was
};

/* CheckBlockedSpawn
AY Feb24, 2022
Checks the horde spawn against all living players
Returns true/false if spawn is blocked.
*/
float(entity spawnpoint) CheckBlockedSpawn = {
	float blocked = FALSE;
	entity p;
	vector p_mins, p_maxs, s_mins, s_maxs;
	
	if (spawnpoint.spawnflags & SKIP_BLOCK_CHECK)
		return FALSE;
	
	p = find(world, classname, "player");
	while (p && !blocked) {
		if ((p.health > 0) && (p.deadflag <= 0)) {
			p_mins = p.origin + p.mins;
			p_maxs = p.origin + p.maxs;
			s_mins = spawnpoint.origin + spawnpoint.mins;
			s_maxs = spawnpoint.origin + spawnpoint.maxs;
				
			if (((p_maxs_x > s_mins_x) && (p_mins_x < s_maxs_x)) &&
				((p_maxs_y > s_mins_y) && (p_mins_y < s_maxs_y)) &&
				((p_maxs_y > s_mins_y) && (p_mins_y < s_maxs_y)))
			{
				dprint("player blocking spawn\n");
				blocked = TRUE;
			}
		}
		p = find(p, classname, "player");
	}
	return blocked;
};