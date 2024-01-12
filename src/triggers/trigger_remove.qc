/*
==============================
SOA: TRIGGER REMOVE
==============================
*/
void() remove_touch = {
    if (other.flags & self.cnt)
        return;
    other.touch = SUB_Null;
    other.model = "";
    remove(self);
};

// QUAKED trigger_remove (.5 .5 .5) ? ignoremonsters ignoreplayers
// Variable sized trigger that removes the thing that touches it.  Does not affect monsters or players.
void() trigger_remove = {
    self.cnt = FL_CLIENT|FL_MONSTER;
    if (self.spawnflags & 1)
        self.cnt = self.cnt - FL_MONSTER;
    if (self.spawnflags & 2)
        self.cnt = self.cnt - FL_CLIENT;
    InitTrigger();
    self.touch = remove_touch;
};