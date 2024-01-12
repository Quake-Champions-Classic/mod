/*
=============================
MG1: TRIGGER CHANGETARGET
=============================
*/

void trigger_changetarget_use() {
	SUB_SwitchTargets(target, self.target, self.killtarget);
}

void trigger_changetarget() {
	if (!self.target)
        objerror("Missing target.");
	if (!self.killtarget)
        objerror("Missing target to change to.");
	self.use = trigger_changetarget_use;
}