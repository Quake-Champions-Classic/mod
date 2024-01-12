/*
===============================================================================
SCOURGE OF ARMAGON TRAP GRAVITY WELL
===============================================================================
*/

void() trap_gravity_touch = {
   if (self.attack_finished > time)
      return;
   if (other.takedamage) {
      T_Damage(other, self, self, self.dmg);
      self.attack_finished = time + 0.2;
   }
};

void() trap_gravity_think = {
   vector vel, dir, delta;

   self.ltime = time;
   trap_tesla_scan();
   while (tesla_numtargets > 0) {
      delta = self.origin - tesla_target.origin;
      dir = normalize(delta);
      vel = dir * self.speed;
      if ((tesla_target.wetsuit_finished > time) && (self.spawnflags & UNDERWATER))
         vel = vel * 0.6;
      tesla_target.velocity = tesla_target.velocity + vel;
      tesla_target = tesla_target.next_ent;
      tesla_numtargets = tesla_numtargets - 1;
   }
   self.nextthink = time + 0.1;
};

/*QUAKED trap_gravity_well (.8 .5 0) (-8 -8 -8) (8 8 8) targetenemies UNDERWATER
targets enemies in vicinity and draws them near, gibbing them on contact.

UNDERWATER cuts the pull in half for players wearing the wetsuit

"distance" how far the gravity well should reach (600 default)
"count" number of people to target (2 default)
"speed" is how strong the pull is. (210 default)
"dmg" is how much damage to do each touch. (10000 default)
*/
void() trap_gravity_well = {
   self.solid = SOLID_TRIGGER;
   self.movetype = MOVETYPE_NONE;
   setsize(self, '-16 -16 -16','16 16 16');
   if (self.dmg == 0)
      self.dmg = 10000;
   if (self.speed == 0)
      self.speed = 210;
   if (self.distance == 0)
      self.distance = 600;
   if (self.spawnflags & 1)
      self.cnt = FL_CLIENT | FL_MONSTER;
   else
      self.cnt = FL_CLIENT;
   self.attack_finished = 0;
   self.think = trap_gravity_think;
   self.touch = trap_gravity_touch;
   self.lastvictim = world;
   tesla_numtargets = 0;
   self.nextthink = time + 0.1;
   self.ltime = time;
};
