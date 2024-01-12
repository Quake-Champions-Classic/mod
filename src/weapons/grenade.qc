void() GrenadeExplode = {
	T_RadiusDamage(self, self.owner, 120, self.lastvictim);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	BecomeExplosion();
};

void() GrenadeTouch = {
    // Don't explode on owner
	if (other == self.owner)
		return;
	
	// Don't touch Ghost Walker
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;
	
	float damg = 100;

	if (other.takedamage == DAMAGE_AIM) {
		if (other.qccFlags & QCC_FL_RESIST_ROCKET)
			damg = damg * 0.5;	// mostly immune
		T_Damage(other, self, self.owner, damg);
		self.lastvictim = other;
		GrenadeExplode();
		return;
	}

	sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);

	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

void() W_FireGrenade = {
	entity missile;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound(self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";	

	makevectors(self.v_angle);
	if (self.v_angle_x)
		missile.velocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 10 + crandom() * v_up * 10;
	else {
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);

	missile.touch = GrenadeTouch;
	
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;
	missile.lastvictim = world;

	setmodel(missile, "progs/grenade.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, self.origin);

	missile.qccFlags |= QCC_FL_THROWABLE;
	missile.qccFlags |= QCC_FL_CANDEFLECT;
};