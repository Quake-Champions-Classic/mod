/*
===================
HORDE KEY
===================
*/

void() Countdown;
.float	wave; // what wave of the horde mode we're on
float key_spawned; // TRUE/FALSE, determine if key has already been spawned, prevent dupes.

float KEY_FIRST = 1;
float KEY_SECOND = 2;
float KEY_THIRD = 4;
float KEY_FOURTH_PLUS = 8;

void() HordePrecacheKeys = {
	if (world.worldtype == WORLDTYPE_MEDIEVAL || world.worldtype == WORLDTYPE_HUB) {
		precache_sound("misc/medkey.wav");
		precache_model("progs/w_g_key.mdl"); // gold key
		precache_model("progs/w_s_key.mdl"); // silver key
	}
	if (world.worldtype == WORLDTYPE_METAL) {
		precache_sound("misc/runekey.wav");
		precache_model("progs/m_g_key.mdl");
		precache_model("progs/m_s_key.mdl");
	}
	if (world.worldtype == WORLDTYPE_BASE) {
		precache_sound2("misc/basekey.wav");
		precache_model2("progs/b_g_key.mdl");
		precache_model2("progs/b_s_key.mdl");
	}
};

void() horde_print_keys = {
	dprint(ftos(keys_silver));
	dprint(" silver keys : ");
	dprint(ftos(keys_gold));
	dprint(" gold keys\n");
};

void(entity temp_player) horde_set_keys = {
	// player has just respawned, reset their keys based on global key values
	if (keys_silver > 0)
		temp_player.items+= IT_KEY1;	
	if (keys_gold > 0)
		temp_player.items+= IT_KEY2;
};	

void(float key_item) horde_key_give_all = {
	entity temp_player;
	temp_player = find(world, classname, "player");	
	while (temp_player) {
		temp_player.items = temp_player.items + key_item;
		temp_player = find(temp_player, classname, "player");
	}	
	horde_print_keys();
};

void(float key_item) horde_key_remove_all = {
	entity temp_player;
	temp_player = find(world, classname, "player");	
	while (temp_player) {
		temp_player.items = temp_player.items - key_item;
		temp_player = find(temp_player, classname, "player");
	}	
	horde_print_keys();
};

void(float key_item)horde_key_give = {
	if (key_item & IT_KEY1) {
		keys_silver++;
		if (keys_silver == 1)
			horde_key_give_all(IT_KEY1);
	}
	else if (key_item & IT_KEY2) {
		keys_gold++;
		if (keys_gold == 1)
			horde_key_give_all(IT_KEY2);
	}
	horde_print_keys();
}

void(float key_item)horde_key_spend = {
	if (key_item & IT_KEY1) {
		keys_silver--;
		if (keys_silver == 0)
			horde_key_remove_all(IT_KEY1);
	}
	else if (key_item & IT_KEY2) {
		keys_gold--;
		if (keys_gold == 0)
			horde_key_remove_all(IT_KEY2);
	}
	horde_print_keys();
}

void() horde_key_touch = {
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (other.flags & FL_ISBOT)
		return;
	
	sprint(other, "$qc_got_item", self.netname);
	
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	
	horde_key_give(self.items);
	
	// find the horde manager and trigger the next wave
	if (key_spawned) {
		dprint("key triggers next wave\n");
		horde_ent.wait = TRUE;
		horde_ent.think = Countdown;
		horde_ent.nextthink = time;
	}
	else
		dprint("key shouldn't trigger next wave!\n");
	remove(self);
};

/* Spawn Key
A key should spawn after every boss wave.
*/
void(float is_gold) SpawnKey = {
	entity item;
	item = spawn();
	
	if (is_gold) {
		item.items = IT_KEY2;		
		// set model and sound based on worldtype
		if (world.worldtype == WORLDTYPE_METAL) {
			item.netname = "$qc_gold_runekey";
			item.noise = "misc/runekey.wav";
			setmodel(item, "progs/m_g_key.mdl");
			centerprint_all("$qc_horde_gold_runekey_appears");
		}
		else if (world.worldtype == WORLDTYPE_BASE) {
			item.netname = "$qc_gold_keycard";
			item.noise = "misc/basekey.wav";
			setmodel(item, "progs/b_g_key.mdl");
			centerprint_all("$qc_horde_gold_keycard_appears");
		}
		else {  // assume medieval
			item.netname = "$qc_gold_key";
			item.noise = "misc/medkey.wav";
			setmodel(item, "progs/w_g_key.mdl");
			centerprint_all("$qc_horde_gold_key_appears");
		}
	}
	else {
		item.items = IT_KEY1;		
		// set model and sound based on worldtype
		if (world.worldtype == WORLDTYPE_METAL) {
			item.netname = "$qc_silver_runekey";
			item.noise = "misc/runekey.wav";
			setmodel(item, "progs/m_s_key.mdl");
			centerprint_all("$qc_horde_silver_runekey_appears");
		}
		else if (world.worldtype == WORLDTYPE_BASE) {
			item.netname = "$qc_silver_keycard";
			item.noise = "misc/basekey.wav";
			setmodel(item, "progs/b_s_key.mdl");
			centerprint_all("$qc_horde_silver_keycard_appears");
		}
		else {  // assume medieval
			item.netname = "$qc_silver_key";
			item.noise = "misc/medkey.wav";
			setmodel(item, "progs/w_s_key.mdl");
			centerprint_all("$qc_horde_silver_key_appears");
		}

	}
	//item.noise = "misc/medkey.wav";
	setsize(item, '-16 -16 -25', '16 16 32');
	item.touch = horde_key_touch;
	//item.think = PlaceItem;
	//item.nextthink = time + 0.2;
	item.target = "horde_manager"; // when used, retrigger the horde manager
	item.flags = FL_ITEM;		// make extra wide
	//item.flags = item.flags & FL_NOBOTS; // AY 11 Nov 2021 so bots can't get keys
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setorigin(item, self.origin + '0 0 32');
	item.velocity = '0 0 255';
	
	// AY Feb22, 2022, rune keys shouldn't have light effects on them
	if (world.worldtype != WORLDTYPE_METAL)
		item.effects = EF_BRIGHTLIGHT;
	
	//dprint("     spawned key\n");
	spawn_tfog(item.origin);
	key_spawned = 1;
};

void() SpawnGoldKey = {
	SpawnKey(TRUE);
};
	
void() SpawnSilverKey = {
	SpawnKey(FALSE);
};

// Function get a key given the current wave
// Wave 3 should return a key with spawnflag "KEY_FIRST"
// Wave 6 should return a key with spawnflag "KEY_SECOND"
// Wave 9 should return a key with spawnflag "KEY_THIRD"
// Wave 9+ should return a key with spawnflag "KEY_FOURTH_PLUS"
// If a key with the correct spawnflag isn't found, return any key
void() GetKey = {
	entity t, l;
	t = find(world, classname, "info_horde_key");
	l = t; // save ref for later
	
	// check if any keys exist
	if (t == world) {
		dprint("ERROR: No info_horde_key!\n");
		// continue as if player got the key
		self.think = Countdown;
		self.nextthink = time + 4;
		return;
	}
	
	while (t != world) {
		if (self.wave <= 3) {   // looking for KEY_FIRST
			if (t.spawnflags & KEY_FIRST) {
				t.think = SpawnSilverKey;
				t.nextthink = time;
				return;
			}
		}
		else if (self.wave <= 6) {  // looking for KEY_SECOND
			if (t.spawnflags & KEY_SECOND) {
				t.think = SpawnSilverKey;
				t.nextthink = time;
				return;
			}
		}
		else if (self.wave <= 9) {  // looking for KEY_THIRD
			if (t.spawnflags & KEY_THIRD) {
				t.think = SpawnGoldKey;
				t.nextthink = time;
				return;
			}
		}
		else {  // looking for KEY_FOURTH_PLUS
			// check next key
			if (t.spawnflags & KEY_FOURTH_PLUS) {
				t.think = SpawnSilverKey;
				t.nextthink = time;
				return;
			}
		}
		t = find(t, classname, "info_horde_key");
	}
	
	// didn't find key with matching spawnflag, return any key
	dprint("didn't find key with matching spawnflag. Return last: ");
	dprint(l.classname);
	
	if (self.wave == 9)
		l.think = SpawnGoldKey;
	else
		l.think = SpawnSilverKey;
	l.nextthink = time;
};

void() info_horde_key = {
	if (not_horde(self))
		return;
	self.wait = FALSE;
};