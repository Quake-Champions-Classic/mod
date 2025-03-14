void(vector p1, vector p2, entity from, float damage) LightningDamage = {
	float tx;
	entity e1, e2;
	vector f;
	
	f = p2 - p1;
	f = normalize(f);
	tx = f_x;
	f_x = 0 - f_y;
	f_y = tx;
	f_z = 0;
	f = f * 16;

	e1 = e2 = world;

	traceline(p1, p2, FALSE, self);
	if (trace_ent.takedamage && !trace_ent.wetsuit_finished) { // HIP: JIM
		particle(trace_endpos, '0 0 100', 225, damage * 4);
		T_Damage(trace_ent, from, from, damage);
		if (self.classname == "player" && other.classname == "player")
			trace_ent.velocity_z += 400;
	}
	e1 = trace_ent;

	traceline(p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage && !trace_ent.wetsuit_finished) { // HIP: JIM
		particle(trace_endpos, '0 0 100', 225, damage * 4);
		T_Damage(trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline(p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage && !trace_ent.wetsuit_finished) { // HIP: JIM
		particle(trace_endpos, '0 0 100', 225, damage * 4);
		T_Damage(trace_ent, from, from, damage);
	}
};


void() W_FireLightning = {
	vector org;
	float cells;

	if (self.ammo_cells < 1) {
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	// explode if under water
	if (self.waterlevel > 1) {
		cells = self.ammo_cells;
		self.ammo_cells = 0;
		W_SetCurrentAmmo ();
		discharged = 1; // HIP: MED 01/05/97 added discharge flag
		T_RadiusDamage(self, self, 13*cells, world);
		discharged = 0;
		return;
	}

	if (self.t_width < time) {
		sound(self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}

	self.punchangle_x = -2;
	self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	org = self.origin + self.view_ofs - '0 0 6';
	makevectors(self.v_angle);
	traceline(org, org + v_forward * 600, TRUE, self);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity(MSG_BROADCAST, self);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);

	LightningDamage(self.origin, trace_endpos + v_forward * 4, self, 13);
};

void() player_light1;

void() W_Lightning_Attack = {
	player_light1();
	self.attack_finished = time + 0.1;
	sound(self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
}

/*
================
PICKUP
================
*/
void() weapon_lightning = {
	precache_model("progs/g_light.mdl");
	setmodel(self, "progs/g_light.mdl");
	self.weapon = IT_LIGHTNING;
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_thunderbolt";
	else
		self.netname = "Thunderbolt";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() item_cells = {
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2) {
		precache_model("maps/b_batt1.bsp");
		setmodel(self, "maps/b_batt1.bsp");
		self.aflag = 50;
	}
	else {
		precache_model("maps/b_batt0.bsp");
		setmodel(self, "maps/b_batt0.bsp");
		self.aflag = 25;
	}
	self.weapon = IT_CELLS;

	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_cells";
	else
		self.netname = "cells";
    
	setsize(self, '0 0 0', '32 32 56');
	StartItem();
};