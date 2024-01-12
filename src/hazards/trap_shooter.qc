/*
======================================

TRAP SHOOTER

======================================
*/

float SPAWNFLAG_SUPERSPIKE	= 1;
float SPAWNFLAG_LASER = 2;
void(vector org, vector vec) LaunchLaser;

/* HIP: defined in defs.qc
float SPAWNFLAG_LAVABALL = 4;
float SPAWNFLAG_ROCKET = 8;
float SPAWNFLAG_SILENT = 16;
*/

float SPAWNFLAG_HIPTRAP = 1024; // used to help differentiate whether we want to use DoE or SoA spikeshooters

// ROGUE
float SPAWNFLAG_LAVASPIKE = 4;
float SPAWNFLAG_SUPERLAVA = 8;
float SPAWNFLAG_LAVASKILL = 16;
float SPAWNFLAG_FIREBALL = 32;
void(vector org, vector dir) launch_lava_spike;
void(vector org, vector dir) launch_fireball;

void() spikeshooter_use = {
	entity lavaball; // HIP

	// ROGUE ------------------------------------------------------------
	if (self.spawnflags & SPAWNFLAG_SUPERSPIKE || !(self.spawnflags)) {
		sound(self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		launch_spike (self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
			newmis.touch = superspike_touch;
	}
	// ------------------------------------------------------------------
	else if (self.spawnflags & SPAWNFLAG_LASER) {
		sound(self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		LaunchLaser (self.origin, self.movedir);
	}
	// HIP: MED 11/09/96 added lava ball and rocket ---------------------
	else if ((self.spawnflags & SPAWNFLAG_LAVABALL) && (self.spawnflags & SPAWNFLAG_HIPTRAP)) {
		if (!(self.spawnflags & SPAWNFLAG_SILENT))
			sound(self, CHAN_VOICE, "misc/spike.wav", 1, ATTN_NORM);
		lavaball = spawn();
		lavaball.movetype = MOVETYPE_FLYMISSILE;
		lavaball.solid = SOLID_BBOX;
		lavaball.classname = "lavaball";
		// set lavaball speed
		lavaball.velocity = self.movedir * 300;
		lavaball.angles = vectoangles(lavaball.velocity);
		lavaball.owner = self;
		lavaball.touch = T_MissileTouch;
		setmodel(lavaball, "progs/lavarock.mdl");
		setsize(lavaball, '-4 -4 -4', '4 4 4');
		setorigin(lavaball, self.origin);
		lavaball.avelocity = '0 0 400';
		lavaball.nextthink = time + 5;
		lavaball.think = SUB_Remove;
	}
	else if ((self.spawnflags & SPAWNFLAG_ROCKET) && (self.spawnflags & SPAWNFLAG_HIPTRAP))
	{
		if (!(self.spawnflags & SPAWNFLAG_SILENT))
			sound(self, CHAN_VOICE, "weapons/sgun1.wav", 1, ATTN_NORM);
		W_FireRocket();
		newmis.velocity = self.movedir*1000;
		newmis.angles = vectoangles(newmis.velocity);
		setorigin(newmis, self.origin + self.movedir*8);
	}
	// ROGUE --------------------------------------------------------------
	else if (self.spawnflags & SPAWNFLAG_FIREBALL) {
        launch_fireball (self.origin, self.movedir);
    }
	else {
		sound(self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		launch_lava_spike (self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERLAVA)
			newmis.touch = superlavaspike_touch;
        else if ((self.spawnflags & SPAWNFLAG_LAVASKILL) && (skill > 1))
			newmis.touch = superlavaspike_touch;
	}
	// --------------------------------------------------------------------
};

void() shooter_think = {
	if (self.state) { //HIP: MED 11/01/96 added state capability
		spikeshooter_use ();
		newmis.velocity = self.movedir * 500;
	}
	self.nextthink = time + self.wait;
};


// QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
// When triggered, fires a spike in the direction set in QuakeEd. Laser is only for REGISTERED.
void() trap_spikeshooter = {
	SetMovedir ();
	self.use = spikeshooter_use;

	// Mission packs have overlapping spawnflags, so try to make sure the right ones get used
	if (world.model == "maps/hip1m1.bsp" || world.model == "maps/hip1m2.bsp" || world.model == "maps/hip1m3.bsp" || world.model == "maps/hip1m4.bsp" || world.model == "maps/hip1m5.bsp" || 
		world.model == "maps/hip2m1.bsp" || world.model == "maps/hip2m2.bsp" || world.model == "maps/hip2m3.bsp" || world.model == "maps/hip2m4.bsp" || world.model == "maps/hip2m5.bsp" || world.model == "maps/hip2m6.bsp" || 
		world.model == "maps/hip2m1.bsp" || world.model == "maps/hip2m2.bsp" || world.model == "maps/hip2m3.bsp" || world.model == "maps/hip2m4.bsp" || world.model == "maps/hipend.bsp" || 
		world.model == "maps/hipdm1.bsp" || world.model == "maps/zoo.bsp" || world.model == "maps/mark.bsp")
		self.spawnflags |= SPAWNFLAG_HIPTRAP;
	
	if (ExtSupported("EX_SPRINT")) {
		self.netname = "$qc_spike_trap";
		self.killstring ="$qc_ks_spiked";
	}
	else {
		self.netname = "spike trap";
		self.killstring = " was spiked\n";
	}

	if (self.spawnflags & SPAWNFLAG_LASER) {
		precache_model2("progs/laser.mdl");		
		precache_sound2("enforcer/enfire.wav");
		precache_sound2("enforcer/enfstop.wav");
	}
	// HIP -------------------------------------------------
	else if ((self.spawnflags & SPAWNFLAG_LAVABALL) && (self.spawnflags & SPAWNFLAG_HIPTRAP)) {
		precache_model("progs/lavarock.mdl");
		precache_sound2("misc/spike.wav");
	}
	else if ((self.spawnflags & SPAWNFLAG_ROCKET) && (self.spawnflags & SPAWNFLAG_HIPTRAP)) {
		precache_model("progs/missile.mdl");
		precache_sound("weapons/sgun1.wav");
	}
   	// ROGUE -----------------------------------------------
	else if (self.spawnflags & SPAWNFLAG_LAVASPIKE) {
		precache_model2("progs/lspike.mdl");
		precache_sound2("lavagun/snail.wav");		// lava nail gun cooldown
		precache_sound2("weapons/rocket1i.wav");
	}
	else if (self.spawnflags & SPAWNFLAG_SUPERLAVA) {
		precache_model2("progs/lspike.mdl");
		precache_sound2("lavagun/snail.wav");		// lava nail gun cooldown
		precache_sound2("weapons/spike2.wav");
	}
	else if (self.spawnflags & SPAWNFLAG_LAVASKILL) {
		precache_model2("progs/lspike.mdl");
		precache_sound2("lavagun/snail.wav");		// lava nail gun cooldown
		precache_sound2("weapons/rocket1i.wav");
		precache_sound2("weapons/spike2.wav");
	}
	else if (self.spawnflags & SPAWNFLAG_FIREBALL) {
		precache_model("progs/fireball.mdl");
	}
	// -----------------------------------------------------
	else
		precache_sound("weapons/spike2.wav");
};

/*QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
void() trap_shooter = {
	trap_spikeshooter ();
	
	if (self.wait == 0)
		self.wait = 1;

	self.state = 1; // HIP: MED 11/01/96 added state capability
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
};

//MED 11/01/96 added new use function
void() trap_shooter_use = {
   self.state = 1 - self.state;
};

//MED 11/01/96 added new function
/*QUAKED trap_switched_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser lavaball rocket silent
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
"state" 0 initially off, 1 initially on. (0 default)
*/
void() trap_switched_shooter = {
	trap_spikeshooter ();

	if (self.wait == 0)
		self.wait = 1;
	
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
	self.use = trap_shooter_use;
};