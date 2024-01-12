/*
================================
SCOURGE OF ARMAGON
================================
*/

/* Earthquake QuickC program
   By Jim Dose'  9/13/96
*/
//JIM
float hip_earthquake;
float quakeactive;

void() StopEarthQuake = {
   hip_earthquake = 0;
};

void(float value) EarthQuakeTime = {
   value = value + time;
   if (value > hip_earthquake)
      hip_earthquake = value;
};

void() earthquake_postthink = {
	if (hip_earthquake > time) {
      if (quakeactive == 0) {
         sound(self, CHAN_VOICE, "misc/quake.wav", 1, ATTN_NONE);
         quakeactive = 1;
      }
		if (self.flags & FL_ONGROUND)
         self.velocity = self.velocity + (random() * '0 0 150');
	}
   else if (quakeactive == 1) {
      sound(self, CHAN_VOICE, "misc/quakeend.wav", 1, ATTN_NONE);
      quakeactive = 0;
   }
};

void() earthquake_use = {
	EarthQuakeTime(self.dmg);
};

// QUAKED func_earthquake (0 0 0.5) (0 0 0) (32 32 32)
// Causes an earthquake.  Triggers targets.
// "dmg" is the duration of the earthquake.  Default is 0.8 seconds.
void() func_earthquake = {
    quakeactive = 0;
    precache_sound("misc/quake.wav");
    precache_sound("misc/quakeend.wav");
    self.classname = "earthquake";
	self.use = earthquake_use;
	self.think = SUB_Null;
    if (!self.dmg)
        self.dmg = 0.8;
};


/*
================================
DISSOLUTION OF ETERNITY
================================
*/

// Level-Wide Earthquakes
float EQ_RANDOM = 1;

void() stop_earthquake;

void() earthquake_rumble = {
	if (self.attack_finished < time)
		stop_earthquake();
	else {
		sound(self, CHAN_VOICE, "equake/rumble.wav", 1, ATTN_NONE);
		self.think = earthquake_rumble;
		self.nextthink = time + 1;
	}
};

void() start_earthquake = {
	earthquake_active = 1;
	if (self.spawnflags & EQ_RANDOM)
		self.attack_finished = time + random() * self.delay;
	else
		self.attack_finished = time + self.delay;
	earthquake_rumble();
};

void() stop_earthquake = {
	earthquake_active = 0;
	self.think = start_earthquake;
	if (self.spawnflags & EQ_RANDOM)
		self.nextthink = time + random() * self.wait;
	else
		self.nextthink = time + self.wait;
};

/*QUAKED earthquake (0 1 0) (-8 -8 -8) (8 8 8) Random
The Earthquake generator.
"delay" - duration of the tremor (default 20)
"wait" - time between tremors (default 60)
"weapon" - richter scale of movement (default 40); if you give a weapon value of 40, the X and Y displacement can vary between -20 and +20, a range of 40.
RANDOM affects the times only. It will change the randomly between 0-n where n is the duration or time between.
*/
void() earthquake = {
	if (!self.delay)
		self.delay = 20;
	if (!self.wait)
		self.wait = 60;
	if (!self.weapon)
		self.weapon = 40;	
	
	precache_sound("equake/rumble.wav");
	earthquake_active = 0;
	earthquake_intensity = self.weapon * 0.5;
	
	setsize(self, '0 0 0', '0 0 0');
	self.think = stop_earthquake;
	self.nextthink = time + 1;
};

// ============================================================
// Earthquake trigger
// ============================================================
void() earthquake_touch = {
	if (self.delay) {
		if (self.attack_finished < time) {
			sound(self, CHAN_VOICE, "equake/rumble.wav", 1, ATTN_NORM);
			self.attack_finished = time + 1;
		}			
		
		if (other.classname == "player") {
			if (other.flags & FL_ONGROUND) {
				other.velocity_x = other.velocity_x + (random() * self.weapon * 2) - self.weapon;
				other.velocity_y = other.velocity_y + (random() * self.weapon * 2) - self.weapon;
				other.velocity_z = other.velocity_z + (random() * self.weapon * 2) - self.weapon;
			}
		}
	}
};

void() rogue_earthquake_use = {
	self.delay = !self.delay;
};

/*QUAKED trigger_earthquake (.5 .5 .5) ?
The Earthquake generator.
Anytime a person is in an active field, they shake. If the trigger is a target, it will be OFF until triggered. It will then toggle between ON and OFF.
"weapon" - richter scale of movement (default 40); if you give a weapon value of 40, the X and Y displacement can vary between -20 and +20, a range of 40.
*/
void() trigger_earthquake = {
	precache_sound("equake/rumble.wav");
	
	if (!self.weapon)
		self.weapon = 40;	
	
	self.weapon = self.weapon * 0.5;
	self.delay = 1;
	self.touch = earthquake_touch;

	if (self.targetname) {
		self.use = rogue_earthquake_use;
		self.delay = 0;
	}

	InitTrigger();
};

void() kill_earthquake = {
	entity eq;

	if (other.classname != "player")
		return;	
    
	eq = find(world, classname, "earthquake");
	if (eq != world) {
		earthquake_active = 0;
		remove(eq); 
    }
};

// QUAKED trigger_earthquake_kill (.5 .5 .5) ?
// Trigger to kill the level-wide earthquake.
void() trigger_earthquake_kill = {
	self.touch = kill_earthquake;
	InitTrigger();
};