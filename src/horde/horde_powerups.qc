/*
============================
HORDE POWERUPS
============================
*/

void() HordePrecachePowerups = {
	// quad damage
	precache_model("progs/quaddama.mdl");
	precache_sound("items/damage.wav");
	precache_sound("items/damage2.wav");
	precache_sound("items/damage3.wav");
	
	// pentagram (invulnerability)
	precache_model("progs/invulner.mdl");
	precache_sound("items/protect.wav");
	precache_sound("items/protect2.wav");
	precache_sound("items/protect3.wav");

	// HIPNOTIC
	// empathy shield
	precache_model("progs/empathy.mdl");
	precache_sound("hipitems/empathy.wav");
	precache_sound("hipitems/empathy2.wav");
	precache_sound("items/suit2.wav");

	// horn
	precache_model("progs/horn.mdl");
	precache_sound("hipitems/horn.wav");

	// ROGUE
	// power shield
	precache_model("progs/shield.mdl");
	precache_model("progs/p_shield.mdl");
	precache_sound("shield/pickup.wav");
	precache_sound("shield/hit.wav");
	precache_sound("shield/fadeout.wav");

	// anti-gravity belt
	precache_model("progs/beltup.mdl");
	precache_sound("belt/pickup.wav");
	precache_sound("belt/use.wav");
	precache_sound("belt/fadeout.wav");
};

void() PowerupFade = {
	if (self.alpha > 0)	{
		self.alpha = self.alpha - 0.25 * frametime;
		self.nextthink = time; // think next frame
	}
	else
		remove(self);
}

void() horde_powerup_think = {
	if (self.velocity_z < 0) {
		dprint("WARNING: Powerup fell out of world. Remove\n");
		remove(self);
	}
	else {
		self.alpha = 1;
		self.think = PowerupFade;
		self.nextthink = time;
	}
};

void() horde_spawn_powerup = {
	float rand;

	if (!powerup_chance)
		powerup_chance = DEFAULT_POWERUP_CHANCE;
	
	if (random() < powerup_chance) { // "if (1)" to guarantee powerup drop
		dprint("powerup chance was: ");
		dprint(ftos(powerup_chance));
		dprint("\n");
		
		powerup_chance = DEFAULT_POWERUP_CHANCE;
		
		entity powerup = spawn();
		setorigin(powerup, self.origin + '0 0 0');

		//setsize(powerup, '-16 -16 -24', '16 16 32');
		powerup.flags = FL_ITEM;
		powerup.solid = SOLID_TRIGGER;
		powerup.movetype = MOVETYPE_BOUNCE;
		powerup.velocity = '0 0 300';
		
		//powerup.velocity_x = crandom() * 64;
		//powerup.velocity_y = crandom() * 64;
		powerup.touch = powerup_touch;
		powerup.think = horde_powerup_think;
		powerup.nextthink = time + 10;
		
		rand = random();
		// HIP -------------------------------------------------
		if (rand < 0.05) { // spawn horn of conjuring
			powerup.noise = "hipitems/horn.wav";
			setmodel(powerup, "progs/horn.mdl");
			powerup.netname = "Horn of Conjuring";
			powerup.touch = horn_touch;
			powerup.classname = "item_hornofconjuring";
		}
		else if (rand < 0.15) { // spawn empathy shields
			powerup.noise = "hipitems/empathy.wav";
			setmodel(powerup, "progs/empathy.mdl");
			if (ExtSupported("EX_SPRINT"))
				powerup.netname = "$qc_empathy_shields";
			else
				powerup.netname = "Empathy Shields";
			powerup.items2 = HIP_IT_EMPATHY_SHIELDS;
			powerup.touch = hip_powerup_touch;
			powerup.classname = "item_artifact_empathy_shields";
		}
		// ROGUE -----------------------------------------------
		else if (rand < 0.25) { // spawn power shield
			powerup.noise = "shield/pickup.wav";
			setmodel(powerup, "progs/shield.mdl");
			if (ExtSupported("EX_SPRINT"))
				powerup.netname = "$qc_power_shield";
			else
				powerup.netname = "Power Shield";
			powerup.items2 = IT2_SHIELD;
			powerup.touch = newitems_touch;
			powerup.classname = "item_powerup_shield";
		}
		else if (rand < 0.3) { // spawn anti-gravity belt
			powerup.noise = "belt/pickup.wav";
			setmodel(powerup, "progs/beltup.mdl");
			if (ExtSupported("EX_SPRINT"))
				powerup.netname = "$qc_anti_grav_belt";
			else
				powerup.netname = "Anti-Gravity Belt";
			powerup.items2 = IT2_ANTIGRAV;
			powerup.touch = newitems_touch;
			powerup.classname = "item_powerup_belt";
		}
		// -----------------------------------------------------
		else if (random() < 0.6) { // spawn pentagram (invulnerability)
			powerup.noise = "items/protect.wav";
			setmodel(powerup, "progs/invulner.mdl");
			if (ExtSupported("EX_SPRINT"))
				powerup.netname = "$qc_pentagram_of_protection";
			else
				powerup.netname = "Pentagram of Protection";
			powerup.items = IT_INVULNERABILITY;
			powerup.classname = "item_artifact_invulnerability";
		}
		else { // spawn quad damage
			powerup.noise = "items/damage.wav";
			setmodel(powerup, "progs/quaddama.mdl");
			if (ExtSupported("EX_SPRINT"))
				powerup.netname = "$qc_quad_damage";
			else
				powerup.netname = "Quad Damage";
			powerup.items = IT_QUAD;
			powerup.classname = "item_artifact_super_damage";
		}
		//powerup.effects = EF_DIMLIGHT;
		
		setsize(powerup, '-12 -12 -12', '12 12 12');
	}
	else
		powerup_chance = powerup_chance + POWERUP_CHANCE_GAIN;
};