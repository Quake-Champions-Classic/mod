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

// MG1: Yoder Sept 24 2021 Horde merge
float COUNTER_LOOPS = 2; // so counters can loop back to the start again
float MONSTER_ONLY = 8; // for trigger_hurt

void() trigger_reactivate = {
	self.solid = SOLID_TRIGGER;
};

float	SPAWNFLAG_NOMESSAGE = 1;
float	SPAWNFLAG_NOTOUCH = 1;

// the wait time has passed, so set back up for another activation
void() multi_wait = {
	if (self.max_health) {
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
};


// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void() multi_trigger = {
	if (self.nextthink > time)
		return;	// allready been triggered

	if (self.classname == "trigger_secret") {
		if (self.enemy.classname != "player")
			return;
		found_secrets = found_secrets + 1;
		WriteByte(MSG_ALL, SVC_FOUNDSECRET);
		
		msg_entity = self.enemy;
		WriteByte(MSG_ONE, SVC_ACHIEVEMENT);
		WriteString(MSG_ONE, "ACH_FIND_SECRET");
	}

	if (self.noise != string_null)
		sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	// don't trigger again until reset
	self.takedamage = DAMAGE_NO;

	activator = self.enemy;
	
	SUB_UseTargets();

	if (self.wait > 0) {
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else {	// We can't just remove(self) here because this is a touch function called while C code is looping through area links...
		self.touch = SUB_Null;
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}

	// HIP: MED 12/01/96 added cnt stuff -------------
	if (self.cnt > 0) {
		self.cnt = self.cnt - 1;
		if (self.cnt == 0) {
			self.touch = SUB_Null;
			self.nextthink = time + 0.1;
			self.think = SUB_Remove;
		}
	}

	if (activator.classname == "player" && world.model == "maps/e2m3.bsp" && self.message == "$map_dopefish") {
		msg_entity = activator;
		WriteByte(MSG_ONE, SVC_ACHIEVEMENT);
		WriteString(MSG_ONE, "ACH_FIND_DOPEFISH");
	}
};

void() multi_killed = {
	self.enemy = damage_attacker;
	multi_trigger();
};

void() multi_use = {
	self.enemy = activator;
	multi_trigger();
};

void() multi_touch = {
	if (other.classname != "player")
		return;
	
	// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0') {
		makevectors(other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}
	
	self.enemy = other;
	multi_trigger ();
};

/*QUAKED trigger_multiple (.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_multiple = {
	INHIBIT_COOP
	self.netname = "trigger_multiple"; // for bot nav support.
	
	if (self.sounds == 1) {
		precache_sound("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2) {
		precache_sound("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}
	else if (self.sounds == 3) {
		precache_sound("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
	}

	// MG1
	self.sounds = 0;
	if (self.spawnflags & SPAWNFLAG_TRIGGER_FIRST) {
		self.use = trigger_multiple;
		self.spawnflags &~= SPAWNFLAG_TRIGGER_FIRST;
		return;
	}
	
	if (!self.wait)
		self.wait = 0.2;

	self.use = multi_use;

	InitTrigger();

	if (self.health) {
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");
		
		self.max_health = self.health;
		self.th_die = multi_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin(self, self.origin);	// make sure it links into the world
	}
	else
		if (!(self.spawnflags & SPAWNFLAG_NOTOUCH))
			self.touch = multi_touch;

	if (self.cnt == 0) // HIP: MED 12/01/96 added cnt stuff
		self.cnt = -1;
};


/*QUAKED trigger_once (.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itself.  You must set the key "target" to the name of another object in the level that has a matching
"targetname".  If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle.  Use "360" for an angle of 0.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_once = {
	self.wait = -1;
	trigger_multiple();
	self.netname = "trigger_once"; // for bot nav support.
};

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
void() trigger_relay = {
	INHIBIT_COOP
	if (RemovedOutsideCoop()) return;
	self.use = SUB_UseTargets;
};