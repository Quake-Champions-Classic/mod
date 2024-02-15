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

Gremlin

==============================================================================
*/
$cd hipwork\models\grem
$origin 0 0 23
$scale 2
$base grembase

$skin grem

$frame stand1 stand2 stand3 stand4 stand5 stand6
$frame stand7 stand8 stand9 stand10 stand11 stand12
$frame stand13 stand14 stand15 stand16 stand17

$frame walk1 walk2 walk3 walk4 walk5 walk6
$frame walk7 walk8 walk9 walk10 walk11 walk12

$frame run1 run2 run3 run4 run5 run6 run7 run8
$frame run9 run10 run11 run12 run13 run14 run15

$frame jump1 jump2 jump3 jump4 jump5 jump6 jump7
$frame jump8 jump9 jump10 jump11 jump12 jump13 jump14
$frame jump15 jump16

$frame attk1 attk2 attk3 attk4 attk5 attk6
$frame attk7 attk8 attk9 attk10 attk11

$frame maul1 maul2 maul3 maul4 maul5 maul6
$frame maul7 maul8 maul9 maul10 maul11 maul12 maul13

$frame spawn1 spawn2 spawn3 spawn4 spawn5 spawn6

$frame look1 look2 look3 look4 look5 look6 look7
$frame look8 look9 look10

$frame pain1 pain2 pain3 pain4

$frame death1 death2 death3 death4 death5 death6 death7
$frame death8 death9 death10 death11 death12

$frame flip1 flip2 flip3 flip4 flip5 flip6 flip7
$frame flip8

$frame lunge1 lunge2 lunge3 lunge4 lunge5 lunge6 lunge7
$frame lunge8 lunge9 lunge10 lunge11

$frame gfire1 gfire2 gfire3 gfire4 gfire5 gfire6

$frame glook1 glook2 glook3 glook4 glook5 glook6 glook7
$frame glook8 glook9 glook10 glook11 glook12 glook13 
$frame glook14 glook15 glook16 glook17 glook18 glook19 glook20

$frame gpain1 gpain2 gpain3

$frame grun1 grun2 grun3 grun4 grun5 grun6 grun7
$frame grun8 grun9 grun10 grun11 grun12 grun13 grun14 grun15

//============================================================================

float NumGremlins;
float NumSpawnGremlins;

/*
===========
GremlinAttemptWeaponSteal

see if we can steal enemy's weapon
============
*/
entity()GremlinFindVictim;
float() GremlinFindTarget;

float() GremlinAttemptWeaponSteal = {
   vector delta;
   entity tempself, victim;
   float best, amount;

   if (self.stoleweapon) {
      dprint("gremlin trying to steal a weapon again\n");
      return FALSE;
   }
   if (!(self.enemy.flags & FL_CLIENT)) {
      return FALSE;
   }

   delta = (self.enemy.origin - self.origin);

   if (vlen(delta) > 100)
      return FALSE;
   if (random() < 0.5)
      return FALSE;
   
   // we are within range so lets go for it
   victim = self.enemy;
   best = victim.weapon;
   if (best == IT_AXE || best == IT_SHOTGUN || best == QCC_ABILITY || best == IT_MJOLNIR) // QCC: Don't let Gremlins take abilities lmao
      return FALSE;
   
   // take that weapon from the entity
   if (victim.qccAltWeapon) // QCC: prox gun isn't in normal items list
      victim.qccItems3 = victim.qccItems3 - (victim.qccItems3 & best);
   else
      victim.items = victim.items - (victim.items & best);

   // give it to our gremlin
   self.items = self.items | best;
   self.weapon = best;
   self.qccAltWeapon = victim.qccAltWeapon;
   self.combat_style = CS_RANGED;

   // take some ammo while we are at it
   self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
   if (best == IT_SUPER_SHOTGUN) {
      amount = victim.ammo_shells;
      if (amount > 20)
         amount = 20;
      victim.ammo_shells = victim.ammo_shells - amount;
      self.ammo_shells = self.ammo_shells + amount;
		self.items = self.items | IT_SHELLS;
      self.currentammo = self.ammo_shells;
      if (ExtSupported("EX_SPRINT"))
         sprint(victim, "$qc_gremlin_ssg");
      else
         sprint(victim, "Gremlin stole your Super Shotgun\n");
   }
   else if (best == IT_NAILGUN) {
      amount = victim.ammo_nails;
      if (amount > 40)
         amount = 40;
      victim.ammo_nails = victim.ammo_nails - amount;
      self.ammo_nails = self.ammo_nails + amount;
      self.items = self.items | IT_NAILS;
      self.currentammo = self.ammo_nails;
      if (ExtSupported("EX_SPRINT"))
         sprint(victim, "$qc_gremlin_ng");
      else
         sprint(victim, "Gremlin stole your Nailgun\n");
   }
   else if (best == IT_SUPER_NAILGUN) {
      amount = victim.ammo_nails;
      if (amount > 40)
         amount = 40;
      victim.ammo_nails = victim.ammo_nails - amount;
      self.ammo_nails = self.ammo_nails + amount;
      self.items = self.items | IT_NAILS;
      self.currentammo = self.ammo_nails;
      if (ExtSupported("EX_SPRINT"))
         sprint(victim, "$qc_gremlin_sng");
      else
         sprint(victim, "Gremlin stole your Super Nailgun\n");
   }
   else if (best == IT_GRENADE_LAUNCHER) { // || IT_PROXIMITY_GUN
      amount = victim.ammo_rockets;
      if (amount > 5)
         amount = 5;
      victim.ammo_rockets = victim.ammo_rockets - amount;
      self.ammo_rockets = self.ammo_rockets + amount;
      self.items = self.items | IT_ROCKETS;
      self.currentammo = self.ammo_rockets;
      if (self.qccAltWeapon) {
         if (ExtSupported("EX_SPRINT"))
            sprint(victim, "$qc_gremlin_prox");
         else
            sprint(victim, "Gremlin stole your Proximity Gun\n");
      }
      else {
         if (ExtSupported("EX_SPRINT"))
            sprint(victim, "$qc_gremlin_gl");
         else
            sprint(victim, "Gremlin stole your Grenade Launcher\n");
      }
   }
   else if (best == IT_ROCKET_LAUNCHER) {
      amount = victim.ammo_rockets;
      if (amount > 5)
         amount = 5;
      victim.ammo_rockets = victim.ammo_rockets - amount;
      self.ammo_rockets = self.ammo_rockets + amount;
      self.items = self.items | IT_ROCKETS;
      self.currentammo = self.ammo_rockets;
      if (ExtSupported("EX_SPRINT"))
         sprint(victim, "$qc_gremlin_rl");
      else
         sprint(victim, "Gremlin stole your Rocket Launcher\n");
   }
   else if (best == IT_LIGHTNING) {
      amount = victim.ammo_cells;
      if (amount > 40)
         amount = 40;
      victim.ammo_cells = victim.ammo_cells - amount;
      self.ammo_cells = self.ammo_cells + amount;
      self.items = self.items | IT_CELLS;
      self.currentammo = self.ammo_cells;
      if (ExtSupported("EX_SPRINT"))
         sprint(victim, "$qc_gremlin_lg");
      else
         sprint(victim, "Gremlin stole your Lightning Gun\n");
   }
   // QCC: allow gremlin to take railgun ---------
   else if (best == QCC_IT_RAILGUN) {
      amount = victim.ammo_cells;
      if (amount > 40)
         amount = 40;
      victim.ammo_cells = victim.ammo_cells - amount;
      self.ammo_cells = self.ammo_cells + amount;
      self.items = self.items | IT_CELLS;
      self.currentammo = self.ammo_cells;
      if (ExtSupported("EX_SPRINT"))
         sprint(victim, "$qc_gremlin_lg");
      else
         sprint(victim, "Gremlin stole your Railgun\n");
   }
   // --------------------------------------------
   else if (best == IT_LASER_CANNON) {
      amount = victim.ammo_cells;
      if (amount > 40)
         amount = 40;
      victim.ammo_cells = victim.ammo_cells - amount;
      self.ammo_cells = self.ammo_cells + amount;
      self.items = self.items | IT_CELLS;
      self.currentammo = self.ammo_cells;
      if (ExtSupported("EX_SPRINT"))
         sprint(victim, "$qc_gremlin_lc");
      else
         sprint(victim, "Gremlin stole your Laser Cannon\n");
   }

   tempself = self;
   self = victim;
   self.weapon = W_BestWeapon ();
   W_SetCurrentAmmo ();
   self = tempself;

   // tag the gremlin as having stolen a weapon
   self.stoleweapon = TRUE;
   self.attack_finished = time;

   // don't fire the first shot at the person we stole the weapon from all the time
   if (random()>0.65)
      self.lastvictim = victim;
   else
      self.lastvictim = self;
   
   // find a recipient
   victim = GremlinFindVictim();
   if (victim != world) {
      self.enemy = victim;
      FoundTarget();
      self.attack_finished = time;
      self.search_time = time + 1.0;
   }

   return TRUE;
};

/*
===========
GremlinFindTarget

gremlin is currently not attacking anything, so try to find a target
============
*/
float() GremlinFindTarget = {
   entity   head, gorge;
   float    dist, result;

   if (self.stoleweapon == FALSE && time > self.wait) {
      self.wait = time + 1.0;
      dist = 2000;
      gorge = world;
      head = nextent(world);
      while (head != world) {
         if ((head.health < 1) && (head.flags & (FL_MONSTER|FL_CLIENT))) {
            result = fabs(head.origin_z - self.origin_z);
            if ((visible(head)) && (result<80) && (head.gorging == FALSE) && (visible_distance<dist))
            {
               dist = visible_distance;
               gorge = head;
            }
         }
         head = nextent(head);
      }
      if ((gorge != world) && (dist < (700*random()))) {
         self.oldenemy = self.enemy;
         self.gorging = TRUE;
         self.enemy = gorge;
         self.search_time = time + 4.0;
         FoundTarget();
         return TRUE;
      }
   }
   else if (self.stoleweapon) {
      head = GremlinFindVictim();
      if (head != world) {
         self.enemy = head;
         FoundTarget();
         self.attack_finished = time;
         self.search_time = time + 2.0;
         return TRUE;
      }
   }
   result = FindTarget();
   self.search_time = time + 2.0;
   return result;
};

/*
=============
gremlin_walk

The monster is walking it's beat
=============
*/
void(float dist) gremlin_walk = {
	movedist = dist;
   if (GremlinFindTarget ())
		return;
	movetogoal (dist);
};

//============================================================================

float() GremlinCheckNoAmmo;
void() gremlin_glook1;

void(float side) Gremlin_Melee;
void(float side) Gremlin_Gorge;

/*
=============
gremlin_stand

The monster is staying in one place for a while, with slight angle turns
=============
*/
void() gremlin_stand = {
   if (FindTarget ())
		return;

	if (time > self.pausetime) {
		self.th_walk ();
		return;
   }
};

void() gremlin_stand1 = [ $stand1, gremlin_stand2 ] { self.walkframe = $stand1; gremlin_stand(); };

void() gremlin_stand2 = [ $stand1, gremlin_stand2 ] {
   self.walkframe += 1;
   if (self.walkframe > $stand17)
   {
      gremlin_stand1();
      return;
   }
   self.frame = self.walkframe;
   gremlin_stand();
};


// =============
// gremlin_walk
// =============
void() gremlin_walk1 =[ $walk1, gremlin_walk2 ] {
   if (random() < 0.1)
      sound(self, CHAN_VOICE, "grem/idle.wav", 1, ATTN_IDLE);
   self.walkframe = $walk1;
   gremlin_walk(8);
};

void() gremlin_walk2 = [ $walk1, gremlin_walk2 ] {
   self.walkframe += 1;
   if (self.walkframe > $walk12)
   {
      gremlin_walk1();
      return;
   }
   self.frame = self.walkframe;
   gremlin_walk(8);
};


/*
=============
gremlin_run

The monster has an enemy it is trying to kill
=============
*/
void(float dist) gremlin_run = {
   float r;
   vector d;

   if (self.watertype == CONTENT_LAVA){
      T_Damage(self, world, world, 2000);
      return; // QCC: don't need to go further than this
   }
   
   movedist = dist;

   if (self.gorging) {
      traceline(self.origin, self.enemy.origin, TRUE, self);
      if (trace_fraction != 1.0) {
         self.gorging = FALSE;
         return;
      }
      if (!visible(self.enemy)) {
         self.gorging = FALSE;
         return;
      }
      r = vlen(self.enemy.origin - self.origin);
      if (r < 130) {
         ai_face();
         if (r < 45) {
            self.th_melee ();
            self.attack_state = AS_STRAIGHT;
         }
         else if (walkmove (self.angles_y, dist) == FALSE) {
            self.gorging = FALSE;
         }
         return;
      }
      movetogoal (dist);      // done in C code...
   }   
   else {
      if (random()>0.97) {
         if (GremlinFindTarget())
            return;
      }

      // get away from player if we stole a weapon
      if (self.stoleweapon == TRUE) {
         if (self.enemy.health < 0 && self.enemy.classname == "player") {
            gremlin_glook1();
            return;
         }

         if (!GremlinCheckNoAmmo()) {
            if (self.t_length == 1) {
               remove(self.trigger_field);
               self.goalentity = self.enemy;
               self.t_length = 0;
            }
            return;
         }

         r = vlen(self.enemy.origin - self.origin);
         d = normalize(self.origin-self.enemy.origin);
         if (self.t_length == 0) {
            if (r<150) {
               self.trigger_field = spawn();
               setsize(self.trigger_field,'-1 -1 -1','1 1 1');
               self.t_length = 1;
            }
         }

         if (self.t_length == 1) {
            if (r > 250) {
               remove(self.trigger_field);
               self.goalentity = self.enemy;
               self.t_length = 0;
            }
            else {
               if (r < 160) {
                  vector ang;
                  float done;
                  vector end;
                  float c;

                  ang = vectoangles(d);
                  done = 0;
                  c = 0;
                  while (done == 0) {
                     makevectors(ang);
                     end = self.enemy.origin + v_forward * 350;
                     traceline(self.enemy.origin,end,FALSE,self);
                     if (trace_fraction == 1.0) {
                        traceline(self.origin,end,FALSE,self);
                        if (trace_fraction == 1.0)
                           done = 1;
                     }
                     ang_y = anglemod(ang_y + 36);
                     c = c + 1;
                     if (c == 10) {
                        done = 1;
                     }
                  }
                  setorigin(self.trigger_field,end);
               }
               self.goalentity = self.trigger_field;
               self.ideal_yaw = vectoyaw(normalize(self.goalentity.origin-self.origin));
               ChangeYaw ();
               movetogoal (dist);      // done in C code...
               self.nextthink = time + 0.1;
               return;
            }
         }
      }
      ai_run(dist);
      self.nextthink = time + 0.1;
   }
};

void() gremlin_run1 = [ $run1, gremlin_run2 ] {
   if (self.stoleweapon)
      self.frame += $grun1 - $run1;
   self.walkframe = $run1;
   if (random() < 0.1)
      sound(self, CHAN_VOICE, "grem/idle.wav", 1, ATTN_IDLE);
   gremlin_run(4);
};

void() gremlin_run2 = [ $run1, gremlin_run2 ] {
   self.walkframe += 1;
   if (self.walkframe > $run15) {
      gremlin_run1();
      return;
   }
   if (self.stoleweapon)
      self.frame = self.walkframe + $grun1 - $run1;
   else
      self.frame = self.walkframe;
   
   if (self.walkframe == $run8 || self.walkframe == $run15)
      gremlin_run(4);
   if (self.walkframe == $run2 || self.walkframe == $run7 || self.walkframe == $run9 || self.walkframe == $run14)
      gremlin_run(8);
   if (self.walkframe == $run3 || self.walkframe == $run6 || self.walkframe == $run10 || self.walkframe == $run13)
      gremlin_run(12);
   else
      gremlin_run(16);
};

// =============
// gremlin_jump
// =============
void() Gremlin_JumpTouch;
void() gremlin_jump1 = [ $jump1, gremlin_jump2 ] { self.walkframe = $jump1; ai_face(); };
void() gremlin_jump2 = [ $jump1, gremlin_jump2] {
   self.walkframe += 1;
   if (self.walkframe < $jump6)
      ai_face();
   
   if (self.walkframe == $jump5) {
      if (self.flags & FL_ONGROUND) {
         self.touch = Gremlin_JumpTouch;
         makevectors(self.angles);
         self.origin_z = self.origin_z + 1;
         self.velocity = v_forward * 300 + '0 0 300';
         self.flags = self.flags - FL_ONGROUND;
      }
      else
         gremlin_run1();
   }
   else if (self.walkframe > $jump11) {
      // if three seconds pass, assume gremlin is stuck and jump again
      self.think = gremlin_jump1;
      self.nextthink = time + 3;
   }
};

void() gremlin_jump12 = [ $jump12, gremlin_jump13 ] {self.walkframe = $jump12;};
void() gremlin_jump13 = [ $jump12, gremlin_jump13 ] {
   self.walkframe +=1;
   if (self.walkframe > $jump16) {
      gremlin_run1();
      return;
   }
   self.frame = self.walkframe;
};

void() Gremlin_JumpTouch = {
   if (self.health <= 0)
		return;
	if (!checkbottom(self)) {
		if (self.flags & FL_ONGROUND) {
         self.touch = SUB_Null;
         self.think = gremlin_jump1;
         self.nextthink = time + 0.1;
      }
		return;	// not on ground yet
   }

	self.touch = SUB_Null;
   self.think = gremlin_jump12;
	self.nextthink = time + 0.1;
};


// =========
// gremlin_gorge
// =========
void() gremlin_gorge1   =[ $maul1,  gremlin_gorge2] {ai_charge(1);};
void() gremlin_gorge2   =[ $maul2,  gremlin_gorge3] {ai_charge(1);};
void() gremlin_gorge3   =[ $maul3,  gremlin_gorge4] {ai_charge(2);};
void() gremlin_gorge4   =[ $maul4,  gremlin_gorge5] {ai_charge(0);};
void() gremlin_gorge5   =[ $maul5,  gremlin_gorge6] {ai_charge(0);};
void() gremlin_gorge6   =[ $maul6,  gremlin_gorge7] {ai_charge(0);Gremlin_Gorge(200);};
void() gremlin_gorge7   =[ $maul7,  gremlin_gorge8] {ai_charge(0);};
void() gremlin_gorge8   =[ $maul8,  gremlin_gorge9] {ai_charge(0);Gremlin_Gorge(-200);};
void() gremlin_gorge9   =[ $maul9,  gremlin_gorge10] {ai_charge(0);};
void() gremlin_gorge10  =[ $maul10, gremlin_gorge11] {ai_charge(0);};
void() gremlin_gorge11  =[ $maul11, gremlin_gorge12] {ai_charge(0);};
void() gremlin_gorge12  =[ $maul12, gremlin_gorge13] {ai_charge(0);};
void() gremlin_gorge13  =[ $maul13, gremlin_gorge1] {ai_charge(0);};

// ========
// gremlin_look
// ========
void() gremlin_look1 = [ $look1, gremlin_look2 ] {
   self.walkframe = $look1;
   self.nextthink = time + 0.2;
};

void() gremlin_look2 = [ $look2, gremlin_look2 ] {
   self.walkframe += 1;
   if (self.walkframe < $look9)
      self.nextthink = time + 0.2;
   else if (self.walkframe == $look9)
   {
      if (self.oldenemy.health > 0) {
         self.enemy = self.oldenemy;
         HuntTarget ();
      }
      else {
         if (self.movetarget)
            self.th_walk ();
         else
            self.th_stand ();
      }
   }
   else {
      gremlin_run1();
      return;
   }
   self.frame = self.walkframe;
};

void() GremlinDropBackpack;

void() gremlin_glook1 = [ $glook1, gremlin_glook2 ] {self.walkframe = $glook1;};
void() gremlin_glook2 = [ $glook2, gremlin_glook2 ] {
   self.walkframe += 1;
   self.frame = self.walkframe;
   if (self.walkframe == $glook20) {
      GremlinDropBackpack();
      self.stoleweapon = FALSE;
      self.combat_style = CS_MELEE;
      if (self.oldenemy.health > 0) {
         self.enemy = self.oldenemy;
         HuntTarget ();
      }
      else {
         if (self.movetarget)
            self.th_walk ();
         else
            self.th_stand ();
      }
   }
};

// ========
// gremlin_pain
// ========
void() gremlin_pain1 = [ $pain1, gremlin_pain2 ] {ai_back(4);};
void() gremlin_pain2 = [ $pain2, gremlin_pain3 ] {ai_back(4);};
void() gremlin_pain3 = [ $pain3, gremlin_pain4 ] {ai_back(2);};
void() gremlin_pain4 = [ $pain4, gremlin_run1 ] {};

void() gremlin_gunpain1 = [ $gpain1, gremlin_gunpain2 ] {ai_back(4);};
void() gremlin_gunpain2 = [ $gpain2, gremlin_gunpain3 ] {ai_back(2);};
void() gremlin_gunpain3 = [ $gpain3, gremlin_run1 ] {};

void(entity attacker, float damage) gremlin_pain = {
   float r;

   if (random()<0.8) {
      self.gorging = FALSE;
      self.enemy = attacker;
      FoundTarget();
   }

   if (self.touch == Gremlin_JumpTouch)
		return;
   
	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 1;

   r = random();
   if (r<0.33)
      sound(self, CHAN_VOICE, "grem/pain1.wav", 1, ATTN_NORM);
   else if (r<0.66)
      sound(self, CHAN_VOICE, "grem/pain2.wav", 1, ATTN_NORM);
   else
      sound(self, CHAN_VOICE, "grem/pain3.wav", 1, ATTN_NORM);

   if (self.stoleweapon)
      gremlin_gunpain1 ();
   else
      gremlin_pain1 ();
};


// ========
// gremlin_spawn
// ========
void() gremlin_spawn1 =[ $spawn1, gremlin_spawn2 ] { self.nextthink = time + 0.3; self.th_pain = SUB_NullPain;};
void() gremlin_spawn2 =[ $spawn2, gremlin_spawn3 ] { self.nextthink = time + 0.3;};
void() gremlin_spawn3 =[ $spawn3, gremlin_spawn4 ] { self.nextthink = time + 0.3;};
void() gremlin_spawn4 =[ $spawn4, gremlin_spawn5 ] { self.nextthink = time + 0.3;};
void() gremlin_spawn5 =[ $spawn5, gremlin_spawn6 ] { self.nextthink = time + 0.3;};
void() gremlin_spawn6 =[ $spawn6, gremlin_run1 ] { self.th_pain = gremlin_pain;};


// =======
// gremlin_die
// =======
void() gremlin_die1 = [ $death1, gremlin_die2 ] {sound(self, CHAN_VOICE, "grem/death.wav", 1, ATTN_NORM);};
void() gremlin_die2 = [ $death2, gremlin_die3 ] {ai_forward(2);};
void() gremlin_die3 = [ $death3, gremlin_die4 ] {ai_forward(1);};
void() gremlin_die4 = [ $death4, gremlin_die5 ] {ai_forward(2);};
void() gremlin_die5 = [ $death5, gremlin_die6 ] {ai_forward(1);};
void() gremlin_die6 = [ $death6, gremlin_die7 ] {self.solid = SOLID_NOT;};
void() gremlin_die7 = [ $death7, gremlin_die8 ] {ai_forward(2);};
void() gremlin_die8 = [ $death8, gremlin_die9 ] {ai_forward(1);};
void() gremlin_die9 = [ $death9, gremlin_die10 ] {ai_forward(2);};
void() gremlin_die10 = [ $death10, gremlin_die11 ] {ai_forward(1);};
void() gremlin_die11 = [ $death11, gremlin_die12 ] {ai_forward(2);};
void() gremlin_die12 = [ $death12, gremlin_die12 ] {};

void() gremlin_gib = {
   sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
   ThrowHead ("progs/h_grem.mdl", -35);
   ThrowGib ("progs/gib1.mdl", -35);
   ThrowGib ("progs/gib1.mdl", -35);
   ThrowGib ("progs/gib1.mdl", -35);
};

void() Gremlin_FlipTouch;
void() gremlin_flip1 = [ $flip1, gremlin_flip2 ] {
   ai_face();
	makevectors(self.angles);
   self.origin_z = self.origin_z + 1;
   self.velocity = '0 0 350' - (v_forward * 200);
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
   sound(self, CHAN_VOICE, "grem/death.wav", 1, ATTN_NORM);
};
void() gremlin_flip2 = [ $flip2, gremlin_flip3 ] {ai_face();};
void() gremlin_flip3 = [ $flip3, gremlin_flip4 ] {};
void() gremlin_flip4 = [ $flip4, gremlin_flip5 ] {};
void() gremlin_flip5 = [ $flip5, gremlin_flip6 ] {};
void() gremlin_flip6 = [ $flip6, gremlin_flip7 ] {self.touch = Gremlin_FlipTouch;};
void() gremlin_flip7 = [ $flip7, gremlin_gib ] {self.nextthink = time + 3;};
void() gremlin_flip8 = [ $flip8, gremlin_flip8 ] { self.solid = SOLID_NOT; };

void() Gremlin_FlipTouch = {
	if (!checkbottom(self)) {
		if (self.flags & FL_ONGROUND) {
         self.touch = SUB_Null;
         self.think = gremlin_flip1;
         self.nextthink = time + 0.1;
      }
		return;	// not on ground yet
   }
	self.touch = SUB_Null;
   self.think = gremlin_flip8;
	self.nextthink = time + 0.1;
};

/*
===============
GremlinDropBackpack
===============
*/
void() GremlinDropBackpack = {
	entity	item;

	item = spawn();
	item.origin = self.origin - '0 0 24';

   self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
   item.items = self.items;

   if (ExtSupported("EX_SPRINT")) {
		if (item.items == IT_AXE)
			item.netname = "$qc_axe";
		else if (item.items == IT_SHOTGUN)
			item.netname = "$qc_shotgun";
		else if (item.items == IT_SUPER_SHOTGUN)
			item.netname = "$qc_double_shotgun";
		else if (item.items == IT_NAILGUN)
			item.netname = "$qc_nailgun";
		else if (item.items == IT_SUPER_NAILGUN)
			item.netname = "$qc_super_nailgun";
		else if (item.items == IT_GRENADE_LAUNCHER)
			item.netname = "$qc_grenade_launcher";
		else if (item.items == IT_ROCKET_LAUNCHER)
			item.netname = "$qc_rocket_launcher";
		else if (item.items == IT_LIGHTNING)
			item.netname = "$qc_thunderbolt";
		// HIP --------------------------------------
		else if (item.items == IT_LASER_CANNON)
			item.netname = "$qc_laser_cannon";
		else if (item.items == IT_PROXIMITY_GUN)
			item.netname = "$qc_prox_gun";
		else if (item.items == IT_MJOLNIR)
			item.netname = "$qc_mjolnir";
		// QCC --------------------------------------
		else if (item.items == QCC_IT_RAILGUN)
			item.netname = "Railgun";
		// ------------------------------------------
		else
			item.netname = "";
	}
	else {
		if (item.items == IT_AXE)
			item.netname = "Axe";
		else if (item.items == IT_SHOTGUN)
			item.netname = "Shotgun";
		else if (item.items == IT_SUPER_SHOTGUN)
			item.netname = "Double-barrelled Shotgun";
		else if (item.items == IT_NAILGUN)
			item.netname = "Nailgun";
		else if (item.items == IT_SUPER_NAILGUN)
			item.netname = "Super Nailgun";
		else if (item.items == IT_GRENADE_LAUNCHER)
			item.netname = "Grenade Launcher";
		else if (item.items == IT_ROCKET_LAUNCHER)
			item.netname = "Rocket Launcher";
		else if (item.items == IT_LIGHTNING)
			item.netname = "Thunderbolt";
		// HIP --------------------------------------
		else if (item.items == IT_LASER_CANNON)
			item.netname = "Laser Cannon";
		else if (item.items == IT_PROXIMITY_GUN)
			item.netname = "Proximity Gun";
		else if (item.items == IT_MJOLNIR)
			item.netname = "Mjolnir";
		// QCC --------------------------------------
		else if (item.items == QCC_IT_RAILGUN)
			item.netname = "Railgun";
		else
			item.netname = "";
	}

   item.ammo_shells = self.ammo_shells;
	item.ammo_nails = self.ammo_nails;
	item.ammo_rockets = self.ammo_rockets;
	item.ammo_cells = self.ammo_cells;
   if (item.ammo_shells < 0)
      item.ammo_shells = 0;
   if (item.ammo_nails < 0)
      item.ammo_nails = 0;
   if (item.ammo_rockets < 0)
      item.ammo_rockets = 0;
   if (item.ammo_cells < 0)
      item.ammo_cells = 0;

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);

	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel(item, "progs/backpack.mdl");
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = BackpackTouch;

	item.nextthink = time + 120;	// remove after 2 minutes
	item.think = SUB_Remove;
};

// =========
// gremlin_die
// =========
void() gremlin_die = {
   vector   vec;
	float		dot;

   if (self.items & (IT_SUPER_SHOTGUN|IT_NAILGUN|IT_SUPER_NAILGUN|IT_GRENADE_LAUNCHER|IT_ROCKET_LAUNCHER|IT_LIGHTNING|IT_LASER_CANNON|IT_PROXIMITY_GUN|QCC_IT_RAILGUN)) {
      GremlinDropBackpack();
      self.stoleweapon = FALSE;
   }

   makevectors(self.angles);
   vec = normalize(damage_attacker.origin - self.origin);
	dot = vec * v_forward;

   // check for gib
   if (self.health < -35) {
		sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
      ThrowHead ("progs/h_grem.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		return;
   }
   else if (dot > 0.7 && (random() < 0.5) && (self.flags & FL_ONGROUND)) {
      gremlin_flip1();
      return;
   }
   // regular death
   gremlin_die1 ();
};


/*
==================
Gremlin_Melee
==================
*/
void(float side)  Gremlin_Melee = {
	local	float	ldmg;
	vector	delta;

	ai_face ();
	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
	if (!CanDamage (self.enemy, self))
		return;

   sound(self, CHAN_WEAPON, "grem/attack.wav", 1, ATTN_NORM);
	ldmg = 10 + 5*random();
	T_Damage(self.enemy, self, self, ldmg);

	makevectors(self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
};


// gremlin_lunge
void() gremlin_lunge1 = [ $lunge1, gremlin_lunge2 ] {
   self.walkframe = $lunge1;
   ai_charge(0);
};

void() gremlin_lunge2 = [ $lunge2, gremlin_lunge2 ] {
   self.walkframe += 1;
   if (self.walkframe <= $lunge11) {
      if (self.walkframe == $lunge7)
         ai_charge(15);
      else {
         ai_charge(0);
         if (self.walkframe == $lunge8)
            Gremlin_Melee(0);
      }
      self.frame = self.walkframe;
   }
   else
      gremlin_run1();
};


// gremlin_claw
void() gremlin_claw1 = [ $attk1, gremlin_claw2 ] {
   self.walkframe = $attk1;
   ai_charge(0);
};

void() gremlin_claw2 = [ $attk2, gremlin_claw2 ] {
   self.walkframe += 1;
   if (self.walkframe <= $attk11) {
      if (self.walkframe == $lunge7)
         ai_charge(15);
      else {
         ai_charge(0);
         if (self.walkframe == $lunge6)
            Gremlin_Melee(200);
      }
      self.frame = self.walkframe;
   }
   else
      gremlin_run1();
};

void() Gremlin_MeleeAttack = {
   float num;
   if (self.gorging)
      gremlin_gorge1();
   else {
      if (self.stoleweapon)
         objerror("gremlin meleeing with stolen weapon");
      else if ((self.enemy.flags & FL_CLIENT) && random() < 0.4) {
         if (GremlinAttemptWeaponSteal())
            return;
      }
      num = random();
      if (num<0.3)
         gremlin_claw1 ();
      else if (num < 0.6)
         gremlin_lunge1 ();
      else
         gremlin_claw1 ();
   }
};


/*
============
GremlinWeaponAttack

attack with a weapon
============
*/
void() Gremlin_FireShotGun = {
   vector dir;

   self.currentammo = self.ammo_shells = self.ammo_shells - 1;
   self.effects = self.effects | EF_MUZZLEFLASH;

   sound(self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);
   dir = normalize(self.enemy.origin - self.origin);
   self.v_angle = vectoangles(dir);
   makevectors(self.v_angle);
   dir = dir + crandom()* 0.1 *v_right + crandom()* 0.1 *v_up;
   dir = normalize(dir);
   self.v_angle = vectoangles(dir);
   FireBullets (10, dir, '0.04 0.04 0');
};

void() Gremlin_FireSuperShotGun = {
   vector dir;

   self.currentammo = self.ammo_shells = self.ammo_shells - 2;
   self.effects = self.effects | EF_MUZZLEFLASH;

   sound(self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
   dir = normalize(self.enemy.origin - self.origin);
   self.v_angle = vectoangles(dir);
   makevectors(self.v_angle);
   dir = dir + crandom()* 0.3 *v_right + crandom()* 0.3 *v_up;
   dir = normalize(dir);
   self.v_angle = vectoangles(dir);
   FireBullets (30, dir, '0.14 0.08 0');
};

void() Gremlin_FireRailgun = {
    vector org;
    entity t;
    float dist, x;

    self.currentammo = self.ammo_cells = self.ammo_cells - 6;
    sound(self, CHAN_WEAPON, "weapons/railshot.wav", 1, ATTN_NORM);
    self.punchangle_x = -2;

    org = self.origin;
    // beam trace
    traceline(org, org + v_forward * 4096, 1, self);
    dist = vlen(trace_endpos - org);
    x = ceil(dist / 64);
    while (x >= 0) {
        t = spawn();
        t.owner = self;
        t.movetype = MOVETYPE_NONE;
        t.solid = SOLID_NOT;
        t.classname = "railbeam";
        t.angles = vectoangles(aim(self, dist));
        t.nextthink = time + 0.2;
        t.think = SUB_Remove;
        setmodel(t, "progs/s_rail.mdl");
        setsize(t, '0 0 0', '0 0 0');
        setorigin(t, org + v_forward * 64 * x);
        particle(t.origin, '0 0 0', 249, 6);
        x = x - 1;
    }
    particle(trace_endpos, '0 0 0', 249, 30);
    
    // Trace damage
    traceline(org, org + v_forward * 4096, 0, self);
    while (trace_ent.takedamage) {
        SpawnBlood (trace_endpos, v_forward * 90, 90);
        T_Damage(trace_ent, self, self, 90);
        traceline(trace_endpos, org + v_forward * 4096, 0, trace_ent);
    }
}

void() gremlin_shot1 = [$gfire1, gremlin_shot2 ] {
   self.effects = self.effects | EF_MUZZLEFLASH;
   self.walkframe = $gfire1;
};
void() gremlin_shot2 = [$gfire2, gremlin_shot2 ] {
   self.walkframe +=1;
   if (self.walkframe > $gfire6) {
      gremlin_run1();
      return;
   }
   self.frame = self.walkframe;
};

void() Gremlin_FireNailGun = {
   vector dir;

   self.currentammo = self.ammo_nails = self.ammo_nails - 1;
   self.effects = self.effects | EF_MUZZLEFLASH;

   dir = normalize(self.enemy.origin - self.origin);
   self.v_angle = vectoangles(dir);
   makevectors(self.v_angle);
   dir = dir + crandom()* 0.1 * v_right + crandom()* 0.1 *v_up;
   dir = normalize(dir);
   launch_spike (self.origin + '0 0 16', dir);
   if (self.weapon == IT_SUPER_NAILGUN) {
      sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
      newmis.classname = "super_spike";
	   newmis.touch = superspike_touch;
      setmodel(newmis, "progs/s_spike.mdl");
	   setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
      self.punchangle_x = -2;
   }
   else
      sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
};

void() gremlin_nail1 = [ $gfire1, gremlin_nail2 ] {
   self.walkframe = 3;
   self.effects = self.effects | EF_MUZZLEFLASH;
   Gremlin_FireNailGun();
};

void() gremlin_nail2 = [ $gfire1, gremlin_nail2 ] {
   self.walkframe += 1;
   if (self.walkframe < 17) {
      self.effects = self.effects | EF_MUZZLEFLASH;
      Gremlin_FireNailGun();
   }
   else if (self.walkframe > 17)
      gremlin_run1();
};

void() Gremlin_FireLaserGun = {
   vector dir;

   self.currentammo = self.ammo_cells = self.ammo_cells - 1;
   self.effects = self.effects | EF_MUZZLEFLASH;

   sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
   dir = normalize(self.enemy.origin - self.origin);
   self.v_angle = vectoangles(dir);
   makevectors(self.v_angle);
   dir = dir + crandom()* 0.1 * v_right + crandom()* 0.1 *v_up;
   dir = normalize(dir);
   HIP_LaunchLaser(self.origin + '0 0 16', dir, 0);
};

void() gremlin_laser1 = [ $gfire1, gremlin_laser2 ] {
   self.walkframe = 3;
	self.effects = self.effects | EF_MUZZLEFLASH;
   Gremlin_FireLaserGun();
};

void() gremlin_laser2 = [ $gfire1, gremlin_laser2 ] {
   self.walkframe += 1;
   if (self.walkframe < 7) {
      self.effects = self.effects | EF_MUZZLEFLASH;
      Gremlin_FireLaserGun();
   }
   else if (self.walkframe > 7)
      gremlin_run1();
};

void() Gremlin_FireRocket = {
	local	entity missile;
   vector dir;

	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
   self.effects = self.effects | EF_MUZZLEFLASH;

	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";

   // set missile speed
   dir = normalize(self.enemy.origin - self.origin);
   self.v_angle = vectoangles(dir);
   makevectors(self.v_angle);
   dir = dir + crandom()* 0.1 * v_right + crandom()* 0.1 *v_up;
   missile.velocity = normalize(dir);
   missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);

	missile.touch = T_MissileTouch;

   // set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel(missile, "progs/missile.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, self.origin + v_forward*8 + '0 0 16');
};

void() GremlinFireProximityGrenade = {
   entity missile;
   vector dir;

   NumProximityGrenades = NumProximityGrenades + 1;
   self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	sound(self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	missile = spawn();
   missile.owner = self;
   missile.lastvictim = self;
   missile.movetype = MOVETYPE_TOSS;
	missile.solid = SOLID_BBOX;
   missile.classname = "proximity_grenade";
   missile.takedamage = DAMAGE_NO;
   missile.health = 5;
   missile.state = 0;

   // set missile speed
   dir = normalize(self.enemy.origin - self.origin);
   self.v_angle = vectoangles(dir);
   makevectors(self.v_angle);
   dir = dir + crandom()* 0.1 *v_right + crandom()* 0.1 *v_up;
   dir = normalize(dir);
   missile.velocity = dir * 600;
	missile.velocity_z = 200;

   missile.avelocity = '100 600 100';

	missile.angles = vectoangles(missile.velocity);

   missile.touch = ProximityGrenadeTouch;

   // set missile duration
   missile.nextthink = time + 2;
   missile.delay = time + 15 + (10*random());
   missile.think = ProximityBomb;
   missile.th_die = ProximityGrenadeExplode;

   setmodel(missile, "progs/proxbomb.mdl");
   setorigin(missile, self.origin);
   setsize(missile, '-1 -1 -1', '1 1 1');
};

void() gremlin_rocket1 = [ $gfire1, gremlin_rocket2 ] {
   self.effects = self.effects | EF_MUZZLEFLASH;
   self.walkframe = $gfire1;
};

void() gremlin_rocket2 = [ $gfire1, gremlin_rocket2 ] {
   self.walkframe += 1;
   if (self.walkframe > $gfire6)
   {
      gremlin_run1();
      return;
   }
   self.frame = self.walkframe;
};

void() Gremlin_FireLightningGun =
{
	local	vector	org, dir;
   float cells;

   // explode if under water
   if (self.watertype <= CONTENT_WATER) {
		cells = self.ammo_cells;
		self.ammo_cells = 0;
      discharged = 1;
		T_RadiusDamage(self, self, 35*cells, world);
      discharged = 0;
		return;
	}
	ai_face ();
   
   self.effects = self.effects | EF_MUZZLEFLASH;
   self.currentammo = self.ammo_cells = self.ammo_cells - 2;
   org = self.origin + '0 0 16';
	dir = self.enemy.origin + '0 0 16' - org;
	dir = normalize(dir);
   dir = normalize(self.enemy.origin - self.origin);
   self.v_angle = vectoangles(dir);
   makevectors(self.v_angle);
   dir = dir + crandom() * 0.1 * v_right + crandom() * 0.1 * v_up;
   dir = normalize(dir);
	traceline(org, self.origin + dir*600, TRUE, self);

   WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity(MSG_BROADCAST, self);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);

   LightningDamage(org, trace_endpos + (dir * 4), self, 13); // QCC: damage set to match player LG
};

void() gremlin_light1 = [ $gfire1, gremlin_light2 ] {
   self.walkframe = 1;
	self.effects = self.effects | EF_MUZZLEFLASH;
   Gremlin_FireLightningGun();
};

void() gremlin_light2 = [ $gfire1, gremlin_light2 ] {
   self.walkframe += 1;
   if (self.walkframe < 5) {
      self.effects = self.effects | EF_MUZZLEFLASH;
      Gremlin_FireLightningGun();
   }
   else if (self.walkframe > 5)
      gremlin_run1();
};

float() GremlinCheckNoAmmo = {
	if (self.currentammo > 0)
		return TRUE;
   else {
      self.stoleweapon = FALSE;
      return FALSE;
   }
};

entity() GremlinFindVictim = {
   entity head, selected;
   float dist, head_dist;

   self.search_time = time + 1.0;   
   // look in our immediate vicinity
   selected = world;
   dist = 1000;
   head = findradius(self.origin, 1000);
   while (head) {
      if (!(head.flags & FL_NOTARGET) && ((head.flags & FL_MONSTER) || (head.flags & FL_CLIENT))) {
         if (visible(head) && (head.health > 0) && (head !=self)) {
            head_dist = vlen(head.origin-self.origin);
            if (head == self.lastvictim)
               head_dist = head_dist * 2;
            if (head.flags & FL_CLIENT)
               head_dist = head_dist / 1.5;
            if (head.classname == self.classname)
               head_dist = head_dist * 1.5;
            if (head_dist < dist) {
               selected = head;
               dist = head_dist;
            }
         }
      }
      head = head.chain;
   }
   self.lastvictim = selected;
   return selected;
};

float() GremlinWeaponAttack = {
   if (!GremlinCheckNoAmmo ())
      return FALSE;

   self.show_hostile = time + 1; // wake monsters up

   if (self.weapon == IT_SHOTGUN) {
      gremlin_shot1 ();
      Gremlin_FireShotGun();
      SUB_AttackFinished(1);
   }
	else if (self.weapon == IT_SUPER_SHOTGUN) {
      gremlin_shot1 ();
      Gremlin_FireSuperShotGun();
      SUB_AttackFinished(1);
   }
	else if (self.weapon == IT_NAILGUN || self.weapon == IT_SUPER_NAILGUN) {
      gremlin_nail1 ();
      SUB_AttackFinished(1);
   }
	else if (self.weapon == IT_GRENADE_LAUNCHER) { // || IT_PROXIMITY_GUN
      gremlin_rocket1();
      if (self.qccAltWeapon) // Prox Gun
         GremlinFireProximityGrenade();
      else
         OgreFireGrenade();
      self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
      SUB_AttackFinished(1);
   }
	else if (self.weapon == IT_ROCKET_LAUNCHER) {
      gremlin_rocket1();
      Gremlin_FireRocket();
      SUB_AttackFinished(1);
   }
	else if (self.weapon == IT_LIGHTNING) {
      gremlin_light1();
      SUB_AttackFinished(1);
      sound(self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
   }
   else if (self.weapon == QCC_IT_RAILGUN) {
      gremlin_shot1 ();
      Gremlin_FireRailgun();
      SUB_AttackFinished(1.5);
   }
   else if (self.weapon == IT_LASER_CANNON) {
      gremlin_laser1();
      SUB_AttackFinished(1);
   }
   return TRUE;
};

void() Gremlin_MissileAttack = {
   if (self.stoleweapon) {
      if (GremlinWeaponAttack())
         return;
      else if ((random()<0.1) && (self.flags & FL_ONGROUND)) {
         gremlin_jump1();
         return;
      }
   }
   if (self.flags & FL_ONGROUND)
      gremlin_jump1();
};


/*
QUAKED monster_gremlin (1 0 0) (-32 -32 -24) (32 32 64) Ambush
*/
void() monster_gremlin = {
   NumGremlins = NumGremlins + 1;
   precache_model("progs/grem.mdl");
   precache_model("progs/h_grem.mdl");

   precache_sound("grem/death.wav");
   precache_sound("grem/attack.wav");
   precache_sound("demon/djump.wav");
   precache_sound("demon/dhit2.wav");
   precache_sound("grem/pain1.wav");
   precache_sound("grem/pain2.wav");
   precache_sound("grem/pain3.wav");
   precache_sound("grem/idle.wav");
   precache_sound("grem/sight1.wav");

   self.noise = "grem/sight1.wav";
   if (ExtSupported("EX_SPRINT"))
      self.killstring = "$qc_ks_gremlin";
   else
      self.killstring = " was outsmarted by a Gremlin\n";
   self.netname = "Gremlin";

   self.health = 100;
   self.max_health = 101;
   self.yaw_speed = 40;
   
   self.th_stand = gremlin_stand1;
   self.th_walk = gremlin_walk1;
   self.th_run = gremlin_run1;
   self.th_die = gremlin_die;
   self.th_melee = Gremlin_MeleeAttack;     // one of two attacks
   self.th_missile = Gremlin_MissileAttack; // check for random jump or firing of weapon
   self.th_pain = gremlin_pain;
   self.allowPathFind = TRUE;
	self.combat_style = CS_MELEE;
   
   InitMonster("progs/grem.mdl", MONSTER_TYPE_WALK, MONSTER_SIZE_SMALL);
};

float()  GremlinCheckAttack = {
	vector	spot1, spot2;
	entity	targ;
	float		chance;

	targ = self.enemy;

   if (time < self.attack_finished)
      return FALSE;

   // see if any entities are in the way of the shot
   spot1 = self.origin;// + self.view_ofs;
   spot2 = targ.origin;// + targ.view_ofs;

   if ((vlen(spot2 - spot1) <= 90) && (self.stoleweapon == FALSE)) {
      self.attack_state = AS_MELEE;
      return TRUE;
   }

   // missile attack
   chance = 0.03 + self.stoleweapon;
   if (random() < chance) {
      self.attack_state = AS_MISSILE;
      return TRUE;
   }

	return FALSE;
};


void(float dm) Gremlin_ThrowHead = {
   string gibname;
   if (self.classname == "monster_ogre")
      gibname = "progs/h_ogre.mdl";
	else if (self.classname == "monster_knight")
      gibname = "progs/h_knight.mdl";
   else if (self.classname == "monster_shambler")
      gibname = "progs/h_shams.mdl";
   else if (self.classname == "monster_demon1")
      gibname = "progs/h_demon.mdl";
   else if (self.classname == "monster_wizard")
      gibname = "progs/h_wizard.mdl";
   else if (self.classname == "monster_zombie")
      gibname = "progs/h_zombie.mdl";
   else if (self.classname == "monster_dog")
      gibname = "progs/h_dog.mdl";
   else if (self.classname == "monster_hell_knight")
      gibname = "progs/h_hellkn.mdl";
   else if (self.classname == "monster_enforcer")
      gibname = "progs/h_mega.mdl";
   else if (self.classname == "monster_army")
      gibname = "progs/h_guard.mdl";
   else if (self.classname == "monster_shalrath")
      gibname = "progs/h_shal.mdl";
   else if (self.classname == "monster_gremlin")
      gibname = "progs/h_grem.mdl";
   else if (self.classname == "monster_scourge")
      gibname = "progs/h_scourg.mdl";
   else if (self.classname == "monster_fish")
      gibname = "progs/gib1.mdl";
   else if (self.classname == "player")
      gibname = self.qccChampGib; // QCC: pick the right champ gib
   else
      return; // safety for unsupported or missing enemy types
   ThrowHead(gibname,dm);
};

/*
============
Gremlin_Damage
============
*/
void(entity targ, entity inflictor, entity attacker, float damage) Gremlin_Damage = {
   // check for godmode or invincibility
	if (targ.flags & FL_GODMODE)
		return;
	if (targ.invincible_finished >= time) {
		if (self.invincible_sound < time) {
			sound(targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
		return;
	}

   // team play damage avoidance
	if ((teamplay == 1 || deathmatch >= QCC_TDM) && (targ.team > 0) && (targ.team == attacker.team))
		return;

   // do the damage
   targ.health = targ.health - damage;
};


/*
============
Gremlin_Split, Gremlin_Gorge

spawns a new gremlin when gorging is finished
============
*/
void() Gremlin_Split = {
   entity grem, temp, head;
   float done, c, proceed;
   vector ang, pos;

   if (NumSpawnGremlins >= (NumGremlins*2))
      return;
   
   done = 0;
   c = 0;
   ang = self.angles;
   while (done == 0) {
      makevectors(ang);
      pos = self.origin + (80 * v_forward);
      head = findradius(pos, 35);
      proceed = 1;
      while (head) {
         if ((head.health > 0) && (head.flags & (FL_MONSTER | FL_CLIENT)))
            proceed = 0;
         head = head.chain;
      }
      traceline(self.origin,pos,FALSE,self);
      if (trace_fraction == 1 && (proceed == 1)) {
         traceline(self.origin,(pos-'40 40 0'),FALSE,self);
         if (trace_fraction == 1) {
            traceline(self.origin,(pos+'40 40 0'),FALSE,self);
            if (trace_fraction == 1) {
               traceline(self.origin,(pos + '0 0 64'),FALSE,self);
               if (trace_fraction == 1) {
                  traceline(self.origin,(pos - '0 0 64'),FALSE,self);
                  if (trace_fraction != 1)
                     done = 1;
               }
            }
         }
      }
      if (done == 0) {
         ang_y = ang_y + 36;
         c = c + 1;
         if (c==10)
            return;
      }
   }

   NumSpawnGremlins = NumSpawnGremlins + 1;
   grem = spawn();
   SUB_CopyEntity(self, grem);
   grem.solid = SOLID_SLIDEBOX;
   grem.movetype = MOVETYPE_STEP;
   setmodel(grem, "progs/grem.mdl");
   setsize(grem, VEC_HULL_MIN, VEC_HULL_MAX);
   grem.health = 50; //Ry: Set the new Gremlin to a flat 50 health, and leave the source Gremlin alone

   if (self.charmed) { //Ry: Also copy Horn of Conjuring status
      grem.charmer = self.charmer; 
      grem.charmed = self.charmed;
   }
   else { //Ry: Don't add to count when charmed
      total_monsters = total_monsters + 1;
      WriteByte(MSG_BROADCAST, SVC_UPDATESTAT);
      WriteByte(MSG_BROADCAST, STAT_TOTALMONSTERS);
      WriteLong(MSG_BROADCAST, total_monsters);
   }

   if (self.enemy && (self.enemy.health > 0) && ((self.enemy.flags & FL_CLIENT) || self.charmed)) //Ry: Also copy Gremlin's current enemy
      grem.enemy = self.enemy;
   else
      grem.enemy = world;

   grem.stoleweapon = FALSE;
   grem.weapon = 0;
   grem.items = 0;
   grem.ammo_cells = 0;
   grem.ammo_nails = 0;
   grem.ammo_rockets = 0;
   grem.ammo_shells = 0;
   grem.combat_style = CS_MELEE;

   setorigin(grem, pos);
   temp = self;
   self = grem;
   gremlin_spawn1();
   self.gorging = FALSE;
   self = temp;
};

void(float side)  Gremlin_Gorge = {
	local	float	ldmg;
	vector	delta;
   entity temp;

	delta = self.enemy.origin - self.origin;
   sound(self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
   ldmg = 7+5*random();
   Gremlin_Damage (self.enemy, self, self, ldmg);

	makevectors(self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
   if (self.enemy.health < -200.0) {
      if (self.enemy.gorging==FALSE) {
         self.enemy.gorging = TRUE;
         sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
         temp = self;
         self = self.enemy;
         Gremlin_ThrowHead(-15);
         ThrowGib ("progs/gib1.mdl", -15);
         ThrowGib ("progs/gib2.mdl", -15);
         ThrowGib ("progs/gib3.mdl", -15);
         self = temp;
         ldmg = 150 + 100*random();
         T_Heal(self,ldmg,FALSE);
         Gremlin_Split();
      }
      self.enemy = world;
      self.gorging = FALSE;
      gremlin_look1();
   }
};