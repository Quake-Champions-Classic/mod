/*
======================================================
QCC: GALENA
======================================================
*/
void() QCC_TotemThrow;
void() QCC_GalenaBotPre;

void() QCC_Galena = {
	// Stats
	self.qccClass = QCC_MEDIUM;
	self.qccAbilityFunc = QCC_TotemThrow;
	self.qccAbilityString = "Unholy Totem";
	self.qccBotPreThink = QCC_GalenaBotPre;
	self.qccFlags |= QCC_FL_CHANNELING;
	// Model
	setmodel(self, "progs/qcgalena.mdl");
	self.qccChampGib = "progs/h_qcgalena.mdl";
	self.qccMeleeMdl = "progs/v_gaunt.mdl";
	QCC_SetSkin(5);
	self.qccGibSkins = self.qccMaxSkins;
	// Sounds
	self.qccSndMelee = "weapons/gauntshot.wav";
	self.qccSndMeleeHit = "";
	self.qccSndMeleeWall = "player/axhit2.wav";
	self.qccSndJump = "galena/galjump.wav";
	self.qccSndLand1 = "galena/galland.wav";
	self.qccSndLand2 = "galena/galland2.wav";
	self.qccSndPain1 = "galena/galpain1.wav";
	self.qccSndPain2 = "galena/galpain2.wav";
	self.qccSndPain3 = "galena/galpain2.wav";
	self.qccSndPain4 = "galena/galpain3.wav";
	self.qccSndPain5 = "galena/galpain3.wav";
	self.qccSndPain6 = "galena/galpain4.wav";
	self.qccSndDeath1 = "galena/galdeath1.wav";
	self.qccSndDeath2 = "galena/galdeath2.wav";
	self.qccSndDeath3 = "galena/galdeath3.wav";
	self.qccSndDeath4 = "galena/galdeath2.wav";
	self.qccSndDeath5 = "galena/galdeath3.wav";
	self.qccSndAxHit1 = "galena/galpain4.wav";
	self.qccSndBurn1 = "galena/galpain4.wav";
	self.qccSndBurn2 = "galena/galpain4.wav";
	self.qccSndGasp1 = "galena/galgasp1.wav";
	self.qccSndGasp2 = "galena/galgasp2.wav";
	self.qccSndDrown1 = "player/drown1.wav";
	self.qccSndDrown2 = "player/drown1.wav";
	self.qccSndH2oDeath = "player/drown1.wav";
};

/*
======================================================
QCC: HEALTH TOTEM
======================================================
*/
void() QCC_TotemExplode = [0, QCC_TotemExplode] {
	self.walkframe++;
	if (self.walkframe < 6)
		self.frame = self.walkframe;
	else
		remove(self);
};

void() QCC_TotemTouch = {
	if (self.frame < 10)
		return;
	if (other.classname == "totem_hitbox")
		return;
	if (other == world)
		return;
	if (other.health <= 0)
		return;
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;
	
	float totem_ct;
	totem_ct = 0;
	entity totem;
	totem = find(world, classname, "unholy_totem");
	while (totem != world) {
		if (totem.owner == self.owner)
			totem_ct++;
		totem = find(totem, classname, "unholy_totem");
	}

	// Explode on enemies
	if (other.takedamage == DAMAGE_AIM && other.team != self.team) {
		setmodel(self, "progs/s_explod.spr");
		setorigin(self, self.origin + '0 0 16');
		
		float spd = 160;
		float amt = 50;
		particle(self.origin, '1 0 0' * spd, 209, amt);
		particle(self.origin, '1 1 0' * spd, 209, amt);
		particle(self.origin, '0 1 0' * spd, 209, amt);
		particle(self.origin, '-1 1 0' * spd, 209, amt);
		particle(self.origin, '-1 0 0' * spd, 209, amt);
		particle(self.origin, '-1 -1 0' * spd, 209, amt);
		particle(self.origin, '0 -1 0' * spd, 209, amt);
		particle(self.origin, '1 -1 0' * spd, 209, amt);
		
		self.touch = SUB_Null;
		self.walkframe = -1;
		QCC_TotemExplode();
		sound(self, CHAN_WEAPON, "galena/totemexp.wav", 1, ATTN_NORM);

		float damg;
		if (totem_ct < 3)
			damg = 40;
		else // totem deals more damage when there's 3 set up
			damg = 60;
		
		entity head;
		head = findradius(self.origin, 160);	
		while (head) {
			if (head.takedamage) {
				if (head.team != self.team) {
					if (CanDamage(head, self)) {
						if (head.flags & FL_MONSTER)
							T_Damage(head, self, self.owner, damg * 4);
						else
							T_Damage(head, self, self.owner, damg);
					}
				}
			}
			head = head.chain;
		}
		return;
	}

	// Heal allies
	if (other.flags & FL_CLIENT && other.team == self.team) {
		if (self.qccIgnorePlayers & other.qccPlayerBit)
			return;
		if (T_Heal(other, 50, (totem_ct > 2))) {
			self.qccIgnorePlayers |= other.qccPlayerBit;
			particle(other.origin + '0 0 -8', '0 0 10', 209, 100);
			particle(other.origin + '0 0 12', '0 0 10', 209, 100);
			sound(self, CHAN_ITEM, "galena/totemheal.wav", 1, ATTN_NORM);
		}
	}
}

void() QCC_TotemDie = { // called by totem hitbox
	sound(self, CHAN_VOICE, "galena/totemkill.wav", 1, ATTN_NORM);
	setorigin(self.owner, self.owner.origin + '0 0 16');
	particle(self.owner.origin, '0 0 0', 209, 100);
	remove(self.owner);
	remove(self);
}

void() QCC_TotemProc = [0, QCC_TotemProc] {
	self.walkframe++;
	if (self.walkframe < 11) {
		self.frame = self.walkframe;
		return;
	}

	// Activate Totem
	self.frame = 10;
	sound(self, CHAN_VOICE, "galena/totemrdy.wav", 1, ATTN_NORM);

	// Totem AoE
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	setsize(self, '-60 -60 0', '60 60 32');
	setorigin(self, self.origin);
	self.touch = QCC_TotemTouch;

	// Hitbox child is smaller than AoE of Totem
	entity totem_hitbox = spawn();
	totem_hitbox.classname = "totem_hitbox";
	totem_hitbox.owner = self;
	totem_hitbox.solid = SOLID_TRIGGER;
	totem_hitbox.takedamage = DAMAGE_AIM;
	totem_hitbox.health = 25;
	setsize(totem_hitbox, '-6 -6 0', '6 6 20');
	setorigin(totem_hitbox, self.origin);
	totem_hitbox.th_die = QCC_TotemDie;

	self.think = SUB_Null;

};

void() QCC_TotemThrow = {
	float totem_ct;
	entity totem, first_totem;

    QCC_AbilityUsed();
    self.attack_finished = time + 0.5;

	sound(self, CHAN_WEAPON, "galena/totemthro.wav", 1, ATTN_NORM);
	totem_ct = random();
	if (totem_ct < 0.25)
		sound(self, CHAN_VOICE, "galena/galabl1.wav", 1, ATTN_NORM);
	else if (totem_ct < 0.5)
		sound(self, CHAN_VOICE, "galena/galabl2.wav", 1, ATTN_NORM);
	else if (totem_ct < 0.75)
		sound(self, CHAN_VOICE, "galena/galabl3.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_VOICE, "galena/galabl4.wav", 1, ATTN_NORM);

	
	totem_ct = 0;
	totem = find(world, classname, "unholy_totem");
	while (totem != world) {
		if (totem.owner == self) {
			totem_ct++;
			totem.qccIgnorePlayers = 0;
			if (first_totem != world) {
				if (totem.qccAbilityEntCt < first_totem.qccAbilityEntCt)
					first_totem = totem;
			}
			else
				first_totem = totem;
		}
		totem = find(totem, classname, "unholy_totem");
	}
	if (totem_ct > 2 && first_totem != world) {
		particle(first_totem.origin, '0 0 10', 209, 100);
		remove(first_totem);
	}

	self.qccAbilityEntCt++;

    totem = spawn();
    totem.classname = "unholy_totem";
	totem.owner = self;
	totem.team = self.team;
	totem.qccAbilityEntCt = self.qccAbilityEntCt;
	totem.qccFlags = QCC_FL_ABILITY;

	totem.movetype = MOVETYPE_TOSS;
	totem.solid = SOLID_BBOX;
	makevectors(self.v_angle);
	totem.velocity = v_forward * 600 + v_up * 200;
	totem.angles_y = self.angles_y;

	setmodel(totem, "progs/w_totem.mdl");
	setsize(totem, '0 0 0', '0 0 0');
	setorigin(totem, self.origin);

    totem.think = QCC_TotemProc;
    totem.nextthink = time + 0.1;
}

/*
=====================================
BOT STUFF
=====================================
*/
void() QCC_GalenaBotPre = {
	if (self.enemy.flags & FL_MONSTER || self.enemy.classname == "player") {
        if (self.qccAbilityTimer < time && self.qccAbilityTimer >= 0 && visible(self.enemy)) {
            // Just throw a totem I guess
            QCC_FireAbility();
		}
    }
};