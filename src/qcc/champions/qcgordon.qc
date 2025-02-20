/*
======================================================
QCC: GORDON FREEMAN
======================================================
*/
void() QCC_ResonanceCascade;
void() QCC_GordonLongJump;
void() QCC_GordonBotPre;

void() QCC_GordonFreeman = {
	// Stats
	self.qccClass = QCC_MEDIUM;
	self.qccAbilityFunc = QCC_ResonanceCascade;
	self.qccAbilityString = "Resonance Cascade";
	self.qccJumpFunc = QCC_GordonLongJump;
	self.qccBotPreThink = QCC_GordonBotPre;
	self.qccFlags |= QCC_FL_FAST_MELEE;
	// Model
	setmodel(self, "progs/qcgordon.mdl");
	self.qccChampGib = "progs/h_qcgordon.mdl";
	self.qccMeleeMdl = "progs/v_crowbar.mdl";
	QCC_SetSkin(8);
	// Sounds
	self.qccSndMelee = "gordon/cbar_miss1.wav";
	self.qccSndMeleeHit = "gordon/cbar_hitbod1.wav";
	self.qccSndMeleeWall = "gordon/cbar_hit1.wav";
	self.qccSndJump = "gordon/pl_jump1.wav";
	self.qccSndLand1 = "gordon/pl_jumpland2.wav";
	self.qccSndLand2 = "gordon/pl_fallpain3.wav";
	self.qccSndPain1 = "gordon/pl_pain2.wav";
	self.qccSndPain2 = "gordon/pl_pain2.wav";
	self.qccSndPain3 = "gordon/pl_pain4.wav";
	self.qccSndPain4 = "gordon/pl_pain5.wav";
	self.qccSndPain5 = "gordon/pl_pain6.wav";
	self.qccSndPain6 = "gordon/pl_pain7.wav";
	self.qccSndDeath1 = "gordon/death.wav";
	self.qccSndDeath2 = "gordon/death.wav";
	self.qccSndDeath3 = "gordon/death.wav";
	self.qccSndDeath4 = "gordon/death.wav";
	self.qccSndDeath5 = "gordon/death.wav";
	self.qccSndAxHit1 = "gordon/pl_pain7.wav";
	self.qccSndBurn1 = "gordon/pl_pain7.wav";
	self.qccSndBurn2 = "gordon/pl_pain7.wav";
	self.qccSndGasp1 = "gordon/breathe2.wav";
	self.qccSndGasp2 = "gordon/breathe1.wav";
	self.qccSndDrown1 = "gordon/pl_swim3.wav";
	self.qccSndDrown2 = "gordon/pl_swim4.wav";
	self.qccSndH2oDeath = "gordon/death.wav";

	self.qccSpeakDamaged = QCC_GordonDamaged;
	self.qccSpeakItem = QCC_GordonItem;
	self.qccSpeakCthonGreet = "gordon/heat_damage.wav";
	self.qccSpeakCthonKill = "gordon/dangeroff.wav";
    self.qccSpeakShubGreet = "gordon/near_death.wav";
    self.qccSpeakShubKill = "gordon/safeday.wav";
};

/*
======================================================
QCC: RESONANCE CASCADE
======================================================
*/
void() QCC_ResonanceFlashProc = {
	if (self.qccAbilityTimer > time) {
        // Fade green tint
        stuffcmd(self.owner, "v_cshift ");
        float t = (self.qccAbilityTimer - time) / 1.3;
        stuffcmd(self.owner, ftos(77 * t));
        stuffcmd(self.owner, " ");
        stuffcmd(self.owner, ftos(210 * t));
        stuffcmd(self.owner, " ");
        stuffcmd(self.owner, ftos(130 * t));
		stuffcmd(self.owner, " ");
		stuffcmd(self.owner, ftos(128 * t));
        stuffcmd(self.owner, "\n");

        self.think = QCC_ResonanceFlashProc;
        self.nextthink = time + 0.01;
        return;
    }

    stuffcmd(self.owner, "v_cshift 1 1 1 1\n");
	remove(self);
}

void(entity pl) QCC_ResonanceFlash = {
	entity ent;
	stuffcmd(pl, "v_cshift 77 210 130 128\n"); // green view
	ent = spawn();
	ent.owner = pl;
	ent.qccAbilityTimer = time + 1.3;
	ent.think = QCC_ResonanceFlashProc;
	ent.nextthink = time + 0.01;
};

void() s_hltele1_proc = [0, s_hltele1_proc] {
	self.walkframe += 1;
	if (self.walkframe > 24) {
		remove(self);
		return;
	}
	self.frame = self.walkframe;
	self.nextthink = 0.01;
};

void() s_hltele2_proc = [0, s_hltele1_proc] {
	self.walkframe += 1;
	if (self.walkframe > 18) {
		remove(self);
		return;
	}
	self.frame = self.walkframe;
	self.nextthink = 0.01;
};

void(vector org) QCC_ResonanceParticles = {
	vector vel;
	vel_x = -50;
	while (vel_x <= 50) {
		vel_y = -50;
		while (vel_y <= 50) {
			vel_z = -50;
			while (vel_z <= 50) {
				particle(org, vel, 241, 10);
				vel_z += 25;
			}
			vel_y += 25;
		}
		vel_x += 25;
	}
};

// called by Ability Object
void() QCC_ResonanceWarp = {
	entity ent;

	// Teleport FX start pos
	sound(self.qccAbilityOwner, 6, "gordon/beamstart2.wav", 0.6, ATTN_NORM);
	ent = spawn();
	setmodel(ent, "progs/qchltele1.spr");
	setorigin(ent, self.qccAbilityOwner.origin);
	ent.think = s_hltele1_proc;
	ent.nextthink = 0.016;

	// Teleport FX end pos
	QCC_ResonanceParticles(self.origin);
	sound(self, 6, "gordon/beamstart7.wav", 0.6, ATTN_NORM);
	ent = spawn();
	setmodel(ent, "progs/qchltele2.spr");
	setorigin(ent, self.origin);
	ent.think = s_hltele2_proc;
	ent.nextthink = 0.016;

	// Teleport Gordon
	ent = self.qccAbilityOwner;
	
	QCC_ResonanceFlash(ent);
	spawn_tdeath(self.origin, ent);
	
	setorigin(ent, self.origin);
	ent.fixangle = 1;
	ent.teleport_time = time + 0.7;
	makevectors(self.angles);
	ent.angles = self.angles;
	ent.velocity = v_forward * 100;
	
	if (!coop && !deathmatch)
		FogPushSettingsFrom(ent, self, 0);
	
	ent.flags -= (self.flags & FL_ONGROUND);

	ent.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
	remove(self);
};

// Called by Gordon
void() QCC_ResonanceCascade = {	
	vector org;
	entity ent;
	float dist;
	float odist;
	
	if (self.qccAbilityTimer < 0)
		return;
	QCC_AbilityUsed();
	self.qccAbilityTimer = -1;

	// Setup Warp Ent
	self.qccAbilityEnt = spawn();
	self.qccAbilityEnt.qccAbilityOwner = self;

	// Check if we targeted somebody we can kill
	makevectors	(self.v_angle);
	org = self.origin;
	traceline(org, org + v_forward * 4096, 0, self);
	if (trace_ent.takedamage) {
		setorigin(self.qccAbilityEnt, trace_ent.origin);
		self.qccAbilityEnt.angles = self.angles;
	}
	// Find a random player start or teleport destination if no target
	else {
		dist = 0;
		ent = nextent(world);
		while (ent != world) {
			if (ent.classname == "info_teleport_destination" || 
				ent.classname == "info_player_deathmatch" || 
				ent.classname == "info_player_coop" ||
				ent.classname == "info_player_start" || 
				ent.classname == "info_player_start2" ) {
				odist = dist;
				dist = vlen(ent.origin - self.origin);
				if (dist > odist) {
					setorigin(self.qccAbilityEnt, ent.origin);
					self.qccAbilityEnt.angles = ent.mangle;
				}
			}
			ent = nextent(ent);
		}
	}

	// Delay the warp, to give opponents a bit of warning
	self.qccAbilityEnt.think = QCC_ResonanceWarp;
	self.qccAbilityEnt.nextthink = time + 2.5;

	// Initial spark
	QCC_ResonanceParticles(self.origin);
	sound(self, 6, "gordon/beamstart3.wav", 0.6, ATTN_NORM);
	QCC_ResonanceParticles(self.qccAbilityEnt.origin);
	sound(self.qccAbilityEnt, 6, "gordon/beamstart3.wav", 0.6, ATTN_NORM);

	QCC_ResonanceFlash(self);
};

/*
======================================================
QCC: LONG JUMP MODULE
======================================================
*/
void() QCC_GordonLongJump = {
	vector vel;

	if (!(self.flags & FL_ONGROUND)) {
		if (self.qccDoubleJump != 0)
			return;
		if (!(self.flags & FL_JUMPRELEASED))
			return;		// don't pogo stick
		
		self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
		self.flags = self.flags - (self.flags & FL_ONGROUND);	// don't stairwalk
		self.button2 = 0;
		self.qccDoubleJump = -1;

		sound(self, CHAN_BODY, "gordon/jumpmod_boost2.wav", 1, ATTN_NORM);

		vel = self.velocity;
		vel_z = 0;
		if (vlen(vel) == 0) {
			makevectors(self.angles);
			vel = v_forward;
		}
		else
			vel = normalize(vel);
		vel = vel * 320;
		self.velocity += vel;
		self.velocity_z = 135;
		
		return;
	}

	self.qccDoubleJump = 0;
};

/*
======================================================
QCC: HEV STATUS
======================================================
*/
// HEV Damage
void(entity targ, entity attacker) QCC_GordonDamaged = {
	string s;

	if (targ.qccTauntTimer > time)
        return;

	if (targ.health <= 0) {
		if (targ.health < -40)
			s = "gordon/death.wav";
		else
			return;
	}
	else if (targ.health < 26)
		s = "gordon/near_death.wav";
	else {
		if (targ.health < 51)
			s = "gordon/health_critical.wav";
		else if (targ.health < 71)
			s = "gordon/blood_loss.wav";
		if (attacker == world && targ.waterlevel > 0) {
			if (self.watertype == CONTENT_SLIME)
				s = "gordon/biohazard.wav";
			else if (self.watertype == CONTENT_LAVA)
				s = "gordon/heat_damage.wav";
		}
	}

	sound(targ, 5, s, 1, ATTN_NORM);
    targ.qccTauntTimer = time + 6;
};

// HEV Armor Pickup
void(entity collector, entity item) QCC_GordonItem = {
    string s;

    s = "";

    // Armor
    if (item.classname == "qcc_item_lightarmor" || item.classname == "qcc_item_heavyarmor" || item.classname == "item_cells") {
		if (collector.armorvalue == 175)
			s = "gordon/armor175.wav";
		else if (collector.armorvalue >= 150)
			s = "gordon/armor150.wav";
		else if (collector.armorvalue >= 125)
			s = "gordon/armor125.wav";
		else if (collector.armorvalue >= 100)
			s = "gordon/armor100.wav";
		else if (collector.armorvalue >= 75)
			s = "gordon/armor75.wav";
		else if (collector.armorvalue >= 50)
			s = "gordon/armor50.wav";
		else if (collector.armorvalue >= 25)
			s = "gordon/armor25.wav";
    }
    // Megahealth
    else if (item.classname == "item_health" && item.spawnflags & H_MEGA)
        s = "gordon/morphine.wav";
    // Powerups
    else if (item.classname == "item_artifact_super_damage")
        s = "gordon/adrenaline.wav";
    else if (item.classname == "item_artifact_invulnerability")
        s = "gordon/pain_block.wav";
    else if (item.classname == "item_artifact_envirosuit")
        s = "gordon/antitoxin.wav";

    if (s == "")
        return;
    
    sound(collector, 5, s, 1, ATTN_NORM);
}

/*
=====================================
BOT STUFF
=====================================
*/
void() QCC_GordonBotPre = {
	if (self.qccAbilityTimer < time && self.qccAbilityTimer >= 0) {
        // Gordon warp on hit
        if (self.took_damage == TRUE)
            QCC_FireAbility();
		if (self.enemy.flags & FL_MONSTER || self.enemy.classname == "player") {
			if (visible(self.enemy))
				ai_face();
				QCC_FireAbility();
		}
    }
};