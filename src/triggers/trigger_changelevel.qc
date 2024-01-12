/*
=================================
TRIGGER CHANGELEVEL
=================================
*/

void() GibMonster;

void() execute_changelevel = {
	entity pos;

	intermission_running = 1;

	// Enforce a wait time before allowing changelevel
	if (deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;

	WriteByte(MSG_ALL, SVC_CDTRACK);
	// QCC: add support for addon intermission music
	WriteByte(MSG_ALL, 3+QCC_CDTRACK_OFFSET);
	WriteByte(MSG_ALL, 3+QCC_CDTRACK_OFFSET);
	
	pos = FindIntermission();

	other = find(world, classname, "player");
	while (other != world) {
		other.view_ofs = '0 0 0';
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = TRUE;		// turn this way immediately
		other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin(other, pos.origin);
		
		if (skill == 3) {
			// [NDS] haleyjd: achieve if completed E1M1 Nightmare Tyson style (axe only)
			if (other.fired_weapon == 0 && world.model == "maps/e1m1.bsp") {
				msg_entity = other;
				WriteByte(MSG_ONE, SVC_ACHIEVEMENT);
				WriteString(MSG_ONE, "ACH_PACIFIST"); // emphasis on "fist", I guess.
			}
			
			// [NDS] haleyjd: achieve if completed E4M6 Nightmare without taking damage
			if (other.took_damage == 0 && world.model == "maps/e4m6.bsp") {
				msg_entity = other;
				WriteByte(MSG_ONE, SVC_ACHIEVEMENT);
				WriteString(MSG_ONE, "ACH_PAINLESS_MAZE"); // emphasis on "fist", I guess.
			}
		}

		other = find(other, classname, "player");
	}	

	WriteByte(MSG_ALL, SVC_INTERMISSION);

	// Campaign completion achievements
	// ID1
	if (campaign) {
		if (world.model == "maps/e1m7.bsp") {
			WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
			WriteString(MSG_ALL, "ACH_COMPLETE_E1M7");
		}
		else if (world.model == "maps/e2m6.bsp") {
			WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
			WriteString(MSG_ALL, "ACH_COMPLETE_E2M6");
		}
		else if (world.model == "maps/e3m6.bsp") {
			WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
			WriteString(MSG_ALL, "ACH_COMPLETE_E3M6");
		}
		else if (world.model == "maps/e4m7.bsp") {
			WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
			WriteString(MSG_ALL, "ACH_COMPLETE_E4M7");
		}
		// HIP
		else if (world.model == "maps/hip1m4.bsp") {
			WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
			WriteString(MSG_ALL, "ACH_COMPLETE_HIP1M4");
		}
		else if (world.model == "maps/hip2m5.bsp") {
			WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
			WriteString(MSG_ALL, "ACH_COMPLETE_HIP2M5");
		}
		// ROGUE
		else if (world.model == "maps/r1m7.bsp") {
			WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
			WriteString(MSG_ALL, "ACH_COMPLETE_R1M7");
		}
		// DOPA
		else if (world.model == "maps/e5end.bsp") {
			WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
			WriteString(MSG_ALL, "ACH_COMPLETE_E5END");
			if (skill == 3) {
				WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
				WriteString(MSG_ALL, "ACH_COMPLETE_E5END_NIGHTMARE"); 			
			}
		}
		// MG1
		else if (world.model == "maps/mgend.bsp") {
			WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
			WriteString(MSG_ALL, "ACH_COMPLETE_MGEND");
			if (skill == 3) {
				WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
				WriteString(MSG_ALL, "ACH_COMPLETE_MGEND_NIGHTMARE"); 			
			}
		}
	}

	// Secret level achievements
	// ID1
	if (world.model == "maps/e1m4.bsp" && nextmap == "e1m8") {
		WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_FIND_E1M8");	
	}
	else if (world.model == "maps/e2m3.bsp" && nextmap == "e2m7") {
		WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_FIND_E2M7");
	}
	else if (world.model == "maps/e3m4.bsp" && nextmap == "e3m7") {
		WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_FIND_E3M7");
	}
	else if (world.model == "maps/e4m5.bsp" && nextmap == "e4m8") {
		WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_FIND_E4M8");
	}	
	// HIP
	else if (world.model == "maps/hip1m2.bsp" && nextmap == "hip1m5") {
		WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_FIND_HIP1M5");
	}
	else if (world.model == "maps/hip2m1.bsp" && nextmap == "hip2m6") {
		WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_FIND_HIP2M6");
	}
	else if (world.model == "maps/hip3m3.bsp" && nextmap == "hipdm1") {
		WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_FIND_HIPDM1");
	}
	// DOPA
 	else if (world.model == "maps/e5m6.bsp" && nextmap == "e5sm2") {
 		WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
 		WriteString(MSG_ALL, "ACH_FIND_E5M8"); 	
 	}
	// MG1
 	else if (world.model == "maps/mge1m1.bsp" && nextmap == "mge1m3") {
 		WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
 		WriteString(MSG_ALL, "ACH_FIND_MGE1M3"); 	
 	}
	
	// MG1
	if (horde_ent) {
		horde_ent.think = SUB_Null;
		horde_ent.nextthink = -1;
		
		other = find(world, category, CATEGORY_MONSTER);
		while (other != world) {
			other.think = GibMonster;
			other.nextthink = time + 0.2 + random() * 1.8;
			other = find(other, category, CATEGORY_MONSTER);
		}
	}

	//Go directly to intermission text.
	if (self.spawnflags & NO_INTERMISSION)
		ExitIntermission();
};

void() changelevel_touch = {
	if (other.classname != "player")
		return;
	
	if ((cvar("noexit") == 1) || (cvar("noexit") == 2 && mapname != "start")) {
		T_Damage(other, self, self, 50000);
		return;
	}

	if (coop || deathmatch)	{
		if (ExtSupported("EX_BPRINT"))
			bprint("$qc_exited", other.netname);
		else {
			bprint (other.netname);
			bprint (" exited the level\n");
		}
	}

	nextmap = self.map;
	intermissiontext = self.endtext;

	//Finished the whole pack, clear the runes. 
	if (world.model == "maps/mgend.bsp")
		serverflags = 0;

	SUB_UseTargets();
	if ((self.spawnflags & NO_INTERMISSION) && (deathmatch == 0) && (self.endtext == string_null)) {
		GotoNextMap();
		return;
	}
	
	self.touch = SUB_Null;
	self.use = SUB_Null;

	// We can't move people right now, because touch functions are called in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

// QCC: Let's trigger level changes remotely
void() changelevel_use = {
	if (activator.classname == "player") {
		if (coop || deathmatch)	{
			if (ExtSupported("EX_BPRINT"))
				bprint("$qc_exited", other.netname);
			else {
				bprint (other.netname);
				bprint (" exited the level\n");
			}
		}
	}

	nextmap = self.map;
	intermissiontext = self.endtext;
	SUB_UseTargets();

	if ((self.spawnflags & NO_INTERMISSION) && (deathmatch == 0) && (self.endtext == string_null)) {
		GotoNextMap();
		return;
	}
	
	self.touch = SUB_Null;
	self.use = SUB_Null;

	// We can't move people right now, because touch functions are called in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

// When the player touches this, he gets sent to the map listed in the "map" variable.
// Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
void() trigger_changelevel = {
	if (!self.map)
		objerror ("changelevel trigger doesn't have map");

	self.netname = "changelevel";
	if (ExtSupported("EX_SPRINT"))
		self.killstring = "$qc_ks_tried_leave";
	else
		self.killstring = " tried to leave\n";
	
	InitTrigger();
	self.touch = changelevel_touch;
	self.use = changelevel_use;
};

// Dimension of the Machine hub
void hub_trigger_changelevel() {
    if ((serverflags & SIGIL_ALL) !=SIGIL_ALL) {
        remove(self);
        return;
    }
    trigger_changelevel();
};