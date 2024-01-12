// Collection of light entities made for Quake Champions Classic.

// Giant flame. Mostly used for the big towers in Goroth maps.
void() light_qccbigflame = {
	precache_model("progs/qcbigflame.mdl");
	setmodel(self, "progs/qcbigflame.mdl");
	if (self.spawnflags & UPSIDEDOWN)
		self.angles = '180 0 0';	
	FireAmbient();
	makestatic(self);
};