// MG1

/*QUAKED trigger_multitouch (.5 .5 .5) ?
A trigger that fires its targets on "first touch", "emptied" or both

YODER Feb08, 2022
*/
float IGNORE_FIRST_TOUCH = 16;
float IGNORE_EMPTIED = 32;

void() trigger_multitouch_think = {
    bprint("untouched\n"); 
    self.wait = 0;
    if (!(self.spawnflags & IGNORE_EMPTIED))
        SUB_UseTargets();
};

void() trigger_multitouch_touch = {
    if (other.classname != "player")
        return;
	if (other.health <= 0)
		return;
    
    if (self.wait == 0) { // first touch?
        self.wait = 1;
        bprint(" first touch\n");
        if (!(self.spawnflags & IGNORE_FIRST_TOUCH))
            SUB_UseTargets();
    }
    
    // think
    self.think = trigger_multitouch_think;
    self.nextthink = time + 0.2;
};

void() trigger_multitouch = {
    InitTrigger();
    self.touch = trigger_multitouch_touch;
    self.wait = 0; // 0 is empty, 1 is touched
};