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
		if (deathmatch >= QCC_TDM) {
			if (qccTeamScore[QCC_TEAM_RED] >= fraglimit) {
				endgame = TRUE;
				centerprint_all("Red Team Wins");
			}
			else if (qccTeamScore[QCC_TEAM_BLUE] >= fraglimit) {
				endgame = TRUE;
				centerprint_all("Blue Team Wins");
			}
			else if (qccTeamScore[QCC_TEAM_YELLOW] >= fraglimit) {
				endgame = TRUE;
				centerprint_all("Yellow Team Wins");
			}
			else if (qccTeamScore[QCC_TEAM_GREEN] >= fraglimit) {
				endgame = TRUE;
				centerprint_all("Green Team Wins");
			}

		}
		else if (self.frags >= fraglimit)
			endgame = TRUE;
	}

	if (!endgame)
		return;
	
	NextLevel();
};

// Use this function when adding or subtracting player flags, so that we can keep better track of our teamplay
void(entity fragger, float new_frags) add_frag = {
	fragger.frags += new_frags;
	//float fraglimit = cvar("fraglimit");
	if (deathmatch == QCC_TDM) {
		if (teamplay && fragger.classname == "player" && fragger.team > QCC_TEAM_NONE && fragger.team < QCC_MAX_TEAMS) {
			qccTeamScore[fragger.team - 1] += new_frags;
		}
	}
}