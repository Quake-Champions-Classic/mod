/*
======================================================
QCC: CALEB
======================================================
*/
void() QCC_DynaLight;
void() QCC_DynaThrow;
void() QCC_Dynamite;
void() QCC_CalebBotPre;

void() QCC_Caleb = {
	// Stats
	self.qccClass = QCC_MEDIUM;
	self.qccAbilityFunc = QCC_Dynamite;
	self.qccAbilityString = "Dynamite";
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
QCC: DYNAMITE
======================================================
*/

void() QCC_DynaThrow = {

}

void() QCC_DynaLight = {

}

void() QCC_Dynamite = {

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
                sound(self, CHAN_VOICE, "caleb/putyoudown.wav", 1, ATTN_NORM);
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

void() QCC_CalebFrag = {
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

	// Random taunt
	else {
        r = floor(random() * 40);
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
		case 34: s = "caleb/timetoplay.wav"; break;
		case 35: s = "caleb/tipperary.wav"; break;
		case 36: s = "caleb/train.wav"; break;
		case 37: s = "caleb/undermyskin.wav"; break;
		case 38: s = "caleb/victims.wav"; break;
		default: s = "caleb/whoslaughing.wav"; break;
		}
    }

    if (s == "")
        return;

    sound(attacker, CHAN_VOICE, s, 1, ATTN_NORM);
    attacker.qccTauntTimer = time + 10;
}

void() QCC_CalebItem = {
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
            QCC_FireAbility(); // light it
			QCC_FireAbility(); // throw it
		}
    }
};