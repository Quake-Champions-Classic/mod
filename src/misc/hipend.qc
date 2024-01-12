/*
===============================================

SCOURGE OF ARMAGON FINALE

===============================================
*/

float SVC_UPDATEENTITY = 128; // Net.Protocol 0x80
void(entity me, entity camera) UpdateCamera =
{
  msg_entity = me;                         // target of message
  WriteByte(MSG_ONE, SVC_UPDATEENTITY|15); // 0x80|1|2|4|8
  WriteByte(MSG_ONE, 64); // 0x40
  WriteEntity(MSG_ONE,camera);
  WriteCoord(MSG_ONE,camera.origin_x);
  WriteCoord(MSG_ONE,camera.origin_y);
  WriteCoord(MSG_ONE,camera.origin_z);
};

void() effect_finale_use = {
    entity pos, pl, targ;

    if (self.state == 1)
        return;
    self.state = 1;

    // find the intermission spot
    pos = find(world, targetname, self.target);
    if (!pos)
        error ("no target in finale");

    WriteByte(MSG_ALL, SVC_CUTSCENE);
    WriteString (MSG_ALL, "");

    //setup decoy
    pl = find(world, classname, "player");
    if (!(self.spawnflags & 2)) {
        targ = find(world, targetname, self.mdl);
        if (self.spawnflags & 1)
            become_decoy(targ.target, pl.origin, pl);
        else
            become_decoy(targ.target, targ.origin, pl);
    }

	while (pl != world) {
        pl.view_ofs = '0 0 0';
        pl.angles = other.v_angle = pos.mangle;
        pl.mangle = pos.mangle;
        pl.fixangle = TRUE;     // turn this way immediately
        pl.trigger_field = self;
        pl.nextthink = time + 0.5;
        pl.takedamage = DAMAGE_NO;
        pl.solid = SOLID_NOT;
        pl.movetype = MOVETYPE_NONE;
        pl.modelindex = 0;
        setorigin(pl, pos.origin);
        pl.origin = pos.origin;
        pl.oldorigin = pos.origin;
        UpdateCamera(pl,pl);
        UpdateCamera(pl,pl.trigger_field);
        pl = find(pl, classname, "player");
    }

    // wait for next sequence
    if (self.spawnfunction) {
        self.nextthink = time + self.wait;
        self.think = self.spawnfunction;
    }
};

/*QUAKED effect_finale (0.3 0.1 0.6) (-8 -8 -8) (8 8 8) useplayer nodecoy
 start the finale sequence
 "target" the camera to go to.
 "mdl" if useplayer is specified, this is a
 path corner with target of the next
 path_corner to run to.
 if use player isn't specified this becomes
 the spawn point as well.
 "spawnfunction" next routine to run
 "delay" time to wait until running routine
 useplayer - use the current player as
             decoy location.
 nodecoy - no decoy, only the camera
*/
void() effect_finale = {
    if (deathmatch) {
		remove(self);
		return;
    }
    setorigin(self,self.origin);
    self.angles = self.mangle;
    self.use = effect_finale_use;
    self.state = 0;
};