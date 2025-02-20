/*
======================================================
QCC: DUSKDUDE
======================================================
*/
void() QCC_FastFire;
void() QCC_PickupThrowable;
void() QCC_DuskDudeBotPre;

void() QCC_DuskDude =
{
	// Stats
	self.qccClass = QCC_MEDIUM;
    self.qccAbilityFunc = QCC_FastFire;
	self.qccAbilityString = "Fast Fire Totem";
	self.qccInteractFunc = QCC_PickupThrowable;
	self.qccBotPreThink = QCC_DuskDudeBotPre;
	self.qccFlags |= QCC_FL_ACROBAT;
	self.qccFlags |= QCC_FL_MERMAID;
	self.qccFlags |= QCC_FL_FAST_MELEE;
	sound(self, CHAN_VOICE, "silence.wav", 1, ATTN_NORM);
	if (ExtSupported("EX_LOCALSOUND"))
		localsound(self, "dusk/sicklestart.wav");
	else
		sound(self, 7, "dusk/sicklestart.wav", 1, ATTN_NORM);
	// Model
	setmodel(self, "progs/qcdusk.mdl");
	QCC_SetSkin(6);
	self.qccGibSkins = self.qccMaxSkins;
	self.qccChampGib = "progs/h_qcdusk.mdl";
	self.qccMeleeMdl = "progs/v_sickles.mdl";
	// Sounds
	self.qccSndMelee = "dusk/sickleslice.wav";
	self.qccSndMeleeHit = "";
	self.qccSndMeleeWall = "player/axhit2.wav";
	self.qccSndJump = "dusk/jump.wav";
	self.qccSndLand1 = "dusk/land.wav";
	self.qccSndLand2 = "dusk/land02.wav";
	self.qccSndPain1 = "dusk/damage.wav";
	self.qccSndPain2 = "dusk/damage.wav";
	self.qccSndPain3 = "dusk/damage.wav";
	self.qccSndPain4 = "dusk/damage.wav";
	self.qccSndPain5 = "dusk/damage.wav";
	self.qccSndPain6 = "dusk/damage.wav";
	self.qccSndDeath1 = "dusk/death.wav";
	self.qccSndDeath2 = "dusk/death.wav";
	self.qccSndDeath3 = "dusk/death.wav";
	self.qccSndDeath4 = "dusk/death.wav";
	self.qccSndDeath5 = "dusk/death.wav";
	self.qccSndAxHit1 = "dusk/damage.wav";
	self.qccSndBurn1 = "dusk/damage.wav";
	self.qccSndBurn2 = "dusk/damage.wav";
	self.qccSndGasp1 = "dusk/jump.wav";
	self.qccSndGasp2 = "dusk/jump.wav";
	self.qccSndDrown1 = "dusk/damage.wav";
	self.qccSndDrown2 = "dusk/damage.wav";
	self.qccSndH2oDeath = "dusk/death.wav";
};

/*
======================================================
QCC: FASTFIRE
======================================================
*/

// called by FastFireEnt
void() QCC_FastFireProc =
{
	if (self.owner.deadflag != DEAD_NO)
		self.qccAbilityTimer = 0;
	if (self.qccAbilityTimer > 0)
    {
		if (self.owner.attack_finished > time)
			self.owner.attack_finished -= 0.1;
		self.qccAbilityTimer -= 0.1;
		// start fading the purple tint at a certain point
		if (self.qccAbilityTimer < 3)
		{
			stuffcmd(self.owner, "v_cshift 255 0 128 ");
			stuffcmd(self.owner, ftos(self.qccAbilityTimer / 3.0 * 64));
			stuffcmd(self.owner, "\n");
		}
        self.nextthink = time + 0.1;
        self.think = QCC_FastFireProc;
    }
    else
    {
		self.owner.qccAbilityTimer = time + QCC_GLOBAL_COOLDOWN;
        stuffcmd(self.owner, "v_cshift 1 1 1 1\n");
        remove(self);
    }
};

// called by Dusk Dude
// doubles attack cooldown speed
void() QCC_FastFire =
{
	if (self.qccAbilityTimer < 0)
		return;
	self.qccAbilityTimer = -1;
	if (self.attack_finished > time)
		self.attack_finished -= 0.1;
    s = spawn();
    s.owner = self;
	s.qccAbilityTimer = 6.6;
	s.nextthink = time + 0.1;
	s.think = QCC_FastFireProc;
    stuffcmd(self, "v_cshift 255 0 128 64\n");
	sound(self, CHAN_ITEM, "dusk/fastfirestart.wav", 1, ATTN_NORM);
	if (ExtSupported("EX_LOCALSOUND"))
		localsound(self, "dusk/fastfire.wav");
	else
		sound(self, CHAN_VOICE, "dusk/fastfire.wav", 1, ATTN_NORM);
};

/*
======================================================================================
QCC: PICKUP OBJECT
Uses Impulse QCC_IM_INTERACT (138) to first pickup an item, then again to throw it.
Item's touch is changed into a movetype BOUNCE and self.touch should be a damage function.
======================================================================================
*/
void() QCC_ThrowableTouch =
{
	vector off;

	if (other == self.qccAbilityOwner)
		return;
	
	off = '0 0 0';
	if (self.qccFlags & QCC_FL_THR_IT_BSP)
	{	
		//off += v_right * vlen(self.size) * 0.25;
		off_z += self.size_z * 0.25;
	}
	else if (self.qccFlags & QCC_FL_THR_IT_MDL)
		off_z += self.size_z * 0.5;
	setsize(self, '0 0 0', '0 0 0'); // needs to be this so the throw entity hull doesn't hit the BSP
	setorigin(self, self.origin + off);
	
	// ITEMS
	if (self.flags & FL_ITEM)
	{
		if (self.classname == "qcc_item_lightarmor")
			particle(self.origin, '0 0 75', 26, 100);
		else if (self.classname == "qcc_item_heavyarmor")
			particle(self.origin, '0 0 100', 74, 200);
		else if (self.items == IT_QUAD)
			particle(self.origin, '0 0 400', 42, 255);
		else if (self.items == IT_INVULNERABILITY)
			particle(self.origin, '0 0 300', 249, 255);
		else if (self.items == IT_INVISIBILITY)
			particle(self.origin, '0 0 200', 240, 255);
		else if (self.classname == "item_sigil")
			particle(self.origin, '0 0 666', 148, 255);
		else if (self.classname == "life_essence") {
			particle(self.origin, '0 0 1' * self.dmg, 73, self.dmg * 2);
			self.noise = "player/tornoff2.wav";
		}
		else
			particle(self.origin, '0 0 1' * self.dmg, 6, self.dmg * 2);
	}
	// MEAT
	else if (self.classname == "gib" || self.classname == "player" || self.classname == "qcc_throwhead" || self.classname == "gibhead" || self.flags & FL_MONSTER)
	{	
		if (self.flags & FL_MONSTER)
			self.dmg = self.max_health;
		else if (self.classname == "player" || self.classname == "qcc_throwhead" || self.classname == "gibhead")
			self.dmg = 100;
		particle(self.origin, '0 0 1' * self.dmg, 73, self.dmg * 2);
		self.noise = "player/tornoff2.wav";
	}
	// EVERYTHING ELSE
	else
		particle(self.origin, '0 0 1' * self.dmg, 6, self.dmg * 2);

	// Deal Damage
	if (other.takedamage)
	{
		if (self.dmg < 50)
			self.dmg = 50;
		T_Damage(other, self, self.qccAbilityOwner, self.dmg);
	}
	if (self.items & (IT_QUAD | IT_INVISIBILITY | IT_INVULNERABILITY))
		T_RadiusDamage(self, self.qccAbilityOwner, 400, other);
	else if (self.classname == "item_sigil")
	{
		other = findradius(self.origin, 5000);
		while (other)
		{
			if (other.takedamage)
				T_Damage(other, self, self.qccAbilityOwner, 40000);
			else if (other.classname == "monster_boss")
			{
				other.think = boss_death10;
				other.nextthink = time + 0.01;
			}
			other = other.chain;
		}
	}

	sound(self, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	if (self.noise != "blob/hit1.wav")
		sound(self, CHAN_WEAPON, "blob/hit1.wav", 1, ATTN_NORM);
	
	// Cleanup	
	if (self.classname == "player")
	{
		if (cvar("pr_checkextension"))
			if (checkextension("EX_MOVETYPE_GIB"))
				self.movetype = MOVETYPE_GIB;
		return;
	}
	if (self.classname == "qcc_throwhead")
		qcc_throwhead_ct -= 1;
	remove(self);
};

// can be called by Dusk Dude or throwable
void(entity throw_ent) QCC_ThrowThrowable = {
	throw_ent.think = SUB_Null;
	throw_ent.nextthink = -1;
	throw_ent.solid = SOLID_BBOX;
	throw_ent.movetype = MOVETYPE_BOUNCE;
	throw_ent.ltime = time;

	makevectors(throw_ent.qccAbilityOwner.v_angle);
	if (throw_ent.qccAbilityOwner.deadflag == DEAD_NO) {
		throw_ent.velocity = v_forward * 600 + v_up * 200 + crandom()*v_right*10 + crandom() * v_up * 10;
		throw_ent.avelocity = '0 0 0';
	}
	else {
		throw_ent.velocity = '0 0 300';
		throw_ent.avelocity = '300 300 300';
	}
	throw_ent.angles = vectoangles(throw_ent.velocity);
	

	if (throw_ent.flags & FL_ITEM) {
		throw_ent.owner = throw_ent.qccAbilityOwner;
		if (throw_ent.classname == "item_rockets" || throw_ent.classname == "weapon_rocketlauncher" || throw_ent.classname == "weapon_grenadelauncher")
			throw_ent.touch = T_MissileTouch;
		else
			throw_ent.touch = QCC_ThrowableTouch;
	}
	else if (throw_ent.classname == "missile")
		throw_ent.owner = throw_ent.qccAbilityOwner;
	// Detonate them grenades
	else if (throw_ent.classname == "grenade") {
		if (!(throw_ent.qccAbilityOwner.deadflag)) {
			throw_ent.avelocity = '300 300 300';
			throw_ent.angles = vectoangles(throw_ent.velocity);
		}
		throw_ent.owner = throw_ent.qccAbilityOwner;
		throw_ent.touch = GrenadeTouch;
		throw_ent.nextthink = time + 2.5;
		throw_ent.think = GrenadeExplode;
	}
	else if (throw_ent.classname == "dynamite") {
		throw_ent.owner = throw_ent.qccAbilityOwner;
		throw_ent.think = QCC_DynaFuse;
		throw_ent.nextthink = time;
	}
	else if (throw_ent.classname == "misc_explobox2") {
		throw_ent.enemy = throw_ent.qccAbilityOwner; // explo_box expects to be shot to be blown up, giving kill responsiblity to its attacker
		throw_ent.touch = barrel_detonate;
	}
	else
		throw_ent.touch = QCC_ThrowableTouch;

	sound(throw_ent.qccAbilityOwner, CHAN_WEAPON, "hknight/slash1.wav", 1, ATTN_NORM);
	throw_ent.qccAbilityOwner.qccAbilityEnt = world;
};

// called by throwable; keeps it in front of the player
void() QCC_ThrowableProc = {
	if (self.qccAbilityOwner.deadflag > DEAD_NO) {
		QCC_ThrowThrowable(self);
		return;
	}
	if (intermission_running)
		return;
	vector pos;
	makevectors(self.qccAbilityOwner.v_angle);
	pos = self.qccAbilityOwner.origin + '0 0 16' + v_forward * 32;
	if (self.qccFlags & QCC_FL_THR_IT_BSP) {	
		pos += v_right * vlen(self.size) * 0.25;
		pos_z -= self.size_z * 0.25;
	}
	else if (self.qccFlags & QCC_FL_THR_IT_MDL)
		pos_z -= self.size_z * 0.5;
	setorigin(self, pos);
	self.angles = self.qccAbilityOwner.angles;
	if (!(self.qccFlags & QCC_FL_THR_IT_BSP))
		self.angles_y += 180;

	if (self.classname == "dynamite") {
		self.frame = floor(time * 10) % 2;
		if (vlen(self.velocity) > 0 && floor(time) % 2 > 0)
        	sound(self, CHAN_WEAPON, "caleb/dynafuse.wav", 1, ATTN_NORM);
		// Fuse ran out!
		if (self.qccAbilityTimer < time) {
			self.qccAbilityOwner.qccAbilityEnt = world;
			sound(self, CHAN_WEAPON, "silence.wav", 1, ATTN_NORM);
			T_RadiusDamage(self, self.owner, 150, world);
			WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte(MSG_BROADCAST, TE_EXPLOSION);
			WriteCoord(MSG_BROADCAST, self.origin_x);
			WriteCoord(MSG_BROADCAST, self.origin_y);
			WriteCoord(MSG_BROADCAST, self.origin_z);
			BecomeExplosion();
		}
	}
	
	self.think = QCC_ThrowableProc;
	self.nextthink = time + 0.01;
};

void() QCC_PickupThrowable = {
	vector pos;
	entity ent;

	if (self.qccAbilityEnt != world) {
		QCC_ThrowThrowable(self.qccAbilityEnt);
		return;
	}

	pos = self.origin + '0 0 16';	
	ent = findradius(pos, 80);
	while (ent) {
		if ((ent.qccFlags & QCC_FL_THROWABLE) && infront(ent) && ent != world) {
			if (ent.qccAbilityOwner.classname != "player" || ent.qccAbilityOwner == ent) {
				makevectors(self.v_angle);
				traceline(pos, ent.origin + '0 0 8', 1, self);
				if (trace_fraction == 1.0)
					break;
				else if (trace_ent == ent)
					break;
			}
		}
		ent = ent.chain;
	}

	if (ent == world || ent == self)
		return;

	// Duplicate items so that they can respawn in their proper spots
	if (ent.flags & FL_ITEM)
	{
		self.qccAbilityEnt = spawn();
		setmodel(self.qccAbilityEnt, ent.model);
		self.qccAbilityEnt.skin = ent.skin;
		self.qccAbilityEnt.classname = ent.classname;
		self.qccAbilityEnt.flags |= FL_ITEM;
		self.qccAbilityEnt.items = ent.items;
		
		if (ent.weapon) {
			if (ent.aflag) {
				setsize(self.qccAbilityEnt, '0 0 0', '32 32 32');
				self.qccAbilityEnt.dmg = 50;
				self.qccAbilityEnt.qccFlags |= QCC_FL_THR_IT_BSP;
				if (ent.classname == "item_cells")
					self.qccAbilityEnt.noise = "weapons/lstart.wav";
				else
					self.qccAbilityEnt.noise = "weapons/lock4.wav";
			}
			else {
				setsize(self.qccAbilityEnt, '-16 -16 16', '16 16 48');
				self.qccAbilityEnt.dmg = 100;
				self.qccAbilityEnt.qccFlags |= QCC_FL_THR_IT_MDL;
				if (ent.classname == "weapon_lightning")
					self.qccAbilityEnt.noise = "weapons/lstart.wav";
				else
					self.qccAbilityEnt.noise = "weapons/pkup.wav";
			}
		}
		else if (ent.classname == "item_health" || ent.classname == "life_essence") {
			setsize(self.qccAbilityEnt, '4 4 4', '28 28 28');
			self.qccAbilityEnt.qccFlags |= QCC_FL_THR_IT_BSP;
			self.qccAbilityEnt.dmg = ent.healamount;
			self.qccAbilityEnt.noise = ent.noise;
		}
		else if (ent.classname == "qcc_item_lightarmor" || ent.classname == "qcc_item_heavyarmor") {
			setsize(self.qccAbilityEnt, '-12 -12 20', '12 12 44');
			self.qccAbilityEnt.qccFlags |= QCC_FL_THR_IT_MDL;
			self.qccAbilityEnt.dmg = ent.armorvalue * 2;
			self.qccAbilityEnt.noise = ent.noise;
		}
		else if ((ent.items & (IT_QUAD | IT_INVISIBILITY | IT_INVULNERABILITY)) || ent.classname == "item_sigil") {
			setsize(self.qccAbilityEnt, '-12 -12 20', '12 12 44');
			self.qccAbilityEnt.qccFlags |= QCC_FL_THR_IT_MDL;
			self.qccAbilityEnt.dmg = 40000;
			self.qccAbilityEnt.noise = ent.noise;
		}
		else if (ent.classname == "qcc_item_hourglass") {
			setsize(self.qccAbilityEnt, '-4 -4 0', '4 4 28');
			self.qccAbilityEnt.qccFlags |= QCC_FL_THR_IT_MDL;
			self.qccAbilityEnt.dmg = 50;
			self.qccAbilityEnt.noise = "timeoff.wav";
		}
		else {
			setsize(self.qccAbilityEnt, ent.mins + '4 4 4', ent.maxs - '4 4 4');
			self.qccAbilityEnt.qccFlags |= QCC_FL_THR_IT_MDL;
			self.qccAbilityEnt.dmg = 50;
			self.qccAbilityEnt.noise = "blob/hit1.wav";
		}
		// Deactivate item and setup for respawn
		ent.model = string_null;
		ent.solid = SOLID_NOT;
		if (deathmatch) {
			if (deathmatch == 3 || deathmatch == 5)
				ent.nextthink = time + 10;
			else if (deathmatch != 2)
				ent.nextthink = time + 15;					
		}
		if (ent.items & (IT_KEY1 | IT_KEY2)) // we need keys to respawn no matter what
			ent.nextthink = time + 15;
		ent.think = SUB_regen;
		activator = self;
		other = self;
		self = ent;
		SUB_UseTargets();
		self = other;
	}
	else {
		ent.noise = "blob/hit1.wav";
		if (ent.flags & FL_MONSTER)
			ent.flags = FL_MONSTER;
		else
			ent.flags = 0;
		if (vlen(ent.size) >= 9)
			setsize(ent, ent.mins + '4 4 4', ent.maxs - '4 4 4');
		self.qccAbilityEnt = ent;
	}

	self.qccAbilityEnt.qccAbilityOwner = self;
	self.qccAbilityEnt.movetype = MOVETYPE_NONE;
	self.qccAbilityEnt.solid = SOLID_NOT;
	self.qccAbilityEnt.angles = self.angles;
	if (!(self.qccAbilityEnt.qccFlags & QCC_FL_THR_IT_BSP))
		self.qccAbilityEnt.angles_y += 180;
	self.qccAbilityEnt.velocity = '0 0 0';
	self.qccAbilityEnt.avelocity = '0 0 0';
	self.qccAbilityEnt.think = QCC_ThrowableProc;
	self.qccAbilityEnt.nextthink = time + 0.01;
	pos = pos + v_forward * 32;
	if (self.qccAbilityEnt.qccFlags & QCC_FL_THR_IT_BSP) {	
		pos += v_right * vlen(self.qccAbilityEnt.size) * 0.25;
		pos_z -= self.qccAbilityEnt.size_z * 0.25;
	}
	else if (self.qccAbilityEnt.qccFlags & QCC_FL_THR_IT_MDL)
		pos_z -= self.qccAbilityEnt.size_z * 0.5;
	setorigin(self.qccAbilityEnt, pos);
};


/*
==============================
BOT STUFF
==============================
*/
void() QCC_DuskDudeBotPre = 
{
    if (self.enemy.flags & FL_MONSTER || self.enemy.classname == "player") {
		// DuskDude Fast Fire Totems on sight
        if (self.qccAbilityTimer < time && self.qccAbilityTimer >= 0 && visible(self.enemy))
            QCC_FireAbility();
    }
};

// TO-DO: pick up and throw items?