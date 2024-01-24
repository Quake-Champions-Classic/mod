/*
======================================================
QCC: KEEL
======================================================
*/
void() QCC_GrenadeSwarm;
void() QCC_KeelBotPre;

void() QCC_Keel = {
	// Stats
	self.qccClass = QCC_HEAVY;
	self.qccAbilityFunc = QCC_GrenadeSwarm;
	self.qccAbilityString = "Grenade Swarm";
    self.qccAbilityCost = QCC_GLOBAL_COOLDOWN / 3;
    self.qccFlags |= (QCC_FL_REINFORCED | QCC_FL_STOCKPILE);
    self.qccSelfDamage = 0.4;
	self.qccBotPreThink = QCC_KeelBotPre;
	// Model
	setmodel(self, "progs/qckeel.mdl");
    setsize(self, '-16 -20 -24', '16 20 40');
    self.view_ofs = '0 0 26';
    self.qccFlags |= (QCC_FL_CUSTOM_SIZE | QCC_FL_CUSTOM_VIEW);
	self.qccChampGib = "progs/h_qckeel.mdl";
	self.qccMeleeMdl = "progs/v_gaunt.mdl";
	QCC_SetSkin(6);
	self.qccGibSkins = self.qccMaxSkins;
	// Sounds
	self.qccSndMelee = "weapons/gauntshot.wav";
    self.qccSndMeleeHit = "";
    self.qccSndMeleeWall = "player/axhit2.wav";
	self.qccSndJump = "keel/keeljump.wav";
	self.qccSndLand1 = "keel/keelland.wav";
	self.qccSndLand2 = "keel/keelland2.wav";
	self.qccSndPain1 = "keel/keelpain1.wav";
	self.qccSndPain2 = "keel/keelpain2.wav";
	self.qccSndPain3 = "keel/keelpain2.wav";
	self.qccSndPain4 = "keel/keelpain3.wav";
	self.qccSndPain5 = "keel/keelpain3.wav";
	self.qccSndPain6 = "keel/keelpain4.wav";
	self.qccSndDeath1 = "keel/keeldeath1.wav";
	self.qccSndDeath2 = "keel/keeldeath2.wav";
	self.qccSndDeath3 = "keel/keeldeath3.wav";
	self.qccSndDeath4 = "keel/keeldeath2.wav";
	self.qccSndDeath5 = "keel/keeldeath3.wav";
	self.qccSndAxHit1 = "keel/keelpain4.wav";
	self.qccSndBurn1 = "keel/keelpain4.wav";
	self.qccSndBurn2 = "keel/keelpain4.wav";
	self.qccSndGasp1 = "keel/keelgasp1.wav";
	self.qccSndGasp2 = "keel/keelgasp2.wav";
	self.qccSndDrown1 = "player/drown1.wav";
	self.qccSndDrown2 = "player/drown1.wav";
	self.qccSndH2oDeath = "player/drown1.wav";
};


// GRENADE SWARM
void() QCC_GrenadeSwarm = {
    QCC_AbilityUsed();

	sound(self, CHAN_WEAPON, "keel/keelabl.wav", 1, ATTN_NORM);

    entity missile;
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "keelgrenade";
	missile.qccFlags = QCC_FL_ABILITY;
		
    // set missile speed
	makevectors(self.v_angle);	
	missile.velocity = v_forward * 600 + v_up * 200;
	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = MultiGrenadeTouch;

    // set missile duration
	missile.nextthink = time + 1;
	missile.think = MultiGrenadeExplode;
    
	setmodel(missile, "progs/mervup.mdl");
	setsize(missile, '0 0 0', '0 0 0');

    if (random() < 0.5) {
        setorigin(missile, self.origin + v_right * -8 + v_up * 29);
        missile.velocity += v_right * 8;
    }
    else {
        setorigin(missile, self.origin + v_right * 8 + v_up * 29);
        missile.velocity += v_right * -8;
    }

    self.attack_finished = time + 0.5;
};

/*
=================================
BOT STUFF
=================================
*/
void() QCC_KeelBotPre = {
    if (self.enemy.flags & FL_MONSTER || self.enemy.classname == "player") {
        if ((self.qccAbilityTimer < time + QCC_GLOBAL_COOLDOWN - self.qccAbilityCost) && visible(self.enemy)) {
            if (range(self.enemy) > RANGE_NEAR)
                QCC_FireAbility();
        }
    }
};