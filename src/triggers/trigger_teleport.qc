/*
==============================================================================

TELEPORT TRIGGERS

==============================================================================
*/

float	PLAYER_ONLY	= 1;
float	SILENT = 2;
float	IGNORE_TARGETNAME = 4; // MG1

void() play_teleport = {
	float v;
	string tmpstr;

	v = random() * 5;
	if (v < 1)
		tmpstr = "misc/r_tele1.wav";
	else if (v < 2)
		tmpstr = "misc/r_tele2.wav";
	else if (v < 3)
		tmpstr = "misc/r_tele3.wav";
	else if (v < 4)
		tmpstr = "misc/r_tele4.wav";
	else
		tmpstr = "misc/r_tele5.wav";

	sound(self, CHAN_VOICE, tmpstr, 1, ATTN_NORM);
	remove(self);
};

void(vector org) spawn_tfog = {
	s = spawn();
	s.origin = org;
	s.nextthink = time + 0.2;
	s.think = play_teleport;
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_TELEPORT);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
};

// MG1 ==============================================
void(vector org) spawn_tfog_silent = {
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_TELEPORT);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
};

void() tdeath_touch = {
	if (other.classname == "monster_hitbox")
		other = other.owner;
	
	if (other == self.owner || other == self.enemy)
		return;

    // frag anyone who teleports in on top of an invincible player
	if (other.classname == "player") {
		if (other.invincible_finished > time)
			self.classname = "teledeath2";

		if (self.owner.classname != "player") {	// other monsters explode themselves
			T_Damage(self.owner, self, self, 50000);
			return;
		}
	}

	if (other.health) {
		// prevent instakill on elder gods
		if ((other.qccFlags & QCC_FL_RESIST_TELEFRAG))
			T_Damage(other, self, self, other.max_health / 3 + 1);
		else
			T_Damage(other, self, self, 50000);
		// QCC: fix to allow warping inside monsters that don't gib, hope it doesn't break anything
		if (other.flags & FL_MONSTER && other.health < 1) {
			other.solid = SOLID_NOT;
			setorigin(other, other.origin); // relink to the world
		}
		self.enemy = other; // hack to prevent elder gods from getting hit multiple times
	}
};

// MG1 ================================================================
// Yoder sept24 2021 horde merge
// a faster version of tdeath to minimize telefragging 
void(vector org, entity death_owner) spawn_tdeath_fast = {
    entity death;
	death = spawn();
	death.classname = "teledeath";
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	setsize(death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin(death, org);
	death.touch = tdeath_touch;
	death.nextthink = time + 0.01;
	death.think = SUB_Remove;
	death.owner = death_owner;
	force_retouch = 2;  // make sure even still objects get hit
};

void(vector org, entity death_owner) spawn_tdeath = {
	entity death;
	death = spawn();
	death.classname = "teledeath";
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	setsize(death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin(death, org);
	death.touch = tdeath_touch;
	death.nextthink = time + 0.2;
	death.think = SUB_Remove;
	death.owner = death_owner;	
	force_retouch = 2;  // make sure even still objects get hit
};

void() teleport_touch = {
	entity    t;
	vector	org;

    // MG1
	if (self.targetname != string_null && !(self.spawnflags & IGNORE_TARGETNAME))
		if (self.nextthink < time)
			return; // not fired yet

	if (self.spawnflags & PLAYER_ONLY)
		if (other.classname != "player")
			return;

	// only teleport living creatures
	if (other.health <= 0 || other.solid != SOLID_SLIDEBOX) {
		// QCC: Nyx needs to not be able to touch anything in Ghostwalk but still needs to go through teleporters
		if (other.qccChampion != QCC_NYX || other.weapon != QCC_ABILITY)
			return;
	}

	SUB_UseTargets();

	// put a tfog where the player was
	spawn_tfog(other.origin);

	t = find(world, targetname, self.target);

	if (!t)
		objerror("couldn't find target");

	// spawn a tfog flash in front of the destination
	makevectors(t.mangle);
	org = t.origin + 32 * v_forward;

	spawn_tfog(org);
	spawn_tdeath(t.origin, other);

	// move the player and lock him down for a little while
	if (!other.health) {
		other.origin = t.origin;
		other.velocity = (v_forward * other.velocity_x) + (v_forward * other.velocity_y);
		return;
	}

	setorigin(other, t.origin);
	other.angles = t.mangle;

	if (other.classname == "player") {
		other.fixangle = 1; // turn this way immediately
		other.teleport_time = time + 0.7;
		other.velocity = v_forward * 300;

		// MG1
		if (!coop && !deathmatch)
			FogPushSettingsFrom(other, t, 0);
	}

	other.flags -= (other.flags & FL_ONGROUND);
};

/*QUAKED info_teleport_destination (.5 .5 .5) (-8 -8 -8) (8 8 32)
This is the destination marker for a teleporter.  It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
void() info_teleport_destination = {
	self.netname = "info_teleport_destination"; // for bot nav support.
	// this does nothing, just serves as a target spot
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.model = string_null;
	self.origin = self.origin + '0 0 27';
	if (!self.targetname)
		objerror ("no targetname");
};

void() teleport_use = {
	self.nextthink = time + 0.2;
	force_retouch = 2;		// make sure even still objects get hit
	self.think = SUB_Null;
};

/*QUAKED trigger_teleport (.5 .5 .5) ? PLAYER_ONLY SILENT
Any object touching this will be transported to the corresponding info_teleport_destination entity.
You must set the "target" field, and create an object with a "targetname" field that matches.
If the trigger_teleport has a targetname, it will only teleport entities when it has been fired.
*/
void() trigger_teleport = {
	vector o;
	
	InitTrigger();
	self.touch = teleport_touch;

	// find the destination 
	if (!self.target)
		objerror ("no target");
	self.use = teleport_use;

	self.netname = "trigger_teleport"; // lets us ID the entity in C code...

	if (!(self.spawnflags & SILENT)) {
		precache_sound("ambience/hum1.wav");
		o = (self.mins + self.maxs)*0.5;
		ambientsound(o, "ambience/hum1.wav",0.5 , ATTN_STATIC);
	}
};