/*
==============================================================================
TRIGGER SETSKILL
==============================================================================
*/

void() trigger_skill_touch = {
	if (other.classname != "player")
		return;		
	cvar_set ("skill", self.message);
};

/*QUAKED trigger_setskill (.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
void() trigger_setskill = {
	InitTrigger();
	self.touch = trigger_skill_touch;
};