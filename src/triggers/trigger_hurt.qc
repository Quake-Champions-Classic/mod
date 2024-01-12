// TRIGGER HURT

// HIP: JIM
void(entity ent, float amount) hurt_setdamage = {
	ent.dmg = amount;
	if (!amount)
		ent.solid = SOLID_NOT;
	else
		ent.solid = SOLID_TRIGGER;
	ent.nextthink = -1;
};

// MG1
void hurt_use() = {
	self.state = 1 - self.state;
}

void() hurt_on = {
	self.solid = SOLID_TRIGGER;
	self.nextthink = -1;
};

void() hurt_touch = {
	if (other.takedamage) {
		// MG1: Yoder Sept24 2021 Horde merge; allows for monster-only hurt volumes
		if ((self.spawnflags & MONSTER_ONLY) && !(other.flags & FL_MONSTER))
			return;
		
		self.solid = SOLID_NOT;
		T_Damage(other, self, self, self.dmg);
		self.think = hurt_on;
		self.nextthink = time + 1;

		// HIP: MED 12/01/96 added count stuff
		if (self.cnt > 0) {
			self.cnt = self.cnt - 1;
			if (self.cnt == 0) {
				self.touch = SUB_Null;
				self.nextthink = time + 0.1;
				self.think = SUB_Remove;
			}
		}
	}
};

/*QUAKED trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
"dmg" = damage amount; default dmg = 5
*/
void() trigger_hurt = {
	self.netname = "trigger_hurt"; // for bot nav support.
	InitTrigger();
	self.touch = hurt_touch;

	if (!self.dmg)
		self.dmg = 5;

	// HIP: MED 12/01/96 added count stuff
	if (self.cnt == 0)
		self.cnt = -1;

	// MG1
	if (!self.wait)
		self.wait = 1;
	if (self.spawnflags & START_OFF)
		self.state = 1;
    
	self.use = hurt_use;
};