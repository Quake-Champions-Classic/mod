/*
=============================
MG1: TRIGGER CLEANUP CORPSES
=============================
*/

void trigger_cleanup_corpses_use() {
    entity e = nextent(world);
    while (e) {
        if (e.flags & FL_MONSTER) {
            if (e.health <= 0)
                remove(e);
        }
        e = nextent(e);
    }
    remove(self);
};

void trigger_cleanup_corpses() {
    if (coop == 0) { remove(self); return; }
    self.use = trigger_cleanup_corpses_use;
}