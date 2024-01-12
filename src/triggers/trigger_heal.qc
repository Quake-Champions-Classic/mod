/*
=================================
TRIGGER HEAL
=================================
*/

void trigger_heal_use() = {
	if (self.state != 1)
		self.state = 1;
	else
		self.state = 0;
}

void() trigger_heal_on = {
	self.solid = SOLID_TRIGGER;
	self.nextthink = -1;
};

void() trigger_heal_touch = {
	if (other.takedamage) {
		if ((self.spawnflags & 2) && !(other.flags & FL_CLIENT))
			return;
		if ((self.spawnflags & MONSTER_ONLY) && !(other.flags & FL_MONSTER))
			return;
		
		self.solid = SOLID_NOT;
		T_Heal(other, self.healamount, self.healtype);
		self.think = trigger_heal_on;
		self.nextthink = time + self.wait;

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

/*
trigger_heal
Any object touching this will be healed
*/
void() trigger_heal = {
	self.netname = "trigger_heal"; // for bot nav support.
	InitTrigger();
	self.touch = trigger_heal_touch;

	if (!self.healamount)
		self.healamount = 5;
	
	if (!self.healtype)
		self.healtype = 2;
	
	if (self.cnt == 0)
		self.cnt = -1;
	
	if (!self.wait)
		self.wait = 1;
	
	if (self.spawnflags & START_OFF)
		self.state = 1;
    
	self.use = trigger_heal_use;
};