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

/* Bullet holes QuickC program
   By Jim Dose'  11/20/96
*/

/*QUAKED wallsprite (0 1 0) (-8 -8 -8) (8 8 8)
Places a sprite on a wall.  Angles should be opposite of face.
"model" sprite to place on wall.  Default is "progs/s_blood1.spr". */
void() wallsprite = {
   if (!self.model)
      self.model = "progs/s_blood1.spr";

   precache_model(self.model);
   setmodel(self, self.model);

   // QuakeEd doesn't save up and down angles properly.
   if (self.angles == '0 -1 0')
      self.angles = '-90 0 0';
	else if (self.angles == '0 -2 0')
      self.angles = '90 0 0';

   // Pull the sprite away from the wall slightly to get rid of z sort errors.
   makevectors(self.angles);
   setorigin(self, self.origin - (v_forward * 0.2));
	makestatic(self);
};
