void() PlayerJump = {	
	if (self.flags & FL_WATERJUMP)
		return;
	
	if (self.waterlevel >= 2) {
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 100;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

		// Play swimming sound
		if (self.swim_flag < time) {
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound(self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				sound(self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}
		return;
	}

	self.qccJumpFunc();
	if (self.qccDoubleJump != 0)
		return;

	if (!(self.flags & FL_ONGROUND))
		return;

	if (!(self.flags & FL_JUMPRELEASED))
		return; // Don't pogo stick

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	self.flags = self.flags - (self.flags & FL_ONGROUND); // Don't stairwalk
	
	self.button2 = 0;
	sound(self, CHAN_BODY, self.qccSndJump, 1, ATTN_NORM);
	self.velocity_z = self.velocity_z + 270;
};

.float	dmgtime;

void() WaterMove = {
	if (self.movetype == MOVETYPE_NOCLIP)
		return;

	if (self.health < 0)
		return;

	if (self.waterlevel != 3) {
		if (!(self.qccFlags & QCC_FL_MERMAID)) {
			if (self.air_finished < time)
				sound(self, CHAN_VOICE, self.qccSndGasp2, 1, ATTN_NORM);
			else if (self.air_finished < time + 9)
				sound(self, CHAN_VOICE, self.qccSndGasp1, 1, ATTN_NORM);
		}
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time && !(self.qccFlags & QCC_FL_MERMAID)) {
		if (self.pain_finished < time) {
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
			T_Damage(self, world, world, self.dmg);
			self.pain_finished = time + 1;
		}
	}
	
	if (!self.waterlevel) {
		if (self.flags & FL_INWATER) {
			sound(self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{	// do damage if we're not Death Knight
		if (!(self.qccFlags & QCC_FL_FIREPROOF) && self.dmgtime < time) {
			if (self.radsuit_finished < time)
                self.dmgtime = time + 0.2;
            else
				self.dmgtime = time + 1;
			T_Damage(self, world, world, 10 * self.waterlevel);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{	// do damage if we're not Sorlag
		if (!(self.qccFlags & QCC_FL_SLIMEPROOF) && self.dmgtime < time && self.radsuit_finished < time) {
			self.dmgtime = time + 1;
			T_Damage(self, world, world, 4 * self.waterlevel);
		}
	}
	
	if (!(self.flags & FL_INWATER)) {
		// player enter water sound
		if (self.watertype == CONTENT_WATER)
			sound(self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
        else if (self.watertype == CONTENT_SLIME)
			sound(self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);
        else if (self.watertype == CONTENT_LAVA)
                sound(self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}
	
	if (!(self.flags & FL_WATERJUMP))
		self.velocity = self.velocity - 0.8 * self.waterlevel * frametime * self.velocity;
};

void() CheckWaterJump = {
	vector start, end;

    // Check for a jump-out-of-water
	makevectorsfixed(self.angles);
	start = self.origin;
	start_z += 8;
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward * 24;
	traceline(start, end, TRUE, self);

    // Solid at waist
	if (trace_fraction < 1) {
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward * 24;
		self.movedir = trace_plane_normal * -50;
		traceline(start, end, TRUE, self);

        // Open at eye level
		if (trace_fraction == 1) {
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// Safety net
			return;
		}
	}
};