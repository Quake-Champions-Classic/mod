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
	self.qccSndGasp2 = "gordon/breathe2.wav";
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
	self.nextthink = 0.0167;
};

void() s_hltele2_proc = [0, s_hltele2_proc] {
	self.walkframe += 1;
	if (self.walkframe > 18) {
		remove(self);
		return;
	}
	self.frame = self.walkframe;
	self.nextthink = 0.0167;
};

void(vector org) QCC_ResonanceParticles = {
	// vector vel;
	// vel_x = -50;
	// while (vel_x <= 50) {
	// 	vel_y = -50;
	// 	while (vel_y <= 50) {
	// 		vel_z = -50;
	// 		while (vel_z <= 50) {
	// 			particle(org, vel, 241, 10);
	// 			vel_z += 25;
	// 		}
	// 		vel_y += 25;
	// 	}
	// 	vel_x += 25;
	// }
};

// called by Ability Object
void() QCC_ResonanceWarp = {
	entity ent;

	// Teleport FX start pos
	sound(self.qccAbilityOwner, 6, "gordon/beamstart2.wav", 0.6, ATTN_NORM);
	ent = spawn();
	setmodel(ent, "progs/qchltele1.spr");
	ent.effects |= EF_DIMLIGHT;
	setorigin(ent, self.qccAbilityOwner.origin);
	ent.think = s_hltele1_proc;
	ent.nextthink = 0.0167;

	// Teleport FX end pos
	QCC_ResonanceParticles(self.origin);
	sound(self, 6, "gordon/beamstart7.wav", 0.6, ATTN_NORM);
	ent = spawn();
	setmodel(ent, "progs/qchltele2.spr");
	ent.effects |= EF_DIMLIGHT;
	setorigin(ent, self.origin);
	ent.think = s_hltele2_proc;
	ent.nextthink = 0.0167;

	// Teleport Gordon
	ent = self.qccAbilityOwner;
	
	QCC_ResonanceFlash(ent);
	spawn_tdeath(self.origin, ent);
	makevectors(self.mangle);

	setorigin(ent, self.origin);
	ent.fixangle = 1;
	ent.teleport_time = time + 0;
	ent.angles = self.mangle;
	ent.velocity = v_forward * 100;
	
	if (!coop && !deathmatch)
		FogPushSettingsFrom(ent, self, 0);
	
	ent.flags -= (self.flags & FL_ONGROUND);
	ent.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
	remove(self);
};

void() QCC_ResonanceProc = {
	// Check if dead
	if (self.qccAbilityOwner.deadflag >= DEAD_DYING) {
		self.qccAbilityOwner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
		remove(self);
		return;
	}

	if (self.qccAbilityTimer < time) {
		QCC_ResonanceWarp();
		return;
	}
	if (self.qccAbilityTimer < time + 0.01)
		spawn_tdeath(self.origin, self.qccAbilityOwner);

	self.nextthink = time + 0.01;
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
	self.qccAbilityEnt.movetype = MOVETYPE_NONE;
	self.qccAbilityEnt.solid = SOLID_NOT;
	self.qccAbilityEnt.qccAbilityOwner = self;
	self.qccAbilityEnt.angles = self.angles;
	setsize(self.qccAbilityEnt, '0 0 0', '0 0 0');
	setorigin(self.qccAbilityEnt, self.origin);

	// Check if we targeted somebody we can kill
	makevectors(self.v_angle);
	org = self.origin;
	traceline(org, org + v_forward * 4096, 0, self);
	if ((trace_ent.flags & FL_MONSTER || trace_ent.classname == "player") && trace_ent.health > 0 && trace_ent != self) {
		setorigin(self.qccAbilityEnt, trace_ent.origin);
		self.qccAbilityEnt.angles = self.angles;
	}
	// Find the farthest spawn point or teleport destination if no target
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
					self.qccAbilityEnt.angles = ent.angles;
				}
			}
			ent = nextent(ent);
		}
	}

	// Delay the warp, to give opponents a bit of warning
	self.qccAbilityEnt.qccAbilityTimer = time + 2.5;
	self.qccAbilityEnt.think = QCC_ResonanceProc;
	self.qccAbilityEnt.nextthink = time + 0.1;

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
void(entity targ, entity inflictor) QCC_GordonDamaged = {
	string s = "";

	if (targ.health < 21)
		s = "gordon/near_death.wav";
	else if (targ.qccTauntTimer < time) {
		// Player Weapons
		if (inflictor.classname == "player" || inflictor.classname == "monster_gremlin") {
			if (inflictor.weapon == QCC_ABILITY) {
				s = "gordon/blood_loss.wav";
			}
			else if (inflictor.weapon == QCC_IT_HEAVYMACHINEGUN || inflictor.weapon == QCC_IT_RAILGUN || 
				inflictor.weapon == IT_SHOTGUN || inflictor.weapon == IT_SUPER_SHOTGUN) {
				s = "gordon/blood_loss.wav";
			}
			else if (inflictor.weapon == IT_LIGHTNING)
				s = "gordon/shock_damage.wav";
			else if (inflictor.weapon == IT_AXE) {
				if (inflictor.qccChampion == QCC_DOOMSLAYER || inflictor.qccChampion == QCC_DUKENUKEM || 
					inflictor.qccChampion == QCC_KEEN || inflictor.qccChampion == QCC_GORDONFREEMAN) {
					s = "gordon/blood_loss.wav";
				}
				else
					s = "gordon/major_lacerations.wav";
			}
		}
		else if (inflictor.classname == "missile" || inflictor.classname == "grenade" || inflictor.classname == "proximity_grenade" || 
					inflictor.classname == "keelgrenade" || inflictor.classname == "keelminigrenade" || 
					inflictor.classname == "MiniGrenade" || inflictor.classname == "MultiRocket") {
				s = "gordon/blood_loss.wav";
		}
		else if (inflictor.classname == "spike" || inflictor.classname == "super_spike") {
			s = "gordon/major_lacerations.wav";
		}
		// Environment
		if (inflictor == world) {
			if (targ.waterlevel > 0) {
				if (self.watertype == CONTENT_SLIME)
				s = "gordon/biohazard.wav";
				else if (self.watertype == CONTENT_LAVA)
				s = "gordon/heat_damage.wav";
			}
			else {
				if (self.jump_flag < -650)
				s = "gordon/minor_fracture.wav";
			}
		}
		// Monsters (mostly)
		else if (inflictor.flags & FL_MONSTER) {
			if (inflictor.classname == "monster_army" || 
				inflictor.classname == "monster_zombie" || 
				inflictor.classname == "monster_fish" || 
				inflictor.classname == "monster_mummy" || 
				inflictor.classname == "monster_morph" || 
				inflictor.classname == "monster_armagon" || 
				inflictor.classname == "monster_death_monger" || 
				inflictor.classname == "monster_volkerh") {
				if (targ.armorvalue < 1)
					s = "gordon/armor0.wav";
				else
					s = "gordon/blood_loss.wav";
			}
			else if (inflictor.classname == "monster_shambler") {
				if (inflictor.frame < 69)
					s = "gordon/major_lacerations.wav";
				else
					s = "gordon/shock_damage.wav";
			}
			else if (inflictor.classname == "monster_tarbaby")
				s = "gordon/biohazard.wav";
			else if (inflictor.classname == "monster_eel" || inflictor.classname == "monster_dragon")
				s = "gordon/shock_damage.wav";
			else if (inflictor.classname == "monster_goroth")
				s = "gordon/heat_damage.wav";
			else if (inflictor.classname == "monster_volkerh" && inflictor.frame > 92 && inflictor.frame < 100)
				s = "gordon/shock_damage.wav";
			else if (targ.armorvalue < 1)
				s = "gordon/armor0.wav";
			else
				s = "gordon/major_lacerations.wav";
		}
		else if (inflictor.classname == "wizard_spike" || inflictor.classname == "acidspit") {
			s = "gordon/biohazard.wav";
		}
		else if (inflictor.classname == "knight_spike" || inflictor.classname == "enforcer_laser" || 
			inflictor.classname == "lavaball" || inflictor.classname == "lava_spike" || 
			inflictor.classname == "flamestrike" || 
			inflictor.classname == "fireball" || inflictor.classname == "lavaman_ball" || 
			inflictor.classname == "chthon_lavaball") {
			s = "gordon/heat_damage.wav";
		}
		else if (inflictor.classname == "plasma" || inflictor.classname == "plasmatrail") {
			s = "gordon/shock_damage.wav";
		}
		else if (targ.armorvalue < 1)
			s = "gordon/armor0.wav";
		else
			s = "gordon/blood_loss.wav";

		if (targ.health < 41)
			s = "gordon/health_critical.wav";
	}

	if (s == "")
		return;

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
		else if (collector.armorvalue >= 15)
			s = "gordon/armor15.wav";
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