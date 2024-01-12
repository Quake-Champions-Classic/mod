/*
=========================
FUNC TOGGLE WALL
=========================
*/

void () blocker_touch =
	{
   if (!self.dmg)
      return;

	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	T_Damage(other, self, self, self.dmg);
   };

void () blocker_use = {
   if (!self.state) {
      self.state = 1;
      setorigin(self, self.origin - '8000 8000 8000');
      sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
   }
   else {
      self.state = 0;
      setorigin(self, self.origin + '8000 8000 8000');
      sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
   }
};

/*QUAKED func_togglewall (0 .5 .8) ? START_OFF
Creates a invisible wall that can be toggled on and off.
START_OFF wall doesn't block until triggered.
"noise" is the sound to play when wall is turned off.
"noise1" is the sound to play when wall is blocking.
"dmg" is the amount of damage to cause when touched.
*/
void() func_togglewall = {
   self.classname = "togglewall";
   self.movetype = MOVETYPE_PUSH;
   self.mdl = self.model;
   setmodel(self, self.model);
   setsize(self, self.mins, self.maxs);
   setorigin(self, self.origin);
   self.touch = blocker_touch;
   self.use = blocker_use;

   if (!self.noise)
      self.noise = ("misc/null.wav");
   if (!self.noise1)
      self.noise1 = ("misc/null.wav");
   precache_sound(self.noise);
   precache_sound(self.noise1);

   self.solid = SOLID_BSP;
   self.model = string_null;
   if (self.spawnflags & START_OFF) {
      self.state = 0;
      setorigin(self, self.origin + '8000 8000 8000');
   }
   else {
      self.state = 1;
      sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
   }
};
