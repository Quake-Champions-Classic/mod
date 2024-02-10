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

// LAVA Weapon Routines

/*
===============
launch_lava_spike

No longer a player weapon; Used for trap shooters
===============
*/
void(vector org, vector dir) launch_lava_spike = {
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = lavaspike_touch;
	newmis.classname = "lava_spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel(newmis, "progs/lspike.mdl");	
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin(newmis, org);

	newmis.velocity = dir * 1000;
};

void() lavaspike_touch = {
	float old_armortype, old_armorvalue;

	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}
	
	// hit something that bleeds
	if (other.takedamage) {
		spawn_touchblood(9);
		if (other.classname == "player") {
			old_armortype = other.armortype;
			old_armorvalue = other.armorvalue;
			other.armortype = 0;
			other.armorvalue = 0;
			T_Damage(other, self, self.owner, 9);
			other.armortype = old_armortype;
			other.armorvalue = old_armorvalue;
		}
		else	// is a monster
			if (other.classname != "monster_lava_man")
				T_Damage(other, self, self.owner, 15);
	}
	else {
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte(MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte(MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte(MSG_BROADCAST, TE_SPIKE);
		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
	}

	remove(self);
};

void() superlavaspike_touch = {
	float old_armortype;

	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}
	
	// hit something that bleeds
	if (other.takedamage) {
		spawn_touchblood(18);
		
		// halve the effectiveness of the armor for players..
		if (other.classname == "player") {
			// save the old armor values...
			old_armortype = other.armortype;
			other.armortype = other.armortype * 0.5;
			T_Damage(other, self, self.owner, 18);
			other.armortype = old_armortype;
		}
		else	// is a monster, do 50% more damage
			if (other.classname != "monster_lava_man")
				T_Damage(other, self, self.owner, 30);
	}
	else {
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
	}

	remove(self);
};

/*
================
PICKUP
================
*/
void() item_lava_spikes = {
	item_spikes();
};