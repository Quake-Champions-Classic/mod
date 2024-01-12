/*
===============================================================================
AMMO
===============================================================================
*/
void() ammo_touch = {
	entity stemp;
	float best, noammo;

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

	noammo = FALSE;

	if (self.weapon == 1) {
		if (other.ammo_shells < 25)
			other.ammo_shells = other.ammo_shells + self.aflag;
		else
			noammo = TRUE;
	}
	if (self.weapon == 2) {
		if (other.ammo_nails < 150)
			other.ammo_nails = other.ammo_nails + self.aflag;
		else
			noammo = TRUE;
	}
	if (self.weapon == 3) {
		if (other.ammo_rockets < 25)
			other.ammo_rockets = other.ammo_rockets + self.aflag;
		else
			noammo = TRUE;
	}
	if (self.weapon == 4) {
		if (other.ammo_cells < 150)
			other.ammo_cells = other.ammo_cells + self.aflag;
		else
			noammo = TRUE;
	}

	if (noammo == TRUE)
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
			self.think = SUB_regen; // Respawn almost immediately
		}
        // Respawn after 4 mins in case the players get stuck on something hard.
		else {
			self.enemy = world;
			self.cnt = 0;
			self.nextthink = time + 4 * 60;
			self.think = SUB_regen;
		}
	}
	else 
#endif
	if (deathmatch)	{
		if (deathmatch == 3 || deathmatch == 5)
			self.nextthink = time + 15;
		else if (deathmatch != 2)
			self.nextthink = time + 30;
	}
	else if (self.wait)	{
		self.enemy = world;
		self.nextthink = time + self.wait;
	}

	activator = other;
	SUB_UseTargets();
};

float WEAPON_BIG2 = 1;

void() item_shells = {
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2) {
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
    
	setsize(self, '0 0 0', '32 32 56');
	StartItem();
};

void() item_spikes = {
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2) {
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
		self.netname = "$qc_nails";
	else
		self.netname = "nails";
    
	setsize(self, '0 0 0', '32 32 56');
	StartItem();
};

void() item_cells = {
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2) {
		precache_model("maps/b_batt1.bsp");
		setmodel(self, "maps/b_batt1.bsp");
		self.aflag = 50;
	}
	else {
		precache_model("maps/b_batt0.bsp");
		setmodel(self, "maps/b_batt0.bsp");
		self.aflag = 25;
	}
	self.weapon = 4;

	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_cells";
	else
		self.netname = "cells";
    
	setsize(self, '0 0 0', '32 32 56');
	StartItem();
};

void() item_rockets = {
	// QCC: railgun ammo for Ziggurat Vertigo
	if (world.model == "maps/e1m8.bsp") {
		item_cells();
		return;
	}
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2) {
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
	setsize(self, '0 0 0', '32 32 56');
	StartItem();
};

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

// QCC: ammo replacements for DoE ammo, since we don't actually have their weapons
void() item_multi_rockets = {
	item_rockets();
};

void() item_lava_spikes = {
	item_spikes();
};

void() item_plasma = {
	item_cells();
};