/*
======================================================
QCC: DOOM SLAYER
======================================================
*/
void() QCC_Berserk;
void() QCC_DoubleJump;
void() QCC_DoomBotPre;

void() QCC_DoomSlayer = {
	// Stats
	self.qccClass = QCC_MEDIUM;
	self.qccAbilityFunc = QCC_Berserk;
	self.qccAbilityString = "Berserk";
	self.qccJumpFunc = QCC_DoubleJump;
	self.qccBotPreThink = QCC_DoomBotPre;
	// Model
	setmodel(self, "progs/qcdoom.mdl");
	self.qccChampGib = "progs/h_qcdoom.mdl";
	self.qccMeleeMdl = "progs/v_punch.mdl";
	QCC_SetSkin(5);
	// Sounds
	self.qccSndMelee = "weapons/ax1.wav";
	self.qccSndMeleeHit = "doom/dspunch.wav";
	self.qccSndMeleeWall = "doom/dspunch.wav";
	self.qccSndJump = "doom/dsjump.wav";
	self.qccSndLand1 = "doom/dsoof.wav";
	self.qccSndLand2 = "doom/dsland2.wav";
	self.qccSndPain1 = "silence.wav";
	self.qccSndPain2 = "silence.wav";
	self.qccSndPain3 = "doom/dsplpain.wav";
	self.qccSndPain4 = "doom/dsplpain.wav";
	self.qccSndPain5 = "doom/dsplpain.wav";
	self.qccSndPain6 = "doom/dsplpain.wav";
	self.qccSndDeath1 = "doom/dspldeth.wav";
	self.qccSndDeath2 = "doom/dspdiehi.wav";
	self.qccSndDeath3 = "doom/dspldeth.wav";
	self.qccSndDeath4 = "doom/dspdiehi.wav";
	self.qccSndDeath5 = "doom/dspldeth.wav";
	self.qccSndAxHit1 = "doom/dsplpain.wav";
	self.qccSndBurn1 = "doom/dsplpain.wav";
	self.qccSndBurn2 = "doom/dsplpain.wav";
	self.qccSndGasp1 = "silence.wav";
	self.qccSndGasp2 = "silence.wav";
	self.qccSndDrown1 = "doom/dsoof.wav";
	self.qccSndDrown2 = "doom/dsoof.wav";
	self.qccSndH2oDeath = "player/h2odeath.wav";
};

/*
======================================================
QCC: BERSERK
======================================================
*/
// Called by Berserk object
void() QCC_BerserkProc = {
	// Check if dead
	if (self.owner.deadflag >= DEAD_DYING) {
		self.owner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
		stuffcmd(self.owner, "v_cshift 1 1 1 1\n");
		remove(self);
		return;
	}

	self.owner.punchangle = '0 0 1';

	particle(self.owner.origin - self.angles * 4 + '0 0 -12', '0 0 0', 225, 6);
	particle(self.owner.origin - self.angles * 4 + '0 0 12', '0 0 0', 225, 6);
	
	if (self.qccAbilityTimer > time) {
		self.nextthink = time + 0.01;
	}
	else {
		stuffcmd(self.owner, "v_cshift 1 1 1 1\n");
		self.owner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
    	self.owner.think = QCC_RestoreWeapon;
		self.owner.qccMoveSpeed = 1;
		self.owner.nextthink = time;
		remove(self);
	}
};

// Called by Doom Slayer
void() QCC_Berserk = {
	if (self.qccAbilityTimer < 0)
		return;
	sound(self, CHAN_ITEM, "doom/dsgetpow.wav", 1, ATTN_NORM);
	self.qccAbilityTimer = -1;
	self.qccMoveSpeed = 1.5625;
	self.weapon = IT_AXE;
	W_SetCurrentAmmo();
	self.th_run();
	entity ent;
	ent = spawn();
	ent.owner = self;
	ent.qccAbilityTimer = time + 5;
	ent.nextthink = time + 0.01;
	ent.think = QCC_BerserkProc;
	stuffcmd(self, "v_cshift 255 0 0 64\n");
};

void() QCC_DoomPunch = {
	// Doom Punch pushes Doom Slayer forward
	if (self.qccChampion == QCC_DOOMSLAYER && self.qccAbilityTimer < 0) {
		makevectors(self.angles);
		self.velocity += v_forward * 300;
	}
};

void() QCC_DoomPunchHit = {
	if (self.qccAbilityTimer < 0) {
			//if (trace_ent.flags & FL_MONSTER)
				T_Damage(trace_ent, self, self, 299);
			//else
				//T_Damage(trace_ent, self, self, 140);
	}
	else
		T_Damage(trace_ent, self, self, 70);
};

/*
======================================================
QCC: DOUBLE JUMP
======================================================
*/
void() QCC_DoubleJump = {
    if (!(self.flags & FL_ONGROUND))
	{
        if (self.qccDoubleJump != 0)
            return;
        if (!(self.flags & FL_JUMPRELEASED))
		    return;		// don't pogo stick
		
        self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
        self.flags = self.flags - (self.flags & FL_ONGROUND);	// don't stairwalk
        self.button2 = 0;
        sound(self, CHAN_BODY, "doom/dsjump2.wav", 1, ATTN_NORM);
		self.qccDoubleJump = -1;
        if (self.velocity_z > 0)
			self.velocity_z = self.velocity_z + 270;
		else
			self.velocity_z = 270;
        return;
    }
    else
    {
        self.qccDoubleJump = 0;
        return;
    }
};

/*
================================================
BOT STUFF
================================================
*/
void() QCC_DoomBotPre = {
	if (self.enemy.flags & FL_MONSTER || self.enemy.classname == "player") {
        if (self.qccAbilityTimer < time && self.qccAbilityTimer >= 0 && visible(self.enemy)) {
            // Berserk is only useful up close
			if (range(self.enemy) <= RANGE_NEAR)
                        QCC_FireAbility();
        }
		// Berserk is only useful with fists
		else if (self.qccAbilityTimer < 0 && self.weapon != IT_AXE)
		{
            self.weapon = IT_AXE;
            W_SetCurrentAmmo();
		}
	}
};