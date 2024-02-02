/*
======================================================
QCC: COMMANDER KEEN
======================================================
*/
void() QCC_KeenSkin;
void() QCC_PogoStick;
void() QCC_PogoTouch;
void() QCC_NeuralStunner;
void() QCC_KeenBotPre;

void() QCC_Keen = {
    // Stats
	self.qccClass = QCC_LIGHT;
	self.qccAbilityFunc = QCC_NeuralStunner;
	self.qccAbilityString = "Neural Stunner";
	self.qccAbilityCost = QCC_GLOBAL_COOLDOWN / 3;
	self.qccPostThink = QCC_PogoStick;
	self.qccBotPreThink = QCC_KeenBotPre;
	
	// Model
	setmodel(self, "progs/qckeen.mdl");
	self.qccChampGib = "progs/h_qckeen.mdl";
	self.qccMeleeMdl = "progs/v_pogo.mdl";
	QCC_SetSkin(10);
	self.qccGibSkins = self.qccMaxSkins;
    self.qccSkinFunc = QCC_KeenSkin;
	if (self.qccSkin == 2 || self.qccSkin == 3 || self.qccSkin == 6)
        setmodel(self, "progs/qckeen2.mdl");
	setsize(self, VEC_HULL_MIN, '16 16 13'); // Keen is so short!
	self.view_ofs = '0 0 10';
	self.qccFlags |= (QCC_FL_CUSTOM_SIZE | QCC_FL_CUSTOM_VIEW);
	
	// Sounds
	self.qccSndMelee = string_null;
	self.qccSndMeleeHit = "keen/jumpatk.wav";
	self.qccSndMeleeWall = string_null;
	self.qccSndJump = "keen/jump.wav";
	self.qccSndLand1 = "keen/land.wav";
	self.qccSndLand2 = "keen/land2.wav";
	self.qccSndPain1 = "keen/pain0.wav";
	self.qccSndPain2 = "keen/pain0.wav";
	self.qccSndPain3 = "keen/pain1.wav";
	self.qccSndPain4 = "keen/pain1.wav";
	self.qccSndPain5 = "keen/pain2.wav";
	self.qccSndPain6 = "keen/pain2.wav";
	self.qccSndDeath1 = "keen/death1.wav";
	self.qccSndDeath2 = "keen/death2.wav";
	self.qccSndDeath3 = "keen/death1.wav";
	self.qccSndDeath4 = "keen/death2.wav";
	self.qccSndDeath5 = "keen/death2.wav";
	self.qccSndAxHit1 = "keen/pain2.wav";
	self.qccSndBurn1 = "keen/pain2.wav";
	self.qccSndBurn2 = "keen/pain2.wav";
	self.qccSndGasp1 = string_null;
	self.qccSndGasp2 = string_null;
	self.qccSndDrown1 = "keen/pain0.wav";
	self.qccSndDrown2 = "keen/pain1.wav";
	self.qccSndH2oDeath = "keen/death1.wav";

	self.qccVictoryFrame = 143;

	if (time - self.ltime < 15) {
		if (self.qccSkin > 6) // Mortimer McMire!
			sound(self, CHAN_VOICE, "keen/mortstart.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_VOICE, "keen/start.wav", 1, ATTN_NORM);
	}
};

void() QCC_KeenSkin = {
	QCC_SwapSkin();
    self.qccSkin = self.qccSkin % self.qccMaxSkins;
    if (self.qccSkin != 2 && self.qccSkin != 3 && self.qccSkin != 6)
        setmodel(self, "progs/qckeen.mdl");
    else
        setmodel(self, "progs/qckeen2.mdl");
    self.modelindex_champ = self.modelindex;
    self.view_ofs = '0 0 10';
    self.velocity = '0 0 0';	// 1998-07-21 Player moves after respawn fix by Xian
    setsize(self, VEC_HULL_MIN, '16 16 13'); // Keen is so short!
    self.skin = self.qccSkin;

	if (time - self.ltime < 15) {
		if (self.qccSkin > 6) // Mortimer McMire!
			sound(self, CHAN_VOICE, "keen/mortstart.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_VOICE, "keen/start.wav", 1, ATTN_NORM);
	}
};

/*
==========================================
POGO STICK
==========================================
*/
void() QCC_PogoTouch = {
	if (other.takedamage != DAMAGE_AIM)
		return;
	
	vector org;
	org = other.origin;
	org_z += other.maxs_z + 16;
	
	if (other.takedamage == DAMAGE_AIM && self.velocity_z < 0 && self.origin_z > org_z) {
		T_Damage(other, self, self, 70);
		SpawnBlood(org, self.velocity, 70);
		sound(self, CHAN_WEAPON, "keen/jumpatk.wav", 1, ATTN_NORM);
		self.flags |= FL_ONGROUND;
	}
};

void() QCC_PogoStick = {
	QCC_MovePostThink();

	if (self.weapon == IT_AXE) {
		// Firing your weapon or entering water switches away from the Pogo Stick
		if (self.button0 || self.waterlevel > 0) {
			if (self.qccPrevWep == IT_AXE)
				self.qccPrevWep = W_BestWeapon();		
			QCC_RestoreWeapon();
			self.attack_finished = time + 0.25;
			self.qccDoubleJump = 0;
			return;
		}

		self.touch = QCC_PogoTouch;

		if (self.flags & FL_ONGROUND) {
			// Bounce height control
			if (self.button2)
				self.velocity_z = self.velocity_z + 540;
			else
				self.velocity_z = self.velocity_z + 270;
			sound(self, CHAN_BODY, "keen/pogo.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_ONGROUND;
		}
		else {
			// Air control on Pogo stick
			vector vel, rot;
			float spd;

			vel = self.velocity;
			vel_z = 0;
			spd = vlen(vel);
			rot = self.angles;
			rot_x = 0;
			makevectors(rot);

			if (spd < 360)
				spd += 150 * qccDeltaTime;
			
			vel = v_forward * spd;
			self.velocity_x = vel_x;
			self.velocity_y = vel_y;
		}
		self.qccDoubleJump = 1;
		return;
	}
	else {
		self.qccDoubleJump = 0;
		self.touch = SUB_Null;
	}

	if (self.button2 && !(self.flags & FL_ONGROUND) && (self.flags & FL_JUMPRELEASED) && !self.waterlevel && self.weapon != IT_AXE) {
		self.qccPrevWep = self.weapon;
		self.weapon = IT_AXE;
		W_SetCurrentAmmo();
	}
};

/*
==========================================
NEURAL STUNNER
==========================================
*/
// called by monsters
void() QCC_StunProc = [0, QCC_StunProc] {
	self.walkframe++;
	if (self.walkframe > 3)
		self.walkframe = 0;
	self.frame = self.walkframe;

	self.enemy = world;

	if (self.qccStunned < time) {
		self.attack_finished = 0;
		if (self.th_run)
			self.th_run();
		else if (self.th_stand)
			self.th_stand();
	}
};

// called by projectile
void() keenproj0 = [0, keenproj1] {self.effects |= EF_PENTALIGHT;};
void() keenproj1 = [1, keenproj2] {self.effects |= EF_PENTALIGHT;};
void() keenproj2 = [2, keenproj3] {self.effects |= EF_PENTALIGHT;};
void() keenproj3 = [3, keenproj4] {self.effects |= EF_PENTALIGHT;};
void() keenproj4 = [4, keenproj5] {self.effects |= EF_PENTALIGHT;};
void() keenproj5 = [5, keenproj0] {self.effects |= EF_PENTALIGHT;};

void() QCC_KeenProjectileTouch = {
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
	
	if (other.takedamage) {
		if (other.qccStunned < time)
			other.qccStunned = time + 2;
		else
			other.qccStunned += 2;
		other.velocity = '0 0 0';
		other.pain_finished = 0;

		if (other.flags & FL_MONSTER) {
			T_Damage(other, self, self.owner, 75);
			if (other.health > 0) {
				other.pain_finished = other.qccStunned;
				if (other.classname == "monster_boss")
					other.think = boss_shockz1;
				else if (other.classname != "monster_oldone")
					other.think = QCC_StunProc;
				other.nextthink = time + 0.01;
			}
		}
		else if (other.flags & FL_CLIENT) {
			if (!teamplay || other.team != self.owner.team) {
				other.attack_finished = time + 1;
				T_Damage(other, self, self.owner, 25);
			}
		}
		else
			T_Damage(other, self, self.owner, 100);
	}

	particle(self.origin, self.velocity*0.1, 241, 50);
	sound(self, CHAN_WEAPON, "keen/rayhit.wav", 1, ATTN_NORM);
	remove(self);
};

// called by Keen
void() keenshot0 = [144, keenshot1] {self.weaponframe=0;};
void() keenshot1 = [144, keenshot2] {
	self.weaponframe=1;
	self.effects |= EF_MUZZLEFLASH;
	sound(self, CHAN_WEAPON, "keen/rayshoot.wav", 1, ATTN_NORM);
	
	newmis = spawn();
	newmis.classname = "keenshot";
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.effects |= EF_PENTALIGHT;
	setmodel(newmis, "progs/s_keenshot.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.touch = QCC_KeenProjectileTouch;

	setorigin(newmis, self.origin + v_forward * 8 + self.view_ofs - '0 0 6');
	makevectors(self.v_angle);
	newmis.velocity = aim(self, 620);
	newmis.velocity = newmis.velocity * 620;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.think = keenproj1;
	newmis.nextthink = time + 0.1;
};
void() keenshot2 = [145, keenshot3] {self.weaponframe=2;};
void() keenshot3 = [146, keenshot4] {self.weaponframe=3;};
void() keenshot4 = [147, keenshot5] {self.weaponframe=4;};
void() keenshot5 = [148, keenshot6] {self.weaponframe=5;};
void() keenshot6 = [144, self.th_stand] {
	QCC_RestoreWeapon();
	self.th_pain = player_pain;
};

void() QCC_NeuralStunner = {
	QCC_AbilityUsed();
	self.weapon = QCC_ABILITY;
    self.currentammo = 3 - ceil((self.qccAbilityTimer - time) / self.qccAbilityCost);
	self.weaponmodel = "progs/v_keenray.mdl";
	self.weaponframe = 0;
	self.attack_finished = time + 0.7;
	self.th_pain = SUB_NullPain;
	keenshot0();
};

/*
=================================
BOT STUFF
=================================
*/
void() QCC_KeenBotPre = {
    if (self.enemy.flags & FL_MONSTER || self.enemy.classname == "player") {
        if ((self.qccAbilityTimer < time + QCC_GLOBAL_COOLDOWN - self.qccAbilityCost) && visible(self.enemy)) {
            // Make sure we only neural stun at mid or close range
            if (range(self.enemy) < RANGE_FAR)
                QCC_FireAbility();
        }
    }
};