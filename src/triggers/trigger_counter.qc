/*
========================================
TRIGGER COUNTER
========================================
*/

void() counter_use = {
	self.count = self.count - 1;

	if (self.count < 0)
		return;
	
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
	
	if (activator.classname == "player" && (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0) {
		if (ExtSupported("EX_CENTERPRINT"))
			centerprint_all("$qc_sequence_completed");
		else
			centerprint_all("Sequence completed!");
	}

	self.enemy = activator;

	// MG1: yoder Sept24, 2021, Horde Merge
	if (self.spawnflags & COUNTER_LOOPS)
		self.count = self.wait;
	
	multi_trigger ();
};

/*QUAKED trigger_counter (.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.
If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.
After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() trigger_counter = {
	INHIBIT_COOP
	if (RemovedOutsideCoop()) return;

	if (!self.count)
		self.count = 2;

	// MG1: Yoder Sept24, 2021 Horde Merge
	// .count is decremented each use and fires its targets on 0
	// .wait stores the original .count and restores to this if COUNTER_LOOPS	
	if (!self.wait)
		self.wait = self.count;

	self.use = counter_use;
};