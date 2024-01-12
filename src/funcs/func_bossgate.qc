/*
=================================
FUNC BOSS GATE
=================================
*/

/*
QUAKED func_bossgate (0 .5 .8) ?
This bmodel appears unless players have all of the episode sigils.
*/
/*
void() func_bossgate =
{
	if ((serverflags & 15) == 15)
		return;		// all episodes completed

	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel(self, self.model);
};
*/

const float BOSSGATE_INVERSE = 64;
void() func_bossgate = {
	float inverse = self.spawnflags & BOSSGATE_INVERSE ? TRUE : FALSE;
	self.spawnflags (-) BOSSGATE_INVERSE;
	if (!self.spawnflags)
		self.spawnflags = SIGIL_E1 | SIGIL_E2 | SIGIL_E3 | SIGIL_E4;
	self.spawnflags &= SIGIL_ALL;
	
	if ((serverflags & self.spawnflags) == self.spawnflags) {   // All runes collected
		if (!inverse) {
			remove(self);
			return;
		}
	}
	else {  //Still missing some runes
		if (inverse) {
			remove(self);
			return;
		}	
	}
	
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel(self, self.model);

	if (self.target || self.killtarget) {
		self.think = SUB_UseTargets;
		self.nextthink = time + 0.2;
	}
};