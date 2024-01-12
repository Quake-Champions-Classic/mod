void() CheckPowerups =
{
	if (self.health <= 0)
		return;

	// invisibility
	if (self.invisible_finished) {
		// sound and screen flash when items starts to run out
		if (self.invisible_sound < time) {
			sound(self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}

		if (self.invisible_finished < time + 3) {
			if (self.invisible_time == 1) {
				if (ExtSupported("EX_SPRINT"))
					sprint(self, "$qc_ring_fade");
				else
					sprint(self, "Ring of Shadows magic is fading\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time) {
				self.invisible_time = time + 1;
				stuffcmd(self, "bf\n");
			}
		}
		
		// use the eyes
		if (self.qccChampion != QCC_NYX || self.qccAbilityTimer >= 0) {
			self.frame = 0;
			self.modelindex = modelindex_eyes;
			self.skin = 0; // QCC: Needed because eyes have no skins
		}

		if (self.invisible_finished < time) { // just stopped
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;

			if (self.qccChampion != QCC_NYX || self.qccAbilityTimer >= 0) {
				self.modelindex = self.modelindex_champ; // don't use eyes
				self.skin = self.qccSkin;
			}
		}
		
	}

	// invincibility
	if (self.invincible_finished) {
	// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3) {
			if (self.invincible_time == 1) {
				if (ExtSupported("EX_SPRINT"))
					sprint(self, "$qc_protection_fade");
				else
					sprint(self, "Protection is almost burned out\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			
			if (self.invincible_time < time) {
				self.invincible_time = time + 1;
				stuffcmd(self, "bf\n");
			}
		}
		
		if (self.invincible_finished < time) { // just stopped
			self.items = self.items - IT_INVULNERABILITY;
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
			self.effects = self.effects | EF_PENTALIGHT;
		else
			self.effects = self.effects - (self.effects & EF_PENTALIGHT);
	}

	// super damage
	if (self.super_damage_finished)	{
		// sound and screen flash when items starts to run out
		if (self.super_damage_finished < time + 3) {
			if (self.super_time == 1) {
				if (ExtSupported("EX_SPRINT"))
					sprint(self, "$qc_quad_fade");
				else
					sprint(self, "Quad Damage is wearing off\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}	  
			
			if (self.super_time < time) {
				self.super_time = time + 1;
				stuffcmd(self, "bf\n");
			}
		}

		if (self.super_damage_finished < time) { // just stopped
			self.items = self.items - IT_QUAD;
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
			self.effects = self.effects | EF_QUADLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_QUADLIGHT);
	}	

	// ID1: Biosuit	
	if (self.radsuit_finished) {
		self.air_finished = time + 12;		// don't drown

		// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3) {
			if (self.rad_time == 1) {
				if (ExtSupported("EX_SPRINT"))
					sprint(self, "$qc_biosuit_fade");
				else
					sprint(self, "Air supply in Biosuit expiring\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time) {
				self.rad_time = time + 1;
				stuffcmd(self, "bf\n");
			}
		}

		if (self.radsuit_finished < time) { // just stopped
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}

	// HIPNOTIC: Wetsuit
	if (self.wetsuit_finished) {
		self.air_finished = time + 12;		// don't drown
        
		if (self.wetsuit_finished < time + 3) {
			if (self.wetsuit_time == 1) {
				if (ExtSupported("EX_SPRINT"))
					sprint(self, "$qc_wetsuit_fade");
				else
					sprint(self, "Air supply in Wetsuit is running out\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.wetsuit_time = time + 1;
			}
			if (self.wetsuit_time < time) {
				self.wetsuit_time = time + 1;
				stuffcmd(self, "bf\n");
			}
		}
		if (self.wetsuit_finished < time) {
			self.items2 = self.items2 - HIP_IT_WETSUIT;
			self.wetsuit_time = 0;
			self.wetsuit_finished = 0;
		}
	}

	// HIPNOTIC: Empathy Shields
	if (self.empathy_finished) {
		if (self.empathy_finished < time + 3) {
			if (self.empathy_time == 1) {
				if (ExtSupported("EX_SPRINT"))
					sprint(self, "$qc_empathy_fade");
				else
					sprint(self, "Empathy Shields are running out\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.empathy_time = time + 1;
			}
			if (self.empathy_time < time) {
			self.empathy_time = time + 1;
				stuffcmd(self, "bf\n");
			}
		}
		if (self.empathy_finished < time) {
			self.items2 = self.items2 - HIP_IT_EMPATHY_SHIELDS;
			self.empathy_time = 0;
			self.empathy_finished = 0;
		}
		if (self.empathy_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}
	
    // ROGUE: Power Shield
	if (self.shield_finished) {
		if (self.shield_finished < time + 3) {
			if (self.shield_time == 1) {
				if (ExtSupported("EX_SPRINT"))
					sprint(self, "$qc_shield_failing");
				else
					sprint(self, "Shield failing...\n");
				sound(self, CHAN_AUTO, "shield/fadeout.wav", 1, ATTN_NORM);
				self.shield_time = 0;
			}
			if (self.shield_time < time) {
				self.shield_time = time + 1;
				stuffcmd(self, "bf\n");
			}
		}
		
		if (self.shield_finished < time) {
			if (ExtSupported("EX_SPRINT"))
				sprint(self, "$qc_shield_lost");
			else
				sprint(self, "Shield Lost.\n");
			self.shield_finished = 0;
			self.items2 = self.items2 - IT2_SHIELD;
		}
	}

    // ROGUE: Anti-Gravity Belt
	if (self.antigrav_finished) {
		if (self.antigrav_finished < time + 3) {
			if (self.antigrav_time == 1) {
				if (ExtSupported("EX_SPRINT"))
					sprint(self, "$qc_antigrav_failing");
				else
					sprint(self, "Antigrav failing...\n");
				self.antigrav_time = 0;
				sound(self, CHAN_AUTO, "belt/fadeout.wav", 1, ATTN_NORM);
			}
			if (self.antigrav_time < time) {
				self.antigrav_time = time + 1;
				stuffcmd(self, "bf\n");
			}
		}
		
		if (self.antigrav_finished < time) {
			if (ExtSupported("EX_SPRINT"))
				sprint(self, "$qc_antigrav_lost");
			else
				sprint(self, "Antigrav Lost.\n");
			self.antigrav_finished = 0;
			self.items2 = self.items2 - IT2_ANTIGRAV;
			self.gravity = 1.0;
		}
	}

	// QCC: Ability
	if (self.qccAbilityTimer > 0 && self.qccAbilityTimer < time) {
		if (ExtSupported("EX_PROMPT")) {
			if (self.qccChampion == QCC_KEEN)
				localsound(self, "keen/rayequip.wav");
			localsound(self, "ablready.wav");
		}
		else {
			if (self.qccChampion == QCC_KEEN)
				sound(self, CHAN_VOICE, "keen/rayequip.wav", 1, ATTN_NORM);
			sound(self, CHAN_ITEM, "ablready.wav", 1, ATTN_NONE);
		}
		QCC_AbilityTimeLeft(self);
		self.qccAbilityTimer = 0;
	}
};

void CheckHealthRot() {
	if (self.healthrot_nextcheck > time)
		return;

	if (self.health > self.max_health) {
		self.health = self.health - 1;
		//self.healthrot_nextcheck = time + 1;
		if (self.owner.qccClass != QCC_HEAVY)
			self.healthrot_nextcheck = time + 1;
		else
			self.healthrot_nextcheck = time + 2;
		return;
	}

	self.healthrot_nextcheck = 999999;
};