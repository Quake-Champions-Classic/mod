/*
===============================================================================
AMMO
===============================================================================
*/
void() ammo_touch = {
	entity stemp;
	float best, picked_up;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;	
	// QCC: Nyx can't pick up stuff during Ghost Walk
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;

#ifdef COOP_RESPAWN_ITEMS_FOR_PLAYERS
	if (coop && other == self.enemy && self.wait <= 0) //In coop, don't allow the same player to pick up all the respawns.
		return;
	self.enemy = other;	// Store this player for coop
#endif

    // If the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;

	picked_up = FALSE;

	if (self.weapon & IT_SHELLS) {
		if (other.ammo_shells < AM_MAX_SHELLS) {
			other.ammo_shells += self.aflag;
			picked_up = TRUE;
			if (other.ammo_shells > AM_MAX_SHELLS)
				other.ammo_shells = AM_MAX_SHELLS;
		}

		if (find(world, classname, "qcc_item_bullets") == world) {
			if (other.ammo_bullets < AM_MAX_BULLETS) {
				other.ammo_bullets += self.aflag;
				if (other.ammo_bullets > AM_MAX_BULLETS)
					other.ammo_bullets = AM_MAX_BULLETS;
				picked_up = TRUE;
			}
		}
	}

	if (self.weapon & IT_NAILS) {
		if (other.ammo_nails < AM_MAX_NAILS) {
			other.ammo_nails += self.aflag;
			if (other.ammo_nails > AM_MAX_NAILS)
				other.ammo_nails = AM_MAX_NAILS;
			picked_up = TRUE;
		}
	}

	if (self.weapon & IT_ROCKETS) {
		if (other.ammo_rockets < AM_MAX_ROCKETS) {
			other.ammo_rockets += self.aflag;
			if (other.ammo_rockets > AM_MAX_ROCKETS)
				other.ammo_rockets = AM_MAX_ROCKETS;
			picked_up = TRUE;
		}
		
		if (find(world, classname, "qcc_item_bolts") == world) {
			if (other.ammo_bolts < AM_MAX_BOLTS) {
				other.ammo_bolts += 5;
				if (other.ammo_bolts > AM_MAX_BOLTS)
					other.ammo_bolts = AM_MAX_BOLTS;
				picked_up = TRUE;
			}
		}
	}

	if (self.weapon & IT_CELLS) {
		if (other.ammo_cells < AM_MAX_CELLS) {
			other.ammo_cells += self.aflag;
			if (other.ammo_cells > AM_MAX_CELLS)
				other.ammo_cells = AM_MAX_CELLS;
			picked_up = TRUE;
		}

		// Gordon Freeman can use cells to recharge armor
		if (other.qccChampion == QCC_GORDONFREEMAN) {
			if (other.armorvalue < other.qccMaxArmor) {
				other.armorvalue += 25;
				if (other.armorvalue > other.qccMaxArmor)
					other.armorvalue = other.qccMaxArmor;
				picked_up = TRUE;
			}
		}
		
		if (find(world, classname, "qcc_item_slugs") == world) {
			if (other.ammo_slugs < AM_MAX_SLUGS) {
				other.ammo_slugs += 5;
				if (other.ammo_slugs > AM_MAX_SLUGS)
					other.ammo_slugs = AM_MAX_SLUGS;
				picked_up = TRUE;
			}
		}
	}

	if (self.qccItems3 & QCC_IT2_BULLETS) {
		if (other.ammo_bullets < AM_MAX_BULLETS) {
			other.ammo_bullets += self.aflag;
			if (other.ammo_bolts > AM_MAX_BOLTS)
				other.ammo_bolts = AM_MAX_BOLTS;
			picked_up = TRUE;
		}
	}

	if (self.qccItems3 & QCC_IT2_BOLTS) {
		if (other.ammo_bolts < AM_MAX_BOLTS) {
			other.ammo_bolts += self.aflag;
			if (other.ammo_bolts > AM_MAX_BOLTS)
				other.ammo_bolts = AM_MAX_BOLTS;
			picked_up = TRUE;
		}
	}

	if (self.qccItems3 & QCC_IT2_SLUGS) {
		if (other.ammo_slugs < AM_MAX_SLUGS) {
			other.ammo_slugs += self.aflag;
			if (other.ammo_slugs > AM_MAX_SLUGS)
				other.ammo_slugs = AM_MAX_SLUGS;
			picked_up = TRUE;
		}
	}

	if (!picked_up)
		if (!(other.qccFlags & QCC_FL_STOCKPILE) || other.qccAbilityTimer <= time)
			return;
	else {
		bound_other_ammo();
		if (ExtSupported("EX_SPRINT"))
			sprint(other, "$qc_got_item", self.netname);
		else {
			sprint(other, "You got the ");
			sprint(other, self.netname);
			sprint(other, "\n");
		}
	}
	
	// Champions with Stockpile reduce their cooldown (Keel, Athena, Big John...)
	if (other.qccFlags & QCC_FL_STOCKPILE && other.qccAbilityTimer > time) {
		QCC_AbilityCooldown(other);
		QCC_AbilityTimeLeft(other);
	}

	sound(other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	other.qccSpeakItem(other, self);
	stuffcmd(other, "bf\n");

	// Change to a better weapon if appropriate
	if (other.weapon == best && (W_WantsToChangeWeapon(other, 0, 1) == 1)) {
		stemp = self;
		self = other;
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		W_SetCurrentAmmo(); // QCC: run it twice so that we don't swap between grenade and proximity every time we pick up ammo
		self = stemp;
	}

	// If changed current ammo, update it
	stemp = self;
	self = other;
	W_SetCurrentAmmo();
	W_SetCurrentAmmo();
	self = stemp;

	// Remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;
	self.think = SUB_regen;

#ifdef COOP_RESPAWN_ITEMS_FOR_PLAYERS
    //Wait overrides coop respawn behaviour
	if (coop && self.wait <= 0) {
		self.cnt++;
        //Not been picked up by all players yet.
		if (self.cnt < num_players) {
			self.nextthink = time + 1;
		}
        // Respawn after 4 mins in case the players get stuck on something hard.
		else {
			self.enemy = world;
			self.cnt = 0;
			self.nextthink = time + 4 * 60;
		}
	}
	else 
#endif
	if (deathmatch)	{
		self.nextthink = time + 20;
	}
	else if (self.wait)	{
		self.enemy = world;
		self.nextthink = time + self.wait;
	}

	activator = other;
	SUB_UseTargets();
};

float WEAPON_BIG2 = 1;

// DO NOT USE THIS!!!! IT WILL BE REMOVED!
float WEAPON_SHOTGUN = 1;
float WEAPON_ROCKET = 2;
float WEAPON_SPIKES = 4;
float WEAPON_BIG = 8;
void() item_weapon = {
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_SHOTGUN) {
		if (self.spawnflags & WEAPON_BIG) {
			precache_model("maps/b_shell1.bsp");
			setmodel(self, "maps/b_shell1.bsp");
			self.aflag = 10;
		}
		else {
			precache_model("maps/b_shell0.bsp");
			setmodel(self, "maps/b_shell0.bsp");
			self.aflag = 5;
		}
		self.weapon = 1;
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_shells";
		else
			self.netname = "shells";
	}

	if (self.spawnflags & WEAPON_SPIKES) {
		if (self.spawnflags & WEAPON_BIG) {
			precache_model("maps/b_nail1.bsp");
			setmodel(self, "maps/b_nail1.bsp");
			self.aflag = 50;
		}
		else {
			precache_model("maps/b_nail0.bsp");
			setmodel(self, "maps/b_nail0.bsp");
			self.aflag = 25;
		}
		self.weapon = 2;
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_spikes";
		else
			self.netname = "nails";
	}

	if (self.spawnflags & WEAPON_ROCKET) {
		if (self.spawnflags & WEAPON_BIG) {
			precache_model("maps/b_rock1.bsp");
			setmodel(self, "maps/b_rock1.bsp");
			self.aflag = 10;
		}
		else {
			precache_model("maps/b_rock0.bsp");
			setmodel(self, "maps/b_rock0.bsp");
			self.aflag = 5;
		}
		self.weapon = 3;
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_rockets";
		else
			self.netname = "rockets";
	}
	
	setsize(self, '0 0 0', '32 32 56');
	StartItem();
};