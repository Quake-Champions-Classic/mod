void() spike_touch = {
    float damg = 12;

	if (other == self.owner)
		return;
	if (other.solid == SOLID_TRIGGER)
		return;
	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}
    // Don't touch Ghost Walker
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;
	
	// Hit something that bleeds
	if (other.takedamage && other.classname != "monster_boss") { // yoder mod, jan 05 2021
		spawn_touchblood(12);
		T_Damage(other, self, self.owner, 12);
	}
	else {
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);

		if (self.classname == "wizard_spike")
			WriteByte(MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knight_spike")
			WriteByte(MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte(MSG_BROADCAST, TE_SPIKE);
        
		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
	}
	
	T_RadiusDamage(self, self.owner, 20, other);
	remove(self);
};

void() superspike_touch = {
	if (other == self.owner)
		return;
	if (other.solid == SOLID_TRIGGER)
		return;
	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}
    // Don't touch Ghost Walker
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;
	
	// hit something that bleeds
	if (other.takedamage && other.classname != "monster_boss") { // yoder mod, jan 05 2021
		spawn_touchblood(18);
		T_Damage(other, self, self.owner, 18);
	}
	else {
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
	}
	
	T_RadiusDamage(self, self.owner, 37, other);
	remove(self);
};

void(vector org, vector dir) launch_spike = {
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;

	setmodel(newmis, "progs/spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin(newmis, org);

	newmis.velocity = dir * 1000;

	if (!(self.flags & FL_MONSTER))	// hell knights and scrags use launch_spike but we shouldn't let them be grabbable
		newmis.qccFlags |= QCC_FL_THROWABLE;
	newmis.qccFlags |= QCC_FL_CANDEFLECT;
};

void() W_FireSuperSpikes = {
	vector dir;
	
	self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	self.attack_finished = time + 0.2;

	dir = aim(self, 1000);
	launch_spike (self.origin + self.view_ofs - '0 0 6', dir);
	newmis.classname = "super_spike";
	newmis.touch = superspike_touch;
	setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);	
    
	sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;
};

void(float ox) W_FireSpikes = {
	vector dir;
	
	makevectors(self.v_angle);	
	if (self.ammo_nails >= 2 && self.weapon == IT_SUPER_NAILGUN) {
		W_FireSuperSpikes();		
        return;
	}

	if (self.ammo_nails < 1) {
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	self.attack_finished = time + 0.2;

	dir = aim(self, 1000);
	launch_spike(self.origin + self.view_ofs - '0 0 6' + v_right * ox, dir);
	
    sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;
};