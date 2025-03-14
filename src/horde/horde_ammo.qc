/*
==================================
HORDE AMMO
==================================
*/

void() HordePrecacheAmmo = {
	precache_model("maps/b_shell1.bsp");
	precache_model("maps/b_shell0.bsp");
	precache_model("maps/b_nail1.bsp");
	precache_model("maps/b_nail0.bsp");
	precache_model("maps/b_rock1.bsp");
	precache_model("maps/b_rock0.bsp");
	precache_model("maps/b_batt1.bsp");
	precache_model("maps/b_batt0.bsp");
}

void() SpawnAmmo;

void() horde_ammo_touch = {
	entity temp_player, t; 
	float best_weapon;
	
	// early exit touch if not a player or not alive
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	
	// if the player was using their best weapon, change up to the new one if better		
	t = self; // hang on to the ammo entity for a moment
	self = other;
	best_weapon = W_BestWeapon();
	self = t; // set self back to ammo entity
	
	// if player is at max ammo for ammo's type, return
	if (((self.weapon == 1) && (other.ammo_shells >= 25)) || // shotgun
		((self.weapon == 2) && (other.ammo_nails >= 150)) || // nailgun
		((self.weapon == 3) && (other.ammo_rockets >= 25)) || // rockets
		((self.weapon == 4) && (other.ammo_cells >= 150))) // cells
		return;
		
	sprint(other, "$qc_got_item", self.netname);
	
	// ammo touch sound
	sound(other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd(other, "bf\n");

	// change to a better weapon if appropriate
	if (other.weapon == best_weapon) {
		t = self;
		self = other;
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo ();
		self = t;
	}

	// loop through all players and give ammo
	temp_player = find(world, classname, "player");
	while (temp_player)	{
		if (temp_player.health > 0) {	// only give ammo to living players
			if (self.weapon == 1) // machine gun
				temp_player.ammo_bullets += self.aflag;
			else if (self.weapon == 2) // shotgun
				temp_player.ammo_shells += self.aflag;
			else if (self.weapon == 3) // spikes
				temp_player.ammo_nails += self.aflag;
			else if (self.weapon == 4) // tribolt
				temp_player.ammo_bolts += self.aflag;
			else if (self.weapon == 5) // rockets
				temp_player.ammo_rockets += self.aflag;
			else if (self.weapon == 6) // cells
				temp_player.ammo_cells += self.aflag;
			else if (self.weapon == 7) // slugs
				temp_player.ammo_slugs += self.aflag;

			// temp swap and set bounds
			t = other;
			other = temp_player;
			bound_other_ammo();
			other = t;
			
			// temp swap again and set current ammo
			t = self;
			self = temp_player;
			W_SetCurrentAmmo();
			self = t;
		}
		temp_player = find(temp_player, classname, "player");
	}
	
	// remove
	self.model = string_null;
	self.solid = SOLID_NOT;
	// AY dec06 2021
	//self.owner.wait = FALSE; The Old Way
	self.owner.think = SpawnAmmo;
	self.owner.nextthink = time + HORDE_AMMO_RESPAWN_DELAY;
	// end AY
	remove(self);
};

void() SpawnAmmo = {
	float r, is_big; 
	entity item;
	vector pos;
	pos = self.origin;
	item = spawn();
	
	// roll a d4, a 1 means big ammo.
	is_big = (random() * 4) <= 1; 
	
	if (is_big)
		pos = pos - '16 16 0';
	else
		pos = pos - '12 12 0';
	
	r = random() * 25;
	if (r < 5) { // bullets
		item.classname = "item_bullets";
		if (is_big) {
			setmodel(item, "maps/b_shell1.bsp");
			item.aflag = 50;
		}
		else {
			setmodel(item, "maps/b_shell0.bsp");
			item.aflag = 25;
		}
		item.weapon = 1;
		item.netname = "bullets";
	}
	else if (r < 10) {	// shells
		item.classname = "item_shells";
		if (is_big) {
			setmodel(item, "maps/b_shell1.bsp");
			item.aflag = 10;
		}
		else {
			setmodel(item, "maps/b_shell0.bsp");
			item.aflag = 5;
		}
		item.weapon = 2;
		item.netname = "$qc_shells";
	}
	else if (r < 15) {	// spikes
		item.classname = "item_spikes";
		if (is_big) {
			setmodel(item, "maps/b_nail1.bsp");
			item.aflag = 50;
		}
		else {
			setmodel(item, "maps/b_nail0.bsp");
			item.aflag = 25;
		}
		item.weapon = 3;
		item.netname = "$qc_nails";
	}
	else if (r < 17) { // bolts
		item.classname = "item_bolts";
		if (is_big) {
			setmodel(item, "maps/b_rock1.bsp");
			item.aflag = 5;
		}
		else {
			setmodel(item, "maps/b_rock0.bsp");
			item.aflag = 2;
		}
		item.weapon = 4;
		item.netname = "bolts";
	}
	else if (r <= 20) {	// rockets
		item.classname = "item_rockets";
		if (is_big) {
			setmodel(item, "maps/b_rock1.bsp");
			item.aflag = 10;
		}
		else {
			setmodel(item, "maps/b_rock0.bsp");
			item.aflag = 5;
		}
		item.weapon = 5;
		item.netname = "$qc_rockets";
	}
	else if (r < 23) {	// cells
		item.classname = "item_cells";
		if (is_big) {
			setmodel(item, "maps/b_batt1.bsp");
			item.aflag = 50;
		}
		else {
			setmodel(item, "maps/b_batt0.bsp");
			item.aflag = 25;
		}
		item.weapon = 6;
		item.netname = "$qc_cells";
	}
	else { // slugs
		item.classname = "item_slugs";
		if (is_big) {
			setmodel(item, "maps/b_batt1.bsp");
			item.aflag = 5;
		}
		else {
			setmodel(item, "maps/b_batt0.bsp");
			item.aflag = 2;
		}
		item.weapon = 7;
		item.netname = "slugs";
	}
	setorigin(item, pos + '0 0 1');
	setsize(item, '0 0 0', '32 32 56');
	item.owner = self;
	self.wait = TRUE;
	item.movetype = MOVETYPE_TOSS;
	item.solid = SOLID_TRIGGER;
	item.flags = FL_ITEM;
	item.touch = horde_ammo_touch;
	
	spawn_tfog_silent(pos + '0 0 8'); // added aug30
};

void() info_horde_ammo = {
	if (not_horde(self))
		return;
	self.think = SpawnAmmo;
	self.nextthink = time + HORDE_START_DELAY + random() * 3;
};