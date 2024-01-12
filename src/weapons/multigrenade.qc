// multi_weapons.qc
// pmack
// sept 96

//=============================================================================
// Multi Grenade Code
//=============================================================================
void() MultiGrenadeTouch;

void() MiniGrenadeExplode = {
	T_RadiusDamage(self, self.owner, 60, world);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION2);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
    WriteByte(MSG_BROADCAST, 230);
    WriteByte(MSG_BROADCAST, 5);

	BecomeExplosion ();
};

void(float offsetAngle) MiniGrenadeLaunch = {
	entity  missile;
	float   tempRand;
	
	missile = spawn();
	missile.owner = self.owner;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	if (self.classname == "keelgrenade")
		missile.classname = "keelminigrenade";
	else
		missile.classname = "MiniGrenade";
		
    // set missile speed	
	missile.v_angle = self.v_angle;
	missile.v_angle_y = missile.v_angle_y + offsetAngle;
	makevectors(missile.v_angle);
		
	missile.velocity = v_forward * 100 + v_up * 400;
	tempRand = (crandom() * 60) - 30;
	missile.velocity = missile.velocity + tempRand * v_forward;
	tempRand = (crandom() * 40) - 20;
	missile.velocity = missile.velocity + tempRand * v_right;
	tempRand = (crandom() * 60) - 30;
	missile.velocity = missile.velocity + tempRand * v_up;

	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = MultiGrenadeTouch;
	
	setmodel(missile, "progs/mervup.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, self.origin);

    // set missile duration
	missile.nextthink = time + 1 + (crandom() * 0.5);
	missile.think = MiniGrenadeExplode;
};

void() MultiGrenadeExplode = {
	MiniGrenadeLaunch(0);
	MiniGrenadeLaunch(72);
	MiniGrenadeLaunch(144);
	MiniGrenadeLaunch(216);
	MiniGrenadeLaunch(288);
	remove(self);
};

void() MultiGrenadeTouch = {
	if (other == self.owner)
		return;		// don't explode on owner
	// Don't touch Ghost Walker
	if (other.qccChampion == QCC_NYX && other.weapon == QCC_ABILITY)
		return;
	
	if (other.takedamage == DAMAGE_AIM) {
		if (self.classname == "MiniGrenade" || self.classname == "keelminigrenade")
			MiniGrenadeExplode();
		else
            MultiGrenadeExplode();
		return;
	}
	// bounce sound
	sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

void() W_FireMultiGrenade = {
	entity missile;
	
	sound(self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "MultiGrenade";
		
    // set missile speed	
	makevectors(self.v_angle);
	if (self.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else {
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = MultiGrenadeTouch;
	
    // set missile duration
	missile.nextthink = time + 2.5;
	missile.think = MultiGrenadeExplode;

	setmodel(missile, "progs/mervup.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, self.origin);
};