/*
==============================
MG1: FUNC EXPLODE!
==============================
*/

void() barrel_explode;

void func_explode_detonate() {
	vector pos = self.mins + (self.size * 0.5);
	pos_z -= 32;
	setmodel(self, string_null);
	setorigin(self, pos);
	barrel_explode();
}

void() func_explode_die = {
	self.takedamage = DAMAGE_NO;
	self.think = func_explode_detonate;
	self.nextthink = self.ltime + 0.15;
}

// QUAKED func_explode (0 .5 .8) (0 0 0) (32 32 64)
// Custom exploding box
void func_explode() = {
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel(self, self.model);

	precache_sound("weapons/r_exp3.wav");
	self.health = 20;
	self.th_die = func_explode_die;
	self.takedamage = DAMAGE_AIM;
	
	self.qccFlags |= (QCC_FL_THROWABLE | QCC_FL_THR_IT_BSP);
};