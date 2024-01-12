/*
=====================================
HORDE WAVE SPAWNING
=====================================
*/

void() Wavecheck;

.float	fodder; // how many fodder squads to spawn
.float	elites; // how many elite squads to spawn
.float	bosses; // how many bosses to spawn
.float	army; // Spawn Army? True/fallse
float(entity spawnpoint) CheckBlockedSpawn;
float SPAWN_RESET_TIME = 5; // amount of time that a spawn point is considered occupied and not valid for use

/* 
SpawnSquad2

Yoder FEB02 2022
*/
void(string name, vector org, vector temp_angles) SpawnSquad2 = {
	if (name == "3 grunts") {
		if (skill > 0) {
			SpawnMonster("grunt", org + '0 -40 0', temp_angles);
			SpawnMonster("grunt", org + '40 40 0', temp_angles);
			SpawnMonster("grunt", org + '-40 40 0', temp_angles);
		}
		else {
			SpawnMonster("grunt", org + '-40 0 0', temp_angles);
			SpawnMonster("grunt", org + '40 0 0', temp_angles);
		}
	}
	else if (name == "2 grunts, 1 dog") {
		SpawnMonster("dog", org + '44 0 0', temp_angles);
		SpawnMonster("grunt", org + '-40 -40 0', temp_angles);
		SpawnMonster("grunt", org + '-40 40 0', temp_angles);
	}
	else if (name == "2 dogs") {
		if (skill > 0) {
			SpawnMonster("dog", org + '-0 -44 0', temp_angles);
			SpawnMonster("dog", org + '0 44 0', temp_angles);
		}
		else
			SpawnMonster("dog", org + '-0 -44 0', temp_angles);
	}
	else if (name == "1 enforcer")
		SpawnMonster("enforcer", org + '0 0 0', temp_angles);
	else if (name == "2 enforcers") {
		if (skill > 0) {
			SpawnMonster("enforcer", org + '40 0 0', temp_angles);
			SpawnMonster("enforcer", org + '-40 0 0', temp_angles);	
		}
		else
			SpawnMonster("enforcer", org + '0 0 0', temp_angles);
	}
	else if (name == "1 ogre")
		SpawnMonster("ogre", org + '0 0 0', temp_angles);
	else if (name == "2 knights") {
		if (skill > 0) {
			SpawnMonster("knight", org + '40 0 0', temp_angles);
			SpawnMonster("knight", org + '-40 0 0', temp_angles);
		}
		else
			SpawnMonster("knight", org + '40 0 0', temp_angles);			
	}
	else if (name == "2 zombies") {
		SpawnMonster("zombie", org + '40 0 0', temp_angles);
		SpawnMonster("zombie", org + '-40 0 0', temp_angles);
	}
	else if (name == "1 wizard")
		SpawnMonster("wizard", org + '0 0 0', temp_angles);
	else if (name == "2 hellknights") {
		if (skill > 0) {
			SpawnMonster("hellknight", org + '0 40 0', temp_angles);
			SpawnMonster("hellknight", org + '0 -40 0', temp_angles);
		}
		else
			SpawnMonster("hellknight", org + '0 40 0', temp_angles);
	}
	else if (name == "2 knights, 1 hellknight") {
		SpawnMonster("hellknight", org + '40 0 0', temp_angles);
		SpawnMonster("knight", org + '-40 40 0', temp_angles);
		SpawnMonster("knight", org + '-40 -40 0', temp_angles);
	}
	else if (name == "3 wizards") {
		if (skill > 0) {
			SpawnMonster("wizard", org + '40 40 40', temp_angles);
			SpawnMonster("wizard", org + '-40 40 40', temp_angles);
			SpawnMonster("wizard", org + '-40 -40 40', temp_angles);
		}
		else {
			SpawnMonster("wizard", org + '40 40 40', temp_angles);
			SpawnMonster("wizard", org + '-40 40 40', temp_angles);
		}
	}
	else if (name == "shambler")
		SpawnMonster("shambler", org, temp_angles);
	else if (name == "double demon") {
		if (skill >= 3 && random() > 0.8) {
			// double shambler
			SpawnMonster("shambler", org + '40 40 0', temp_angles);
			SpawnMonster("shambler", org + '-40 -40 0', temp_angles);
		}
		else if (skill >= 1) {
			SpawnMonster("demon", org + '40 40 0', temp_angles);
			SpawnMonster("demon", org + '-40 -40 0', temp_angles);
		}
		else
			SpawnMonster("demon", org, temp_angles);
	}
	else if (name == "shalrath")
		SpawnMonster("shalrath", org, temp_angles);
	// HIPNOTIC ----------------------------------------------------------
	else if (name == "1 scourge")
		SpawnMonster("scourge", org, temp_angles);
	else if (name == "double scourge") {
		if (skill >= 1) {
			SpawnMonster("scourge", org + '40 40 0', temp_angles);
			SpawnMonster("scourge", org + '-40 -40 0', temp_angles);
		}
		else
			SpawnMonster("scourge", org, temp_angles);
	}
	else if (name == "2 grunts, 1 scourge") {
		SpawnMonster("scourge", org + '40 0 0', temp_angles);
		SpawnMonster("grunt", org + '-40 40 0', temp_angles);
		SpawnMonster("grunt", org + '-40 -40 0', temp_angles);
	}
	else if (name == "2 gremlins") {
		if (skill > 1) {
			SpawnMonster("gremlin", org + '-40 0 0', temp_angles);
			SpawnMonster("gremlin", org + '40 0 0', temp_angles);
		}
		else
			SpawnMonster("gremlin", org, temp_angles);
	}
	else if (name == "3 gremlins") {
		if (skill > 1) {    // gremlins like to spawn more gremlins, so this can get a bit much
			SpawnMonster("gremlin", org + '0 -40 0', temp_angles);
			SpawnMonster("gremlin", org + '40 40 0', temp_angles);
			SpawnMonster("gremlin", org + '-40 40 0', temp_angles);
		}
		else {
			SpawnMonster("gremlin", org + '-40 0 0', temp_angles);
			SpawnMonster("gremlin", org + '40 0 0', temp_angles);
		}
	}
	// ROGUE -------------------------------------------------------------
	else if (name == "2 swords") {
		SpawnMonster("sword", org + '-40 0 0', temp_angles);
		SpawnMonster("sword", org + '40 0 0', temp_angles);
	}
	else if (name == "mummy")
		SpawnMonster("mummy", org, temp_angles);
	else if (name == "morph")
		SpawnMonster("morph", org, temp_angles);
	else if (name == "wrath")
		SpawnMonster("wrath", org, temp_angles);
	else if (name == "2 wraths") {
		if (skill >= 1)
		{
			SpawnMonster("wrath", org + '40 40 0', temp_angles);
			SpawnMonster("wrath", org + '-40 -40 0', temp_angles);
		}
		else
			SpawnMonster("wrath", org, temp_angles);
	}
	else if (name == "super_wrath") {
		if (skill >= 1)
			SpawnMonster("super_wrath", org, temp_angles);
		else
			SpawnMonster("wrath", org, temp_angles);
	}
	// -------------------------------------------------------------------
	else
		dprint("ERROR: unrecognized squad name!\n");
	
	spawn_tfog(org);
};

/*
HordeFindSpawnpoint
Yoder February 2nd 2022
*/
float HORDE_SQUAD_TYPE_NORMAL = 0;
float HORDE_SQUAD_TYPE_RANGED = 1;
float HORDE_SQUAD_TYPE_FLYING = 2;
float HORDE_SQUAD_TYPE_BOSS = 3;

float HORDE_SQUAD_CAT_ERROR = -1;
float HORDE_SQUAD_CAT_FODDER = 0;
float HORDE_SQUAD_CAT_ELITE = 1;
float HORDE_SQUAD_CAT_BOSS = 2;

entity(float squad_type)HordeFindSpawnpoint = {
	float spawnpoint, temp_spawncount, loopcount, randomspawn;
	float temp_spawncount_valid; // how many of the spawn points are valid
	entity t;
	spawnpoint = 0;
	loopcount = 0;
	string squad_class;
	
	if (squad_type == HORDE_SQUAD_TYPE_BOSS)
		squad_class = "info_monster_start_boss";
	else if (squad_type == HORDE_SQUAD_TYPE_FLYING)
		squad_class = "info_monster_start_flying";
	else if (squad_type == HORDE_SQUAD_TYPE_RANGED)
		squad_class = "info_monster_start_ranged";
	else
		squad_class = "info_monster_start";
	
	// STEP 1: count all spawns of spawn type
	temp_spawncount = 0;
	temp_spawncount_valid = 0;

	// count the spawnpoints for squad_class
	t = find(world, classname, squad_class);
	while (t) {
		temp_spawncount++;
		if ((time > t.wait) && (!(t.spawnflags & START_OFF)) &&
			(!CheckBlockedSpawn(t)))
			temp_spawncount_valid++;
		t = find(t, classname, squad_class);
	}
	
	// verify against 0 valid spawns
	if (temp_spawncount_valid <= 0) {
		if (squad_type == HORDE_SQUAD_TYPE_NORMAL) {
			dprint("HordeFindSpawnPoint: FOUND 0 Valid spawns\n");
			return world; // already on fallback option, oops
		}
		else {
			squad_type = HORDE_SQUAD_TYPE_NORMAL;
			squad_class = "info_monster_start";
			t = world;
			loopcount = 1;
		}
	}
	
	// count again, but for Normal spawn points?
	if (loopcount) {
		temp_spawncount = 0;
		temp_spawncount_valid = 0;
		
		t = find(world, classname, squad_class);
		while (t) {
			temp_spawncount++;
			if ((time > t.wait) && (!(t.spawnflags & START_OFF)) &&
				(!CheckBlockedSpawn(t)))
				temp_spawncount_valid++;
			t = find(t, classname, squad_class);
		}
	}
	
	// verify against 0 valid spawns
	if (temp_spawncount_valid <= 0) {
		dprint("HordeFindSpawnPoint: FOUND 0 Valid spawns after recheck\n");
		return world; // already on fallback option, oops
	}
	
	// pick random spawncount
	loopcount = 0;
	randomspawn = temp_spawncount * random();
	dprint("randomspawn: ");dprint(ftos(randomspawn));
	dprint(" | whole count: ");dprint(ftos(temp_spawncount));
	dprint(" | valid count: ");dprint(ftos(temp_spawncount_valid));dprint("\n");
	t = find(world, classname, squad_class);
	while (t) {
		spawnpoint++;
		if (spawnpoint >= randomspawn) {
			if (!(t.spawnflags & START_OFF) && (time > t.wait) && (!(CheckBlockedSpawn(t)))) {
				dprint("picked spawnpoint: ");dprint(ftos(spawnpoint));dprint("\n");
				return t;
			}
		}
		t = find(t, classname, squad_class);
		
		if (!t) {
			if (loopcount)
				dprint("something has gone horribly wrong!\n");
			else {
				loopcount = 1;				
				t = find(t, classname, squad_class);
				spawnpoint = 0;
				randomspawn = 0; // allow any valid spawn
			}
		}
	}
	return world;
};

/*
SpawnWave2
Instead of finding a spawn point and then spawning a squad,
decide a squad, and then find a spawn point.
Yoder February 2nd 2022
*/
void() SpawnWave2 = {
	entity t, oself; // t is the temp spawn, oself is for temp storage of self
	float squad_type;
	string squad_name; // specific squad name
	float r; // random roll
	float squad_cat; //
	
	//STEP 1: determine what kind of monster is getting spawned
	if (self.army) {		
		if (self.fodder > 0) {
			r = random() * 4;
			if (r < 1)
				squad_name = "3 grunts";
			else if (r < 2)
				squad_name = "2 grunts, 1 dog";
			else if (r < 3.5)
				squad_name = "2 dogs";
			else {
				squad_name = "1 enforcer";
				squad_type = HORDE_SQUAD_TYPE_RANGED;
			}

			squad_cat = HORDE_SQUAD_CAT_FODDER;
		}
		else if (self.elites > 0) {
			squad_type = HORDE_SQUAD_TYPE_RANGED; 
			r = random() * 2;
			if (r < 1.5)
				squad_name = "2 enforcers";
			else
				squad_name = "1 scourge"; // HIP
			
			squad_cat = HORDE_SQUAD_CAT_ELITE;
		}
		else if (self.bosses > 0) {
			squad_name = "double scourge";
			squad_type = HORDE_SQUAD_TYPE_NORMAL;
		}
	}
	else {	// NON-ARMY
		if (self.fodder > 0) {
			r = random() * 8;
			if (r < 2)
				squad_name = "2 knights";
			else if (r < 4)
				squad_name = "2 gremlins"; // HIP
			else if (r < 5)
				squad_name = "2 zombies";
			else if (r < 7) {
				squad_name = "1 wizard";
				squad_type = HORDE_SQUAD_TYPE_FLYING;
			}
			else
				squad_name = "2 swords"; // ROGUE
			
			squad_cat = HORDE_SQUAD_CAT_FODDER;
		}
		else if (self.elites > 0) {
			r = random() * 9;
			if (r < 1)
				squad_name = "2 hellknights";
			else if (r < 2)
				squad_name = "2 knights, 1 hellknight";
			else if (r < 3)
				squad_name = "3 gremlins"; // HIP
			else if (r < 4) {
				squad_name = "1 ogre";
				squad_type = HORDE_SQUAD_TYPE_RANGED;
			}
			else if (r < 5) {
				squad_name = "3 wizards";
				squad_type = HORDE_SQUAD_TYPE_FLYING;
			}
			// ROGUE -------------------------------------
			else if (r < 6) {
				squad_name = "ogre boss";
				squad_type = HORDE_SQUAD_TYPE_RANGED;
			}
			else if (r < 8)
				squad_name = "mummy";
			else
				squad_name = "wrath";
			
			squad_cat = HORDE_SQUAD_CAT_ELITE;
		}
		else if (self.bosses > 0) {
			squad_type = HORDE_SQUAD_TYPE_BOSS;
			r = random();
			if (r < 0.2)
				squad_name = "shambler";
			else if (r < 0.6) {
				squad_name = "double demon";
				squad_type = HORDE_SQUAD_TYPE_NORMAL;
			}
			else if (r < 0.7)
				squad_name = "shalrath";
			// ROGUE -----------------------------------------------
			else if (r < 0.8)
				squad_name = "morph";
			else if (r < 0.9) {
				squad_name = "2 wraths";
				squad_type = HORDE_SQUAD_TYPE_NORMAL;
			}
			else
				squad_name = "super_wrath";
			// -----------------------------------------------------
			
			squad_cat = HORDE_SQUAD_CAT_BOSS;
		}
	}	
	
	//STEP 2: find a spawn point for the squad
	t = HordeFindSpawnpoint(squad_type);
	dprint("spawnpoint found was: ");dprint(t.classname);dprint("\n");
	if (t && (squad_cat != HORDE_SQUAD_CAT_ERROR)) {
		t.wait = time + SPAWN_RESET_TIME; // block spawnpoint from reuse for a duration
		
		// use targets
		oself = self;
		self = t;
		SUB_UseTargets();
		self = oself;
		
		// set angles, just in case
		if (!t.angles)
			t.angles = '0 0 0';
		
		SpawnSquad2(squad_name, t.origin, t.angles);
		WriteByte(MSG_ALL, SVC_UPDATESTAT);
		WriteByte(MSG_ALL, 12); // 12 = STAT_TOTALMONSTERS
		WriteLong(MSG_ALL, total_monsters);
		
		if (squad_cat == HORDE_SQUAD_CAT_FODDER)
			self.fodder--;
		else if (squad_cat == HORDE_SQUAD_CAT_ELITE)
			self.elites--;
		else if (squad_cat == HORDE_SQUAD_CAT_BOSS)
			self.bosses--;
		
		if ((self.fodder + self.elites + self.bosses) <= 0) { // max spawns hit
			dprint("wave spawn completed!\n");
			self.wait = FALSE;
			self.think = Wavecheck;
			self.nextthink = time + 30;
		}
		else {
			// normal spawnwave wait time
			self.think = SpawnWave2;
			self.nextthink = time + 1 + random() + 1;
		}
	}
	else {
		dprint("no valid spawns, wait a moment\n");
		self.think = SpawnWave2;
		self.nextthink = time + 1;
	}
};

/* SpawnWavePrep
called once at the countdown starts
determines the number of squads by type
also spawns ammo and items
*/
float() SpawnWavePrep = {
	entity p;
	float playercount, playerscalar;
	// Reset Key Spawn
	key_spawned = FALSE;
	
	// Respawn dead players!
	if (HordeGetPlayersAlive() < 1) {
		dprint("WARNING: Last player died at round end, don't start new round!\n");
		return 0;
	}
	
	// Items
	p = find(world, classname, "info_horde_item");
	while (p) {
		if (!p.wait) {
			p.think = SpawnItem;
			p.nextthink = time + random() * 2;
		}
		p = find(p, classname, "info_horde_item");
	}

	self.wave++;
	dprint("wave ");
	dprint(ftos(self.wave));
	dprint("\n");
	
	// See spreadsheet for notes on squad scaling
	
	// AY FEB07 scaling start wave based on difficulty
	float temp_wave;
	if (skill >= 3)
		temp_wave = self.wave + 6;
	else if (skill >= 2)
		temp_wave = self.wave + 3;
	else
		temp_wave = self.wave;
	
	// Determine if Army wave
	if ((temp_wave + 2) % 3 == 0)
		self.army = TRUE;
	else
		self.army = FALSE;
	
	// player scalar
	playercount = HordeGetPlayersAlive();
	if (playercount >= 4)
		playerscalar = 2;
	else if (playercount >= 3)
		playerscalar = 1.5;
	else if (playercount >= 2)
		playerscalar = 1.25;
	else
		playerscalar = 1;
	
	// Boss Count
	if (temp_wave % 3 == 0)
		self.bosses = floor((temp_wave+1)/4);
	else if ((skill > 1) && (temp_wave > 9)) // QCC: allow bosses in army waves
		self.bosses = floor((temp_wave+1)/8); //AY feb07, some extra spice
	
	// Elite Count
	self.elites = ceil((temp_wave - 1)/3) - floor(self.bosses/2);
	self.elites = floor(self.elites * playerscalar);
	
	// Fodder Count
	self.fodder = (temp_wave + 2) - (self.bosses * 2 + self.elites);
	self.fodder = floor(self.fodder * playerscalar);
	
	// Trigger map entities
	entity stemp;
	p = find(world, targetname, self.target);
	while (p) {
		stemp = self;
		self = p;
		if (self.use != SUB_Null) {
			if (self.use)
			self.use ();
		}
		self = stemp;
		p = find(p, targetname, self.target);
	}

	self.wait = TRUE;
	return 1;
}