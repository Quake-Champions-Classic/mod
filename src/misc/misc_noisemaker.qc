/*
===================================
MG1: MISC NOISEMAKER
===================================
*/

void() noise_think = {
	self.nextthink = time + 0.5;
	sound(self, 1, "enforcer/enfire.wav", 1, ATTN_NORM);
	sound(self, 2, "enforcer/enfstop.wav", 1, ATTN_NORM);
	sound(self, 3, "enforcer/sight1.wav", 1, ATTN_NORM);
	sound(self, 4, "enforcer/sight2.wav", 1, ATTN_NORM);
	sound(self, 5, "enforcer/sight3.wav", 1, ATTN_NORM);
	sound(self, 6, "enforcer/sight4.wav", 1, ATTN_NORM);
	sound(self, 7, "enforcer/pain1.wav", 1, ATTN_NORM);
};

// QUAKED misc_noisemaker (1 0.5 0) (-10 -10 -10) (10 10 10)
// For optimzation testing, starts a lot of sounds.
void() misc_noisemaker = {
	precache_sound2("enforcer/enfire.wav");
	precache_sound2("enforcer/enfstop.wav");
	precache_sound2("enforcer/sight1.wav");
	precache_sound2("enforcer/sight2.wav");
	precache_sound2("enforcer/sight3.wav");
	precache_sound2("enforcer/sight4.wav");
	precache_sound2("enforcer/pain1.wav");
	precache_sound2("enforcer/pain2.wav");
	precache_sound2("enforcer/death1.wav");
	precache_sound2("enforcer/idle1.wav");
	self.nextthink = time + 0.1 + random();
	self.think = noise_think;
};