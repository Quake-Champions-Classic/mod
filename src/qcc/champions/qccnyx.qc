/*
======================================================
QCC: NYX
======================================================
*/
void() QCC_Ghostwalk;
void() QCC_WallJump;
void() QCC_NyxBotPost;

void() QCC_Nyx = {
	// Stats
	self.qccClass = QCC_LIGHT;
    self.qccAbilityFunc = QCC_Ghostwalk;
    self.qccAbilityString = "Ghost Walk";
    self.qccJumpFunc = QCC_WallJump;
    self.qccMoveSpeed = 1.05;
    self.qccPreThink = QCC_MovePreThink;
	self.qccPostThink = QCC_MovePostThink;
    self.qccBotPostThink = QCC_NyxBotPost;
	// Model
	setmodel(self, "progs/qcnyx.mdl");
    QCC_SetSkin(2);
    self.qccGibSkins = self.qccMaxSkins;
	self.qccChampGib = "progs/h_qcnyx.mdl";
	self.qccMeleeMdl = "progs/v_nxsword.mdl";
	// Sounds
	self.qccSndMelee = "knight/sword1.wav";
    self.qccSndMeleeHit = "";
    self.qccSndMeleeWall = "player/axhit2.wav";
	self.qccSndJump = "nyx/nyxjump.wav";
	self.qccSndLand1 = "nyx/nyxland.wav";
	self.qccSndLand2 = "nyx/nyxland2.wav";
	self.qccSndPain1 = "nyx/nyxpain1.wav";
	self.qccSndPain2 = "nyx/nyxpain2.wav";
	self.qccSndPain3 = "nyx/nyxpain2.wav";
	self.qccSndPain4 = "nyx/nyxpain3.wav";
	self.qccSndPain5 = "nyx/nyxpain3.wav";
	self.qccSndPain6 = "nyx/nyxpain4.wav";
	self.qccSndDeath1 = "nyx/nyxdeath1.wav";
	self.qccSndDeath2 = "nyx/nyxdeath2.wav";
	self.qccSndDeath3 = "nyx/nyxdeath3.wav";
	self.qccSndDeath4 = "nyx/nyxdeath2.wav";
	self.qccSndDeath5 = "nyx/nyxdeath3.wav";
	self.qccSndAxHit1 = "nyx/nyxpain4.wav";
	self.qccSndBurn1 = "nyx/nyxpain4.wav";
	self.qccSndBurn2 = "nyx/nyxpain4.wav";
	self.qccSndGasp1 = "nyx/nyxgasp1.wav";
	self.qccSndGasp2 = "nyx/nyxgasp2.wav";
	self.qccSndDrown1 = "player/drown1.wav";
	self.qccSndDrown2 = "player/drown1.wav";
	self.qccSndH2oDeath = "player/drown1.wav";
};

/*
======================================================
QCC: GHOST WALK
======================================================
*/
void(vector org) QCC_GhostwalkFX = {
    entity ent;
    ent = spawn();
	ent.origin = org;
	ent.nextthink = time + 0.2;
    ent.think = SUB_Remove;
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_TELEPORT);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
};

// called by Ghostwalk object
void() QCC_GhostwalkProc = {
    // Check if dead
	if (self.owner.deadflag >= DEAD_DYING) {
		self.owner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
		stuffcmd(self.owner, "v_cshift 1 1 1 1\n");
		remove(self);
		return;
	}
    
	if (self.qccAbilityTimer > time) {
		self.nextthink = time + 0.01;
        if (self.qccAbilityTimer == 1)
            spawn_tdeath (self.owner.origin,self.owner);
    }
	else {
        stuffcmd(self.owner, "v_cshift 1 1 1 1\n"); // reset view color
        self.owner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
        self.owner.nextthink = time + 0.01;
        self.owner.think = QCC_RestoreWeapon;
        // Restore sounds
        self.owner.qccSndJump = "nyx/nyxjump.wav";
        self.owner.qccSndLand1 = "nyx/nyxland.wav";
        self.owner.qccSndLand2 = "nyx/nyxland2.wav";
        //self.owner.solid = SOLID_SLIDEBOX;
        self.owner.items = self.owner.items & ~IT_INVISIBILITY;
        self.owner.invisible_finished = 0;
        self.owner.modelindex = self.owner.modelindex_champ;
        self.owner.skin = self.owner.qccSkin;
        setsize(self.owner, VEC_HULL_MIN, VEC_HULL_MAX);
        self.owner.takedamage = DAMAGE_AIM;
        QCC_GhostwalkFX(self.owner.origin);
        sound(self.owner, CHAN_ITEM, "nyx/invisexit.wav", 1, ATTN_NORM);
        remove(self);
    }
};

void() QCC_Ghostwalk = {
    if (self.qccAbilityTimer < 0)
		return;
    QCC_AbilityUsed();
    self.qccAbilityTimer = -1;
    self.weapon = QCC_ABILITY;
    self.weaponmodel = 0;
    self.weaponframe = 0;
    self.attack_finished = time + 3;
    QCC_GhostwalkFX(self.origin);
    stuffcmd(self, "v_cshift 1 75 255 64\n"); // blue view

    float r;
    r = random();
    if (r < 0.25)
        sound(self, CHAN_WEAPON, "nyx/invis1.wav", 1, ATTN_NORM);
    else if (r < 0.5)
        sound(self, CHAN_WEAPON, "nyx/invis2.wav", 1, ATTN_NORM);
    else if (r < 0.5)
        sound(self, CHAN_WEAPON, "nyx/invis3.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_WEAPON, "nyx/invis4.wav", 1, ATTN_NORM);
    sound(self, CHAN_ITEM, "nyx/invisenter.wav", 1, ATTN_NORM);

    // Silence movement sounds
	self.qccSndJump = "silence.wav";
	self.qccSndLand1 = "silence.wav";
	self.qccSndLand2 = "silence.wav";

    // No collision?
    //self.solid = SOLID_NOT;
    self.items = self.items | IT_INVISIBILITY;
    self.modelindex = 0;
    setmodel(self, "progs/qcinvis.mdl");
    self.skin = 0;
    setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
    self.takedamage = DAMAGE_NO;
    entity fool = nextent(world);
    while (fool != world) {
        if (fool.enemy == self)
            fool.enemy = world;
        fool = nextent(fool);
    }
    entity ent;
    ent = spawn();
    ent.owner = self;
    ent.qccAbilityTimer = time + 3;
    ent.nextthink = time + 0.01;
    ent.think = QCC_GhostwalkProc;
};

/*
======================================================
QCC: WALL JUMP
======================================================
*/
void() QCC_WallJump = {
    if (!(self.flags & FL_ONGROUND)) {
        if (self.qccDoubleJump != 0)
            return;
        if (!(self.flags & FL_JUMPRELEASED))
		    return;		// don't pogo stick
        float i;
        i = 0;
        vector o = self.origin;
        o_z = o_z + 24;
        while (i < 4) {
            vector vCheck;
            if (i < 2) {vCheck = v_forward * 32;}
            if (i > 1) {vCheck = v_right * 32;}
            if (i == 1 || i == 3) {vCheck = vCheck - vCheck * 2;}
            
            traceline(o, o + vCheck, TRUE, self);
            if (trace_fraction != 1)
                self.qccDoubleJump++;
            else {
                traceline(self.origin, self.origin + vCheck, TRUE, self);
                if (trace_fraction != 1)
                    self.qccDoubleJump++;
            }
            if (self.qccDoubleJump > 0) {
                self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
                self.flags = self.flags - (self.flags & FL_ONGROUND);	// don't stairwalk
                self.button2 = 0;
                sound(self, CHAN_BODY, self.qccSndJump, 1, ATTN_NORM);
                self.velocity_z = 405;
                self.qccDoubleJump = -1;
                return;
            }
            i = i + 1;
        }
    }
    else {
        self.qccDoubleJump = 0;
        return;
    }
};

/*
===========================
BOT STUFF
===========================
*/
void() QCC_NyxBotPost = {
    if (self.qccAbilityTimer < time && self.qccAbilityTimer >= 0) {
        // Nyx invis on hit
        if (self.took_damage == TRUE)
            QCC_FireAbility();
    }
};