/*
=============================================================================
				LEVEL CHANGING
=============================================================================
*/
float	intermission_running;
float	intermission_exittime;

// MG1
void intermission_clear_powerups(entity e) = {
    // Remove ID1 powerups
	e.items (-) IT_QUAD | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT;
    e.super_damage_finished = 0;
	e.super_time = 0;
	e.invisible_finished = 0;
	e.invisible_time = 0;
	e.invincible_finished = 0;
	e.invincible_time = 0;
	e.radsuit_finished = 0;
	e.rad_time = 0;

    // Remove HIP + ROGUE powerups
	self.items2 = self.items2 - (self.items2 & (HIP_IT_WETSUIT | HIP_IT_EMPATHY_SHIELDS | IT2_ANTIGRAV | IT2_SHIELD));
	self.gravity = 1.0;
    e.wetsuit_finished = 0;
    e.wetsuit_time = 0;
    e.empathy_finished = 0;
    e.empathy_time = 0;
    e.antigrav_finished = 0;
    e.antigrav_time = 0;
    e.shield_finished = 0;
    e.shield_time = 0;
};

float reset_flag;
 
void() SetChangeParms = {
    if (reset_flag) {
        setspawnparms(self);
		parm16 = self.qccChampion;
		parm15 = self.qccSkin;
        return;
	}

	if (self.health <= 0 || deathmatch) {
		SetNewParms();
		parm16 = self.qccChampion;
		parm15 = self.qccSkin;
		return;
	}
	// MG1
	if (world.worldtype == WORLDTYPE_HUB) {
		SetNewParms();
		parm16 = self.qccChampion;
		parm15 = self.qccSkin;
		return;
	}
 
	// Remove ID1 items
	self.items = self.items - (self.items & (IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD));
	
	// HIP / ROGUE items
	self.items2 = self.items2 - (self.items2 & (HIP_IT_WETSUIT | HIP_IT_EMPATHY_SHIELDS | IT2_ANTIGRAV | IT2_SHIELD));
	self.gravity = 1.0;

	// QCC: items3 used mostly for alt weapons
	self.qccItems3 = self.qccItems3 - (self.qccItems3 & (IT_PROXIMITY_GUN));
	
	// Cap super health in deathmatch (probably not needed)
	if (deathmatch && self.health > self.max_health)
		self.health = self.max_health;

	if (self.health < self.max_health / 2)
		self.health = self.max_health / 2;

	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;

	if (self.ammo_shells < 15)
		parm4 = 15;
	else
		parm4 = self.ammo_shells;

	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;

	// QCC: can't get old weapon back if we start a stage with an ability
	if (self.weapon != QCC_ABILITY)
		parm8 = self.weapon;
	else
		parm8 = self.qccPrevWep;
	
	parm9 = self.armortype * 100;
	parm10 = self.items2; // ROGUE

	// QCC Parms
	parm16 = self.qccChampion;
	parm15 = self.qccSkin;
	parm14 = self.qccItems3;
};

void() SetNewParms = {
	parm1 = IT_SHOTGUN | IT_AXE;
	if (skill == 3 && !deathmatch)
		parm2 = 50;
	else if (deathmatch)
		parm2 = 125;
	else
		parm2 = 100;
	parm3 = 0;
	parm4 = 15;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = 1;
	parm9 = 0;
	parm14 = 0;
	parm15 = self.qccSkin;
};

void() DecodeLevelParms = {
	// Take away all stuff on starting new episode
	// ID1 or MG1
	if (world.model == "maps/start.bsp" || world.worldtype == WORLDTYPE_HUB) {
		if (serverflags)
			SetNewParms();
	}
	// HIP
	else if (world.model == "maps/hip1m1.bsp" || world.model == "maps/hip2m1.bsp" || world.model == "maps/hip3m1.bsp")
		SetNewParms();
	// ROGUE
	else if (world.model == "maps/r2m1.bsp" && !deathmatch)
		SetNewParms();
	// MG1: Reset weapons between horde map loads
	else if (cvar("horde"))
		SetNewParms();
	
	self.items = parm1;
	self.health = parm2;
	if (self.health > 100)
		self.healthrot_nextcheck = time + 1;
	self.armorvalue = parm3;
	if (self.armorvalue > self.qccMaxArmor)
		self.qccArmorRot_nextcheck = time + 1;

	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weapon = parm8;
	self.armortype = parm9 * 0.01;
	self.items2 = parm10; // ROGUE

	// QCC Parms
	if (time < 3) {
		self.qccChampion = parm16;
		self.qccNextChampion = parm16;
	}
	self.qccSkin = parm15;
	self.qccItems3 = parm14;
};

string() HordeRandomMap = {	
	if (mapname == "horde1")
		return "horde2";
	else if (mapname == "horde2")
		return "horde3";
	else if (mapname == "horde3")
		return "horde4";
	else
		return "horde1";
};

string nextmap;

void() GotoNextMap = {
	// QCC
	entity pl;
	pl = find(world, classname, "player");
	while (pl != world) {
		stuffcmd(pl, "v_cshift 1 1 1 1\n"); // Reset view color before entering next level
		pl = find(pl, classname, "player");
	}

	if (cvar("samelevel"))	// If samelevel is set, stay on same level
		changelevel (mapname);
	else {
		if (cvar("horde")) // MG1
			changelevel(HordeRandomMap());
		else
			changelevel (nextmap);
	}
};