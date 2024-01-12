/*
================================
MG1: TRIGGER_COUNTER_TIMED
================================
*/

void() counter_timed_think = {
	self.count = self.cnt;
}

void() counter_timed_use = {
	self.count = self.count - 1;
	if (self.count < 0)
	return;
	
	self.nextthink = time + self.delay;

	if (self.count != 0) {
		if (activator.classname == "player" && (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0) {
			if (self.count >= 4) {
				if (ExtSupported("EX_CENTERPRINT"))
					centerprint_all("$qc_more_go");
				else
					centerprint_all("There are more to go...");
			} 
			else if (self.count == 3) {
				if (ExtSupported("EX_CENTERPRINT"))
					centerprint_all("$qc_three_more");
				else
					centerprint_all("Only 3 more to go...");
			}
			else if (self.count == 2) {
				if (ExtSupported("EX_CENTERPRINT"))
					centerprint_all("$qc_two_more");
				else
					centerprint_all("Only 2 more to go...");
			}
			else {
				if (ExtSupported("EX_CENTERPRINT"))
					centerprint_all("$qc_one_more");
				else
					centerprint_all("Only 1 more to go...");
			}
		}
		return;
	}
	
	if (activator.classname == "player"	&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0) {
		if (ExtSupported("EX_CENTERPRINT"))
			centerprint_all("$qc_sequence_completed");
		else
			centerprint_all("Sequence completed!");
	}

	self.enemy = activator;
	self.delay = 0;
	self.nextthink = -1;
	self.think = SUB_Null;
	multi_trigger ();
	remove(self);
};

/*QUAKED trigger_counter_timed (.5 .5 .5) ? nomessage message_all
Acts as an intermediary for an action that takes multiple inputs.
If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.
After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() trigger_counter_timed = {
	INHIBIT_COOP
	if (RemovedOutsideCoop()) return;

	self.wait = -1;
	if (!self.count)
		self.count = 2;

	if (!self.delay)
		self.delay = 2;
	
	self.cnt = self.count;

	self.use = counter_timed_use;
	self.think = counter_timed_think;
};
