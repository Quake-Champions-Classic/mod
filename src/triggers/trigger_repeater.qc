// MG1

float REPEATER_ON = 1;
void() repeater_think = {
	SUB_UseTargets();
	self.nextthink = time + self.wait + (self.pausetime * random());
};

void() repeater_use = {
	if (self.spawnflags & REPEATER_ON) {    // turn off
		self.spawnflags = self.spawnflags - REPEATER_ON;
		self.nextthink = 0;
		self.think = SUB_Null;
	}
	else {  // turn on
		self.spawnflags = self.spawnflags + REPEATER_ON;
		self.nextthink = time + self.wait + (self.pausetime * random());
		self.think = repeater_think;
	}
};

void() trigger_repeater = {
	INHIBIT_COOP
	if (RemovedOutsideCoop()) return;

	if (!self.wait)
		self.wait = 1;
    
	self.use = repeater_use;
    
	if (self.spawnflags & REPEATER_ON) {
		self.nextthink = time + self.wait + (self.pausetime * random());
		self.think = repeater_think;
	}
	else {	
		self.nextthink = 0;
		self.think = SUB_Null;
	}
};