/*
======================================================
QCC: SCALEBEARER
======================================================
*/
void() QCC_LeapingLizard;
void() QCC_AcidSpitAbility;
void() QCC_SorlagBotPre;

void() QCC_Sorlag = {
	// Stats
	self.qccClass = QCC_HEAVY;
    self.qccAbilityFunc = QCC_AcidSpitAbility;
    self.qccAbilityString = "Acid Spit";
    self.qccPreThink = QCC_LeapingLizard;
    self.qccBotPreThink = QCC_SorlagBotPre;
    self.qccFlags |= QCC_FL_SLIMEPROOF;
    self.qccFlags |= QCC_FL_MERMAID;
	// Model
	setmodel(self, "progs/qcsorlag.mdl");
    setsize(self, '-16 -20 -24', '16 20 40');
    self.view_ofs = '0 0 26';
    self.qccFlags |= (QCC_FL_CUSTOM_SIZE | QCC_FL_CUSTOM_VIEW);
    QCC_SetSkin(5);
	self.qccChampGib = "progs/h_qcsorlag.mdl";
	self.qccMeleeMdl = "progs/v_sorclaw.mdl";
	// Sounds
	self.qccSndMelee = "weapons/ax1.wav";
    self.qccSndMeleeHit = "demon/dhit2.wav";
    self.qccSndMeleeWall = "player/axhit2.wav";
	self.qccSndJump = "sorlag/sorjump.wav";
	self.qccSndLand1 = "sorlag/sorland.wav";
	self.qccSndLand2 = "sorlag/sorland2.wav";
	self.qccSndPain1 = "sorlag/sorpain1.wav";
	self.qccSndPain2 = "sorlag/sorpain2.wav";
	self.qccSndPain3 = "sorlag/sorpain2.wav";
	self.qccSndPain4 = "sorlag/sorpain3.wav";
	self.qccSndPain5 = "sorlag/sorpain3.wav";
	self.qccSndPain6 = "sorlag/sorpain4.wav";
	self.qccSndDeath1 = "sorlag/sordeath1.wav";
	self.qccSndDeath2 = "sorlag/sordeath2.wav";
	self.qccSndDeath3 = "sorlag/sordeath3.wav";
	self.qccSndDeath4 = "sorlag/sordeath2.wav";
	self.qccSndDeath5 = "sorlag/sordeath3.wav";
	self.qccSndAxHit1 = "sorlag/sorpain4.wav";
	self.qccSndBurn1 = "sorlag/sorpain4.wav";
	self.qccSndBurn2 = "sorlag/sorpain4.wav";
	self.qccSndGasp1 = "sorlag/sorgasp1.wav";
	self.qccSndGasp2 = "sorlag/sorgasp2.wav";
	self.qccSndDrown1 = "player/drown1.wav";
	self.qccSndDrown2 = "player/drown1.wav";
	self.qccSndH2oDeath = "player/drown1.wav";
};

// MOVEMENT
void() QCC_LeapingLizard = {
    self.qccMoveSpeed = 1;

    if (!(self.flags & FL_ONGROUND) && self.waterlevel < 2) {
        vector vel, rot, vfwd;
        float spd;
        vel = self.qccLastVelocity;
        vel_z = 0;
        rot = self.v_angle;
        rot_x = 0;
        makevectors(rot);
        vfwd = v_forward;
        vfwd_z = 0;
        spd = vlen(vel);
        
        if (spd < 10 || (normalize(vel) * vfwd < 0.5))
            return;
        
        // Limit Sorlag's speed
        if (spd > 1 && spd < 625)
            spd += 100 * qccDeltaTime;
        else if (spd > 625) {
            spd -= 100 * qccDeltaTime;
            if (spd < 600)
                spd = 600;
        }
        
        vel = vfwd * spd;
        self.velocity_x = vel_x;
        self.velocity_y = vel_y;
    }
    else if (self.waterlevel > 1)
        self.qccMoveSpeed = 1.953125; // Sorlag's a good swimmer; can reach 625ups

    QCC_MovePreThink();
};

// ACID SPIT
void() QCC_PoisonedThink = {
    if (self.owner.qccPoisoned < time || self.owner.health <= 0) {
        remove(self);
        return;
    }
	particle(self.owner.origin, '0 0 32', 57, 25);
    if (self.flags & FL_MONSTER)
        T_Damage(self.owner, self, self.qccAbilityOwner, 30);
    else 
        T_Damage(self.owner, self, self.qccAbilityOwner, 10);
	self.nextthink = time + 1;
};

void(entity spit_owner, entity spit_targ) QCC_GetPoisoned = {	
	// Sorlag is immune to poison, as are dead bodies
	if ((spit_targ.qccFlags & QCC_FL_SLIMEPROOF) || spit_targ.health <= 0 || spit_targ.qccPoisoned > time)
		return;
    entity ent;
	ent = spawn();
	ent.classname = "acidspit";
	ent.qccAbilityOwner = spit_owner;
	ent.owner = spit_targ; 
	ent.movetype = MOVETYPE_NONE;
	ent.solid = SOLID_NOT;
	setmodel(ent, "");
	setsize(ent, '0 0 0', '0 0 0');
	setorigin(ent, '0 0 0');
	spit_targ.qccPoisoned = time + 7;
	ent.nextthink = time + 1;
	ent.think = QCC_PoisonedThink;
    sound(spit_targ, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);
};

void() QCC_AcidPoolTouch = { QCC_GetPoisoned(self.owner, other); };

void() QCC_AcidPoolAnim = [0, QCC_AcidPoolAnim] {
    self.walkframe += 1;
    if (self.walkframe < 10)
        self.frame = self.walkframe;
    else
        remove(self);
};

void() QCC_AcidSpitTouch = {
    vector vec;

    if (other == self.owner)
        return;
        
    if (pointcontents(self.origin) < CONTENT_WATER) {
        remove(self);
        return;
    }

    particle(self.origin, '0 0 0', 57, 50);
    sound(self, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);

    if (other.takedamage || (other.flags & FL_MONSTER)) {
        if (self.flags & FL_MONSTER)
            T_Damage(other, self, self.owner, 45);
        else
            T_Damage(other, self, self.owner, 15);
        QCC_GetPoisoned(self.owner, other);
        return;
    }

    // create Acid Pool
    vec = self.origin - normalize(self.velocity);
    traceline(vec, vec + normalize(self.velocity) * 16, FALSE, self);
    if (trace_fraction < 1) {
        self.movetype = MOVETYPE_NONE;
        self.solid = SOLID_TRIGGER;
        setmodel(self, "progs/s_sorpool.mdl");
        setsize(self, '-12 -12 0', '12 12 4');
        setorigin(self, trace_endpos);

        vec = trace_plane_normal;
        self.angles = vectoangles(vec);
        self.angles_x -= 90;
        
        self.touch = QCC_AcidPoolTouch;
        self.frame = 0;
        self.nextthink = time + 4.1;
        self.think = QCC_AcidPoolAnim;
    }    
};

void() QCC_AcidSpitAnim = [0, QCC_AcidSpitAnim] {
    particle(self.origin, '0 0 0', 57, 10);
    self.walkframe += 1;
    if (self.walkframe < 5)
        self.walkframe = 0;
    self.frame = self.walkframe;
    if (vlen(self.velocity) == 0)
        remove(self);
};

void(entity ent) QCC_AcidSpitProjectile = {
	newmis = spawn();
    newmis.classname = "acidspit";
	newmis.owner = ent;
	newmis.movetype = MOVETYPE_TOSS;
	newmis.solid = SOLID_BBOX;

	makevectors(ent.v_angle);

	if (ent.v_angle_x)
		newmis.velocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 10 + crandom() * v_up * 10;
	else {
		newmis.velocity = aim(ent, 10000);
		newmis.velocity = newmis.velocity * 600;
		newmis.velocity_z = 200;
	}

	newmis.avelocity = '300 300 300';
	newmis.angles = vectoangles(newmis.velocity);	
	newmis.touch = QCC_AcidSpitTouch;

	setmodel(newmis, "progs/s_sorspit.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		
	setorigin(newmis, ent.origin);

    newmis.think = QCC_AcidSpitAnim;
    newmis.nextthink = time + 0.1;
};

// projectile spawner
void() QCC_AcidSpitAbilityProc = {
    QCC_AcidSpitProjectile(self.owner);
    self.nextthink = time + 0.16;
    self.think = QCC_AcidSpitAbilityProc;

    self.qccAbilityTimer -= 1;
    if (self.qccAbilityTimer < 1)
        remove(self);
};

// called by Sorlag
void() QCC_AcidSpitAbility = {
    sound(self, CHAN_WEAPON, "sorlag/acidspit.wav", 1, ATTN_NORM);
    QCC_AbilityUsed();
    self.attack_finished = time + 1.3;
    QCC_AcidSpitProjectile(self);
    entity ent;
    ent = spawn();
    ent.qccAbilityTimer = 4;
    ent.owner = self;
    ent.think = QCC_AcidSpitAbilityProc;
    ent.nextthink = 0.16;
};

// BOT
void() QCC_SorlagBotPre = {
	if (self.enemy.flags & FL_MONSTER || self.enemy.classname == "player") {
        if (self.qccAbilityTimer < time && self.qccAbilityTimer >= 0 && visible(self.enemy)) {
			// Acid Spit if in the same room
			if (self.frame < 126 && range(self.enemy) <= RANGE_MID)
				QCC_FireAbility();
		}
	}
};