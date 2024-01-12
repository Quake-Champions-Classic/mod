/*
==========================================
Dissolution of Eternity and Dimension of the Machine trigger_explosion
==========================================
*/

const float NO_DAMAGE = 1;
void() trigger_explosion_activate = {
	self.delay = 0;
	SUB_UseTargets();
	
	if (!(self.spawnflags & NO_DAMAGE))
		T_RadiusDamage(self, self.owner, 120, self);
		
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	
	BecomeExplosion();
};

void() trigger_explosion_use = {
	if (self.delay > 0) {
		self.think = trigger_explosion_activate;
		self.nextthink = time + self.delay;
	}
	else {
		trigger_explosion_activate();
	}
};

void() trigEx_die = {
	SUB_UseTargets();
	self.touch = SUB_Null;
	self.nextthink = time + 0.1;
	self.think = SUB_Remove;
};

void() trigger_explosion = {
	INHIBIT_COOP
	if (RemovedOutsideCoop()) return;

	if (self.targetname != string_null) {
		self.use = trigger_explosion_use;
		return;
	}

	// DoE trigger_explosion stuff
	InitTrigger();

	if (!self.health)
		self.health = 20;
	
	self.max_health = self.health;
	self.th_die = trigEx_die;
	self.takedamage = DAMAGE_YES;
	self.solid = SOLID_BBOX;
	setorigin(self, self.origin);	// make sure it links into the world
};