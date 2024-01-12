/*
===================================================
SOA: TRIGGER USE KEY
===================================================
*/

/* Trigger QuickC program
   By Jim Dose'  12/2/96
*/

float USE_GOLD_KEY = 1;

void() keytrigger_use = {
   if (activator.classname != "player")
		return;
   if (self.attack_finished > time)
		return;

   self.attack_finished = time + 2;

   // FIXME: blink key on player's status bar
   if ((self.items & activator.items) != self.items) {
      if (self.message != "")
         centerprint (activator, self.message);
      else {
         if (self.owner.items == IT_KEY1) {
            if (world.worldtype == WORLDTYPE_BASE) {
               if (ExtSupported("EX_CENTERPRINT"))
                  centerprint (other, "$qc_need_silver_keycard");
               else
                  centerprint (other, "You need the silver keycard");
            }
            else if (world.worldtype == WORLDTYPE_METAL) {
               if (ExtSupported("EX_CENTERPRINT"))
                  centerprint (other, "$qc_need_silver_runekey");
               else
                  centerprint (other, "You need the silver runekey");
            }
            else if (world.worldtype == WORLDTYPE_MEDIEVAL || world.worldtype == WORLDTYPE_HUB) {
               if (ExtSupported("EX_CENTERPRINT"))
                  centerprint (other, "$qc_need_silver_key");
               else
                  centerprint (other, "You need the silver key");
            }
         }
         else if (self.owner.items == IT_KEY2) {
            if (world.worldtype == WORLDTYPE_BASE) {
               if (ExtSupported("EX_CENTERPRINT"))
                  centerprint (other, "$qc_need_gold_keycard");
               else
                  centerprint (other, "You need the gold keycard");
            }
            else if (world.worldtype == WORLDTYPE_METAL) {
               if (ExtSupported("EX_CENTERPRINT"))
                  centerprint (other, "$qc_need_gold_runekey");
               else
                  centerprint (other, "You need the gold runekey");			
            }
            else if (world.worldtype == WORLDTYPE_MEDIEVAL || world.worldtype == WORLDTYPE_HUB) {
               if (ExtSupported("EX_CENTERPRINT"))
                  centerprint (other, "$qc_need_gold_key");
               else
                  centerprint (other, "You need the gold key");
            }
         }
      }
      sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
      return;
   }

   activator.items = activator.items - self.items;

   // we can't just remove(self) here, because this is a touch function
   // called while C code is looping through area links...
   self.touch = SUB_Null;
   self.use = SUB_Null;
   self.nextthink = time + 0.1;
   self.think = SUB_Remove;
   self.message = "";

   sound(self, CHAN_VOICE, self.noise4, 1, ATTN_NORM);

   SUB_UseTargets();
};

void() keytrigger_touch = {
   activator = other;
   keytrigger_use();
};

/*QUAKED trigger_usekey (0 .5 0) ? USE_GOLD_KEY
Variable sized single use trigger that requires a key to trigger targets. Must be targeted at one or more entities.
"message" is printed when the trigger is touched without having the right key.
*/
void() trigger_usekey = {
   if (world.worldtype == 0) {
		precache_sound("doors/medtry.wav");
		precache_sound("doors/meduse.wav");
		self.noise3 = "doors/medtry.wav";
		self.noise4 = "doors/meduse.wav";
	}
	else if (world.worldtype == 1) {
		precache_sound("doors/runetry.wav");
		precache_sound("doors/runeuse.wav");
		self.noise3 = "doors/runetry.wav";
		self.noise4 = "doors/runeuse.wav";
	}
	else if (world.worldtype == 2) {
		precache_sound("doors/basetry.wav");
		precache_sound("doors/baseuse.wav");
		self.noise3 = "doors/basetry.wav";
		self.noise4 = "doors/baseuse.wav";
	}
	else
		dprint ("no worldtype set!\n");

   if (self.spawnflags & USE_GOLD_KEY)
      self.items = IT_KEY2;
   else
      self.items = IT_KEY1;

   self.use = keytrigger_use;
   self.touch = keytrigger_touch;
	InitTrigger();
};