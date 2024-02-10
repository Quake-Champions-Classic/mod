// multi_weapons.qc
// pmack
// sept 96

//=============================================================================
// Multi Rocket Code
//=============================================================================
void() MultiRocketExplode = {
	float damg;
	damg = 60;

	if (other.health) {
		if (other.qccFlags & QCC_FL_RESIST_ROCKET)
			damg = damg * 0.5;	// mostly immune
		T_Damage(other, self, self.owner, damg);
	}

	T_RadiusDamage(self, self.owner, 75, other);
	self.origin = self.origin - 8 * normalize(self.velocity);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() MultiRocketTouch = {
	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}

	MultiRocketExplode ();
};

void() HomingMissileThink = {
	vector dir;

	if (self.enemy.health < 1) {
		remove(self);
		return;
	}

	dir = normalize(self.enemy.origin - self.origin);
	self.velocity = dir * 1000;
	self.nextthink = time + 0.1;
	self.think = HomingMissileThink;	
};

void() HomingMissileAcquire = {
	vector	oldVelocity;
	vector	aimangle;

	if (self.delay < time) {
		MultiRocketExplode ();
		return;
	}

	oldVelocity = self.velocity;
	makevectors(self.v_angle);
	self.velocity = aim(self, 1000);
	self.velocity = self.velocity * 1000;

	aimangle = self.origin + self.velocity;	
	traceline(self.origin, aimangle, FALSE, self);
	if (trace_fraction < 1) {
		if (trace_ent.flags & FL_MONSTER) {
			self.enemy = trace_ent;
			HomingMissileThink();
			return;
		}
	}
	
	self.velocity = oldVelocity;
	self.v_angle = vectoangles (self.velocity);
	self.angles = self.v_angle;
	self.think = HomingMissileAcquire;
	self.nextthink = time + 0.2;
};

void(float offset, float frameNum) MultiRocketLaunch = {
	entity 	missile;
	vector	aimangle;
	
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "MultiRocket";
	missile.delay = time + 4;
	missile.frame = frameNum;
	missile.touch = MultiRocketTouch;

	if (deathmatch || coop)
		setmodel(missile, "progs/rockup_d.mdl");
	else
		setmodel(missile, "progs/rockup.mdl");

	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, self.origin + v_forward*8 + '0 0 16');
	
	if (coop || deathmatch) {
		aimangle = self.v_angle;
		aimangle_y = aimangle_y + (offset * 0.66);
		makevectors(aimangle);
		missile.velocity = aim(self, 1000);
		missile.velocity = missile.velocity * 1000;
		missile.angles = vectoangles(missile.velocity);

		missile.think = MultiRocketExplode;
		missile.nextthink = time + 4;
	}
	else {
		makevectors(self.v_angle);
		missile.velocity = v_forward * 1000 - v_right*offset*8;
		missile.angles = vectoangles(missile.velocity);
		missile.v_angle = self.v_angle;	

		aimangle = missile.origin + missile.velocity;
		traceline(missile.origin, aimangle, FALSE, self);
		if (trace_fraction < 1) {
			if (trace_ent.flags & FL_MONSTER) {
				missile.enemy = trace_ent;
				missile.think = HomingMissileThink;
				return;
			}
		}

		missile.think = HomingMissileAcquire;
		missile.nextthink = time + 0.1;
	}
};

void() W_FireMultiRocket = {	
	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;	
	MultiRocketLaunch (-10, 2);
	MultiRocketLaunch (-5, 3);
	MultiRocketLaunch (5, 0);
	MultiRocketLaunch (10, 1);
};

/*
================
PICKUP
================
*/
void() item_multi_rockets = {
	item_rockets();
};