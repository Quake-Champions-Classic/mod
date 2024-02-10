/*
================
HEAVY MACHINE GUN
================
*/


/*
================
PICKUP
================
*/
void() qcc_weapon_heavymachinegun = {
    weapon_nailgun();
    self.classname = "weapon_nailgun";
    /*
    self.classname = "qcc_weapon_heavymachinegun";
	setmodel(self, "progs/g_hmg.mdl");
	self.weapon = QCC_IT_HEAVYMACHINEGUN;
	self.netname = "Heavy Machine Gun";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
    */
};

void() qcc_item_bullets = {
	item_spikes();
};