/*
===================================
PLAYER THINK FUNCTIONS
===================================
*/

float() HordeGetPlayersAlive;

void() PlayerDeathThink = {
	float forward;
	
	if ((self.flags & FL_ONGROUND))	{
		forward = vlen(self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

	if (self.spawn_deferred) {
		entity spot;		
		spot = SelectSpawnPoint(FALSE);
		if (spot != world || time >= self.spawn_deferred)
			respawn();
		return;
	}

	// Wait for all buttons released
	if (self.deadflag == DEAD_DEAD)	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

	// Wait for any button down
	if (!self.button2 && !self.button1 && !self.button0)
		return;

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;

	// MG1: Yoder Sept24, 2021
	if (horde_ent) {
		if ((coop && HordeGetPlayersAlive() <= 0) || (!coop))
			horde_respawn_all();
		return;
	}	

	respawn();
};

void(float num_bubbles) DeathBubbles;

// Called every frame before physics are run
void() PlayerPreThink = {
	if (intermission_running) {
		stuffcmd(self, "v_cshift 1 1 1 1\n"); // Reset view color
		IntermissionThink();
		return;
	}

	QCC_PreThinkImpulse(); // Need this to use the prompts for champion selection

	// Intermission or Finale
	if (self.view_ofs == '0 0 0')
		return;

	if (self.qccChampion == QCC_OBSERVER) {
		QCC_ObserverPreThink();
		return;
	}
	
   	// HIP: Kill player on Edge of Oblivion
   	if (self.origin_z < -1300 && world.model == "maps/hipdm1.bsp" && self.health > 0) {
    	self.deathtype = "falling";
    	if (self.invincible_finished >= time) {
        	self.invincible_finished = 0;
         	self.items = self.items - (self.items & IT_INVULNERABILITY);
         	self.invincible_time = 0;
			self.invincible_finished = 0;
         	self.effects = self.effects - (self.effects & EF_PENTALIGHT);
        }
      	T_Damage(self, self, world, self.health + 1000);
    }

	// ROGUE
	if (earthquake_active) {
		if (self.flags & FL_ONGROUND) {
			self.velocity_x = self.velocity_x + (random() * earthquake_intensity * 2) - earthquake_intensity;
			self.velocity_y = self.velocity_y + (random() * earthquake_intensity * 2) - earthquake_intensity;
			self.velocity_z = self.velocity_z + (random() * earthquake_intensity * 2) - earthquake_intensity;
		}
	}

	makevectors(self.v_angle); // Is this still used?

	if (deathmatch || coop)
		CheckRules();

	WaterMove();

	// HIP: Wetsuit
	if (self.wetsuit_finished > time) {
		if (self.waterlevel==2)
			self.velocity = self.velocity * 1.25;
		if (self.waterlevel==3)
			self.velocity = self.velocity * 1.5;
    	if (self.waterlevel >= 2) {
			if (self.swim_flag < time) {
                self.swim_flag = time + 7;
				sound(self, CHAN_BODY, "misc/wetsuit.wav", 1, ATTN_NORM);
			}
			else {
				if (fabs(self.swim_flag - time - 6)<0.04)
					DeathBubbles(1);
				else if (fabs(self.swim_flag - time - 5.5)<0.04)
					DeathBubbles(1);
				else if (fabs(self.swim_flag - time - 5)<0.04)
					DeathBubbles(1);
			}
        }
    }

	if (self.waterlevel == 2)
		CheckWaterJump();

	if (self.deadflag >= DEAD_DEAD) {
		PlayerDeathThink();
		return;
	}
	
	if (self.deadflag == DEAD_DYING)
		return;	// Dying, so do nothing

	if (self.button2)
		PlayerJump();
	else {
		// QCC: Hackaround to give Duke's jetpack turning off event an audio queue
		if (self.qccChampion == QCC_DUKENUKEM && self.qccDoubleJump > 0 && self.qccDoubleJump < 101) {
			self.qccDoubleJump = 300;
			sound(self, CHAN_ITEM, "duke/jetpakof.wav", 1, ATTN_NORM);
		}
		self.flags = self.flags | FL_JUMPRELEASED;
	}

	self.qccPreThink(); // Custom champion pre-think, generally used to modify movement

	// Teleporters can force a non-moving pause time	
	if (time < self.pausetime)
		self.velocity = '0 0 0';
	
	// ROGUE
	if (self.items2 & IT2_ANTIGRAV) {
		if (time > self.AGping) {
			sound(self, CHAN_AUTO, "belt/use.wav", 0.4, ATTN_NORM);
			self.AGping = time + 3;
			if (self.AGping >= self.antigrav_finished - 3)
				self.AGping = self.antigrav_finished + 3;
		}
	}

	RuneApplyElder(self); // Regeneration Rune

	if (time > self.attack_finished && self.currentammo == 0 && self.weapon != IT_AXE && self.weapon != QCC_ABILITY && self.weapon != IT_MJOLNIR) {
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
	}
};

void() xpackEnding; // ROGUE ending

//Called every frame after physics are run
void() PlayerPostThink = {
    // Intermission or Finale
	if (self.view_ofs == '0 0 0') {
		earthquake_postthink();
		return;
	}

	if (self.qccChampion == QCC_OBSERVER) {
		QCC_ObserverPostThink();
		return;
	}

	if (self.wetsuit_finished > time) {
		if (self.waterlevel==2)
			self.velocity = self.velocity * 0.8;
		if (self.waterlevel==3)
			self.velocity = self.velocity * 0.66;
    }
	
    earthquake_postthink(); // ROGUE
	
	if (self.deadflag)
		return;

	if (rogue_cutscene_running)
		xpackEnding();

	self.qccPostThink();
		
	W_WeaponFrame();

	// Check to see if player landed and play landing sound
	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0)) {
		if (self.watertype == CONTENT_WATER)
			sound(self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650 && !(self.qccFlags & QCC_FL_ACROBAT)) {
			T_Damage(self, world, world, 5); 
			sound(self, CHAN_VOICE, self.qccSndLand2, 1, ATTN_NORM);
			if (self.health <= 5)
				self.deathtype = "falling";
		}
		else if (self.qccTauntTimer < time)
			sound(self, CHAN_VOICE, self.qccSndLand1, 1, ATTN_NORM);

		self.jump_flag = 0;
	}

	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;

	CheckPowerups();
	CheckHealthRot();
	QCC_CheckArmorRot();
};