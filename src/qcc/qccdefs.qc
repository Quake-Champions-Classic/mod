/*
=================================================
QUAKE CHAMPIONS CLASSIC
=================================================
NEW CHAMPION INSTRUCTIONS
* Champion mdl must have matching animation frame counts with default player.mdl;
	they don't have to be animated the same, but we still use the player animation calls.
	Ability / extra animations should start on frame 144.
* Champions should be sized similarly to Ranger as they will use his navigation hull. See qccchamps.qc > QCC_SpawnChampion.
	Specifically, the X mins needs to be -16 as that is how the engine will decide the navigational hull size.
	Larger champions can have taller and deeper hit boxes, but keep X mins -16 and X maxs to +16.
* If using a custom melee weapon, the first 9 frames must be dedicated to idle (1), swing A (2-4), and swing B (5-8).
	If reusing the melee model for an ability, add these extra animations starting from frame 10.
* qccdefs.qc:
	-Add the spawn method declarations.
	-Add the Champion to the Champion IDs enum.
* qccchamps.qc:
	-Add all required precaches (models, sounds) to QCC_Precaches. Every model and sound you use for your champion.
	-Add Champion spawn methods to QCC_SpawnChampion, QCC_PickChampion, and QCC_SpawnChampion2.
*/

void() W_Attack;
// Borrowed from Triggers
void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath; 

// INTERLOPERS
void() QCC_Precaches;		// world
void() QCC_SpawnWeapons;	// world
void() QCC_PreThinkImpulse;	// client

// SHARED
void() QCC_SpawnChampion;
void(float pick_dir) QCC_PickChampion;
void() QCC_PickChampion2;
void() QCC_FireAbility;			// weapons
void(entity ent) QCC_AbilityTimeLeft;
void(entity ent) QCC_AbilityCooldown;
void() QCC_RestoreWeapon;
void(float max_skins) QCC_SetSkin;
void() QCC_SwapSkin;
void() QCC_CheckArmorRot;
void() QCC_MovePreThink;
void() QCC_MovePostThink;

// WEAPONS
void() qcc_weapon_heavymachinegun;
void() qcc_weapon_railgun;
float() QCC_Rocket_to_Rail;
void() QCC_W_FireRail;

// ITEMS
void() qcc_item_hourglass;		// items
void() qcc_hourglass_horde_touch; // mg1/horde
void() QCC_ThrowArmorshard;
void() qcc_item_lightarmor;
void() qcc_item_heavyarmor;
void(float it_flag) QCC_ThrowPowerup;

// CHAMPIONS
// Ranger
void() QCC_Ranger;
// Death Knight
void() QCC_DeathKnight;
void(entity f_owner, entity f_target) QCC_CatchFire;	// weapons
// Nyx
void() QCC_Nyx;
// Doom Slayer
void() QCC_DoomSlayer;
void() QCC_DoomPunch;		// player
void() QCC_DoomPunchHit;	// weapons
// Commander Keen
void() QCC_Keen;
void() QCC_StunProc;
// Keel
void() QCC_Keel;
// Scalebearer
void() QCC_Scalebearer;
// Sorlag
void() QCC_Sorlag;
// Slash
void() slash_slide;
void() QCC_SlashAttack;
void() QCC_Slash;
// Anarki
void() QCC_Anarki;
// Galena
void() QCC_Galena;
// Duke Nukem
void() QCC_DukeNukem;
void() QCC_Jetpack;			// client
void() QCC_DukeSpawn;
void(entity targ, entity attacker) QCC_DukeFrag;
void(entity collector, entity item) QCC_DukeItem;
// Caleb
void() QCC_Caleb;
void() QCC_CalebSpawn;
void(entity targ, entity attacker) QCC_CalebFrag;
void(entity collector, entity item) QCC_CalebItem;
// Dusk Dude
void() QCC_DuskDude;
void(entity ent) QCC_ThrowheadQueue;	// client
// Big John
void() QCC_BigJohn;

// Observer
void() QCC_Observer;
void() QCC_ObserverPreThink;
void() QCC_ObserverPostThink;

/*
-------------------------------------
// QCC GLOBAL CONSTANTS
-------------------------------------
*/
nosave float qccMapStarted;
float qccDeltaTime;
float MAX_PLAYERS = 16; // used for .ignore_players and other loops and arrays
float QCC_ABILITY = 22137;
float QCC_GLOBAL_COOLDOWN = 60;
float QCC_LIGHT = 0;
float QCC_MEDIUM = 1;
float QCC_HEAVY = 2;
// Impulses
float QCC_IM_ABILITY = 22;
float QCC_IM_PICK_CHAMP = 23;
float QCC_IM_SKIN = 24;
float QCC_IM_INTERACT = 25;
float QCC_IM_PREV_CHAMP = 26;
float QCC_IM_OBSERVER = 29;
float QCC_IM_RAILGUN = 39;
float QCC_IM_CHAMPSTART = 100;
// Items
float QCC_IT_HEAVYMACHINEGUN = 4; // replaces nailgun
//float QCC_IT_TRIBOLT = 16; // replaces grenade launcher
float QCC_IT_RAILGUN = 65536;

// Champion IDs
enum : float {
	QCC_RANGER,
	QCC_DEATHKNIGHT,
	QCC_NYX,
	QCC_DOOMSLAYER,
	QCC_KEEN,
	QCC_KEEL,
	QCC_SCALEBEARER,
	QCC_SORLAG,
	QCC_SLASH,
	QCC_ANARKI,
	QCC_GALENA,
	QCC_DUKENUKEM,
	QCC_DUSKDUDE,
	QCC_BIGJOHN,
	QCC_CHAMPS_MAX,
	QCC_CALEB
};

float QCC_OBSERVER = -1;

// Flags
float QCC_FL_THROWABLE =		1;
float QCC_FL_THR_IT_BSP =		2;
float QCC_FL_THR_IT_MDL =		4;
float QCC_FL_CANDEFLECT =		8;
float QCC_FL_ACROBAT =			16;		// no fall damage
float QCC_FL_MERMAID =			32;		// breathe underwater
float QCC_FL_FIREPROOF =		64;		// immune to lava / fire
float QCC_FL_SLIMEPROOF =		128;	// immune to slime / poison
float QCC_FL_REINFORCED =		256;	// reduced splash damage
float QCC_FL_INFIGHT =			512;	// monsters ignore class alliances, monster_army default behavior
float QCC_FL_RESIST_ROCKET =	1024;	// 50% damage reduction
float QCC_FL_RESIST_LIGHT =		2048;
float QCC_FL_STOCKPILE =		4096;	// Picking up ammo reduces cooldown
float QCC_FL_RESIST_TELEFRAG =	8192;	// Takes 3 telefrags to telefrag; used for Elder Gods vs Ranger / Nyx
float QCC_FL_MONSTER_NOMOVE =	16384;
float QCC_FL_CUSTOM_SIZE =		32768;
float QCC_FL_CUSTOM_VIEW =		65536;
float QCC_FL_CHANNELING =		131072;	// 5% cooldown on health pickup; 10% cooldown on Mega pickup
float QCC_FL_ABILITY =			262144; // needed for radius damaging abilities


// Music
float HIP_CDTRACK_OFFSET = 10;
float ROGUE_CDTRACK_OFFSET = 18;
float QCC_CDTRACK_OFFSET;
nosave float *qcc_world_sounds; // this will point to world.sounds to allow us to listen to addon music

// TEAMPLAY
enum : float {
	QCC_TEAM_RED,
	QCC_TEAM_BLUE,
	QCC_TEAM_YELLOW,
	QCC_TEAM_GREEN,
	QCC_MAX_TEAMS
};

/*
-------------------------------------
ENTITY FIELDS
-------------------------------------
*/
.float qccPlayerBit; // bit value set in PutClientInServer
.float qccFlags;
.float qccNextChampion;
.float qccChampion;
.void() qccSpawnFunc;
.float qccClass;
.void() qccAttackFunc; // weapon attack replacer; defaults to W_Attack
.float qccIgnorePlayers; // keeps track of player interactions with this entity via bitmask; see Galena's totems

// Appearance
.float modelindex_champ; // used in conjunction with the client.qc hackery, maintains champion model indexing after invisibility and other nonsense
.float qccSkin;
.float qccMaxSkins;
.void() qccSkinFunc; // some champs have multiple models; instead of constantly adding if/elses to the skinfunc let's just give some champs a unique one
.string qccChampGib; // head model on gib
.float qccGibSkins;
.string qccMeleeMdl; // melee weapon model
.float qccVictoryFrame; // frame to set champion to on Shub death

// Ability
.void() qccAbilityFunc; // ability function call
.string qccAbilityString;
.entity qccAbilityEnt;
.float qccAbilityEntCt;
.entity qccAbilityOwner;
.float qccAbilityCost;
.float qccAbilityTimer;
.float qccPrevWep;
.float qccArmorType2;
.float qccSlideTime;

// Items
.float qccMaxArmor;
.float qccArmorRot_nextcheck;
.float qccAltWeapon;
.float qccItems3;

//Status
.float qccSelfDamage;
.float qccOnFire;
.float qccPoisoned;
.float qccStunned;

// Movement
.float qccDoubleJump;
.vector qccLastVelocity;
.void() qccInteractFunc; // Impulse QCC_IM_INTERACT call
.void() qccJumpFunc; // for special jumptypes; wall jump, double jump, jetpack, etc...
.void() qccPreThink; // useful for things like varying champ speeds or movement methods
.void() qccPostThink; // used to reset the changes made in prethink (important for the movement code)
.float qccMoveSpeed; // multiplier used to alter speed values in PreThink

// Sound
.void() qccSpeakSpawn;
.void(entity targ, entity attacker) qccSpeakFrag;
.void(entity collector, entity item) qccSpeakItem;
.string qccSpeakCthonGreet;
.string qccSpeakCthonKill;
.string qccSpeakShubGreet;
.string qccSpeakShubKill;
.float qccTauntTimer;
.string qccSndMelee; // axe, sword, gauntlet sound
.string qccSndMeleeHit; // melee weapon enemy hit sound; leave "" for silent (default behavior)
.string qccSndMeleeWall; // melee weapon wall hit sound
.string qccSndJump;
.string qccSndLand1; // soft landing
.string qccSndLand2; // cronch landing
.string qccSndPain1;
.string qccSndPain2;
.string qccSndPain3;
.string qccSndPain4;
.string qccSndPain5;
.string qccSndPain6;
.string qccSndDeath1;
.string qccSndDeath2;
.string qccSndDeath3;
.string qccSndDeath4;
.string qccSndDeath5;
.string qccSndAxHit1;
.string qccSndBurn1;
.string qccSndBurn2;
.string qccSndGasp1; // gasping for air on water exit
.string qccSndGasp2;
.string qccSndDrown1; // water pain
.string qccSndDrown2;
.string qccSndH2oDeath;

// Bot stuff
.void() qccBotPreThink;
.void() qccBotPostThink;

/*
==================================================================
ANNOUNCER
==================================================================
*/
entity qcc_announcer; // spawned in worldspawn function
.float qcc_queue_index;
.float delay1, delay2, delay3, delay4;
void() QCC_AnnouncerPlayback;
void(string snd, float delay) QCC_Announce;


/*
==================================================================
MISC HELPERS
==================================================================
*/
// Various helpful math functions
vector(vector point, float ang) QCC_RotatePointYaw = {
	vector vec;
	float x, y;
	
	vec = '0 1 0' * self.angles_y;
	makevectors(vec);
	vec = point;
	x = vec_x * v_forward_x - vec_y * v_forward_y;
	y = vec_x * v_forward_y + vec_y * v_forward_x;
	vec_x = x;
	vec_y = y;
	
	return vec;
};

// Used to check if we're using Rerelease
float ExtSupported(string extension) {
	if (!cvar("pr_checkextension"))
		return FALSE;
	return checkextension(extension);
}

// Hipnotic + Rogue shared defs
enum class BotGoalReturnCode : int {
	Error = 0,
	Success,
	InProgress
};