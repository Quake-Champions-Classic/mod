/*
===========================
HORDE ITEMS
===========================
*/

void() HordePrecacheItems = {
	precache_model("maps/b_bh25.bsp");
	precache_sound("items/health1.wav");
	precache_model("maps/b_bh25s.bsp");
	precache_sound("items/r_item2.wav");
	precache_model("progs/armor.mdl"); // regular armor
	precache_model("progs/qclarmor.mdl");
	precache_model("progs/qchourglass.mdl");
}

void() horde_health_touch = {	
	if (other.classname != "player")
		return;
	
	if (self.healtype == 2) {
		if (!T_Heal(other, self.healamount, 1))
			return;
	}
	else {
		if (!T_Heal(other, self.healamount, 0))
			return;
	}
	
	sprint(other, "$qc_item_health", ftos(self.healamount));
	
	// health touch sound
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	
	self.model = string_null;
	self.solid = SOLID_NOT;
	self.owner.wait = FALSE;
	remove(self);
};

void() horde_armor_touch = {
	float value;
	
	if (other.health <= 0)
		return;
	if (other.classname != "player")
		return;

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
	
	if (other.qccChampion == QCC_DUKENUKEM && self.classname != "qcc_item_armorshard")
		QCC_DukeItem(other, self);

	self.solid = SOLID_NOT;
	self.model = string_null;
	sprint(other, "$qc_item_armor");
	// armor touch sound
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM); // QCC: use noise instead of default armor sound
	stuffcmd(other, "bf\n");
	self.owner.wait = FALSE;
	remove(self);
};

void() SpawnItem = {
	float r;
	entity item;
	vector pos;
	item = spawn();
	
	pos = self.origin; // set to origin, then offset as needed

	r = random() * 6; 
	if (r < 5) {   // regular health
		item.classname = "item_health";
		if (r < 2) {
			setmodel(item, "maps/b_bh25s.bsp");
			item.noise = "items/r_item2.wav";
			item.healtype = 2;
		}
		else {
			setmodel(item, "maps/b_bh25.bsp");
			item.noise = "items/health1.wav";
			item.healtype = 1;
		}
		item.touch = horde_health_touch;
		item.healamount = 25;
		setsize(item, '0 0 0', '32 32 56');
		pos = pos - '16 16 0';
	}
	else {  // armor
		item.classname = "qcc_item_lightarmor";
		setmodel(item, "progs/qclarmor.mdl");
		item.armorvalue = 50;
		item.noise = "items/lightarmor.wav";
		item.touch = horde_armor_touch;
		setsize(item, '-16 -16 0', '16 16 56');
	}

	setorigin(item, pos + '0 0 1');
	item.owner = self;
	self.wait = TRUE;	
	item.movetype = MOVETYPE_TOSS;
	item.solid = SOLID_TRIGGER;
	item.flags = FL_ITEM;
	spawn_tfog_silent(pos + '0 0 8'); // added aug30
};

void() info_horde_item = {
	if (not_horde(self))
		return;
	self.wait = FALSE;
};