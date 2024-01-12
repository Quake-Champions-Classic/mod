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

/*
==============================================================================

SCOURGE

==============================================================================
*/

$cd hipwork\models\scourge
$origin 0 0 23
$base scorbase

$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6
$frame stand7 stand8 stand9 stand10 stand11 stand12

$frame walk1 walk2 walk3 walk4 walk5 walk6

$frame shoot1 shoot2

$frame sting1 sting2 sting3 sting4 sting5 sting6
$frame sting7 sting8 sting9 sting10 sting11

$frame pain1 pain2 pain3 pain4 pain5

$frame death1 death2 death3 death4 death5
/*
===========
ScourgeCheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============
*/
float() ScourgeCheckAttack =
{
	vector	spot1, spot2;
	entity	targ;
	float		chance;

   targ = self.enemy;
   // see if any entities are in the way of the shot
   spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

   if (vlen(spot1 - spot2) <= 100) {
      if (CanDamage (self.enemy, self)) {
         self.attack_state = AS_MELEE;
         return TRUE;
      }
   }

   if (time < self.attack_finished)
		return FALSE;

   if (!enemy_visible)
		return FALSE;


   chance = spot2_z - spot1_z;
   if (chance > 64)
      return FALSE;
   else if (chance < -200)
      return FALSE;

   if (vlen(spot1 - spot2) > 1000)
		return FALSE;
   if (vlen(spot1 - spot2) < 150)
		return FALSE;

	traceline(spot1, spot2, FALSE, self);
   if (trace_inopen && trace_inwater)
		return FALSE;  // sight line crossed contents

   if (trace_ent != targ)
		return FALSE;	// don't have a clear shot

   self.attack_state = AS_MISSILE;
	SUB_AttackFinished (2 + 2*random());
	return TRUE;
};

void(float ox) SCOURGE_FireSpikes =
{
   vector   src, vec;

   ai_face();
   makevectors(self.angles);
   src = self.origin - '0 0 19' + v_right*ox + v_forward*14;
   vec = (self.enemy.origin + (200*v_forward)) - src;
   vec = normalize(vec);
   sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
   launch_spike (src, vec);

   self.attack_finished = time + 0.2;
};

// Attack_With_Tail
//
void() Attack_With_Tail =
{
   float ldmg;
   vector   delta;

   ai_face ();

   delta = self.enemy.origin - self.origin;

   if (vlen(delta) > 100)
		return;
	if (!CanDamage (self.enemy, self))
		return;

	ldmg = (random() + random() + random()) * 40;
	T_Damage(self.enemy, self, self, ldmg);
   sound(self, CHAN_WEAPON, "shambler/smack.wav", 1, ATTN_NORM);

   SpawnMeatSpray (self.origin + v_forward*16, crandom() * 50 * v_right);
};

void() ScourgeTriggerThink;
void() ScourgeTriggerTouch;
void() scourge_think =
{
   entity trig;
   if (!self.state)
   {
      trig = spawn();
      trig.angles = '0 0 0';
      trig.solid = SOLID_TRIGGER;
      setsize(trig, '-64 -64 -24', '64 64 64');
      trig.takedamage = DAMAGE_NO;
      trig.movetype = MOVETYPE_NONE;
      trig.modelindex = 0;
      trig.model = "";
      trig.lastvictim = self;
      trig.think = ScourgeTriggerThink;
      trig.touch = ScourgeTriggerTouch;
      trig.nextthink = time + 0.1 + random();
      setorigin(trig,self.origin);
      self.lastvictim = trig;
      self.state = 1;
   }

   if ((self.spawnsilent == 0) && (self.spawnmulti == 1))
      sound(self, CHAN_BODY, "misc/null.wav", 1, ATTN_IDLE);
   else if ((self.spawnsilent == 1) && (self.spawnmulti == 0))
      sound(self, CHAN_BODY, "scourge/walk.wav", 1, ATTN_IDLE);
   self.spawnmulti = self.spawnsilent;
};

void(float dist) ai_right =
{
   walkmove ((self.angles_y+90), dist);
};

void(float dist) ai_left =
{
   walkmove ((self.angles_y+270), dist);
};

//============================================================================

void() scourge_stand1 = [ $stand1, scourge_stand2 ] {
   self.walkframe = $stand1;
   self.spawnsilent = 0;
   ai_stand();
   scourge_think();
};

void() scourge_stand2 = [ $stand2, scourge_stand2 ] {
   self.walkframe += 1;
   if (self.walkframe > $stand12)
   {
      scourge_stand1();
      return;
   }
   self.frame = self.walkframe;
   self.spawnsilent = 0;
   ai_stand();
   scourge_think();
};

void() scourge_walk1 = [ $walk1, scourge_walk2 ] {
   if (random() < 0.1)
      sound(self, CHAN_VOICE, "scourge/idle.wav", 1, ATTN_IDLE);
   self.spawnsilent = 1;
   scourge_think();
   ai_walk(8);
};
void() scourge_walk2 = [ $walk2, scourge_walk3 ] {ai_walk(8);};
void() scourge_walk3 = [ $walk3, scourge_walk4 ] {ai_walk(8);};
void() scourge_walk4 = [ $walk4, scourge_walk5 ] {ai_walk(8);};
void() scourge_walk5 = [ $walk5, scourge_walk6 ] {ai_walk(8);};
void() scourge_walk6 = [ $walk6, scourge_walk1 ] {ai_walk(8);};

void() scourge_run1 = [ $walk1, scourge_run2 ] {
   if (random() < 0.1)
      sound(self, CHAN_VOICE, "scourge/idle.wav", 1, ATTN_IDLE);
   self.spawnsilent = 1;
   scourge_think();
   if (self.attack_state == AS_STRAIGHT) //Ry: Resume using dodging state [10-21-2022]
      self.attack_state = AS_DODGING;
   ai_run(18);
};
void() scourge_run2 = [ $walk2, scourge_run3 ] {scourge_think();ai_run(14);};
void() scourge_run3 = [ $walk3, scourge_run4 ] {ai_run(14);};
void() scourge_run4 = [ $walk4, scourge_run5 ] {ai_run(14);};
void() scourge_run5 = [ $walk5, scourge_run6 ] {ai_run(14);};
void() scourge_run6 = [ $walk6, scourge_run1 ] {ai_run(14);};

void() scourge_strafeleft1 = [ $walk1, scourge_strafeleft2 ] {self.spawnsilent = 1;scourge_think();ai_left(20);};
void() scourge_strafeleft2 = [ $walk2, scourge_strafeleft3 ] {ai_left(20);};
void() scourge_strafeleft3 = [ $walk3, scourge_strafeleft4 ] {ai_left(20);};
void() scourge_strafeleft4 = [ $walk4, scourge_strafeleft5 ] {ai_left(14);};
void() scourge_strafeleft5 = [ $walk5, scourge_strafeleft6 ] {ai_left(14);};
void() scourge_strafeleft6 = [ $walk6, scourge_run1 ] {ai_left(14);};

void() scourge_straferight1 = [ $walk1, scourge_straferight2 ] {self.spawnsilent = 1;scourge_think();ai_right(20);};
void() scourge_straferight2 = [ $walk2, scourge_straferight3 ] {ai_right(20);};
void() scourge_straferight3 = [ $walk3, scourge_straferight4 ] {ai_right(20);};
void() scourge_straferight4 = [ $walk4, scourge_straferight5 ] {ai_right(14);};
void() scourge_straferight5 = [ $walk5, scourge_straferight6 ] {ai_right(14);};
void() scourge_straferight6 = [ $walk6, scourge_run1 ] {ai_right(14);};

void() scourge_turn1 = [ $walk1, scourge_turn2 ] {self.spawnsilent = 1;scourge_think();ai_turn_in_place();};
void() scourge_turn2 = [ $walk2, scourge_turn3 ] {ai_turn_in_place();};
void() scourge_turn3 = [ $walk3, scourge_turn4 ] {ai_turn_in_place();};
void() scourge_turn4 = [ $walk4, scourge_turn5 ] {ai_turn_in_place();};
void() scourge_turn5 = [ $walk5, scourge_turn6 ] {ai_turn_in_place();};
void() scourge_turn6 = [ $walk6, scourge_turn1 ] {ai_turn_in_place();};

void() scourge_atk1 = [ $shoot1,   scourge_atk2 ]
{
   self.walkframe = 1;
   self.spawnsilent = 0;
   scourge_think();
   self.effects = self.effects | EF_MUZZLEFLASH;
   SCOURGE_FireSpikes(40);
};

void() scourge_atk2 = [ $shoot2, scourge_atk2 ] {
   self.walkframe += 1;
   if (self.walkframe > 8)
   {
      scourge_run1();
      return;
   }
   self.effects = self.effects | EF_MUZZLEFLASH;
   if (self.walkframe % 2)
   {
      self.frame = $shoot1;
      SCOURGE_FireSpikes(40);
   }
   else
      SCOURGE_FireSpikes(-56);
   if (self.walkframe == 8)
      SUB_AttackFinished (4*random());
};

void() scourge_melee1 = [ $sting1, scourge_melee2 ] {self.spawnsilent = 0;scourge_think();ai_charge(3);};
void() scourge_melee2 = [ $sting2, scourge_melee3 ] {ai_charge(3);};
void() scourge_melee3 = [ $sting3, scourge_melee4 ] {ai_charge(2);};
void() scourge_melee4 = [ $sting4, scourge_melee5 ] {ai_charge(2);};
void() scourge_melee5 = [ $sting5, scourge_melee6 ] {
   sound(self, CHAN_WEAPON, "scourge/tailswng.wav", 1, ATTN_NORM);
   ai_charge(3);
};
void() scourge_melee6 = [ $sting6, scourge_melee7 ] {ai_charge(1);};
void() scourge_melee7 = [ $sting7, scourge_melee8 ] {Attack_With_Tail();};
void() scourge_melee8 = [ $sting8, scourge_melee9 ] {ai_face();};
void() scourge_melee9 = [ $sting9, scourge_melee10 ] {ai_face();};
void() scourge_melee10 = [ $sting10, scourge_melee11 ] {ai_face();};
void() scourge_melee11 = [ $sting11, scourge_run1 ] {ai_face();SUB_CheckRefire(scourge_melee1);};

void() scourge_pain1 = [ $pain1, scourge_pain2 ] {self.spawnsilent = 0;scourge_think();};
void() scourge_pain2 = [ $pain2, scourge_pain3 ] {};
void() scourge_pain3 = [ $pain3, scourge_pain4 ] {};
void() scourge_pain4 = [ $pain4, scourge_pain5 ] {};
void() scourge_pain5 = [ $pain5, scourge_run1 ] {};

void(entity attacker, float damage) scourge_pain =
{
	float r;

   if (random() * 50 > damage)
		return; // didn't flinch

   if (self.pain_finished > time)
		return;

   r = random ();
   sound(self, CHAN_VOICE, "scourge/pain.wav", 1, ATTN_NORM);

   self.pain_finished = time + 2.0;
   scourge_pain1 ();
};

void() scourge_die1 = [ $death1, scourge_die2 ] {self.spawnsilent = 0;scourge_think();};
void() scourge_die2 = [ $death2, scourge_die3 ] {};
void() scourge_die3 = [ $death3, scourge_die4 ] {self.solid = SOLID_NOT;};
void() scourge_die4 = [ $death4, scourge_die5 ] {};
void() scourge_die5 = [ $death5, scourge_die5 ] {};

void() scourge_die =
{
   // stop sound
   if (self.lastvictim != world)
      remove(self.lastvictim);
   self.spawnsilent = 0;
   scourge_think();

   // check for gib
   if (self.health < -35)
   {
		sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
      ThrowHead ("progs/h_scourg.mdl", self.health);
      ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
      return;
   }
   // regular death
   sound(self, CHAN_VOICE, "scourge/pain2.wav", 1, ATTN_NORM);
   scourge_die1 ();
};

//
// scourge_melee
//
void() scourge_melee =
{
   scourge_melee1();
   SUB_AttackFinished (2*random());
};

//
// ScourgeTriggerThink
//
void() ScourgeTriggerThink =
{
   entity targ;

   if (self.lastvictim.health<=0) {
      remove(self);
      return;
   }

   targ = self.lastvictim;
   makevectors(targ.angles);
   setorigin(self, targ.origin + (v_forward*300));
   self.nextthink = time + 0.1;
};

//
// ScourgeTriggerTouch
//
void() ScourgeTriggerTouch =
{
   entity targ;
   entity tempent;
   vector dir;

   if (other.flags & (FL_MONSTER|FL_CLIENT))
      return;
   
   if (other.movetype != MOVETYPE_FLYMISSILE)
      return;
   
   targ = self.lastvictim;
   if (targ.health<=0) {
      remove(self);
      return;
   }

   dir = targ.origin - other.origin;
   dir = normalize(dir);
   if ((dir * normalize(other.velocity))<0.8)
      return;

   if (time > self.duration)
   {
      tempent = self;
      self = targ;
      if (random()<0.5)
         scourge_strafeleft1();
      else
         scourge_straferight1();
      self.duration = time + 1.5;
   }
   self = tempent;
};

/*QUAKED monster_scourge (1 0 0) (-16 -16 -24) (16 16 40) Ambush

*/
void() monster_scourge =
{
   precache_model2("progs/scor.mdl");
   precache_model2("progs/h_scourg.mdl");
	precache_model2("progs/laser.mdl");
   precache_model2("progs/s_light.mdl");
   precache_model2("progs/spike.mdl");

   precache_sound("misc/null.wav");
   precache_sound("scourge/idle.wav");
   precache_sound("scourge/pain.wav");
   precache_sound("scourge/pain2.wav");
   precache_sound("scourge/sight.wav");
   precache_sound("scourge/tailswng.wav");
   precache_sound("scourge/walk.wav");
   precache_sound2("shambler/smack.wav");
   precache_sound2("weapons/rocket1i.wav");

   self.noise = "scourge/sight.wav";
   if (ExtSupported("EX_SPRINT"))
      self.killstring = "$qc_ks_centroid";
   else
      self.killstring = " was stung by a Centroid\n";
   self.netname = "Centroid";

   self.health = 300;
   self.max_health = self.health;

   self.th_stand = scourge_stand1;
   self.th_walk = scourge_walk1;
   self.th_run = scourge_run1;
   self.th_pain = scourge_pain;
   self.th_die = scourge_die;
   self.th_melee = scourge_melee;
   self.th_missile = scourge_atk1;
   self.yaw_speed = 60;
   self.attack_state = AS_DODGING;
   self.allowPathFind = TRUE;
	self.combat_style = CS_MIXED;

   InitMonster("progs/scor.mdl", MONSTER_TYPE_WALK, MONSTER_SIZE_LARGE);
};
