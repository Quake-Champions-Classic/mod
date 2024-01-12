/*
=====================================
HORDE MONSTER FUNCTIONS
=====================================
*/

entity() HordeFindTarget;

/*QUAKED info_monster_start START_OFF
if targeted, it will toggle between on or off, like lights 
*/
float SKIP_BLOCK_CHECK = 2;
void() monster_start_use = {
	if (self.spawnflags & START_OFF)
		self.spawnflags = self.spawnflags - START_OFF;
	else
		self.spawnflags = self.spawnflags + START_OFF;
};

void() info_monster_start = {
	if (not_horde(self))
		return;
	self.wait = FALSE; // used for checking if this is a valid spawn
	self.use = monster_start_use;
	setorigin(self, self.origin);	
	setsize(self, '-80 -80 0', '80 80 128');
};

void() info_monster_start_ranged = {    // used for ogres and enforcers
	if (not_horde(self))
		return;
	self.wait = FALSE; // used for checking if this is a valid spawn
	self.use = monster_start_use;
	setorigin(self, self.origin);	
	setsize(self, '-44 -44 0', '44 44 128');
};

void() info_monster_start_flying = {    // used exclusively for scrags (wizards)
	if (not_horde(self))
		return;
	self.wait = FALSE; // used for checking if this is a valid spawn
	self.use = monster_start_use;
	setorigin(self, self.origin);	
	setsize(self, '-80 -80 0', '80 80 128');
};

void() info_monster_start_boss = {  // used for shalraths and shamblers
	if (not_horde(self))
		return;
	self.wait = FALSE; // used for checking if this is a valid spawn
	self.use = monster_start_use;
	setorigin(self, self.origin);	
	setsize(self, '-44 -44 0', '44 44 128');
};

void() HordePrecacheMonsters = {
	// knight
	precache_model("progs/knight.mdl");
	precache_model("progs/h_knight.mdl");

	precache_sound("knight/kdeath.wav");
	precache_sound("knight/khurt.wav");
	precache_sound("knight/ksight.wav");
	precache_sound("knight/sword1.wav");
	precache_sound("knight/sword2.wav");
	precache_sound("knight/idle.wav");
	
	// hellknight
	precache_model2("progs/hknight.mdl");
	precache_model2("progs/k_spike.mdl");
	precache_model2("progs/h_hellkn.mdl");
	
	precache_sound2("hknight/attack1.wav");
	precache_sound2("hknight/death1.wav");
	precache_sound2("hknight/pain1.wav");
	precache_sound2("hknight/sight1.wav");
	precache_sound("hknight/hit.wav");		// used by C code, so don't sound2
	precache_sound2("hknight/slash1.wav");
	precache_sound2("hknight/idle.wav");
	precache_sound2("hknight/grunt.wav");

	precache_sound("knight/sword1.wav");
	precache_sound("knight/sword2.wav");
	
	// dog
	precache_model("progs/h_dog.mdl");
	precache_model("progs/dog.mdl");

	precache_sound("dog/dattack1.wav");
	precache_sound("dog/ddeath.wav");
	precache_sound("dog/dpain1.wav");
	precache_sound("dog/dsight.wav");
	precache_sound("dog/idle.wav");
	
	// demon
	precache_model("progs/demon.mdl");
	precache_model("progs/h_demon.mdl");

	precache_sound("demon/ddeath.wav");
	precache_sound("demon/dhit2.wav");
	precache_sound("demon/djump.wav");
	precache_sound("demon/dpain1.wav");
	precache_sound("demon/idle1.wav");
	precache_sound("demon/sight2.wav");
	
	// ogre
	precache_model("progs/ogre.mdl");
	precache_model("progs/h_ogre.mdl");
	precache_model("progs/grenade.mdl");

	precache_sound("ogre/ogdrag.wav");
	precache_sound("ogre/ogdth.wav");
	precache_sound("ogre/ogidle.wav");
	precache_sound("ogre/ogidle2.wav");
	precache_sound("ogre/ogpain1.wav");
	precache_sound("ogre/ogsawatk.wav");
	precache_sound("ogre/ogwake.wav");
	
	// grunt
	precache_model("progs/soldier.mdl");
	precache_model("progs/h_guard.mdl");
	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");

	precache_sound("soldier/death1.wav");
	precache_sound("soldier/idle.wav");
	precache_sound("soldier/pain1.wav");
	precache_sound("soldier/pain2.wav");
	precache_sound("soldier/sattck1.wav");
	precache_sound("soldier/sight1.wav");

	precache_sound("player/udeath.wav");		// gib death
	
	// enforcer
	precache_model2("progs/enforcer.mdl");
	precache_model2("progs/h_mega.mdl");
	precache_model2("progs/laser.mdl");

	precache_sound2("enforcer/death1.wav");
	precache_sound2("enforcer/enfire.wav");
	precache_sound2("enforcer/enfstop.wav");
	precache_sound2("enforcer/idle1.wav");
	precache_sound2("enforcer/pain1.wav");
	precache_sound2("enforcer/pain2.wav");
	precache_sound2("enforcer/sight1.wav");
	precache_sound2("enforcer/sight2.wav");
	precache_sound2("enforcer/sight3.wav");
	precache_sound2("enforcer/sight4.wav");
	
	// shambler
	precache_model("progs/shambler.mdl");
	precache_model("progs/s_light.mdl");
	precache_model("progs/h_shams.mdl");
	precache_model("progs/bolt.mdl");
	
	precache_sound("shambler/sattck1.wav");
	precache_sound("shambler/sboom.wav");
	precache_sound("shambler/sdeath.wav");
	precache_sound("shambler/shurt2.wav");
	precache_sound("shambler/sidle.wav");
	precache_sound("shambler/ssight.wav");
	precache_sound("shambler/melee1.wav");
	precache_sound("shambler/melee2.wav");
	precache_sound("shambler/smack.wav");
	
	// shalrath
	precache_model2("progs/shalrath.mdl");
	precache_model2("progs/h_shal.mdl");
	precache_model2("progs/v_spike.mdl");
	
	precache_sound2("shalrath/attack.wav");
	precache_sound2("shalrath/attack2.wav");
	precache_sound2("shalrath/death.wav");
	precache_sound2("shalrath/idle.wav");
	precache_sound2("shalrath/pain.wav");
	precache_sound2("shalrath/sight.wav");
	
	// wizard
	precache_model("progs/wizard.mdl");
	precache_model("progs/h_wizard.mdl");
	precache_model("progs/w_spike.mdl");

	precache_sound("wizard/hit.wav");		// used by c code
	precache_sound("wizard/wattack.wav");
	precache_sound("wizard/wdeath.wav");
	precache_sound("wizard/widle1.wav");
	precache_sound("wizard/widle2.wav");
	precache_sound("wizard/wpain.wav");
	precache_sound("wizard/wsight.wav");	
	
	// zombies
	precache_model("progs/zombie.mdl");
	precache_model("progs/h_zombie.mdl");
	precache_model("progs/zom_gib.mdl");

	precache_sound("zombie/z_idle.wav");
	precache_sound("zombie/z_idle1.wav");
	precache_sound("zombie/z_shot1.wav");
	precache_sound("zombie/z_gib.wav");
	precache_sound("zombie/z_pain.wav");
	precache_sound("zombie/z_pain1.wav");
	precache_sound("zombie/z_fall.wav");
	precache_sound("zombie/z_miss.wav");
	precache_sound("zombie/z_hit.wav");
	precache_sound("zombie/idle_w2.wav");

	// SCOURGE OF ARMAGON ==============================================
	// scourge
	precache_model("progs/scor.mdl");
	precache_model("progs/h_scourg.mdl");
	precache_model("progs/spike.mdl");
	precache_sound("misc/null.wav");
	precache_sound("scourge/idle.wav");
	precache_sound("scourge/pain.wav");
	precache_sound("scourge/pain2.wav");
	precache_sound("scourge/sight.wav");
	precache_sound("scourge/tailswng.wav");
	precache_sound("scourge/walk.wav");
	precache_sound("weapons/rocket1i.wav");

	// gremlin
	precache_model("progs/grem.mdl");
	precache_model("progs/h_grem.mdl");
	precache_sound("grem/death.wav");
	precache_sound("grem/attack.wav");
	precache_sound("grem/pain1.wav");
	precache_sound("grem/pain2.wav");
	precache_sound("grem/pain3.wav");
	precache_sound("grem/idle.wav");
	precache_sound("grem/sight1.wav");

	// DISSOLUTION OF ETERNITY ===========================================
	// sword (phantom swordsman)
	precache_model("progs/sword.mdl");
	
	// mummy
	precache_model("progs/mummy.mdl");

	// morph (guardian)
	precache_model("progs/morph_gr.mdl");
	precache_model("progs/morph_eg.mdl");
	precache_model("progs/morph_az.mdl");
	precache_sound("guard/death.wav");
	precache_sound("guard/pain1.wav");
	precache_sound("guard/see1.wav");

	// wrath
	precache_model("progs/wrath.mdl");
	precache_model("progs/w_ball.mdl");
	precache_model("progs/wrthgib1.mdl");
	precache_model("progs/wrthgib2.mdl");
	precache_model("progs/wrthgib3.mdl");	
	precache_sound("wrath/wsee.wav");
	precache_sound("wrath/watt.wav");
	precache_sound("wrath/wpain.wav");
	precache_sound("wrath/wdthc.wav");

	// super_wrath (overlord)
	precache_model("progs/s_wrath.mdl");
	precache_model("progs/s_wrtgb1.mdl");
	precache_model("progs/s_wrtgb2.mdl");
	precache_model("progs/s_wrtgb3.mdl");
	precache_sound("s_wrath/smash.wav");	
};

void() GibMonster = {
	T_Damage(self, world, world, 4000);
};

/*
================
SpawnMonster
================
*/
entity(string class, vector org, vector temp_angles) SpawnMonster = {
	entity monster;
	float rand;
	monster = spawn();
	
	monster.angles = temp_angles; 
	monster.solid = SOLID_SLIDEBOX;
	monster.movetype = MOVETYPE_STEP;
	monster.flags = monster.flags | FL_MONSTER;	
	entity oself; // old self
	
	// perform enemy-type specific loading
	if (class == "knight") {
		setmodel(monster, "progs/knight.mdl");
		setsize(monster, '-16 -16 -24', '16 16 40');
		org = org + '0 0 24'; // offset based on size
		monster.classname = "monster_knight";
		monster.health = 75;
		monster.th_stand = knight_stand1;
		monster.th_walk = knight_walk1;
		monster.th_run = knight_run1;
		monster.th_melee = knight_atk1;
		monster.th_pain = knight_pain;
		monster.th_die = knight_die;
	}
	else if (class == "hellknight") {
		setmodel(monster, "progs/hknight.mdl");
		setsize(monster, '-16 -16 -24', '16 16 40');
		org = org + '0 0 24';
		monster.classname = "monster_hell_knight";
		monster.health = 250;
		monster.th_stand = hknight_stand1;
		monster.th_walk = hknight_walk1;
		monster.th_run = hknight_run1;
		monster.th_melee = hknight_melee;
		monster.th_missile = hknight_magicc1;
		monster.th_pain = hknight_pain;
		monster.th_die = hknight_die;
	}
	else if (class == "dog") {
		setmodel(monster, "progs/dog.mdl");
		setsize(monster, '-32 -32 -24', '32 32 40');
		org = org + '0 0 24';
		monster.classname = "monster_dog";
		monster.health = 25;
		monster.th_stand = dog_stand1;
		monster.th_walk = dog_walk1;
		monster.th_run = dog_run1;
		monster.th_pain = dog_pain;
		monster.th_die = dog_die;
		monster.th_melee = dog_atta1;
		monster.th_missile = dog_leap1;
	}
	else if (class == "demon") {
		setmodel(monster, "progs/demon.mdl");

		setsize(monster, VEC_HULL2_MIN, VEC_HULL2_MAX);
		monster.classname = "monster_demon1";
		monster.health = 300;
		org = org + '0 0 48';
		monster.th_stand = demon1_stand1;
		monster.th_walk = demon1_walk1;
		monster.th_run = demon1_run1;
		monster.th_die = demon_die;
		monster.th_melee = Demon_MeleeAttack;
		monster.th_missile = demon1_jump1;
		monster.th_pain = demon1_pain;
	}
	else if (class == "ogre" || class == "ogre_boss") {	// ROGUE: add Multigrenade Ogre
		setmodel(monster, "progs/ogre.mdl");
		setsize(monster, VEC_HULL2_MIN, VEC_HULL2_MAX);
		monster.classname = "monster_ogre";
		monster.health = 200;
		org = org + '0 0 32';
		monster.th_stand = ogre_stand1;
		monster.th_walk = ogre_walk1;
		monster.th_run = ogre_run1;
		monster.th_die = ogre_die;
		monster.th_melee = ogre_melee;
		monster.th_missile = ogre_nail1;
		monster.th_pain = ogre_pain;
		// ROGUE: Multigrenade Ogre
		if (class == "ogre_boss") {
			monster.spawnflags |= 2;
			monster.skin = 1;
		}
	}
	else if (class == "grunt") {
		setmodel(monster, "progs/soldier.mdl");
		setsize(monster, '-16 -16 -24', '16 16 40');
		monster.classname = "monster_army";
		monster.health = 30;
		org = org + '0 0 24';
		monster.th_stand = army_stand1;
		monster.th_walk = army_walk1;
		monster.th_run = army_run1;
		monster.th_missile = army_atk1;
		monster.th_pain = army_pain;
		monster.th_die = army_die;
	}
	else if (class == "enforcer") {
		setmodel(monster, "progs/enforcer.mdl");
		setsize(monster, '-16 -16 -24', '16 16 40');
		monster.classname = "monster_enforcer";
		monster.health = 80;
		org = org + '0 0 24';
		monster.th_stand = enf_stand1;
		monster.th_walk = enf_walk1;
		monster.th_run = enf_run1;
		monster.th_pain = enf_pain;
		monster.th_die = enf_die;
		monster.th_missile = enf_atk1;
	}
	else if (class == "shambler") {
		setmodel(monster, "progs/shambler.mdl");
		setsize(monster, VEC_HULL2_MIN, VEC_HULL2_MAX);
		monster.classname = "monster_shambler";
		monster.health = 600;
		org = org + '0 0 32';
		monster.th_stand = sham_stand1;
		monster.th_walk = sham_walk1;
		monster.th_run = sham_run1;
		monster.th_die = sham_die;
		monster.th_melee = sham_melee;
		monster.th_missile = sham_magic1;
		monster.th_pain = sham_pain;
		self.qccFlags |= QCC_FL_REINFORCED;
		self.qccFlags |= QCC_FL_RESIST_ROCKET;
		self.qccFlags |= QCC_FL_RESIST_LIGHT;
	}
	else if (class == "shalrath") {
		setmodel(monster, "progs/shalrath.mdl");
		setsize(monster, VEC_HULL2_MIN, VEC_HULL2_MAX);
		monster.classname = "monster_shalrath";
		org = org + '0 0 32';
		monster.health = 400;
		monster.th_stand = shal_stand;
		monster.th_walk = shal_walk1;
		monster.th_run = shal_run1;
		monster.th_die = shalrath_die;
		monster.th_pain = shalrath_pain;
		monster.th_missile = shal_attack1;
	}
	else if (class == "wizard") {
		setmodel(monster, "progs/wizard.mdl");
		monster.flags = monster.flags | FL_FLY; // special behavior
		monster.classname = "monster_wizard";
		setsize(monster, VEC_HULL_MIN, VEC_HULL_MAX);
		org = org + '0 0 32';
		monster.health = 80;
		monster.th_stand = wiz_stand1;
		monster.th_walk = wiz_walk1;
		monster.th_run = wiz_run1;
		monster.th_missile = Wiz_Missile;
		monster.th_pain = Wiz_Pain;
		monster.th_die = wiz_die;
	}
	else if (class == "zombie") {
		setmodel(monster, "progs/zombie.mdl");
		setsize(monster, '-16 -16 -24', '16 16 40');
		monster.classname = "monster_zombie";
		org = org + '0 0 32';
		monster.health = 60;
		monster.th_stand = zombie_stand1;
		monster.th_walk = zombie_walk1;
		monster.th_run = zombie_run1;
		monster.th_pain = zombie_pain;
		monster.th_die = zombie_die;
		monster.th_missile = zombie_missile;
		monster.target = string_null; // don't target anything!
	}
	// SCOURGE OF ARMAGON ==============================================
	else if (class == "scourge") {
		setmodel(monster, "progs/scor.mdl");
		setsize(monster, VEC_HULL2_MIN, VEC_HULL2_MAX);
		monster.classname = "monster_scourge";
		org = org + '0 0 32';
		monster.health = 300;
		monster.th_stand = scourge_stand1;
		monster.th_walk = scourge_walk1;
		monster.th_run = scourge_run1;
		monster.th_pain = scourge_pain;
		monster.th_die = scourge_die;
		monster.th_melee = scourge_melee;
		monster.th_missile = scourge_atk1;
	}
	else if (class == "gremlin") {
		if (NumGremlins < 25) // Limit gremlins, this can get pretty crazy pretty quick
			NumGremlins += 1;
		setmodel(monster, "progs/grem.mdl");
		setsize(monster, VEC_HULL_MIN, VEC_HULL_MAX);
		monster.classname = "monster_gremlin";
		org = org + '0 0 24';
		monster.health = 100;
		monster.max_health = 101;
		monster.yaw_speed = 40;
		monster.th_stand = gremlin_stand1;
		monster.th_walk = gremlin_walk1;
		monster.th_run = gremlin_run1;
		monster.th_die = gremlin_die;
		monster.th_melee = Gremlin_MeleeAttack;     // one of two attacks
		monster.th_missile = Gremlin_MissileAttack; // check for random jump or firing of weapon
		monster.th_pain = gremlin_pain;
	}
	// DISSOLUTION OF ETERNITY ===========================================
	else if (class == "sword") {
		setmodel(monster, "progs/sword.mdl");
		setsize(monster, '-16 -16 -24', '16 16 40');
		org = org + '0 0 24';
		monster.classname = "monster_sword";
		monster.health = 150;
		monster.th_stand = sword_stand1;
		monster.th_walk = sword_stand1;
		monster.th_run = sword_pause;
		monster.th_melee = sword_atk1;
		monster.th_pain = sword_pain;
		monster.th_die = sword_die;
	}
	else if (class == "mummy") {
		setmodel(monster, "progs/mummy.mdl");
		setsize(monster, VEC_HULL_MIN, VEC_HULL_MAX);
		monster.classname = "monster_mummy";
		org = org + '0 0 32';
		monster.health = 500;
		monster.th_stand = mummy_stand1;
		monster.th_walk = mummy_walk1;
		monster.th_run = mummy_run1;
		monster.th_missile = mummy_missile;
		monster.th_pain = mummy_pain;
		monster.th_die = mummy_die;
	}
	else if (class == "morph") {
		rand = random() * 3;
		if (rand < 1)
			monster.model = "progs/morph_az.mdl"; // Aztec
		else if (rand < 2)
			monster.model = "progs/morph_eg.mdl"; // Egyptian
		else
			monster.model = "progs/morph_gr.mdl"; // Greek
		setsize(monster, VEC_HULL_MIN, VEC_HULL_MAX);
		monster.classname = "monster_morph";
		org = org + '0 0 24';
		monster.health = 2000;
		monster.th_stand = morph_stand1;
		monster.th_walk = morph_walk1;
		monster.th_run = morph_run1;
		monster.th_melee = morph_attack;
		monster.th_missile = morph_fire1;
		monster.th_pain = morph_pain;
		monster.th_die = morph_die;
	}
	else if (class == "wrath") {
		setmodel(monster, "progs/wrath.mdl");
		monster.flags = monster.flags | FL_FLY;
		monster.classname = "monster_wrath";
		setsize(monster, VEC_HULL_MIN, VEC_HULL_MAX);
		org = org + '0 0 32';
		monster.health = 400;
		monster.yaw_speed = 35;
		monster.th_stand = wrath_stand1;
		monster.th_walk = wrath_walk01;
		monster.th_run = wrath_run01;
		monster.th_missile = wrath_attack;
		monster.th_pain = wrath_pain;
		monster.th_die = wrath_die02;
	}
	else if (class == "super_wrath") {
		setmodel(monster, "progs/s_wrath.mdl");
		monster.flags = monster.flags | FL_FLY;
		monster.classname = "monster_wrath";
		setsize(monster, VEC_HULL_MIN, VEC_HULL_MAX);
		org = org + '0 0 32';
		monster.health = 1000;
		monster.yaw_speed = 35;
		monster.th_stand = overlord_stand1;
		monster.th_walk = overlord_walk01;
		monster.th_run = overlord_run01;
		monster.th_missile = overlord_missile;
		monster.th_melee = overlord_melee;
		monster.th_pain = overlord_pain;
		monster.th_die = overlord_die02;
	}
	else
		dprint("ERROR: No monster provided");
	// finish the shared settings
	setorigin(monster, org);
	monster.origin_z = monster.origin_z + 1;	// raise off floor a bit
	
	// temporarily swap self for next funcs
	oself = self;
	self = monster;
	
	if (class != "wizard")
		droptofloor();
	
	if (!walkmove(0,0)) {
		dprint ("walkmonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}
	
	if (class == "morph") {
		morph_setup(self);
		self.health = 1000;
		morph_wake31();
	}
	
	// resume normal self behavior
	self = oself;

	monster.category = CATEGORY_MONSTER;
	monster.takedamage = DAMAGE_AIM;
	monster.ideal_yaw = monster.angles * '0 1 0';
	if (!monster.yaw_speed)
		monster.yaw_speed = 20;
	monster.view_ofs = '0 0 25';
	monster.use = monster_use;
	
	monster.flags = monster.flags | FL_MONSTER;

	
	monster.enemy = HordeFindTarget(); // find a random living player
	monster.think = FoundTarget;
	monster.nextthink = time + 0.1;
	
	spawn_tdeath_fast (monster.origin, monster);
	
	monster.owner = self;
	if (monster.classname != "monster_zombie") // don't count zombies toward total goal
		total_monsters = total_monsters + 1;	
	
	return monster;
};