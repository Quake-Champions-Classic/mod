/*  Copyright (C) 1996-2022 id Software LLC

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/


void() SUB_Null = {};

// MG1
const float MESSAGE_ALL_PLAYERS = 2097152;
float(...) SUB_True = { return TRUE; };
void(entity attacker, float damage) SUB_NullPain = {};

void() SUB_Remove = {
	remove(self);
};

/*
QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.
*/
void() SetMovedir = {
	// MG1
	if (self.movedir) {
		self.angles = '0 0 0';
		return;
	}
	
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else {
		makevectors(self.angles);
		self.movedir = v_forward;
	}
	
	self.angles = '0 0 0';
};

// MG1: Removes self if COOP_ONLY spawnflag is set and we're not in coop.
// Returns TRUE if it was removed.
float RemovedOutsideCoop() {
	if (!coop && (self.spawnflags & COOP_ONLY)) {
		remove(self);
		return TRUE;
	}
	return FALSE;
}

void() InitTrigger = {
	if (RemovedOutsideCoop())
		return;

	// trigger angles are used for one-way touches.  An angle of 0 is assumed
	// to mean no restrictions, so use a yaw of 360 instead.
	if (self.angles != '0 0 0')
		SetMovedir ();

	self.solid = SOLID_TRIGGER;
	setmodel(self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = string_null;
};

// Calculate self.velocity and self.nextthink to reach dest from self.origin traveling at speed
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt = {
	entity	stemp;
	stemp = self;
	self = ent;
	SUB_CalcMove(tdest, tspeed, func);
	self = stemp;
};

void(vector tdest, float tspeed, void() func) SUB_CalcMove = {
	vector	vdestdelta;
	float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin) {
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
		
	// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;
	
	// calculate length of vector
	len = vlen (vdestdelta);
	
	// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	if (traveltime < 0.1) {
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
	
	// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

	// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1 / traveltime);	// qcc won't take vec/float	
};

// After moving, set origin to exact final destination
void()  SUB_CalcMoveDone = {
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};

// Calculate self.avelocity and self.nextthink to reach destangle from self.angles rotating
// The calling function should make sure self.think is valid
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt = {
	entity stemp;
	stemp = self;
	self = ent;
	SUB_CalcAngleMove(destangle, tspeed, func);
	self = stemp;
};

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove = {
	vector	destdelta;
	float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");
		
	// set destdelta to the vector needed to move
	destdelta = destangle - self.angles;
	
	// calculate length of vector
	len = vlen (destdelta);
	
	// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

	// scale the destdelta vector by the time spent traveling to get velocity
	self.avelocity = destdelta * (1 / traveltime);
	
	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
};

// After rotating, set angle to exact final angle
void() SUB_CalcAngleMoveDone = {
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;

	if (self.think1)
		self.think1();
};

void() DelayThink = {
	activator = self.enemy;
	SUB_UseTargets();
	remove(self);
};

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function
==============================
*/
void() SUB_UseTargets = {
	entity t, act, stemp, otemp;

	if (self.delay) {
		// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		t.spawnflags = self.spawnflags & MESSAGE_ALL_PLAYERS;
#ifdef ALLOW_DELAYED_THINK_CANCEL
		t.targetname = self.targetname;
		t.use = SUB_Null;
#endif
		return;
	}

	// print the message
	if (activator.classname == "player" && self.message != string_null) {
		if (self.spawnflags & MESSAGE_ALL_PLAYERS)
			centerprint_all (self.message); //Ingame message, localized
		else
			centerprint (activator, self.message); //Ingame message, localized

		if (!self.noise)
			sound(activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

	// kill the killtagets
	if (self.killtarget != string_null) {
		t = find(world, targetname, self.killtarget);		
		while (t) {
			remove(t);
			t = find(t, targetname, self.killtarget);
		}
	}
	
	// fire targets
	if (self.target != string_null) {
		act = activator;
		t = find(world, targetname, self.target);
		while (t) {
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if (self.use != SUB_Null) {
				if (self.use)
				self.use ();
			}
			self = stemp;
			other = otemp;
			activator = act;
			t = find(t, targetname, self.target);
		}
	}
};

/*
in nightmare mode, all attack_finished times become 0
some monsters refire twice automatically
update: not anymore! it makes nightmare too easy
*/
void(float normal) SUB_AttackFinished = {
	self.cnt = 0;	// refire count for nightmare
	self.attack_finished = time + normal;
};

float (entity targ) visible;

void (void() thinkst) SUB_CheckRefire = {
	if (skill != 3)
		return;

	if (self.cnt == 1)
		return;

	if (!visible (self.enemy))
		return;

	self.cnt = 1;
	self.think = thinkst;
};

void SUB_SwitchTargets(.string field, string oldtarget, string newtarget) {
	entity e = find(world, targetname, oldtarget);
	while (e) {
		e.field = newtarget;
		e = find(e, targetname, oldtarget);
	}
};

entity SUB_FindWithPredicate(entity start, .string field, string search, float(entity e) predicate = (float(entity e))SUB_True) {
	entity t = find(start, field, search);
	while (t && !predicate(t))
		t = find(t, field, search);
	return t;
};

float SUB_CountTargets(entity e, float(entity e) predicate = (float(entity e))SUB_True) {
	float cnt = 0;
	entity t = SUB_FindWithPredicate(world, targetname, e.target, predicate);
	while (t) {
		cnt++;
		t = SUB_FindWithPredicate(t, targetname, e.target, predicate);
	}
	return cnt;
};

entity SUB_RandomTarget(entity e, float(entity e) predicate = (float(entity e))SUB_True) {
	float cnt = SUB_CountTargets(e, predicate);
	if (cnt == 0)
		return world;
	cnt = floor(cnt * random());
	entity t = SUB_FindWithPredicate(world, targetname, e.target, predicate);
	while (cnt--)
		t = SUB_FindWithPredicate(t, targetname, e.target, predicate);
	return t;
};

void SUB_SetWorldtype() {
	if (self.worldtype)
		self.worldtype--;
	else
		self.worldtype = world.worldtype;
};


/*
================================================================

Hipnotic Sub-Routines

================================================================
*/

void (entity srcent, entity destent) SUB_CopyEntity = {
	destent.modelindex=srcent.modelindex;
	destent.absmin=srcent.absmin;
	destent.absmax=srcent.absmax;
	destent.ltime=srcent.ltime;
	destent.movetype=srcent.movetype;
	destent.solid=srcent.solid;
	destent.origin=srcent.origin;
	destent.oldorigin=srcent.oldorigin;
	destent.velocity=srcent.velocity;
	destent.angles=srcent.angles;
	destent.avelocity=srcent.avelocity;
	destent.punchangle=srcent.punchangle;
	destent.classname=srcent.classname;
	destent.model=srcent.model;
	destent.frame=srcent.frame;
	destent.skin=srcent.skin;
	destent.effects=srcent.effects;
	destent.mins=srcent.mins;
	destent.maxs=srcent.maxs;
	destent.size=srcent.size;
	destent.touch=srcent.touch;
	destent.use=srcent.use;
	destent.think=srcent.think;
	destent.blocked=srcent.blocked;
	destent.nextthink=srcent.nextthink;
	destent.groundentity=srcent.groundentity;
	destent.health=srcent.health;
	destent.frags=srcent.frags;
	destent.weapon=srcent.weapon;
	destent.weaponmodel=srcent.weaponmodel;
	destent.weaponframe=srcent.weaponframe;
	destent.currentammo=srcent.currentammo;
	destent.ammo_shells=srcent.ammo_shells;
	destent.ammo_nails=srcent.ammo_nails;
	destent.ammo_rockets=srcent.ammo_rockets;
	destent.ammo_cells=srcent.ammo_cells;
	destent.items=srcent.items;
	destent.takedamage=srcent.takedamage;
	destent.chain=srcent.chain;
	destent.deadflag=srcent.deadflag;
	destent.view_ofs=srcent.view_ofs;
	destent.button0=srcent.button0;
	destent.button1=srcent.button1;
	destent.button2=srcent.button2;
	destent.impulse=srcent.impulse;
	destent.fixangle=srcent.fixangle;
	destent.v_angle=srcent.v_angle;
	destent.idealpitch=srcent.idealpitch;
	destent.netname=srcent.netname;
	destent.enemy=srcent.enemy;
	destent.flags=srcent.flags;
	destent.colormap=srcent.colormap;
	destent.team=srcent.team;
	destent.max_health=srcent.max_health;
	destent.teleport_time=srcent.teleport_time;
	destent.armortype=srcent.armortype;
	destent.armorvalue=srcent.armorvalue;
	destent.waterlevel=srcent.waterlevel;
	destent.watertype=srcent.watertype;
	destent.ideal_yaw=srcent.ideal_yaw;
	destent.yaw_speed=srcent.yaw_speed;
	destent.aiment=srcent.aiment;
	destent.goalentity=srcent.goalentity;
	destent.spawnflags=srcent.spawnflags;
	destent.target=srcent.target;
	destent.targetname=srcent.targetname;
	destent.dmg_take=srcent.dmg_take;
	destent.dmg_save=srcent.dmg_save;
	destent.dmg_inflictor=srcent.dmg_inflictor;
	destent.owner=srcent.owner;
	destent.movedir=srcent.movedir;
	destent.message=srcent.message;
	destent.sounds=srcent.sounds;
	destent.noise=srcent.noise;
	destent.noise1=srcent.noise1;
	destent.noise2=srcent.noise2;
	destent.noise3=srcent.noise3;
	destent.wad=srcent.wad;
	destent.map=srcent.map;
	destent.worldtype=srcent.worldtype;
	destent.killtarget=srcent.killtarget;
	destent.light_lev=srcent.light_lev;
	destent.style=srcent.style;
	destent.th_stand=srcent.th_stand;
	destent.th_walk=srcent.th_walk;
	destent.th_run=srcent.th_run;
	destent.th_missile=srcent.th_missile;
	destent.th_melee=srcent.th_melee;
	destent.th_pain=srcent.th_pain;
	destent.th_die=srcent.th_die;
	destent.th_turn=srcent.th_turn;
	destent.oldenemy=srcent.oldenemy;
	destent.speed=srcent.speed;
	destent.lefty=srcent.lefty;
	destent.search_time=srcent.search_time;
	destent.attack_state=srcent.attack_state;
	destent.walkframe=srcent.walkframe;
	destent.attack_finished=srcent.attack_finished;
	destent.pain_finished=srcent.pain_finished;
	destent.invincible_finished=srcent.invincible_finished;
	destent.invisible_finished=srcent.invisible_finished;
	destent.super_damage_finished=srcent.super_damage_finished;
	destent.radsuit_finished=srcent.radsuit_finished;
	destent.invincible_time=srcent.invincible_time;
	destent.invincible_sound=srcent.invincible_sound;
	destent.invisible_time=srcent.invisible_time;
	destent.invisible_sound=srcent.invisible_sound;
	destent.super_time=srcent.super_time;
	destent.super_sound=srcent.super_sound;
	destent.rad_time=srcent.rad_time;
	destent.fly_sound=srcent.fly_sound;
	destent.axhitme=srcent.axhitme;
	destent.show_hostile=srcent.show_hostile;
	destent.jump_flag=srcent.jump_flag;
	destent.swim_flag=srcent.swim_flag;
	destent.air_finished=srcent.air_finished;
	destent.bubble_count=srcent.bubble_count;
	destent.deathtype=srcent.deathtype;
	destent.mdl=srcent.mdl;
	destent.mangle=srcent.mangle;
	destent.oldorigin=srcent.oldorigin;
	destent.t_length=srcent.t_length;
	destent.t_width=srcent.t_width;
	destent.dest=srcent.dest;
	destent.dest1=srcent.dest1;
	destent.dest2=srcent.dest2;
	destent.wait=srcent.wait;
	destent.delay=srcent.delay;
	destent.trigger_field=srcent.trigger_field;
	destent.noise4=srcent.noise4;
	destent.pausetime=srcent.pausetime;
	destent.movetarget=srcent.movetarget;
	destent.aflag=srcent.aflag;
	destent.dmg=srcent.dmg;
	destent.cnt=srcent.cnt;
	destent.think1=srcent.think1;
	destent.finaldest=srcent.finaldest;
	destent.finalangle=srcent.finalangle;
	destent.count=srcent.count;
	destent.lip=srcent.lip;
	destent.state=srcent.state;
	destent.pos1=srcent.pos1;
	destent.pos2=srcent.pos2;
	destent.height=srcent.height;
	destent.waitmin=srcent.waitmin;
	destent.waitmax=srcent.waitmax;
	destent.distance=srcent.distance;
	destent.volume=srcent.volume;
	destent.gorging=srcent.gorging;
	destent.stoleweapon=srcent.stoleweapon;
	destent.spawnfunction=srcent.spawnfunction;
	destent.spawnthink=srcent.spawnthink;
	destent.spawnmodel=srcent.spawnmodel;
	destent.spawnsolidtype=srcent.spawnsolidtype;
	destent.spawnmins=srcent.spawnmins;
	destent.spawnmaxs=srcent.spawnmaxs;
	destent.spawnclassname=srcent.spawnclassname;
 };
 
 vector (vector ang) SUB_NormalizeAngles = {
	while (ang_x > 360)
	   ang_x = ang_x - 360;
	while (ang_x < 0)
	   ang_x = ang_x + 360;
	while (ang_y > 360)
	   ang_y = ang_y - 360;
	while (ang_y < 0)
	   ang_y = ang_y + 360;
	while (ang_z > 360)
	   ang_z = ang_z - 360;
	while (ang_z < 0)
	   ang_z = ang_z + 360;
	return ang;
 };
 