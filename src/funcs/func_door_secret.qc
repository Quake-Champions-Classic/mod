/*
=============================================================================

SECRET DOORS

=============================================================================
*/

void() fd_secret_move1;
void() fd_secret_move2;
void() fd_secret_move3;
void() fd_secret_move4;
void() fd_secret_move5;
void() fd_secret_move6;
void() fd_secret_done;

float SECRET_OPEN_ONCE = 1;		// stays open
float SECRET_1ST_LEFT = 2;		// 1st move is left of arrow
float SECRET_1ST_DOWN = 4;		// 1st move is down from arrow
float SECRET_NO_SHOOT = 8;		// only opened by trigger
float SECRET_YES_SHOOT = 16;	// shootable even if targeted


void () fd_secret_use = {
	float temp;
	
	self.health = 10000;

	// exit if still moving around...
	if (self.origin != self.oldorigin)
		return;
	
	self.message = string_null; // no more message

	SUB_UseTargets();
	
	if (!(self.spawnflags & SECRET_NO_SHOOT)) {
		self.th_pain = SUB_NullPain; // MG1
		self.takedamage = DAMAGE_NO;
	}

	self.velocity = '0 0 0';

	// Make a sound, wait a little...	
	sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.nextthink = self.ltime + 0.1;

	temp = 1 - (self.spawnflags & SECRET_1ST_LEFT);	// 1 or -1
	makevectors(self.mangle);
	
	if (!self.t_width) {
		if (self.spawnflags & SECRET_1ST_DOWN)
			self. t_width = fabs(v_up * self.size);
		else
			self. t_width = fabs(v_right * self.size);
	}
		
	if (!self.t_length)
		self. t_length = fabs(v_forward * self.size);

	if (self.spawnflags & SECRET_1ST_DOWN)
		self.dest1 = self.origin - v_up * self.t_width;
	else
		self.dest1 = self.origin + v_right * (self.t_width * temp);
		
	self.dest2 = self.dest1 + v_forward * self.t_length;
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move1);
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
};

void (entity attacker, float damage) fd_secret_use_pain = { fd_secret_use(); } // MG1

// Wait after first movement...
void () fd_secret_move1 = {
	self.nextthink = self.ltime + 1.0;
	self.think = fd_secret_move2;
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

// Start moving sideways w/sound...
void () fd_secret_move2 = {
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	SUB_CalcMove(self.dest2, self.speed, fd_secret_move3);
};

// Wait here until time to go back...
void () fd_secret_move3 = {
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
	if (!(self.spawnflags & SECRET_OPEN_ONCE)) {
		self.nextthink = self.ltime + self.wait;
		self.think = fd_secret_move4;
	}
};

// Move backward...
void () fd_secret_move4 = {
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move5);		
};

// Wait 1 second...
void () fd_secret_move5 = {
	self.nextthink = self.ltime + 1.0;
	self.think = fd_secret_move6;
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () fd_secret_move6 = {
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	SUB_CalcMove(self.oldorigin, self.speed, fd_secret_done);
};

void () fd_secret_done = {
	if (!self.targetname || self.spawnflags & SECRET_YES_SHOOT) {
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
		//self.th_pain = fd_secret_use;
		//self.th_die = fd_secret_use; // secret door kill crash fix
		self.th_pain = fd_secret_use_pain; // MG1
		self.th_die = fd_secret_use;
	}
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () secret_blocked = {
	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	T_Damage(other, self, self, self.dmg);
};

void() secret_touch = {
	if (other.classname != "player")
		return;
	if (self.attack_finished > time)
		return;
	self.attack_finished = time + 2;	
	if (self.message != string_null) {
		centerprint (other, self.message);
		sound(other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
	}
};


/*QUAKED func_door_secret (0 .5 .8) ? open_once 1st_left 1st_down no_shoot always_shoot
Basic secret door. Slides back, then to the side. Angle determines direction.
"wait"  = # of seconds before coming back
"1st_left" = 1st move is left of arrow
"1st_down" = 1st move is down from arrow
"always_shoot" = even if targeted, keep shootable
"t_width" = override WIDTH to move back (or height if going down)
"t_length" = override LENGTH to move sideways
"dmg"		damage to inflict when blocked (2 default)
If a secret door has a targetname, it will only be opened by it's botton or trigger, not by damage.
"sounds"
1) medieval
2) metal
3) base
*/
void () func_door_secret = {
	if (self.sounds == 0)
		self.sounds = 3;

	if (self.sounds == 1) {
		precache_sound("doors/latch2.wav");
		precache_sound("doors/winch2.wav");
		precache_sound("doors/drclos4.wav");
		self.noise1 = "doors/latch2.wav";
		self.noise2 = "doors/winch2.wav";
		self.noise3 = "doors/drclos4.wav";
	}
	else if (self.sounds == 2) {
		precache_sound("doors/airdoor1.wav");
		precache_sound("doors/airdoor2.wav");
		self.noise2 = "doors/airdoor1.wav";
		self.noise1 = "doors/airdoor2.wav";
		self.noise3 = "doors/airdoor2.wav";
	}
	else if (self.sounds == 3) {
		precache_sound("doors/basesec1.wav");
		precache_sound("doors/basesec2.wav");
		self.noise2 = "doors/basesec1.wav";
		self.noise1 = "doors/basesec2.wav";
		self.noise3 = "doors/basesec2.wav";
	}

	if (!self.dmg)
		self.dmg = 2;
		
	// Magic formula...
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.classname = "func_door_secret";
	setmodel(self, self.model);
	setorigin(self, self.origin);	
	
	self.touch = secret_touch;
	self.blocked = secret_blocked;
	self.speed = 50;
	self.use = fd_secret_use;

	if (!self.targetname || self.spawnflags & SECRET_YES_SHOOT) {
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
		self.th_pain = fd_secret_use_pain; // MG1
		self.th_die = fd_secret_use;
	}

	self.oldorigin = self.origin;

	if (!self.wait)
		self.wait = 5;  // 5 seconds before closing
};