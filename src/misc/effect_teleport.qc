/*
====================================
EFFECT TELEPORT
====================================
*/

void() effect_teleport_use = {
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
     WriteByte(MSG_BROADCAST, TE_TELEPORT);
    WriteCoord(MSG_BROADCAST, self.origin_x);
    WriteCoord(MSG_BROADCAST, self.origin_y);
    WriteCoord(MSG_BROADCAST, self.origin_z);
    sound(self, CHAN_VOICE, "misc/r_tele1.wav", 1, ATTN_NORM);
};
 
// QUAKED effect_teleport (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
// Create a teleport effect when triggered
void() effect_teleport = {
    precache_sound("misc/r_tele1.wav");
    self.use = effect_teleport_use;
};