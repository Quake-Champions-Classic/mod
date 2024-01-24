/*
======================================================
CHAMPION SPAWNING
======================================================
*/
// Will replace the player spawning code in client.qc
// This way we can have champion picking and custom player models
void() QCC_SpawnChampion = {
	float armorbit;

	self.qccAbilityString = "Ability";
	self.qccAbilityCost = QCC_GLOBAL_COOLDOWN;
	self.qccPreThink = QCC_MovePreThink;
	self.qccPostThink = QCC_MovePostThink;
	self.qccAttackFunc = W_Attack;
	self.qccInteractFunc = SUB_Null;
	self.qccJumpFunc = SUB_Null;
	self.qccBotPreThink = SUB_Null;
	self.qccBotPostThink = SUB_Null;
	self.qccSelfDamage = 0;
	self.qccArmorType2 = 0;
	self.qccFlags = 0;
	self.touch = SUB_Null;
	self.qccAbilityOwner = self;
	self.qccMoveSpeed = 1.0;
	self.qccSkinFunc = QCC_SwapSkin;
	self.qccGibSkins = 1;
	if (self.impulse == QCC_IM_ABILITY) // try to prevent ability use on respawn
		self.impulse = 0;
	stuffcmd(self, "v_cshift 1 1 1 1\n"); // reset view color in case it doesn't get reset after death

	// Cleanup ability stuff if swapped champs
	if (self.qccNextChampion != self.qccChampion) {
		if (self.qccAbilityEnt != world) {
			self.qccAbilityEnt.think = SUB_Remove;
			self.qccAbilityEnt.nextthink = time;
			self.qccAbilityEnt = world;
		}
	}

	switch (self.qccNextChampion) {
		case QCC_RANGER:
			QCC_Ranger(); break;
		case QCC_DEATHKNIGHT:
			QCC_DeathKnight(); break;
		case QCC_NYX:
			QCC_Nyx(); break;
		case QCC_DOOMSLAYER:
			QCC_DoomSlayer(); break;
		case QCC_KEEN:
			QCC_Keen(); break;
		case QCC_KEEL:
			QCC_Keel(); break;
		case QCC_SCALEBEARER:
			QCC_Scalebearer(); break;
		case QCC_SORLAG:
			QCC_Sorlag(); break;
		case QCC_SLASH:
			QCC_Slash(); break;
		case QCC_ANARKI:
			QCC_Anarki(); break;
		case QCC_GALENA:
			QCC_Galena(); break;
		case QCC_DUKENUKEM:
			QCC_DukeNukem(); break;
		case QCC_DUSKDUDE:
			QCC_DuskDude(); break;
		case QCC_BIGJOHN:
			QCC_BigJohn(); break;
		default:
			QCC_Ranger(); break;
	}
	
	// Size and View Offset need to be set after setting the new model, or weird things can happen
	self.modelindex_champ = self.modelindex;
	if (!(self.qccFlags & QCC_FL_CUSTOM_SIZE))
		setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	if (!(self.qccFlags & QCC_FL_CUSTOM_VIEW))
		self.view_ofs = '0 0 22';
	
	self.velocity = '0 0 0';	// 1998-07-21 Player moves after respawn fix by Xian
	self.qccChampion = self.qccNextChampion;
	parm16 = self.qccChampion;
	
	// Reset ability timer, just in case
	if (self.qccAbilityTimer > time + QCC_GLOBAL_COOLDOWN)
		self.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
	else if (self.qccAbilityTimer < 0)
		self.qccAbilityTimer = 0;
	
	self.qccDoubleJump = 0;

	if (self.qccClass == QCC_LIGHT) {
		if (deathmatch || world.model == "maps/start.bsp")
			self.armorvalue = 0;
		self.qccMaxArmor = 75;
		armorbit = IT_ARMOR1;
	}
	else if (self.qccClass == QCC_MEDIUM) {
		if (deathmatch || world.model == "maps/start.bsp")
			self.armorvalue = 50;
		self.qccMaxArmor = 100;
		armorbit = IT_ARMOR2;
	}
	else if (self.qccClass == QCC_HEAVY) {
		if (deathmatch || world.model == "maps/start.bsp")
			self.armorvalue = 100;
		self.qccMaxArmor = 125;
		armorbit = IT_ARMOR3;
	}
	self.items = self.items - (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + armorbit;
	self.armortype = 0.67;
	
	if (self.weapon == QCC_ABILITY) {
		self.weapon = IT_SHOTGUN;
		self.weapon = W_BestWeapon();
	}
	W_SetCurrentAmmo();
	if (self.th_stand)
		self.th_stand();
	else
		player_stand();
};

void(float pick_dir) QCC_PickChampion = {
	// Some champ abilities can break respawning, like Ghost Walk
	if (self.weapon == QCC_ABILITY || self.qccAbilityTimer < 0)
		return;

	if (ExtSupported("EX_PROMPT")) {
		prompt(self, "Choose your Champion", QCC_CHAMPS_MAX);
		promptchoice(self, "Ranger", QCC_IM_CHAMPSTART + QCC_RANGER);
		promptchoice(self, "Death Knight", QCC_IM_CHAMPSTART + QCC_DEATHKNIGHT);
		promptchoice(self, "Nyx", QCC_IM_CHAMPSTART + QCC_NYX);
		promptchoice(self, "Doom Slayer", QCC_IM_CHAMPSTART + QCC_DOOMSLAYER);
		promptchoice(self, "Commander Keen", QCC_IM_CHAMPSTART + QCC_KEEN);
		promptchoice(self, "Keel", QCC_IM_CHAMPSTART + QCC_KEEL);
		promptchoice(self, "Scalebearer", QCC_IM_CHAMPSTART + QCC_SCALEBEARER);
		promptchoice(self, "Sorlag", QCC_IM_CHAMPSTART + QCC_SORLAG);
		promptchoice(self, "Slash", QCC_IM_CHAMPSTART + QCC_SLASH);
		promptchoice(self, "Anarki", QCC_IM_CHAMPSTART + QCC_ANARKI);
		promptchoice(self, "Galena", QCC_IM_CHAMPSTART + QCC_GALENA);
		promptchoice(self, "Duke Nukem", QCC_IM_CHAMPSTART + QCC_DUKENUKEM);
		promptchoice(self, "The Intruder", QCC_IM_CHAMPSTART + QCC_DUSKDUDE);
		promptchoice(self, "Big John", QCC_IM_CHAMPSTART + QCC_BIGJOHN);
	}
	else {
		self.qccNextChampion += pick_dir;
		if (self.qccNextChampion >= QCC_CHAMPS_MAX)
			self.qccNextChampion = 0;
		else if (self.qccNextChampion < 0)
			self.qccNextChampion = QCC_CHAMPS_MAX - 1;
		QCC_PickChampion2();
	}
};

void() QCC_PickChampion2 = {
	string champ_string;

	if (ExtSupported("EX_PROMPT"))
		clearprompt(self);
	
	if (ExtSupported("EX_CENTERPRINT")) {
		switch (self.qccNextChampion) {
			case QCC_RANGER:
				champ_string = "the Ranger"; break;
			case QCC_DEATHKNIGHT:
				champ_string = "the Death Knight"; break;
			case QCC_NYX:
				champ_string = "Nyx"; break;
			case QCC_DOOMSLAYER:
				champ_string = "the Doom Slayer"; break;
			case QCC_KEEN:
				champ_string = "Commander Keen"; break;
			case QCC_KEEL:
				champ_string = "Keel"; break;
			case QCC_SCALEBEARER:
				champ_string = "the Scalebearer"; break;
			case QCC_SORLAG:
				champ_string = "Sorlag"; break;
			case QCC_SLASH:
				champ_string = "Slash"; break;
			case QCC_ANARKI:
				champ_string = "Anarki"; break;
			case QCC_GALENA:
				champ_string = "Galena"; break;
			case QCC_DUKENUKEM:
				champ_string = "Duke Nukem"; break;
			case QCC_DUSKDUDE:
				champ_string = "the Intruder"; break;
			case QCC_BIGJOHN:
				champ_string = "Big John"; break;
			default:
				self.qccNextChampion = QCC_RANGER; champ_string = "the Ranger"; break;
		}
	}
	
	if (coop || !deathmatch || time - self.ltime < 15) {
		if (self.qccChampion == QCC_OBSERVER) // observer has to rebuild the player because we fuck it up so much
			PutClientInServer();
		else
			QCC_SpawnChampion();
		
		if (ExtSupported("EX_CENTERPRINT"))
			centerprint(self, "You are now {}", champ_string); // might be able to add language support later
		else {
			switch (self.qccNextChampion) {
				case QCC_RANGER:
					centerprint(self, "You are now the Ranger"); break;
				case QCC_DEATHKNIGHT:
					centerprint(self, "You are now the Death Knight"); break;
				case QCC_NYX:
					centerprint(self, "You are now Nyx"); break;
				case QCC_DOOMSLAYER:
					centerprint(self, "You are now the Doom Slayer"); break;
				case QCC_KEEN:
					centerprint(self, "You are now Commander Keen"); break;
				case QCC_KEEL:
					centerprint(self, "You are now Keel"); break;
				case QCC_SCALEBEARER:
					centerprint(self, "You are now the Scalebearer"); break;
				case QCC_SORLAG:
					centerprint(self, "You are now Sorlag"); break;
				case QCC_SLASH:
					centerprint(self, "You are now Slash"); break;
				case QCC_ANARKI:
					centerprint(self, "You are now Anarki"); break;
				case QCC_GALENA:
					centerprint(self, "You are now Galena"); break;
				case QCC_DUKENUKEM:
					centerprint(self, "You are now Duke Nukem"); break;
				case QCC_DUSKDUDE:
					centerprint(self, "You are now the Intruder"); break;
				case QCC_BIGJOHN:
					centerprint(self, "You are now Big John"); break;
			}
		}
	}
	else {
		if (ExtSupported("EX_CENTERPRINT"))
			centerprint(self, "You will respawn as {}", champ_string);
		else {
			switch (self.qccNextChampion) {
				case QCC_RANGER:
					centerprint(self, "You will respawn as the Ranger"); break;
				case QCC_DEATHKNIGHT:
					centerprint(self, "You will respawn as the Death Knight"); break;
				case QCC_NYX:
					centerprint(self, "You will respawn as Nyx"); break;
				case QCC_DOOMSLAYER:
					centerprint(self, "You will respawn as Doom Slayer"); break;
				case QCC_KEEN:
					centerprint(self, "You will respawn as Commander Keen"); break;
				case QCC_KEEL:
					centerprint(self, "You will respawn as Keel"); break;
				case QCC_SCALEBEARER:
					centerprint(self, "You will respawn as the Scalebearer"); break;
				case QCC_SORLAG:
					centerprint(self, "You will respawn as Sorlag"); break;
				case QCC_SLASH:
					centerprint(self, "You will respawn as Slash"); break;
				case QCC_ANARKI:
					centerprint(self, "You will respawn as Anarki"); break;
				case QCC_GALENA:
					centerprint(self, "You will respawn as Galena"); break;
				case QCC_DUKENUKEM:
					centerprint(self, "You will respawn as Duke Nukem"); break;
				case QCC_DUSKDUDE:
					centerprint(self, "You will respawn as the Intruder"); break;
				case QCC_BIGJOHN:
					centerprint(self, "You will respawn as Big John"); break;
			}
		}
	}
};

void() QCC_PreThinkImpulse = {
	if (self.impulse >= QCC_IM_CHAMPSTART && self.impulse <= QCC_IM_CHAMPSTART + QCC_CHAMPS_MAX) {
		self.qccNextChampion = self.impulse - QCC_IM_CHAMPSTART;
		QCC_PickChampion2();
		self.impulse = 0;
	}
	else
		return;
};

void(float max_skins) QCC_SetSkin = {
	self.qccMaxSkins = max_skins;
	self.qccSkin = self.qccSkin % self.qccMaxSkins;
	// Team play sets skins accordingly; Most engines automatically set team based upon pants color
	if (teamplay > 0 && self.team > -1 && !coop) {
		self.skin = self.team % self.qccMaxSkins;
		// Doom Slayer on Green Team should be green, not black
		if (self.qccChampion == QCC_DOOMSLAYER && self.team == 4)
			self.skin = 0;
	}
	// In the remaster, non-team modes set Team to -1, so we'll keep track of skins a a different way as a fallback
	else
		self.skin = self.qccSkin;
};

// Skins are complicated
void() QCC_SwapTeam = {
	string team_color;

	self.team += 1;
	if (self.team >= QCC_MAX_TEAMS)
		self.team = 0;
	
	self.qccSkin = self.team;
	if (self.qccSkin >= self.qccMaxSkins)
		self.qccSkin = self.team % self.qccMaxSkins;

	// Some champs need exceptions
	switch (self.qccChampion) {
		case QCC_DOOMSLAYER: {
			if (self.team == QCC_TEAM_GREEN)
				self.qccSkin = 0; // need to set to green manually because Doom Slayer's 4th skin is black like in the OG games
				break;
			}
	}

	self.skin = self.qccSkin;

	switch (self.team) {
		case QCC_TEAM_RED: team_color = "Red"; break;
		case QCC_TEAM_BLUE: team_color = "Blue"; break;
		case QCC_TEAM_YELLOW: team_color = "Yellow"; break;
		case QCC_TEAM_GREEN: team_color = "Green"; break;
	}

	if (ExtSupported("EX_BPRINT"))
		bprint("{} has joined the {} Team\n", self.netname);
	else {
		bprint(self.netname);
		bprint(" has joined the ");
		bprint(team_color);
		bprint(" Team\n");
	}
}

// Called by impulse 137
void() QCC_SwapSkin = {
	if (teamplay > 0 && !coop) {
		QCC_SwapTeam();
		return;
	}
	
	self.qccSkin += 1;
	if (self.qccSkin >= self.qccMaxSkins)
		self.qccSkin = self.qccSkin % self.qccMaxSkins;
	self.skin = self.qccSkin;

	string sn = ftos(self.skin);
	switch (self.skin) {
		case 0: sn = "default"; break;
		case 1: sn = "Red Team"; break;
		case 2: sn = "Blue Team"; break;
		case 3: sn = "Yellow Team"; break;
		case 4: {
			if (self.qccChampion != QCC_DOOMSLAYER) { sn = "Green Team"; break; }
			else { sn = "Black"; break; } // Doom Slayer's 4th color is actually black
		}
	}
	if (ExtSupported("EX_SPRINT"))
		sprint(self, "Changed appearance to {}\n", sn);
	else {
		sprint(self, "Changed appearance to ");
		sprint(self, sn);
		sprint(self, "\n");
	}
};

void() QCC_CheckArmorRot = {
	if (self.qccArmorRot_nextcheck > time)
		return;

	if (self.armorvalue > self.qccMaxArmor) {
        self.armorvalue -= 1;
		if (self.qccClass != QCC_HEAVY)
			self.qccArmorRot_nextcheck = time + 1;
		else
			self.qccArmorRot_nextcheck = time + 2;
		return;
	}

	self.qccArmorRot_nextcheck = 0;
};

/*
========================================================================
QCC: MOVEMENT METHODS
Common movement methods for Champions. Mostly differentiation between the varying weight classes.
========================================================================
*/
void() QCC_MovePreThink = {
	// Commander Keen Neural Stunner effect
	if (self.qccStunned > time) {
		self.velocity_x = 0;
		self.velocity_y = 0;
	}
	else {
		self.velocity_x *= self.qccMoveSpeed;
		self.velocity_y *= self.qccMoveSpeed;
	}
};

void() QCC_MovePostThink = {
	self.qccLastVelocity = self.velocity;
	// Commander Keen Neural Stunner effect
	if (self.qccStunned > time) {
		self.velocity_x = 0;
		self.velocity_y = 0;
	}
	else if (self.qccMoveSpeed != 0) {
		self.velocity_x /= self.qccMoveSpeed;
		self.velocity_y /= self.qccMoveSpeed;
	}
};


/*
========================================================================
QCC: THROWABLE HEAD QUEUE
Used to regulate number of head gibs in multiplayer
========================================================================
*/
float qcc_throwhead_ct;

void() qcc_throwhead = {}; // safe than sorry

void(entity ent) QCC_ThrowheadQueue = {
	entity throwhead, oldhead;
	throwhead = spawn();
	throwhead.qccFlags = ent.qccFlags;
	throwhead.touch = ent.touch;
	throwhead.angles = ent.angles;
	throwhead.model = ent.model;
	throwhead.modelindex = ent.modelindex;
	throwhead.frame = ent.frame;
	throwhead.colormap = ent.colormap;
	if (ent.qccChampion == QCC_KEEN || ent.qccChampion == QCC_NYX)
		throwhead.skin = ent.skin;
	throwhead.solid = ent.solid;
	throwhead.movetype = ent.movetype;
	throwhead.velocity = ent.velocity;
	throwhead.flags = 0;
	throwhead.dmg = ent.dmg;
	setorigin(throwhead, ent.origin);
	setsize(throwhead, ent.mins, ent.maxs);
	throwhead.think = ent.think;
	throwhead.nextthink = ent.nextthink;
	if (ent.qccAbilityOwner.qccChampion == QCC_DUSKDUDE && ent.qccAbilityOwner != ent) {
		throwhead.qccAbilityOwner = ent.qccAbilityOwner;
		if (ent.qccAbilityOwner.qccAbilityEnt == ent)
			ent.qccAbilityOwner.qccAbilityEnt = throwhead;
		throwhead.owner = throwhead;
		throwhead.classname = "gibhead";
	}	
	else {
		throwhead.qccAbilityOwner = throwhead;
		if (qcc_throwhead_ct < 4)
			qcc_throwhead_ct += 1;
		else {
			oldhead = find(world, classname, "qcc_throwhead");
			if (oldhead != world)
				remove(oldhead);
		}
		throwhead.classname = "qcc_throwhead";
	}
};