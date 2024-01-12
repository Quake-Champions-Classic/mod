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

/*
====================================================
ARMOR
====================================================
*/
void() qcc_armor_touch = {
	float value;
	
	if (other.health <= 0)
		return;
	if (other.classname != "player")
		return;    
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
        return; // ghost walkers can't grab

#ifdef COOP_RESPAWN_ITEMS_FOR_PLAYERS
	if (coop && other == self.enemy && self.wait <= 0) // In coop, don't allow the same player to pick up all the respawns.
		return;
	self.enemy = other;	// Store this player for coop
#endif

	if (self.classname == "qcc_item_lightarmor") {
        if (other.armorvalue >= other.qccMaxArmor)
            return;
		value = other.qccMaxArmor - other.armorvalue;
    }
    else {
        if (other.armorvalue >= other.qccMaxArmor + 75)
            return;
        value = other.qccMaxArmor + 75 - other.armorvalue;
    }
    
    if (value > self.armorvalue)
        value = self.armorvalue;
	
    if (value <= 0)
        return;
    
	other.armorvalue += value;
    if (other.armorvalue > other.qccMaxArmor)
        other.qccArmorRot_nextcheck = time + 3;

	self.solid = SOLID_NOT;
	self.model = string_null;

	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	
	if (other.qccChampion == QCC_DUKENUKEM && self.classname != "qcc_item_armorshard")
		QCC_DukeItem(other, self);

	activator = other;
	SUB_UseTargets();

    if (self.classname != "qcc_item_armorshard") {
#ifdef COOP_RESPAWN_ITEMS_FOR_PLAYERS	
        if (coop && self.wait <= 0) {
            self.cnt++;
            //Not been picked up by all players yet.
            if (self.cnt < num_players) {
                self.nextthink = time + 1; 
                self.think = SUB_regen; // Respawn almost immediately
            }
            else {
                self.enemy = world;
                self.cnt = 0;
                self.nextthink = time + 8 * 60;
                self.think = SUB_regen; // Respawn after 8 mins in case the players get stuck on something hard.
            }
        }
        else 
#endif
        if (deathmatch && deathmatch != 2) {
            self.nextthink = time + 30;
            self.think = SUB_regen;
        }
        else if (self.wait) {
            self.enemy = world;
            self.nextthink = time + self.wait;
            self.think = SUB_regen;
        }

        if (ExtSupported("EX_SPRINT"))
            sprint(other, "$qc_item_armor");
        else
            sprint(other, "You got armor\n");
    }
    /*
    else if (time - self.ltime > 3) {
        sprint(other, "You got an armorshard\n");
        remove(self); // armorshards don't respawn
    }
    */
};

void() QCC_ThrowArmorshard = {
    entity new;

    new = spawn();
    new.touch = qcc_armor_touch;
	new.armorvalue = 10;
	setmodel(new, "progs/qcarmorshard.mdl");
    new.noise = "items/armorshard.wav";
	setsize(new, '-16 -16 -16', '16 16 16');
    setorigin(new, self.origin + '0 0 16');
	new.velocity = VelocityForDamage(-20);
    new.solid = SOLID_TRIGGER;
	new.movetype = MOVETYPE_BOUNCE;
	if (cvar("pr_checkextension"))
        if (checkextension("EX_MOVETYPE_GIB"))
            new.movetype = MOVETYPE_GIB;
    new.avelocity_x = random()*600;
    new.avelocity_y = random()*600;
    new.avelocity_z = random()*600;
    new.think = SUB_Remove;
    new.ltime = time;
    new.nextthink = time + 15;
    new.classname = "qcc_item_armorshard";
};

void() qcc_item_lightarmor = {
    self.touch = qcc_armor_touch;
	self.armorvalue = 50;
	precache_model("progs/qclarmor.mdl");
	setmodel(self, "progs/qclarmor.mdl");
    self.noise = "items/lightarmor.wav";
	setsize(self, '-16 -16 0', '16 16 56');
    self.classname = "qcc_item_lightarmor";
	StartItem();
};

void() qcc_item_heavyarmor = {
    self.touch = qcc_armor_touch;
	self.armorvalue = 100;
	precache_model("progs/armor.mdl");
	setmodel(self, "progs/armor.mdl");
	self.skin = 2;
    self.noise = "items/armor1.wav";
	setsize(self, '-16 -16 0', '16 16 56');
    self.classname = "qcc_item_heavyarmor";
	StartItem();
};


/*
================================================
AMMO
================================================
*/
void() qcc_item_bolts = {
	item_rockets();
};

void() qcc_item_bullets = {
	item_spikes();
};

void() qcc_item_slugs = {
	item_cells();
};

/*
================================================
POWER UPS
================================================
*/

void(float it_flag) QCC_ThrowPowerup = {
    entity new;

    new = spawn();
	
    if (it_flag == IT_INVULNERABILITY && self.invincible_finished > time) {
        if (ExtSupported("EX_SPRINT"))
            new.netname = "$qc_pentagram_of_protection";
        else
            new.netname = "Pentagram of Protection";
        setmodel(new, "progs/invulner.mdl");
        new.noise = "items/protect.wav";
        new.items = IT_INVULNERABILITY;
        new.classname = "item_artifact_invulnerability";
        new.delay = self.invincible_finished - time;
    }
    else if (it_flag == IT_QUAD && self.super_damage_finished > time) {
        if (ExtSupported("EX_SPRINT"))
            new.netname = "$qc_quad_damage";
        else
            new.netname = "Quad Damage";
        setmodel(new, "progs/quaddama.mdl");
        new.noise = "items/damage.wav";
        new.items = IT_QUAD;
        new.classname = "item_artifact_super_damage";
        new.delay = self.super_damage_finished - time;
    }
    else if (it_flag == IT_INVISIBILITY && self.invisible_finished > time) {
        if (ExtSupported("EX_SPRINT"))
		    new.netname = "$qc_ring_of_shadows";
        else
		    new.netname = "Ring of Shadows";
        setmodel(new, "progs/invisibl.mdl");
        new.noise = "items/inv1.wav";
	    new.items = IT_INVISIBILITY;
        new.classname = "item_artifact_invisibility";
        new.delay = self.invisible_finished - time;
    }
    else {
        remove(new);
        return;
    }
    
    new.touch = powerup_touch;
	setsize(new, '-16 -16 -24', '16 16 32');
    setorigin(new, self.origin + '0 0 16');
    new.solid = SOLID_TRIGGER;
    new.flags = FL_ITEM;
    new.qccFlags |= QCC_FL_THROWABLE;
	new.movetype = MOVETYPE_BOUNCE;
	if (cvar("pr_checkextension"))
        if (checkextension("EX_MOVETYPE_GIB"))
            new.movetype = MOVETYPE_GIB;
    new.think = SUB_Remove;
    new.nextthink = time + 30;
};