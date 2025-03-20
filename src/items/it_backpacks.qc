/*
===============================================================================
PLAYER BACKPACKS
===============================================================================
*/
void() BackpackTouch = {
	float best, old, new, acount;
	entity stemp;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;	
	// QCC: Nyx can't pick up stuff during Ghost Walk
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;
		
    if (ExtSupported("EX_SPRINT"))
        sprint(other, "$qc_backpack_got");
    else
		sprint(other, "You get ");
    
    acount = 0;
	if (self.items)	{	
		if ((other.items & self.items) == 0) {
			acount = 1;
			if (ExtSupported("EX_SPRINT"))
				sprint(other, "{}", self.netname);
			else {
				sprint(other, "the ");
				sprint(other, self.netname);
			}
		}
 	}

	// If the player was using his best weapon, change up to the new one if better          
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;

	// Change weapons
	other.ammo_shells += self.ammo_shells;
	other.ammo_nails += self.ammo_nails;
	other.ammo_rockets += self.ammo_rockets;
	other.ammo_cells += self.ammo_cells;
	other.ammo_bullets += self.ammo_bullets;
	other.ammo_bolts += self.ammo_bolts;
	other.ammo_slugs += self.ammo_slugs;

	new = self.items;
	if (!new)
		new = other.weapon;
	old = other.items;
	other.items = other.items | self.items;
	
	bound_other_ammo();

	if (self.ammo_bullets) {
		if (acount)
			sprint(other, ", ");
		acount = 1;
		sprint(other, ftos(self.ammo_bullets));
		sprint(other, " bullets");
	}

	if (self.ammo_shells) {
		if (acount)
			sprint(other, ", ");
		acount = 1;

		if (ExtSupported("EX_SPRINT"))
			sprint(other, "$qc_backpack_shells", ftos(self.ammo_shells));
		else {
			sprint(other, ftos(self.ammo_shells));
			sprint(other, " shells");
		}
	}

	if (self.ammo_nails) {
		if (acount)
			sprint(other, ", ");
		acount = 1;

		if (ExtSupported("EX_SPRINT"))
			sprint(other, "$qc_backpack_nails", ftos(self.ammo_nails));
		else {
			sprint(other, ftos(self.ammo_nails));
			sprint(other, " nails");
		}
	}

	if (self.ammo_bolts) {
		if (acount)
			sprint(other, ", ");
		acount = 1;
		sprint(other, ftos(self.ammo_bolts));
		sprint(other, " bolts");
	}

	if (self.ammo_rockets) {
		if (acount)
			sprint(other, ", ");
		acount = 1;

		if (ExtSupported("EX_SPRINT"))
			sprint(other, "$qc_backpack_rockets", ftos(self.ammo_rockets));
		else {
			sprint(other, ftos(self.ammo_rockets));
			sprint(other, " rockets");
		}
	}

	if (self.ammo_cells) {
		if (acount)
			sprint(other, ", ");
		acount = 1;

		if (ExtSupported("EX_SPRINT"))
			sprint(other, "$qc_backpack_cells", ftos(self.ammo_cells));
		else {
			sprint(other, ftos(self.ammo_cells));
			sprint(other, " cells");
		}
	}

	if (self.ammo_slugs) {
		if (acount)
			sprint(other, ", ");
		acount = 1;
		sprint(other, ftos(self.ammo_slugs));
		sprint(other, " slugs");
	}
	
	sprint(other, "\n");
	sound(other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	remove(self);
	self = other;
	
	// Change to the weapon
	if (W_WantsToChangeWeapon(other, old, other.items) == 1) {
		if (self.flags & FL_INWATER) {
			if (new != IT_LIGHTNING)
				Deathmatch_Weapon (old, new);
		}
		else              
			Deathmatch_Weapon (old, new);
	}
	W_SetCurrentAmmo ();
};

/*
===============
DropBackpack
===============
*/
void() DropBackpack = {
	entity item;

	// MG1: Don't drop backpacks in horde mode
	if (horde_ent)
		return; 

    // Nothing in it
	if (!(self.ammo_bullets + self.ammo_shells + self.ammo_nails + self.ammo_bolts + self.ammo_rockets + self.ammo_cells + self.ammo_slugs))
		return;

	item = spawn();
	item.origin = self.origin - '0 0 24';	
	item.items = self.weapon;
	item.classname = "item_backpack"; // added for bots.

	if (ExtSupported("EX_SPRINT")) {
		if (item.items == IT_AXE)
			item.netname = "$qc_axe";
		else if (item.items == QCC_IT_HEAVYMACHINEGUN)
			item.netname = "Heavy Machine Gun";
		else if (item.items == IT_SHOTGUN)
			item.netname = "$qc_shotgun";
		else if (item.items == IT_SUPER_SHOTGUN)
			item.netname = "$qc_double_shotgun";
		else if (item.items == IT_NAILGUN)
			item.netname = "$qc_nailgun";
		else if (item.items == IT_SUPER_NAILGUN)
			item.netname = "$qc_super_nailgun";
		else if (item.items == IT_GRENADE_LAUNCHER)
			item.netname = "$qc_grenade_launcher";
		else if (item.items == IT_ROCKET_LAUNCHER)
			item.netname = "$qc_rocket_launcher";
		else if (item.items == IT_LIGHTNING)
			item.netname = "$qc_thunderbolt";
		// HIP
		else if (item.items == IT_LASER_CANNON)
			item.netname = "$qc_laser_cannon";
		else if (item.items == IT_PROXIMITY_GUN)
			item.netname = "$qc_prox_gun";
		else if (item.items == IT_MJOLNIR)
			item.netname = "$qc_mjolnir";
		// QCC
		else if (item.items == QCC_IT_RAILGUN)
			item.netname = "Railgun";
		else
			item.netname = "";
	}
	else {
		if (item.items == IT_AXE)
			item.netname = "Axe";
		else if (item.items == QCC_IT_HEAVYMACHINEGUN)
			item.netname = "Heavy Machine Gun";
		else if (item.items == IT_SHOTGUN)
			item.netname = "Shotgun";
		else if (item.items == IT_SUPER_SHOTGUN)
			item.netname = "Double-barrelled Shotgun";
		else if (item.items == IT_NAILGUN)
			item.netname = "Nailgun";
		else if (item.items == IT_SUPER_NAILGUN)
			item.netname = "Super Nailgun";
		else if (item.items == IT_GRENADE_LAUNCHER)
			item.netname = "Grenade Launcher";
		else if (item.items == IT_ROCKET_LAUNCHER)
			item.netname = "Rocket Launcher";
		else if (item.items == IT_LIGHTNING)
			item.netname = "Thunderbolt";
		// HIP
		else if (item.items == IT_LASER_CANNON)
			item.netname = "Laser Cannon";
		else if (item.items == IT_PROXIMITY_GUN)
			item.netname = "Proximity Gun";
		else if (item.items == IT_MJOLNIR)
			item.netname = "Mjolnir";
		// QCC
		else if (item.items == QCC_IT_RAILGUN)
			item.netname = "Railgun";
		else
			item.netname = "";
	}

	item.ammo_bullets = self.ammo_bullets;
	item.ammo_shells = self.ammo_shells;
	item.ammo_nails = self.ammo_nails;
	item.ammo_bolts = self.ammo_bolts;
	item.ammo_rockets = self.ammo_rockets;
	item.ammo_cells = self.ammo_cells;
	item.ammo_slugs = self.ammo_slugs;

	// Include some ammo in the backpack if the weapon is being given
	if (item.ammo_bullets < 20 && item.items == QCC_IT_HEAVYMACHINEGUN) {
		item.ammo_bullets = 20;
	}
	if (item.ammo_shells < 5 && (item.items == IT_SHOTGUN || item.items == IT_SUPER_SHOTGUN)) {
		item.ammo_shells = 5;
	}
	if (item.ammo_nails < 20 && (item.items == IT_NAILGUN || item.items == IT_SUPER_NAILGUN)) {
		item.ammo_nails = 20;
	}
	if  (item.ammo_bolts < 5 && item.items == QCC_IT_TRIBOLT) {
		item.ammo_bolts = 5;
	}
	if (item.ammo_rockets < 5 && (item.items == IT_GRENADE_LAUNCHER || item.items == IT_ROCKET_LAUNCHER)) {
		item.ammo_rockets = 5;
	}
	if (item.ammo_cells < 20 && (item.items == IT_LIGHTNING || item.items == IT_LASER_CANNON || item.items == IT_MJOLNIR)) {
		item.ammo_cells = 20;
	}
	if (item.ammo_slugs < 5 && item.items == QCC_IT_RAILGUN) {
		item.ammo_slugs = 5;
	}

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel(item, "progs/backpack.mdl");
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = BackpackTouch;
	
	item.nextthink = time + 120;
	item.think = SUB_Remove;
};