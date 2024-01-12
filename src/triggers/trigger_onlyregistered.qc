// ONLY REGISTERED TRIGGERS

void() trigger_onlyregistered_touch = {
	if (other.classname != "player")
		return;

	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;

	if (cvar("registered")) {
		self.message = string_null;
		SUB_UseTargets();
		remove(self);
	}
	else {
		if (self.message != string_null) {
			centerprint (other, self.message);
			sound(other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		}
	}
};

/*QUAKED trigger_onlyregistered (.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
void() trigger_onlyregistered = {
	precache_sound("misc/talk.wav");
	InitTrigger();
	self.touch = trigger_onlyregistered_touch;
};