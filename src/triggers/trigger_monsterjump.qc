/*
===============================
TRIGGER MONSTERJUMP
===============================
*/

void() trigger_monsterjump_touch = {
	if (other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER)
		return;

	// MG1: yoder add, July 10th 2020
	// making it so trigger_monsterjump's with spawnflag 8 only affect monsters with spawnflag 8
	if (self.spawnflags & 64) {
		if (!(other.spawnflags & 64)) {
			dprint("monster didn't have spawnflag 8!\n");
			return;
		}
	}

	// set XY even if not on ground, so the jump will clear lips
	other.velocity_x = self.movedir_x * self.speed;
	other.velocity_y = self.movedir_y * self.speed;
	
	if (!(other.flags & FL_ONGROUND))
		return;
	
	other.flags = other.flags - FL_ONGROUND;
	other.velocity_z = self.height;

	// HIP: MED 12/01/96 added count stuff
	if (self.cnt>0) {
		self.cnt = self.cnt - 1;
		if (self.cnt == 0) {
			self.touch = SUB_Null;
			self.nextthink = time + 0.1;
			self.think = SUB_Remove;
		}
	}
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards
*/
void() trigger_monsterjump = {
	if (!self.speed)
		self.speed = 200;

	if (!self.height)
		self.height = 200;

	if (self.angles == '0 0 0')
		self.angles = '0 360 0';
		
	// HIP: MED 12/01/96 added count stuff
	if (self.cnt == 0)
		self.cnt = -1;
	
	InitTrigger();
	self.touch = trigger_monsterjump_touch;
};