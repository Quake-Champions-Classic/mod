/*
===========================
MISC EXPLOBOX
===========================
*/

void() barrel_explode = {
	// did say self.owner
	T_RadiusDamage(self, self.enemy, 160, world);
	sound(self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);
	particle(self.origin, '0 0 0', 75, 255);

	// yoder add, 27/09/2020 to make barrels fire targets on explode
	activator = self.enemy;
	dprint("enemy name: ");
	dprint(self.enemy.classname);
	dprint("\n");
	SUB_UseTargets();

	self.origin_z = self.origin_z + 32;
	
	BecomeExplosion ();
};

void() barrel_detonate = {
	self.takedamage = DAMAGE_NO;
	self.think = barrel_explode;
	self.nextthink = self.ltime + 0.3;
}


// QUAKED misc_explobox (0 .5 .8) (0 0 0) (32 32 64)
// TESTING THING
void() misc_explobox = {
	float	oldz;
	
	if (!self.mdl) 
		self.mdl = "maps/b_explob.bsp";

	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	precache_model(self.mdl);
	setmodel(self, self.mdl);
	precache_sound("weapons/r_exp3.wav");
	self.health = 20;
	self.th_die = barrel_detonate;
	self.takedamage = DAMAGE_AIM;
	
	if (ExtSupported("EX_SPRINT")) {
		self.netname = "$qc_exploding_barrel";
		self.killstring = "$qc_ks_blew_up";
	}
	else {
		self.netname = "exploding barrel";
		self.killstring = " blew up\n";
	}

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();

	if (oldz - self.origin_z > 250) {
		dprint ("explobox fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}

	self.classname = "explo_box"; // Used by ClientObituary to print death message
};

// QUAKED misc_explobox2 (0 .5 .8) (0 0 0) (32 32 64)
// Smaller exploding box, REGISTERED ONLY
void() misc_explobox2 = {
	self.mdl = "maps/b_exbox2.bsp";
	self.qccFlags |= (QCC_FL_THROWABLE | QCC_FL_THR_IT_BSP);
	misc_explobox();
};