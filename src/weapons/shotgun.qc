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

	if (self.currentammo == 1) {
		W_FireShotgun ();
		return;
	}
		
	sound(self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
	self.punchangle_x = -4;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	dir = aim(self, 100000);
	FireBullets(30, dir, '0.14 0.08 0');
};