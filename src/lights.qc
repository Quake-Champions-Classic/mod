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

const string LightStyles[] = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"};
const float LightStyles_MAX = LightStyles.length - 1;
const string LightStylesHalf[] = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m"};
const float LightStylesHalf_MAX = LightStylesHalf.length - 1;


//============================================================================
// No special functionality, just to hold dynamic shadowcasting lights for KEX
const float DYNAMICLIGHT_NOT_IN_COOP = 1;
void dynamiclight()  {
    if (coop && self.spawnflags & DYNAMICLIGHT_NOT_IN_COOP)
        remove(self);
}

//============================================================================

void InitLightStyles() {
    //
    // Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
    //

    // 0 normal
    lightstyle(0, "m");
        
    // 1 FLICKER (first variety)
    lightstyle(1, "mmnmmommommnonmmonqnmmo");

    // 2 SLOW STRONG PULSE
    lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");

    // 3 CANDLE (first variety)
    lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");

    // 4 FAST STROBE
    lightstyle(4, "ma");

    // 5 GENTLE PULSE 1
    lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");

    // 6 FLICKER (second variety)
    lightstyle(6, "nmonqnmomnmomomno");

    // 7 CANDLE (second variety)
    lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");

    // 8 CANDLE (third variety)
    lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");

    // 9 SLOW STROBE (fourth variety)
    lightstyle(9, "aaaaaaaazzzzzzzz");

    // 10 FLUORESCENT FLICKER
    lightstyle(10, "mmamammmmammamamaaamammma");

    // 11 SLOW PULSE NOT FADE TO BLACK
    lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");

    // New styles under here if needed:

    // styles 32-62 are assigned by the light program for switchable lights

    // 63 testing
    lightstyle(63, "a");    
}

//============================================================================

string LightFractionToStyle(float frac) {
    if (frac <= 0) return LightStyles[0];
    if (frac >= 1) return LightStyles[LightStyles_MAX];
    frac*= LightStyles.length;
    frac = floor(frac);
    return LightStyles[frac];
}

string LightFractionToStyleHalf(float frac) {
    if (frac <= 0) return LightStylesHalf[0];
    if (frac >= 1) return LightStylesHalf[LightStylesHalf_MAX];
    frac*= LightStylesHalf.length;
    frac = floor(frac);
    return LightStylesHalf[frac];
}

enum : int {
    LightRampStateOff,
    LightRampStateFadeUp,
    LightRampStateOn,
    LightRampStateFadeDown
};

float LIGHTRAMP_FULLRANGE = 1;

void target_lightramp_setlight(float style, float frac) {
    if (self.spawnflags & LIGHTRAMP_FULLRANGE)
        lightstyle(style, LightFractionToStyle(frac));
    else
        lightstyle(style, LightFractionToStyleHalf(frac));
}

void target_lightramp_tick(float dt) {
    float diff = dt * self.delay;
    switch(self.state) {
        case LightRampStateFadeDown:
            self.cnt-= diff;
            break;
            
        case LightRampStateFadeUp:
            self.cnt+= diff;
            break;
    }
    target_lightramp_setlight(self.owner.style, self.cnt);
    if (self.cnt >= 1) {
        self.cnt = 1;
        self.state = LightRampStateOn;
        RemoveFrameTickEntity(self);
    }
    if (self.cnt <= 0) {
        self.cnt = 0;
        self.state = LightRampStateOff;
        RemoveFrameTickEntity(self);
    }

}

void target_lightramp_use() {
    switch(self.state) {
        case LightRampStateFadeDown:
            self.state = LightRampStateFadeUp;
            return;

        case LightRampStateOff:
            self.state = LightRampStateFadeUp;
            RegisterFrameTickEntity(self);
            return;

        case LightRampStateOn:
            self.state = LightRampStateFadeDown;
            RegisterFrameTickEntity(self);
            return;
        
        case LightRampStateFadeUp:
            self.state = LightRampStateFadeDown;
            return;
    }
}

void target_lightramp_init() {
    self.think = SUB_Null;
    if (!self.target) objerror("\n\ntarget_lightramp with no target.\n\n");
    if (!self.targetname) objerror("\n\ntarget_lightramp with no targetname.\n\n");
    
    self.owner = find(world, targetname, self.target);
    if (!self.owner) objerror("\n\ntarget_lightramp with unmatched target.\n\n");

    if (self.owner.spawnflags & START_OFF) {
        self.state = LightRampStateOff;
        self.cnt = 0;
    }
    else {
        self.state = LightRampStateOn;
        self.cnt = 1;
    }    
    self.use = target_lightramp_use;
    self.tick = target_lightramp_tick;
}

void target_lightramp() {    
    if (!self.delay)
        self.delay = 1;
    self.delay = 1 / self.delay;
    self.think = target_lightramp_init;
    self.nextthink = time + 0.1;
}

//============================================================================

const float LIGHT_TARGETNAME_IS_STYLE = 2;

void() light_use = {
	if (self.spawnflags & START_OFF) {
		lightstyle(self.style, "m");
		self.spawnflags = self.spawnflags - START_OFF;
	}
	else {
		lightstyle(self.style, "a");
		self.spawnflags = self.spawnflags + START_OFF;
	}
};

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
*/
void() light = {
	if (!self.targetname) {	// inert light
		remove(self);
		return;
	}
	
	if (self.style >= 32) {
        if (self.spawnflags & LIGHT_TARGETNAME_IS_STYLE) {
            lightstyle(self.style, self.targetname);
            remove(self);
            return;
        }
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
};

/*QUAKED light_fluoro (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
Makes steady fluorescent humming sound
*/
void() light_fluoro = {
	if (self.style >= 32) {
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}	
	precache_sound("ambience/fl_hum1.wav");
	ambientsound(self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_fluorospark (0 1 0) (-8 -8 -8) (8 8 8)
Non-displayed light.
Default light value is 300
Default style is 10
Makes sparking, broken fluorescent sound
*/
void() light_fluorospark = {
	if (!self.style)
		self.style = 10;
	precache_sound("ambience/buzz1.wav");
	ambientsound(self.origin, "ambience/buzz1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_globe (0 1 0) (-8 -8 -8) (8 8 8)
Sphere globe light.
Default light value is 300
Default style is 0
*/
void() light_globe = {
	precache_model("progs/s_light.spr");
	setmodel(self, "progs/s_light.spr");
	makestatic(self);
};

void() FireAmbient = {
	precache_sound("ambience/fire1.wav");
	ambientsound(self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
};

const float UPSIDEDOWN = 4;

/*QUAKED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20)
Short wall torch
Default light value is 200
Default style is 0
*/
void() light_torch_small_walltorch = {
	precache_model("progs/flame.mdl");
	setmodel(self, "progs/flame.mdl");	
	if (self.spawnflags & UPSIDEDOWN)
		self.angles = '180 0 0';	
	FireAmbient();
	makestatic(self);
};

/*QUAKED light_flame_large_yellow (0 1 0) (-10 -10 -12) (12 12 18)
Large yellow flame ball
*/
void() light_flame_large_yellow = {
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");
	self.frame = 1;	
	if (self.spawnflags & UPSIDEDOWN)
		self.angles = '180 0 0';	
	FireAmbient();
	makestatic(self);
};

/*QUAKED light_flame_small_yellow (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Small yellow flame ball
*/
void() light_flame_small_yellow = {
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");	
	if (self.spawnflags & UPSIDEDOWN)
		self.angles = '180 0 0';	
	FireAmbient();
	makestatic(self);
};

/*QUAKED light_flame_small_white (0 1 0) (-10 -10 -40) (10 10 40) START_OFF
Small white flame ball
*/
void() light_flame_small_white = {
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");	
	if (self.spawnflags & UPSIDEDOWN)
		self.angles = '180 0 0';	
	FireAmbient();
	makestatic(self);
};

/*QUAKED light_flame_gas (0 1 0) (-10 -10 -40) (10 10 40) START_OFF
Gas flare (spawns two entites)
*/
void() light_flame_gas = {
    precache_model("progs/flame3.mdl");
	setmodel(self, "progs/flame3.mdl");
    self.alpha = 0.6;
    entity e = spawn();
    setorigin(e, self.origin);
    setmodel(e, "progs/flame3.mdl");
    e.alpha = 0.4;
    e.frame = 1;
};

/*QUAKED light_candle (0 .5 0) (-4 -4 -10) (4 4 10)
Candle
Default light value is 200
Default style is 0
*/
void() light_candle = {
	precache_model("progs/candle.mdl");
	setmodel(self, "progs/candle.mdl");
	makestatic(self);
};
