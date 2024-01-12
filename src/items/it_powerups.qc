/*
===============================================================================
POWERUPS
===============================================================================
*/
void() powerup_regen;

void() powerup_announce = {
	if (self.classname == "item_artifact_super_damage")
		centerprint_all("Incoming Quad...");
	else if (self.classname == "item_artifact_invulnerability")
		centerprint_all("Incoming Protection...");
	self.nextthink = time + 15;
	self.think = powerup_regen;
};

void() powerup_despawn = {
	// QCC: Swap Quad and Pent if we think it's cool
	if ((self.spawnflags & 1)) {
		if (self.classname == "item_artifact_super_damage")
			self.classname = "item_artifact_invulnerability";
		else if (self.classname == "item_artifact_invulnerability")
			self.classname = "item_artifact_super_damage";
	}
	self.nextthink = time + 75;
	self.solid = SOLID_NOT;
	self.model = string_null;
	self.think = powerup_announce;
};

void() powerup_regen = {
	if (self.classname == "item_artifact_super_damage") {
		self.noise = "items/damage.wav";
		setmodel(self, "progs/quaddama.mdl");
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_quad_damage";
		else
			self.netname = "Quad Damage";
		self.items = IT_QUAD;
		self.classname = "item_artifact_super_damage";
		centerprint_all("Quad Spawned");
	}
	else if (self.classname == "item_artifact_invulnerability") {
		self.noise = "items/protect.wav";
		setmodel(self, "progs/invulner.mdl");
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_pentagram_of_protection";
		else
			self.netname = "Pentagram of Protection";
		self.items = IT_INVULNERABILITY;
		self.classname = "item_artifact_invulnerability";
		centerprint_all("Protection Spawned");
	}

	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound(self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);
	setorigin(self, self.origin);

	self.nextthink = time + 30;
	self.think = powerup_despawn;
};

void() powerup_touch = {
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;	
	// QCC: Nyx can't pick up stuff during Ghost Walk
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;

	if (ExtSupported("EX_SPRINT"))
		sprint(other, "$qc_got_item", self.netname);
	else {
		sprint(other, "You got the ");
		sprint(other, self.netname);
		sprint(other,"\n");
	}

	if (deathmatch) {
		self.mdl = self.model;

		if ((self.spawnflags & 1)) {
			self.nextthink = time + 30;
			self.think = powerup_despawn;
		}
		else {
			self.nextthink = time + 120;
			self.think = SUB_regen;
		}

		if (self.classname == "item_random_powerup") { // ROGUE
			self.nextthink = time + 60;
			self.think = random_regen;
		}
	}
	else if (self.wait) {
		self.nextthink = time + self.wait;
		if (self.classname == "item_random_powerup") // ROGUE
			self.think = random_regen;
		else
			self.think = SUB_regen;
	}

	// Apply the appropriate powerup
	if (self.items == IT_SUIT) {
		other.rad_time = 1;
		other.radsuit_finished = time + 30;
        // MG1: Respawn biosuit in coop, since it might be required for progression
		if (coop) {
			self.target = string_null;
			self.think = SUB_regen;
			self.nextthink = time + 2.5;
		}
	}
	
	if (self.items == IT_INVULNERABILITY) {
		other.invincible_time = 1;
		if (horde_ent)
			other.invincible_finished = time + 5;
		else if (self.movetype == MOVETYPE_BOUNCE || self.movetype == MOVETYPE_GIB)
			other.invincible_finished = time + self.delay;
		else
			other.invincible_finished = time + 30;
	}
	
	if (self.items == IT_INVISIBILITY) {
		other.invisible_time = 1;
		if (self.movetype == MOVETYPE_BOUNCE || self.movetype == MOVETYPE_GIB)
			other.invisible_finished = time + self.delay;
		else
			other.invisible_finished = time + 30;
	}

	if (self.items == IT_QUAD) {
		other.super_time = 1;
		if (horde_ent)
			other.super_damage_finished = time + 5;
		else if (self.movetype == MOVETYPE_BOUNCE || self.movetype == MOVETYPE_GIB)
			other.super_damage_finished = time + self.delay;
		else
			other.super_damage_finished = time + 30;
	}
	
	sound(other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	self.solid = SOLID_NOT;
	other.items = other.items | self.items;
	self.model = string_null;

	activator = other;
	SUB_UseTargets();

	// QCC
	if (other.qccChampion == QCC_DUKENUKEM)
		QCC_DukeItem(other, self);
	
	if (self.movetype == MOVETYPE_BOUNCE || self.movetype == MOVETYPE_GIB) // dropped powerup
		remove(self);
};

// Player is invulnerable for 30 seconds
void() item_artifact_invulnerability = {
    self.items = IT_INVULNERABILITY;
	setmodel(self, "progs/invulner.mdl");
    setsize(self, '-16 -16 -24', '16 16 32');
	self.noise = "items/protect.wav";
	self.touch = powerup_touch;

	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_pentagram_of_protection";
	else
		self.netname = "Pentagram of Protection";
	
    StartItem();

	// QCC: delay powerup spawns
	if (self.spawnflags & 1) {
		self.nextthink = time + 75;
		self.solid = SOLID_NOT;
		self.model = string_null;
		self.think = powerup_announce;
	}
};

// Player takes no damage from water or slime for 30 seconds
void() item_artifact_envirosuit = {    
    self.items = IT_SUIT;
    precache_model("progs/suit.mdl");
	precache_sound("items/suit.wav");
	precache_sound("items/suit2.wav");
	setmodel(self, "progs/suit.mdl");
    setsize(self, '-16 -16 -24', '16 16 32');
	self.noise = "items/suit.wav";
	self.touch = powerup_touch;

	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_biosuit";
	else
		self.netname = "Biosuit";
    
	StartItem();
};

// Player is invisible for 30 seconds
void() item_artifact_invisibility = {
    self.items = IT_INVISIBILITY;
    setmodel(self, "progs/invisibl.mdl");
	setsize(self, '-16 -16 -24', '16 16 32');
	self.noise = "items/inv1.wav";
	self.touch = powerup_touch;

	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_ring_of_shadows";
	else
		self.netname = "Ring of Shadows";
    
	StartItem();

	// QCC: delay powerup spawns
	if (self.spawnflags & 1) {
		self.nextthink = time + 75;
		self.solid = SOLID_NOT;
		self.model = string_null;
		self.think = powerup_announce;
	}
};


// The next attack from the player will do 4x damage
void() item_artifact_super_damage = {    
    self.items = IT_QUAD;
	setmodel(self, "progs/quaddama.mdl");
	setsize(self, '-16 -16 -24', '16 16 32');
    self.noise = "items/damage.wav";
	self.touch = powerup_touch;

	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_quad_damage";
	else
		self.netname = "Quad Damage";
    
	StartItem();

	// QCC: delay powerup spawns
	if (deathmatch) {
		self.nextthink = time + 90;
		self.mdl = self.model;
		self.think = SUB_regen;
		self.solid = SOLID_NOT;
		self.model = string_null;
	}
};


/*
===============================================================================

SCOURGE OF ARMAGON POWERUPS

===============================================================================
*/
float UNDERWATER = 2;

void() hip_powerup_touch = {
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	// QCC: Nyx can't pick up stuff during Ghost Walk
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;

	if (ExtSupported("EX_SPRINT"))
		sprint(other, "$qc_got_item", self.netname);
	else {
		sprint(other, "You got the ");
		sprint(other, self.netname);
		sprint(other, "\n");
	}

	if (deathmatch) {
		self.mdl = self.model;
		self.nextthink = time + 60;
		self.think = SUB_regen;
	}

	sound(other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	self.solid = SOLID_NOT;
	other.items2 = other.items2 | self.items2;
	self.model = string_null;

	// do the apropriate action
	if (self.items2 == HIP_IT_WETSUIT)
	{
		other.wetsuit_time = 1;
		other.wetsuit_finished = time + 30;
		if (coop) { // QCC: Respawn wetsuit in coop, since it might be required for progression
			self.target = string_null;
			self.think = SUB_regen;
			self.nextthink = time + 2.5;
		}
	}
	if (self.items2 == HIP_IT_EMPATHY_SHIELDS) {
		other.empathy_time = 1;
		if (horde_ent)
			other.empathy_finished = time + 5;
		else
			other.empathy_finished = time + 30;
	}

	activator = other;
	SUB_UseTargets();
};

// QUAKED item_artifact_wetsuit (0 .5 .8) (-16 -16 -24) (16 16 32)
// Player takes no damage from electrical attacks and swims faster for 30 seconds
void() item_artifact_wetsuit = {
	self.touch = hip_powerup_touch;
	precache_model("progs/wetsuit.mdl");
	precache_sound("misc/wetsuit.wav");
	precache_sound("misc/weton.wav");
	precache_sound("items/suit2.wav");
	self.noise = "misc/weton.wav";
	setmodel(self, "progs/wetsuit.mdl");
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_wetsuit";
	else
		self.netname = "Wetsuit";
	self.items2 = HIP_IT_WETSUIT;
	setsize(self, '-16 -16 -24', '16 16 32');
	StartItem();
};

// QUAKED item_hornofconjuring (0 .5 .8) (-16 -16 0) (16 16 32)
// Horn of Conjuring.
// You must make func_spawn entities connected to this entity to spawn the charmed creature.
void() horn_touch = {
	if (other.classname != "player")
		return;   
   // QCC: Nyx can't pick up stuff during Ghost Walk
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;

	if (deathmatch) {
		self.mdl = self.model;
		self.nextthink = time + 60;
		self.think = SUB_regen;
	}

	self.solid = SOLID_NOT;
	self.model = string_null;
	if (ExtSupported("EX_SPRINT"))
		sprint(other, "$qc_got_horn");
	else
		sprint(other, "You got the Horn of Conjuring\n");
	sound(other, CHAN_VOICE, self.noise, 1, ATTN_NONE);
	stuffcmd(other, "bf\n");
	activator = other;
	horn_active = 1;
	horn_charmer = other;

	if (self.target != "")
		SUB_UseTargets();
	else { // No targeted func_spawn; probably a Horn of Conjuring in a Horde Map Find a spawn!
		float x, r;
		r = random() * 10;
		entity horn_spawn = nextent(world);
		while (x < r) {
			if (horn_spawn == world)
				break;
			if (horn_spawn.classname == "func_spawn" || horn_spawn.classname == "func_spawn_small") {
				self.target = horn_spawn.targetname;
				x += 1;
			}
			horn_spawn = nextent(horn_spawn);
		}
		SUB_UseTargets();
		self.target = "";	// Reset it so we can get a new horn spawn target
	}

	horn_active = 0;
};

void() item_hornofconjuring = {
	self.touch = horn_touch;
	precache_model("progs/horn.mdl");
	precache_sound("hipitems/horn.wav");
	setmodel(self, "progs/horn.mdl");
	self.noise = "hipitems/horn.wav";
	setsize(self, '-16 -16 0', '16 16 32');
	StartItem();
};

// QUAKED item_artifact_empathy_shields (0 .5 .8) (-16 -16 0) (16 16 32)
// Empathy Shield.
void() item_artifact_empathy_shields = {
	self.touch = hip_powerup_touch;
	precache_model("progs/empathy.mdl");
	precache_sound("hipitems/empathy.wav");
	precache_sound("hipitems/empathy2.wav");
	precache_sound("items/suit2.wav");
	setmodel(self, "progs/empathy.mdl");
	self.noise = "hipitems/empathy.wav";
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_empathy_shields";
	else
		self.netname = "Empathy Shields";
	self.items2 = HIP_IT_EMPATHY_SHIELDS;
	setsize(self, '-16 -16 0', '16 16 32');
	StartItem();
};


/*
===============================================================================

DISSOLUTION OF ETERNITY POWERUPS

===============================================================================
*/

void() sphere_spawn;

void() newitems_touch = {
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	// QCC: Nyx can't pick up stuff during Ghost Walk
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;
		
	// only one per person, please.
	if (self.classname == "item_sphere")
		if (other.items2 & IT2_V_SPHERE)
			return;

	if (ExtSupported("EX_SPRINT"))
		sprint(other, "$qc_got_item", self.netname);
	else {
		sprint(other, "You got the ");
		sprint(other, self.netname);
		sprint(other, "\n");
	}

	if (deathmatch) {
		if (self.classname == "item_random_powerup") {
			self.nextthink = time + 60;
			self.think = random_regen;
		}
		else if (self.classname == "item_sphere") {
			self.mdl = self.model;
			self.nextthink = time + 60*3;
			self.think = SUB_regen;
		}
		else {
			self.mdl = self.model;
			self.nextthink = time + 60;
			self.think = SUB_regen;
		}
	}	

	sound(other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	stuffcmd(other, "bf\n");
	self.solid = SOLID_NOT;
	other.items = other.items | self.items;
	other.items2 = other.items2 | self.items2;
	self.model = string_null;

	// do the apropriate action
	if (self.items2 == IT2_SHIELD) {
		other.shield_time = 1;
		if (horde_ent)
			other.shield_finished = time + 5;
		else
			other.shield_finished = time + 30;
	}
	else if (self.items2 == IT2_ANTIGRAV) {
		other.antigrav_time = 1;
		if (horde_ent)
			other.antigrav_finished = time + 10;
		else
			other.antigrav_finished = time + 45;
		other.gravity = 0.25;
		if (coop && self.classname == "item_powerup_belt" && !horde_ent) { // Respawn anti-gravity belt in coop, since it might be required for progression
			self.target = string_null;
			self.think = SUB_regen;
			self.nextthink = time + 2.5;
		}
	}
	else if (self.items2 == IT2_V_SPHERE) {
		other.items2 = other.items2 | IT2_V_SPHERE;
		sphere_spawn();
	}
	
	activator = other;
	SUB_UseTargets();
};

// QUAKED item_powerup_shield (0 .5 .8) (-16 -16 -24) (16 16 32)
// The shield upgrade
void() shield_think = {
	if (self.owner.shield_death_time < time) {
		self.owner.shield_entity = world;
		remove(self);
		return;
	}
	
	if ((self.owner.shield_death_time - 0.25) <= time)
		self.model = string_null;
	else {
		setorigin(self, self.owner.origin);	
		self.v_angle = self.owner.v_angle;
		self.angles = self.owner.angles;
	}
	
	self.think = shield_think;
	self.nextthink = time + 0.05;
};

void(entity shieldOwner, vector dir) shield_spawn = {
	if (shieldOwner.shield_death_time > time)
		return;
	
	entity newShield;
	newShield = spawn();
	newShield.owner = shieldOwner;
	newShield.solid = SOLID_NOT;
	newShield.takedamage = DAMAGE_NO;
	newShield.movetype = MOVETYPE_NONE;
	newShield.classname = "power_shield";
	
	shieldOwner.shield_death_time = time + 0.3;
	shieldOwner.shield_entity = newShield;
		
	newShield.v_angle = shieldOwner.v_angle;
	newShield.angles = shieldOwner.angles;
	setorigin(newShield, shieldOwner.origin);
	setmodel(newShield, "progs/p_shield.mdl");
	setsize(newShield, '0 0 0', '0 0 0');

	newShield.nextthink = time + 0.1; 		
	newShield.think = shield_think;
};

float(entity targ, entity inflictor, entity attacker, float damage) shield_hit = {
	vector	dir;
	float	save, hitAngle;
			
	dir = inflictor.origin - targ.origin;
	save = vectoyaw (dir);
	makevectors(targ.angles);
	hitAngle = save - vectoyaw (v_forward);

	if (hitAngle > 90 && hitAngle < 270)
		return damage;
	else if (hitAngle < -90 && hitAngle > -270)
		return damage;
	
	shield_spawn (targ, dir);			 

	if (targ.shieldSoundTime < time) {
		sound(targ, CHAN_ITEM, "shield/hit.wav", 1, ATTN_NORM);
		targ.shieldSoundTime = time + 0.5;
	}

	if (inflictor.classname == "lava_spike")
		save = damage * 0.70;
	else
		save = damage * 0.30;

	return save;
};

void() item_powerup_shield = {
	self.touch = newitems_touch;
	precache_model("progs/shield.mdl");
	precache_model("progs/p_shield.mdl");
	precache_sound("shield/pickup.wav");
	precache_sound("shield/hit.wav");
	precache_sound("shield/fadeout.wav");
	self.noise = "shield/pickup.wav";
	setmodel(self, "progs/shield.mdl");
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_power_shield";
	else
		self.netname = "Power Shield";
	self.items2 = IT2_SHIELD;
	setsize(self, '-16 -16 -24', '16 16 32');
	StartItem();
};

// QUAKED item_powerup_belt (0 .5 .8) (-16 -16 -24) (16 16 32)
// The anti-grav belt
void() item_powerup_belt = {
	self.touch = newitems_touch;
	precache_model("progs/beltup.mdl");
	precache_sound("belt/pickup.wav");
	precache_sound("belt/use.wav");
	precache_sound("belt/fadeout.wav");
	self.noise = "belt/pickup.wav";
	setmodel(self, "progs/beltup.mdl");
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_anti_grav_belt";
	else
		self.netname = "Anti-Gravity Belt";
	self.items2 = IT2_ANTIGRAV;
	setsize(self, '-16 -16 -24', '16 16 32');
	StartItem();
};


// QUAKED item_sphere (0 0 1) (-8 -8 -8) (8 8 8) ?
// The Vengeance Sphere. DEATHMATCH ONLY.
void() sphere_impact = {
	if (other.health)
        T_Damage(other, self, self, 1000);
    T_RadiusDamage(self, self, 300, other);
	self.origin = self.origin - 8*normalize(self.velocity);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	BecomeExplosion();
};

void(entity ownerEntity) sphere_remove = {
	entity theSphere;	
	theSphere = find(world, classname, "Vengeance");
	while (theSphere != world) {
		if (theSphere.owner == self) {
			if (ExtSupported("EX_SPRINT"))
				bprint("$qc_death_denied_vengance", theSphere.owner.netname);
			else {
				bprint(theSphere.owner.netname);
				bprint(" is denied Vengeance\n");
			}
			remove(theSphere);
			theSphere = find(world, classname, "Vengeance");
		}
		else
			theSphere = find(theSphere, classname, "Vengeance");
	}
};

void() sphere_attack = {
	self.solid = SOLID_TRIGGER;
	self.touch = sphere_impact;
	if (self.enemy.health < 1) {
		if (ExtSupported("EX_SPRINT"))
			sprint(self.owner, "$qc_you_are_denied_vengeance");
		else
			sprint(self.owner, "You are denied Vengeance\n");
		remove(self);
		return;
	}
	ai_track(self.enemy, 650);
	self.nextthink = time + 0.1;
    self.think = sphere_attack; 
};

void() sphere_think = {
	if (self.shieldSoundTime < time) {
		sound(self, CHAN_VOICE, "sphere/sphere.wav", 1, ATTN_NORM);
		self.shieldSoundTime = time + 4;
	}	
	if (time > self.delay) {
		if (self.owner.items2 & IT2_V_SPHERE)
			self.owner.items2 = self.owner.items2 - IT2_V_SPHERE;
		if (ExtSupported("EX_SPRINT"))
			sprint(self.owner, "$qc_vengeance_lost");
		else
			sprint(self.owner, "Vengeance Sphere lost\n");
		remove(self);
		return;
	}
	if (self.owner.health < 1) {
		if (self.owner.items2 & IT2_V_SPHERE)
			self.owner.items2 = self.owner.items2 - IT2_V_SPHERE;
		if (self.owner.enemy.classname == "player") {
			self.enemy = self.owner.enemy;
			sphere_attack();
			return;
		}
		if (self.owner.enemy.owner.classname == "player") {
			self.enemy = self.owner.enemy.owner;
			sphere_attack();
			return;
		}
		remove(self);
		return;
	}	
	ai_orbit(self.owner, 16, '0 0 48');	
    self.think = sphere_think;
    self.nextthink = time + 0.1;
};

void() sphere_spawn = {
    entity missile;
    missile = spawn();
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_NOT;
    missile.classname = "Vengeance";
	missile.netname = "Vengeance Sphere";
    missile.owner = other;
    missile.weapon = 0;
    missile.delay = time + 30;
    setmodel(missile, "progs/sphere.mdl");
    setsize(missile, '0 0 0', '0 0 0');     
    setorigin(missile, self.origin);
	missile.avelocity = '40 40 40';
    missile.think = sphere_think;
    missile.nextthink = time + 0.1;
};

void() item_sphere = {
    if (!deathmatch) {
		remove(self);
        return;
    }
    precache_model("progs/sphere.mdl");
	precache_sound("sphere/sphere.wav");
	self.noise = "sphere/sphere.wav";
	if (ExtSupported("EX_SPRINT"))
		self.netname = "$qc_vengeance_sphere";
	else
		self.netname = "Vengeance Sphere";
    self.touch = newitems_touch;
    setmodel(self, "progs/sphere.mdl");
    setsize(self, '-8 -8 -8', '8 8 8');
	self.avelocity = '40 40 40';
	StartItem();
};

// =======================================================
// Random Items!
// =======================================================

// equal divisions of 1:
// 5: 0.2, 0.4, 0.6, 0.8, 1
// 6: 0.16, 0.33, 0.48, 0.66, 0.83, 1
// 7: 0.14, 0.28, 0.43, 0.56, 0.71, 0.86, 1
// 8: 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1
void() random_pick_type = {
	float randItem;	
	randItem = random();
	
	self.touch = powerup_touch;
	setsize(self, '-16 -16 -24', '16 16 32');

	if (randItem < 0.2) {
		self.touch = newitems_touch;
		self.noise = "shield/pickup.wav";
		setmodel(self, "progs/shield.mdl");
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_power_shield";
		else
			self.netname = "Power Shield";
		self.items = 0;
		self.items2 = IT2_SHIELD;
	}
	else if (randItem < 0.4) {
		self.touch = newitems_touch;
		self.noise = "belt/pickup.wav";
		setmodel(self, "progs/beltup.mdl");
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_anti_grav_belt";
		else
			self.netname = "Anti-Gravity Belt";
		self.items = 0;
		self.items2 = IT2_ANTIGRAV;
	}
	else if (randItem < 0.6) {
		self.noise = "items/protect.wav";
		setmodel(self, "progs/invulner.mdl");
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_pentagram_of_protection";
		else
			self.netname = "Pentagram of Protection";
		self.items = IT_INVULNERABILITY;
		self.items2 = 0;
	}
	else if (randItem < 0.8) {
		self.noise = "items/inv1.wav";
		setmodel(self, "progs/invisibl.mdl");
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_ring_of_shadows";
		else
			self.netname = "Ring of Shadows";
		self.items = IT_INVISIBILITY;
		self.items2 = 0;
	}
	else {
		self.noise = "items/damage.wav";
		setmodel(self, "progs/quaddama.mdl");
		if (ExtSupported("EX_SPRINT"))
			self.netname = "$qc_quad_damage";
		else
			self.netname = "Quad Damage";
		self.items = IT_QUAD;
		self.items2 = 0;
	}
};

// QUAKED item_random_powerup (0 .5 .8) (-16 -16 -24) (16 16 32)
// The Random Box! Contains a random powerup.
void() item_random_powerup = {
	if (!deathmatch) {
		remove(self);
		return;
	}
	
	// Precache the lot of it....
	precache_model("progs/shield.mdl");
	precache_model("progs/p_shield.mdl");
	precache_model("progs/beltup.mdl");
	precache_model("progs/invulner.mdl");
	precache_model("progs/invisibl.mdl");
	precache_model("progs/quaddama.mdl");

	precache_sound("items/inv1.wav");
	precache_sound("items/inv2.wav");
	precache_sound("items/inv3.wav");
	precache_sound("items/protect.wav");
	precache_sound("items/protect2.wav");
	precache_sound("items/protect3.wav");
	precache_sound("items/damage.wav");
	precache_sound("items/damage2.wav");
	precache_sound("items/damage3.wav");

	precache_sound("belt/pickup.wav");
	precache_sound("belt/use.wav");
	precache_sound("belt/fadeout.wav");
	precache_sound("shield/pickup.wav");
	precache_sound("shield/hit.wav");
	precache_sound("shield/fadeout.wav");

	random_pick_type();
	StartItem();
};

void() random_regen = {
	random_pick_type();
	SUB_regen();
};