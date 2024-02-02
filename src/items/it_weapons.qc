/*
===============================================================================
WEAPONS
===============================================================================
*/
void() bound_other_ammo = {
	if (other.ammo_shells > 25)
		other.ammo_shells = 25;

	if (other.ammo_nails > 150)
		other.ammo_nails = 150;

	if (other.ammo_rockets > 25)
		other.ammo_rockets = 25;		

	if (other.ammo_cells > 150)
		other.ammo_cells = 150;		
};


float(float w) RankForWeapon = {
	if (w == QCC_ABILITY) // QCC
		return -1;
	if (w == IT_AXE && self.qccChampion == QCC_DOOMSLAYER && self.qccAbilityTimer < 0)
		return -1;
	if (w == QCC_IT_RAILGUN) // QCC
		return 0;
	if (w == IT_LIGHTNING)
		return 1;
	if (w == IT_ROCKET_LAUNCHER)
		return 2;
	if (w == IT_LASER_CANNON) // HIP
		return 3;
	if (w == IT_SUPER_NAILGUN)
		return 4;
	if (w == IT_PROXIMITY_GUN) // HIP
		return 5;
	if (w == IT_GRENADE_LAUNCHER)
		return 6;
	if (w == IT_SUPER_SHOTGUN)
		return 7;
	if (w == IT_NAILGUN)
		return 8;
	if (w == IT_MJOLNIR) // HIP
		return 9;
	return 10;
};

float (float w) WeaponCode = {
	if (w == IT_SUPER_SHOTGUN)
		return 3;
	if (w == IT_NAILGUN)
		return 4;
	if (w == IT_SUPER_NAILGUN)
		return 5;
	if (w == IT_GRENADE_LAUNCHER)
		return 6;
	if (w == IT_ROCKET_LAUNCHER)
		return 7;
	if (w == IT_LIGHTNING)
		return 8;	
	// QCC
	if (w == QCC_IT_RAILGUN)
		return QCC_IM_RAILGUN;

	return 1;
};

// Deathmatch weapon change rules for picking up a weapon
void(float old, float new) Deathmatch_Weapon = {
	float or, nr;

	// mal: let bots pick their own weapon.
	if (self.flags & FL_ISBOT)
		return;
    
	// Change self.weapon if desired
	or = RankForWeapon(self.weapon);
	nr = RankForWeapon(new);
	if (nr < or)
		self.weapon = new;
};

float() W_BestWeapon;
float(entity playerEnt, float old, float new) W_WantsToChangeWeapon;

void() weapon_touch = {
	float hadammo, best, new, old, leave;
	entity stemp;

    if (!(other.flags & FL_CLIENT))
        return;	
	// QCC: Nyx can't pick up stuff during Ghost Walk
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;

    new = other.items;

    // If the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;

	if (coop || deathmatch == 2 || deathmatch == 3 || deathmatch == 5)
		leave = TRUE;
	else
		leave = FALSE;
	
	if (self.classname == "weapon_nailgun")	{
		if (leave && (other.items & IT_NAILGUN))
			return;
		hadammo = other.ammo_nails;			
		new = IT_NAILGUN;
		if (other.ammo_nails < 100)
			other.ammo_nails = 100;
		else
			other.ammo_nails += 10;
	}
	else if (self.classname == "weapon_supernailgun") {
		if (leave && (other.items & IT_SUPER_NAILGUN))
			return;
		hadammo = other.ammo_rockets;			
		new = IT_SUPER_NAILGUN;
		if (other.ammo_nails < 100)
			other.ammo_nails = 100;
		else
			other.ammo_nails += 10;
	}
	else if (self.classname == "weapon_supershotgun") {
		if (leave && (other.items & IT_SUPER_SHOTGUN))
			return;
		hadammo = other.ammo_rockets;			
		new = IT_SUPER_SHOTGUN;
		if (other.ammo_shells < 10)
			other.ammo_shells = 10;
		else
			other.ammo_shells += 5;
	}
	else if (self.classname == "weapon_rocketlauncher") {
		if (leave && (other.items & IT_ROCKET_LAUNCHER))
			return;
		hadammo = other.ammo_rockets;			
		new = IT_ROCKET_LAUNCHER;
		if (other.ammo_rockets < 10)
			other.ammo_rockets = 10;
		else
			other.ammo_rockets += 5;
	}
	else if (self.classname == "weapon_grenadelauncher") {
		if (leave && (other.items & IT_GRENADE_LAUNCHER))
			return;
		hadammo = other.ammo_rockets;			
		new = IT_GRENADE_LAUNCHER;
		if (other.ammo_rockets < 10)
			other.ammo_rockets = 10;
		else
			other.ammo_rockets += 5;
	}
	else if (self.classname == "weapon_lightning") {
		if (leave && (other.items & IT_LIGHTNING))
			return;
		hadammo = other.ammo_rockets;			
		new = IT_LIGHTNING;
		if (other.ammo_cells < 100)
			other.ammo_cells = 100;
		else
			other.ammo_cells += 10;
	}
	// HIP
	else if (self.classname == "weapon_laser_gun") {
		if (leave && (other.items & IT_LASER_CANNON))
			return;
		hadammo = other.ammo_rockets;
		new = IT_LASER_CANNON;
		if (other.ammo_cells < 100)
			other.ammo_cells = 100;
		else
			other.ammo_cells += 10;
	}
	else if (self.classname == "weapon_mjolnir") {
		if (leave && (other.items & IT_MJOLNIR))
			return;
		hadammo = other.ammo_rockets;
		new = IT_MJOLNIR;
		other.ammo_cells = other.ammo_cells + 30;
	}
	else if (self.classname == "weapon_proximity_gun") {
		if (leave && (other.qccItems3 & IT_PROXIMITY_GUN)) // we check for qccItems3 validity
			return;
		hadammo = other.ammo_rockets;
		new = IT_PROXIMITY_GUN;
		if (other.ammo_rockets < 10)
			other.ammo_rockets = 10;
		else
			other.ammo_rockets += 5;
	}
	// QCC
	else if (self.classname == "qcc_weapon_railgun") {
		if (leave && (other.items & QCC_IT_RAILGUN))
			return;
		hadammo = other.ammo_cells;
		new = QCC_IT_RAILGUN;
		if (other.ammo_cells < 75)
			other.ammo_cells = 75;
		else
			other.ammo_cells += 30;
	}
	else
		objerror ("weapon_touch: unknown classname");

	if (ExtSupported("EX_SPRINT"))
		sprint(other, "$qc_got_item", self.netname);
	else {
		sprint(other, "You got the ");
		sprint(other, self.netname);
		sprint(other, "\n");
	}

	sound(other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd(other, "bf\n");

	// Change to the weapon
	bound_other_ammo();
	old = other.items;
	other.items = other.items | new;
	other.qccItems3 = other.qccItems3 | self.qccItems3; // QCC: addon alt weapons
	
	stemp = self;
	self = other;
	
	if (W_WantsToChangeWeapon(other, old, other.items) == 1) {
		if (!deathmatch)
			self.weapon = new;
		else
			Deathmatch_Weapon (old, new);
	}
	W_SetCurrentAmmo();

	self = stemp;

	// Moved up so the targets are fired even in coop, but only once.
	activator = other;
	SUB_UseTargets();
	if (leave) {
		self.target = string_null;
		return;
	}

	// Remove it in single player, or set up for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;

	if (deathmatch && deathmatch != 2) {
		self.nextthink = time + 30;
		self.think = SUB_regen;
	}
	else if (self.wait) {
		self.nextthink = time + self.wait;
		self.think = SUB_regen;
	}
	
	// QCC
	other.qccSpeakItem(other, self);
};

void() weapon_supershotgun = {
	precache_model("progs/g_shot.mdl");
	setmodel(self, "progs/g_shot.mdl");
	self.weapon = IT_SUPER_SHOTGUN;
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_double_shotgun";
	else
		self.netname = "Double-barrelled Shotgun";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() weapon_nailgun = {
	if (!deathmatch) {
		if (world.model == "maps/e4m1.bsp" || world.model == "maps/end.bsp") {
			qcc_weapon_railgun();
			return;
		}
  	}
	precache_model("progs/g_nail.mdl");
	setmodel(self, "progs/g_nail.mdl");
	self.weapon = IT_NAILGUN;
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_nailgun";
	else
		self.netname = "nailgun";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() weapon_supernailgun = {
	precache_model("progs/g_nail2.mdl");
	setmodel(self, "progs/g_nail2.mdl");
	self.weapon = IT_SUPER_NAILGUN;
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_super_nailgun";
	else
		self.netname = "Super Nailgun";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() weapon_grenadelauncher = {
	precache_model("progs/g_rock.mdl");
	setmodel(self, "progs/g_rock.mdl");
	self.weapon = IT_GRENADE_LAUNCHER;
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_grenade_launcher";
	else
		self.netname = "Grenade Launcher";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() weapon_rocketlauncher = {
	if (time < 2 && QCC_Rocket_to_Rail() == TRUE)
		return;
	precache_model("progs/g_rock2.mdl");
	setmodel(self, "progs/g_rock2.mdl");
	self.weapon = IT_ROCKET_LAUNCHER;
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_rocket_launcher";
	else
		self.netname = "Rocket Launcher";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() weapon_lightning = {
	precache_model("progs/g_light.mdl");
	setmodel(self, "progs/g_light.mdl");
	self.weapon = IT_LIGHTNING;
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_thunderbolt";
	else
		self.netname = "Thunderbolt";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};


/*
===============================================================================

SCOURGE OF ARMAGON WEAPONS

===============================================================================
*/

// QUAKED weapon_mjolnir (0 .5 .8) (-16 -16 0) (16 16 32)
void() weapon_mjolnir = {
	qcc_weapon_railgun();
	self.classname = "qcc_weapon_railgun";
	/*
	precache_model("progs/g_hammer.mdl");
	setmodel(self, "progs/g_hammer.mdl");
	self.weapon = 4;
	self.netname = "$qc_mjolnir";
	self.items = IT_MJOLNIR;
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
	*/
};

// QUAKED weapon_laser_gun (0 .5 .8) (-16 -16 0) (16 16 32)
void() weapon_laser_gun = {
	precache_model("progs/g_laserg.mdl");
	setmodel(self, "progs/g_laserg.mdl");
	self.weapon = IT_LASER_CANNON;
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_laser_cannon";
	else
		self.netname = "Laser Cannon";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

// QUAKED weapon_proximity_gun (0 .5 .8) (-16 -16 0) (16 16 32)
void() weapon_proximity_gun = {
	precache_model("progs/g_prox.mdl");
	setmodel(self, "progs/g_prox.mdl");
	self.weapon = IT_PROXIMITY_GUN;
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_prox_gun";
	else
		self.netname = "Proximity Gun";
	self.qccItems3 = IT_PROXIMITY_GUN;
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};