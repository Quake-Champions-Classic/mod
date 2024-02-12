void CheatCommand() {
	if ((deathmatch || coop) && cheats_allowed == FALSE) // mal: allow impulse 9 IF cheats allowed
		return;

	self.ammo_rockets = 25;
	self.ammo_nails = 150;
	self.ammo_shells = 25;
	self.items = self.items | 
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_LIGHTNING |
		IT_KEY1 | IT_KEY2;

	self.ammo_cells = 150;

	// HIP: MED ---------------------------------------
	self.items = self.items | IT_LASER_CANNON;
   	//self.items = self.items | IT_MJOLNIR;
   	self.qccItems3 = self.qccItems3 | IT_PROXIMITY_GUN;
	
	// QUAKE CHAMPIONS CLASSIC ------------------------
	self.health = 175;
	self.healthrot_nextcheck = time + 3;
	self.armorvalue = self.qccMaxArmor + 75;
	self.qccArmorRot_nextcheck = time + 3;
	self.ammo_bullets = 150;
	self.ammo_bolts = 15;
	self.ammo_slugs = 10;
	self.items = self.items | QCC_IT_RAILGUN;
	self.qccAbilityTimer = 0;
	// ------------------------------------------------

	self.impulse = 0;
	W_SetCurrentAmmo();
};

void() ServerflagsCommand = {
	serverflags = serverflags * 2 + 1;
};

void() QuadCheat = {
	if (!cheats_allowed)
		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	dprint ("quad cheat\n");
};

void() WetsuitCheat = {
	if (deathmatch || coop)
		return;
	self.items2 = self.items2 | HIP_IT_WETSUIT;
	self.wetsuit_time = 1;
	self.wetsuit_finished = time + 30;
	if (ExtSupported("EX_BPRINT"))
		bprint("$qc_wetsuit_cheat");
	else
		bprint("wetsuit cheat\n");
};

void() EmpathyShieldsCheat = {
	if (deathmatch || coop)
		return;
	self.items2 = self.items2 | HIP_IT_EMPATHY_SHIELDS;
	self.empathy_time = 1;
	self.empathy_finished = time + 30;
	if (ExtSupported("EX_BPRINT"))
		bprint("$qc_empathy_cheat");
	else
		bprint("empathy shields cheat\n");
};

void() DumpEntities = {
	float i = 1;
    entity head = nextent(world);
	while (head!=world)	{
		dprint(ftos(i));
		dprint(" ");
		dprint(head.classname);
		dprint("\n");
		head = nextent(head);
		i = i + 1;
	}
};

void() DumpLiveEntities = {
	float i = 1;
	entity head = nextent(world);
	while (head != world) {
		if (head.health > 0) {
			dprint(ftos(i));
			dprint(" ");
			dprint(head.classname);
			dprint(" ");
			dprint(vtos(head.origin));
			dprint("\n");
			dprint("--------------------\n");
		}
		head = nextent(head);
		i = i + 1;
	}
};

void() Genocide = {
	if (deathmatch || coop)
		return;
    
	if (ExtSupported("EX_BPRINT"))
		bprint("$qc_genocide_cheat");
	else
		bprint("Genocide!\n");
    
	entity head = nextent(world);
	while (head!=world) {
      	if ((head.health > 0) && (head.flags & FL_MONSTER))
        	T_Damage(head, world, world, head.health + 10);
    	head = nextent(head);
    }
};

float dump_coord;

void () ToggleDump = {
	dump_coord = 1 - dump_coord;
	if (dump_coord == TRUE) {
		if (ExtSupported("EX_BPRINT"))
			bprint("$qc_dump_player_loc");
		else
			bprint("Dumping Player Location\n");
	}
};

void () DumpCoordinates = {
   	entity pl = checkclient();
   	if (pl) {
     	bprint("Player: ");
    	bprint(vtos(pl.origin));
      	bprint("\n");
    }
};

void() ImpulseCommands = {
	if (self.impulse >= 1 && self.impulse <= 8)
		W_ChangeWeapon();
	else if (self.impulse == 10)
		CycleWeaponCommand();
	else if (self.impulse == 12)
		CycleWeaponReverseCommand();	
	// QUAKE CHAMPIONS CLASSIC -------------------
	else if (self.impulse == QCC_IM_RAILGUN)
		W_ChangeWeapon();
	else if (self.impulse == QCC_IM_ABILITY && self.health > 0)
		QCC_FireAbility();
	else if (self.impulse == QCC_IM_INTERACT)
		self.qccInteractFunc();
	else if (self.impulse == QCC_IM_PICK_CHAMP)
		QCC_PickChampion(1);
	else if (self.impulse == QCC_IM_PREV_CHAMP)
		QCC_PickChampion(-1);
	else if (self.impulse == QCC_IM_SKIN)
		self.qccSkinFunc();
	else if (self.impulse == QCC_IM_OBSERVER)
		QCC_Observer();
	// HIP ---------------------------------------
	else if (self.impulse >= 36 && self.impulse <= 39)
		W_ChangeWeapon();
	// -------------------------------------------
	else if (self.impulse == 9)
		CheatCommand();
	else if (self.impulse == 255)
		QuadCheat();
	else if (self.impulse == 11)
		ServerflagsCommand();
	
	self.impulse = 0;
};