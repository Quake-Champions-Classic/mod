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
	setmodel(self, "progs/qcranger.mdl");
	self.qccChampGib = "progs/h_player.mdl";
	self.qccMeleeMdl = "progs/v_axe.mdl";
	QCC_SetSkin(1);
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
QCC: DYNAMITE
======================================================
*/
void() QCC_DynaLight = {

}

void() QCC_DynaThrow = {

}

void() QCC_Dynamite = {

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