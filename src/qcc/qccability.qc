/*
====================================================
BASE ABILITY METHODS
====================================================
*/
void() QCC_AbilityUsed = {
	if (self.qccAbilityTimer > time)
		self.qccAbilityTimer += self.qccAbilityCost;
	else
		self.qccAbilityTimer = time + self.qccAbilityCost;
};

void(entity ent) QCC_AbilityTimeLeft = {
	// Defaults to QCC_RANGER
	sprint(ent, ent.qccAbilityString);
	if (ent.qccAbilityTimer - time <= QCC_GLOBAL_COOLDOWN - ent.qccAbilityCost) {
		sprint(ent, " is ready!\n");
		return;
	}
	sprint(ent, " ready in ");
	string time_left_str;
	time_left_str = ftos(floor(ent.qccAbilityTimer - time) - (QCC_GLOBAL_COOLDOWN - ent.qccAbilityCost));
	sprint(ent, time_left_str);
	sprint(ent, " seconds\n");
};

void(entity ent) QCC_AbilityCooldown = {
	if (ent.qccAbilityTimer > time)
		ent.qccAbilityTimer = ent.qccAbilityTimer - (QCC_GLOBAL_COOLDOWN * 0.1);
};

void() QCC_FireAbility = {
	if (self.qccChampion == QCC_OBSERVER)
		return;

	// Check the timer
	if (self.qccAbilityTimer > time + QCC_GLOBAL_COOLDOWN - self.qccAbilityCost) {
		if (self.qccAbilityTimer <= time + QCC_GLOBAL_COOLDOWN)
			QCC_AbilityTimeLeft(self);
		return;
	}
	
	// Save the current weapon model so we can swap back to it
	if (self.qccAbilityTimer >= 0) {
		if (self.qccChampion != QCC_KEEN || self.weapon != IT_AXE)
			self.qccPrevWep = self.weapon;
	}

	// Use the Champion's ability
	self.qccAbilityFunc();
};

// We use this for any abilities that alter the player's view model
void() QCC_RestoreWeapon = {
	if (self.qccPrevWep != QCC_ABILITY)
		self.weapon = self.qccPrevWep;
	else {
		self.weapon = IT_SHOTGUN;
		self.weapon = W_BestWeapon();
	}
	self.weaponframe = 0;
	self.attack_finished = time;
	W_SetCurrentAmmo ();
	self.th_run();
};