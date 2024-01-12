/*
================================
AMBIENT SOUNDS
================================
*/

// QUAKED ambient_generic (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_generic = {
	if (!self.noise) {
		dprint("ambient_generic with no noise. Removing.\n");
		remove(self);
	}
	if (!self.volume)
		self.volume = 0.5;
	if (!self.delay)
		self.delay = 3;	
	precache_sound(self.noise);
	ambientsound(self.origin, self.noise, self.volume, self.delay);
	makestatic(self);
};

// QUAKED ambient_suck_wind (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_suck_wind = {
	precache_sound("ambience/suck1.wav");
	ambientsound(self.origin, "ambience/suck1.wav", 1, ATTN_STATIC);
};

// QUAKED ambient_drone (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_drone = {
	precache_sound("ambience/drone6.wav");
	ambientsound(self.origin, "ambience/drone6.wav", 0.5, ATTN_STATIC);
};

// QUAKED ambient_flouro_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_flouro_buzz = {
	precache_sound("ambience/buzz1.wav");
	ambientsound(self.origin, "ambience/buzz1.wav", 1, ATTN_STATIC);
};

// QUAKED ambient_drip (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_drip = {
	precache_sound("ambience/drip1.wav");
	ambientsound(self.origin, "ambience/drip1.wav", 0.5, ATTN_STATIC);
};

// QUAKED ambient_comp_hum (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_comp_hum = {
	precache_sound("ambience/comp1.wav");
	ambientsound(self.origin, "ambience/comp1.wav", 1, ATTN_STATIC);
};

// QUAKED ambient_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_thunder = {
	precache_sound("ambience/thunder1.wav");
	ambientsound(self.origin, "ambience/thunder1.wav", 0.5, ATTN_STATIC);
};

// QUAKED ambient_light_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_light_buzz = {
	precache_sound("ambience/fl_hum1.wav");
	ambientsound(self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};

// QUAKED ambient_swamp1 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_swamp1 = {
	precache_sound("ambience/swamp1.wav");
	ambientsound(self.origin, "ambience/swamp1.wav", 0.5, ATTN_STATIC);
};

//QUAKED ambient_swamp2 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_swamp2 = {
	precache_sound("ambience/swamp2.wav");
	ambientsound(self.origin, "ambience/swamp2.wav", 0.5, ATTN_STATIC);
};


/*
========================================

SCOURGE OF ARMAGON AMBIENT SOUNDS

========================================
*/
// "volume" how loud it should be (0.5 is default)

// QUAKED ambient_humming (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_humming = {
	if (self.volume == 0)
		self.volume = 0.5;
	precache_sound("ambient/humming.wav");
	ambientsound(self.origin, "ambient/humming.wav", self.volume, ATTN_STATIC);
};

// QUAKED ambient_rushing (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_rushing = {
	if (self.volume == 0)
		self.volume = 0.5;
	precache_sound("ambient/rushing.wav");
	ambientsound(self.origin, "ambient/rushing.wav", self.volume, ATTN_STATIC);
};

// QUAKED ambient_running_water (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_running_water = {
	if (self.volume == 0)
		self.volume = 0.5;
	precache_sound("ambient/runwater.wav");
	ambientsound(self.origin, "ambient/runwater.wav", self.volume, ATTN_STATIC);
};

// QUAKED ambient_fan_blowing (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_fan_blowing = {
	if (self.volume == 0)
		self.volume = 0.5;
	precache_sound("ambient/fanblow.wav");
	ambientsound(self.origin, "ambient/fanblow.wav", self.volume, ATTN_STATIC);
};

// QUAKED ambient_waterfall (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_waterfall = {
	if (self.volume == 0)
		self.volume = 0.5;
	precache_sound("ambient/waterfal.wav");
	ambientsound(self.origin, "ambient/waterfal.wav", self.volume, ATTN_STATIC);
};

// QUAKED ambient_riftpower (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
void() ambient_riftpower = {
	if (self.volume == 0)
		self.volume = 0.5;
	precache_sound("ambient/riftpowr.wav");
	ambientsound(self.origin, "ambient/riftpowr.wav", self.volume, ATTN_STATIC);
};