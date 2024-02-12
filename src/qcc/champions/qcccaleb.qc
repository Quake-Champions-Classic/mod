/*
======================================================
CALEB
======================================================
*/
void() QCC_Dynamite;
void() QCC_CalebBotPre;

void() QCC_Caleb = {
	// Stats
	self.qccClass = QCC_MEDIUM;
	self.qccAbilityFunc = QCC_Dynamite;
	self.qccAbilityString = "Dynamite";
    self.qccAbilityCost = QCC_GLOBAL_COOLDOWN / 3;
	self.qccBotPreThink = QCC_CalebBotPre;
	// Model
	setmodel(self, "progs/qccaleb.mdl");
	self.qccChampGib = "progs/h_qccaleb.mdl";
	self.qccMeleeMdl = "progs/v_pfork.mdl";
	QCC_SetSkin(6);	
	self.qccGibSkins = self.qccMaxSkins;
	// Sounds
	self.qccSndMelee = "weapons/ax1.wav";
	self.qccSndMeleeHit = "caleb/meleeflesh.wav";
	self.qccSndMeleeWall = "caleb/meleewall.wav";
	self.qccSndJump = "caleb/jump.wav";
	self.qccSndLand1 = "caleb/land.wav";
	self.qccSndLand2 = "caleb/land2.wav";
	self.qccSndPain1 = "caleb/pain1.wav";
	self.qccSndPain2 = "caleb/pain2.wav";
	self.qccSndPain3 = "caleb/pain3.wav";
	self.qccSndPain4 = "caleb/pain4.wav";
	self.qccSndPain5 = "caleb/pain5.wav";
	self.qccSndPain6 = "caleb/pain6.wav";
	self.qccSndDeath1 = "caleb/death1.wav";
	self.qccSndDeath2 = "caleb/death2.wav";
	self.qccSndDeath3 = "caleb/death3.wav";
	self.qccSndDeath4 = "caleb/death4.wav";
	self.qccSndDeath5 = "caleb/death5.wav";
	self.qccSndAxHit1 = "caleb/agony.wav";
	self.qccSndBurn1 = "caleb/burn1.wav";
	self.qccSndBurn2 = "caleb/burn2.wav";
	self.qccSndGasp1 = "caleb/gasp.wav";
	self.qccSndGasp2 = "caleb/gasp.wav";
	self.qccSndDrown1 = "caleb/drown1.wav";
	self.qccSndDrown2 = "caleb/drown2.wav";
	self.qccSndH2oDeath = "caleb/h2odeath.wav";

	self.qccSpeakSpawn = QCC_CalebSpawn;
	self.qccSpeakFrag = QCC_CalebFrag;
	self.qccSpeakItem = QCC_CalebItem;
	self.qccSpeakCthonGreet = "caleb/extrabad.wav";
	self.qccSpeakCthonKill = "thatsallfolks.wav";
	self.qccSpeakShubGreet = "caleb/shebitch.wav";
	self.qccSpeakShubKill = "caleb/dingdong.wav";
};

/*
======================================================
DYNAMITE
======================================================
*/
// Dynamite functions
void() QCC_DynaBlow = {
    sound(self, CHAN_WEAPON, "silence.wav", 1, ATTN_NORM);
    T_RadiusDamage(self, self.owner, 150, world);
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_EXPLOSION);
    WriteCoord(MSG_BROADCAST, self.origin_x);
    WriteCoord(MSG_BROADCAST, self.origin_y);
    WriteCoord(MSG_BROADCAST, self.origin_z);
    BecomeExplosion();
}

void() QCC_DynaOops = {
    sound(self.owner, CHAN_WEAPON, "silence.wav", 1, ATTN_NORM);

    // The dynamite was already thrown
    if (self.owner.qccAbilityEnt != self) {
        remove(self);
        return;
    }
    
    entity oself = self;
    self = self.owner;
    QCC_AbilityUsed();
    QCC_RestoreWeapon();
    self = oself;

    // Blow up the dynamite on Caleb
    self.owner.qccAbilityEnt = world;
    self.owner.th_pain = player_pain;
    self.owner.th_die = PlayerDie;
    setorigin(self, self.owner.origin);
    T_Damage(self.owner, self, self.owner, 150);
	QCC_DynaBlow();
}

void() QCC_DynaFuse = [0, QCC_DynaFuse] {
    self.frame = floor(time * 10) % 2;
    if (vlen(self.velocity) > 0 && floor(time) % 2 > 0)
        sound(self, CHAN_WEAPON, "caleb/dynafuse.wav", 1, ATTN_NORM);
    // Fuse ran out!
    if (time >= self.qccAbilityTimer) {
        sound(self, CHAN_WEAPON, "silence.wav", 1, ATTN_NORM);
        QCC_DynaBlow();
    }
}

// Caleb functions
void() caleb_dynatoss1 = [176, caleb_dynatoss2] { self.weaponframe = 6; self.nextthink = time + 0.05;}
void() caleb_dynatoss2 = [177, caleb_dynatoss3] { self.weaponframe = 7; self.nextthink = time + 0.05;}
void() caleb_dynatoss3 = [178, caleb_dynatoss4] {
    QCC_AbilityUsed();

    self.weaponframe = 8;
    self.th_pain = player_pain;
    self.th_die = PlayerDie;

    sound(self, CHAN_WEAPON, "caleb/dynatoss.wav", 1, ATTN_NORM);

    entity bomb;
    bomb = spawn();

    float wait_to_explode;
    if (self.qccAbilityEnt != world) {
        wait_to_explode = self.qccAbilityEnt.state;
        bomb.qccAbilityTimer = self.qccAbilityEnt.qccAbilityTimer;
        remove(self.qccAbilityEnt);
        self.qccAbilityEnt = world;
    }
    
	bomb.owner = self;
	bomb.classname = "dynamite";

	bomb.movetype = MOVETYPE_BOUNCE;
	bomb.solid = SOLID_BBOX;
	setmodel(bomb, "progs/w_dynamite.mdl");
	setsize(bomb, '0 0 0', '0 0 0');		
	setorigin(bomb, self.origin);

    makevectors(self.v_angle);
	bomb.velocity = v_forward * 600 + v_up * 200;
	bomb.avelocity = '0 300 0';
	bomb.angles = vectoangles(bomb.velocity);

    if (!wait_to_explode)
        bomb.touch = QCC_DynaBlow;
    else {
        bomb.nextthink = time + 0.1;
        bomb.think = QCC_DynaFuse;
    }

    bomb.qccFlags |= QCC_FL_ABILITY;
	bomb.qccFlags |= QCC_FL_THROWABLE;
	bomb.qccFlags |= QCC_FL_CANDEFLECT;

    self.nextthink = time + 0.05;
}
void() caleb_dynatoss4 = [179, caleb_dynatoss5] { self.weaponframe = 9; self.nextthink = time + 0.05;}
void() caleb_dynatoss5 = [180, caleb_dynatoss6] { self.weaponframe = 10; self.nextthink = time + 0.05;}
void() caleb_dynatoss6 = [181, caleb_dynatoss7] { self.weaponframe = 11; self.nextthink = time + 0.05;}
void() caleb_dynatoss7 = { QCC_RestoreWeapon();	player_stand();}

void(float wait_to_explode) QCC_DynaToss = {
    if (self.qccAbilityEnt != world)
        self.qccAbilityEnt.state = wait_to_explode;
    self.pain_finished = time + 1.0;
    self.attack_finished = time + 0.4;
    caleb_dynatoss1();
}

void() caleb_dynarun;

void(entity attacker, float damage) caleb_dynapain = [161, caleb_dynapain2] {
    PainSound();
    if (self.button0) {
        QCC_DynaToss(FALSE);
        return;
    }
    self.weaponframe = 5;
    self.walkframe = self.frame;
};
void() caleb_dynapain2 = [161, caleb_dynapain2] {
    if (self.button0) {
        QCC_DynaToss(FALSE);
        return;
    }

    if (self.walkframe < 167) {
        self.walkframe += 1;
        self.frame = self.walkframe;
        self.weaponframe = self.frame % 2 + 4;
        return;
    }

    self.walkframe = 155;
	caleb_dynarun();
}

void() caleb_dynadeath = [167, caleb_dynadeath2] {
    if (self.qccAbilityEnt != world) {
        remove(self.qccAbilityEnt);
        self.qccAbilityEnt = world;
    }
    self.th_pain = player_pain;
    self.th_die = PlayerDie;
    self.walkframe = 168;
    QCC_DeathCommon();
}
void() caleb_dynadeath2 = [168, caleb_dynadeath2] {
    if (self.walkframe < 175) {
        self.frame = self.walkframe;
        self.walkframe += 1;
        return;
    }
    sound(self, CHAN_WEAPON, "silence.wav", 1, ATTN_NORM);
    self.health = -99;
    self.nextthink = -1;
	GibPlayer();
    entity bomb;
    bomb = spawn();
    setsize(bomb, '0 0 0', '0 0 0');		
	setorigin(bomb, self.origin);
    bomb.think = QCC_DynaBlow;
    bomb.nextthink = time;
}

void() caleb_dynastand = [143, caleb_dynastand] {
    if (self.weaponframe > 3)
        self.weaponframe = self.walkframe % 2 + 4;
    else
        self.weaponframe += 1;

    if (self.button0) {
        QCC_DynaToss(FALSE);
        return;
    }

	if (self.velocity_x || self.velocity_y) {
		self.walkframe = 155;
		caleb_dynarun();
		return;
	}

    if (self.walkframe > 154)
        self.walkframe = 143;
    self.frame = self.walkframe;
    self.walkframe += 1;
}

void() caleb_dynarun = [155, caleb_dynarun] {
    if (self.weaponframe > 3)
        self.weaponframe = self.walkframe % 2 + 4;
    else
        self.weaponframe += 1;

    if (self.button0) {
        QCC_DynaToss(FALSE);
        return;
    }

	if (!self.velocity_x && !self.velocity_y) {
		self.walkframe = 143;
		caleb_dynastand();
		return;
	}

	if (self.walkframe > 160)
        self.walkframe = 155;
    self.frame = self.walkframe;
    self.walkframe += 1;
}

void() QCC_Dynamite = {
    // Already throwing it
    if (self.frame > 166)
        return;

    // Equipped and lit
    if (self.qccAbilityEnt != world) {
		QCC_DynaToss(TRUE);
        return;
	}
	
	self.weapon = QCC_ABILITY;
	self.currentammo = 3 - ceil((self.qccAbilityTimer - time) / self.qccAbilityCost);		
	self.weaponmodel = "progs/v_dynamite.mdl";
	self.weaponframe = 0;
	self.attack_finished = time + 0.3;
    self.th_pain = caleb_dynapain;
    self.th_die = caleb_dynadeath;

    self.qccAbilityEnt = spawn();
    self.qccAbilityEnt.owner = self;
    self.qccAbilityEnt.qccAbilityTimer = time + 6;
    self.qccAbilityEnt.think = QCC_DynaOops;
    self.qccAbilityEnt.nextthink = time + 6;
    sound(self, CHAN_WEAPON, "caleb/dynafuse.wav", 1, ATTN_NORM);
    self.walkframe = 155;
    caleb_dynarun();
}

/*
======================================================
LIFE ESSENCE
======================================================
*/
void() QCC_LifeEssenceTouch = {
    if (other.classname != "player")
		return;
    // Enemies can't pick them up
    if (teamplay && other.team != self.team)
        return;
	// Nyx can't pick up stuff during Ghost Walk
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;
    
	if (!T_Heal(other, self.healamount, 0))
		return;
	if (other.qccFlags & QCC_FL_CHANNELING && other.qccAbilityTimer > time) {
		other.qccAbilityTimer = other.qccAbilityTimer - (QCC_GLOBAL_COOLDOWN * 0.05);
		QCC_AbilityTimeLeft(other);
	}
	
	if (ExtSupported("EX_SPRINT"))
		sprint(other, "$qc_item_health", ftos(self.healamount));
	else {
		sprint(other, "You receive ");
		sprint(other, ftos(self.healamount));
		sprint(other, " health\n");
	}
    
	sound(other, CHAN_ITEM, "caleb/lifeessence.wav", 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	
	remove(self);
}

void() QCC_LifeEssenceProc = [0, QCC_LifeEssenceProc] {
    self.frame = self.walkframe;
    self.walkframe += 1;
    if (self.walkframe > 3)
        self.walkframe = 0;
    particle(self.origin, crandom() * '1 0 0' + crandom() * '0 1 0' + '0 0 4', 225, 6);
    if (time > self.qccAbilityTimer)
        remove(self);
}

void(entity targ, entity attacker) QCC_DropLifeEssence = {
    if (targ == attacker)
        return;
    if (teamplay && targ.team == attacker.team)
        return;
    
    entity e;
    traceline(targ.origin, targ.origin + '0 0 -500', TRUE, targ);
    if (trace_fraction < 1) {
        e = spawn();
        e.classname = "life_essence";
        e.owner = attacker;
        e.team = attacker.team;
        setmodel(e, "progs/lifeessence.mdl");
        setsize(e, VEC_HULL_MIN, VEC_HULL_MAX);
        e.flags = FL_ITEM;
        e.solid = SOLID_TRIGGER;
        setorigin(e, trace_endpos);
        e.qccFlags |= QCC_FL_THROWABLE;
        e.healamount = 25;
        e.qccAbilityTimer = time + 30;
        e.touch = QCC_LifeEssenceTouch;
        e.think = QCC_LifeEssenceProc;
        e.nextthink = time;
    }
}

/*
======================================================
CALEB VOICE
======================================================
*/
void() QCC_CalebSpawn = {
	float r, x;
    string s;
    
    if (self.waterlevel > 2)
        return;
    
    s = "";
    
    // Map just started
    x = 0;
    if (time > self.ltime + 15)
        x = 1;

    // No frags, so probably just started
    if (x != 1) {
        if (world.model == "maps/start.bsp") {
            // First time starting
            if (!(serverflags)) {
                sound(self, CHAN_VOICE, "caleb/liveagain.wav", 1, ATTN_NORM);
                return;
            }
            // Opened the pit
            else if ((serverflags & 15) == 15) {
                sound(self, CHAN_VOICE, "caleb/putdown.wav", 1, ATTN_NORM);
                return;
            }
        }

        r = random() * 8;
        if (r < 1)
            s = "caleb/liveagain.wav";
        else if (r < 2)
            s = "caleb/alldead.wav";
        else if (r < 3)
            s = "caleb/comeout.wav";
        else if (r < 4)
            s = "caleb/donateblood.wav";
        else if (r < 5)
            s = "caleb/business.wav";
        else if (r < 6)
            s = "caleb/promisesfun.wav";
        else if (r < 7)
            s = "caleb/sweethome.wav";
		else
			s = "caleb/sweetsuffering.wav";

		if (s == "")
			return;
		
		sound(self, CHAN_VOICE, s, 1, ATTN_NORM);
		self.qccTauntTimer = time + 10;
    }
}

void(entity targ, entity attacker) QCC_CalebFrag = {
    if (self.health < 1)
        return;
    
	string s;
    float r;
    
    if (attacker.qccTauntTimer > time)
        return;
    
    if (self.waterlevel > 2)
        return;

    s = "";
    r = random();

	// Someone alert PETA
	if (targ.classname == "monster_dog") {
		if (r < 0.5)
			s = "caleb/arf.wav";
		else
			s = "playdead.wav";
	}

    // Weapon specific deaths
    else if (attacker.weapon == IT_AXE) {
        if (r < 0.25)
            s = "caleb/lambs.wav";
        else if (r < 0.5)
            s = "caleb/heresjohnny.wav";
        else if (r < 0.75)
            s = "caleb/faceoff.wav";
        else
            s = "caleb/bleedonme.wav";
    }

	else if (r < 0.2 && (attacker.weapon == IT_ROCKET_LAUNCHER || attacker.weapon == IT_LIGHTNING || attacker.weapon == IT_GRENADE_LAUNCHER)) {
		s = "caleb/fleshcooked.wav";
	}

	else if (r < 0.3 && (attacker.weapon == IT_SHOTGUN || attacker.weapon == IT_SUPER_SHOTGUN)) {
		if (r < 0.15)
			s = "caleb/boomstick.wav";
		else
			s = "caleb/shotgun.wav";
	}

    // Check if target is using Caleb
    else if (r < 0.2 && (targ.flags & FL_CLIENT) && targ.qccChampion == QCC_CALEB) {
		s = "caleb/hatemimes.wav";
    }

    else if (r < 0.4 && (targ.flags & FL_CLIENT) && targ.qccChampion == QCC_DUKENUKEM) {
        if (r < 0.2)
            s = "caleb/timetoplay.wav";
        else
            s = "caleb/shakeit.wav";
    }

	// Random taunt
	else {
        r = floor(random() * 39);
		switch (r) {
        case 0: s = "caleb/alreadydead.wav"; break;
        case 1: s = "caleb/amateurs.wav"; break;
		case 2: s = "caleb/anothercorpse.wav"; break;
        case 3: s = "caleb/cackle1.wav"; break;
        case 5: s = "caleb/cackle2.wav"; break;
        case 6: s = "caleb/cackle3.wav"; break;
        case 7: s = "caleb/coagulate.wav"; break;
        case 8: s = "caleb/dontwaste.wav"; break;
        case 9: s = "caleb/downhatch.wav"; break;
        case 10: s = "caleb/endline.wav"; break;
        case 11: s = "caleb/faith.wav"; break;
        case 12: s = "caleb/freshvictims.wav"; break;
        case 13: s = "caleb/goodway.wav"; break;
        case 14: s = "caleb/guywithgun.wav"; break;
        case 15: s = "caleb/hurtingstop.wav"; break;
        case 16: s = "caleb/insects.wav"; break;
        case 17: s = "caleb/laugh1.wav"; break;
        case 18: s = "caleb/laugh2.wav"; break;
        case 19: s = "caleb/laugh3.wav"; break;
        case 20: s = "caleb/letsdoit.wav"; break;
        case 21: s = "caleb/lookedbetter.wav"; break;
        case 22: s = "caleb/nevermore.wav"; break;
        case 23: s = "caleb/nightnight.wav"; break;
        case 24: s = "caleb/notlookinatyou.wav"; break;
        case 25: s = "caleb/notnice.wav"; break;
        case 26: s = "caleb/playdead.wav"; break;
        case 27: s = "caleb/reflexes.wav"; break;
        case 28: s = "caleb/rip.wav"; break;
        case 29: s = "caleb/standandbleed.wav"; break;
        case 30: s = "caleb/strangers.wav"; break;
        case 31: s = "caleb/sunshine.wav"; break;
		case 32: s = "caleb/whosnext.wav"; break;
		case 33: s = "caleb/teachya.wav"; break;
		case 34: s = "caleb/victims.wav"; break;
		case 35: s = "caleb/tipperary.wav"; break;
		case 36: s = "caleb/train.wav"; break;
		case 37: s = "caleb/undermyskin.wav"; break;
		default: s = "caleb/whoslaughing.wav"; break;
		}
    }

    if (s == "")
        return;

    sound(attacker, CHAN_VOICE, s, 1, ATTN_NORM);
    attacker.qccTauntTimer = time + 10;
}

void(entity collector, entity item) QCC_CalebItem = {
	string s;
    float r;

    if (collector.qccTauntTimer > time)
        return;
    
    if (collector.waterlevel > 2)
        return;

    s = "";

    // Weapons
    if (item.classname == "weapon_nailgun" || item.classname == "weapon_supernailgun" || item.classname == "weapon_grenadelauncher" || item.classname == "qcc_weapon_heavymachinegun") {    
		r = random();
		if (r < 0.5)
        	s = "caleb/weapon.wav";
		else
			s = "caleb/laugh1.wav";
    }
	else if (item.classname == "weapon_supershotgun") {
		r = random();
		if (r < 0.5)
			s = "caleb/boomstick.wav";
		else
			s = "caleb/shotgun.wav";
	}
    else if (item.classname == "weapon_rocketlauncher" || item.classname == "weapon_lightning") {
        r = random();
        if (r < 0.5)
            s = "caleb/rocket.wav";
        else
            s = "caleb/laugh3.wav";
    }
	else if (item.classname == "qcc_weapon_railgun") {
		if (r < 0.5)
			s = "caleb/railgun.wav";
		else
			s = "caleb/laugh2.wav";
	}

    // Powerups
    else if (item.classname == "item_artifact_super_damage" || item.classname == "item_artifact_invulnerability") {
		r = random();
		if (r < 0.5)
        	s = "caleb/quad.wav";
		else
			s = "caleb/everybodydies.wav";
	}
    else if (item.classname == "item_artifact_invisibility")
        s = "caleb/tada.wav";
    // Runes
    else if (item.classname == "item_sigil")
        s = "caleb/sigil.wav";

    if (s == "")
        return;
    
    sound(collector, CHAN_VOICE, s, 1, ATTN_NORM);
    collector.qccTauntTimer = time + 6;
}

/*
=====================================
BOT STUFF
=====================================
*/
void() QCC_CalebBotPre = {
	if (self.enemy.flags & FL_MONSTER || self.enemy.classname == "player") {
        if (self.qccAbilityTimer < time && self.qccAbilityTimer >= 0 && visible(self.enemy)) {
            QCC_FireAbility();
		}
    }
};