/*
====================================================
SCOURGE OF ARMAGON TRAP TESLA COIL && GOD'S WRATH
====================================================
*/

entity tesla_target;
float tesla_numtargets;

void() trap_tesla_scan = {
   entity head;
   entity prev;

    // look in our immediate vicinity
    tesla_numtargets = 0;
    head = findradius(self.origin, self.distance);
    while (head) {
        if (!(head.flags & FL_NOTARGET) && (head.flags & self.cnt)) {
            if (visible(head) && (head.health > 0) && (head.struck_by_mjolnir==0)) {
                if (tesla_numtargets == 0)
                    tesla_target = head;
                else
                    prev.next_ent = head;
                tesla_numtargets = tesla_numtargets + 1;
                prev = head;
                if (tesla_numtargets==self.count)
                    return;
            }
        }
        head = head.chain;
    }
};

void() TeslaLightningThink = {
    self.owner.attack_state = 2;
    if (time > self.delay) {
        self.enemy.struck_by_mjolnir = 0;
        remove(self);
        return;
    }
    
    traceline(self.origin, self.enemy.origin, TRUE, self);
    if (trace_fraction != 1.0 || self.enemy.health <= 0 || vlen(self.origin - self.enemy.origin) > (self.distance + 10)) {
        self.enemy.struck_by_mjolnir = 0;
        remove(self);
        return;
    }
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
    WriteEntity(MSG_BROADCAST, self);
    WriteCoord(MSG_BROADCAST, self.origin_x);
    WriteCoord(MSG_BROADCAST, self.origin_y);
    WriteCoord(MSG_BROADCAST, self.origin_z);
    WriteCoord(MSG_BROADCAST, trace_endpos_x);
    WriteCoord(MSG_BROADCAST, trace_endpos_y);
    WriteCoord(MSG_BROADCAST, trace_endpos_z);
    LightningDamage(self.origin, trace_endpos, self.lastvictim, self.dmg);
    self.nextthink = time + 0.1;
};

void(entity targ) SpawnTeslaLightning = {
    entity lgt;
    // spawn actual lightning
    lgt = spawn();
    if (self.duration > 0)
        lgt.delay = time + self.duration;
    else
        lgt.delay = time + 9999;
    lgt.enemy = targ;
    targ.struck_by_mjolnir = 1;
    lgt.distance = self.distance;
    lgt.owner = self;
    lgt.lastvictim = self.lastvictim;
    lgt.dmg = self.dmg;
    lgt.origin = self.origin;
    lgt.think = TeslaLightningThink;
    lgt.nextthink = time;
    lgt.deathtype = self.deathtype;
};

void() trap_tesla_think = {
    if (self.state == 0) {
        self.nextthink = time + 0.25;
        return;
    }
    if (self.attack_state == 0) {
        self.think = trap_tesla_think;
        trap_tesla_scan();
        if (tesla_numtargets > 0) {
            if (self.wait > 0)
                sound(self, CHAN_AUTO, "misc/tesla.wav", 1, ATTN_NORM);
            self.attack_state = 1;
            self.nextthink = time + self.wait;
            return;
        }
        self.nextthink = time + 0.25;
        if (self.delay > 0) {
            if (time > self.search_time)
                self.attack_state = 3;
        }
    }
    else if (self.attack_state == 1) {
        trap_tesla_scan();
        while (tesla_numtargets > 0) {
            sound(self, CHAN_AUTO, "hipweap/mjolhit.wav", 1, ATTN_NORM);
            SpawnTeslaLightning (tesla_target);
            tesla_target = tesla_target.next_ent;
            tesla_numtargets = tesla_numtargets - 1;
        }
        self.attack_state = 2;
        self.nextthink = time + 1;
    }
    else if (self.attack_state == 2) {
        self.attack_state = 3;
        self.nextthink = time + 0.2;
    }
    else if (self.attack_state == 3) {
        self.attack_state = 0;
        self.nextthink = time + 0.1;
        if (self.classname == "trap_gods_wrath")
            self.nextthink = -1;
    }
};

/*QUAKED trap_tesla_coil (0 .5 .8) (-8 -8 -8) (8 8 8) targetenemies
targets enemies in vicinity and fires at them
"wait" how long build up should be (2 second default)
"dmg" how much damage lightning should inflict (2 + 5*skill default)
"duration" how long each lightning attack should last (continuous default)
"distance" how far the tesla coil should reach (600 default)
"state" on/off for the coil (0 default is off)
"count" number of people to target (2 default)
*/
void() trap_tesla_coil = {
    precache_sound("misc/tesla.wav");
    precache_sound("hipweap/mjolhit.wav");   // lightning sound
    if (self.wait == 0)
        self.wait = 2;
    if (self.dmg == 0)
        self.dmg = 2 + (5*cvar("skill"));
    if (self.duration == 0)
        self.duration = -1;
    if (self.distance == 0)
        self.distance = 600;
    if (self.spawnflags & 1)
        self.cnt = FL_CLIENT | FL_MONSTER;
    else
        self.cnt = FL_CLIENT;
    self.use = trap_lightning_switched_use;
    if (self.delay == 0)
        self.delay = -1;
    self.nextthink = time + random();
    self.think = trap_tesla_think;
    self.lastvictim = world;
    tesla_numtargets = 0;
    self.attack_state = 0;
    if (ExtSupported("EX_SPRINT"))
        self.deathtype = "$qc_suicide_electrocuted";
    else
        self.deathtype = " is electrocuted\n";
};

void() trap_gods_wrath_use = {
    if (self.attack_state==0) {
        self.search_time = time + self.delay;
        self.lastvictim = activator;
        trap_tesla_think();
    }
};

/*QUAKED trap_gods_wrath (0 .5 .8) (-8 -8 -8) (8 8 8) targetenemies
targets enemies in vicinity and fires at them
"dmg" how much damage lightning should inflict (5 default)
"duration" how long each lightning attack should last (continuous default)
"distance" how far god's wrath should reach (600 default)
"delay" how long to wait until god calms down
   this is only needed if no one is targetted (5 seconds default)
"count" number of people to target (2 default)
*/
void() trap_gods_wrath = {
    if (self.delay == 0)
        self.delay = 5;
    trap_tesla_coil();
    self.wait = 0;
    self.state = 1;
    self.nextthink = -1;
    if (ExtSupported("EX_SPRINT"))
        self.deathtype = "$qc_suicide_wrath";
    else
        self.deathtype = " suffers the wrath of God\n";
    self.use = trap_gods_wrath_use;
};