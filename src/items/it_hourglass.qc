/*
====================================================
HOURGLASS
====================================================
*/
void() qcc_hourglass_touch = {
	if (other.classname != "player")
		return;    
    if (other.qccAbilityTimer < time || other.qccAbilityTimer > time + QCC_GLOBAL_COOLDOWN)
        return;

#ifdef COOP_RESPAWN_ITEMS_FOR_PLAYERS
    if (coop && other == self.enemy && self.wait <= 0) // In coop, don't allow the same player to pick up all the respawns.
        return;
    self.enemy = other;	// Store this player for coop
#endif

	QCC_AbilityCooldown(other);
	QCC_AbilityTimeLeft(other);
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
    stuffcmd(other, "bf\n");
	self.model = string_null;
	self.solid = SOLID_NOT;

    if (cvar("horde")) {
        self.owner.wait = FALSE;
	    remove(self);
        return;
    }

    if (deathmatch && deathmatch != 2) // deathmatch 2 is silly old rules
		self.nextthink = time + 20;

#ifdef COOP_RESPAWN_ITEMS_FOR_PLAYERS		
    if (coop && self.wait <= 0) {
        self.cnt++;
        //Not been picked up by all players yet.
        if (self.cnt < num_players)
            self.nextthink = time + 1; // Respawn almost immediately
        else {
            self.enemy = world;
            self.cnt = 0;
            self.nextthink = time + 6 * 60; // Respawn after 6 mins in case the players get stuck on something hard.
        }
    } else 
#endif
    if (self.wait) {
		self.nextthink = time + self.wait;
		self.enemy = world;
	}

    self.think = SUB_regen;
    activator = other;
	SUB_UseTargets();
};

void() qcc_hourglass_horde_touch = {
    if (other.classname != "player")
		return;	
    if (other.qccAbilityTimer < time || other.qccAbilityTimer > time + QCC_GLOBAL_COOLDOWN)
        return;
	
    QCC_AbilityCooldown(other);
    QCC_AbilityTimeLeft(other);
    sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	
	self.model = string_null;
	self.solid = SOLID_NOT;
	self.owner.wait = FALSE;
	remove(self);
};

void() qcc_item_hourglass = {
	precache_model("progs/qchourglass.mdl");
	setmodel(self, "progs/qchourglass.mdl");
	self.classname = "item_hourglass";
	self.noise = "timeoff.wav";
	self.touch = qcc_hourglass_touch;
	setsize(self, '-16 -16 -16', '16 16 40');
    StartItem();
};