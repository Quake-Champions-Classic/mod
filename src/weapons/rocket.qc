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