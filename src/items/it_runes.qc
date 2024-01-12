/*
===============================================================================
END OF LEVEL RUNES
===============================================================================
*/
void() sigil_touch = {
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;	
	// QCC: Nyx can't pick up stuff during Ghost Walk
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;
	
	if (ExtSupported("EX_CENTERPRINT"))
		centerprint(other, "$qc_got_rune");
	else
		centerprint (other, "You got the rune!");

	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	self.solid = SOLID_NOT;
	self.model = string_null;
	serverflags = serverflags | (self.spawnflags & 15);

	// QCC: Duke's got a lot to say
	if (other.qccChampion == QCC_DUKENUKEM)
		QCC_DukeItem(other, self);

	self.classname = string_null;	// so rune doors won't find it	
	activator = other;
	SUB_UseTargets();
};

// MG1 runes behave differently than ID1 runes
void() item_sigil2;

// End of level sigil, pick up to end episode and return to Start Map.
void() item_sigil = {
	// MG1 uses special runes, make sure they stay special
	if (world.model == "maps/hub.bsp" || world.model == "maps/mge1m2.bsp" || world.model == "maps/mge2m2.bsp" || 
        world.model == "maps/mge3m2.bsp" || world.model == "maps/mge4m2.bsp" || world.model == "maps/mge5m2.bsp")
	{
		item_sigil2();
		return;
	}

	if (!self.spawnflags)
		objerror ("no spawnflags");

	precache_sound("misc/runekey.wav");
	self.noise = "misc/runekey.wav";

	if (self.spawnflags & 1) {
		precache_model("progs/end1.mdl");
		setmodel(self, "progs/end1.mdl");
	}
	if (self.spawnflags & 2) {
		precache_model2("progs/end2.mdl");
		setmodel(self, "progs/end2.mdl");
	}
	if (self.spawnflags & 4) {
		precache_model2("progs/end3.mdl");
		setmodel(self, "progs/end3.mdl");
	}
	if (self.spawnflags & 8) {
		precache_model2("progs/end4.mdl");
		setmodel(self, "progs/end4.mdl");
	}
	
	self.touch = sigil_touch;
	setsize(self, '-16 -16 -24', '16 16 32');
	StartItem();

	self.qccFlags |= QCC_FL_THROWABLE;
};

/*
===============================================================================
DIMENSION OF THE MACHINE RUNES
===============================================================================
*/

float SIGIL_ALL = SIGIL_E1 | SIGIL_E2 | SIGIL_E3 | SIGIL_E4 | SIGIL_E5;
float SIGIL_ALL_ALL_ALLLL = SIGIL_E1 | SIGIL_E2 | SIGIL_E3 | SIGIL_E4 | SIGIL_E5 | SIGIL_E6;

void() sigil2_touch = {
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	// QCC: Nyx can't pick up stuff during Ghost Walk
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;

	centerprint_all (self.netname); // Netname is localized

	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	self.solid = SOLID_NOT;
	self.model = string_null;
    float lastPickup = SUB_LeftShift(self.spawnflags & SIGIL_ALL, SIGIL_NUMBITS);
    serverflags = serverflags | (self.spawnflags & SIGIL_ALL) | lastPickup;
	
	if (cvar("horde") && (self.spawnflags & SIGIL_E2)) { // Hunger
		entity e;
		e = find(world, classname, "player");
		while (e) {
			e.hunger_time = time + HUNGER_MAX;
			dprint("hunger time is: ");
			dprint(ftos(e.hunger_time));
			dprint("\n");
			e = find(e, classname, "player");
		}
	}
	
	activator = other;
	SUB_UseTargets();
};

float sigil_getLastPickup() {
    float lastPickup = SUB_RightShift(serverflags, SIGIL_NUMBITS) & SIGIL_ALL;
    return lastPickup;
}

void sigil_clearLastPickup() {
    serverflags = serverflags & ~SUB_LeftShift(SIGIL_ALL, SIGIL_NUMBITS);
}

void() item_sigil2 = {
	dprint("SPAWNING SIGIL: ");
	dprint(ftos(self.spawnflags));
	dprint("\n");
	if (!self.spawnflags)
		self.spawnflags|= SIGIL_E1;

	precache_sound("misc/runekey.wav");
	self.noise = "misc/runekey.wav";

    string tempmdl = string_null;

	if (self.spawnflags & SIGIL_E1) {
        self.spawnflags = SIGIL_E1;
		tempmdl = "progs/mg1_rune1.mdl";
		self.netname = "$qc_mg1_pickup_rune1";
	}
	else if (self.spawnflags & SIGIL_E2) {
		self.spawnflags = SIGIL_E2;
        tempmdl = "progs/mg1_rune2.mdl";
		self.netname = "$qc_mg1_pickup_rune2";
	}
	else if (self.spawnflags & SIGIL_E3) {
		self.spawnflags = SIGIL_E3;
        tempmdl = "progs/mg1_rune3.mdl";
		self.netname = "$qc_mg1_pickup_rune3";
	}
	else if (self.spawnflags & SIGIL_E4) {
		self.spawnflags = SIGIL_E4;
        tempmdl = "progs/mg1_rune4.mdl";
		self.netname = "$qc_mg1_pickup_rune4";
	}
	else if (self.spawnflags & SIGIL_E5) {
		self.spawnflags = SIGIL_E5;
        tempmdl = "progs/mg1_rune5.mdl";
		self.netname = "$qc_mg1_pickup_rune5";
	}
	else if (self.spawnflags & SIGIL_E6) {
		self.spawnflags = SIGIL_E6;
        tempmdl = "progs/mg1_rune6.mdl";
		self.netname = "$qc_mg1_pickup_rune6";
	}    

	dprint("PREP SIGIL\n");

    precache_model(tempmdl);
    setmodel(self, tempmdl);

	self.touch = sigil2_touch;
	setsize(self, '-16 -16 -24', '16 16 32');
	StartItem();

	self.qccFlags |= QCC_FL_THROWABLE;
};

const float RUNE_INDICATOR_ACTIVE = 1024;

void() misc_rune_indicator_use = {
	self.alpha = 1.0;
	SUB_UseTargets();
}

void() misc_rune_indicator = {
	float active = self.spawnflags & RUNE_INDICATOR_ACTIVE ? TRUE : FALSE;
	self.spawnflags (-) RUNE_INDICATOR_ACTIVE;
	if (!self.spawnflags)
		self.spawnflags|= SIGIL_E1;
	self.spawnflags &= SIGIL_ALL_ALL_ALLLL;

    string mdl = string_null;

	if (self.spawnflags & SIGIL_E1) {
        self.spawnflags = SIGIL_E1;
		mdl = "progs/mg1_rune1.mdl";
	}
	else if (self.spawnflags & SIGIL_E2) {
		self.spawnflags = SIGIL_E2;
        mdl = "progs/mg1_rune2.mdl";
	}
	else if (self.spawnflags & SIGIL_E3) {
		self.spawnflags = SIGIL_E3;
        mdl = "progs/mg1_rune3.mdl";
	}
	else if (self.spawnflags & SIGIL_E4) {
		self.spawnflags = SIGIL_E4;
        mdl = "progs/mg1_rune4.mdl";
	}
	else if (self.spawnflags & SIGIL_E5) {
		self.spawnflags = SIGIL_E5;
        mdl = "progs/mg1_rune5.mdl";
	}
	else if (self.spawnflags & SIGIL_E6) {
		self.spawnflags = SIGIL_E6;
        mdl = "progs/mg1_rune6.mdl";
	}
    
    precache_model(mdl);
    setmodel(self, mdl);

	self.use = misc_rune_indicator_use;

	if (((self.spawnflags & serverflags) == self.spawnflags) || active) {
		self.think = SUB_UseTargets;
		self.nextthink = time + 0.2;
	}
	else //Show a ghost of the rune before you collect it.
		self.alpha = 0.2;
};