void() GrenadeTouch;

void() W_FireAxe = {
	vector source, org;
	
	makevectors(self.v_angle);
	source = self.origin + '0 0 16';

	// Don't swing the pogo stick
	if (self.qccChampion == QCC_KEEN)
		return;
	
	// QCC: Projectile Deflection ---------------------------------------------
	entity ent;
	ent = findradius(source + v_forward*48, 32);
	while (ent)	{
		if (ent.qccFlags & QCC_FL_CANDEFLECT) {
			if (self.qccChampion == QCC_DUSKDUDE && infront(ent)) {
				ent.velocity *= -1;
				if (ent.owner.classname == "monster_ogre") // boost the grenade's damage to make it more worthwhile to deflect
					ent.touch = GrenadeTouch;
				else if (ent.owner.classname == "monster_shalrath") { // try to send vore balls back to sender
					if (ent.owner.health > 0)
						ent.enemy = ent.owner;
					else
						ent.enemy = world;
				}
				ent.owner = self;
			}
		}
		ent = ent.chain;
	}
	// ------------------------------------------------------------------------

	traceline(source, source + v_forward*64, 2, self); // made traceline larger, to make it easier to hit enemies
	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward * 4;

	if (trace_ent.takedamage && trace_ent.classname != "monster_boss") { // yoder mod, Jan 05 2021
		trace_ent.axhitme = 1;
		SpawnBlood(org, '0 0 0', 70);

		if (self.qccSndMeleeHit != "")
			sound(self, CHAN_WEAPON, self.qccSndMeleeHit, 1, ATTN_NORM);
        
		// Berserk ability increases damage dealt with fists
		if (self.qccChampion == QCC_DOOMSLAYER)
			QCC_DoomPunchHit();
		else {
			if (self.qccFlags & QCC_FL_FAST_MELEE) // Dusk Dude and Gordon Freeman attack faster, so they should deal a little less damage
				T_Damage(trace_ent, self, self, 50);
			else
				T_Damage(trace_ent, self, self, 70);

			// Death Knight sets enemies on fire with his sword
			if (self.qccChampion == QCC_DEATHKNIGHT)
				QCC_CatchFire(self, trace_ent);
		}
	}
	else {
        // hit wall
		sound(self, CHAN_WEAPON, self.qccSndMeleeWall, 1, ATTN_NORM);
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord(MSG_BROADCAST, org_x);
		WriteCoord(MSG_BROADCAST, org_y);
		WriteCoord(MSG_BROADCAST, org_z);
	}
};

void() player_axe1;
void() player_axeb1;
void() player_axec1;
void() player_axed1;

void() W_Axe_Attack = {
	sound(self, CHAN_WEAPON, self.qccSndMelee, 1, ATTN_NORM);
	float r = random();
	if (r < 0.25)
		player_axe1();
	else if (r < 0.5)
		player_axeb1();
	else if (r < 0.75)
		player_axec1();
	else
		player_axed1();
	self.attack_finished = time + 0.5;
	if (self.qccFlags & QCC_FL_FAST_MELEE) // Dusk Dude's sickles are fast in DUSK
		self.attack_finished = time + 0.25;
};