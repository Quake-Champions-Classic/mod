/*
======================================
QCC: PROP DYNAMIC
Morphing prop entity. Can playback looping animation.
======================================
*/

void() QCC_PropAnim = {
    self.frame += 1;
    if (self.frame == self.cnt)
        self.frame = self.count; // Back to start
    self.nextthink = time + 0.1;
};

void() QCC_PropUse = {
    if (self.state) {
        self.state = FALSE;
        self.nextthink = 0;
    }
    else {
        self.state = TRUE;
        QCC_PropAnim();
    }
};

void() qcc_prop_dynamic = {
    if (self.model == "") {
        remove(self);
        return;
    }

    precache_model(self.model);
    setmodel(self, self.model);
    setorigin(self, self.origin);
    self.solid = SOLID_NOT;
    self.movetype = MOVETYPE_NONE;

    self.frame = self.count;
    if (self.cnt > 0) {
        if (self.speed <= 0)
            self.speed = 0.1;
        if (self.targetname != "") {
            self.use = QCC_PropUse;
            if (self.spawnflags & 1)
                return;
        }
        self.state = TRUE;
        self.think = QCC_PropAnim;
        self.nextthink = time + self.speed;
        return;
    }
    self.targetname = "";
    makestatic(self);
};