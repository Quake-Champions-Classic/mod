/*
=================================
SOA: TRIGGER WATERFALL
=================================
*/

void() trigger_waterfall_touch = {
    // only affect players
    if (!(other.flags & FL_CLIENT))
        return;

    other.velocity = other.velocity + self.movedir;
    other.velocity_x = other.velocity_x + self.count * (random() - 0.5);
    other.velocity_y = other.velocity_y + self.count * (random() - 0.5);
};

/*QUAKED trigger_waterfall (.2 .5 .2) ?
 Pushes the player in the direction specified by angles.
 "speed" is the strength of the push (default 50).
 "count" amount of random xy movement to add to velocity (default 100).
*/
void() trigger_waterfall = {
    InitTrigger();
    self.touch = trigger_waterfall_touch;

    if (self.count == 0)
        self.count = 100;

    if (self.speed == 0)
        self.movedir = self.movedir * 50;
    else
      self.movedir = self.movedir * self.speed;
};