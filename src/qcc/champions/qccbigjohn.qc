/*
======================================================
QCC: BIG JOHN
======================================================
*/
void() QCC_BigBarrage;
void() QCC_BigJohnBotPre;

void(entity attacker, float damage) bigjohn_pain = {
	if (self.pain_finished > time)
		return;
	player_pain(attacker, damage);
	self.pain_finished = time + 3;
}

void() QCC_BigJohn = {
	// Stats
	self.qccClass = QCC_HEAVY;
	self.qccAbilityFunc = QCC_BigBarrage;
	self.qccAbilityString = "Big Barrage";
	self.qccFlags |= QCC_FL_STOCKPILE;
	self.qccBotPreThink = QCC_BigJohnBotPre;
	self.qccMoveSpeed = 0.9375;
	self.th_pain = bigjohn_pain;
	// Model
	setmodel(self, "progs/qcbigjohn.mdl");
    setsize(self, '-16 -24 -24', '16 24 40');
    self.view_ofs = '0 0 26';
    self.qccFlags |= (QCC_FL_CUSTOM_SIZE | QCC_FL_CUSTOM_VIEW);
	self.qccChampGib = "progs/h_qcbigjohn.mdl";
	self.qccMeleeMdl = "progs/v_gaunt.mdl";
	QCC_SetSkin(5);
	self.qccGibSkins = self.qccMaxSkins;
	// Sounds
	self.qccSndMelee = "weapons/gauntshot.wav";
    self.qccSndMeleeHit = "";
    self.qccSndMeleeWall = "player/axhit2.wav";
	self.qccSndJump = "bigjohn/bigjjump.wav";
	self.qccSndLand1 = "bigjohn/bigjland.wav";
	self.qccSndLand2 = "bigjohn/bigjland2.wav";
	self.qccSndPain1 = "bigjohn/bigjpain1.wav";
	self.qccSndPain2 = "bigjohn/bigjpain2.wav";
	self.qccSndPain3 = "bigjohn/bigjpain3.wav";
	self.qccSndPain4 = "bigjohn/bigjpain4.wav";
	self.qccSndPain5 = "bigjohn/bigjpain5.wav";
	self.qccSndPain6 = "bigjohn/bigjpain6.wav";
	self.qccSndDeath1 = "bigjohn/bigjdeath1.wav";
	self.qccSndDeath2 = "bigjohn/bigjdeath2.wav";
	self.qccSndDeath3 = "bigjohn/bigjdeath3.wav";
	self.qccSndDeath4 = "bigjohn/bigjdeath1.wav";
	self.qccSndDeath5 = "bigjohn/bigjdeath2.wav";
	self.qccSndAxHit1 = "bigjohn/bigjaxhit.wav";
	self.qccSndBurn1 = "bigjohn/bigjburn1.wav";
	self.qccSndBurn2 = "bigjohn/bigjburn2.wav";
	self.qccSndGasp1 = "silence.wav";
	self.qccSndGasp2 = "silence.wav";
	self.qccSndDrown1 = "player/drown1.wav";
	self.qccSndDrown2 = "player/drown2.wav";
	self.qccSndH2oDeath = "player/h2odeath.wav";

	if (time - self.ltime < 15)
		localsound(self, "bigjohn/bigjabl1.wav");
};

/*
=============================
BIG BARRAGE
=============================
*/

// Separate death animation if killed while using ability
void() bigjohn_die =[148, bigjohn_die2] {
	self.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN - self.currentammo / 2;
	self.walkframe = 148;
	
	// QCC --------------------------------------------
	// Drop powerups
	if (self.items & IT_INVULNERABILITY)
		QCC_ThrowPowerup(IT_INVULNERABILITY);
	if (self.items & IT_QUAD)
		QCC_ThrowPowerup(IT_QUAD);
	if (self.items & IT_INVISIBILITY)
		QCC_ThrowPowerup(IT_INVISIBILITY);
	// ------------------------------------------------

	self.items = self.items - (self.items & (IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD));
	self.invisible_finished = 0;	// don't die as eyes
	self.invincible_finished = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.effects = 0;
	self.modelindex = self.modelindex_champ;	// don't use eyes

	// HIP: JIM ----------------------------
	self.wetsuit_finished = 0;
   	self.empathy_finished = 0;
   	self.items2 = self.items2 - (self.items2 & HIP_IT_EMPATHY_SHIELDS);
	// -------------------------------------

	// ROGUE -------------------------------
	self.gravity = 1.0;
	self.shield_finished = 0;
	self.antigrav_finished = 0;
	// -------------------------------------

	if (deathmatch || coop) {
		DropBackpack();
		// QCC: Throw armorshards -------------------
		QCC_ThrowArmorshard();
		QCC_ThrowArmorshard();
		// ------------------------------------------
	}
	
	self.weaponmodel = string_null;
	self.view_ofs = '0 0 -8';
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.movetype = MOVETYPE_TOSS;

	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random() * 300;

	DeathSound();
	
	self.angles_x = 0;
	self.angles_z = 0;
};

void() bigjohn_die2 =[149, bigjohn_die2] {
	self.walkframe += 1;
	if (self.walkframe > 155) {
		self.health = -99;
		GibPlayer();
		self.think = PlayerDead;
		return;
	}
	self.frame = self.walkframe;
};

void() bigjohnshot_touch = {
	if (other == self.owner)
		return;
	if (other.solid == SOLID_TRIGGER)
		return;
	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}
	
	if (other.takedamage) {
		float damg = 25;
		spawn_touchblood(damg);
		if ((other.flags & FL_MONSTER)) {
			damg *= 2;
			if (other.health - damg < 1 || (self.super_damage_finished > time && other.health - damg * 4 < 1)) // always gib on kill
				other.health = -99;
			T_Damage(other, self, self.owner, damg);
		}
		else {
			if ((other.flags & FL_CLIENT) && (other.health - damg < 1)) // always gib on kill
				other.health = -99;
			T_Damage(other, self, self.owner, damg);
		}
	}
	else {
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_SPIKE);        
		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
	}

	remove(self);
};

void() bigjohn_ability5;
void() bigjohn_ability0 = [143, bigjohn_ability1] {self.weaponframe = 0;};
void() bigjohn_ability1 = [144, bigjohn_ability2] {self.weaponframe = 1;};
void() bigjohn_ability2 = [145, bigjohn_ability3] {self.weaponframe = 2;};

void() bigjohn_ability3 = [146, bigjohn_ability4] {
	self.nextthink = 0.08;
	self.weaponframe = 3;
	self.currentammo -= 1;	

	entity missile;
	sound(self, CHAN_WEAPON, "bigjohn/bigjfire.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "bigjohnshot";
	makevectors(self.v_angle);
	missile.velocity = aim(self, 1000);
	missile.velocity_x += crandom() * 0.5;
	missile.velocity_y += crandom() * 0.5;
	missile.velocity_z += crandom() * 0.25;
	missile.velocity = normalize(missile.velocity) * 1000;
	missile.angles = vectoangles(missile.velocity);	
	missile.touch = bigjohnshot_touch;	
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;
	setmodel(missile, "progs/w_bigjshot.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, self.origin + v_forward * 8 + self.view_ofs - '0 0 6');
	missile.qccFlags |= QCC_FL_CANDEFLECT;
};

void() bigjohn_ability4 = [147, bigjohn_ability3] {
	if (self.currentammo <= 0) {
		self.think = bigjohn_ability5;
	}
	self.nextthink = 0.08;
};

void() bigjohn_ability5 = [145, bigjohn_ability6] {self.weaponframe = 2;};
void() bigjohn_ability6 = [144, bigjohn_ability7] {self.weaponframe = 1;};
void() bigjohn_ability7 = [143, bigjohn_ability8] {self.weaponframe = 0;};
void() bigjohn_ability8 = {
	self.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN - self.currentammo / 2;
	QCC_RestoreWeapon();
	self.th_die = PlayerDie;
	self.attack_finished = time + 0.25;
	self.pain_finished = time + 0.5;
	self.qccMoveSpeed = 0.9375;
	self.qccArmorType2 = 0;
	self.th_stand();
};

void() QCC_BigBarrage = {
	if (self.qccAbilityTimer < 0) {
		self.think = bigjohn_ability5;
	}
	else {
		QCC_AbilityUsed();

		if (random() < 0.5)
			sound(self, CHAN_VOICE, "bigjohn/bigjabl1.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_VOICE, "bigjohn/bigjabl2.wav", 1, ATTN_NORM);
		
		self.weapon = QCC_ABILITY;
		self.currentammo = 90;	
		self.qccAbilityTimer = -1;
		self.qccMoveSpeed = 0;
		self.qccArmorType2 = 0.67;
		
		self.weaponmodel = "progs/v_bigjgun.mdl";
		self.weaponframe = 0;
		self.attack_finished = time + 0.3;
		self.pain_finished = time + 10;
		self.th_die = bigjohn_die;
		bigjohn_ability0();
	}
};

/*
=================================
BOT STUFF
=================================
*/
void() QCC_BigJohnBotPre = {
    if (self.enemy.flags & FL_MONSTER || self.enemy.classname == "player") {
        if ((self.qccAbilityTimer < time + 45 - self.qccAbilityCost) && self.qccAbilityTimer > -1 && visible(self.enemy)) {
            QCC_FireAbility();
        }
    }
};