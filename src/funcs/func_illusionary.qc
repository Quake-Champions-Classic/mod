/*
=================================
FUNC ILLUSIONARY
=================================
*/

// QUAKED func_illusionary (0 .5 .8) ?
// A simple entity that looks solid but lets you walk through it.
void() func_illusionary = {
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel(self, self.model);
	makestatic(self);
};