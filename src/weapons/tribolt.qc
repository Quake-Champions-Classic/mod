/*
================
TRIBOLT
================
*/


/*
================
PICKUP
================
*/
void() qcc_weapon_tribolt = {
    weapon_grenadelauncher();
    self.classname = "weapon_grenadelauncher";
    /*
    self.classname = "qcc_weapon_tribolt";
	setmodel(self, "progs/g_tbolt.mdl");
	self.weapon = QCC_IT_TRIBOLT;
	self.netname = "Tribolt";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
    */
};

void() qcc_item_bolts = {
	item_rockets();
};