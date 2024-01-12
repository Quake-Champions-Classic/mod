/*
===============================
MISC FIREBALL
===============================
*/

void() fire_touch = {
	T_Damage(other, self, self, 20);
	if (self.noise2)	// MG1
		sound(self, CHAN_VOICE, self.noise2, 0.8, ATTN_NORM);
	remove(self);
};

void() fire_fly = {
	entity	fireball;

	fireball = spawn();
	fireball.solid = SOLID_TRIGGER;
	fireball.movetype = MOVETYPE_TOSS;

	// MG1
	if (self.movedir) {
		fireball.velocity = self.movedir;
		fireball.velocity_x += crandom() * 20;
		fireball.velocity_y += crandom() * 20;
		fireball.velocity_z += crandom() * 20;
	}
	else {
		fireball.velocity_x = (random() * 100) - 50;
		fireball.velocity_y = (random() * 100) - 50;
		fireball.velocity_z = self.speed + (random() * 200);
	}

	if (self.noise)
		sound(self, CHAN_VOICE, self.noise, 1.0, ATTN_NORM);
	fireball.noise2 = self.noise2;

	fireball.classname = "fireball";
	setmodel(fireball, "progs/lavaball.mdl");
	setsize(fireball, '0 0 0', '0 0 0');
	setorigin(fireball, self.origin);
	fireball.nextthink = time + 5;
	fireball.think = SUB_Remove;
	fireball.touch = fire_touch;

	if (ExtSupported("EX_SPRINT")) {
		self.netname = "$qc_lava_ball";
		self.killstring = "$qc_ks_lavaball";
	}
	else {
		self.netname = "Lava Ball";
		self.killstring = " ate a lavaball\n";
	}
	
	self.nextthink = time + (random() * 5) + 3;
	self.think = fire_fly;
};

// QUAKED misc_fireball (0 .5 .8) (-8 -8 -8) (8 8 8)
// Lava Balls
void() misc_fireball = {	
	precache_model("progs/lavaball.mdl");
	self.classname = "fireball";
	
	if (ExtSupported("EX_SPRINT")) {
		self.netname = "$qc_lava_ball";
		self.killstring = "$qc_ks_lavaball";
	}
	else {
		self.netname = "Lava Ball";
		self.killstring = " ate a lavaball\n";
	}

	if (!self.speed)
		self.speed = 1000;
	
	// MG1
	if (self.noise)
		precache_sound(self.noise);
	if (self.noise2)
		precache_sound(self.noise2);
	
	if (self.targetname)
		self.use = fire_fly;
	else
	{
		self.nextthink = time + (random() * 5);
		self.think = fire_fly;
	}
};