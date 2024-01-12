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

//=====================================================================
//
// Spawning Functions (Hipnotic)
//
//=====================================================================

void() spawn_think = {
   self.think = spawn_think;
   self.nextthink = time + 1;
};

void() spawn_use = {
   entity spawnentity;

   if ((self.spawnmulti == 1) || (horn_active)) {
      spawnentity = spawn();
      SUB_CopyEntity(self.spawnmaster, spawnentity);   // copy the master mold
   }
   else
      spawnentity = self.spawnmaster;
   
   spawnentity.model = spawnentity.spawnmodel;
   spawnentity.solid = spawnentity.spawnsolidtype;

   //restore thinking function
   spawnentity.think = spawnentity.spawnthink;
   setmodel(spawnentity, spawnentity.model);
   setorigin(spawnentity, spawnentity.origin);
   spawnentity.mins = spawnentity.spawnmins;
   spawnentity.maxs = spawnentity.spawnmaxs;
   setsize(spawnentity, spawnentity.mins, spawnentity.maxs);

   // spawn the teleport effect
   if (self.spawnsilent == 0)
      spawn_tfog(spawnentity.origin);
   
   // call spawnentity think function
   if (horn_active) {
      spawnentity.charmer = horn_charmer;
      spawnentity.charmed = 1;
   }

   // check to see if it is a monster
   if (spawnentity.flags & FL_MONSTER) {
      if ((self.spawnmulti != 0) && (horn_active == 0)) {
         total_monsters = total_monsters + 1;
         WriteByte(MSG_BROADCAST, SVC_UPDATESTAT);
         WriteByte(MSG_BROADCAST, STAT_TOTALMONSTERS);
         WriteLong (MSG_BROADCAST, total_monsters);
      }
      if (horn_active)
         spawnentity.effects = spawnentity.effects | EF_DIMLIGHT;
   }
   if ((self.spawnmulti == 0) && (horn_active == 0))
      remove(self);
};

/*QUAKED func_spawn (0 .5 .8) (-32 -32 -24) (32 32 64) big/ambush megahealth
This will spawn a thing upon being used. The thing that is spawned depends upon the value of "spawnfunction".
"spawnclassname" should contain the same value as "spawnfunction". If "spawnfunction" is unspecified a random monster is chosen.
The angles, target and all flags are passed on. Think of it like setting up a normal entity.
"spawnsilent" set this to 1 if you want a silent spawn.
"spawnmulti" set this to 1 if you want this spawn to be reoccuring.
*/
void() func_spawn = {
   entity tempself, monster;
   float tempdeathmatch, temptotal_monsters;

   // save off deathmatch and zero it out
   tempself = self;
   tempdeathmatch = deathmatch;
   deathmatch = 0;

   if (!self.spawnfunction) {
      float spawnchance;
      
      monster = tempself;
      self = spawn();
      SUB_CopyEntity(tempself, self);

      spawnchance = random();
      if (spawnchance < 0.5) {
         self.spawnfunction = monster_dog;
         self.spawnclassname = "monster_dog";
      }
      else if (spawnchance < 0.8) {
         self.spawnfunction = monster_ogre;
         self.spawnclassname = "monster_ogre";
      }
      else if (spawnchance < 0.92) {
         self.spawnfunction = monster_demon1;
         self.spawnclassname = "monster_demon1";
      }
      else if (spawnchance < 0.97) {
         self.spawnfunction = monster_zombie;
         self.spawnclassname = "monster_zombie";
      }
      else {
         self.spawnfunction = monster_shambler;
         self.spawnclassname = "monster_shambler";
      }

      self.classname = self.spawnclassname;

      // call the named spawn function
      self.spawnfunction();
      self.spawnmodel = self.model;
      self.spawnmins = self.mins;
      self.spawnmaxs = self.maxs;
      setmodel(self, "");
      setsize(self, self.spawnmins, self.spawnmaxs);

      //save off solid flag
      self.spawnsolidtype = self.solid;
      self.solid = SOLID_NOT;

      //save off think func and get rid of his thinking
      self.spawnthink = self.think;
      self.think = spawn_think;
      self.nextthink = time + 1;

      monster = self;
   }
   else {
      self = spawn();
      SUB_CopyEntity(tempself,self);

      // save off monster count so it doesn't get f'ed up
      temptotal_monsters = total_monsters;

      if (self.spawnclassname == string_null)
         objerror("No spawnclassname defined");
      self.classname = self.spawnclassname;

      // call the named spawn function
      self.spawnfunction();

      // make sure monster count is correct
      if (self.spawnmulti != 0)
         total_monsters = temptotal_monsters;
      
      self.spawnmodel = self.model;
      self.spawnmins = self.mins;
      self.spawnmaxs = self.maxs;
      setmodel(self, "");
      self.model = "";
      setsize(self, self.spawnmins, self.spawnmaxs);

      //save off solid flag
      self.spawnsolidtype = self.solid;
      self.solid = SOLID_NOT;

      //save off think func and get rid of his thinking
      self.spawnthink = self.think;
      self.think = spawn_think;
      self.nextthink = time + 1;
      monster = self;
   }

   self = tempself;
   deathmatch = tempdeathmatch;
   self.solid = SOLID_NOT;
   self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
   setmodel(self, self.model);  // set size and link into world
   self.use = spawn_use;
   self.spawnmaster = monster;
};

/*QUAKED func_spawn_small (0 .5 .8) (-16 -16 -24) (16 16 40) big/ambush megahealth
This will spawn a thing upon being used. The thing that is spawned depends upon the value of "spawnfunction".
"spawnclassname" should contain the same value as "spawnfunction".
If "spawnfunction" is unspecified a random monster is chosen.
The angles, target and all flags are passed on. Think of it like setting up a normal entity.
"spawnsilent" set this to 1 if you want a silent spawn.
"spawnmulti" set this to 1 if you want this spawn to be reoccuring.
*/
void() func_spawn_small = {
   func_spawn();
};
