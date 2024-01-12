float PUSH_ONCE = 1;
float ADDITIVE_PUSH = 2; // MG1
float PUSH_START_OFF = 4; // MG1

void() trigger_push_touch = {
	// MG1: yoder Sept 24 2021 horde merge	
	if (horde_ent) {
		if (other.spawnflags & PUSH_START_OFF) // ignore this spawnflag in horde mode
			other.spawnflags-= PUSH_START_OFF;
		
		if ((other.classname != "player")) {
			if ((other.classname == "item_artifact_invulnerability") || (other.classname == "item_artifact_super_damage")) {
				if (self.spawnflags & ADDITIVE_PUSH)
					other.velocity = other.velocity + (self.speed * self.movedir * 10 * frametime); 
				else
					other.velocity = self.speed * self.movedir * 10;
			}
			return;
		}
	}

	if (other.health > 0 || other.classname == "grenade") {
		if (other.flags & FL_INSHELTER) return;

		if (self.spawnflags & ADDITIVE_PUSH) // yoder add, Jan 28 2021
			other.velocity = other.velocity + self.speed * self.movedir * 10 * frametime;
		else
			other.velocity = self.speed * self.movedir * 10;
		if (other.classname == "player") {
			if (other.fly_sound < time) {
				other.fly_sound = time + 1.5;
				sound(other, CHAN_AUTO, "ambience/windfly.wav", 1, ATTN_NORM);
			}
		}
		if (other.flags & FL_MONSTER)
            other.flags (-) FL_ONGROUND; //If a monster walks inside a trigger_push, make it fly
	}

	if (self.spawnflags & PUSH_ONCE)
		remove(self);
};

// MG1
void() trigger_push_use = {
	if (self.solid == SOLID_TRIGGER) {
		dprint("trigger_push: switched off\n");
		self.solid = SOLID_NOT;
	}
	else {
		dprint("trigger_push: switched on\n");
		self.solid = SOLID_TRIGGER;
		force_retouch = 1;
	}
};

// QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE
// Pushes the player
void() trigger_push = {
	InitTrigger();
	precache_sound("ambience/windfly.wav");
	self.touch = trigger_push_touch;
	self.use = trigger_push_use; // MG1
	if (self.spawnflags & PUSH_START_OFF) self.solid = SOLID_NOT; // MG1
	self.netname = "trigger_push"; // lets us ID the entity in C code...
	if (!self.speed)
		self.speed = 1000;
};

// MG1
const float SHELTER_FLIPPED = 1;

void() trigger_shelter_portal_touch = {
	if (other.health > 0 || other.classname == "grenade") {
		vector offs = other.origin - self.pos1;
		float dot = offs * self.pos2;
		if (dot >= 0)
			other.flags (+) FL_INSHELTER;
		else
			other.flags (-) FL_INSHELTER;
	}
};

// QUAKED trigger_shelter (.5 .5 .5) 
// Shelters the player from pushes
void() trigger_shelter_portal = {
	InitTrigger();
	self.touch = trigger_shelter_portal_touch;
	self.pos1 = self.mins + (self.size * 0.5);
	if (self.size_x < self.size_y) {
		if (self.size_x < self.size_z)
			self.pos2 = '1 0 0';
		else
			self.pos2 = '0 0 1';
	}
	else {
		if (self.size_y < self.size_z)
			self.pos2 = '0 1 0';
		else
			self.pos2 = '0 0 1';
	}
	if (self.spawnflags & SHELTER_FLIPPED)
        self.pos2 *= -1;
};