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

float IsExplosionDamage; // ROGUE
void() horde_spawn_powerup; // MG1: Yoder Sept24 2021 Horde Merge

void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker, entity inflictor) ClientObituary; // QCC

void() monster_death_use;

//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage = {
	// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH) {
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;

		if (trace_ent == targ)
			return TRUE;

		return FALSE;
	}
	
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};


/*
============
Killed
============
*/
void(entity targ, entity attacker, entity inflictor) Killed = {
	entity oself;

	oself = self;
	self = targ;
	
	if (self.health < -99)
		self.health = -99; // don't let sbar look bad if a player
	
	// HIP
	if (self.charmed)
		self.effects = self.effects - (self.effects & EF_DIMLIGHT);

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE) {	// doors, triggers, etc
		if (self.classname == "misc_explobox" || self.classname == "misc_explobox2") // MG1: yoder add, 27/09/202 to let the SUB_UseTargets work
			self.enemy = attacker;
		self.th_die ();
		self = oself;
		return;
	}
	
	self.enemy = attacker;

	// MG1: Yoder March04 2022, punish team killspree
	if (cvar("horde") && (attacker.classname) == "player" && (targ.classname == "player")) {
		dprint("punish teamkill\n");
		attacker.killtime = 0;
		add_frag(attacker, -2);
	}
	
	// bump the monster counter
	if (self.flags & FL_MONSTER) {
		// Yoder Sept24, 2021 Horde Merge
		if (horde_ent) {
			if (self.classname != "monster_zombie") { // zombies don't count
				killed_monsters = killed_monsters + 1;
				WriteByte(MSG_ALL, SVC_KILLEDMONSTER); 
			}
			
			// check kill spree
			if (attacker.classname == "player") {
				attacker.killspree++;
				attacker.killtime = time + KILLSPREE_GAP;
					
				if (time < attacker.killtime) {
					if (attacker.killspree >= 14)
						sprint(attacker, "$qc_horde_streak_generic", ftos(attacker.killspree));
					else if (attacker.killspree == 13)
						sprint(attacker, "$qc_horde_streak_13");
					else if (attacker.killspree == 12)
						sprint(attacker, "$qc_horde_streak_12");
					else if (attacker.killspree == 11)
						sprint(attacker, "$qc_horde_streak_11");
					else if (attacker.killspree == 10)
						sprint(attacker, "$qc_horde_streak_10");
					else if (attacker.killspree == 9)
						sprint(attacker, "$qc_horde_streak_9");
					else if (attacker.killspree == 8)
						sprint(attacker, "$qc_horde_streak_8");
					else if (attacker.killspree == 7)
						sprint(attacker, "$qc_horde_streak_7");
					else if (attacker.killspree == 6)
						sprint(attacker, "$qc_horde_streak_6");
					else if (attacker.killspree == 5)
						sprint(attacker, "$qc_horde_streak_5");
					else if (attacker.killspree == 4)
						sprint(attacker, "$qc_horde_streak_4");
					else if (attacker.killspree == 3)
						sprint(attacker, "$qc_horde_streak_3");
					else if (attacker.killspree == 2)
						sprint(attacker, "$qc_horde_streak_2");
				}
			}
			
			// check to see about spawning a powerup
			horde_spawn_powerup();
		}
		else { // standard behavior
			killed_monsters = killed_monsters + 1;
			WriteByte(MSG_ALL, SVC_KILLEDMONSTER);
		}

		if (attacker.classname == "player") {
			add_frag(attacker, 1);
			// Monster kills cool down the ability timer because it's fun to use abilities more than once in a SP map
			// Just don't offer cooldowns when using abilities to do the killing
			if (!(inflictor.qccFlags & QCC_FL_ABILITY) && attacker.qccAbilityTimer > -1 && attacker.qccAbilityTimer <= time + QCC_GLOBAL_COOLDOWN)
				QCC_AbilityCooldown(attacker);
		}
		
		if (attacker != self && attacker.flags & FL_MONSTER) {
			WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
			WriteString(MSG_ALL, "ACH_FRIENDLY_FIRE");
		}
	}

	// ROGUE: Guarantee gib if killed by buzzsaw.
	if (attacker.classname == "buzzsaw" || 
		attacker.classname == "Vengeance" ||
		attacker.classname == "pendulum")
		self.health = -99;
	
	self.gravity = 1.0; // PGM - gravity fix!
	
	if (attacker.classname == "player") {
		// Reset ability timer if we died while using an ability
		if (targ.qccAbilityTimer < 0)
			targ.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
		// Some champions have taunts
		attacker.qccSpeakFrag(targ, attacker);
	}
		
	
	ClientObituary(self, attacker, inflictor);
	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;

	monster_death_use();
	self.th_die();

	if (attacker.qccChampion == QCC_CALEB) {
		if ((targ.classname == "player") || targ.movetype == MOVETYPE_BOUNCE || targ.movetype == MOVETYPE_GIB)
			QCC_DropLifeEssence(targ, attacker);
	}
	
	self = oself;
};

// ROGUE ====
// Function prototype for shield impact handler.
// ==========
float(entity targ, entity inflictor, entity attacker, float damage) shield_hit;

/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/

float empathyused; // HIP

void(entity targ, entity inflictor, entity attacker, float damage) T_Damage = {
	vector	dir;
	entity	oldself;
	float	save, take;

	if (!targ.takedamage)
		return;

	// MG1: Yoder add, September 9 2020
	if (targ.is_frozen)
		return;

	// mal: in Coop, don't let bots hurt human teammates - that would be REALLY annoying...
	if (coop && targ != attacker && targ.classname == "player" && attacker.classname == "player")
		if (attacker.flags & FL_ISBOT && !(targ.flags & FL_ISBOT))
			return;

	// shub kill crash fix.
	if (targ.classname == "monster_oldone" && damage < 9999)
		return;
		
	if (targ.classname == "trigger_explosion") {
		if (IsExplosionDamage != 1)
			return;
	}
	IsExplosionDamage = 0;
	
	if (targ.items2 & IT2_SHIELD) {
		// Allow some damage to pass through.
		damage = shield_hit(targ, inflictor, attacker, damage);
		if (damage == 0)
			return;
	}

	// used to keep track of what hit us
	damage_inflictor = inflictor;
	// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

	// figure momentum add
	if ((inflictor != world) && (targ.movetype == MOVETYPE_WALK)) {
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		targ.velocity += dir * damage * 4;
	}

	// Self damage reduction
	if (targ == attacker) {
		if (targ.qccSelfDamage != 0)
			damage = ceil(damage * targ.qccSelfDamage);
		else
			damage /= 2;
	}

	if (targ != attacker && targ.team == attacker.team) {
		if (teamplay) // Don't hurt team mates!
			return;
		if (deathmatch >= QCC_TDM)
			return;
		if (targ.qccFlags & QCC_FL_ABILITY) // Don't hurt your team's ability spawns (Totems, turrets, etc...)
			return;
	}

	// Don't hurt your own ability spawns (Totems, turrets, etc...)
	if (targ.qccFlags & QCC_FL_ABILITY) {
		if (targ.owner == attacker || targ.owner.owner == attacker)
			return;
	}

	// check for quad damage powerup on the attacker
	if (attacker.super_damage_finished > time)
		damage = damage * 4;
	
	// ROGUE: rune power up (Black Magic)
	damage = RuneApplyBlack(damage, attacker); // QCC: DoE only applies it in DM but it might be fun to have in SP
	
	// HIP
	//check for empathy shields
	if ((targ.items2 & HIP_IT_EMPATHY_SHIELDS) && !(inflictor.items2 & HIP_IT_EMPATHY_SHIELDS) && (targ != attacker)) {
		empathyused = 1;
		damage = damage / 2;
		T_Damage(attacker, targ, targ, damage);
		empathyused = 0;
	}

	// QCC:	Pentagram now only reduces damage by 2/3
	// Put it here so that it reduces armor loss as well
	if (targ.invincible_finished >= time) {
		if (self.invincible_sound < time) {
			sound(targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
		damage = ceil(damage * 0.33);
	}
	else if (targ.qccArmorType2 > 0) // Scalebearer and Clutch have special damage reduction abilities, but don't let them stack with Pentagram
		damage = ceil(damage * (1.0 - targ.qccArmorType2));

	// save damage based on the target's armor level
	save = ceil(targ.armortype * damage);

	if (save >= targ.armorvalue)
		save = targ.armorvalue;
	
	targ.armorvalue = targ.armorvalue - save;
	take = ceil(damage - save);

	// add to the damage total for clients, which will be sent as a single
	// message at the end of the frame
	// FIXME: remove after combining shotgun blasts?
	if (targ.flags & FL_CLIENT) {
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

	// check for godmode or invincibility
	if (targ.flags & FL_GODMODE)
		return;

	if (targ.items2 & HIP_IT_EMPATHY_SHIELDS) {
    	if (self.empathy_sound < time) {
        	sound(targ, CHAN_ITEM, "hipitems/empathy2.wav", 1, ATTN_NORM);
        	self.empathy_sound = time + 0.5;
		}
	}
	
	// MG1: special case for killable chthon (yoder, december 16 2020)
	if ((targ.classname == "monster_boss")) { // is killable chthon
		// is MG1 Cthon with Killable flag
		if (targ.spawnflags & 2) {
			if (attacker.weapon != IT_LIGHTNING && attacker.weapon != QCC_ABILITY)
				if (damage < 40000)
					return;
		}
		else if (damage < 40000) // QCC: we can telefrag Cthon
			return;
	}

	// ROGUE: rune power up (Earth Magic)
	take = RuneApplyEarth(take, targ); // QCC: DoE only applies this in DM but might be fun for SP
		
	// [NDS] haleyjd: if player and actual health damage is inflicted, flag it here
	if (targ.classname == "player" && take != 0)
		targ.took_damage = 1;

	// do the damage
	targ.health = targ.health - take;

	if (targ.health <= 0) {
		Killed (targ, attacker, inflictor);
		return;
	}

	if (targ.qccStunned > time) // QCC: Stunned enemies can't react until the stun is over
		return;

	 if (targ.classname == "player")
	 	targ.qccSpeakDamaged(targ, inflictor);

	//react to the damage
	oldself = self;
	self = targ;

	if ((self.flags & FL_MONSTER) && attacker != world) {
		// HIP: charmed stuff
		if (self != attacker && attacker != self.enemy && self.charmer != attacker && self.classname != "monster_dragon") {
			// Get mad unless of the same class (except when same-class infighting allowed)
			if ((self.classname != attacker.classname) || (self.qccFlags & QCC_FL_INFIGHT)) {
				// If in horde mode, have enemies obey a reaggro time
				if (cvar("horde")) {
					if ((self.enemy.classname == "player") &&  // current and new enemy are both players, check reaggro times
						(attacker.classname == "player"))
					{
						// check reaggro times
						if ((!self.aggro_time) || (self.aggro_time + AGGRO_MIN + (random() * AGGRO_ADD < time))) {
							self.oldenemy = self.enemy;
							self.enemy = attacker;
							self.aggro_time = time;
							FoundTarget();
						}
					}
					else { // immediately aggro, store the player if previous was player
						if (self.enemy.classname == "player")
							self.oldenemy = self.enemy;
						self.enemy = attacker;
						FoundTarget();
					}
				}
				// ---------------------------------------------------------------------------
				else { // original behavior
					if (self.enemy.classname == "player")
						self.oldenemy = self.enemy;
					self.enemy = attacker;
					FoundTarget();
				}
			}
		}
	}

	if (self.th_pain) {
		self.th_pain (attacker, take);
		// nightmare mode monsters don't go into pain frames often
		if (skill == 3)
			self.pain_finished = time + 5;		
	}

	self = oldself;
};

/*
ROGUE ============
T_EELZap
==================
*/
void(entity inflictor, entity attacker, float damage) T_EELZap = {
	local	float 	points;
	local	entity	head;
	local	vector	org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head) {
		if (head.takedamage) {
			org = head.origin + (head.mins + head.maxs)*0.5;
			points = 0.5*vlen (inflictor.origin - org);
			if (points < 0)
				points = 0;
			points = damage - points;
			if (head == attacker)
				points = points * 0.5;
			if (points > 0) {
				if (CanDamage (head, inflictor)) {	// eels take no damage from this attack
					if (head.classname != "monster_eel" && (head.flags & FL_INWATER))					
						T_Damage(head, inflictor, attacker, points);
				}
			}
		}
		head = head.chain;
	}
};

/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage = {
	local	float 	points;
	local	entity	head;
	local	vector	org;

	IsExplosionDamage = 1; // ROGUE

	// MG1
	#ifdef GIB_DOWNED_ZOMBIES
	//Look for downed zombies and gib them if possible
	if (damage >= 60) {
		head = find(world, classname, "monster_zombie");
		while (head) {
			if (head.solid == SOLID_NOT) {
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
				if (points > 60) {
					if (CanDamage(head, inflictor))
						Killed(head, attacker, inflictor);
				}
			}
			head = find(head, classname, "monster_zombie");
		}
	}
	#endif

	head = findradius(inflictor.origin, damage + 40);
	
	while (head) {
		if (head != ignore && head.takedamage) {
			org = head.origin + (head.mins + head.maxs) * 0.5;
			points = 0.5 * vlen (inflictor.origin - org);
			if (points < 0)
				points = 0;
			points = damage - points;

			if ((inflictor.qccFlags & QCC_FL_ABILITY) && (head.flags & FL_MONSTER))
				points *= 4;

			if (points > 0) {
				if (CanDamage(head, inflictor)) {
					if (head.qccFlags & QCC_FL_RESIST_ROCKET)
						points *= 0.5;
					else if (head.qccFlags & QCC_FL_REINFORCED)
						points *= 0.8;
					
					T_Damage(head, inflictor, attacker, points);
				}
			}
		}
		head = head.chain;
	}
};

/*
============
T_BeamDamage
============
*/
void(entity attacker, float damage) T_BeamDamage = {
	local	float 	points;
	local	entity	head;
	
	head = findradius(attacker.origin, damage+40);
	
	while (head) {
		if (head.takedamage) {
			points = 0.5 * vlen(attacker.origin - head.origin);
			if (points < 0)
				points = 0;

			points = damage - points;

			if (head == attacker)
				points = points * 0.5;

			if (points > 0 && CanDamage(head, attacker)) {
				if (head.qccFlags & QCC_FL_RESIST_LIGHT)
					T_Damage(head, attacker, attacker, points * 0.5);
				else
					T_Damage(head, attacker, attacker, points);
			}
		}
		head = head.chain;
	}
};
