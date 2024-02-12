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
	
	if (self.classname != "qcc_item_armorshard")
        other.qccSpeakItem(other, self);

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
        if (deathmatch) {
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
===============================================================================
ARMOR
===============================================================================
*/
void() item_armor1 = {
	qcc_item_lightarmor();
};

void() item_armor2 = {
	qcc_item_lightarmor();
};

void() item_armorInv = {
	qcc_item_heavyarmor();
};