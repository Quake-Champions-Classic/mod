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

void() movetarget_f;
void() t_movetarget;
void() knight_walk1;
void() knight_bow6;
void() knight_bow1;
void(entity etemp, entity stemp, entity stemp, float dmg) T_Damage;
float CanTakedamage(entity e) = { return e.takedamage > 0; }

/*

.enemy
Will be world if not currently angry at anyone.

.movetarget
The next path spot to walk toward.  If .enemy, ignore .movetarget.
When an enemy is killed, the monster will try to return to it's path.

.hunt_time
Set to time + something when the player is in sight, but movement straight for
him is blocked.  This causes the monster to use wall following code for
movement direction instead of sighting on the player.

.ideal_yaw
A yaw angle of the intended direction, which will be turned towards at up
to 45 deg / state.  If the enemy is in view and hunt_time is not active,
this will be the exact line towards the enemy.

.pausetime
A monster will leave it's stand state and head towards it's .movetarget when
time > .pausetime.

walkmove(angle, speed) primitive is all or nothing
*/

//
// when a monster becomes angry at a player, that monster will be used
// as the sight target the next frame so that monsters near that one
// will wake up even if they wouldn't have noticed the player
//
entity	sight_entity;
float	sight_entity_time;
void() FoundTarget; // HIP

void makevectorsfixed(vector ang) {
	ang_x *= -1;
	makevectors(ang);
};

float(float v) anglemod = {
	while (v >= 360)
		v = v - 360;
	while (v < 0)
		v = v + 360;
	return v;
};

/*
==============================================================================

MOVETARGET CODE

The angle of the movetarget effects standing and bowing direction, but has no effect on movement, which allways heads to the next target.

targetname
must be present.  The name of this movetarget.

target
the next spot to move to.  If not present, stop here for good.

pausetime
The number of seconds to spend standing or bowing for path_stand or path_bow

==============================================================================
*/


void() movetarget_f = {
	if (!self.targetname)
		objerror ("monster_movetarget: no targetname");
		
	self.solid = SOLID_TRIGGER;
	self.touch = t_movetarget;
	setsize(self, '-8 -8 -8', '8 8 8');
	
};

/*QUAKED path_corner (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will continue walking towards the next target corner.
*/
void() path_corner = {
	movetarget_f ();
};


/*
=============
t_movetarget

Something has bumped into a movetarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/
void() t_movetarget = {
	entity	temp;

	if (other.movetarget != self)
		return;
	
	if (other.enemy)
		return;		// fighting, not following a path

	// MG1 ------------------------------------------------------------------
	self.owner = other; //We have a valid visitor!
	if (other.dmg_inflictor && other.dmg_inflictor.classname == "path_corner") {
		//Clear the previous path corner from owning our new visitor
		if (other.dmg_inflictor.owner == other.dmg_inflictor)
			other.dmg_inflictor.owner = world;
	}
	other.dmg_inflictor = self;
	
	if (other.pausetime > time)
		return; // Waiting to walk...
	// ----------------------------------------------------------------------

	temp = self;
	self = other;
	other = temp;

	if (self.classname == "monster_ogre")
		sound(self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);// play chainsaw drag sound

	//dprint ("t_movetarget\n");
	if (other.target) { // HIP condition
		self.goalentity = self.movetarget = find(world, targetname, other.target);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		if (!self.movetarget) {
			self.pausetime = time + 999999;
			self.th_stand ();
			return;
		}
		// MG1 --------------------------------
		else if (other.wait) {
			self.pausetime = time + other.wait;
			self.th_stand ();
		}
		// HIP --------------------------------
		else if (other.delay) {
        	self.pausetime = time + other.delay;
        	self.th_stand ();
        }
	}
	// HIP -----------------------------------------------
	else {
    	self.pausetime = time + 999999;
    	self.th_stand();
    	return;
	}
	// ---------------------------------------------------
};

// HIP START ====================================================================================
//MED 01/20/97
/*
=============
t_followtarget

Something has bumped into a followtarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/
void() t_followtarget = {
	entity   temp;
	vector   spot1, spot2;
	entity   targ;
	entity   client;

	if (!(other.flags & FL_MONSTER))
		return;
	if (other.classname == "monster_decoy")
		return;
	if (other.wetsuit_time > time)
		return;
	targ = other.enemy;

	// see if any entities are in the way of the shot
	spot1 = other.origin + other.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, FALSE, other);
	if (trace_fraction == 1)
		return;

	if (other.enemy) {
		// make the monster tame
		other.oldenemy = other.enemy;
		other.enemy = world;
		other.think = other.th_walk;
	}

	temp = self;
	self = other;
	other = temp;

	self.goalentity = self.movetarget = find(world, targetname, other.target);
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	self.wetsuit_time = time + 2;
	if (!self.movetarget) {
		if (self.oldenemy != world) {
			self.enemy = self.oldenemy;
			FoundTarget();
			return;
		}
		else {
			client = checkclient ();
			if (!client) {
				self.enemy = client;
				FoundTarget();
				return;
			}
			self.pausetime = time + 999999;
			self.th_stand ();
		}
	}
};

void() followtarget_f = {
	self.solid = SOLID_TRIGGER;
	self.touch = t_followtarget;
	setmodel(self, self.model);  // set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
};

/*QUAKED path_follow (0.5 0.3 0) ?
Monsters will stop what they are doing and follow to the path
*/

void() path_follow = {
   followtarget_f ();
};

/*QUAKED path_follow2 (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will stop what they are doing and follow to the path
*/

void() path_follow2 = {
   	self.solid = SOLID_TRIGGER;
  	self.touch = t_followtarget;
	setsize(self, '-8 -8 -8', '8 8 8');
};
// HIP END ======================================================================================

// MG1 START ====================================================================================
//============================================================================
// Functions for changing how path_corners work.
//============================================================================
void monster_use();

void target_cancelpause_use() {
	entity mon = find(world, targetname, self.target);
	while (mon) {
		if (mon.flags & FL_MONSTER) {
			mon.pausetime = 0;
			mon.use = monster_use;
		}
		mon = find(mon, targetname, self.target);
	}
}

/*QUAKED target_cancelpause (0.5 0.3 0) (-8 -8 -8) (8 8 8)
When activated, will zero out the pausetime for monsters, causing them to continue walking their paths.
*/
void target_cancelpause() {
	if (!self.target) objerror("target_cancelpause with no target given.\n");
	if (!self.targetname) objerror("target_cancelpause with no targetname given.\n");
	self.use = target_cancelpause_use;
}

//============================================================================

void target_switchpath_use() {
	entity e = find(world, targetname, self.target);
	while (e) {
		if (e.classname == "path_corner") {
			string oldTarget = e.target;
			// Just switch the target
			e.target = self.netname;
			
			// Has this corner been visited by a monster lately?
			if (e.owner) {
				entity o = e.owner;
				entity oldTargetEntity = find(world, targetname, oldTarget);
				if (o.movetarget == oldTargetEntity) {
					// Switch that monster over to walk to the new target instead
					o.goalentity = o.movetarget = find(world, targetname, e.target);
					o.ideal_yaw = vectoyaw(o.goalentity.origin - o.origin);
				}
			}
		}
		e = find(e, targetname, self.target);
	}
}

/*QUAKED target_switchpath (0.5 0.3 0) (-8 -8 -8) (8 8 8)
When activated, will switch out the target .
*/
void target_switchpath() {
	if (!self.target) objerror("target_switchtarget with no target given.\n");
	if (!self.targetname) objerror("target_switchtarget with no targetname given.\n");
	if (!self.netname) objerror("target_switchtarget with no netname given.\n");
	self.use = target_switchpath_use;
}

#ifdef MONSTERS_AWARE_OF_CONTENTS
#define RETURN_IF_DIED_FROM_CONTENTS_DAMAGE if (CheckContentsDamage()) return;

//============================================================================
// CheckContentsDamage
// Returns TRUE if the monster died and shouldn't proceed with its current think
//============================================================================

.float dmgtime;
float CheckContentsDamage() {
	if (self.waterlevel == 0) return FALSE; //Not in any liquid
	if (self.health <= 0) return FALSE; //Dead or dying
	if (time < self.dmgtime) return FALSE; //Still processing damage from last time
	if (self.spawnflags & SPAWNFLAG_NO_CONTENTS_DAMAGE) return FALSE; //We're immune

	if (self.watertype == CONTENT_SLIME) {
		self.dmgtime = time + 1;
		T_Damage(self, world, world, 4 * self.waterlevel);
		// self.pain_finished = 0; //Enable for spasming monsters
	}
	else if (self.watertype == CONTENT_LAVA) {
		self.dmgtime = time + 0.2;
		if (self.classname == "monster_zombie") {
			T_Damage(self, world, world, 120); // GIB!
			return TRUE;
		}
		T_Damage(self, world, world, 30 * self.waterlevel);
		// self.pain_finished = 0; //Enable for spasming monsters
	}
	return self.health <= 0;
}
#else
#define RETURN_IF_DIED_FROM_CONTENTS_DAMAGE ;
#endif

// MG1 END ==================================================================

// just kidding, more MG1 mods
const vector RANGES_NORMAL = '120 500 1000';
const vector RANGES_NEARSIGHTED = '120 300 340';

const float VISIONCONE_NORMAL = 0.3;
const float VISIONCONE_NEARSIGHTED = 0.866; // ~30 degrees

/*
=============
range

returns the range catagorization of an entity reletive to self
0	melee range, will become hostile even if back is turned
1	visibility and infront, or visibility and show hostile
2	infront and show hostile
3	only triggered by damage
=============
*/
float(entity targ) range = {
	vector	spot1, spot2;
	float		r;	
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	r = vlen (spot1 - spot2);

	// MG1
	vector ranges = (self.spawnflags & SPAWNFLAG_NEARSIGHTED) ? ((self.enemy) ? RANGES_NORMAL * 0.8 : RANGES_NEARSIGHTED) : RANGES_NORMAL;
	
	if (r < ranges_x)
		return RANGE_MELEE;
	if (r < ranges_y)
		return RANGE_NEAR;
	if (r < ranges_z)
		return RANGE_MID;
	return RANGE_FAR;
};

/*
=============
visible

returns 1 if the entity is visible to self, even if not infront ()
=============
*/
float (entity targ) visible = {
	vector	spot1, spot2;
	
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline(spot1, spot2, TRUE, self);	// see through other monsters
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_fraction == 1) {
		visible_distance = vlen(spot2-spot1); // HIP: MED 11/21/96
		return TRUE;
	}
	return FALSE;
};


/*
=============
infront

returns 1 if the entity is in front (in sight) of self
=============
*/
float(entity targ) infront = {
	vector	vec;
	float		dot, dottarget;
	
	makevectorsfixed(self.angles);
	vec = normalize(targ.origin - self.origin);
	dot = vec * v_forward;
	
	// MG1
	dottarget = (self.spawnflags & SPAWNFLAG_NEARSIGHTED) ? VISIONCONE_NEARSIGHTED : VISIONCONE_NORMAL;

	if (dot > dottarget)
		return TRUE;
	return FALSE;
};

// HIP START: MED 10/18/96 added charmed stuff
//============================================================================
void() UpdateCharmerGoal = {
	entity targ;
	vector d;

	d = normalize(self.origin-self.charmer.origin);

	if (self.huntingcharmer == 1) {
		targ = spawn();
		self.trigger_field = targ;
		setorigin(targ,self.charmer.origin);
		self.huntingcharmer = 2;
		self.goalentity = targ;
	}
	if (self.huntingcharmer == 2) {
		targ = self.trigger_field;
		traceline(self.origin,self.charmer.origin,TRUE,self);
		if (trace_fraction == 1.0)
			setorigin(targ,self.charmer.origin);
	}
	else {
		targ = self.trigger_field;
		setorigin(targ,self.charmer.origin + (d*300));
	}
};

//============================================================================
void() HuntCharmer = {
	self.huntingcharmer = 1;
	UpdateCharmerGoal();
	self.think = self.th_walk;
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	self.nextthink = time + 0.1;
};

//============================================================================
void() FleeCharmer = {
	self.huntingcharmer = 1;
	UpdateCharmerGoal();
	self.huntingcharmer = 3;
	self.think = self.th_walk;
	self.nextthink = time + 0.1;
};

//============================================================================
void() StopHuntingCharmer = {
	self.goalentity = world;
	if (self.huntingcharmer>1)
		remove(self.trigger_field);
	self.huntingcharmer = 0;
	self.think = self.th_stand;
	self.nextthink = time + 0.1;
};
// HIP END CHARMER STUFF =====================================================

//============================================================================

void() HuntTarget = {
	self.goalentity = self.enemy;
	self.think = self.th_run;
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.nextthink = time + 0.1;
	SUB_AttackFinished (1);	// wait a while before first attack
};

void SightSound() {
	if (self.classname == "enforcer") {
		float rsnd;

		rsnd = rint(random() * 3);			
		if (rsnd == 1)
			sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
		else if (rsnd == 2)
			sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
		else if (rsnd == 0)
			sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
		else
			sound(self, CHAN_VOICE, self.noise4, 1, ATTN_NORM);
	}
	else if (self.noise != string_null) {
		// HIP --------------------------------------------------------------
		// I guess gremlins don't make a sound if they already stole a weapon
		if (self.classname == "monster_gremlin" && self.stoleweapon != 0)
			return;
		// Armagon's attenuation makes him heard everywhere???
		else if (self.classname == "monster_armagon")
			sound(self, CHAN_VOICE, self.noise, 1, 0.1);
		// ------------------------------------------------------------------
		else
			sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}
};

void() FoundTarget = {
	if (self.enemy.classname == "player") {
		// HIP -----------------------------------------------------------------------
		if (self.charmed) {
			if ((self.charmer == self.enemy) || (self.charmer == self.enemy.charmer)) {
				self.enemy = world;
				return;
			}
        }
		// ---------------------------------------------------------------------------

		// let other monsters see this monster for a while
		sight_entity = self;
		sight_entity_time = time;
	}
	// HIP -----------------------------------------------
	else if (self.charmed) {
    	if (self.charmer == self.enemy.charmer) {
        	self.enemy = world;
        	return;
        }
    }
	// ---------------------------------------------------
	
	self.show_hostile = time + 1;		// wake up other monsters

	SightSound ();
	HuntTarget ();
};

/*
===========
FindTarget

Self is currently not attacking anything, so try to find a target

Returns TRUE if an enemy was sighted

When a player fires a missile, the point of impact becomes a fakeplayer so
that monsters that see the impact will respond as if they had seen the
player.

To avoid spending too much time, only a single client (or fakeclient) is
checked each frame.  This means multi player games will have slightly
slower noticing monsters.
============
*/
float() FindTarget = {
	entity	client;
	float	r;

	//First, if we are attacking friends, try to find another friend
	if (self.spawnflags & MONSTER_ATTACK_FRIEND) {
		entity f = SUB_RandomTarget(self, CanTakedamage);
		if (f) {
			self.enemy = f;
			FoundTarget ();
			return TRUE;
		}
	}

	// if the first spawnflag bit is set, the monster will only wake up on
	// really seeing the player, not another monster getting angry

	// spawnflags & 3 is a big hack, because zombie crucified used the first
	// spawn flag prior to the ambush flag, and I forgot about it, so the second
	// spawn flag works as well

	// HIP: MED 10/17/96 added charmed stuff -------------------------------
	if (self.charmed) {
		self.effects = self.effects | EF_DIMLIGHT;
		if (self.huntingcharmer > 0) {
			UpdateCharmerGoal();
			r = vlen(self.origin - self.goalentity.origin);
			if (r < MIN_CHARMER_DISTANCE) {
				if ((self.huntingcharmer == 3) && (r > TOOCLOSE_CHARMER_DISTANCE))
					return FALSE;
				StopHuntingCharmer();
				return TRUE;
			}
		}
		else if (vlen (self.origin - self.charmer.origin) > MAX_CHARMER_DISTANCE) {
			HuntCharmer();
			return FALSE;
		}
		else if (vlen (self.origin - self.charmer.origin) < TOOCLOSE_CHARMER_DISTANCE) {
			FleeCharmer();
			return FALSE;
		}
	}
	// -----------------------------------------------------------------

	if (sight_entity_time >= time - 0.1 && !(self.spawnflags & 3)) {
		client = sight_entity;
		if (client.enemy == self.enemy)
			return TRUE;
	}

	// HIP: MED 10/17/96 added charmed clause --------------------------
	else if (self.charmed) {
		entity head;
		entity selected;
		float dist;

		selected = world;
		dist = CHARMED_RADIUS;
		head = findradius(self.origin, CHARMED_RADIUS);
		while (head) {
			if (!(head.flags & FL_NOTARGET) && (head.flags & FL_MONSTER)) {
				if (visible(head) && (visible_distance < dist) && (head.health>0)) {
					if ((head !=self) && (head != self.charmer) && (head.charmer != self.charmer)) {
						selected = head;
						dist = visible_distance;
					}
				}
			}
			head = head.chain;
		}
		if (selected == world)
			return FALSE;

		client = selected;
	}
	else {
		client = checkclient ();
		if (!client)
			return FALSE;	// current check entity isn't in PVS
	}

	if (client == self.enemy)
		return FALSE;
	
	if (!self.charmed) { // HIP: MED 10/17/96 added charmed stuff
		if (client.flags & FL_NOTARGET)
			return FALSE;
	}

	if (client.items & IT_INVISIBILITY)
		return FALSE;

	r = range (client);
	if (r == RANGE_FAR)
		return FALSE;
		
	if (!visible (client))
		return FALSE;

	if (!self.charmed) { // HIP: MED 10/17/96 added charmed stuff
		if (r == RANGE_NEAR) {
			if (client.show_hostile < time && !infront (client))
				return FALSE;
		}
		else if (r == RANGE_MID) {
			if (!infront (client))
				return FALSE;
		}
	}
	
	// got one
	self.enemy = client;
   	if ((!self.charmed) && (!self.enemy.charmed)) { // HIP: MED 10/17/96 added charmed stuff
		if (self.enemy.classname != "player") {
			self.enemy = self.enemy.enemy;
			if (self.enemy.classname != "player") {
				self.enemy = world;
				return FALSE;
			}
		}
	}

	// ROGUE: PGM hack
	if (self.classname != "dragon")
		FoundTarget ();
	
	return TRUE;
};


//=============================================================================

void(float dist) ai_forward = {
	walkmove(self.angles_y, dist);
};

void(float dist) ai_back = {
	walkmove((self.angles_y+180), dist);
};


/*
=============
ai_pain

stagger back a bit
=============
*/
void(float dist) ai_pain = {
	ai_back (dist);
};

/*
=============
ai_painforward

stagger back a bit
=============
*/
void(float dist) ai_painforward = {
	walkmove(self.ideal_yaw, dist);
};

/*
=============
ai_walk

The monster is walking it's beat
=============
*/
void(float dist) ai_walk = {	
	RETURN_IF_DIED_FROM_CONTENTS_DAMAGE // MG1

	if (!(self.qccFlags & QCC_FL_MONSTER_NOMOVE))
		movedist = dist;
	else
		movedist = 0;
	
	// check for noticing a player
	if (FindTarget())
		return;

	// HIP: MED 11/02/96 -------------------------------------
	if (self.huntingcharmer) {
		movetogoal(dist);
    	self.nextthink = time + ((self.nextthink - time) * 0.5);
	}
	// -------------------------------------------------------
	else
		movetogoal(dist);
};


/*
=============
ai_stand

The monster is staying in one place for a while, with slight angle turns
=============
*/
void() ai_stand = {
	RETURN_IF_DIED_FROM_CONTENTS_DAMAGE // MG1

	if (FindTarget())
		return;
	
	if (time > self.pausetime) {
		self.th_walk();
		return;
	}
};

/*
=============
ai_turn

don't move, but turn towards ideal_yaw
=============
*/
void() ai_turn = {
	if (FindTarget ())
		return;	
	ChangeYaw ();
};

// HIP: MED 11/10/96 added ai_turn_in_place
/*
=============
ai_turn_in_place

don't move, but turn towards ideal_yaw
=============
*/
void() ai_turn_in_place = {
	float delta;

	self.nextthink = time + 0.1;
	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);
	delta = fabs(self.angles_y - enemy_yaw);
	if (delta > MIN_ANGLE_DELTA) {
    	self.ideal_yaw = enemy_yaw;
    	ChangeYaw();
	}
	else
    	self.think = self.th_run;
};

//=============================================================================

/*
=============
ChooseTurn
=============
*/
void(vector dest3) ChooseTurn = {
	vector	dir, newdir;
	
	dir = self.origin - dest3;

	newdir_x = trace_plane_normal_y;
	newdir_y = 0 - trace_plane_normal_x;
	newdir_z = 0;
	
	if (dir * newdir > 0) {
		dir_x = 0 - trace_plane_normal_y;
		dir_y = trace_plane_normal_x;
	}
	else {
		dir_x = trace_plane_normal_y;
		dir_y = 0 - trace_plane_normal_x;
	}

	dir_z = 0;
	self.ideal_yaw = vectoyaw(dir);	
};

/*
============
FacingIdeal

============
*/
float() FacingIdeal = {
	float delta;	
	delta = anglemod(self.angles_y - self.ideal_yaw);
	if (delta > 45 && delta < 315)
		return FALSE;
	return TRUE;
};


//=============================================================================

float()	WizardCheckAttack;
float()	DogCheckAttack;

// HIP: MED -------------------------
float()  GremlinCheckAttack;
float()  ScourgeCheckAttack;
float()  ArmagonCheckAttack;
// ----------------------------------

float() CheckAnyAttack = {
	if (!enemy_visible)
		return FALSE;
	if (self.classname == "monster_army")
		return SoldierCheckAttack ();
	if (self.classname == "monster_ogre")
		return OgreCheckAttack ();
	if (self.classname == "monster_shambler")
		return ShamCheckAttack ();
	if (self.classname == "monster_demon1")
		return DemonCheckAttack ();
	if (self.classname == "monster_dog")
		return DogCheckAttack ();
	if (self.classname == "monster_wizard")
		return WizardCheckAttack ();
	// HIP ------------------------------------
	if (self.classname == "monster_gremlin")
    	return GremlinCheckAttack ();
	if (self.classname == "monster_scourge")
    	return ScourgeCheckAttack ();
	if (self.classname == "monster_armagon")
    	return ArmagonCheckAttack ();
	// ----------------------------------------
	return CheckAttack ();
};


/*
=============
ai_run_melee

Turn and close until within an angle to launch a melee attack
=============
*/
void() ai_run_melee = {
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (FacingIdeal()) {
		self.th_melee ();
		self.attack_state = AS_STRAIGHT;
	}
};


/*
=============
ai_run_missile

Turn in place until within an angle to launch a missile attack
=============
*/
void() ai_run_missile = {
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (FacingIdeal()) {
		self.th_missile ();
		self.attack_state = AS_STRAIGHT;
	}
};


/*
=============
ai_run_slide

Strafe sideways, but stay at aproximately the same range
=============
*/
void() ai_run_slide = {
	float ofs;	
	self.ideal_yaw = enemy_yaw;
	ChangeYaw();
	if (self.lefty)
		ofs = 90;
	else
		ofs = -90;
	
	if (walkmove(self.ideal_yaw + ofs, movedist))
		return;
		
	self.lefty = 1 - self.lefty;
	
	walkmove(self.ideal_yaw - ofs, movedist);
};

// HIP: MED
/*
=============
ai_run_dodge

Strafe sideways, but continue moving towards the enemy
Used by the Scourge.
=============
*/
void() ai_run_dodge = {
	float ofs;
	float newyaw;

	/*
	// attempt to jump over missiles
	if (self.enemy.weaponframe == 1)
	{
		if (self.flags & FL_ONGROUND)
		{
			self.origin_z = self.origin_z + 1;
			self.velocity = self.velocity + '0 0 500';
			self.flags = self.flags - FL_ONGROUND;
		}
		self.ltime = self.ltime + 1.0;
	}
	*/
	self.nextthink = time + 0.1;
	if (self.lefty)
		ofs = 40;
	else
		ofs = -40;

	if (time > self.ltime) {
		self.lefty = 1 - self.lefty;
		self.ltime = time + 0.8;
	}

	newyaw = enemy_yaw + ofs;
	self.ideal_yaw = enemy_yaw;
	if (walkmove(newyaw, movedist)) {
		ChangeYaw();
		return;
	}

	self.lefty = 1 - self.lefty;
	self.ltime = time + 0.8;
	newyaw = enemy_yaw - ofs;
	self.ideal_yaw = enemy_yaw;
	walkmove(newyaw, movedist);
	ChangeYaw();
};

/*
=============
ai_pathtogoal

Advanced movement code that use the bots pathfinder if allowed and conditions are right.
Feel free to add any other conditions needed.
=============
*/
void ai_pathtogoal(float dist) {
	if (self.allowPathFind == FALSE) {
		movetogoal(dist); // can't use pathfinding, so use normal Quake movement behavior.	
		return;
	}

	if (enemy_visible) {
		if (self.combat_style == CS_RANGED) {
			// do the normal "shoot, walk, shoot" behavior...
			movetogoal(dist);
			return;
		} else if (self.combat_style == CS_MELEE) {
			// path pretty close to the enemy, then let normal Quake movement take over.
			if (enemy_range > RANGE_NEAR) {
				if (walkpathtogoal(dist, self.enemy.origin) == PATH_IN_PROGRESS) {
					return;
				}
			}
		} else if (self.combat_style == CS_MIXED) {
			// most mixed combat AI have fairly short range attacks, so try to path within mid range.
			if (enemy_range > RANGE_MID) {
				if (walkpathtogoal(dist, self.enemy.origin) == PATH_IN_PROGRESS) {
					return;
				}
			}
		}
	} else {
		// we can't see our enemy, let's see if we can path to them
		if (walkpathtogoal(dist, self.enemy.origin) == PATH_IN_PROGRESS) {
			return;
		}
	}

	movetogoal(dist); // fall back to normal Quake movement behavior.
}

/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/
float RUN_STRAIGHT; // HIP

void(float dist) ai_run = {
	RETURN_IF_DIED_FROM_CONTENTS_DAMAGE // MG1
	
	float axis; // HIP
	
	if (!(self.qccFlags & QCC_FL_MONSTER_NOMOVE))
		movedist = dist;
	else
		movedist = 0;
	
	// see if the enemy is dead
	if (self.enemy.health <= 0) {
		self.enemy = world;

		// HIP: MED 10/30/96 added charmed stuff
		if (self.charmed) {
			HuntCharmer();
			return;
		}

		// FIXME: look all around for other targets
		if (self.oldenemy.health > 0) {
			self.enemy = self.oldenemy;
			HuntTarget();
		}
		else {
			if (self.movetarget)
				self.th_walk();
			else
				self.th_stand();
			return;
		}
	}

	self.show_hostile = time + 1;		// wake up other monsters

	// check knowledge of enemy
	enemy_visible = visible(self.enemy);
	if (enemy_visible)
		self.search_time = time + 5;

	// look for other coop players
	if (coop && self.search_time < time && !self.charmed) { // HIP: MED 10/17/96 added charmed stuff
		if (FindTarget ())
			return;
	}

	enemy_infront = infront(self.enemy);
	enemy_range = range(self.enemy);
	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);

	// HIP: MED ---------------------------------------------
	if (self.th_turn) {
		float angledelta;
		angledelta = fabs(self.angles_y - enemy_yaw);
		if (angledelta > MIN_ANGLE_DELTA) {
			self.th_turn();
			return;
		}
	}
	// ------------------------------------------------------
	
	if (self.attack_state == AS_MISSILE) {
		ai_run_missile();
		return;
	}
	if (self.attack_state == AS_MELEE) {
		ai_run_melee();
		return;
	}

	if (CheckAnyAttack())
		return;					// beginning an attack
		
	if (self.attack_state == AS_SLIDING) {
		ai_run_slide();
		return;
	}

	// HIP ---------------------------------------------
	if (self.attack_state == AS_DODGING) {
      ai_run_dodge();
		return;
	}

	// MED 11/11/96
	if (RUN_STRAIGHT && time > self.endtime) {
		RUN_STRAIGHT = 0;
		axis = walkmove(self.angles_y, movedist);
		if (!axis) {
			self.endtime = time + 3;
			movetogoal(dist);      // done in C code...
		}
		return;
	}
	// -------------------------------------------------

	// MG1 ---------------------------------------------
	if (isHordeMode) {
		ai_pathtogoal(dist);
		return;
	}
	// -------------------------------------------------

	// mal: added here for demonstration purposes for mods, but disabled by default in id1...
#ifdef USE_ADVANCED_PATHING
	ai_pathtogoal(dist);
#else
	movetogoal(dist); // fall back to normal Quake movement behavior.
#endif
};


/*
===========================================

DISSOLUTION OF ETERNITY AI FUNCTIONS

===========================================
*/

// new ai functions
//
// pmack

// ================================================================
// ai_orbit - used to have an object orbit an entity.
//
// destEnt: the entity to orbit
// radius: how large a radius to orbit at (0 will just track)
// offset: center of the orbit. this is added to dest.origin.
//
// Uses self.orbitPosition to determine current destination.
// ================================================================
void(entity destEnt, float radius, vector offset) ai_orbit = {
    vector dir;
    float dist;

	if (self.orbitPosition > 3)
		self.orbitPosition = 0;
	else if (self.orbitPosition < 0)
		self.orbitPosition = 0;
	
	traceline(self.origin, destEnt.origin + offset, TRUE, world);
	if (trace_fraction < 1) {
		setorigin(self, destEnt.origin + offset);
        self.orbitPosition = self.orbitPosition + 1;
		return;
	}
	
    if (self.orbitPosition == 0) {
        dir = (destEnt.origin + offset) - self.origin;
    	dir_x = dir_x + radius;
	}
	else if (self.orbitPosition == 1)  {
	    dir = (destEnt.origin + offset) - self.origin;
     	dir_y = dir_y + radius;
	}
	else if (self.orbitPosition == 2) {
	    dir = (destEnt.origin + offset) - self.origin;
    	dir_x = dir_x - radius;
    }
	else {
	    dir = (destEnt.origin + offset) - self.origin;
     	dir_y = dir_y - radius;
	}

    dist = vlen(dir);

    if (dist < 8)
        self.orbitPosition = self.orbitPosition + 1;
    else if (dist < 50) {
        self.velocity = normalize(dir);
        self.velocity = self.velocity * 150;
    }
    else {
        self.velocity = normalize(dir);
        self.velocity = self.velocity * 500;
    }
};

// ================================================================
// ai_track - used to have an object chase/track an enemy. the object
//		flies directly at the destEnt's view_ofs point.
//
// destEnt: the entity to orbit
// trackSpeed: the velocity multiplier (speed) of the object
// ================================================================
void(entity destEnt, float trackSpeed) ai_track = {
	vector	dir;	
	dir = destEnt.origin + destEnt.view_ofs;
	dir = normalize(dir - self.origin);
    self.velocity = dir * trackSpeed;
};

// ================================================================
// ViolentDeath
// ================================================================

void(string gibname, float dm) AccelerateGib = {
	entity	new;
	float	offset1;

	new = spawn();
	new.origin = self.origin;
	setmodel(new, gibname);
	setsize(new, '-8 -8 -8', '8 8 8');
	
	new.velocity = -1.25 * self.velocity;
	makevectors(new.velocity);
	offset1 = random() * 300 - 150;
	new.velocity = new.velocity + v_right * offset1;
	offset1 = random() * 300 - 150;
	new.velocity = new.velocity + v_up * offset1;
		
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	new.think = SUB_Remove;
	new.ltime = time;
	new.nextthink = time + 10 + random()*10;
	new.frame = 0;
	new.flags = 0;
};

void(float gibCount) ViolentDeath = {
	while (gibCount > 0) {
		AccelerateGib ("progs/gib1.mdl", (-4 * gibCount));
		AccelerateGib ("progs/gib2.mdl", (-6 * gibCount));
		AccelerateGib ("progs/gib3.mdl", (-8 * gibCount));
		gibCount = gibCount - 3;
	}	
};

entity(string gibname) StartGib = {
	entity new;
	new = spawn();
	new.origin = self.origin;
	setmodel(new, gibname);
	setsize(new, '0 0 0', '0 0 0');	
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.think = SUB_Remove;
	new.ltime = time;
	new.nextthink = time + 10 + random()*10;
	new.frame = 0;
	new.flags = 0;	
	return new;
};