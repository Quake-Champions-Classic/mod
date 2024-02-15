/*
===============================================================================
MAP RULES
===============================================================================
*/
void() NextLevel = {
	entity o;

	if (nextmap != string_null)
		return; // Already done

	// ID1
	if (mapname == "start" && !deathmatch) {
		if (!cvar("registered"))
			mapname = "e1m1";
		else if (!(serverflags & 1)) {
			mapname = "e1m1";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2)) {
			mapname = "e2m1";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4)) {
			mapname = "e3m1";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8)) {
			mapname = "e4m1";
			serverflags = serverflags - 7;
		} 
		o = spawn();
		o.map = mapname;
	}
	// MG1
	else if (world.model == "maps/mgdm1.bsp") {
		o = spawn();
		o.map = "mgdm2";
	}
	else if (world.model == "maps/mgdm2.bsp") {
		o = spawn();
		o.map = "mgdm3";
	}
	else if (world.model == "maps/mgdm3.bsp") {
		o = spawn();
		o.map = "mgdm4";
	}
	else if (world.model == "maps/mgdm4.bsp") {
		o = spawn();
		o.map = "mgdm1";
	}
	else {
		// Find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");
		if (!o || mapname == "start") {
			// Go back to same map if no trigger_changelevel
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = TRUE;
	if (o.nextthink < time) {
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
};

// Exit deathmatch games upon conditions
void() CheckRules = {
	float timelimit, fraglimit, endgame;
	
	if (gameover) // Someone else quit the game already
		return;
	
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	
	if (timelimit && time >= timelimit) {
		endgame = TRUE;
		if (deathmatch >= QCC_TDM) {
			if (qccTeamScore[QCC_TEAM_RED] > qccTeamScore[QCC_TEAM_BLUE] && 
				qccTeamScore[QCC_TEAM_RED] > qccTeamScore[QCC_TEAM_YELLOW] &&
				qccTeamScore[QCC_TEAM_RED] > qccTeamScore[QCC_TEAM_GREEN]) 
			{
				centerprint_all("Red Team Wins");
			}
			else if (qccTeamScore[QCC_TEAM_BLUE] > qccTeamScore[QCC_TEAM_RED] && 
				qccTeamScore[QCC_TEAM_BLUE] > qccTeamScore[QCC_TEAM_YELLOW] &&
				qccTeamScore[QCC_TEAM_BLUE] > qccTeamScore[QCC_TEAM_GREEN]) 
			{
				centerprint_all("Blue Team Wins");
			}
			else if (qccTeamScore[QCC_TEAM_YELLOW] > qccTeamScore[QCC_TEAM_BLUE] && 
				qccTeamScore[QCC_TEAM_YELLOW] > qccTeamScore[QCC_TEAM_RED] &&
				qccTeamScore[QCC_TEAM_YELLOW] > qccTeamScore[QCC_TEAM_GREEN]) 
			{
				centerprint_all("Yellow Team Wins");
			}
			else if (qccTeamScore[QCC_TEAM_GREEN] > qccTeamScore[QCC_TEAM_BLUE] && 
				qccTeamScore[QCC_TEAM_GREEN] > qccTeamScore[QCC_TEAM_YELLOW] &&
				qccTeamScore[QCC_TEAM_GREEN] > qccTeamScore[QCC_TEAM_RED]) 
			{
				centerprint_all("Green Team Wins");
			}
			else 
				centerprint_all("Tie Game!");

		}
	}
	
	if (fraglimit) {
		if (self.frags >= fraglimit)
			endgame = TRUE;
		
		if (deathmatch >= QCC_TDM) {
			if (qccTeamScore[QCC_TEAM_RED] >= fraglimit)
				centerprint_all("Red Team Wins");
			else if (qccTeamScore[QCC_TEAM_BLUE] >= fraglimit)
				centerprint_all("Blue Team Wins");
			else if (qccTeamScore[QCC_TEAM_YELLOW] >= fraglimit)
				centerprint_all("Yellow Team Wins");
			else if (qccTeamScore[QCC_TEAM_GREEN] >= fraglimit)
				centerprint_all("Green Team Wins");
		}
	}

	if (!endgame)
		return;
	
	NextLevel();
};

// Use this function when adding or subtracting player flags, so that we can keep better track of our teamplay
void(entity fragger, float new_frags) add_frag = {
	entity pl;
	// Only add frags if we're not playing CTF
	if (deathmatch <= QCC_TDM) {
		fragger.frags += new_frags;
		if (deathmatch == QCC_TDM) {
			if (fragger.classname == "player" && fragger.team > QCC_TEAM_NONE && fragger.team < QCC_MAX_TEAMS) {
				qccTeamScore[fragger.team - 1] += new_frags;
				pl = find(world, classname, "player");
				while (pl != world) {
					if (pl != fragger && pl.team == fragger.team)
						pl.frags += new_frags;
					pl = find(pl, classname, "player");
				}
			}
		}
	}
}

// Use this function for capturing flags or accumulating soul points in sacrifice
void(entity scorer, float new_score) add_score = {
	entity pl;
	if (deathmatch >= QCC_CTF) {
		if (scorer.classname == "player" && scorer.team > QCC_TEAM_NONE && scorer.team < QCC_MAX_TEAMS) {
			qccTeamScore[scorer.team] += new_score;
			pl = find(world, classname, "player");
			while (pl != world) {
				if (pl.team == scorer.team)
					pl.frags = qccTeamScore[scorer.team] += new_score;
				pl = find(pl, classname, "player");
			}
		}
	}
}

void() update_deathmatch_mode = {
	entity oself;

	deathmatch = cvar("deathmatch");

	switch (deathmatch) {
		case QCC_CAMPAIGN: {
			if (isHordeMode)
				centerprint_all("You are playing Horde Mode");
			else if (coop)
				centerprint_all("You are playing Coop");
			else
				centerprint_all("You are playing Single Player");
			return;			
		}
		case QCC_FFA:
		case QCC_FFA2:
			centerprint_all("You are playing Deathmatch Free For All"); break;		
		case QCC_DUEL:
			centerprint_all("You are playing Duel"); break;		
		case QCC_TDM:
			centerprint_all("You are playing Team Deathmatch"); break;
		case QCC_CTF:
			centerprint_all("You are playing Capture the Flag"); break;		
		default:
			centerprint_all("Unknown Deathmatch Mode"); break;
	}

	if (deathmatch >= QCC_TDM) {
		oself = self;
		self = find(world, classname, "player");
		while (self != world) {
			self.team = self.qccSkin % QCC_MAX_TEAMS;
			if (self.flags & FL_ISBOT) // Bots should only pick red or blue team
				self.team = rint(random() * 32678) % 2 + 1;
			self.team -= 1;
			QCC_SwapTeam();
			self = find(self, classname, "player");
		}
		self = oself;
	}
}