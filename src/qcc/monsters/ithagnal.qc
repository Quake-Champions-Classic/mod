/*
==============================================================================

ITHAGNAL

==============================================================================

To set up Ithagnal fully, add this before ai.qc's "void() SightSound" function:

void() ithagnal_wake;

And add this to ai.qc's "void() SightSound" function:

	else if (self.classname == "monster_ithagnal")
		sound(self, CHAN_VOICE, "ithagnal/ithwake.wav", 1, ATTN_NONE);

Add this to client.qc's void() ClientObituary = function, after the line "if (attacker.flags & FL_MONSTER)":

				if (attacker.classname == "monster_ithagnal")
					bprint ("'s soul was flayed by the madness of Ithagnal\n");

And add this line to your FGD file to see him properly in Trenchbroom:

@PointClass base(Monster) size(-256 -308 -32, 256 308 384) model({ "path": ":progs/ithagnal.mdl" }) = monster_ithagnal : "Ithagnal" []

*/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9 stand10
$frame stand11 stand12 stand13 stand14 stand15 stand16 stand17 stand18 stand19 stand20
$frame stand21 stand22 stand23 stand24 stand25 stand26 stand27 stand28 stand29 stand30
$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8
$frame wallwalk1 wallwalk2 wallwalk3 wallwalk4 wallwalk5 wallwalk6 wallwalk7 wallwalk8
$frame ceilwalk1 ceilwalk2 ceilwalk3 ceilwalk4 ceilwalk5 ceilwalk6 ceilwalk7 ceilwalk8
$frame ceilstand1 ceilstand2 ceilstand3 ceilstand4 ceilstand5 ceilstand6 ceilstand7 ceilstand8 ceilstand9 ceilstand10
$frame ceilstand11 ceilstand12 ceilstand13 ceilstand14 ceilstand15 ceilstand16 ceilstand17 ceilstand18 ceilstand19 ceilstand20
$frame ceilstand21 ceilstand22 ceilstand23 ceilstand24 ceilstand25 ceilstand26 ceilstand27 ceilstand28 ceilstand29 ceilstand30
$frame voreball1 voreball2 voreball3 voreball4 voreball5 voreball6 voreball7 voreball8 voreball9 voreball10
$frame voreball11 voreball12 voreball13 voreball14 voreball15 voreball16 voreball17 voreball18 voreball19 voreball20
$frame voreball21 voreball22 voreball23 voreball24
$frame vomit1 vomit2 vomit3 vomit4 vomit5 vomit6 vomit7 vomit8 vomit9 vomit10
$frame vomit11 vomit12 vomit13 vomit14 vomit15 vomit16 vomit17 vomit18 vomit19 vomit20
$frame teletouch1 teletouch2 teletouch3 teletouch4 teletouch5 teletouch6 teletouch7 teletouch8 teletouch9 teletouch10
$frame telethrow1 telethrow2 telethrow3 telethrow4 telethrow5 telethrow6 telethrow7 telethrow8 telethrow9 telethrow10
$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13 death14 death15 death16 death17 death18 death19 death20
$frame death21 death22 death23 death24 death25 death26 death27 death28 death29 death30
$frame death31 death32 death33 death34 death35 death36

// Ithagnal special functions
void() IthagnalTaunt = {
	if (self.qccTauntTimer > time) 
		return;
	
	float r;
	r = random();	
	if (r < 0.33)
		//sound(self, CHAN_VOICE, "ithagnal/ithtaunt1.wav", 1, ATTN_NONE);
		self.qccTauntTimer = time + 12;
	if (r >= 0.33 && r < 0.66)
		//sound(self, CHAN_VOICE, "ithagnal/ithtaunt2.wav", 1, ATTN_NONE);
		self.qccTauntTimer = time + 8;
	if (r >= 0.66)
		//sound(self, CHAN_VOICE, "ithagnal/ithtaunt3.wav", 1, ATTN_NONE);
		self.qccTauntTimer = time + 8;
};

void(vector pos, float sz) IthagnalMagicHand = {
	vector vec, dir;
	float x, y, z;
		
	vec = QCC_RotatePointYaw(pos, self.angles_y);		
	vec = self.origin + vec;
	if (sz > 0) {
		z = -1;
		while (z <= 1) {
			x = -1;
			while (x <= 1) {
				y = -1;
				while (y <= 1) {
					dir_x = x;
					dir_y = y;
					dir_z = z;
					dir = normalize(dir);
					particle(vec + dir * 8, dir * 32, 155, 100 * sz);
					y = y + 1;
				}
				x = x + 1;
			}
			z = z + 1;
		}
	}
	else
		particle(vec, '0 0 -32', 148, 100);
};

/*================
    MOVEMENT
==================*/
void() ith_stand_loop = [$stand1, ith_stand_loop] {
    self.frame = self.walkframe;
    if (self.walkframe < $stand30)
        self.walkframe += 1;
    else
        self.walkframe = $stand1;
    ai_stand();
};

void() ith_stand = {
    self.walkframe = $stand1;
    ith_stand_loop();
};

void() ith_walk_loop = [$walk1, ith_walk_loop] {
    self.frame = self.walkframe;
    if (self.walkframe < $walk8)
        self.walkframe += 1;
    else
        self.walkframe = $walk1;
    ai_walk(16);
};

void() ith_walk = {
    self.walkframe = $walk1;
    ith_walk_loop();
};

void() ith_run_loop = [$walk1, ith_run_loop] {
    self.frame = self.walkframe;
    if (self.walkframe < $walk8)
        self.walkframe += 1;
    else
        self.walkframe = $walk1;
    ai_run(40);
};

void() ith_run = {
    self.walkframe = $walk1;
    ith_run_loop();
};

/*================
    COMBAT
==================*/
void() ith_wake = {
    //sound(self, CHAN_VOICE, "ithagnal/ithwake.wav", 1, ATTN_NONE);
	self.qccTauntTimer = time + 10;
};

// VORE BARRAGE ======================================================================
void(vector pos) IthMissile = {
	entity 	missile;
	vector	org, dir;
	float	dist, flytime;

    org = QCC_RotatePointYaw(pos, self.angles_y);		
	org = self.origin + org;

	dir = normalize((self.enemy.origin + '0 0 10') - org);
	dist = vlen (self.enemy.origin - org);
	flytime = dist * 0.002;

	if (flytime < 0.1)
		flytime = 0.1;

	self.effects = self.effects | EF_MUZZLEFLASH;
	sound(self, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM);

	missile = spawn();
	missile.classname = "vore_ball";
	missile.owner = self;

	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setmodel(missile, "progs/v_spike.mdl");

	setsize(missile, '0 0 0', '0 0 0');		

    setorigin(missile, org);
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.nextthink = flytime + time;
	missile.think = ShalHome;
	missile.enemy = self.enemy;
	missile.touch = ShalMissileTouch;

	missile.classname = "missile"; // QCC
	missile.qccFlags |= QCC_FL_THROWABLE; // QCC: this'll be funny
	missile.qccFlags |= QCC_FL_CANDEFLECT;
};

// Ithagnal raises her hand to charge several voreballs, then launches them
void() ith_voreball1 = [$voreball1, ith_voreball2] {IthagnalMagicHand('170 143 304', 0); ai_face();};
void() ith_voreball2 = [$voreball2, ith_voreball3] {IthagnalMagicHand('154 -150 376', 0); ai_face();};
void() ith_voreball3 = [$voreball3, ith_voreball4] {IthagnalMagicHand('125 -150 452', 0); ai_face();};
void() ith_voreball4 = [$voreball4, ith_voreball5] {IthagnalMagicHand('94 -139 524', 0); ai_face();};
void() ith_voreball5 = [$voreball5, ith_voreball6] {IthagnalMagicHand('58 -123 597', 0); ai_face();};
void() ith_voreball6 = [$voreball6, ith_voreball7] {IthagnalMagicHand('20 -101 634', 0); ai_face();};
void() ith_voreball7 = [$voreball7, ith_voreball8] {IthagnalMagicHand('0 -98 663', 0); ai_face();};
void() ith_voreball8 = [$voreball8, ith_voreball9] {IthagnalMagicHand('-6 -93 703', 0); ai_face();};
void() ith_voreball9 = [$voreball9, ith_voreball10] {IthagnalMagicHand('-18 -83 726', 0); ai_face();};
void() ith_voreball10 = [$voreball10, ith_voreball11] {IthagnalMagicHand('-37 -83 745', 0); ai_face();};
void() ith_voreball11 = [$voreball11, ith_voreball12] {IthagnalMagicHand('-42 -76 742', 0); ai_face();};
void() ith_voreball12 = [$voreball12, ith_voreball_atk1a] {IthagnalMagicHand('-56 -76 742', 0); ai_face();};

void() ith_voreball_atk1a = [$voreball13, ith_voreball_atk1b] {IthagnalMagicHand('-63 -76 741', 0); IthMissile('-63 -76 741');};
void() ith_voreball_atk1b = [$voreball14, ith_voreball_atk1c] {IthagnalMagicHand('241 -145 451', 0); IthMissile('241 -145 451');};
void() ith_voreball_atk1c = [$voreball15, ith_voreball16] {IthagnalMagicHand('330 37 208', 0); IthMissile('330 37 208');};

void() ith_voreball16 = [$voreball16, ith_voreball17] {IthagnalMagicHand('357 47 195', 0);};
void() ith_voreball17 = [$voreball17, ith_voreball18] {};
void() ith_voreball18 = [$voreball18, ith_voreball19] {};
void() ith_voreball19 = [$voreball19, ith_voreball20] {};
void() ith_voreball20 = [$voreball20, ith_voreball21] {};
void() ith_voreball21 = [$voreball21, ith_voreball22] {};
void() ith_voreball22 = [$voreball22, ith_voreball23] {};
void() ith_voreball23 = [$voreball23, ith_voreball24] {};
void() ith_voreball24 = [$voreball24, ith_run] {self.attack_finished = time + 1.5;};

// VOMIT ======================================================================
void() IthVomitAnim2 = [0, IthVomitAnim2] {
    self.walkframe += 1;
    if (self.walkframe < 30) {
        self.frame = self.walkframe;
        float ofs = (30 - self.frame) / 30;
        setsize(self, '-80 -80 0' * ofs, '80 80 4' * ofs);
        setorigin(self, self.origin);
    }
    else
        remove(self);
};

void() IthVomitAnim1 = [0, IthVomitAnim1] {
    self.walkframe -= 1;
    if (self.walkframe < 0) {
        self.think = IthVomitAnim2;
        self.nextthink = time + 15;
    }
    else {
        self.frame = self.walkframe;
        float ofs = (30 - self.frame) / 30;
        setsize(self, '-80 -80 0' * ofs, '80 80 4' * ofs);
        setorigin(self, self.origin);
    }
};

void() IthVomitTouch = {
    vector vec;

    if (other == self.owner)
        return;
        
    if (pointcontents(self.origin) < CONTENT_WATER) {
        remove(self);
        return;
    }

    particle(self.origin, '0 0 0', 57, 50);
    sound(self, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);

    if (other.takedamage) {
        T_Damage(other, self, self.owner, 100);
        QCC_GetPoisoned(self.owner, other);
        return;
    }

    // create Vomit Pool
    vec = self.origin - normalize(self.velocity);
    traceline(vec, vec + normalize(self.velocity) * 16, FALSE, self);
    if (trace_fraction < 1) {
        self.movetype = MOVETYPE_NONE;
        self.solid = SOLID_TRIGGER;
        setmodel(self, "progs/ithvomit2.mdl");
        setsize(self, '-80 -80 0', '80 80 4');
        setorigin(self, trace_endpos);

        vec = trace_plane_normal;
        self.angles = vectoangles(vec);
        self.angles_x -= 90;
        
        self.touch = QCC_AcidPoolTouch;
        self.frame = 20;
        self.nextthink = time + 0.1;
        self.think = IthVomitAnim1;
    }    
};

void(vector pos) IthVomit = {
    vector org;
    entity vomit;

    org = QCC_RotatePointYaw(pos, self.angles_y);
    org = org + self.origin;
	makevectorsfixed(self.angles);
	
    vomit = spawn();
    vomit.classname = "acidspit";
	setmodel(vomit, "progs/ithvomit.mdl");
	vomit.owner = self;
	vomit.movetype = MOVETYPE_TOSS;
	vomit.solid = SOLID_BBOX;
	vomit.touch = IthVomitTouch;

    vomit.velocity = normalize(self.enemy.origin - org);
    vomit.velocity *= 200;
    vomit.velocity_x += crandom() * 200;
    vomit.velocity_y += crandom() * 200;
    vomit.velocity_z = -200;

	vomit.avelocity = '300 300 300';
	vomit.angles = vectoangles(vomit.velocity);	
	setsize(vomit, '0 0 0', '0 0 0');		
	setorigin(vomit, org);

    vomit.think = QCC_AcidSpitAnim;
    vomit.nextthink = time + 0.1;
};

// Ithagnal vomits corrosive bile across the floor, don't step in it!
void() ith_vomit1 = [$vomit1, ith_vomit2] {ai_face();};
void() ith_vomit2 = [$vomit2, ith_vomit3] {ai_face();};
void() ith_vomit3 = [$vomit3, ith_vomit4] {ai_face();};
void() ith_vomit4 = [$vomit4, ith_vomit5] {ai_face();};
void() ith_vomit5 = [$vomit5, ith_vomit6] {ai_face();};
void() ith_vomit6 = [$vomit6, ith_vomit7] {ai_face();IthVomit('155 0 231');};
void() ith_vomit7 = [$vomit7, ith_vomit8] {ai_face();};
void() ith_vomit8 = [$vomit8, ith_vomit9] {ai_face();};
void() ith_vomit9 = [$vomit9, ith_vomit10] {ai_face();};
void() ith_vomit10 = [$vomit10, ith_vomit11] {ai_face();IthVomit('158 0 265');};
void() ith_vomit11 = [$vomit11, ith_vomit12] {ai_face();};
void() ith_vomit12 = [$vomit12, ith_vomit13] {ai_face();};
void() ith_vomit13 = [$vomit13, ith_vomit14] {ai_face();};
void() ith_vomit14 = [$vomit14, ith_vomit15] {ai_face();};
void() ith_vomit15 = [$vomit15, ith_vomit16] {ai_face();IthVomit('159 0 307');};
void() ith_vomit16 = [$vomit16, ith_vomit17] {ai_face();};
void() ith_vomit17 = [$vomit17, ith_vomit18] {ai_face();};
void() ith_vomit18 = [$vomit18, ith_vomit19] {ai_face();};
void() ith_vomit19 = [$vomit19, ith_vomit20] {ai_face();};
void() ith_vomit20 = [$vomit20, ith_run] {self.attack_finished = time + 1.5;};

// VOMIT ======================================================================
// Ithagnal throws her enemies around her chambers with her mind
void() ith_telethrow1 = [$telethrow1, ith_telethrow2] {};
void() ith_telethrow2 = [$telethrow2, ith_telethrow3] {};
void() ith_telethrow3 = [$telethrow3, ith_telethrow4] {};
void() ith_telethrow4 = [$telethrow4, ith_telethrow5] {};
void() ith_telethrow5 = [$telethrow5, ith_telethrow6] {};
void() ith_telethrow6 = [$telethrow6, ith_telethrow7] {
    vector org;
    entity head;
    makevectors(self.angles);
    org = QCC_RotatePointYaw('360 0 300', self.angles_y);
    org = self.origin + org;
    head = findradius(org, 800);
    while (head) {
        if (head != self && head.owner != self) {
            switch (head.movetype) {
                case MOVETYPE_FLYMISSILE:
                    head.velocity = normalize(self.enemy.origin - head.origin) * 1000 + v_right * crandom() * 300;
                    head.owner = self;
                case MOVETYPE_BOUNCE:
                    head.velocity = normalize(self.enemy.origin - head.origin) * 1000 + v_right * crandom() * 300;
                    head.owner = self;
                    head.movetype = MOVETYPE_FLYMISSILE;
                    setorigin(head, head.origin);
            }
            if (head.classname == "grenade")
                head.touch = T_MissileTouch;
            head.angles = vectoangles(head.velocity);
        }
        head = head.chain;
    }

};
void() ith_telethrow7 = [$telethrow7, ith_telethrow8] {};
void() ith_telethrow8 = [$telethrow8, ith_telethrow9] {};
void() ith_telethrow9 = [$telethrow9, ith_telethrow10] {};
void() ith_telethrow10 = [$telethrow10, ith_run] {self.attack_finished = time + 1.5;};

// Grab our victims and projectiles
void() IthagnalGrab = {
    vector org;
    entity head;
    org = QCC_RotatePointYaw('360 0 300', self.angles_y);
    org = self.origin + org;
    head = findradius(org, 800);
    while (head) {
        if (head != self && head.owner != self) {
            switch (head.movetype) {
                case MOVETYPE_FLYMISSILE:
                    head.velocity = '0 0 0';
                case MOVETYPE_BOUNCE:
                    head.velocity = '0 0 0';
                    head.movetype = MOVETYPE_FLYMISSILE;
                    setorigin(head, head.origin);
            }
        }
        head = head.chain;
    }
};

void() ith_teletouch1 = [$teletouch1, ith_teletouch2] {ai_face();};
void() ith_teletouch2 = [$teletouch2, ith_teletouch3] {ai_face();};
void() ith_teletouch3 = [$teletouch3, ith_teletouch4] {ai_face();};
void() ith_teletouch4 = [$teletouch4, ith_teletouch5] {ai_face();};
void() ith_teletouch5 = [$teletouch5, ith_teletouch6] {ai_face();IthagnalGrab();};
void() ith_teletouch6 = [$teletouch6, ith_teletouch7] {ai_face();IthagnalGrab();};
void() ith_teletouch7 = [$teletouch7, ith_teletouch8] {ai_face();IthagnalGrab();};
void() ith_teletouch8 = [$teletouch8, ith_teletouch9] {ai_face();IthagnalGrab();};
void() ith_teletouch9 = [$teletouch9, ith_teletouch10] {ai_face();IthagnalGrab();};
void() ith_teletouch10 = [$teletouch10, ith_run] {
    vector org;
    entity head;
    float thr = FALSE;
    org = QCC_RotatePointYaw('359 0 300', self.angles_y);
    org = self.origin + org;
    head = findradius(org, 666);
    while (head) {
        if (head.movetype == MOVETYPE_FLYMISSILE || head.movetype == MOVETYPE_BOUNCE) {
            thr = TRUE;
            break;
        }
        head = head.chain;
    }
    if (thr)
        self.think = ith_telethrow1;
    else
        self.attack_finished = time + 1.5;
};

// Delay + randomize attack
void() ith_attack = {
    float r;

    // go for another player if multi player
	if (self.enemy.health <= 0 || random() < 0.02) {
		self.enemy = find(self.enemy, classname, "player");
		if (!self.enemy)
			self.enemy = find(self.enemy, classname, "player");
	}

    if (self.attack_finished > time) {
        if (self.walkframe > $walk8)
            self.walkframe = $walk1;
        ith_run_loop();
        return;
    }

    // enemy is right under you! get'em away
    if (vlen(self.enemy.origin - self.origin) < 64) {
        ith_vomit1();
        return;
    }

    // enemy is using projectile weapons - throw their shots back at'em
    if (self.enemy.weapon == IT_ROCKET_LAUNCHER || self.enemy.weapon == IT_SUPER_NAILGUN || 
        self.enemy.weapon == IT_GRENADE_LAUNCHER || self.enemy.weapon == IT_NAILGUN || 
        self.enemy.weapon == IT_LASER_CANNON) {
        if (random() < 0.6) {
            ith_teletouch1();
            return;
        }
    }

    r = random();
    if (r < 0.333)
        ith_voreball1();
    else if (r < 0.666)
        ith_vomit1();
    else
        ith_teletouch1();
};

/*================
    DAMAGE
==================*/
void(entity attacker, float damage)	ith_pain = {
	return;
};

// called by hitboxes
void() ith_hitbox_proc = {
    vector vec = '0 0 0';

    if (self.owner.health < 1) {
        remove(self);
        return;
    }

    self.think = ith_hitbox_proc;
    self.nextthink = time + 0.05;

    // body positioning
    if (!self.ammo_shells) {
        self.angles = self.owner.angles;
        setorigin(self, self.owner.origin);
        return;
    }

    // leg positioning
    vec_x = self.ammo_shells * 208;
    vec_y = self.ammo_nails * 264;
    vec = QCC_RotatePointYaw(vec, self.owner.angles_y);
    setorigin(self, self.owner.origin + vec);
};

void() ith_hitbox_touch = {
    if (!other.takedamage)
        return;
    
    if (other == self.owner || other.owner == self.owner)
        return;
    
    T_Damage(other, self, self.owner, 100);
};

void() ith_spawn_hitboxes = {
    entity ent;
    vector ofs;
    float x, y;

    // legs
    ofs = '208 264 0';
    x = -1;
    while (x <= 1) {
        y = -1;
        ofs_x = x * 208;
        while (y <= 1) {
            ent = spawn();
            ent.classname = "monster_hitbox";
            ent.owner = self;
            ent.ammo_shells = x;
            ent.ammo_nails = y;
            ent.takedamage = DAMAGE_AIM;
            ent.solid = SOLID_BBOX;
            setsize(ent, '-50 -50 -24', '50 50 436');
            ofs_y = y * 264;
            ofs = QCC_RotatePointYaw(ofs, self.angles_y);
            setorigin(ent, self.origin + ofs);
            ent.touch = ith_hitbox_touch;
            ent.think = ith_hitbox_proc;
            ent.nextthink = time + 0.05;
            y += 2;
        }
        x += 2;
    }

    // body
    ent = spawn();
    ent.classname = "monster_hitbox";
    ent.owner = self;
    ent.takedamage = DAMAGE_AIM;
    ent.solid = SOLID_BBOX;
    setsize(ent, '-70 -70 135', '70 70 422');
    ent.angles = self.angles;
    setorigin(ent, self.origin);
    ent.think = ith_hitbox_proc;
    ent.nextthink = time + 0.05;
};

void() ith_head_pop = {
	vector	oldo;
	float	x, y, z, r;

	sound(self, CHAN_BODY, "player/udeath.wav", 1, ATTN_NONE);
	oldo = self.origin;
    // -60 0 470/524
	z = 470;
	while (z <= 524) {
		x = -68;
		while (x <= -52) {
			y = -8;
			while (y <= 8) {
				self.origin_x = oldo_x + x;
				self.origin_y = oldo_y + y;
				self.origin_z = oldo_z + z;

				r = random();
				if (r < 0.3)				
					ThrowGib("progs/gib1.mdl", -100);
				else if (r < 0.6)
					ThrowGib("progs/gib2.mdl", -100);
				else
					ThrowGib("progs/gib3.mdl", -100);
				y = y + 8;
			}
			x = x + 8;
		}
		z = z + 18;
	}
    setorigin(self, oldo);
};

void() ith_gib = {
	// throw tons of meat chunks	
	vector	oldo;
	float	x, y, z, r;

	sound(self, CHAN_BODY, "boss2/pop2.wav", 1, ATTN_NORM);	
	oldo = self.origin;
	z = 121;
	while (z <= 366) {
		x = -70;
		while (x <= 70) {
			y = -96;
			while (y <= 96) {
				self.origin_x = oldo_x + x;
				self.origin_y = oldo_y + y;
				self.origin_z = oldo_z + z;

				r = random();
				if (r < 0.3)				
					ThrowGib("progs/gib1.mdl", -100);
				else if (r < 0.6)
					ThrowGib("progs/gib2.mdl", -100);
				else
					ThrowGib("progs/gib3.mdl", -100);
				y = y + 32;
			}
			x = x + 35;
		}
		z = z + 64;
	}
	remove(self);
};

void() ith_death_proc = [$death1, ith_death_proc] {
    self.frame = self.walkframe;
    if (self.frame == $death3) {
        self.solid = SOLID_NOT;
        setorigin(self, self.origin);
    }
    // head blows up
    else if (self.frame == $death26)
        ith_head_pop();
    // body blows up
    else if (self.frame == $death36)
        self.think = ith_gib;
    
    self.walkframe += 1;
};

void() ith_death = {
    self.walkframe = $death1;
    //sound(self, CHAN_VOICE, "ithagnal/ithdie.wav", 1, ATTN_NONE);
    ith_death_proc();
};

/*================
    SPAWN
==================*/
void() monster_ithagnal = {
	if (deathmatch) {
		remove(self);
		return;
	}
	
	precache_model("progs/ithagnal.mdl");
    precache_model("progs/v_spike.mdl");
    precache_model("progs/ithvomit.mdl");
    precache_model("progs/ithvomit2.mdl");
	
	precache_sound("boss2/pop2.wav");
    precache_sound("shalrath/attack.wav");
	precache_sound("shalrath/attack2.wav");
	
	// precache_sound("ithagnal/ithwake.wav");
	// precache_sound("ithagnal/ithtaunt1.wav");
	// precache_sound("ithagnal/ithtaunt2.wav");
	// precache_sound("ithagnal/ithtaunt3.wav");
	// precache_sound("ithagnal/ithdie.wav");

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_STEP;
	setmodel(self, "progs/ithagnal.mdl");

	setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	if (skill > 1)
		self.max_health = 10000;
	else
		self.max_health = 6000;
	self.health = self.max_health;

	self.th_stand = ith_stand;
	self.th_walk = ith_walk;
	self.th_run = ith_run;
	self.th_die = ith_death;
	//self.th_melee = ith_stomp;
	self.th_missile = ith_attack;
	self.th_pain = ith_pain;
	self.use = ith_wake;
	self.combat_style = CS_MIXED;

	self.qccFlags |= QCC_FL_SLIMEPROOF;
	self.qccFlags |= QCC_FL_RESIST_TELEFRAG;

	self.netname = "Ithagnal";
	self.killstring = "'s soul was flayed by the madness of Ithagnal\n";
	
    ith_spawn_hitboxes();

	walkmonster_start();
};