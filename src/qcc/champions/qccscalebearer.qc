/*
======================================================
QCC: SCALEBEARER
======================================================
*/
void() QCC_ScalePreThink;
void() QCC_ScaleTouch;
void() QCC_BullRush;
void() QCC_ScaleBotPre;

void() QCC_Scalebearer =
{
	// Stats
	self.qccClass = QCC_HEAVY;
    self.qccAbilityFunc = QCC_BullRush;
    self.qccAbilityString = "Bull Rush";
    self.touch = QCC_ScaleTouch;
    self.qccPreThink = QCC_ScalePreThink;
    self.qccBotPreThink = QCC_ScaleBotPre;
	// Model
	setmodel(self, "progs/qcscale.mdl");
    setsize(self, '-16 -20 -24', '16 20 40');
    self.view_ofs = '0 0 26';
    self.qccFlags |= (QCC_FL_CUSTOM_SIZE | QCC_FL_CUSTOM_VIEW);
    QCC_SetSkin(5);
    self.qccGibSkins = self.qccMaxSkins;
	self.qccChampGib = "progs/h_qcscale.mdl";
	self.qccMeleeMdl = "progs/v_gaunt.mdl";
	// Sounds
	self.qccSndMelee = "weapons/gauntshot.wav";
    self.qccSndMeleeHit = "";
    self.qccSndMeleeWall = "player/axhit2.wav";
	self.qccSndJump = "scale/scalejump.wav";
	self.qccSndLand1 = "scale/scaleland.wav";
	self.qccSndLand2 = "scale/scaleland2.wav";
	self.qccSndPain1 = "scale/scalepain1.wav";
	self.qccSndPain2 = "scale/scalepain2.wav";
	self.qccSndPain3 = "scale/scalepain2.wav";
	self.qccSndPain4 = "scale/scalepain3.wav";
	self.qccSndPain5 = "scale/scalepain3.wav";
	self.qccSndPain6 = "scale/scalepain4.wav";
	self.qccSndDeath1 = "scale/scaledeath1.wav";
	self.qccSndDeath2 = "scale/scaledeath2.wav";
	self.qccSndDeath3 = "scale/scaledeath3.wav";
	self.qccSndDeath4 = "scale/scaledeath2.wav";
	self.qccSndDeath5 = "scale/scaledeath3.wav";
	self.qccSndAxHit1 = "scale/scalepain4.wav";
	self.qccSndBurn1 = "scale/scalepain4.wav";
	self.qccSndBurn2 = "scale/scalepain4.wav";
	self.qccSndGasp1 = "scale/scalegasp1.wav";
	self.qccSndGasp2 = "scale/scalegasp2.wav";
	self.qccSndDrown1 = "player/drown1.wav";
	self.qccSndDrown2 = "player/drown1.wav";
	self.qccSndH2oDeath = "player/drown1.wav";
};

// MOVEMENT
void() QCC_ScalePreThink = {
    vector vel, rot;
    float spd, topspd, dot;

    self.qccMoveSpeed = 1.0;
    vel = self.qccLastVelocity;
    vel_z = 0;
    spd = vlen(vel);
    vel = normalize(vel);
    rot = self.angles;
    rot_x = 0;
    makevectors(rot);

    if (self.qccAbilityTimer < 0) // Bullrush speed
        topspd = 700;
    else
        topspd = 425;
    
    if (self.waterlevel < 2) {
        //Scalebearer accelerates quickly when movement matches his view angle
        if (spd <= topspd) {
            dot = vel * v_forward;
            if (dot > 0.8) 
                self.qccMoveSpeed += spd / 500 * 0.6 * dot;
        }
    }

    // Bullrush auto accelerates you
    if (self.qccAbilityTimer < 0) {
        if (spd < 400) 
            vel = v_forward * 400;
        else
            vel = v_forward * (150 * qccDeltaTime);
        self.velocity_x += vel_x;
        self.velocity_y += vel_y;
    }
    
    QCC_MovePreThink();
};

void() QCC_ScaleTouch = 
{
    float spd, damg;
    entity ent;

    if (!other.takedamage)
        return;
    
    spd = vlen(self.velocity);

    // Heavyweight
    if (self.qccAbilityTimer > -1) {
        if (spd > 395)
            damg = 25;
        else
            damg = ceil(25 * (spd / 395));
        if (other.flags & FL_MONSTER)
            damg *= 2;
        ent = spawn();
        ent.classname = "heavyweight";
    }
    else { // Bull Rush
        damg = 75;
        if (other.flags & FL_MONSTER)
            damg *= 10;
        ent = self;
    }

    if (damg)
        T_Damage(other, ent, self, damg);
    
    if (ent != self) {
        ent.nextthink = time + 0.1;
        ent.think = SUB_Remove;
    }
    // If we're in Bull Rush and the enemy survived, stop Bull Rush
    else if (ent == self && other.health > 0)
        self.qccAbilityEnt.qccAbilityTimer = time;
    
    player_touch();
};

// BULLRUSH
void() QCC_BullRushProc =
{
    // Check if dead
    if (self.owner.deadflag >= DEAD_DYING) {
        self.owner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
        self.owner.qccArmorType2 = 0;
        self.owner.qccDoubleJump = FALSE;
        sound(self.owner, CHAN_WEAPON, "silence.wav", 1, ATTN_NORM);
        remove(self);
        return;
    }

    particle(self.owner.origin - self.angles * 4 + '0 0 -10', '0 0 0', 10, 10);
    particle(self.owner.origin - self.angles * 4 + '0 0 18', '0 0 0', 10, 10);
    
    if (self.qccAbilityTimer > time) {
        self.nextthink = time + 0.01;
    }
    else {
        self.owner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
        self.owner.qccArmorType2 = 0;
        self.owner.qccDoubleJump = FALSE;
        self.owner.nextthink = time + 0.01;
        self.owner.think = QCC_RestoreWeapon;
        self.owner.qccAbilityEnt = world;
        self.attack_finished = time + 0.4;
        sound(self.owner, CHAN_WEAPON, "silence.wav", 1, ATTN_NORM);
        remove(self);
    }
};

void() QCC_BullRush = 
{
    if (!(self.flags & FL_ONGROUND))
        return;
    if (self.qccAbilityTimer < 0) {
        if (self.qccAbilityEnt != world)
            self.qccAbilityEnt.qccAbilityTimer = 0;
		return;
    }
    QCC_AbilityUsed();
    self.qccAbilityTimer = -1;
    self.weapon = QCC_ABILITY;
    self.weaponmodel = 0;
    self.weaponframe = 0;
    self.attack_finished = time + 3;
    self.qccArmorType2 = 0.5;
    self.qccDoubleJump = TRUE;
    sound(self, CHAN_WEAPON, "scale/bullrush.wav", 1, ATTN_NORM);

    s = spawn();
    s.owner = self;
    s.qccAbilityTimer = time + 3;
    s.think = QCC_BullRushProc;
    s.nextthink = time + 0.01;
    self.qccAbilityEnt = s;
};

// BOT
void() QCC_ScaleBotPre = 
{
    if (self.enemy.flags & FL_MONSTER || self.enemy.classname == "player") {
        if (self.qccAbilityTimer < time && self.qccAbilityTimer >= 0 && visible(self.enemy)) {
			QCC_FireAbility();
		}
	}
};