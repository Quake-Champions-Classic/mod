/*
========================
CLIENT CONNECTION
========================
*/

void() ClientConnect = {
	if (ExtSupported("EX_BPRINT"))
		bprint("$qc_entered", self.netname);
	else {
		bprint (self.netname);
		bprint (" entered the game\n");
	}

	self.ltime = time; // QCC: relevant for choosing a Champ on connection, Duke Nukem voice stuff
	num_players++; // mg1, used mostly for coop stuff

	if (self.flags & FL_ISBOT) {
		self.qccNextChampion = rint(random() * 32768) % QCC_CHAMPS_MAX;
		self.qccChampion = self.qccNextChampion;
		parm16 = self.qccChampion;
		self.qccSkin = rint(random() * 32768);
		if (deathmatch >= QCC_TDM)
			self.qccSkin = self.qccSkin % 2 + 1; // Red Team or Blue Team
		parm15 = self.qccSkin;
	}

	// a client connecting during an intermission can cause problems
	if (intermission_running)
		ExitIntermission();
};

void() ClientDisconnect = {
    // if the level end trigger has been activated, just return since they aren't *really* leaving
	if (gameover)
		return;

	num_players--;	
	// yoder oct13, horde fix for dc-ing players
	if (cvar("horde")) {
		dprint("horde mode, player disconnect\n");
		self.health = 0;
	}

	// let everyone else know
	if (ExtSupported("EX_BPRINT"))
		bprint("$qc_left_game", self.netname, ftos(self.frags));
	else {
		bprint (self.netname);
		bprint (" left the game with ");
		bprint (ftos(self.frags));
		bprint (" frags\n");
	}

	sound(self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	self.effects = 0;
	set_suicide_frame();
};