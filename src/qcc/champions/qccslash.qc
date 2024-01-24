/*
======================================================
QCC: SLASH
======================================================
*/
void() QCC_SlashPreThink;
void() QCC_PlasmaTrail;
void() QCC_SlashBotPre;

void() QCC_Slash = {
	// Stats
	self.qccClass = QCC_LIGHT;
    self.qccAbilityFunc = QCC_PlasmaTrail;
    self.qccAbilityString = "Plasma Trail";
    self.qccMoveSpeed = 1.05;
    self.qccPreThink = QCC_SlashPreThink;
    self.qccBotPreThink = QCC_SlashBotPre;
	// Model
	setmodel(self, "progs/qcslash.mdl");
    QCC_SetSkin(2);
    self.qccGibSkins = self.qccMaxSkins;
	self.qccChampGib = "progs/h_qcslash.mdl";
	self.qccMeleeMdl = "progs/v_gaunt.mdl";
	// Sounds
	self.qccSndMelee = "weapons/gauntshot.wav";
    self.qccSndMeleeHit = "";
    self.qccSndMeleeWall = "player/axhit2.wav";
	self.qccSndJump = "slash/slashjump.wav";
	self.qccSndLand1 = "slash/slashland.wav";
	self.qccSndLand2 = "slash/slashland2.wav";
	self.qccSndPain1 = "slash/slashpain1.wav";
	self.qccSndPain2 = "slash/slashpain2.wav";
	self.qccSndPain3 = "slash/slashpain2.wav";
	self.qccSndPain4 = "slash/slashpain3.wav";
	self.qccSndPain5 = "slash/slashpain3.wav";
	self.qccSndPain6 = "slash/slashpain4.wav";
	self.qccSndDeath1 = "slash/slashdie1.wav";
	self.qccSndDeath2 = "slash/slashdie2.wav";
	self.qccSndDeath3 = "slash/slashdie3.wav";
	self.qccSndDeath4 = "slash/slashdie2.wav";
	self.qccSndDeath5 = "slash/slashdie3.wav";
	self.qccSndAxHit1 = "slash/slashpain4.wav";
	self.qccSndBurn1 = "slash/slashpain4.wav";
	self.qccSndBurn2 = "slash/slashpain4.wav";
	self.qccSndGasp1 = "slash/slashgasp1.wav";
	self.qccSndGasp2 = "slash/slashgasp2.wav";
	self.qccSndDrown1 = "player/drown1.wav";
	self.qccSndDrown2 = "player/drown1.wav";
	self.qccSndH2oDeath = "player/drown1.wav";
};

/*
=============================================
CROUCH SLIDE ANIMATIONS
=============================================
*/
// idle / move
void() slash_slide = [147, slash_slide] {
	if (self.th_run != slash_slide)
		self.th_run();
	
	self.weaponframe = 0;
	if (self.weapon == IT_AXE)
		self.frame = 143;
};

// Axe
void() slash_axeslide1 = [143, slash_axeslide2] {self.weaponframe = 1;};
void() slash_axeslide2 = [144, slash_axeslide3] {self.weaponframe = 2;};
void() slash_axeslide3 = [145, slash_axeslide4] {self.weaponframe = 3; W_FireAxe();};
void() slash_axeslide4 = [146, slash_slide] {self.weaponframe = 4;};

// Shotgun
void() slash_shotslide1 = [158, slash_shotslide2] {
	self.weaponframe = 1;
	self.effects = self.effects | EF_MUZZLEFLASH;
};
void() slash_shotslide2 = [159, slash_shotslide3] {self.weaponframe = 2;};
void() slash_shotslide3 = [160, slash_shotslide4] {self.weaponframe = 3;};
void() slash_shotslide4 = [161, slash_shotslide5] {self.weaponframe = 4;};
void() slash_shotslide5 = [162, slash_shotslide6] {self.weaponframe = 5;};
void() slash_shotslide6 = [163, slash_slide] {self.weaponframe = 6;};

// Nailgun
void() slash_nailslide1 = [148, slash_nailslide2] {
	if (self.qccAttackFunc != QCC_SlashAttack) {
		player_nail1();
		return;
	}
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	if (!self.button0) {
		slash_slide();
		return;
	}

	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;

	SuperDamageSound();
	W_FireSpikes (4);
	self.attack_finished = time + 0.2;
};

void() slash_nailslide2 = [149, slash_nailslide1] {
	if (self.qccAttackFunc != QCC_SlashAttack) {
		player_nail2();
		return;
	}

	self.effects = self.effects | EF_MUZZLEFLASH;

	if (!self.button0) {
		slash_slide();
		return;
	}

	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;

	SuperDamageSound();
	W_FireSpikes (-4);
	self.attack_finished = time + 0.2;
};

// Grenade / Rocket Launcher
void() slash_rockslide1 = [152, slash_rockslide2] {
	self.weaponframe = 1;
	self.effects = self.effects | EF_MUZZLEFLASH;
};
void() slash_rockslide2 = [153, slash_rockslide3] {self.weaponframe = 2;};
void() slash_rockslide3 = [154, slash_rockslide4] {self.weaponframe = 3;};
void() slash_rockslide4 = [155, slash_rockslide5] {self.weaponframe = 4;};
void() slash_rockslide5 = [156, slash_rockslide6] {self.weaponframe = 5;};
void() slash_rockslide6 = [157, slash_slide] {self.weaponframe = 6;};

// Lightning Gun
void() slash_lightslide1 = [150, slash_lightslide2] {
	if (self.qccAttackFunc != QCC_SlashAttack) {
		player_light1();
		return;
	}

	self.effects = self.effects | EF_MUZZLEFLASH;

	if (!self.button0) {
		slash_slide();
		return;
	}

	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;

	SuperDamageSound();
	W_FireLightning();
	self.attack_finished = time + 0.2;
};

void() slash_lightslide2 = [151, slash_lightslide1] {
	if (self.qccAttackFunc != QCC_SlashAttack) {
		player_light2();
		return;
	}

	self.effects = self.effects | EF_MUZZLEFLASH;

	if (!self.button0) {
		slash_slide();
		return;
	}

	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;

	SuperDamageSound();
	W_FireLightning();
	self.attack_finished = time + 0.2;
};

// Laser Cannon
void() slash_laserslide1 = [148, slash_laserslide2] {
	if (self.qccAttackFunc != QCC_SlashAttack) {
		player_laser1();
		return;
	}

	self.attack_finished = time + 0.1;
	self.weaponframe = 1;
	self.nextthink = time + 0.1;
	HIP_FireLaser(0);
};
void() slash_laserslide2 = [149, slash_laserslide3] {
	if (self.qccAttackFunc != QCC_SlashAttack) {
		player_laser2();
		return;
	}

	self.attack_finished = time + 0.1;
	self.weaponframe = 2;
	self.nextthink = time + 0.1;
};
void() slash_laserslide3 = [149, slash_laserslide4] {
	if (self.qccAttackFunc != QCC_SlashAttack) {
		player_laser3();
		return;
	}

	self.attack_finished = time + 0.1;
	self.weaponframe = 3;
	self.nextthink = time + 0.1;
	HIP_FireLaser(1);
};
void() slash_laserslide4 = [148, slash_laserslide1] {
	if (self.qccAttackFunc != QCC_SlashAttack) {
		player_laser4();
		return;
	}

	self.attack_finished = time + 0.1;
	self.weaponframe = 4;
	self.nextthink = time + 0.1;
};

void() QCC_SlashAttack = {
	if (W_HasNoAmmo())
		return;
	
	makevectors	(self.v_angle);		// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up
	
	// [NDS] haleyjd: record player attacked
	if (self.weapon != IT_AXE)
		self.fired_weapon = 1;

	if (self.weapon == IT_AXE) {
		sound(self, CHAN_WEAPON, self.qccSndMelee, 1, ATTN_NORM);
		slash_axeslide1();
		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == IT_SHOTGUN) {
		slash_shotslide1();
		W_FireShotgun();
		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN) {
		slash_shotslide1();
		W_FireSuperShotgun();
		self.attack_finished = time + 0.7;
	}
	else if (self.weapon == IT_NAILGUN || self.weapon == IT_SUPER_NAILGUN)
		slash_nailslide1();
	else if (self.weapon == IT_GRENADE_LAUNCHER && !(self.qccAltWeapon)) {
		slash_rockslide1();
		W_FireGrenade();
		self.attack_finished = time + 0.6;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER) {
		slash_rockslide1();
		W_FireRocket();
		self.attack_finished = time + 0.8;
	}
	else if (self.weapon == IT_LIGHTNING) {
		slash_lightslide1();
		self.attack_finished = time + 0.1;
		sound(self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
	// QCC
	else if (self.weapon == QCC_IT_RAILGUN) {
		slash_rockslide1();
		QCC_W_FireRail();
		self.attack_finished = time + 1.5;
	}
	// HIP
	else if (self.weapon == IT_LASER_CANNON)
		slash_laserslide1();
	else if (self.weapon == IT_PROXIMITY_GUN && self.qccAltWeapon == 1) {
		slash_rockslide1();
		W_FireProximityGrenade();
		self.attack_finished = time + 0.6;
	}
};

/*
=============================================
CROUCH SLIDE
=============================================
*/
void(float active) QCC_SlashSlideToggle = {
	if (active == FALSE) {
		self.th_run = player_run;
		self.th_stand = player_stand;
		self.qccAttackFunc = W_Attack;
		self.view_ofs = '0 0 22';
		return;
	}
	self.th_run = slash_slide;
	self.th_stand = slash_slide;
	self.qccAttackFunc = QCC_SlashAttack;
	self.view_ofs = '0 0 10';
}

void() QCC_SlashPreThink = {
	if (self.waterlevel > 1)
		self.qccSlideTime = 0;
	
	if (!self.button2 && self.qccSlideTime > time + 0.25)
		self.qccSlideTime = time + 0.25;

	if (self.flags & FL_ONGROUND) {
		if (self.qccSlideTime < time)
			self.qccMoveSpeed = 1.05;

		if (self.qccSlideTime > time && self.button2) {
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			if (self.view_ofs_z > 11) {
				sound(self, 7, "slash/slidestart.wav", 1, ATTN_NORM);
				QCC_SlashSlideToggle(TRUE);
			}
			else {
				if (self.qccTauntTimer < time && self.qccAbilityTimer > -1) {
					self.qccTauntTimer = time + 1.95;
					float r = random() * 5;
					if (r < 1)
						sound(self, CHAN_BODY, "slash/slideloop1.wav", 1, ATTN_NORM);
					else if (r < 2)
						sound(self, CHAN_BODY, "slash/slideloop2.wav", 1, ATTN_NORM);
					else if (r < 3) {
						sound(self, CHAN_BODY, "slash/slideloop3.wav", 1, ATTN_NORM);
						self.qccTauntTimer = time + 2.95;
					}
					else if (r < 4)
						sound(self, CHAN_BODY, "slash/slideloop4.wav", 1, ATTN_NORM);
					else
						sound(self, CHAN_BODY, "slash/slideloop5.wav", 1, ATTN_NORM);
				}
			}

			// Max Slide Speed is 680
			if (self.qccSlideTime > time + 1)
				self.qccMoveSpeed = 2.125;
			else
				self.qccMoveSpeed = 1.075 * (self.qccSlideTime - time) + 1.05;
		}
		else {
			if (self.view_ofs_z < 21) {
				if (self.qccSlideTime > time)
					self.qccSlideTime = time + 0.25;
				sound(self, CHAN_BODY, "slash/slidestop.wav", 1, ATTN_NORM);
				QCC_SlashSlideToggle(FALSE);
			}
			if (self.qccSlideTime + 0.25 < time)
				self.qccSlideTime = 0;
		}
	}
	else {
		if (self.button2)
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
		if (self.jump_flag < -50 && !self.button2) {
			self.qccSlideTime = time + (self.jump_flag / -2000) * 8 + 1;
			if (self.qccSlideTime > time + 6)
				self.qccSlideTime = time + 6;
		}
		if (self.view_ofs_z < 21)
			QCC_SlashSlideToggle(FALSE);
	}

	// Plasma Trail increases speed overall
	if (self.qccAbilityEnt != world) {
		if (self.qccAbilityEnt.qccAbilityTimer > time + 3) {
			if (self.flags & FL_ONGROUND)
				self.qccMoveSpeed += 0.25;
		}
	}

	// Max Speed is 700
	if (self.qccMoveSpeed > 2.1875)
		self.qccMoveSpeed = 2.1875;

	QCC_MovePreThink();
};

/*
=============================================
PLASMA TRAIL
=============================================
*/
void() ptrail_explode1 = [0, ptrail_explode2] {};
void() ptrail_explode2 = [1, ptrail_explode3] {};
void() ptrail_explode3 = [2, ptrail_explode4] {};
void() ptrail_explode4 = [3, ptrail_explode5] {};
void() ptrail_explode5 = [4, ptrail_explode6] {};
void() ptrail_explode6 = [5, SUB_Remove] {};

// Called by Plasma Trail entities
void() QCC_PlasmaTrailExplode = {		
	self.touch = SUB_Null;
	if (self.qccAbilityOwner.skin == 1)
		self.effects |= EF_PENTALIGHT;
	else if (self.qccAbilityOwner.skin == 3)
		self.effects |= EF_DIMLIGHT;
	else
		self.effects |= EF_QUADLIGHT;
	particle(self.origin, '0 0 0', 209, 100);
	setmodel(self, "progs/s_explod.spr");
	
	self.qccFlags = QCC_FL_ABILITY;
	T_RadiusDamage(self, self.owner, 50, self.owner);
	ptrail_explode1();
	
	if (self.qccAbilityEnt != world) {
		self.qccAbilityEnt.nextthink = time + 0.07;
		float r = random() * 5;
		if (r < 1)
			sound(self, 0, "slash/plaschain1.wav", 1, ATTN_NORM);
		else if (r < 2)
			sound(self, 0, "slash/plaschain2.wav", 1, ATTN_NORM);
		else if (r < 3)
			sound(self, 0, "slash/plaschain3.wav", 1, ATTN_NORM);
		else if (r < 4)
			sound(self, 0, "slash/plaschain4.wav", 1, ATTN_NORM);
		else
			sound(self, 0, "slash/plaschain5.wav", 1, ATTN_NORM);
	}
	else
		sound(self, 0, "slash/plasexp.wav", 1, ATTN_NORM);

	self.owner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
};

void() QCC_PlasmaTrailTouch = {
	if (other == self.owner)
		return;
	
	if (other.takedamage) {
		if (other.flags & FL_MONSTER)
			T_Damage(other, self, self.owner, 10);
		else
			T_Damage(other, self, self.owner, 1);
		SpawnBlood(other.origin, '0 0 0', 50);
	}
};

// Called by Plasma Trail Controller
void() QCC_PlasmaTrailProc = {
	if (self.owner.health <= 0) {
		if (self.owner.qccAbilityTimer < 0)
			self.owner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
		return;
	}

	entity ent;	
	ent = spawn();	
	setmodel(ent, "progs/w_plastrail.mdl");
	
	ent.solid = SOLID_TRIGGER;
	setsize(ent, '-20 -15 -15', '20 15 15');
	setorigin(ent, self.owner.origin);
	ent.angles = vectoangles(normalize(self.owner.velocity));
	
	ent.owner = self.owner;
	ent.touch = QCC_PlasmaTrailTouch;	
	ent.think = QCC_PlasmaTrailExplode;
	ent.nextthink = time + 6;

	// Chain the trail entities so that we can explode them in a chain rather than all at once
	if (self.lastvictim != world)
		self.lastvictim.qccAbilityEnt = ent;
	else
		self.qccAbilityEnt = ent;
	self.lastvictim = ent;

	if (self.qccAbilityTimer < time + 3) {
		if (self.qccAbilityTimer < time && self.owner.qccAbilityTimer < 0)
			self.owner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
		sound(self, CHAN_BODY, "slash/plasstop.wav", 1, ATTN_NORM);
		return;
	}
	
	self.think = QCC_PlasmaTrailProc;
	self.nextthink = time + 0.07;		
};

// called by Slash
void() QCC_PlasmaTrail = {
	if (self.qccAbilityTimer < 0) {		
		if (self.qccAbilityEnt != world) {
			self.qccAbilityEnt.qccAbilityEnt.nextthink = time;
			self.qccAbilityEnt.think = SUB_Remove;
			self.qccAbilityEnt.nextthink = time + 0.2;
		}
		self.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
		self.qccTauntTimer = time + 30;
		sound(self, CHAN_BODY, "slash/plasstop.wav", 1, ATTN_NORM);
		return;
	}

	self.qccAbilityTimer = -1;
	
	sound(self, 7, "slash/plasstart.wav", 1, ATTN_NORM);
	self.qccTauntTimer = time + 2.95;
	sound(self, CHAN_BODY, "slash/plasloop.wav", 1, ATTN_NORM);

	// Create plasma trail controller
	entity ent;
	ent = spawn();
	self.qccAbilityEnt = ent;
	ent.owner = self;
	ent.think = QCC_PlasmaTrailProc;
	ent.nextthink = time;
	ent.qccAbilityTimer = time + 6;

	self.qccTauntTimer = 0; // used for plasma trail loop sound
	if (random() < 0.5)
		sound(self, 6, "slash/slashab1.wav", 1, ATTN_NORM);
	else
		sound(self, 6, "slash/slashab2.wav", 1, ATTN_NORM);

};

/*
==========================================
BOT THINKS
==========================================
*/
void() QCC_SlashBotPre = {
	if (self.enemy.flags & FL_MONSTER || self.enemy.classname == "player") {
        if (self.qccAbilityTimer < time && self.qccAbilityTimer >= 0 && visible(self.enemy)) {
			// PlasmaTrail if in the same room
			if (range(self.enemy) <= RANGE_MID)
				QCC_FireAbility();
		}
	}
}