/*
================
HEAVY MACHINE GUN
================
*/
void(float damage, vector direction, vector spread) FireBullet = {
	vector dir, org, vel;

	makevectors(self.v_angle);

	org = self.origin + v_forward * 10;
	org_z = self.absmin_z + self.size_z * 0.7;

	dir = direction + crandom() * spread_x * v_right + crandom() * spread_y * v_up;

	traceline(org, org + dir * 2048, FALSE, self);
	if (trace_fraction != 1.0) {
		vel = normalize(dir + v_up*crandom() + v_right*crandom());
		vel = vel + 2 * trace_plane_normal;
		vel = vel * 200;

		org = trace_endpos - dir * 4;

		if (trace_ent.takedamage && other.classname != "monster_boss") { // yoder mod, jan 05 2021
			SpawnBlood(org, vel * 0.2, damage);
			T_Damage(trace_ent, self, self, damage);
		}
		else {
			WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte(MSG_BROADCAST, TE_GUNSHOT);
			WriteCoord(MSG_BROADCAST, org_x);
			WriteCoord(MSG_BROADCAST, org_y);
			WriteCoord(MSG_BROADCAST, org_z);
		}
	}
};

void() W_FireHeavyMachineGun = {
	vector dir;
	
	makevectors(self.v_angle);
	
	if (self.ammo_bullets < 1) {
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		return;
	}

	self.currentammo = self.ammo_bullets = self.ammo_bullets - 1;
	self.attack_finished = time + 0.2;

	dir = aim(self, 100000);
	FireBullet(9, dir, '0.02 0.02 0');
	
    sound(self, CHAN_WEAPON, "weapons/hmgshot.wav", 1, ATTN_NORM);
	self.punchangle_x = -1;
};

/*
================
PICKUP
================
*/
void() qcc_weapon_heavymachinegun = {
	setmodel(self, "progs/g_hmg.mdl");
	self.weapon = QCC_IT_HEAVYMACHINEGUN;
	self.netname = "Heavy Machine Gun";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() qcc_item_bullets = {
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2) {
		precache_model("maps/b_shell1.bsp");
		setmodel(self, "maps/b_shell1.bsp");
		self.aflag = 50;
	}
	else {
		precache_model("maps/b_shell0.bsp");
		setmodel(self, "maps/b_shell0.bsp");
		self.aflag = 25;
	}
	self.qccItems3 = QCC_IT2_BULLETS;

	if (ExtSupported("EX_SPRINT"))
		self.netname = "bullets";
	else
		self.netname = "bullets";
    
	setsize(self, '0 0 0', '32 32 56');
	StartItem();
};