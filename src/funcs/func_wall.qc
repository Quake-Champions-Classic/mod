/*
=======================
FUNC WALL
=======================
*/

// change to alternate textures
void() func_wall_use = {
	self.frame = 1 - self.frame;
};

// QUAKED func_wall (0 .5 .8) ?
// This is just a solid wall if not inhibitted
void() func_wall = {
	self.angles = '0 0 0';
	self.classname = "func_wall";
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel(self, self.model);
};