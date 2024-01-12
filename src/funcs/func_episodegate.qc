/*
==============================
FUNC EPISODE GATE
==============================
*/

// QUAKED func_episodegate (0 .5 .8) ? E1 E2 E3 E4
// This bmodel will appear if the episode has allready been completed, so players can't reenter it.
void() func_episodegate = {
    // Can still enter episode
	if (!(serverflags & self.spawnflags))
		return;
    
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel(self, self.model);
};
