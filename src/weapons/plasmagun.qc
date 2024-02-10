//=============================================================================
// Plasma Gun Code
//=============================================================================
void(vector p1, vector p2, entity from, float damage) PlasmaDamage = {
	float tx;
	entity e1, e2;
	vector f;
	
	f = p2 - p1;
	f = normalize(f);
	tx = f_x;
	f_x = 0 - f_y;
	f_y = tx;
	f_z = 0;
	f = f * 16;

	e1 = e2 = world;

	traceline(p1, p2, FALSE, self);
	if (trace_ent.takedamage && !trace_ent.wetsuit_finished) {
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from.owner, damage);
		if (self.classname == "player" && other.classname == "player")
			trace_ent.velocity_z += 400;
	}
	e1 = trace_ent;

	traceline(p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage && !trace_ent.wetsuit_finished) { // HIP: JIM
		particle(trace_endpos, '0 0 100', 225, damage * 4);
		T_Damage(trace_ent, from, from.owner, damage);
	}
	e2 = trace_ent;

	traceline(p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage && !trace_ent.wetsuit_finished) { // HIP: JIM
		particle(trace_endpos, '0 0 100', 225, damage * 4);
		T_Damage(trace_ent, from, from.owner, damage);
	}
};

//================================
//================================
void(entity current, float doDamage) PlasmaDischarge = {
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity(MSG_BROADCAST, current);
	WriteCoord(MSG_BROADCAST, current.origin_x);
	WriteCoord(MSG_BROADCAST, current.origin_y);
	WriteCoord(MSG_BROADCAST, current.origin_z);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	sound(self, CHAN_VOICE, "weapons/lhit.wav", 1, ATTN_NORM);
	if (doDamage == 1)
        PlasmaDamage(self.origin, current.origin, self, 50);
};

//================================
//================================
void() PlasmaGroundOut = {
	entity	current, start;
	float		monstersHit;
	
	monstersHit = 0;
	current = findradius (self.origin, 320);
	start = current;
	while (monstersHit < 5) {
		if (current.flags & FL_MONSTER || current.classname == "player") {
			if (current != self.owner) {
				traceline(self.origin, current.origin, TRUE, world);
				if (trace_fraction == 1) {
					monstersHit = monstersHit + 1;
					PlasmaDischarge(current, 1);
				}
			}
		}
		current = current.chain;
		if (start == current || !current)
			return;
	}
};

//================================
//================================
void() PlasmaTouch = {
	float	damg;

	if (other == self.owner)
		return;	// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}

	damg = 80 + random()*20;
	sound(self, CHAN_WEAPON, "plasma/explode.wav", 1, ATTN_NORM);
	
	if (other.health) {
		if (other.qccFlags & QCC_FL_RESIST_LIGHT)
			damg = damg * 0.5;
		T_Damage(other, self, self.owner, damg);
	}

	// don't do radius damage to the other, because all the damage was done in the impact
	T_RadiusDamage(self, self.owner, 70, other);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION2);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	WriteByte(MSG_BROADCAST, 244);
	WriteByte(MSG_BROADCAST, 3);

	PlasmaGroundOut();
	remove(self);
};

//================================
//================================
void() PlasmaLaunch = {
	self.velocity = normalize(self.velocity);
	self.velocity = self.velocity * 1250;
	self.nextthink = time + 5;
	self.think = SUB_Remove;
};

void(vector org, vector dir) launch_plasma = {
	entity missile;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "plasma";
	if (ExtSupported("EX_SPRINT"))
		missile.killstring = "$qc_ks_plasma";
	else
		missile.killstring = " was turned to plasma\n";
	
	// set missile speed	
	missile.velocity = dir * 0.01;
	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = PlasmaTouch;
	
	setmodel(missile, "progs/plasma.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, org);

	sound(missile, CHAN_WEAPON, "plasma/flight.wav", 1, ATTN_NORM);
	if (!deathmatch && !coop)
		missile.effects = EF_BRIGHTLIGHT;
	
	// set missile duration
	missile.think = PlasmaLaunch;
	missile.nextthink = time + 0.1;
};

//================================
//================================
void() W_FirePlasma =  {
	vector dir;

	// explode if under water
	if (self.waterlevel > 1) {
		T_RadiusDamage(self, self, 2000, world);
		return;
	}

	sound(self, CHAN_WEAPON, "plasma/fire.wav", 0.5, ATTN_NORM);
	self.punchangle_x = -2;
	makevectors(self.v_angle);
	dir = aim(self, 1000);
	launch_plasma(self.origin + v_forward * 24 + '0 0 16', dir);
};

/*
================
PICKUP
================
*/
void() item_plasma = {
	item_cells();
};