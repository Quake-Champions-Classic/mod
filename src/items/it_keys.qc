/*
===============================================================================
KEYS

In order for keys to work you MUST set your maps worldtype to one of the following:
0: medieval
1: metal
2: base
===============================================================================
*/
void() key_touch = {
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (other.items & self.items)
		return;

	if (ExtSupported("EX_SPRINT"))
		sprint(other, "$qc_got_item", self.netname);
	else {
		sprint(other, "You got the ");
		sprint(other, self.netname);
		sprint(other,"\n");
	}

	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	other.items = other.items | self.items;

	if (!coop) {	
		self.solid = SOLID_NOT;
		self.model = string_null;
	}

	activator = other;
	SUB_UseTargets();
	self.target = string_null;  // Only fire the trigger once
};


void() key_setsounds = {
	if (world.worldtype == WORLDTYPE_MEDIEVAL) {
		precache_sound("misc/medkey.wav");
		self.noise = "misc/medkey.wav";
	}
	else if (world.worldtype == WORLDTYPE_METAL) {
		precache_sound("misc/runekey.wav");
		self.noise = "misc/runekey.wav";
	}
	else if (world.worldtype == WORLDTYPE_BASE) {
		precache_sound2("misc/basekey.wav");
		self.noise = "misc/basekey.wav";
	}
};

// Silver Key
void() item_key1 =
{
	if (world.worldtype == WORLDTYPE_MEDIEVAL) {
		precache_model("progs/w_s_key.mdl");
		setmodel(self, "progs/w_s_key.mdl");
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_silver_key";
		else
			self.netname = "silver key";

	}
	else if (world.worldtype == WORLDTYPE_METAL) {
		precache_model("progs/m_s_key.mdl");
		setmodel(self, "progs/m_s_key.mdl");
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_silver_runekey";
		else
			self.netname = "silver runekey";
	}
	else if (world.worldtype == WORLDTYPE_BASE) {
		precache_model2("progs/b_s_key.mdl");
		setmodel(self, "progs/b_s_key.mdl");
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_silver_keycard";
		else
			self.netname = "silver keycard";
	}

	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY1;
	setsize(self, '-16 -16 -24', '16 16 32');
	StartItem();
};

// Gold Key
void() item_key2 = {
	if (world.worldtype == WORLDTYPE_MEDIEVAL) {
		precache_model("progs/w_g_key.mdl");
		setmodel(self, "progs/w_g_key.mdl");
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_gold_key";
		else
			self.netname = "gold key";
	}
	else if (world.worldtype == WORLDTYPE_METAL) {
		precache_model("progs/m_g_key.mdl");
		setmodel(self, "progs/m_g_key.mdl");
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_gold_runekey";
		else
			self.netname = "gold runekey";
	}
	else if (world.worldtype == WORLDTYPE_BASE) {
		precache_model2("progs/b_g_key.mdl");
		setmodel(self, "progs/b_g_key.mdl");
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_gold_keycard";
		else
			self.netname = "gold keycard";
	}

	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY2;
	setsize(self, '-16 -16 -24', '16 16 32');
	StartItem();
};