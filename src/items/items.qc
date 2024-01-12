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

void() W_SetCurrentAmmo;

/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD BE .8 .3 .4 IN COLOR */

void() SUB_regen = {
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound(self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);
	setorigin(self, self.origin);
};

// Prints a warning message when spawned
void() noclass = {
	dprint("noclass spawned at");
	dprint(vtos(self.origin));
	dprint("\n");
	remove(self);
};

// Plants the object on the floor
void() PlaceItem = {
	float oldz;

	if (self.netname == string_null) {
		if (self.items) {
			self.netname = GetNetName(self.items);
		}
		else if (self.weapon) {
			if (self.qccItems3) // QCC: used for alt weapons
				self.netname = GetNetName(self.weapon + 1);
			else
				self.netname = GetNetName(self.weapon);	
		}
	}

	self.mdl = self.model;		// so it can be restored on respawn
	self.flags = FL_ITEM;		// make extra wide
	self.solid = SOLID_TRIGGER;

	// MG1
	if (self.spawnflags & DROPTOFLOOR_DISABLE)
		self.movetype = MOVETYPE_NONE;
	else
		self.movetype = MOVETYPE_TOSS;
	
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	oldz = self.origin_z;

	self.qccFlags |= QCC_FL_THROWABLE;

	if (!droptofloor()) {
		dprint("Bonus item fell out of level at ");
		dprint(vtos(self.origin));
		dprint("\n");
		remove(self);
		return;
	}
};

// Sets the clipping size and plants the object on the floor
void() StartItem = {
	INHIBIT_COOP // MG1
	if (RemovedOutsideCoop())
		return;
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = PlaceItem;
};