/*
===============================================================================
WEAPONS
===============================================================================
*/
float AM_MAX_SHELLS = 25;
float AM_MAX_NAILS = 150;
float AM_MAX_ROCKETS = 25;
float AM_MAX_CELLS = 150;
float AM_MAX_BOLTS = 15;
float AM_MAX_BULLETS = 150;
float AM_MAX_SLUGS = 10;

void() bound_other_ammo = {
	if (other.ammo_shells > AM_MAX_SHELLS)
		other.ammo_shells = AM_MAX_SHELLS;

	if (other.ammo_nails > AM_MAX_NAILS)
		other.ammo_nails = AM_MAX_NAILS;

	if (other.ammo_rockets > AM_MAX_ROCKETS)
		other.ammo_rockets = AM_MAX_ROCKETS;

	if (other.ammo_cells > AM_MAX_CELLS)
		other.ammo_cells = AM_MAX_CELLS;
	
	if (other.ammo_bullets > AM_MAX_BULLETS)
		other.ammo_bullets = AM_MAX_BULLETS;
	
	if (other.ammo_bolts > AM_MAX_BOLTS)
		other.ammo_bolts = AM_MAX_BOLTS;
	
	if (other.ammo_slugs > AM_MAX_SLUGS)
		other.ammo_slugs = AM_MAX_SLUGS;
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
	float best, new, old;
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

	// Moved up so the targets are fired even in coop, but only once.
	activator = other;
	SUB_UseTargets();

	if (coop) {
		if (other.items & self.weapon || other.qccItems3 & self.weapon) {
			self.target = string_null;
			return;
		}
	}

	new = self.weapon;

	switch (self.weapon) {
		case IT_SHOTGUN:
		case IT_SUPER_SHOTGUN: {
			if (other.ammo_shells < 10)
				other.ammo_shells = 10;
			else
				other.ammo_shells += 1;
			break;
		}

		case IT_NAILGUN:
		case IT_SUPER_NAILGUN: {
			if (other.ammo_nails < 100)
				other.ammo_nails = 100;
			else
				other.ammo_nails += 10;
			break;
		}

		case IT_GRENADE_LAUNCHER:
		case IT_ROCKET_LAUNCHER: 
		case IT_PROXIMITY_GUN: {
			if (other.ammo_rockets < 10)
				other.ammo_rockets = 10;
			else
				other.ammo_rockets += 1;
			break;
		}

		case IT_LIGHTNING:
		case IT_LASER_CANNON:
		case IT_MJOLNIR: {
			if (other.ammo_cells < 100)
				other.ammo_cells = 100;
			else
				other.ammo_cells += 10;
			break;
		}

		case QCC_IT_HEAVYMACHINEGUN: {
			if (other.ammo_bullets < 100)
				other.ammo_bullets = 100;
			else
				other.ammo_bullets += 10;
			break;
		}

		case QCC_IT_TRIBOLT: {
			if (other.ammo_bolts < 10)
				other.ammo_bolts = 10;
			else
				other.ammo_bolts += 1;
			break;
		}

		case QCC_IT_RAILGUN: {
			if (other.ammo_slugs < 10)
				other.ammo_slugs = 10;
			else
				other.ammo_slugs += 1;
			break;
		}

		default:
			objerror ("weapon_touch: unknown classname");
	}

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

	// Remove it in single player, or set up for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;

	if (deathmatch || isHordeMode) {
		if (deathmatch == 2) // Duel
			self.nextthink = time + 5;
		else // Free For All or TDM
			self.nextthink = time + 1;
		self.think = SUB_regen;
	}
	else if (self.wait) {
		self.nextthink = time + self.wait;
		self.think = SUB_regen;
	}
	
	// QCC
	other.qccSpeakItem(other, self);
};