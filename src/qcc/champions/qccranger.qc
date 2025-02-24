/*
======================================================
QCC: RANGER
======================================================
*/
void() QCC_DireOrbThrow;
void() QCC_RangerBotPre;

void() QCC_Ranger = {
	// Stats
	self.qccClass = QCC_MEDIUM;
	self.qccAbilityFunc = QCC_DireOrbThrow;
	self.qccAbilityString = "Dire Orb";
	self.qccBotPreThink = QCC_RangerBotPre;
	self.qccSelfDamage = 0.25;
	// Model
	setmodel(self, "progs/qcranger.mdl");
	self.qccChampGib = "progs/h_player.mdl";
	self.qccMeleeMdl = "progs/v_axe.mdl";
	QCC_SetSkin(8);
	// Sounds
	self.qccSndMelee = "weapons/ax1.wav";
	self.qccSndMeleeHit = "";
	self.qccSndMeleeWall = "player/axhit2.wav";
	self.qccSndJump = "player/plyrjmp8.wav";
	self.qccSndLand1 = "player/land.wav";
	self.qccSndLand2 = "player/land2.wav";
	self.qccSndPain1 = "player/pain1.wav";
	self.qccSndPain2 = "player/pain2.wav";
	self.qccSndPain3 = "player/pain3.wav";
	self.qccSndPain4 = "player/pain4.wav";
	self.qccSndPain5 = "player/pain5.wav";
	self.qccSndPain6 = "player/pain6.wav";
	self.qccSndDeath1 = "player/death1.wav";
	self.qccSndDeath2 = "player/death2.wav";
	self.qccSndDeath3 = "player/death3.wav";
	self.qccSndDeath4 = "player/death4.wav";
	self.qccSndDeath5 = "player/death5.wav";
	self.qccSndAxHit1 = "player/axhit1.wav";
	self.qccSndBurn1 = "player/lburn1.wav";
	self.qccSndBurn2 = "player/lburn2.wav";
	self.qccSndGasp1 = "player/gasp1.wav";
	self.qccSndGasp2 = "player/gasp2.wav";
	self.qccSndDrown1 = "player/drown1.wav";
	self.qccSndDrown2 = "player/drown2.wav";
	self.qccSndH2oDeath = "player/h2odeath.wav";
};

/*
======================================================
QCC: DIRE ORB
======================================================
*/
void() QCC_DireOrbExplosion;

void() QCC_DireOrbCheck = {
	if (self.owner.deadflag >= DEAD_DEAD)
		QCC_DireOrbExplosion();
};

void() dorb_fly1 = [0, dorb_fly2] {QCC_DireOrbCheck();};
void() dorb_fly2 = [1, dorb_fly3] {QCC_DireOrbCheck();};
void() dorb_fly3 = [2, dorb_fly4] {QCC_DireOrbCheck();};
void() dorb_fly4 = [3, dorb_fly5] {QCC_DireOrbCheck();};
void() dorb_fly5 = [4, dorb_fly6] {QCC_DireOrbCheck();};
void() dorb_fly6 = [3, dorb_fly7] {QCC_DireOrbCheck();};
void() dorb_fly7 = [2, dorb_fly8] {QCC_DireOrbCheck();};
void() dorb_fly8 = [1, dorb_fly1] {QCC_DireOrbCheck();};

void() dorb_x1 = [0, dorb_x2] {};
void() dorb_x2 = [1, dorb_x3] {};
void() dorb_x3 = [2, dorb_x4] {};
void() dorb_x4 = [3, dorb_x5] {};
void() dorb_x5 = [4, dorb_x6] {};
void() dorb_x6 = [3, dorb_x7] {};
void() dorb_x7 = [2, dorb_x8] {};
void() dorb_x8 = [1, QCC_DireOrbExplosion] {};

// Called by Orb
void() QCC_DireOrbExplosion = {
	self.owner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	self.effects |= EF_QUADLIGHT;
	setmodel(self, "progs/s_explod.spr");
	
	T_RadiusDamage(self, self.owner, 50, self.owner);
	
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	
	s_explode1 ();
};

// Called by Orb
void() QCC_DireOrbTouch = {
	if (other == self.owner)
		return;		// don't explode on owner
	
	if (pointcontents(self.origin) == CONTENT_SKY) {
		self.owner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
		remove(self);
		return;
	}
	
	// sound(self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	
	self.origin = self.origin - 8*normalize(self.velocity);
	
	if (other.health) {
		spawn_touchblood(15);
		T_Damage(other, self, self.owner, 15);
	}
	
	// Only explode if we hit a wall
	if (other.classname == "worldspawn") {
		self.movetype = MOVETYPE_NONE;
		dorb_x1();
	}
};

// Called by Ranger
// shows Ranger's arm throw out the orb
void() QCC_DireOrbAnimProc = [144, QCC_DireOrbAnimProc] {
	if (self.walkframe > 4) {
		self.weaponframe = 0;
		self.walkframe = 0;
		self.th_pain = player_pain;
		QCC_RestoreWeapon();
		self.th_run();
	}
	else {
		self.frame = self.frame + self.walkframe;
		self.weaponframe = self.walkframe;
		// Actual warp is delayed so we don't have collision issues on a perfect orb
		if (self.walkframe == 1) {
			vector aVec;	
			makevectors(self.qccAbilityEnt.mangle);	
			aVec = self.qccAbilityEnt.origin;
			float i = 0;
			while (i < 6) {
				vector vCheck;
				if (i < 2)
					vCheck = v_forward * 32;
				if (i > 1 && i < 4)
					vCheck = v_up * 32;
				if (i > 3)
					vCheck = v_right * 32;
				if (i == 1 || i == 3 || i == 5)
					vCheck = vCheck - vCheck * 2;
				traceline(aVec, aVec + vCheck, TRUE, self);
				if (trace_fraction < 1)
					aVec = aVec - vCheck;
				i = i + 1;
			}
			spawn_tfog(self.origin);
			setorigin(self,aVec);
			self.teleport_time = time + 0;
			self.flags -= self.flags & FL_ONGROUND;
		}
	}
	self.walkframe = self.walkframe + 1;
	self.nextthink = 0.02;
}

void(entity attacker, float damage) QCC_DireOrbPain = {PainSound();};

void() QCC_DireOrbAnim = {
	self.walkframe = 0;
	self.weapon = QCC_ABILITY;
	self.weaponmodel = "progs/v_dorb.mdl";
	self.weaponframe = 0;
	self.attack_finished = time + 0.1;
	self.show_hostile = time + 1;	// wake monsters up
	self.th_pain = QCC_DireOrbPain;
	QCC_DireOrbAnimProc();
}

// Called by Ranger
void() QCC_DireOrbWarp = {
	QCC_DireOrbAnim();
	
	vector aVec;	
	makevectors(self.qccAbilityEnt.mangle);	
	aVec = self.qccAbilityEnt.origin;
	float i;
	i = 0;
	while (i < 6) {
		vector vCheck;
		if (i < 2)
			vCheck = v_forward * 32;
		if (i > 1 && i < 4)
			vCheck = v_up * 32;
		if (i > 3)
			vCheck = v_right * 32;
		if (i == 1 || i == 3 || i == 5)
			vCheck = vCheck - vCheck * 2;
		traceline(aVec, aVec + vCheck, TRUE, self);
		if (trace_fraction < 1)
			aVec = aVec - vCheck;
		i = i + 1;
	}

	spawn_tfog(self.origin);
	spawn_tdeath(aVec, self);
	
	i = 0;
	while (i < 4) {
		vector offset;
		if (i == 0)
			offset = v_forward * 3;
		if (i == 1)
			offset = v_forward * -3;
		if (i == 2)
			offset = v_right * 3;
		if (i == 3)
			offset = v_right * -3;
		spawn_tfog(aVec + offset);
		i = i + 1;
	}

	self.qccAbilityEnt.nextthink = time + 0;
	self.qccAbilityEnt.think = QCC_DireOrbExplosion;
	if (!coop && !deathmatch)
		FogPushSettingsFrom(self, self.qccAbilityEnt, 0);
	self.qccAbilityTimer = 0;
};

void() QCC_DireOrbActivate = {

};

// Called by Ranger
void() QCC_DireOrbThrow = {
	if (self.qccAbilityTimer < 0) {		
		QCC_DireOrbWarp();
		return;
	}
	
	sound(self, CHAN_WEAPON, "misc/r_tele2.wav", 1, ATTN_NORM);
	QCC_DireOrbAnim();
	
	self.qccAbilityTimer = -1;
	
	self.qccAbilityEnt = spawn();
	self.qccAbilityEnt.classname = "direorb";
	self.qccAbilityEnt.owner = self;
	self.qccAbilityEnt.qccFlags = QCC_FL_ABILITY;
	self.qccAbilityEnt.movetype = MOVETYPE_FLY;
	self.qccAbilityEnt.solid = SOLID_TRIGGER;
	self.qccAbilityEnt.effects |= EF_QUADLIGHT;
	setmodel(self.qccAbilityEnt, "progs/w_dorb.mdl");
	setsize(self.qccAbilityEnt, '0 0 0', '0 0 0');
	
	self.qccAbilityEnt.touch = QCC_DireOrbTouch;
	
	// set orb movement
	setorigin(self.qccAbilityEnt, self.origin + v_forward * 8 + '0 0 16');
	makevectors(self.qccAbilityEnt.owner.v_angle);
	self.qccAbilityEnt.velocity = aim(self.qccAbilityEnt.owner, 620);
	self.qccAbilityEnt.velocity = self.qccAbilityEnt.velocity * 620;
	self.qccAbilityEnt.angles = vectoangles(self.qccAbilityEnt.velocity);
	
	// set orb animation
	self.qccAbilityEnt.think = dorb_fly2;
	self.qccAbilityEnt.nextthink = time + 0.1;
};

/*
=====================================
BOT STUFF
=====================================
*/
void() QCC_RangerBotPre = {
	entity head;
	
	if (self.enemy.flags & FL_MONSTER || self.enemy.classname == "player") {
        if (self.qccAbilityTimer < time && self.qccAbilityTimer >= 0 && visible(self.enemy)) {
            // Ranger dire orbs anywhere
            if (self.frame < 144)
                QCC_FireAbility();
		}
        else if (self.qccAbilityTimer < 0) {
            // Ranger Warp if Dire Orb is close enough
			if (self.frame < 144) {
                head = findradius(self.qccAbilityEnt.origin, 32);
                while (head) {
                    if (deathmatch && head.classname == "player") {
						QCC_FireAbility();
						return;
					}
                    else if ((teamplay || deathmatch >= QCC_TDM) && head.team != self.team) {
                        if ((head.flags & FL_MONSTER) || head.classname == "player") {
                                QCC_FireAbility();
                                return;
                        }
					}
                    head = head.chain;
                }    
            }
        }
    }
};