/*
================
ROCKET LAUNCHER
================
*/
void() T_MissileTouch = {
    // Don't explode on owner
	if (other == self.owner)
		return;
	
    // Don't touch Ghost Walker
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;

	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}

	float damg = 100;
	
	if (other.takedamage == DAMAGE_AIM) {
		if (other.qccFlags & QCC_FL_RESIST_ROCKET)
			damg = damg * 0.5;	// mostly immune
		T_Damage(other, self, self.owner, damg);
	}

	// Don't do radius damage to the other because all the damage was done in the impact
	T_RadiusDamage(self, self.owner, 120, other);

	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() W_FireRocket = {
	entity missile;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
		
	makevectors(self.v_angle);
	missile.velocity = aim(self, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = T_MissileTouch;
	
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel(missile, "progs/missile.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, self.origin + v_forward * 8 + self.view_ofs - '0 0 6');

	missile.qccFlags |= QCC_FL_THROWABLE;
	missile.qccFlags |= QCC_FL_CANDEFLECT;

	newmis = missile; // HIP: MED 11/09/96
};

/*
================
PICKUP
================
*/
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

void() qcc_item_slugs;
void() item_rockets = {
	// QCC: railgun ammo for Ziggurat Vertigo
	if (world.model == "maps/e1m8.bsp") {
		qcc_item_slugs();
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

	self.weapon = IT_ROCKETS;

	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_rockets";
	else
		self.netname = "rockets";
	setsize(self, '0 0 0', '32 32 56');
	StartItem();
};