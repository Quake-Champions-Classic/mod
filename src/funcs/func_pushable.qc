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

/* Pushable walls QuickC program
   By Jim Dose'  9/16/96

*/

void() push_use = {
	vector delta;
	float x, y;
	makevectors(other.angles);

	x = fabs(other.velocity_x);
	y = fabs(other.velocity_y);
	dprint(ftos(x));
	dprint(", ");
	dprint(ftos(y));
	if (x > y) {
		dprint(" x move\n\n\n\n");
		if (other.velocity_x > 0)
			walkmove (0, 16 * frametime);
		else
			walkmove(180, 16 * frametime);
	}
	else {
		dprint(" y move\n\n\n\n");
		if (other.velocity_y > 0)
			walkmove (90, 16 * frametime);
		else
			walkmove(270, 16 * frametime);
	}
	delta = self.origin - self.oldorigin;
	setorigin(self.owner, self.owner.oldorigin + delta);
};

/*QUAKED func_pushable (0 .5 .8) ?
Pushable walls.
*/
void() func_pushable = {
	entity new;
	vector newsize;

	self.mangle = self.angles;
	self.angles = '0 0 0';

	self.classname = "pushablewall";
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel(self, self.model);
	setorigin(self, self.origin);
	setsize(self, self.mins, self.maxs);
	self.oldorigin = self.origin;

	new = spawn();
	new.owner = self;
	new.mangle = self.mangle;
	new.angles = self.angles;

	new.classname = "pushablewallproxy";
	new.solid = SOLID_BBOX;
	new.movetype = MOVETYPE_STEP;
	new.origin = (self.mins + self.maxs) * 0.5 + '0 0 1';
	newsize = (self.maxs - self.mins) * 0.5;
	new.mins = '-1 -1 0' - newsize;
	new.maxs = '1 1 -2' + newsize;
	setsize(new, new.mins, new.maxs);
	setorigin(new, new.origin);
	new.oldorigin = new.origin;
	new.touch = push_use;
};
