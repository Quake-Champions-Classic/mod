/*  Copyright (C) 1996-2022 id Software LLC

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/


//============================================================================

typedef struct 
{
    string mdl;
    float frame;
}poseInfo;

#pragma warning disable F317 //Use of stale framemacros
poseInfo poses[] =
{
    { "progs/demon.mdl", 53 },
    { "progs/dog.mdl", 16 },
    { "progs/dog.mdl", 25 },
    { "progs/enforcer.mdl", 54 },
    { "progs/enforcer.mdl", 65 },
    { "progs/fish.mdl", 38 },
    { "progs/hknight.mdl", 53 },
    { "progs/hknight.mdl", 62 },
    { "progs/knight.mdl", 85 },
    { "progs/knight.mdl", 96 },
    { "progs/ogre.mdl", 125 },
    { "progs/ogre.mdl", 135 },
    { "progs/shalrath.mdl", 22 },
    { "progs/shambler.mdl", 93 },
    { "progs/soldier.mdl", 17 },
    { "progs/soldier.mdl", 28 },
    { "progs/wizard.mdl", 53 },
    { "progs/player.mdl", 49 },
    { "progs/player.mdl", 60 },
    { "progs/player.mdl", 69 },
    { "progs/player.mdl", 84 },
    { "progs/player.mdl", 93 },
    { "progs/player.mdl", 102 },
    // Heads
    { "progs/h_demon.mdl", 0 },
    { "progs/h_dog.mdl", 0 },
    { "progs/h_guard.mdl", 0 },
    { "progs/h_hellkn.mdl", 0 },
    { "progs/h_knight.mdl", 0 },
    { "progs/h_mega.mdl", 0 },
    { "progs/h_ogre.mdl", 0 },
    { "progs/h_player.mdl", 0 },
    { "progs/h_shal.mdl", 0 },
    { "progs/h_shams.mdl", 0 },
    { "progs/h_wizard.mdl", 0 },
    { "progs/h_zombie.mdl", 0 },
    // Gibs
    { "progs/gib1.mdl", 0 },
    { "progs/gib2.mdl", 0 },
    { "progs/gib3.mdl", 0 },

    // QUAKE CHAMPIONS CLASSIC
    { "progs/qcdoom.mdl", 49 },
    { "progs/qcdoom.mdl", 60 },
    { "progs/qcdoom.mdl", 69 },
    { "progs/qcdoom.mdl", 84 },
    { "progs/qcdoom.mdl", 93 },
    { "progs/qcdoom.mdl", 102 },
    { "progs/h_qcdoom.mdl", 0 },
    
};
#pragma warning enable F317

void misc_corpse()
{
    if (self.style < 0 || self.style >= poses.length)
    {
        objerror("misc_corpse with invalid style.");
        return;
    }
    poseInfo pose = poses[self.style];
    precache_model(pose.mdl);
    self.frame = pose.frame;
    self.solid = SOLID_NOT;
    self.movetype = MOVETYPE_NONE;
    setmodel(self, pose.mdl);
}

void printCorpseFGDStuff()
{
    dprint("Corpseframes:\n");
    for(float i = 0; i < poses.length; i++)
    {
        //style ==  0 -> { path: "progs/demon.mdl"      , frame: 53  },
        dprint("style ==  ");
        dprint(ftos(i));
        dprint(" -> { path: \"");
        dprint(poses[i].mdl);
        dprint("\"\t, frame: ");
        dprint(ftos(poses[i].frame));
        dprint("\t},\n");
    }
}

//============================================================================
