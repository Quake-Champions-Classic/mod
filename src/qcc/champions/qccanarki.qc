/*
======================================================
QCC: ANARKI
======================================================
*/
void() QCC_AnarkiPreThink;
void() QCC_Injection;
void() QCC_AnarkiBotPost;

void() QCC_Anarki = {
	// Stats
	self.qccClass = QCC_LIGHT;
    self.qccAbilityFunc = QCC_Injection;
    self.qccAbilityString = "Injection";
    self.qccMoveSpeed = 1.05;
    self.qccPreThink = QCC_AnarkiPreThink;
    self.qccBotPostThink = QCC_AnarkiBotPost;
    self.qccFlags |= QCC_FL_ACROBAT;

    // Anarki Bonus Health
    entity ent;
    ent = find(world, classname, "anarki_bonus");
    while (ent.owner != self && ent != world)
        ent = find(ent, classname, "anarki_bonus");
    
    if (ent != world) // found previous bonus health entity
        self.qccAbilityEnt = ent;
    else { // couldn't find previous health entity, better start over
        self.qccAbilityEnt = spawn();
        self.qccAbilityEnt.classname = "anarki_bonus";
        self.qccAbilityEnt.owner = self;
    }

    self.max_health = 100 + self.qccAbilityEnt.max_health;

	// Model
	setmodel(self, "progs/qcanarki.mdl");
    QCC_SetSkin(1);
    self.qccGibSkins = self.qccMaxSkins;
	self.qccChampGib = "progs/h_qcanarki.mdl";
	self.qccMeleeMdl = "progs/v_gaunt.mdl";
	// Sounds
	self.qccSndMelee = "weapons/gauntshot.wav";
    self.qccSndMeleeHit = "";
    self.qccSndMeleeWall = "player/axhit2.wav";
	self.qccSndJump = "anarki/anarjump.wav";
	self.qccSndLand1 = "anarki/anarland.wav";
	self.qccSndLand2 = "anarki/anarland2.wav";
	self.qccSndPain1 = "anarki/anarpain1.wav";
	self.qccSndPain2 = "anarki/anarpain2.wav";
	self.qccSndPain3 = "anarki/anarpain2.wav";
	self.qccSndPain4 = "anarki/anarpain3.wav";
	self.qccSndPain5 = "anarki/anarpain3.wav";
	self.qccSndPain6 = "anarki/anarpain4.wav";
	self.qccSndDeath1 = "anarki/anardie1.wav";
	self.qccSndDeath2 = "anarki/anardie2.wav";
	self.qccSndDeath3 = "anarki/anardie3.wav";
	self.qccSndDeath4 = "anarki/anardie2.wav";
	self.qccSndDeath5 = "anarki/anardie3.wav";
	self.qccSndAxHit1 = "anarki/anarpain4.wav";
	self.qccSndBurn1 = "anarki/anarpain4.wav";
	self.qccSndBurn2 = "anarki/anarpain4.wav";
	self.qccSndGasp1 = "anarki/anargasp1.wav";
	self.qccSndGasp2 = "anarki/anargasp2.wav";
	self.qccSndDrown1 = "player/drown1.wav";
	self.qccSndDrown2 = "player/drown1.wav";
	self.qccSndH2oDeath = "player/drown1.wav";
};

// MOVEMENT
void() QCC_AnarkiPreThink = {
    float max_spd;
    if (self.qccAbilityTimer > -1) {
        self.qccMoveSpeed = 1.05;
        max_spd = 625; 
    }
    else { // Injection boosts speed 10%
        self.qccMoveSpeed = 1.155;
        max_spd = 700;
    }

    if (!(self.flags & FL_ONGROUND) && self.waterlevel < 1) {
        vector vel, rot, vfwd;
        float spd;
        vel = self.velocity;
        vel_z = 0;
        rot = self.v_angle;
        rot_x = 0;
        makevectors(rot);
        vfwd = v_forward;
        vfwd_z = 0;
        spd = vlen(vel);
        
        if (spd > 10 && (normalize(vel) * vfwd > 0.5)) {            
            // Limit Anarki's speed
            if (spd > 1 && spd < max_spd)
                spd += 25 * qccDeltaTime;
            if (spd > max_spd) {
                spd -= 100 * qccDeltaTime;
                if (spd < max_spd)
                    spd = max_spd;
            }
            
            vel = vfwd * spd;
            self.velocity_x = vel_x;
            self.velocity_y = vel_y;
        }
    }

    QCC_MovePreThink();
};

// INJECTION
void() QCC_InjectionProc = {
    // Changed champions
    if (self.owner.qccChampion != QCC_ANARKI)
        self.qccAbilityTimer = 0;

    if (self.qccAbilityTimer > time) {
        // Fade blue tint
        stuffcmd(self.owner, "v_cshift 1 ");
        float t = (self.qccAbilityTimer - time) / 5;
        stuffcmd(self.owner, ftos(75 * t));
        stuffcmd(self.owner, " ");
        stuffcmd(self.owner, ftos(255 * t));
        stuffcmd(self.owner, " ");
        stuffcmd(self.owner, ftos(64 * t));
        stuffcmd(self.owner, "\n");

        self.think = QCC_InjectionProc;
        self.nextthink = time + 0.01;
        return;
    }
    // Injection ended
    self.owner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
    stuffcmd(self.owner, "v_cshift 1 1 1 1\n");
};

void() QCC_Injection = {
    if (self.qccAbilityTimer < 0)
		return;
    self.qccAbilityTimer = -1;
    self.qccAbilityEnt.qccAbilityTimer = time + 5;
    self.qccAbilityEnt.think = QCC_InjectionProc;
    self.qccAbilityEnt.nextthink = time + 0.01;
    if (self.qccAbilityEnt.max_health < 25) {
        self.qccAbilityEnt.max_health += 1;
        self.max_health += 1;
    }
    T_Heal(self, 50, TRUE);
    self.healthrot_nextcheck = time + 3;
	particle(self.origin + '0 0 -8', '0 0 10', 209, 100);
    particle(self.origin + '0 0 12', '0 0 10', 209, 100);
    stuffcmd(self, "v_cshift 1 75 255 64\n"); // blue view
    float r = random();
    if (r < 0.34)
		sound(self, 6, "anarki/anarab1.wav", 1, ATTN_NORM);
    else if (r < 0.67)
		sound(self, 6, "anarki/anarab2.wav", 1, ATTN_NORM);
	else
		sound(self, 6, "anarki/anarab3.wav", 1, ATTN_NORM);
    sound(self, 7, "anarki/anarinject.wav", 1, ATTN_NORM);
    self.attack_finished = time + 1;
};

/*
===========================
BOT STUFF
===========================
*/
void() QCC_AnarkiBotPost = {
    if (self.qccAbilityTimer < time && self.qccAbilityTimer >= 0) {
        // Anarki injection on hit
        if (self.took_damage == TRUE)
            QCC_FireAbility();
    }
};