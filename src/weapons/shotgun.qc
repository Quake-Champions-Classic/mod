/*
================
FireBullets
Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread) FireBullets = {
	vector direction, src;
	makevectors(self.v_angle);
	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();
	while (shotcount > 0) {
		direction = dir + crandom() * spread_x * v_right + crandom() * spread_y * v_up;
		traceline(src, src + direction * 2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack(4, direction);
		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
};

void() W_FireShotgun = {
	vector dir;

	sound(self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim(self, 100000);
	FireBullets(10, dir, '0.04 0.04 0');
};

void() W_FireSuperShotgun = {
	vector dir;
		
	sound(self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
	self.punchangle_x = -4;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim(self, 100000);
	FireBullets(30, dir, '0.14 0.08 0');
};

void() player_shot1;

void() W_Shotgun_Attack = {
	if (self.items & IT_SUPER_SHOTGUN) {
		player_shot1();
		W_FireSuperShotgun();
		self.attack_finished = time + 0.7;
	}
	else {
		player_shot1();
		W_FireShotgun();
		self.attack_finished = time + 0.5;
	}
}

/*
================
PICKUP
================
*/
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
	self.weapon = IT_SHELLS;

	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_shells";
	else
		self.netname = "shells";
    
	setsize(self, '0 0 0', '32 32 56');
	StartItem();
};