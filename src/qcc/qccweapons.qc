/*
================
Heavy Machine Gun
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

/*
================
Tribolt
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

/*
================
Railgun
================
*/
void() qcc_weapon_railgun = {
    self.classname = "qcc_weapon_railgun";
	setmodel(self, "progs/g_rail.mdl");
	self.weapon = QCC_IT_RAILGUN;
	self.netname = "Railgun";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void(vector o) QCC_SpawnRailgun = {
    entity rg;
    rg = spawn();
    rg.classname = "qcc_weapon_railgun";
	setmodel(rg, "progs/g_rail.mdl");
	rg.weapon = QCC_IT_RAILGUN;
	rg.netname = "Railgun";
	rg.touch = weapon_touch;
	setsize(rg, '-16 -16 0', '16 16 56');
    setorigin(rg, o);
    // StartItem();
	rg.nextthink = time + 0.2;
	rg.think = PlaceItem;
}

// Called by weapon_rocketlauncher
float() QCC_Rocket_to_Rail = {
    float spawn_rail, ct;
    string m;
    entity rl;

    spawn_rail = FALSE;
    m = world.model;

    rl = find(world, classname, "qcc_weapon_railgun");
    if (rl == world) {
        if (!deathmatch) {
            if (m == "maps/e1m8.bsp" || m == "maps/e2m4.bsp" || m == "maps/e3m4.bsp")
                spawn_rail = TRUE;
        }
        else {
            if (m == "maps/dm2.bsp" && self.origin == '2480 -1712 0')
                spawn_rail = TRUE;
            else if (m == "maps/dm4.bsp" && self.origin == '768 -880 -256')
                spawn_rail = TRUE;
            else if (m == "maps/dm6.bsp" && self.origin == '1512 -432 36')
                spawn_rail = TRUE;
            else if (m != "maps/dm1.bsp" && m != "maps/dm2.bsp" && m != "maps/dm3.bsp" && m != "maps/dm4.bsp" && m != "maps/dm5.bsp" && m != "maps/dm6.bsp" && m != "maps/dm7.bsp") {
                rl = find(world, classname, "weapon_rocketlauncher");
                while (rl != world) {
                    ct++;
                    rl = find(rl, classname, "weapon_rocketlauncher");
                }
                if (ct > 1)
                    spawn_rail = TRUE;
            }
        }
    }

    if (spawn_rail == TRUE)
        qcc_weapon_railgun();
    
    return spawn_rail;
}

void() QCC_W_FireRail = {
    vector org;
    entity t;
    float dist, x;

    if (self.ammo_cells < 15) {
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

    self.currentammo = self.ammo_cells = self.ammo_cells - 15;
    sound(self, CHAN_WEAPON, "weapons/railshot.wav", 1, ATTN_NORM);
    self.punchangle_x = -2;

    org = self.origin;// + self.view_ofs - '0 0 6';
    // beam trace
    traceline(org, org + v_forward * 4096, 1, self);
    dist = vlen(trace_endpos - org);
    x = ceil(dist / 64);
    while (x >= 0) {
        t = spawn();
        t.owner = self;
        t.movetype = MOVETYPE_NONE;
        t.solid = SOLID_NOT;
        t.classname = "railbeam";
        t.angles = vectoangles(aim(self, dist));
        t.nextthink = time + 0.2;
        t.think = SUB_Remove;
        setmodel(t, "progs/s_rail.mdl");
        setsize(t, '0 0 0', '0 0 0');
        setorigin(t, org + v_forward * 64 * x);
        particle(t.origin, '0 0 0', 249, 6);
        x = x - 1;
    }
    particle(trace_endpos, '0 0 0', 249, 30);
    
    // Trace damage
    traceline(org, org + v_forward * 4096, 0, self);
    while (trace_ent.takedamage) {
        SpawnBlood(trace_endpos, v_forward * 90, 90);
        T_Damage(trace_ent, self, self, 90);
        traceline(trace_endpos, org + v_forward * 4096, 0, trace_ent);
    }
}


/*
================
QCC_StartFrame

Used to spawn in QCC specific weapons, like the railgun, into maps without editing them
================
*/
void() QCC_SpawnWeapons = {
    string m;
    m = world.model;
    if (m == "maps/dm3.bsp")
        QCC_SpawnRailgun('-600 240 -40');
    else if (m == "maps/dm5.bsp")
       QCC_SpawnRailgun('-96 -768 192');
    else if (m == "maps/dm7.bsp")
        QCC_SpawnRailgun('640 -672 320');
    return;
}

