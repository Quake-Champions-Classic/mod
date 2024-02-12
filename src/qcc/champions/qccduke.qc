/*
======================================================
QCC: DUKE NUKEM
======================================================
*/
void() QCC_DukeSkin;
void() QCC_Devastator;
void() QCC_DukeSpawn;
void() QCC_DukeNukemBotPre;

void() QCC_DukeNukem = {
	// Stats
	self.qccClass = QCC_MEDIUM;
    self.qccAbilityFunc = QCC_Devastator;
    self.qccAbilityString = "Devastator";
    self.qccJumpFunc = QCC_Jetpack;
    self.qccBotPreThink = QCC_DukeNukemBotPre;

	// Model
	setmodel(self, "progs/qcduke.mdl");
	self.qccChampGib = "progs/h_qcduke.mdl";
	self.qccMeleeMdl = "progs/v_mfoot.mdl";
	QCC_SetSkin(8);
    self.qccSkinFunc = QCC_DukeSkin;
    if (self.qccSkin == 7)
        setmodel(self, "progs/qcduke2.mdl");

	// Sounds
	self.qccSndMelee = "weapons/ax1.wav";
	self.qccSndMeleeHit = "duke/kickhit.wav";
	self.qccSndMeleeWall = "duke/kickhit.wav";
	self.qccSndJump = "duke/jump.wav";
	self.qccSndLand1 = "duke/land02.wav";
	self.qccSndLand2 = "duke/land2.wav";
	self.qccSndPain1 = "duke/pain2.wav";
	self.qccSndPain2 = "duke/pain3.wav";
	self.qccSndPain3 = "duke/pain5.wav";
	self.qccSndPain4 = "duke/pain6.wav";
	self.qccSndPain5 = "duke/pain7.wav";
	self.qccSndPain6 = "duke/pain8.wav";
	self.qccSndDeath1 = "duke/dmdeath.wav";
	self.qccSndDeath2 = "duke/dscrem2.wav";
	self.qccSndDeath3 = "duke/dscrem3.wav";
	self.qccSndDeath4 = "duke/dmdeath.wav";
	self.qccSndDeath5 = "duke/dscrem1.wav";
	self.qccSndAxHit1 = "duke/dscrem4.wav";
	self.qccSndBurn1 = "duke/dscrem5.wav";
	self.qccSndBurn2 = "duke/dscrem6.wav";
	self.qccSndGasp1 = "duke/gasps.wav";
	self.qccSndGasp2 = "duke/gasps.wav";
	self.qccSndDrown1 = "duke/drown1.wav";
	self.qccSndDrown2 = "duke/drown2.wav";
	self.qccSndH2oDeath = "duke/chokn.wav";
    
    self.qccSpeakSpawn = QCC_DukeSpawn;
    self.qccSpeakFrag = QCC_DukeFrag;
    self.qccSpeakItem = QCC_DukeItem;
    self.qccSpeakCthonGreet = "duke/rip.wav";
    self.qccSpeakCthonKill = "duke/dukesentya.wav";
    self.qccSpeakShubGreet = "duke/quake.wav";
    self.qccSpeakShubKill = "duke/teleport.wav";
};

void() QCC_DukeSkin = {
    QCC_SwapSkin();
    self.qccSkin = self.qccSkin % self.qccMaxSkins;
    if (self.qccSkin != 7)
        setmodel(self, "progs/qcduke.mdl");
    else
        setmodel(self, "progs/qcduke2.mdl");
    self.modelindex_champ = self.modelindex;
    self.view_ofs = '0 0 22';
    self.velocity = '0 0 0';	// 1998-07-21 Player moves after respawn fix by Xian
    setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
    self.skin = self.qccSkin;
};

void() duke_run;
void() duke_stand;
void() duke_shoot;
float() DevastatorEnd;

void() QCC_Jetpack = {
    vector vspd;

    if (self.flags & FL_ONGROUND) {
        self.qccDoubleJump = 0;
        return;
    }
    if (self.weapon == QCC_ABILITY)
        return;
    
    if (self.qccDoubleJump < 101 && (self.flags & FL_JUMPRELEASED)) {
        self.qccDoubleJump += 1;
        if (self.qccDoubleJump > 100 || !self.button2) {
            self.qccDoubleJump = 300;
            self.th_run();
            sound(self, CHAN_ITEM, "duke/jetpakof.wav", 1, ATTN_NORM);
            return;
        }

        if (!self.button0) {
            self.frame = 144;
        }

        // Lift up when going still, keep height when going forward
        vspd = self.velocity;
        vspd_z = 0;
        self.velocity_z = 200 - vlen(vspd);
        if (self.velocity_z < 10)
            self.velocity_z = 10;

        if (self.qccDoubleJump % 10 == 9)
            sound(self, CHAN_ITEM, "duke/jetpaki.wav", 1, ATTN_NORM);
    }
};

/*
======================================================
QCC: DEVASTATOR
======================================================
*/
float() DevastatorEnd = {
    if (time > self.qccAbilityTimer - QCC_GLOBAL_COOLDOWN) {
        QCC_RestoreWeapon();
        self.th_pain = player_pain;
        return 1;
    }
    return 0;
};

void() duke_stand = [151, duke_stand] {
    if (DevastatorEnd() == 1)
        return;

    self.weaponframe = 0;

    if (self.button0) {
        duke_shoot();
        return;
    }

	if (self.velocity_x || self.velocity_y) {
		self.walkframe=0;
		duke_run();
		return;
	}
	if (self.walkframe >= 4)
		self.walkframe = 0;
	self.frame = self.frame + self.walkframe;
	self.walkframe = self.walkframe + 1;	
};

void() duke_run = [145, duke_run] {
    if (DevastatorEnd() == 1)
        return;

    self.weaponframe = 0;

    if (self.button0) {
        duke_shoot();
        return;
    }

	if (!self.velocity_x && !self.velocity_y) {
		self.walkframe=0;
		duke_stand();
		return;
	}
	if (self.walkframe == 6)
		self.walkframe = 0;
	self.frame = self.frame + self.walkframe;

	self.walkframe = self.walkframe + 1;
};

void() duke_pain_proc = {
    if (self.button0) {
        duke_shoot();
        return;
    }
}

void() duke_pain1 = [156, duke_pain2] {
    PainSound();
    self.weaponframe = 0;
    duke_pain_proc();
};
void() duke_pain2 = [157, duke_pain3] {duke_pain_proc();};
void() duke_pain3 = [158, duke_pain4] {duke_pain_proc();};
void() duke_pain4 = [159, duke_pain5] {duke_pain_proc();};
void() duke_pain5 = [160, duke_pain6] {duke_pain_proc();};
void() duke_pain6 = [161, duke_run] {duke_pain_proc();};

void (entity attacker, float damage) duke_pain = {
    duke_pain1();
}

void() DevastatorTouch = {
	float damg;

	if (other == self.owner)
		return;
	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}

	damg = 76;

	if (other.health)
    	T_Damage(other, self, self.owner, damg);
	T_RadiusDamage(self, self.owner, damg + 20, other);

	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void(float offset) DevastatorFire = {
    vector dir, org;
	sound(self, CHAN_WEAPON, "duke/deva.wav", 1, ATTN_NORM);
    makevectors(self.v_angle);
	dir = aim(self, 1000);
    org = self.origin + '0 0 16' + v_right * offset;
    
    newmis = spawn();
	newmis.classname = "devmissile";
	newmis.owner = self;
    newmis.qccFlags = QCC_FL_ABILITY;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;    
	newmis.angles = vectoangles(dir);	
	newmis.touch = DevastatorTouch;
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel(newmis, "progs/missile.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);    
	newmis.velocity = dir * 1000;

	self.attack_finished = time + 0.2;
	self.punchangle_x = -3;
    self.currentammo -= 2;
}

void() duke_shoot = [161, duke_shoot] {
    if (DevastatorEnd() == 1)
        return;

    self.effects = self.effects | EF_MUZZLEFLASH;

    if (!self.button0) {
        duke_stand();
        return;
    }
    
    self.weaponframe = self.weaponframe + 1;    
	if (self.weaponframe == 5)
        self.weaponframe = 1;
    
    if (self.weaponframe == 1)
        DevastatorFire(4);
    else if (self.weaponframe == 3)
        DevastatorFire(-4);
    self.frame = self.frame + self.weaponframe;
}


void() QCC_Devastator = {
    float r;
    string s;

    self.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN + 5;
    self.walkframe = 0;
	self.weapon = QCC_ABILITY;
    self.currentammo = 99;
	self.weaponmodel = "progs/v_deva.mdl";
	self.weaponframe = 0;
    self.attack_finished = time;
    self.th_pain = duke_pain;
	duke_stand();

    if (self.waterlevel > 2)
        return;

    sound(self, CHAN_ITEM, "duke/wpnsel21.wav", 1, ATTN_NORM);
    r = random() * 11;

    if (r < 1)
        s = "duke/blowshitup.wav";
    else if (r < 2)
        s = "duke/gotmilk.wav";
    else if (r < 3)
        s = "duke/hehehe.wav";
    else if (r < 4)
        s = "duke/gunguy.wav";
    else if (r < 5)
        s = "duke/ihop.wav";
    else if (r < 6)
        s = "duke/letgod.wav";
    else if (r < 7)
        s = "duke/dance.wav";
    else if (r < 8)
        s = "duke/arrivederci.wav";
    else if (r < 9)
        s = "duke/timetokill.wav";
    else if (r < 10)
        s = "duke/mod.wav";
    else
        s = "duke/trd.wav";
    
    if (s == "")
        return;
    
    sound(self, CHAN_VOICE, s, 1, ATTN_NORM);
    self.qccTauntTimer = time + 6;
}

void() QCC_DukeSpawn = {
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
                sound(self, CHAN_VOICE, "duke/wthplc.wav", 1, ATTN_NORM);
                return;
            }
            // Opened the pit
            else if ((serverflags & 15) == 15) {
                sound(self, CHAN_VOICE, "duke/stormgates.wav", 1, ATTN_NORM);
                return;
            }
        }
        r = random() * 9;
        if (r < 1)
            s = "duke/letsrk.wav";
        else if (r < 2)
            s = "duke/wherami.wav";
        else if (r < 3)
            s = "duke/hell90s.wav";
        else if (r < 4)
            s = "duke/romero.wav";
        else if (r < 5)
            s = "duke/betduke.wav";
        else if (r < 6)
            s = "duke/chew.wav";
        else if (r < 7)
            s = "duke/blowshitup.wav";
        else if (r < 8)
            s = "duke/cokrok.wav";
        else
            s = "duke/wansom.wav";
    }
    // Respawning
    else {
        r = random() * 8;
        if (r < 1)
            s = "duke/cry.wav";
        else if (r < 2)
            s = "duke/kicka.wav";
        else if (r < 3)
            s = "duke/pissin.wav";
        else if (r < 4)
            s = "duke/rip.wav";
        else if (r < 5)
            s = "duke/smackdb.wav";
        else if (r < 6)
            s = "duke/yohoho2.wav";
        else if (r < 7)
            s = "duke/nothink.wav";
        else
            s = "duke/mthrfkr.wav";
    }
    
    if (s == "")
        return;
    
    sound(self, CHAN_VOICE, s, 1, ATTN_NORM);
    self.qccTauntTimer = time + 6;
}

void(entity targ, entity attacker) QCC_DukeFrag = {
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

    // Mighty foot killed target
    if (attacker.weapon == IT_AXE) {
        if (r < 0.25)
            s = "duke/footface.wav";
        else if (r < 0.5)
            s = "duke/stomped.wav";
        else if (r < 0.75)
            s = "duke/bug.wav";
        else
            s = "duke/bloodboot.wav";
    }

    // Check if target is using a specific champion
    else if (r < 0.3) {
        if (targ.flags & FL_CLIENT) {
            if (targ.qccChampion == QCC_RANGER) {
                r = random();
                if (r < 0.5)
                    s = "duke/teleport.wav";
                else
                    s = "duke/quake.wav";
            }
            else if (targ.qccChampion == QCC_DEATHKNIGHT)
                s = "duke/dukesentya.wav";
            else if (targ.qccChampion == QCC_NYX || targ.qccChampion == QCC_SORLAG || targ.qccChampion == QCC_SLASH)
                s = "duke/allbizbabe.wav";
            else if (targ.qccChampion == QCC_DOOMSLAYER)
                s = "duke/doomedsm.wav";
            else if (targ.qccChampion == QCC_DUKENUKEM) {
                r = random();
                if (r < 0.333)
                    s = "duke/myself.wav";
                else if (r < 0.666)
                    s = "duke/realthing.wav";
                else
                    s = "duke/kickmyass.wav";
            }
        }
    }

    // Random taunt
    if (s == "") {
        r = floor(random() * 31);
        switch (r) {
        case 0: s = "duke/trd.wav"; break;
        case 1: s = "duke/aisle.wav"; break;
        case 2: s = "duke/amess.wav"; break;
        case 3: s = "duke/bitchn.wav"; break;
        case 4: s = "duke/blowit.wav"; break;
        case 5: s = "duke/bookem.wav"; break;
        case 6: s = "duke/cool.wav"; break;
        case 7: s = "duke/damn.wav"; break;
        case 8: s = "duke/getsom.wav"; break;
        case 9: s = "duke/gmeovr.wav"; break;
        case 10: s = "duke/gothrt.wav"; break;
        case 11: s = "duke/groovy.wav"; break;
        case 12: s = "duke/hail.wav"; break;
        case 13: s = "duke/holysh.wav"; break;
        case 14: s = "duke/imgood.wav"; break;
        case 15: s = "duke/inhell.wav"; break;
        case 16: s = "duke/letsrk.wav"; break;
        case 17: s = "duke/lookin.wav"; break;
        case 18: s = "duke/meat.wav"; break;
        case 19: s = "duke/name.wav"; break;
        case 20: s = "duke/nobody.wav"; break;
        case 21: s = "duke/piece.wav"; break;
        case 22: s = "duke/slacker.wav"; break;
        case 23: s = "duke/sukitdn.wav"; break;
        case 24: s = "duke/rokrol.wav"; break;
        case 25: s = "duke/betduke2.wav"; break;
        case 26: s = "duke/huckleberry.wav"; break;
        case 27: s = "duke/itsgood.wav"; break;
        case 28: s = "duke/ripieces.wav"; break;
        case 29: s = "duke/oneking.wav"; break;
        default: s = "duke/fragged.wav"; break;
        }
    }

    if (s == "")
        return;

    sound(attacker, CHAN_VOICE, s, 1, ATTN_NORM);
    attacker.qccTauntTimer = time + 6;
};


void(entity collector, entity item) QCC_DukeItem = {
    string s;
    float r;

    if (collector.qccTauntTimer > time)
        return;
    
    if (collector.waterlevel > 2)
        return;

    s = "";

    // Weapons
    if (item.classname == "weapon_nailgun" || item.classname == "weapon_supernailgun" || item.classname == "weapon_supershotgun" || item.classname == "weapon_grenadelauncher") {    
        r = random();
        if (r < 0.25)
            s = "duke/wansom.wav";
        else if (r < 0.5)
            s = "duke/cool.wav";
        else if (r < 0.75)
            s = "duke/groovy.wav";
        else
            s = "duke/getsom.wav";
    }
    else if (item.classname == "weapon_rocketlauncher" || item.classname == "weapon_lightning") {
        r = random();
        if (r < 0.333)
            s = "duke/hehehe.wav";
        else if (r < 0.666)
            s = "duke/letsrk.wav";
        else
            s = "duke/timetokill.wav";
    }
    // Armor
    else if (item.classname == "qcc_item_lightarmor" || item.classname == "qcc_item_heavyarmor") {
        r = random();
        if (r < 0.333)
            s = "duke/pwrarmr.wav";
        else if (r < 0.666)
            s = "duke/groovy.wav";
        else
            s = "duke/cool.wav";
    }
    // Megahealth
    else if (item.classname == "item_health" && item.spawnflags & H_MEGA)
        s = "duke/lookin.wav";
    // Powerups
    else if (item.classname == "item_artifact_super_damage")
        s = "duke/timetokill.wav";
    else if (item.classname == "item_artifact_invulnerability")
        s = "duke/bos.wav";
    else if (item.classname == "item_artifact_invisibility")
        s = "duke/wherami.wav";
    else if (item.classname == "item_artifact_envirosuit")
        s = "duke/groovy.wav";
    // Runes
    else if (item.classname == "item_sigil")
        s = "duke/imgood.wav";

    if (s == "")
        return;
    
    sound(collector, CHAN_VOICE, s, 1, ATTN_NORM);
    collector.qccTauntTimer = time + 6;
}

/*
==============================
BOT STUFF
==============================
*/
void() QCC_DukeNukemBotPre = {
    if (self.enemy.flags & FL_MONSTER || self.enemy.classname == "player") {
        if (self.qccAbilityTimer < time && self.qccAbilityTimer >= 0 && visible(self.enemy)) {
            // Make sure we only Devastate mid or far range
            if (range(self.enemy) >= RANGE_MID)
                QCC_FireAbility();
        }
    }
}