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
void() InitBodyQueue;
void() InitLightStyles;

void() main = {
	dprint ("main function\n");
	
// these are just commands the the prog compiler to copy these files

	precache_file ("progs.dat");
	precache_file ("gfx.wad");
	precache_file ("quake.rc");
	precache_file ("default.cfg");

	precache_file ("end1.bin");
	precache_file2 ("end2.bin");

	precache_file ("demo1.dem");
	precache_file ("demo2.dem");
	precache_file ("demo3.dem");

//
// these are all of the lumps from the cached.ls files
//
	precache_file ("gfx/palette.lmp");
	precache_file ("gfx/colormap.lmp");

	precache_file2 ("gfx/pop.lmp");

	precache_file ("gfx/complete.lmp");
	precache_file ("gfx/inter.lmp");

	precache_file ("gfx/ranking.lmp");
	precache_file ("gfx/vidmodes.lmp");
	precache_file ("gfx/finale.lmp");
	precache_file ("gfx/conback.lmp");
	precache_file ("gfx/qplaque.lmp");

	precache_file ("gfx/menudot1.lmp");
	precache_file ("gfx/menudot2.lmp");
	precache_file ("gfx/menudot3.lmp");
	precache_file ("gfx/menudot4.lmp");
	precache_file ("gfx/menudot5.lmp");
	precache_file ("gfx/menudot6.lmp");

	precache_file ("gfx/menuplyr.lmp");
	precache_file ("gfx/bigbox.lmp");
	precache_file ("gfx/dim_modm.lmp");
	precache_file ("gfx/dim_drct.lmp");
	precache_file ("gfx/dim_ipx.lmp");
	precache_file ("gfx/dim_tcp.lmp");
	precache_file ("gfx/dim_mult.lmp");
	precache_file ("gfx/mainmenu.lmp");
	
	precache_file ("gfx/box_tl.lmp");
	precache_file ("gfx/box_tm.lmp");
	precache_file ("gfx/box_tr.lmp");
	
	precache_file ("gfx/box_ml.lmp");
	precache_file ("gfx/box_mm.lmp");
	precache_file ("gfx/box_mm2.lmp");
	precache_file ("gfx/box_mr.lmp");
	
	precache_file ("gfx/box_bl.lmp");
	precache_file ("gfx/box_bm.lmp");
	precache_file ("gfx/box_br.lmp");
	
	precache_file ("gfx/sp_menu.lmp");
	precache_file ("gfx/ttl_sgl.lmp");
	precache_file ("gfx/ttl_main.lmp");
	precache_file ("gfx/ttl_cstm.lmp");
	
	precache_file ("gfx/mp_menu.lmp");
	
	precache_file ("gfx/netmen1.lmp");
	precache_file ("gfx/netmen2.lmp");
	precache_file ("gfx/netmen3.lmp");
	precache_file ("gfx/netmen4.lmp");
	precache_file ("gfx/netmen5.lmp");
	
	precache_file ("gfx/sell.lmp");
	
	precache_file ("gfx/help0.lmp");
	precache_file ("gfx/help1.lmp");
	precache_file ("gfx/help2.lmp");
	precache_file ("gfx/help3.lmp");
	precache_file ("gfx/help4.lmp");
	precache_file ("gfx/help5.lmp");

	precache_file ("gfx/pause.lmp");
	precache_file ("gfx/loading.lmp");

	precache_file ("gfx/p_option.lmp");
	precache_file ("gfx/p_load.lmp");
	precache_file ("gfx/p_save.lmp");
	precache_file ("gfx/p_multi.lmp");

// sounds loaded by C code
	precache_sound("misc/menu1.wav");
	precache_sound("misc/menu2.wav");
	precache_sound("misc/menu3.wav");

	precache_sound("ambience/water1.wav");
	precache_sound("ambience/wind2.wav");

// shareware
	precache_file ("maps/start.bsp");

	precache_file ("maps/e1m1.bsp");
	precache_file ("maps/e1m2.bsp");
	precache_file ("maps/e1m3.bsp");
	precache_file ("maps/e1m4.bsp");
	precache_file ("maps/e1m5.bsp");
	precache_file ("maps/e1m6.bsp");
	precache_file ("maps/e1m7.bsp");
	precache_file ("maps/e1m8.bsp");

// registered
	precache_file2 ("gfx/pop.lmp");

	precache_file2 ("maps/e2m1.bsp");
	precache_file2 ("maps/e2m2.bsp");
	precache_file2 ("maps/e2m3.bsp");
	precache_file2 ("maps/e2m4.bsp");
	precache_file2 ("maps/e2m5.bsp");
	precache_file2 ("maps/e2m6.bsp");
	precache_file2 ("maps/e2m7.bsp");

	precache_file2 ("maps/e3m1.bsp");
	precache_file2 ("maps/e3m2.bsp");
	precache_file2 ("maps/e3m3.bsp");
	precache_file2 ("maps/e3m4.bsp");
	precache_file2 ("maps/e3m5.bsp");
	precache_file2 ("maps/e3m6.bsp");
	precache_file2 ("maps/e3m7.bsp");

	precache_file2 ("maps/e4m1.bsp");
	precache_file2 ("maps/e4m2.bsp");
	precache_file2 ("maps/e4m3.bsp");
	precache_file2 ("maps/e4m4.bsp");
	precache_file2 ("maps/e4m5.bsp");
	precache_file2 ("maps/e4m6.bsp");
	precache_file2 ("maps/e4m7.bsp");
	precache_file2 ("maps/e4m8.bsp");

	precache_file2 ("maps/end.bsp");

	precache_file2 ("maps/dm1.bsp");
	precache_file2 ("maps/dm2.bsp");
	precache_file2 ("maps/dm3.bsp");
	precache_file2 ("maps/dm4.bsp");
	precache_file2 ("maps/dm5.bsp");
	precache_file2 ("maps/dm6.bsp");
};


entity	lastspawn;

//=======================
/*QUAKED worldspawn (0 0 0) ?
Only used for the world entity.
Set message to the level name.
Set sounds to the cd track to play.

World Types:
0: medieval
1: metal
2: base
*/
//=======================
float startingserverflags;
 
void() worldspawn = {
	startingserverflags = serverflags;
	lastspawn = world;
	InitBodyQueue();

	// custom map attributes
	if (self.model == "maps/e1m8.bsp")
		cvar_set ("sv_gravity", "100");
	else
		cvar_set ("sv_gravity", "800");

	// the area based ambient sounds MUST be the first precache_sounds

	// player precaches	
	W_Precache ();			// get weapon precaches

	// sounds used from C physics code
	precache_sound("demon/dland2.wav");		// landing thud
	precache_sound("misc/h2ohit1.wav");		// landing splash

	// setup precaches allways needed
	precache_sound("items/itembk2.wav");		// item respawn sound
	precache_sound("player/plyrjmp8.wav");		// player jump
	precache_sound("player/land.wav");			// player landing
	precache_sound("player/land2.wav");		// player hurt landing
	precache_sound("player/drown1.wav");		// drowning pain
	precache_sound("player/drown2.wav");		// drowning pain
	precache_sound("player/gasp1.wav");		// gasping for air
	precache_sound("player/gasp2.wav");		// taking breath
	precache_sound("player/h2odeath.wav");		// drowning death

	precache_sound("misc/talk.wav");			// talk
	precache_sound("player/teledth1.wav");		// telefrag
	precache_sound("misc/r_tele1.wav");		// teleport sounds
	precache_sound("misc/r_tele2.wav");
	precache_sound("misc/r_tele3.wav");
	precache_sound("misc/r_tele4.wav");
	precache_sound("misc/r_tele5.wav");
	precache_sound("weapons/lock4.wav");		// ammo pick up
	precache_sound("weapons/pkup.wav");		// weapon up
	precache_sound("items/armor1.wav");		// armor up
	precache_sound("weapons/lhit.wav");		//lightning
	precache_sound("weapons/lstart.wav");		//lightning start
	precache_sound("items/damage3.wav");

	precache_sound("misc/power.wav");			//lightning for boss

// player gib sounds
	precache_sound("player/gib.wav");			// player gib sound
	precache_sound("player/udeath.wav");		// player gib sound
	precache_sound("player/tornoff2.wav");		// gib sound

// player pain sounds

	precache_sound("player/pain1.wav");
	precache_sound("player/pain2.wav");
	precache_sound("player/pain3.wav");
	precache_sound("player/pain4.wav");
	precache_sound("player/pain5.wav");
	precache_sound("player/pain6.wav");

// player death sounds
	precache_sound("player/death1.wav");
	precache_sound("player/death2.wav");
	precache_sound("player/death3.wav");
	precache_sound("player/death4.wav");
	precache_sound("player/death5.wav");

// ax sounds	
	precache_sound("weapons/ax1.wav");			// ax swoosh
	precache_sound("player/axhit1.wav");		// ax hit meat
	precache_sound("player/axhit2.wav");		// ax hit world

	precache_sound("player/h2ojump.wav");		// player jumping into water
	precache_sound("player/slimbrn2.wav");		// player enter slime
	precache_sound("player/inh2o.wav");		// player enter water
	precache_sound("player/inlava.wav");		// player enter lava
	precache_sound("misc/outwater.wav");		// leaving water sound

	precache_sound("player/lburn1.wav");		// lava burn
	precache_sound("player/lburn2.wav");		// lava burn

	precache_sound("misc/water1.wav");			// swimming
	precache_sound("misc/water2.wav");			// swimming

	precache_model("progs/player.mdl");
	precache_model("progs/eyes.mdl");
	precache_model("progs/h_player.mdl");
	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");

	precache_model("progs/s_bubble.spr");	// drowning bubbles
	precache_model("progs/s_explod.spr");	// sprite explosion

	precache_model("progs/v_axe.mdl");
	precache_model("progs/v_shot.mdl");
	precache_model("progs/v_nail.mdl");
	precache_model("progs/v_rock.mdl");
	precache_model("progs/v_shot2.mdl");
	precache_model("progs/v_nail2.mdl");
	precache_model("progs/v_rock2.mdl");

	precache_model("progs/bolt.mdl");		// for lightning gun
	precache_model("progs/bolt2.mdl");		// for lightning gun
	precache_model("progs/bolt3.mdl");		// for boss shock
	precache_model("progs/lavaball.mdl");	// for testing
	
	precache_model("progs/missile.mdl");
	precache_model("progs/grenade.mdl");
	precache_model("progs/spike.mdl");
	precache_model("progs/s_spike.mdl");
	precache_model("progs/backpack.mdl");
	precache_model("progs/zom_gib.mdl");
	precache_model("progs/v_light.mdl");

	// HIP PRELOADS
	precache_sound("misc/shortexp.wav");
	precache_sound("misc/longexpl.wav");
	precache_model("progs/v_laserg.mdl");
	precache_model("progs/v_hammer.mdl");
	precache_model("progs/v_prox.mdl");
	precache_model("progs/proxbomb.mdl");
	precache_model("progs/lasrspik.mdl");

	StopEarthQuake();

	if (cvar("crosshair") == 2)
		footsteps = 1;
	else
		footsteps = 0;

	// ROGUE PRELOADS
	precache_sound("enforcer/enfstop.wav");    // shield impact
	precache_sound("plasma/explode.wav");
	precache_sound("plasma/flight.wav");			
	precache_sound("plasma/fire.wav");
	precache_sound("shield/hit.wav");
	precache_sound("belt/use.wav");
	precache_sound("items/damage2.wav");
	precache_model("progs/mervup.mdl");
	precache_model("progs/rockup.mdl");
	precache_model("progs/rockup_d.mdl");
	precache_model("progs/lspike.mdl");
	precache_model("progs/shield.mdl");
	precache_model("progs/p_shield.mdl");
	precache_model("progs/plasma.mdl");
	precache_model("progs/v_plasma.mdl");

	// MG1: Moved to lights.qc
	InitLightStyles();

	// QCC Map Load Stuff
	QCC_Precaches();
	QCC_SpawnWeapons();
	qcc_world_sounds = &world.sounds;

	// Dropped Powerup Preloads
	precache_model("progs/invulner.mdl");
	precache_sound("items/protect.wav");
	precache_sound("items/protect2.wav");
	precache_sound("items/protect3.wav");
	precache_model("progs/quaddama.mdl");
	precache_sound("items/damage.wav");
	precache_sound("items/damage2.wav");
	precache_sound("items/damage3.wav");
	precache_model("progs/invisibl.mdl");
	precache_sound("items/inv1.wav");
	precache_sound("items/inv2.wav");
	precache_sound("items/inv3.wav");
	
	// announcer stuff
	qcc_announcer = spawn();
	qcc_announcer.qcc_queue_index = 0;
	qcc_announcer.nextthink = 0.1;
	qcc_announcer.think = QCC_AnnouncerPlayback;
};

void LoadGame();
float LastTime;

void StartFrame() {
	teamplay = cvar("teamplay");
	skill = cvar("skill");
	cheats_allowed = cvar("sv_cheats");
	qccDeltaTime = time - LastTime;
	LastTime = time;

    // save off a global here so it gets included in savegames
    if (!campaign_valid) {
        campaign_valid = TRUE;
        campaign = cvar("campaign");
    } else
        cvar_set("campaign", ftos(campaign));

	framecount = framecount + 1;

	if (!load_flag && framecount > 2) {
	   if (framecount != 3)
		  LoadGame();
	   load_flag = TRUE;
	}
	RunFrameTickEntities(qccDeltaTime);

	// QCC: map load stuff
	if (!qccMapStarted && framecount > 2) {
		entity pl;
		pl = find(world, classname, "player");
		while (pl != world) {
			stuffcmd(pl, "v_cshift 1 1 1 1\n"); // reset view color at map start
			pl = find(pl, classname, "player");
		}

		// music override for addons
		QCC_CDTRACK_OFFSET = 0;
		if (ExtSupported("EX_PROMPT")) {
			// HIP
			if (world.model == "maps/hip1m1.bsp" || world.model == "maps/hip1m2.bsp" || world.model == "maps/hip1m3.bsp" || world.model == "maps/hip1m4.bsp" || world.model == "maps/hip1m5.bsp" || 
				world.model == "maps/hip2m1.bsp" || world.model == "maps/hip2m2.bsp" || world.model == "maps/hip2m3.bsp" || world.model == "maps/hip2m4.bsp" || world.model == "maps/hip2m5.bsp" || world.model == "maps/hip2m6.bsp" || 
				world.model == "maps/hip2m1.bsp" || world.model == "maps/hip2m2.bsp" || world.model == "maps/hip2m3.bsp" || world.model == "maps/hip2m4.bsp" || world.model == "maps/hipend.bsp" || 
				world.model == "maps/hipdm1.bsp" || world.model == "maps/zoo.bsp" || world.model == "maps/mark.bsp")
			{
				QCC_CDTRACK_OFFSET = HIP_CDTRACK_OFFSET;
			}
			// ROGUE
			if (world.model == "maps/ctf1.bsp" || world.model == "maps/r1m1.bsp" || world.model == "maps/r1m2.bsp" || world.model == "maps/r1m3.bsp" || world.model == "maps/r1m4.bsp" || 
				world.model == "maps/r1m5.bsp" || world.model == "maps/r1m6.bsp" || world.model == "maps/r1m7.bsp" || world.model == "maps/r2m1.bsp" || world.model == "maps/r2m2.bsp" || 
				world.model == "maps/r2m3.bsp" || world.model == "maps/r2m4.bsp" || world.model == "maps/r2m5.bsp" || world.model == "maps/r2m6.bsp" || world.model == "maps/r2m7.bsp" || world.model == "maps/r2m8.bsp")
			{
				QCC_CDTRACK_OFFSET = ROGUE_CDTRACK_OFFSET;
			}

			if (QCC_CDTRACK_OFFSET)
			{
				float newtrack = world.sounds + QCC_CDTRACK_OFFSET;
				WriteByte(MSG_ALL, SVC_CDTRACK);
				WriteByte(MSG_ALL, newtrack);
				WriteByte(MSG_ALL, 3+QCC_CDTRACK_OFFSET);
				*qcc_world_sounds = newtrack;
			}
		}

		qccMapStarted = TRUE;
	}
};

/*
==============================================================================

BODY QUEUE

==============================================================================
*/

entity	bodyqueue_head;

void() bodyqueue = {};	// just here so spawn functions don't complain after the world creates bodyqueues

void() InitBodyQueue = {	
	bodyqueue_head = spawn();
	bodyqueue_head.classname = "bodyqueue";
	bodyqueue_head.owner = spawn();
	bodyqueue_head.owner.classname = "bodyqueue";
	bodyqueue_head.owner.owner = spawn();
	bodyqueue_head.owner.owner.classname = "bodyqueue";
	bodyqueue_head.owner.owner.owner = spawn();
	bodyqueue_head.owner.owner.owner.classname = "bodyqueue";
	bodyqueue_head.owner.owner.owner.owner = bodyqueue_head;
};


// make a body que entry for the given ent so the ent can be respawned elsewhere
void(entity ent) CopyToBodyQueue = {
	// QCC: If Dusk Dude was holding their skull, keep holding it
	if (ent.qccFlags & QCC_FL_THROWABLE) {
		QCC_ThrowheadQueue(ent);
		return;
	}

	bodyqueue_head.angles = ent.angles;
	bodyqueue_head.model = ent.model;
	bodyqueue_head.modelindex = ent.modelindex;
	bodyqueue_head.frame = ent.frame;
	bodyqueue_head.colormap = ent.colormap;
	// QCC ----------------------------------------
	if (ent.modelindex == ent.modelindex_champ)
		bodyqueue_head.skin = ent.skin;
	// --------------------------------------------
	bodyqueue_head.movetype = ent.movetype;
	bodyqueue_head.velocity = ent.velocity;
	bodyqueue_head.flags = 0;
	setorigin(bodyqueue_head, ent.origin);
	setsize(bodyqueue_head, ent.mins, ent.maxs);
	bodyqueue_head = bodyqueue_head.owner;
};


