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
	float timelimit, fraglimit;
	
	if (gameover) // Someone else quit the game already
		return;
	
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	
	if (timelimit && time >= timelimit) {
		NextLevel();
		return;
	}
	
	if (fraglimit && self.frags >= fraglimit) {
		NextLevel();
		return;
	}
};