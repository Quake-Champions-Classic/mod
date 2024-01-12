/*
==============================================================================
SOA: TRIGGER SET GRAVITY
==============================================================================
*/

void() trigger_gravity_touch = {
	if (other.classname != "player")
		return;
   if (self.gravity == -1)
      other.gravity = 1.0;
   else
      other.gravity = self.gravity;
};

/*QUAKED trigger_setgravity (.5 .5 .5) ?
set the gravity of a player
"gravity" what to set the players gravity to
 - 0 (default) normal gravity
 - 1 no gravity
 - 2 almost no gravity
 - ...
 - 101 normal gravity
 - 102 slightly higher gravity
 - ...
 - 1000 very high gravity
*/
void() trigger_setgravity = {
    InitTrigger();
    self.touch = trigger_gravity_touch;
    if (!self.gravity)
      self.gravity = -1;
   else
      self.gravity = ((self.gravity - 1) / 100);
};