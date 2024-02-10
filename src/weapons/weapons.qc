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

// called by worldspawn
void() W_Precache = {
	precache_sound("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound("weapons/rocket1i.wav");	// spike gun
	precache_sound("weapons/sgun1.wav");
	precache_sound("weapons/guncock.wav");	// player shotgun
	precache_sound("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound("weapons/spike2.wav");	// super spikes
	precache_sound("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound("weapons/grenade.wav");	// grenade launcher
	precache_sound("weapons/bounce.wav");		// grenade bounce
	precache_sound("weapons/shotgn2.wav");	// super shotgun

	// HIP: MED -----------------------------------------------
	precache_sound("enforcer/enfstop.wav");   // laser cannon
	//MED 11/06/96
	precache_sound("knight/sword1.wav");   // laser cannon
	precache_sound("hipweap/laserg.wav");   // laser cannon
	precache_sound("hipweap/laserric.wav");   // laser cannon ricochet
	precache_sound("hipweap/proxwarn.wav");   // proximity bomb
	precache_sound("hipweap/proxbomb.wav");   // proximity bomb
	//MED 11/19/96
	precache_sound("hipweap/mjolhit.wav");   // mjolnir
	precache_sound("hipweap/mjolslap.wav");   // mjolnir
	precache_sound("hipweap/mjoltink.wav");   // mjolnir
	// --------------------------------------------------------
};

void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;

float() crandom = {	return 2 * (random() - 0.5); };

vector() wall_velocity = {
	vector vel;	
	vel = normalize(self.velocity);
	vel = normalize(vel + v_up * (random()- 0.5) + v_right * (random()- 0.5));
	vel = vel + trace_plane_normal * 2;
	vel = vel * 200;	
	return vel;
};

/*
================
GORE
================
*/
void(vector org, vector vel) SpawnMeatSpray = {
	entity missile;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectorsfixed(self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();
	missile.avelocity = '3000 1000 2000';
	
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel(missile, "progs/zom_gib.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, org);
};

void(vector org, vector vel, float damage) SpawnBlood = { particle(org, vel * 0.1, 73, damage * 2); };

void(float damage) spawn_touchblood = {
	vector vel = wall_velocity () * 0.2;
	SpawnBlood(self.origin + vel * 0.01, vel, damage);
};

void(vector org, vector vel) SpawnChunk = { particle(org, vel * 0.02, 0, 10); };


/*
==============================================================================
MULTI-DAMAGE
Collects multiple small damages into a single damage
==============================================================================
*/
entity	multi_ent;
float	multi_damage;

void() ClearMultiDamage = {
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage = {
	if (!multi_ent)
		return;
	T_Damage(multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage = {
	if (!hit)
		return;	
	if (hit != multi_ent) {
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack = {
	vector vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir * 4;

	if (trace_ent.takedamage && other.classname != "monster_boss") { // yoder mod, jan 05 2021
		SpawnBlood(org, vel * 0.2, damage);
		AddMultiDamage(trace_ent, damage);
	}
	else {
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord(MSG_BROADCAST, org_x);
		WriteCoord(MSG_BROADCAST, org_y);
		WriteCoord(MSG_BROADCAST, org_z);
	}
};

/*
==============================================================================
Explosion
==============================================================================
*/
void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

void() BecomeExplosion = {
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel(self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1();
};

/*
===============================================================================
PLAYER WEAPON USE
===============================================================================
*/
void() player_run;

void() W_SetCurrentAmmo = {
	// Don't switch away from active abilities
	if (self.weapon == QCC_ABILITY)
		return;
	
	// Get out of any weapon firing states
	if (self.th_run)
		self.th_run();
	else
		player_run();
	
	self.weaponframe = 0;

	self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
	//self.items2 = self.items2 - (self.items2 & (QCC_IT2_BULLETS | QCC_IT2_BOLTS | QCC_IT2_SLUGS));

	switch (self.weapon) {
		case IT_AXE:
			self.weaponmodel = self.qccMeleeMdl;
			self.currentammo = 0;
			self.weaponframe = 0;
			break;
		
		case IT_SHOTGUN:
		case IT_SUPER_SHOTGUN: {
			if (self.weapon == IT_SUPER_SHOTGUN)
				self.weaponmodel = "progs/v_shot2.mdl";
			else
				self.weaponmodel = "progs/v_shot.mdl";
			self.currentammo = self.ammo_shells;
			self.items = self.items | IT_SHELLS;
			break;
		}

		case IT_NAILGUN:
		case IT_SUPER_NAILGUN: {
			if (self.weapon == IT_SUPER_NAILGUN)
				self.weaponmodel = "progs/v_nail2.mdl";
			else
				self.weaponmodel = "progs/v_nail.mdl";
			self.currentammo = self.ammo_nails;
			self.items = self.items | IT_NAILS;
			break;
		}

		case IT_GRENADE_LAUNCHER:
		case IT_ROCKET_LAUNCHER:
		case IT_PROXIMITY_GUN: {
			if (self.weapon == IT_ROCKET_LAUNCHER)
				self.weaponmodel = "progs/v_rock2.mdl";
			else if (self.qccAltWeapon == 1)
				self.weaponmodel = "progs/v_prox.mdl";
			else
				self.weaponmodel = "progs/v_rock.mdl";
			self.currentammo = self.ammo_rockets;
			self.items = self.items | IT_ROCKETS;
			break;
		}

		case IT_LIGHTNING:
			self.weaponmodel = "progs/v_light.mdl";
			self.currentammo = self.ammo_cells;
			self.items = self.items | IT_CELLS;
			break;
		
		case IT_LASER_CANNON:
			self.weaponmodel = "progs/v_laserg.mdl";
			self.currentammo = self.ammo_cells;
			self.items = self.items | IT_CELLS;
			break;

		case QCC_IT_RAILGUN:
			self.weaponmodel = "progs/v_rail.mdl";
			self.currentammo = self.ammo_slugs;
			self.items = self.items | IT_CELLS;
			break;
		
		default:
			self.currentammo = 0;
			self.weaponmodel = string_null;
			break;
	}
};

float() W_BestWeapon = {
	float it;

	// QCC -------------------------------
	if (self.weapon == QCC_ABILITY)
		return QCC_ABILITY;
	// -----------------------------------
	
	it = self.items;

	if (self.ammo_slugs > 0 && (it & QCC_IT_RAILGUN))
		return QCC_IT_RAILGUN;
	if (self.waterlevel <= 1 && self.ammo_cells > 0 && (it & IT_LIGHTNING))
		return IT_LIGHTNING;
	else if (self.ammo_cells > 0 && (it & IT_LASER_CANNON)) // HIP: MED
		return IT_LASER_CANNON;
	else if (self.ammo_nails > 1 && (it & IT_SUPER_NAILGUN))
		return IT_SUPER_NAILGUN;
	else if (self.ammo_shells > 1 && (it & IT_SUPER_SHOTGUN))
		return IT_SUPER_SHOTGUN;
	else if (self.ammo_nails > 0 && (it & IT_NAILGUN))
		return IT_NAILGUN;
	else if (self.ammo_shells > 0 && (it & IT_SHOTGUN))
		return IT_SHOTGUN;
	else if (it & IT_MJOLNIR) // HIP: MED
		return IT_MJOLNIR;

	if (self.qccChampion != QCC_KEEN)
		return IT_AXE;
	
	return 0;
};

float(entity playerEnt, float old, float new) W_WantsToChangeWeapon = {
	float playerFlags = CheckPlayerEXFlags(playerEnt);
	if ((playerFlags & PEF_CHANGENEVER) != FALSE)
		return FALSE;	
	if (((playerFlags & PEF_CHANGEONLYNEW) != FALSE) && old == new)
		return FALSE;
	return TRUE;
};

float() W_HasNoAmmo = {
	if (self.currentammo)
		return FALSE;
	if (self.weapon == IT_AXE || self.weapon == QCC_ABILITY || self.weapon == 0)
		return FALSE;	// doesnt need ammo
	if (self.weapon == IT_MJOLNIR) // HIP: MED
		return FALSE;	
	self.weapon = W_BestWeapon ();
	W_SetCurrentAmmo ();	
	// drop the weapon down
	return TRUE;
};

/*
============
W_Attack
============
*/
// Weapon Attack Functions
void() W_FireShotgun;
void() W_FireSuperShotgun;
void() W_FireGrenade;
void() W_FireRocket;
void() W_FireProximityGrenade;

// Player Attack Animations
void() player_run;
void() player_axe1;
void() player_axeb1;
void() player_axec1;
void() player_axed1;
void() player_shot1;
void() player_nail1;
void() player_light1;
void() player_rocket1;
// HIP
void() player_laser1;
//void() player_hammer1;
//void() player_mjolnir1;

void() SuperDamageSound = {
	if (self.super_damage_finished > time) {
		if (self.super_sound < time) {
			self.super_sound = time + 1;
			sound(self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};

void() W_Attack = {
	if (W_HasNoAmmo())
		return;
	
	makevectors	(self.v_angle);		// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up
	
	// [NDS] haleyjd: record player attacked
	if (self.weapon != IT_AXE)
		self.fired_weapon = 1;

	switch (self.weapon) {
		case IT_AXE: {
			sound(self, CHAN_WEAPON, self.qccSndMelee, 1, ATTN_NORM);
			float r = random();
			if (r < 0.25)
				player_axe1();
			else if (r<0.5)
				player_axeb1();
			else if (r<0.75)
				player_axec1();
			else
				player_axed1();
			self.attack_finished = time + 0.5;
			if (self.qccChampion == QCC_DUSKDUDE) // Dusk Dude's sickles are fast in DUSK
				self.attack_finished = time + 0.3;
			return;
		}

		case IT_SHOTGUN:
			player_shot1();
			W_FireShotgun();
			self.attack_finished = time + 0.5;
			return;
		
		case IT_SUPER_SHOTGUN:
			player_shot1();
			W_FireSuperShotgun();
			self.attack_finished = time + 0.7;
			return;
		
		case IT_NAILGUN:
		case IT_SUPER_NAILGUN:
			player_nail1();
			return;
		
		case IT_GRENADE_LAUNCHER: {
			player_rocket1();
			if (!self.qccAltWeapon)
				W_FireGrenade();
			else
				W_FireProximityGrenade();
			self.attack_finished = time + 0.6;
			return;
		}

		case IT_ROCKET_LAUNCHER:
			player_rocket1();
			W_FireRocket();
			self.attack_finished = time + 0.8;
			return;
		
		case IT_LIGHTNING:
			player_light1();
			self.attack_finished = time + 0.1;
			sound(self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
			return;
		
		case QCC_IT_RAILGUN:
			player_rocket1();
			QCC_W_FireRail();
			self.attack_finished = time + 1.5;
			return;
		
		case IT_LASER_CANNON:
			player_laser1();
			return;
		
		case IT_MJOLNIR: {
			/*
			if (self.ammo_cells < 30)
				player_hammer1();
			else
				player_mjolnir1();
				self.attack_finished = time + 0.8;
			*/
		}
	}
};

void() W_ChangeWeapon = {
	float am, fl, aw;
	
	// Don't switch away from ability
	if (self.weapon == QCC_ABILITY)
		return;

	fl = self.items;
	aw = FALSE;
	am = 0;
	
	if (self.impulse == 1)
		fl = IT_AXE;
	else if (self.impulse == 2)	{
		fl = IT_SHOTGUN;
		if (self.ammo_shells < 1)
			am = 1;
	}
	else if (self.impulse == 3)	{
		fl = IT_SUPER_SHOTGUN;
		if (self.ammo_shells < 2)
			am = 1;
	}		
	else if (self.impulse == 4)	{
		fl = IT_NAILGUN;
		if (self.ammo_nails < 1)
			am = 1;
	}
	else if (self.impulse == 5)	{
		fl = IT_SUPER_NAILGUN;
		if (self.ammo_nails < 2)
			am = 1;
	}
	else if (self.impulse == 6)	{
		if (self.weapon == IT_GRENADE_LAUNCHER && !(self.qccAltWeapon))
			aw = TRUE; // switch to prox gun
		fl = IT_GRENADE_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 7)	{
		fl = IT_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 8)	{
		fl = IT_LIGHTNING;
		if (self.ammo_cells < 1)
			am = 1;
	}

	else if (self.impulse == QCC_IM_RAILGUN) {
		fl = QCC_IT_RAILGUN;
		if (self.ammo_slugs < 1)
			am = 1;			
	}

	else if (self.impulse == 37) {
		fl = IT_LASER_CANNON;
		if (self.ammo_cells < 1)
			am = 1;
	}
	/*
	else if (self.impulse == 226)
		fl = IT_MJOLNIR;
	*/
	else if (self.impulse == 36) {
		fl = IT_PROXIMITY_GUN;
		aw = 1;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	// ------------------------------------------
	
	self.impulse = 0;
	
	// QCC: need a special condition for alt weapons
	if (aw) {
		if (!(self.qccItems3 & fl)) {
			// don't have the weapon or the ammo
			if (ExtSupported("EX_SPRINT"))
				sprint(self, "$qc_no_weapon");
			else
				sprint(self, "No weapon.\n");
			return;
		}
	}
	else if (!(self.items & fl)) {
		if (ExtSupported("EX_SPRINT"))
			sprint(self, "$qc_no_weapon");
		else
			sprint(self, "No weapon.\n");
		return;
	}

	if (am)	{
		if (ExtSupported("EX_SPRINT"))
			sprint(self, "$qc_not_enough_ammo");
		else
			sprint(self, "Not enough ammo.\n");
		return;
	}
	
	self.weapon = fl;
	self.qccAltWeapon = aw;	
	W_SetCurrentAmmo ();
};

//Go to the next weapon with ammo
void() CycleWeaponCommand = {
	float it, am;
	
	it = self.items;
	self.impulse = 0;
	
	while (1) {
		am = 0;

		// HIP: MED ------------------------------------
		if (self.weapon == IT_LASER_CANNON) {
			/*
			if (self.qccChampion == ????)
	        	self.weapon = IT_MJOLNIR;
			else
			*/
				self.weapon = IT_AXE;
		}
		// ---------------------------------------------
		else if (self.weapon == IT_AXE) {
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == IT_SHOTGUN) {
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}		
		else if (self.weapon == IT_SUPER_SHOTGUN) {
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN) {
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN) {
			self.weapon = IT_GRENADE_LAUNCHER;
			self.qccAltWeapon = FALSE;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER) {
			if ((self.qccItems3 & IT_PROXIMITY_GUN) && !(self.qccAltWeapon))
				self.qccAltWeapon = TRUE; // swap to prox gun
			else {
				self.weapon = IT_ROCKET_LAUNCHER;
				self.qccAltWeapon = FALSE;
			}
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER) {
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}
		// QCC ---------------------------------------
		else if (self.weapon == IT_LIGHTNING) {
			self.weapon = QCC_IT_RAILGUN;
			if (self.ammo_slugs < 1)
				am = 1;
		}
		else if (self.weapon == QCC_IT_RAILGUN) {
			self.weapon = IT_LASER_CANNON;
			if (self.ammo_cells < 1)
				am = 1;
		}
		// -------------------------------------------
	
		if ((self.items & self.weapon) && am == 0) {
			W_SetCurrentAmmo();
			return;
		}
	}
};

// Go to the prev weapon with ammo
void() CycleWeaponReverseCommand = {
	float it, am;

	it = self.items;
	self.impulse = 0;

	while (1) {
		am = 0;

		// QCC -----------------------------------
		if (self.weapon == IT_LASER_CANNON) {
			self.weapon = QCC_IT_RAILGUN;
			if (self.ammo_slugs < 1)
				am = 1;
		}
		else if (self.weapon == QCC_IT_RAILGUN) {
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}
		// ---------------------------------------
		else if (self.weapon == IT_LIGHTNING) {
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}	
		else if (self.weapon == IT_ROCKET_LAUNCHER) {
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.qccItems3 & IT_PROXIMITY_GUN)
				self.qccAltWeapon = TRUE;
			else
				self.qccAltWeapon = FALSE;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER) {
			if (self.qccAltWeapon) { // currently prox gun
				self.qccAltWeapon = FALSE;
				if (self.ammo_rockets < 1)
					am = 1;
			}
			else {
				self.weapon = IT_SUPER_NAILGUN;
				if (self.ammo_nails < 2)
					am = 1;
			}
		}
		else if (self.weapon == IT_SUPER_NAILGUN) {
			self.weapon = IT_NAILGUN;

			if (self.ammo_nails < 1)
			am = 1;
		}
		else if (self.weapon == IT_NAILGUN) {
			self.weapon = IT_SUPER_SHOTGUN;

			if (self.ammo_shells < 2)
			am = 1;
		}
		else if (self.weapon == IT_SUPER_SHOTGUN) {
			self.weapon = IT_SHOTGUN;

			if (self.ammo_shells < 1)
			am = 1;
		}
		else if (self.weapon == IT_SHOTGUN) {
			self.weapon = IT_AXE;
		}
		// HIP: MED -----------------------------------------------
		else if (self.weapon == IT_AXE || self.weapon == IT_MJOLNIR) {
			self.weapon = IT_LASER_CANNON;
			if (self.ammo_cells < 1)
				am = 1;
		}
		// --------------------------------------------------------

		if ((it & self.weapon) && am == 0) {
			W_SetCurrentAmmo();
			return;
		}
	}
};

void() ImpulseCommands;

// Called every frame so impulse events can be handled as well as possible
void() W_WeaponFrame = {
	if (time < self.attack_finished) {
		if (self.impulse == QCC_IM_ABILITY || self.impulse == QCC_IM_INTERACT)
			self.impulse = 0;
		return;
	}

	if (self.impulse)
		ImpulseCommands();
	
	// check for attack
	if (self.button0) {
		SuperDamageSound();
		self.qccAttackFunc();
	}
};

/*
================
QCC_SpawnWeapons

Used to spawn in QCC specific weapons, like the railgun, into maps without editing them
================
*/
void(vector o) QCC_SpawnRailgun;

void() QCC_SpawnWeapons = {
    string m;
    m = world.model;
    if (m == "maps/dm3.bsp")
        QCC_SpawnRailgun('-600 240 -40');
    else if (m == "maps/dm5.bsp")
       QCC_SpawnRailgun('-96 -768 192');
    else if (m == "maps/dm7.bsp")
        QCC_SpawnRailgun('640 -672 320');
    return;
}
