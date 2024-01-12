/*
INFO_INTERMISSION

This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
Can optionally use an entity as a target direction.
*/

void() info_intermission_aim_at_target = {
    if (self.target != string_null) {
        entity t;
        t = find(world, targetname, self.target);
        if (t != world) {
            self.mangle = vectoangles(t.origin - self.origin);
            self.mangle_x *= -1;
        }
    }
}

void() info_intermission = {
    self.think = info_intermission_aim_at_target;
    self.nextthink = time + 0.1 + random();
    self.use = info_intermission_aim_at_target; // could be useful if our camera focal point changes before exiting the map
};