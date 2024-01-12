/*
============================
QCC: BOUNCEPAD
============================
*/

void() QCC_BouncePadTouch = {
    if (other.flags & (FL_FLY | FL_SWIM))
		return;
    
    if (other.classname != "player" && !(other.flags & FL_MONSTER))
        return;
    
    if (!(other.flags & FL_ONGROUND))
        return;
    
    other.flags -= other.flags & FL_ONGROUND;
    sound(self, CHAN_AUTO, "bounce.wav", 1, ATTN_IDLE);
    makevectors(self.angles);
    other.velocity = self.speed * v_forward + self.height * v_up;

    if (self.target)
        SUB_UseTargets();
};

void() QCC_BouncePadAnim =[ 0, QCC_BouncePadAnim ] {
    self.walkframe += 1;
    if (self.walkframe > 13)
        self.walkframe = 0;
    self.frame = self.walkframe + self.style;
    makevectors(self.angles);
    particle(self.origin + (v_right * crandom() + v_forward * crandom()) * 10, v_up * 8, 216, 8);
    self.nextthink = time + 0.07;
};

// qcc_bouncepad
// use "angle", "height" and "speed" to set the bounce direction and velocity
void() qcc_bouncepad = {
    precache_model("progs/qcbounce.mdl");
    precache_sound("bounce.wav");
    precache_sound("bouncamb.wav");

    setmodel(self, "progs/qcbounce.mdl");
    self.solid = SOLID_TRIGGER;
    setsize(self, '-16 -16 0', '16 16 8');
    
    ambientsound(self.origin, "bouncamb.wav", 0.5, ATTN_STATIC);

    self.style *= 14;

    if (!self.height)
        self.height = 500;

    self.touch = QCC_BouncePadTouch;
    QCC_BouncePadAnim();
};