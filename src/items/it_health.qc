/*
=========================================================================
HEALTH BOX
=========================================================================
*/
// T_Heal: add health to an entity, limiting health to max_health; "ignore" will ignore max_health limit
float (entity e, float healamount, float ignore_limit) T_Heal = {
    if (e.health <= 0)
		return FALSE;
    
    if (!ignore_limit && e.health >= e.max_health && e.qccOnFire < time && e.qccPoisoned < time)
		return FALSE;
    
	// QCC: remove DOT effects on heal
	if (e.qccOnFire > time)
		e.qccOnFire = time - 1;
    if (e.qccPoisoned > time)
        e.qccPoisoned = time - 1;

	healamount = ceil(healamount);

	// MG1: AY Dec13 2021, horde rune of hunger
	if (cvar("horde") && (serverflags & 2))
		e.hunger_time = time + HUNGER_MAX;

	e.health = e.health + healamount;

	if (!ignore_limit || (self.flags & FL_MONSTER)) {
		if (e.health >= e.max_health)
			e.health = e.max_health;
	}
	else { // overstack heal
		e.healthrot_nextcheck = time + 3;		
		if (e.health > 175) // QCC
			e.health = 175;
	}

	return TRUE;
};

// Health box. Normally gives 25 points.

// Rotten health boxes now turn into Ability Hourglasses.

// Megahealth will add 100 health (up to 175), then rot you down to your maximum health limit,
// 1 point per second for Light and Medium Champs, 1 point per 2 seconds for Heavy Champs.

float	H_ROTTEN = 1;
float	H_MEGA = 2;
float	H_SPECIAL = 4;
.float	healamount, healtype;

void() health_touch = {	
	if (other.classname != "player")
		return;	
	// QCC: Nyx can't pick up stuff during Ghost Walk --------------
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;
    
#ifdef COOP_RESPAWN_ITEMS_FOR_PLAYERS
	if (coop && other == self.enemy && self.wait <= 0) // In coop, don't allow the same player to pick up all the respawns.
		return;
	self.enemy = other;	// Store this player for coop
#endif
	
    // Megahealth?  Ignore max_health...
	if (self.healtype == 2) {
		if (!T_Heal(other, self.healamount, 1))
			return;
		if (other.qccFlags & QCC_FL_CHANNELING && other.qccAbilityTimer > time) {
			QCC_AbilityCooldown(other);
			QCC_AbilityTimeLeft(other);
		}
		if (other.qccChampion == QCC_DUKENUKEM)
			QCC_DukeItem(other, self);
	}
	else {
		if (!T_Heal(other, self.healamount, 0))
			return;
		if (other.qccFlags & QCC_FL_CHANNELING && other.qccAbilityTimer > time) {
			other.qccAbilityTimer = other.qccAbilityTimer - (QCC_GLOBAL_COOLDOWN * 0.05);
			QCC_AbilityTimeLeft(other);
		}
	}
	
	if (ExtSupported("EX_SPRINT"))
		sprint(other, "$qc_item_health", ftos(self.healamount));
	else {
		sprint(other, "You receive ");
		sprint(other, ftos(self.healamount));
		sprint(other, " health\n");
	}
    
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	
	self.model = string_null;
	self.solid = SOLID_NOT;

    // Deathmatch 2 is silly old rules
	if (deathmatch && deathmatch != 2) {
		if (self.healtype == 2)
			self.nextthink = time + 30; // QCC: Reduced to 30 seconds because QUAKE CHAMPIONS
		else
			self.nextthink = time + 15;
		self.think = SUB_regen;	
	}

#ifdef COOP_RESPAWN_ITEMS_FOR_PLAYERS		
	if (coop && self.wait <= 0) {
		self.cnt++;
        // Not been picked up by all players yet.
		if (self.cnt < num_players) {
			self.nextthink = time + 1; 
			self.think = SUB_regen; // Respawn almost immediately
		}
		else {
			self.enemy = world;
			self.cnt = 0;
			self.nextthink = time + 6 * 60;
			self.think = SUB_regen; // Respawn after 6 mins in case the players get stuck on something hard.
		}
	}
	else 
#endif

	if (self.wait) {
		self.nextthink = time + self.wait;
		self.think = SUB_regen;
		self.enemy = world;
	}
	activator = other;
	SUB_UseTargets();
};

void() item_health = {	
	self.touch = health_touch;

    // QCC: Replace rotten medkits with ability hourglasses
	if (self.spawnflags & H_ROTTEN)	{
		qcc_item_hourglass();
	}
	else if (self.spawnflags & H_MEGA) {
		precache_model("maps/b_bh100.bsp");
		precache_sound("items/r_item2.wav");
		setmodel(self, "maps/b_bh100.bsp");
		self.noise = "items/r_item2.wav";
		self.healamount = 100;
		self.healtype = 2;
	}
	else if (self.spawnflags & H_SPECIAL) {
		precache_model("maps/b_bh25s.bsp");
		precache_sound("items/r_item2.wav");
		setmodel(self, "maps/b_bh25s.bsp");
		self.noise = "items/r_item2.wav";
		self.healamount = 25;
		self.healtype = 2;
	}
	else {
		precache_model("maps/b_bh25.bsp");
		precache_sound("items/health1.wav");
		setmodel(self, "maps/b_bh25.bsp");
		self.noise = "items/health1.wav";
		self.healamount = 25;
		self.healtype = 1;
	}

	setsize(self, '0 0 0', '32 32 56');
	StartItem();
};