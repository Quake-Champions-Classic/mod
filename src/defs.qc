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

/*
==============================================================================

			SOURCE FOR GLOBALVARS_T C STRUCTURE

==============================================================================
*/

//
// system globals
//
entity	self;
entity	other;
entity	world;
float	time;
float	frametime;

float	force_retouch;		// force all entities to touch triggers next frame.  this is needed because
							// non-moving things don't normally scan for triggers, and when a trigger is
							// created (like a teleport trigger), it needs to catch everything.
							// decremented each frame, so set to 2 to guarantee everything is touched
string	mapname;

float	deathmatch;
float	coop;
float	teamplay;

float	serverflags;		// propagated from level to level, used to keep track of completed episodes

float	total_secrets;
float	total_monsters;

float	found_secrets;		// number of secrets found
float	killed_monsters;	// number of monsters killed

// spawnparms are used to encode information about clients across server level changes
float	parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;

//
// global variables set by built in functions
//	
vector	v_forward, v_up, v_right;	// set by makevectors()
	
// set by traceline / tracebox
float	trace_allsolid;
float	trace_startsolid;
float	trace_fraction;
vector	trace_endpos;
vector	trace_plane_normal;
float	trace_plane_dist;
entity	trace_ent;
float	trace_inopen;
float	trace_inwater;

entity	msg_entity;			// destination of single entity writes

//
// required prog functions
//
void() 	main;					// only for testing
void()	StartFrame;
void() 	PlayerPreThink;
void() 	PlayerPostThink;
void()	ClientKill;
void()	ClientConnect;
void() 	PutClientInServer;		// call after setting the parm1... parms
void()	ClientDisconnect;
void()	SetNewParms;			// called when a client first connects to a server.
								// sets parms so they can be saved off for restarts
void()	SetChangeParms;			// call to set parms for self so they can be saved for a level transition

//================================================
void	end_sys_globals;		// flag for structure dumping
//================================================

/*
==============================================================================

			SOURCE FOR ENTVARS_T C STRUCTURE

==============================================================================
*/

//
// system fields (*** = do not set in prog code, maintained by C code)
//
.float		modelindex;		// *** model index in the precached list
.vector		absmin, absmax;	// *** origin + mins / maxs
.float		ltime;			// local time for entity
.float		movetype;
.float		solid;			// ***
.vector		origin;			// ***
.vector		oldorigin;
.vector		velocity;
.vector		angles;
.vector		avelocity;
.vector		punchangle;		// temp angle adjust from damage or recoil
.string		classname;		// spawn function
.string		model;
.float		frame;
.float		skin;
.float		effects;
.vector		mins, maxs;		// bounding box extents reletive to origin
.vector		size;			// maxs - mins
.void()		touch;
.void()		use;
.void()		think;
.void()		blocked;		// for doors or plats, called when can't push other
.float		nextthink;
.entity		groundentity;

// stats
.float		health;
.float		frags;
.float		weapon;			// one of the IT_SHOTGUN, etc flags
.string		weaponmodel;
.float		weaponframe;
.float		currentammo;
.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
.float		items;			// bit flags

.float		takedamage;
.entity		chain;
.float		deadflag;
.vector		view_ofs;		// add to origin to get eye point
.float		button0;		// fire
.float		button1;		// use
.float		button2;		// jump
.float		impulse;		// weapon changes
.float		fixangle;
.vector		v_angle;		// view / targeting angle for players
.float		idealpitch;		// calculated pitch angle for lookup up slopes
.string		netname;
.entity 	enemy;
.float		flags;
.float		colormap;
.float		team;
.float		max_health;		// players maximum health is stored here
.float		teleport_time;	// don't back up
.float		armortype;		// save this fraction of incoming damage
.float		armorvalue;
.float		waterlevel;		// 0 = not in, 1 = feet, 2 = waist, 3 = eyes
.float		watertype;		// a contents value
.float		ideal_yaw;
.float		yaw_speed;
.entity		aiment;
.entity 	goalentity;		// a movetarget or an enemy
.float		spawnflags;
.string		target;
.string		targetname;

// damage is accumulated through a frame. and sent as one single
// message, so the super shotgun doesn't generate huge messages
.float		dmg_take;
.float		dmg_save;
.entity		dmg_inflictor;

.entity		owner;		// who launched a missile
.vector		movedir;	// mostly for doors, but also used for waterjump
.string		message;	// trigger messages
.float		sounds;		// either a cd track number or sound number
.string		noise, noise1, noise2, noise3;	// contains names of wavs to play

//================================================
void		end_sys_fields;			// flag for structure dumping
//================================================

/*
==============================================================================

				VARS NOT REFERENCED BY C CODE

==============================================================================
*/

//
// constants
//

float	FALSE				= 0;
float 	TRUE				= 1;

// edict.flags
float	FL_FLY				= 1;
float	FL_SWIM				= 2;
float	FL_CLIENT			= 8;		// set for all client edicts
float	FL_INWATER			= 16;		// for enter / leave water splash
float	FL_MONSTER			= 32;
float	FL_GODMODE			= 64;		// player cheat
float	FL_NOTARGET			= 128;		// player cheat
float	FL_ITEM				= 256;		// extra wide size for bonus items
float	FL_ONGROUND			= 512;		// standing on something
float	FL_PARTIALGROUND	= 1024;		// not all corners are valid
float	FL_WATERJUMP		= 2048;		// player jumping out of water
float	FL_JUMPRELEASED		= 4096;		// for jump debouncing
float 	FL_ISBOT     		= 8192; 	// mal: this will be set on bot players
float 	FL_NO_PLAYERS		= 16384;	// mal: used by the spawn point editor
float 	FL_NO_MONSTERS		= 32768;	// mal: used by the spawn point editor
float   FL_NO_BOTS			= 65536;	// mal: any item marked with this will be ignored by bots.
float 	FL_OBJECTIVE		= 131072; 	// mal: any item marked with this is an objective of some kind.

// edict.movetype values
float	MOVETYPE_NONE		= 0;	// never moves
float	MOVETYPE_WALK		= 3;	// players only
float	MOVETYPE_STEP		= 4;	// discrete, not real time unless fall
float	MOVETYPE_FLY		= 5;
float	MOVETYPE_TOSS		= 6;	// gravity
float	MOVETYPE_PUSH		= 7;	// no clip to world, push and crush
float	MOVETYPE_NOCLIP		= 8;
float	MOVETYPE_FLYMISSILE	= 9;	// fly with extra size against monsters
float	MOVETYPE_BOUNCE		= 10;
float	MOVETYPE_GIB		= 11;	// like MOVETYPE_BOUNCE, but with adjustable gravity

// edict.solid values
float	SOLID_NOT			= 0;	// no interaction with other objects
float	SOLID_TRIGGER		= 1;	// touch on edge, but not blocking
float	SOLID_BBOX			= 2;	// touch on edge, block
float	SOLID_SLIDEBOX		= 3;	// touch on edge, but not an onground
float	SOLID_BSP			= 4;	// bsp clip, touch on edge, block
float	SOLID_CORPSE		= 5;	// reports touch and can shoot it, but not blocking otherwise.

// range values
float	RANGE_MELEE			= 0;
float	RANGE_NEAR			= 1;
float	RANGE_MID			= 2;
float	RANGE_FAR			= 3;

// deadflag values
float	DEAD_NO				= 0;
float	DEAD_DYING			= 1;
float	DEAD_DEAD			= 2;
float	DEAD_RESPAWNABLE	= 3;

// takedamage values
float	DAMAGE_NO			= 0;
float	DAMAGE_YES			= 1;
float	DAMAGE_AIM			= 2;

// items
float	IT_AXE				= 4096;
float	IT_SHOTGUN			= 1;
float	IT_SUPER_SHOTGUN	= 2;
float	IT_NAILGUN			= 4;
float	IT_SUPER_NAILGUN	= 8;
float	IT_GRENADE_LAUNCHER	= 16;
float	IT_ROCKET_LAUNCHER	= 32;
float	IT_LIGHTNING		= 64;
float	IT_EXTRA_WEAPON		= 128;
float	IT_SHELLS			= 256;
float	IT_NAILS			= 512;
float	IT_ROCKETS			= 1024;
float	IT_CELLS			= 2048;
float	IT_ARMOR1			= 8192;
float	IT_ARMOR2			= 16384;
float	IT_ARMOR3			= 32768;
float	IT_SUPERHEALTH		= 65535; //65536; QCC: we no longer add megahealth to the items list, since it goes unreferenced in the C code
float	IT_KEY1				= 131072;
float	IT_KEY2				= 262144;

float	IT_INVISIBILITY		= 524288;
float	IT_INVULNERABILITY	= 1048576;
float	IT_SUIT				= 2097152;
float	IT_QUAD				= 4194304;

// point content values
float	CONTENT_EMPTY		= -1;
float	CONTENT_SOLID		= -2;
float	CONTENT_WATER		= -3;
float	CONTENT_SLIME		= -4;
float	CONTENT_LAVA		= -5;
float	CONTENT_SKY			= -6;

float	STATE_TOP			= 0;
float	STATE_BOTTOM		= 1;
float	STATE_UP			= 2;
float	STATE_DOWN			= 3;

vector	VEC_ORIGIN			= '0 0 0';
vector	VEC_HULL_MIN		= '-16 -16 -24';
vector	VEC_HULL_MAX		= '16 16 32';
vector	VEC_HULL2_MIN		= '-32 -32 -24';
vector	VEC_HULL2_MAX		= '32 32 64';

// protocol bytes
float	SVC_TEMPENTITY		= 23;
float	SVC_KILLEDMONSTER	= 27;
float	SVC_FOUNDSECRET		= 28;
float	SVC_INTERMISSION	= 30;
float	SVC_FINALE			= 31;
float	SVC_CDTRACK			= 32;
float	SVC_SELLSCREEN		= 33;
float	SVC_SPAWNEDMONSTER	= 39;
float	SVC_ACHIEVEMENT		= 52;
float	SVC_CHAT 			= 53;
float	SVC_LEVELCOMPLETED	= 54;
float	SVC_BACKTOLOBBY		= 55;
float	SVC_LOCALSOUND		= 56;
float	SVC_PROMPT			= 57;

float	TE_SPIKE		= 0;
float	TE_SUPERSPIKE	= 1;
float	TE_GUNSHOT		= 2;
float	TE_EXPLOSION	= 3;
float	TE_TAREXPLOSION	= 4;
float	TE_LIGHTNING1	= 5;
float	TE_LIGHTNING2	= 6;
float	TE_WIZSPIKE		= 7;
float	TE_KNIGHTSPIKE	= 8;
float	TE_LIGHTNING3	= 9;
float	TE_LAVASPLASH	= 10;
float	TE_TELEPORT		= 11;
float	TE_EXPLOSION2   = 12;
float	TE_BEAM			= 13;

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel
float	CHAN_AUTO		= 0;
float	CHAN_WEAPON		= 1;
float	CHAN_VOICE		= 2;
float	CHAN_ITEM		= 3;
float	CHAN_BODY		= 4;

float	ATTN_NONE		= 0;
float	ATTN_NORM		= 1;
float	ATTN_IDLE		= 2;
float	ATTN_STATIC		= 3;

// update types
float	UPDATE_GENERAL	= 0;
float	UPDATE_STATIC	= 1;
float	UPDATE_BINARY	= 2;
float	UPDATE_TEMP		= 3;

// entity effects
float	EF_BRIGHTFIELD	= 1;
float	EF_MUZZLEFLASH 	= 2;
float	EF_BRIGHTLIGHT 	= 4;
float	EF_DIMLIGHT 	= 8;
float 	EF_QUADLIGHT    = 16;
float 	EF_PENTALIGHT   = 32;
float	EF_CANDLELIGHT	= 64;

// messages
float	MSG_BROADCAST	= 0;	// unreliable to all
float	MSG_ONE			= 1;	// reliable to one (msg_entity)
float	MSG_ALL			= 2;	// reliable to all
float	MSG_INIT		= 3;	// write to the init string

// team numbers
float TEAM_NONE			= -1;
float TEAM_MONSTERS		= 0;
float TEAM_HUMANS		= 1;

// mal: basic colors - based on the Quake color palette.
float COLOR_RED			= 251;
float COLOR_GREEN		= 184;
float COLOR_BLUE		= 208;
float COLOR_YELLOW		= 192;
float COLOR_WHITE		= 254;
float COLOR_BLACK		= 0;
float COLOR_CYAN		= 244;
float COLOR_ORANGE		= 95;

float DRAW_AI_SINGLE_FRAME		= .1; // mal: use for AI that think every 10th of a second
float DRAW_GAME_SINGLE_FRAME	= -1; // mal: use in game code that updates every frame.

// player expanded settings flags
float PEF_CHANGEONLYNEW	= 1;
float PEF_CHANGENEVER   = 2;

// mal: codes that the QuakeC built-ins "bot_movetopoint" and "bot_followentity" will return each time they're called
float BOT_GOAL_ERROR 		= 0;	// can't do this goal for some reason.
float BOT_GOAL_SUCCESS 		= 1;	// goal as requested is complete.
float BOT_GOAL_IN_PROGRESS 	= 2;	// goal is in progress

// mal: codes that the QuakeC built-in "walkpathtogoal" will return each time it's called
float PATH_ERROR 			= 0;	// something bad happened (no nav nodes, no nearby nodes, no path, etc.).
float PATH_REACHED_GOAL 	= 1;	// reached whatever we were trying to get to.
float PATH_REACHED_PATH_END = 2;	// reached the end of the path - can now move directly to target.
float PATH_MOVE_BLOCKED 	= 3;	// something (or someone) is in our way.
float PATH_IN_PROGRESS 		= 4;	// path was found, and we're following it.

//================================================

//
// globals
//
float	movedist;
float	gameover;			// set when a rule exits
string	string_null;		// null string, nothing should be held here
entity	newmis;				// launch_spike sets this after spawning it
entity	activator;			// the entity that activated a trigger or brush
entity	damage_attacker;	// set by T_Damage
float	framecount;
float	skill;
float	campaign_valid;
float	campaign;
float	cheats_allowed;		// mal: let's us run cheat commands in DM/Coop games.
entity	s;					// temp entity used for spawn functions; used to be declared in triggers.qc

//================================================

//
// world fields (FIXME: make globals)
//
.string	wad;
.string	map;
float	WORLDTYPE_MEDIEVAL = 0;
float	WORLDTYPE_METAL = 1;
float	WORLDTYPE_BASE = 2;
.float	worldtype;

//================================================

.string	killtarget;

// QuakeEd fields
.float	light_lev;		// not used by game, but parsed by light util
.float	style;

// Monster Ai
.void() th_stand;
.void() th_walk;
.void() th_run;
.void() th_missile;
.void() th_melee;
.void(entity attacker, float damage) th_pain;
.void() th_die;
.entity	oldenemy;		// mad at this player before taking damage
.float	speed;
.float	lefty;
.float	search_time;

// Attack state (not really used in Vanilla)
.float	attack_state;
float	AS_STRAIGHT		= 1;
float	AS_SLIDING		= 2;
float	AS_MELEE		= 3;
float	AS_MISSILE		= 4;

.float  allowPathFind; // not used in Vanilla, but added for demonstration purposes...

// Combat style
.float 	combat_style;
float   CS_NONE 		= 0; // default - used for bosses or other monsters that don't move
float 	CS_RANGED		= 1;
float 	CS_MELEE		= 2;
float 	CS_MIXED		= 3; // can do ranged or melee equally.

// Player only fields
.float	walkframe;
.float 	attack_finished;
.float	pain_finished;
.float	invincible_finished;
.float	invisible_finished;
.float	super_damage_finished;
.float	radsuit_finished;
.float	invincible_time, invincible_sound;
.float	invisible_time, invisible_sound;
.float	super_time, super_sound;
.float	rad_time;
.float	fly_sound;
.float 	healthrot_nextcheck; // if grabbed Mega-Health, the next time we'll rot the players health
.float	axhitme;
.float	show_hostile;	// set to time + 0.2 whenever a client fires a weapon or takes damage.
						// Used to alert monsters that otherwise would let the player go
.float	jump_flag;		// player jump flag
.float	swim_flag;		// player swimming sound flag
.float	air_finished;	// when time > air_finished, start drowning
.float	bubble_count;	// keeps track of the number of bubbles
.string	deathtype;		// keeps track of how the player died
.float	fired_weapon;	// [NDS] haleyjd: if player has fired a weapon, for achievement
.float	took_damage;	// [NDS] haleyjd: if player has taken damage, for achievement

// object stuff
.string	mdl;
.vector	mangle;		// angle at start
.vector	oldorigin;	// only used by secret door
.float	t_length, t_width;

// Doors, etc
.vector	dest, dest1, dest2;
.float	wait;			// time from firing to restarting
.float	delay;			// time from activation to firing
.entity	trigger_field;	// door's trigger entity
.string	noise4;
.float	aflag;
.float	dmg;			// damage done by door when hit

// plats / doors / buttons
.float	lip;
.float	state;
.vector	pos1, pos2;		// top and bottom positions
.float	height;

// Monsters
.float 	pausetime;
.entity movetarget;

// Misc
.float	cnt;			// misc flag

// Subs
.void()	think1;
.vector	finaldest, finalangle;

// Triggers
.float	count;			// for counting triggers

// Sounds
.float	waitmin, waitmax;
.float	distance;
.float	volume;

.string	killstring;	// monster kill message
.float	spawn_deferred;
void makevectorsfixed(vector ang);		

//===========================================================================	

//
// builtin functions
//

void(vector ang)	makevectors		= #1;		// sets v_forward, etc globals
void(entity e, vector o) setorigin	= #2;
void(entity e, string m) setmodel	= #3;		// set movetype and solid first
void(entity e, vector min, vector max) setsize = #4;
// #5 was removed
void() break						= #6;
float() random						= #7;		// returns 0 - 1
void(entity e, float chan, string samp, float vol, float atten) sound = #8;
vector(vector v) normalize			= #9;
void(string e) error				= #10;
void(string e) objerror				= #11;
float(vector v) vlen				= #12;
float(vector v) vectoyaw			= #13;
entity() spawn						= #14;
//void(entity e) remove				= #15; // MG1 modifies

// sets trace_* globals
// nomonsters can be:
// An entity will also be ignored for testing if forent == test,
// forent->owner == test, or test->owner == forent
// a forent of world is ignored
void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;	

entity() checkclient				= #17;	// returns a client to look for
entity(entity start, .string fld, string match) find = #18;
string(string s) precache_sound		= #19;
string(string s) precache_model		= #20;
void(entity client, string s)stuffcmd = #21;
entity(vector org, float rad) findradius = #22;
void(string s, ...) bprint				= #0:ex_bprint;
void(entity client, string s, ...) sprint = #0:ex_sprint;
void(string s, ...) dprint				= #25;
string(float f) ftos				= #26;
string(vector v) vtos				= #27;
void() coredump						= #28;		// prints all edicts
void() traceon						= #29;		// turns statment trace on
void() traceoff						= #30;
void(entity e) eprint				= #31;		// prints an entire edict
float(float yaw, float dist) walkmove	= #32;	// returns TRUE or FALSE
// #33 was removed
//float() droptofloor= #34;	// TRUE if landed on floor // MG1 modified, see mg1/defs.qc
void(float style, string value) lightstyle = #35;
float(float v) rint					= #36;		// round to nearest int
float(float v) floor				= #37;		// largest integer <= v
float(float v) ceil					= #38;		// smallest integer >= v
// #39 was removed
float(entity e) checkbottom			= #40;		// true if self is on ground
float(vector v) pointcontents		= #41;		// returns a CONTENT_*
// #42 was removed
float(float f) fabs = #43;
vector(entity e, float speed) aim = #44;		// returns the shooting vector
float(string s) cvar = #45;						// return cvar.value
void(string s) localcmd = #46;					// put string into local que
entity(entity e) nextent = #47;					// for looping through all ents
void(vector o, vector d, float color, float count) particle = #48;// start a particle effect
void() ChangeYaw = #49;						// turn towards self.ideal_yaw
											// at self.yaw_speed
// #50 was removed
vector(vector v) vectoangles			= #51;

// direct client message generation
void(float to, float f) WriteByte		= #52;
void(float to, float f) WriteChar		= #53;
void(float to, float f) WriteShort		= #54;
void(float to, float f) WriteLong		= #55;
void(float to, float f) WriteCoord		= #56;
void(float to, float f) WriteAngle		= #57;
void(float to, string s) WriteString	= #58;
void(float to, entity s) WriteEntity	= #59;

// broadcast client message generation
// void(float f) bWriteByte		= #59;
// void(float f) bWriteChar		= #60;
// void(float f) bWriteShort		= #61;
// void(float f) bWriteLong		= #62;
// void(float f) bWriteCoord		= #63;
// void(float f) bWriteAngle		= #64;
// void(string s) bWriteString	= #65;
// void(entity e) bWriteEntity = #66;

void(float step) movetogoal			= #67;
string(string s) precache_file		= #68;		// no effect except for -copy
void(entity e) makestatic			= #69;
void(string s) changelevel			= #70;
//#71 was removed
void(string var, string val) cvar_set = #72;	// sets cvar.value
void(entity client, string s, ...) centerprint = #0:ex_centerprint;	// sprint, but in middle
void(vector pos, string samp, float vol, float atten) ambientsound = #74;
string(string s) precache_model2	= #75;		// registered version only
string(string s) precache_sound2	= #76;		// registered version only
string(string s) precache_file2		= #77;		// registered version only
void(entity e) setspawnparms		= #78;		// set parm1... to the
												// values at level start
												// for coop respawn

float() finaleFinished = #0:ex_finaleFinished;

// Plays a sound that only "client" can hear. Useful for announcers...
void localsound(entity client, string sample) = #0:ex_localsound;

// Debug rendering functions.
void draw_point(vector point, float colormap, float lifetime, float depthtest) = #0:ex_draw_point;
void draw_line(vector start, vector end, float colormap, float lifetime, float depthtest) = #0:ex_draw_line;
void draw_arrow(vector start, vector end, float colormap, float size, float lifetime, float depthtest) = #0:ex_draw_arrow;
void draw_ray(vector start, vector direction, float length, float colormap, float size, float lifetime, float depthtest) = #0:ex_draw_ray;
void draw_circle(vector origin, float radius, float colormap, float lifetime, float depthtest) = #0:ex_draw_circle;
void draw_bounds(vector min, vector max, float colormap, float lifetime, float depthtest) = #0:ex_draw_bounds;
void draw_worldtext(string s, vector origin, float size, float lifetime, float depthtest) = #0:ex_draw_worldtext;
void draw_sphere(vector origin, float radius, float colormap, float lifetime, float depthtest) = #0:ex_draw_sphere;
void draw_cylinder(vector origin, float halfHeight, float radius, float colormap, float lifetime, float depthtest) = #0:ex_draw_cylinder;

// Bot functions that return a value based on "BOT_GOAL_<X>", depending on the status of the goal.
float bot_movetopoint(entity bot, vector point) = #0:ex_bot_movetopoint;
float bot_followentity(entity bot, entity goal) = #0:ex_bot_followentity;

// Function for checking new player configured flags, such as weapon swap behaviour
float CheckPlayerEXFlags(entity playerEnt) = #0:ex_CheckPlayerEXFlags;

// Path monsters to the goal using any available nav nodes on the map
float walkpathtogoal(float movedist, vector goal) = #0:ex_walkpathtogoal;

float checkextension(string s) = #99;

void setcolor(entity client, float color) = #401;

void prompt(entity client, string text, float numChoices) = #0:ex_prompt;
void promptchoice(entity client, string text, float impulse) = #0:ex_promptchoice;
void clearprompt(entity client) = #0:ex_clearprompt;

//============================================================================

// subs.qc
void(vector tdest, float tspeed, void() func) SUB_CalcMove;
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;
void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void() SUB_CalcMoveDone;
void() SUB_CalcAngleMoveDone;
void() SUB_Null;
void() SUB_UseTargets;
void() SUB_Remove;

//	combat.qc
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
float(entity e, float healamount, float ignore) T_Heal; // health function
float(entity targ, entity inflictor) CanDamage;

// player.qc
vector(float dm) VelocityForDamage;

// misc.qc
void() barrel_detonate;

// cthon.qc
void() boss_shockz1;
void() boss_death10;


/*
==============================================================================

			SCOURGE OF ARMAGON DEFS

==============================================================================
*/
float		IT_MJOLNIR					= 128;
float		IT_LASER_CANNON				= 8388608;
float		IT_PROXIMITY_GUN			= 16;
float		HIP_IT_WETSUIT				= 2;
float		HIP_IT_EMPATHY_SHIELDS		= 4;
float		HIP_IT_HORN_OF_CONJURING	= 8;

float		SVC_CUTSCENE				= 34;		//added update stat message
float		STAT_TOTALMONSTERS			= 12;	//added total monster message
float		STAT_TOTALSECRETS			= 11;
float		MIN_ANGLE_DELTA				= 10;

float		AS_DODGING					= 5;
float		CHARMED_RADIUS				= 1500;
float		MAX_CHARMER_DISTANCE		= 200;
float		MIN_CHARMER_DISTANCE		= 150;
float		TOOCLOSE_CHARMER_DISTANCE	= 120;

float		SPAWNFLAG_SUPERSPIKE		= 1;
float		SPAWNFLAG_LASER				= 2;
float		SPAWNFLAG_LAVABALL			= 4;
float		SPAWNFLAG_ROCKET			= 8;
float		SPAWNFLAG_SILENT			= 16;

float		visible_distance;
entity		damage_inflictor;
float		footsteps;
.void()		th_turn;

.float		wetsuit_finished;
.float		wetsuit_time;
.float		empathy_finished;
.float		empathy_time;
.float		empathy_sound;
.float		color;

// Have to use a new items flag because we ran out of bits in the original
.float		items2;

// Gremlin stuff
.float		gorging;
.float		stoleweapon;
.entity		lastvictim;

// Spawn variables
.void()		spawnfunction;
.string		spawnclassname;
.float		spawnsolidtype;
.string		spawnmodel;
.void()		spawnthink;
.entity		spawnmaster;
.vector		spawnmins;
.vector		spawnmaxs;
.float		spawnsilent;
.float		spawnmulti;

// Horn of Conjuring
.float		charmed;
.entity		charmer;
.float		huntingcharmer;
float		horn_active;
entity		horn_charmer;
.vector		old_velocity;

// Rotation
.vector		neworigin;
.vector		rotate;
.float		endtime;
.float		rotate_type;
.string		path;
.string		group;
.string		event;

// Miscellaneous
.float      duration;
.entity     next_ent;				// used for linked list of entities
.float      struck_by_mjolnir;
.float		last_teleport_time;		// teleport invulnerability
.float		gravity;
float		discharged;
entity		hipdecoy;

// Hipnotic's Prototypes
void() StopEarthQuake;
void(float value) EarthQuakeTime;
void() earthquake_postthink;
float(entity counter) counter_GetCount;
vector(vector ang) SUB_NormalizeAngles;
void (entity srcent, entity destent) SUB_CopyEntity;
void(vector loc, float rad, float damage, float dur, float pause, float vol) multi_explosion;
void(string targ, vector orig, entity ent) become_decoy; // QCC: added ent argument
//void(vector origin, vector dir, float color, float count, float lifespan) particlestream = #79;
void() RotateTargets;
void() RotateTargetsFinal;
void() SetTargetOrigin;
void() LinkRotateTargets;
void(entity ent, float amount) hurt_setdamage;

/*
==============================================================================

			DISSOLUTION OF ETERNITY DEFS

==============================================================================
*/
float		GAMECFG_ENABLE_RUNES	= 1; // enable runes (default is disabled)
float		IT2_SHIELD				= 64;
float		IT2_ANTIGRAV			= 128;
float		IT2_EARTHQUAKE			= 512;			
float		IT2_V_SPHERE			= 1024;

// rogue globals!
float		earthquake_active;
float		earthquake_intensity;
float		rogue_cutscene_running;

// player only fields
.float		shield_finished, antigrav_finished;
.float		shield_time, antigrav_time;
.entity		shield_entity;

// elevator fields
.float		elevatorLastUse;
.float		elevatorOnFloor;
.float		elevatorToFloor;
.vector		elevatorDestination; 

// plat2 fields
.float		plat2Called;
.float		plat2LastMove;
.float		plat2GoTime;
.float		plat2GoTo;

// New Ai fields
.float		orbitPosition;

// Dragon specific fields 
.float		playerInRoom;
.float		playerInTransit;
.float		dragonInRoom;
.float		dragonInTransit;
.float		dragonAttacking;
.float		dragonPainSequence;
.vector		dragonLastVelocity;
.float		dragonDeathState;

// Other Rogue Fields
.float		AGping;
.float		childrenSpawned;
.float		ltrailLastUsed;
.float		shield_death_time;
.float		shieldSoundTime;
.float		tag_frags;
.float		tag_message_time;

// Rogue Prototypes
void() lavaspike_touch;
void() superlavaspike_touch;
void(entity ownerEntity) sphere_remove;
void() random_regen;
void() BecomeExplosion;


/*
==============================================================================

			DIMENSION OF THE MACHINE DEFS

==============================================================================
*/
// edict.flags
float	FL_FUTUREMONSTER	= 16384;	// for marking unspawned monsters
float	FL_INSHELTER		= 32768;	// for marking entities as sheltered from trigger_push
float	DROPTOFLOOR_DISABLE	= 65536;
float	IT_ALL_WEAPONS		= IT_AXE | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING | IT_EXTRA_WEAPON | IT_LASER_CANNON ;

// protocol bytes
float	SVC_UPDATESTAT	= 3; // Yoder add, 23/09/2020
float	SVC_CENTERPRINT	= 26; // Yoder add, 23/09/2020

//================================================

// globals
nosave float load_flag;
float	isHordeMode; 	// mal: cache off horde cvar

//================================================

// world fields (FIXME: make globals)
.string		endtext;
const float	WORLDTYPE_HUB = 3;

//================================================

.float		alpha;
.void(float deltaTime) tick;

// quakeed fields
float		SPAWNFLAG_NOMESSAGE				= 1;
float		SPAWNFLAG_NOTOUCH				= 1;
float		SPAWNFLAG_TRIGGER_FIRST			= 2;
float		SPAWNFLAG_NEARSIGHTED			= 8192;
float		MONSTER_ATTACK_FRIEND			= 32;
#ifdef MONSTERS_AWARE_OF_CONTENTS
float		SPAWNFLAG_NO_CONTENTS_DAMAGE	= 16384;
#endif

// monster ai
.float		speed2;		// used by func_doors' "door_go_down"

// object stuff
float		START_OFF = 1;

//===========================================================================
void RemoveFrameTickEntity(entity rem);
void(entity e) remove_real = #15;
void(entity e) remove {
	if (e.tick)
		RemoveFrameTickEntity(e);
	remove_real(e);
}

float(float yaw, float dist) droptofloor_real = #34;	// TRUE if landed on floor
float() droptofloor = { 
	if (self.spawnflags & DROPTOFLOOR_DISABLE)
		return TRUE;
	return droptofloor_real(0, 0); 
}

void centerprint_all(string s) {
	entity e = find(world, classname, "player");
	while (e) {
		centerprint(e, s);
		e = find(e, classname, "player");
	}
}

//============================================================================

.float		is_frozen;				// defines whether an entity is frozen
const float	COOP_ONLY = 32768;		// Only spawn in coop. Used by items and monsters
const float	COOP_SPAWN_ACTIVE = 73;

const float	NOT_IN_COOP = 131072;
#define INHIBIT_COOP if (coop && self.spawnflags & NOT_IN_COOP) {remove(self); return;}

var float	num_players = 0;

//
// horde.qc stuff
//
.float		is_frozen;				// defines whether an entity is frozen
float		FADETIME	= 5;		// STATIC GLOBAL, how long after death until monsters fade out
float		DEFAULT_POWERUP_CHANCE	= 0.025;
float		POWERUP_CHANCE_GAIN		= 0.025;
float		powerup_chance;
entity		horde_ent;				// global horde manager so code can reference without lookup
void()		remote_wavecheck;		// trigger wavecheck from outside the base entity
float		keys_silver;			// number of silver keys the players are carrying
float		keys_gold;				// number of gold keys the players are carrying
.float		killtime;				// game time at which player got their last killed
.float		killspree;				// player's current killing spree
float		KILLSPREE_GAP	= 2;	// amount of time that can lapse for a kill to no longer count as part of a spree
.string		category;				// to do find operations by type
string		CATEGORY_MONSTER = "monster";
//.vector	old_velocity;			// declared in HIP
float		MONSTER_IGNORE_DAMAGE_LAVA	= 1;
float		MONSTER_IGNORE_DAMAGE_SLIME	= 2;
.float		aggro_time;				// when a monster is aggro'd, set this value to the time. Future aggro's check against this.
float		AGGRO_MIN = 1;			// how long to wait before allowing a new Aggro
float		AGGRO_ADD = 1;			// random additional wait

float		HORDE_START_DELAY			= 10;	// how long to wait before starting
float		HORDE_AMMO_RESPAWN_DELAY	= 20;	// how long between horde ammo spawns
//float		horde;
.float		hunger_time;
float		HUNGER_MAX = 10;		// max delay between hunger pangs
float		HUNGER_MIN = 2.5;		// min delay between hunger pangs

.float		axe_hit_chain;			// number of consecutive axe hits
.float		axe_hit_chain_time;		// time of last axe hit + combo time
float		AXE_COMBO_TIME = 0.7;	// max time before combo resets

// AY Dec15 2021, moving from item_runes to defs since these get used by horde now
float		SIGIL_E1 = 1;
float		SIGIL_E2 = 2;
float		SIGIL_E3 = 4;
float		SIGIL_E4 = 8;
float		SIGIL_E5 = 16;
float		SIGIL_E6 = 32;
float		SIGIL_NUMBITS = 6;
