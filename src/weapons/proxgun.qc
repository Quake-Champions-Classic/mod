/*
===========================
PROXIMITY GUN
===========================
*/
void() ProximityExplode = {
   	T_RadiusDamage(self, self.owner, 95, world);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	BecomeExplosion();
};

float NumProximityGrenades;

void() ProximityGrenadeExplode = {
	self.takedamage = DAMAGE_NO;
	NumProximityGrenades = NumProximityGrenades - 1;
	self.deathtype = "exploding";
	self.nextthink = time + 0.1;
	self.owner = self.lastvictim;
	self.think = ProximityExplode;
};

void() ProximityGrenadeTouch = {
	// Don't explode on owner
    if (other == self)
		return;
    // Don't blow up from other prox grenades
	if (other.classname == self.classname)
		return;
    
	self.movetype = MOVETYPE_TOSS;

	if (self.state == 1)
		return;
    
	if (vlen(other.velocity) > 0) {
		ProximityGrenadeExplode();
		self.think();
		return;
	}

	if (other.takedamage == DAMAGE_AIM) {
		ProximityGrenadeExplode();
		self.think();
		return;
	}

	sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
	self.movetype = MOVETYPE_NONE;
	setsize(self, '-8 -8 -8', '8 8 8');
	self.state = 1;
	self.spawnmaster = other;
};

void() ProximityBomb = {
	entity head;
	float blowup;

	if (time > self.delay || NumProximityGrenades > 15 || vlen(self.spawnmaster.velocity) > 0)	{
		ProximityGrenadeExplode();
		self.think();
		return;
	}

	self.owner = world;
	self.takedamage = DAMAGE_YES;

	head = findradius(self.origin, 140);    
	blowup = FALSE;
	while (head) {
		if (head != self && head.health > 0 && (head.flags & (FL_CLIENT|FL_MONSTER)) && head.classname != self.classname)
			blowup = TRUE;
		if (head.classname == self.classname && head.state == 0)
			blowup = TRUE;
        
		traceline(self.origin, head.origin, TRUE, self);
		if (trace_fraction != 1.0)
			blowup = FALSE;
        
		if (blowup == TRUE) {
			sound(self, CHAN_WEAPON, "hipweap/proxwarn.wav", 1, ATTN_NORM);
			ProximityGrenadeExplode();
			self.nextthink = time + 0.5;
			return;
		}

		head = head.chain;
	}

	self.nextthink = time + 0.25;
};

void() W_FireProximityGrenade = {
	entity missile;

	NumProximityGrenades = NumProximityGrenades + 1;
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	sound(self, CHAN_WEAPON, "hipweap/proxbomb.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;

	missile = spawn();
	missile.owner = self;
	missile.lastvictim = self;
	missile.movetype = MOVETYPE_TOSS;
	missile.solid = SOLID_BBOX;
	missile.classname = "proximity_grenade";
	missile.takedamage = DAMAGE_NO;
	missile.health = 5;
	missile.state = 0;

	makevectors(self.v_angle);
	if (self.v_angle_x)
		missile.velocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 10 + crandom() * v_up * 10;
	else {
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '100 600 100';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = ProximityGrenadeTouch;
    
	missile.nextthink = time + 2;
	missile.delay = time + 15 + (10*random());
	missile.think = ProximityBomb;
	missile.th_die = ProximityGrenadeExplode;

	setmodel(missile, "progs/proxbomb.mdl");
	setorigin(missile, self.origin);
	setsize(missile, '-1 -1 -1', '1 1 1');
};

/*
================
PICKUP
================
*/
void() weapon_proximity_gun = {
	precache_model("progs/g_prox.mdl");
	setmodel(self, "progs/g_prox.mdl");
	self.weapon = IT_PROXIMITY_GUN;
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_prox_gun";
	else
		self.netname = "Proximity Gun";
	self.qccItems3 = IT_PROXIMITY_GUN;
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};