/*
=============================================================================
				INTERMISSION
=============================================================================
*/

const float NO_INTERMISSION = 1; // MG1

// Returns the entity to view the intermission from
entity() FindIntermission = {
	entity spot;
	float cyc;

	// Look for info_intermission first
	spot = find(world, classname, "info_intermission");
	if (spot) {	// pick a random one
		cyc = random() * 10;
		while (cyc > 1) {
			spot = find(spot, classname, "info_intermission");
			if (!spot)
				spot = find(spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

	// Then look for the start position
	spot = find(world, classname, "info_player_start");
	if (spot)
		return spot;
	
	// testinfo_player_start is only found in regioned levels
	spot = find(world, classname, "testplayerstart");
	if (spot)
		return spot;
	
	objerror ("FindIntermission: no spot");
	return world;
};

// HIP + ROGUE
void() finale_transition = {
	if (!coop) {
		localcmd("menu_credits\n");
		localcmd("disconnect\n");
	}
    else {
		changelevel("start");
	}
}

// HIP + ROGUE
void() finale_check = {
	if (finaleFinished()) {
		self.nextthink = time + 5;
		self.think = finale_transition;
	}
    else {
		self.nextthink = time + 0.1;
	}
}

string intermissiontext;
void() ExitIntermission = {
	// Skip any text in deathmatch
	if (deathmatch) {
		GotoNextMap();
		return;
	}
	
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

	// Run some text if at the end of an episode
	if (intermission_running == 2) {
		// ID1
		if (world.model == "maps/e1m7.bsp") {
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 2);
			WriteByte(MSG_ALL, 3);
	
			if (!cvar("registered")) {
				WriteByte(MSG_ALL, SVC_FINALE);
				if (ExtSupported("EX_SPRINT"))
					WriteString (MSG_ALL, "$qc_finale_e1_shareware");
				else
					WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!");
			}
			else {
				WriteByte(MSG_ALL, SVC_FINALE);
				if (ExtSupported("EX_SPRINT"))
					WriteString (MSG_ALL, "$qc_finale_e1");
				else
					WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!");
			}	
			return;
		}
		else if (world.model == "maps/e2m6.bsp") {
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 2);
			WriteByte(MSG_ALL, 3);

			WriteByte(MSG_ALL, SVC_FINALE);
			if (ExtSupported("EX_SPRINT"))
				WriteString (MSG_ALL, "$qc_finale_e2");
			else
				WriteString (MSG_ALL, "The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herself in her frightful\notherworld cathedral.");
			return;
		}
		else if (world.model == "maps/e3m6.bsp") {
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 2);
			WriteByte(MSG_ALL, 3);

			WriteByte(MSG_ALL, SVC_FINALE);
			if (ExtSupported("EX_SPRINT"))
				WriteString (MSG_ALL, "$qc_finale_e3");
			else
				WriteString (MSG_ALL, "The charred viscera of diabolic horrors\nbubble viscously as you seize the Rune\nof Hell Magic. Its heat scorches your\nhand, and its terrible secrets blight\nyour mind. Gathering the shreds of your\ncourage, you shake the devil's shackles\nfrom your soul, and become ever more\nhard and determined to destroy the\nhideous creatures whose mere existence\nthreatens the souls and psyches of all\nthe population of Earth.");
			return;
		}
		else if (world.model == "maps/e4m7.bsp") {
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 2);
			WriteByte(MSG_ALL, 3);

			WriteByte(MSG_ALL, SVC_FINALE);
			if (ExtSupported("EX_SPRINT"))
				WriteString (MSG_ALL, "$qc_finale_e4");
			else
				WriteString (MSG_ALL, "Despite the awful might of the Elder\nWorld, you have achieved the Rune of\nElder Magic, capstone of all types of\narcane wisdom. Beyond good and evil,\nbeyond life and death, the Rune\npulsates, heavy with import. Patient and\npotent, the Elder Being Shub-Niggurath\nweaves her dire plans to clear off all\nlife from the Earth, and bring her own\nfoul offspring to our world! For all the\ndwellers in these nightmare dimensions\nare her descendants! Once all Runes of\nmagic power are united, the energy\nbehind them will blast open the Gateway\nto Shub-Niggurath, and you can travel\nthere to foil the Hell-Mother's plots\nin person.");
			return;
		}
		//HIP
		else if (world.model == "maps/hip1m4.bsp") {
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 6+QCC_CDTRACK_OFFSET);
			WriteByte(MSG_ALL, 3+QCC_CDTRACK_OFFSET);
			WriteByte(MSG_ALL, SVC_FINALE);
			if (ExtSupported("EX_SPRINT"))
		   		WriteString (MSG_ALL, "$qc_finale_hip1");
			else
				WriteString (MSG_ALL, "Deep within the bowels of the\nResearch Facility, you discover the\npassage that the followers of Quake\nhave used to enter our world.\nThe bastards used some type of\ngigantic teleporter to overload\none of our own slipgates!  As long as\nthis portal exists, Earth will never\nbe safe from Quake's cruel minions.");
			return;
		}
		else if (world.model == "maps/hip2m5.bsp") {
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 6+QCC_CDTRACK_OFFSET);
			WriteByte(MSG_ALL, 3+QCC_CDTRACK_OFFSET);
			WriteByte(MSG_ALL, SVC_FINALE);
			if (ExtSupported("EX_SPRINT"))
				WriteString (MSG_ALL, "$qc_finale_hip2");
			else
				WriteString (MSG_ALL, "After destroying the power generator,\nyou pass beyond the gate of Mortum's\nKeep.  A wave of nausea suddenly flows\nover you and you find yourself cast\nout into a liquid void.  You float\nlifelessly, yet aware, in a lavender\nsea of energy.");
			return;
		}
		else if (world.model == "maps/hipend.bsp") {
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 2+QCC_CDTRACK_OFFSET);
			WriteByte(MSG_ALL, 3+QCC_CDTRACK_OFFSET);
			WriteByte(MSG_ALL, SVC_FINALE);
			if (ExtSupported("EX_SPRINT"))
				WriteString (MSG_ALL, "$qc_finale_hipend");
			else
				WriteString (MSG_ALL, "After the last echoes of Armagon's\ndeath yell fade away, you breathe a\nheavy sigh of relief.  With the loss\nof his magic, Armagon's fortress\nbegins to collapse.  The rift he\ncreated to send his grisly troops\nthrough time slowly closes and seals\nitself forever.  In the chaos that\nensues, a wall collapses, revealing\none remaining time portal.  With your\nchances to escape rapidly growing\nslim, you race for the portal,\nmindless of your destination.  In a\nflash of light, you find yourself\nback at Command HQ, safe and sound.");
			if (campaign && world.model == "maps/hipend.bsp") {
				WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
				WriteString(MSG_ALL, "ACH_COMPLETE_HIPEND");
				if (skill == 3) {
					WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
					WriteString(MSG_ALL, "ACH_COMPLETE_HIPEND_NIGHTMARE"); 			
				}
			}
			return;
		}
		// ROGUE
		else if (world.model == "maps/r1m7.bsp") {
			WriteByte(MSG_ALL, SVC_FINALE);
			if (ExtSupported("EX_SPRINT"))
				WriteString (MSG_ALL, "$qc_finale_r1");
			else
				WriteString(MSG_ALL, "Victory! The Overlord's mangled\nremains are the evidence.  His evil\nWrath army?  Cast out to wander\naimlessly throughout time.\n\nAs the Slipgate fog surrounds you,\nthoughts rage into your consciousness:\nHas Quake's oppressive reign ended?\nIs it Salvation, or Damnation, which\nwaits beyond the Vortex?\n\nAnother thought, not quite your own,\nrazors through the haze.  \"Forgiveness\ncan yet be granted; Our Master remains\nto absolve your sins against his Chosen.\nFall down upon your knees-pray for\nQuake's mercy.\"");
			return;
		}
		else if (coop && mapname == "r2m8") {
			localcmd("menu_credits\n");
			localcmd("disconnect\n");
			return;
		}
		// MG1
		else if (world.endtext)
			intermissiontext = world.endtext;

		if (intermissiontext) {
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, 2+QCC_CDTRACK_OFFSET);
			WriteByte(MSG_ALL, 3+QCC_CDTRACK_OFFSET);

			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, intermissiontext);
			intermissiontext = string_null;
			return;
		}
		
		if (nextmap == "start" && !coop && !cvar("horde")) {
			localcmd("menu_credits\n");
			localcmd("disconnect\n");
		} 
		else 
			GotoNextMap();
	}
	
	if (intermission_running == 3) {
		// Shareware episode has been completed, go to sell screen
		if (!cvar("registered")) {
			WriteByte(MSG_ALL, SVC_SELLSCREEN);
			return;
		}

		// Finale Text
		// ID1
		if (world.model == "maps/e1m7.bsp" || world.model == "maps/e2m6.bsp" || world.model == "maps/e3m6.bsp" || world.model == "maps/e4m7.bsp") {
			if ((serverflags & 15) == 15) {
				WriteByte(MSG_ALL, SVC_FINALE);
				if (ExtSupported("EX_SPRINT"))
					WriteString (MSG_ALL, "$qc_finale_all_runes");
				else
					WriteString (MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisible forces moving to\nunseal ancient barriers. Shub-Niggurath\nhad hoped to use the Runes Herself to\nclear off the Earth, but now instead,\nyou will use them to enter her home and\nconfront her as an avatar of avenging\nEarth-life. If you defeat her, you will\nbe remembered forever as the savior of\nthe planet. If she conquers, it will be\nas if you had never been born.");
				return;
			}
		}
		// HIP
		else if (world.model == "maps/hip1m4.bsp") {
			WriteByte(MSG_ALL, SVC_FINALE);
			if (ExtSupported("EX_SPRINT"))
				WriteString (MSG_ALL, "$qc_finale_hip1m4");
			else
				WriteString (MSG_ALL, "If you can find the source of the\nportal's power, you can shut it\ndown--possibly forever!  With only a\nmoment's consideration for your own\nsafety, you re-enter the dark domain,\nknowing Hell would be a better fate\nthan experiencing the reign of Quake.");
			return;
		}
		else if (world.model == "maps/hip2m5.bsp") {
			WriteByte(MSG_ALL, SVC_FINALE);
			if (ExtSupported("EX_SPRINT"))
				WriteString (MSG_ALL, "$qc_finale_hip2m5");
			else
				WriteString (MSG_ALL, "After what seems like an eternity,\nyou feel the presence of a diabolical\nintelligence.  You are held helpless\nfor a moment as your mind is open to\nthat of Armagon--Quake's General and\nmaster of this realm.  Recognizing\nyou as the one who foiled his\nattempt to conquer Earth, a hellish\nhowl fills your mind and blots out\nall consciousness.  When you awake,\nyou find yourself on the shores of\nreality, but in a time and place\nunknown to you.");
			return;
		}
		else if (world.model == "maps/hipend.bsp") {
			WriteByte(MSG_ALL, SVC_FINALE);
			if (ExtSupported("EX_SPRINT"))
				WriteString (MSG_ALL, "$qc_finale_hipend2");
			else
				WriteString (MSG_ALL, "Congratulations!  You are victorious!\nThe minions of Quake have once again\nfallen before your mighty hand.\nIs this the last you will see of\nQuake's hellions?\n\nOnly time will tell...");
			intermission_exittime = time + 10000000;  // Never allow exit
  
			// Instead of sitting here forever, run the QuakeEx credits and send the user back to start
			entity timer = spawn();
			timer.nextthink = time + 1;
			timer.think = finale_check;	
			return;
		}
		// MG1
		else if ((serverflags & SIGIL_ALL) == SIGIL_ALL) {
			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "$qc_mg1_endtext_all_runes");
			return;
		}		
	}

	// ROGUE
	if (coop) {
		if (mapname == "r2m8") {
			localcmd("menu_credits\n");
			localcmd("disconnect\n");
			return;
		} 
	}
	else
		GotoNextMap();
};

// When the player presses attack or jump, change to the next level
void() IntermissionThink = {
	if (time < intermission_exittime)
		return;
	if (!self.button0 && !self.button1 && !self.button2)
		return;	
	ExitIntermission();
};