/*
Observer class that cannot interact or interfere with the game.
Will reset frags and team to zero when swapped to.
Accessible by impulse command.
*/

void() QCC_Observer = {
    if (self.health <= 0)
        return;
    
    if (self.qccChampion == QCC_OBSERVER) {
        PutClientInServer();
        return;
    }

    self.qccChampion = QCC_OBSERVER;
    self.qccAbilityFunc = SUB_Null;
    self.solid = SOLID_NOT;
    self.movetype = MOVETYPE_FLY;
    setmodel(self, "progs/qcinvis.mdl");
    self.skin = 0;
    setsize(self, '0 0 0', '0 0 0');
    self.view_ofs = '0 0 1'; // can't use '0 0 0' since that's used for intermissions
    setorigin(self, self.origin + '0 0 32');

    // Remove frags and team so that observers can't cheat hopefully
    self.team = TEAM_NONE;
    if (self.frags > 0) // don't remove suicide penalties, that's cheating, too
        self.frags = 0;

    // Adjust health and armor
    self.health = 666;
    self.armorvalue = 0;
    self.takedamage = DAMAGE_NO;
    self.deadflag = DEAD_NO;
    self.air_finished = time + 12;

    // Remove powerups
    self.super_damage_finished = 0;
    self.invincible_finished = 0;
    self.invisible_finished = 0;
    self.radsuit_finished = 0;
    self.wetsuit_finished = 0;
    self.empathy_finished = 0;
    self.shield_finished = 0;
    self.antigrav_finished = 0;
    CheckPowerups();
    self.effects = 0;

    // Remove weapon and items
	self.items = 0;
    self.currentammo = 0;
    self.weapon = 0;
    self.weaponmodel = string_null;

    // Flag settings
    self.flags = (FL_FLY | FL_NOTARGET);

    // Monsters should stop targeting
    self.show_hostile = 0;
    self.enemy = world;
    entity fool = nextent(world);
    while (fool != world) {
        if (fool.enemy == self)
            fool.enemy = world;
        fool = nextent(fool);
    }
};

// Stolen from CTF progs, might help with Nyx ghostwalk?
void(entity door) ObserverDoor = {
    entity d,d_master;
    vector dmin,dmax;
    float is_x,is_y,is_z,set;
    vector dir,or;
  
    d_master = d = door.owner;
    if (d_master) {
        dmin = d_master.absmin;
        dmax = d_master.absmax;
    }
    else
        dmin = dmax = '0 0 0';

    if (dmin != dmax) {
        // regular doors
        if (d_master.state != STATE_BOTTOM)
            return;
        
        do {
            if (d.absmin_x < dmin_x)
                dmin_x = d.absmin_x;
            if (d.absmax_x > dmax_x)
                dmax_x = d.absmax_x;
            if (d.absmin_y < dmin_y)
                dmin_y = d.absmin_y;
            if (d.absmax_y > dmax_y)
                dmax_y = d.absmax_y;
            if (d.absmin_z < dmin_z)
                dmin_z = d.absmin_z;
            if (d.absmax_z > dmax_z)
                dmax_z = d.absmax_z;
            d = d.enemy; // next linked door;
        } while ((d != d_master) && (d != world));
    }
    else // ignore secret doors
        return;

    set = is_x = is_y = is_z = FALSE;
    or = self.origin;
    if (dmin_x + 15 < self.absmin_x && self.absmax_x < dmax_x - 15)
        is_x = TRUE;
    if (dmin_y + 15 < self.absmin_y && self.absmax_y < dmax_y - 15)
        is_y = TRUE;
    if (dmin_z + 15 < self.absmin_z && self.absmax_z < dmax_z - 15)
        is_z = TRUE;

    if (is_x && is_y) {
        if (or_z < dmin_z) {
            dir = '0 0  1';
            or_z = dmax_z + 25;
        }
        else if (or_z > dmax_z) {
            dir = '0 0 -1';
            or_z = dmin_z - 25;
        }
        set = TRUE;
    }
    else if (is_x && is_z) {
        if (or_y < dmin_y) {
            dir = '0  1 0';
            or_y = dmax_y + 25;
        }
        else if (or_y > dmax_y) {
            dir = '0 -1 0';
            or_y = dmin_y - 25;
        }
        set = TRUE;
    }
    else if (is_y && is_z) {
        if (or_x < dmin_x) {
            dir = ' 1 0 0';
            or_x = dmax_x + 25;
        }
        else if (or_x > dmax_x) {
            dir = '-1 0 0';
            or_x = dmin_x - 25;
        }
        set = TRUE;
    }

    if (set) { 
        vector v;
        v = normalize(self.velocity);
        if (dir * v < 0.5)
            return;
        
        self.origin = or;
        setorigin(self, self.origin);
    }
};

// Stolen from CTF progs
void(entity tele) ObserverTeleporter = {
    entity targ;
    vector v1,v2;

    v1 = ((tele.absmax + tele.absmin) * 0.5) - self.origin; normalize(v1);
    v2 = self.velocity; normalize(v2);
    if (v1 * v2 <= 0.1)
        return;
  
    targ = find(world, targetname, tele.target);
    if (!targ)
        return;

    makevectors(targ.mangle);
    setorigin(self, targ.origin);
    self.angles = targ.mangle;
    self.fixangle = TRUE; // turn this way immediately
    self.teleport_time = time + 0.7;
    self.velocity = v_forward * 300;
};

void() QCC_ObserverPreThink = {
    if (deathmatch || coop)
		CheckRules();
    
    self.flags |= FL_ONGROUND;

    // Fly around
    makevectors(self.v_angle);
    float dot = normalize(self.velocity) * v_forward;
    vector vel;
    float spd;
    spd = vlen(self.velocity);
    vel = v_forward * spd;
    self.velocity_z = vel_z * dot;

    // look for doors, etc.
    entity e = findradius(self.origin,75);
    while (e != world) {
        if (e.classname == "func_door") {
            ObserverDoor(e);
            e = world;
        }

        if (e.classname == "trigger_teleport") {
            ObserverTeleporter(e);
            e = world;
        }

        e = e.chain;
        if (!e)
            e = world;
    }
    
    // Teleporters can force a non-moving pause time	
	if (time < self.pausetime)
        self.velocity = '0 0 0';
};

void() QCC_ObserverPostThink = {
    //earthquake_postthink();

    if (time > self.attack_finished) {
        if (self.impulse)
            ImpulseCommands();
        
        entity spot;

        // Swap viewpoints via start position
        if (self.button0) {
            self.attack_finished = time + 0.5;

            if (self.enemy.classname != "player")
                spot = nextent(self.enemy);
            else
                spot = nextent(world);
            
            while (spot != world) {
                if (spot.classname == "info_intermission" || spot.classname == "info_player_deathmatch" || spot.classname == "info_player_start") {
                    self.enemy = spot;
                    break;
                }
                spot = nextent(spot);
            }
            
            if (spot == world) {
                self.enemy = world;
                return;
            }

            if (spot.classname == "info_intermission") {
                setorigin(self, spot.origin);
                self.angles = self.v_angle = spot.mangle;
            }
            else {
                setorigin(self, spot.origin + '0 0 48');
                self.angles = spot.angles;
            }
            self.fixangle = TRUE;
        }
        // Cycle through players
        else if (self.button2) {
            self.attack_finished = time + 0.5;
            
            if (self.enemy.classname == "player")
                spot = nextent(self.enemy);
            else
                spot = nextent(world);
            
            while (spot != world) {
                if (spot.classname == "player") {
                    self.enemy = spot;
                    break;
                }
                spot = nextent(spot);
            }
            
            if (spot == world) {
                self.enemy = world;
                return;
            }

            setorigin(self, spot.origin + '0 0 10');
            self.angles = spot.angles;
            self.fixangle = TRUE;
        }
    }
};