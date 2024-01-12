/*
============================================

DISSOLUTION OF ETERNITY FUNC BOBBING

============================================
*/

/* Water QuickC program
   By Jim Dose'  12/16/96
*/

void() bobbingwater_think = {
    vector ang;
    self.count = self.count + self.speed * (time - self.ltime);
    if (self.count > 360)
        self.count = self.count - 360;
    ang_x = self.count;
    ang_y = 0;
    ang_z = 0;
    makevectors(ang);
    self.origin_z = v_forward_z * self.cnt;
    setorigin(self, self.origin);
    self.ltime = time;
    self.nextthink = time + 0.02;
};

/*QUAKED func_bobbingwater (0 .5 .8) ?
Used to emulate water.  To use, create a thin water brush and center it on the water line of the body of water to bob.
The amount of the bob is the depth of the brush.
"speed" is how long in seconds it takes the brush to do one full bob.
*/
void() func_bobbingwater = {
    self.angles = '0 0 0';
    self.movetype = MOVETYPE_STEP;
    self.solid = SOLID_NOT;
    setmodel(self,self.model);
    self.think = bobbingwater_think;
    self.count = 0;
    self.cnt = self.size_z / 2;
    if (!self.speed)
        self.speed = 4;
    self.speed = 360 / self.speed;
    self.nextthink = time + 0.02;
    self.ltime = time;
};


/*
============================================

DIMENSION OF THE MACHINE FUNC BOB

============================================
*/

const float FUNC_BOB_NONSOLID = 1;
const float FUNC_BOB_START_ON = 2;

const float FUNC_BOB_THINKINTERVAL = 0.05;

vector func_bob_GetPositionForAngle(float an) {
    self.count += (an);
    self.count = mod(self.count, 360);

    float dd = sin(self.count);
    vector offs = self.dest * dd;
    if (self.dest2) {   
        float ddc = cos(self.count);
        offs+= (self.dest2 * ddc);
    }

    return offs;
}

void func_bob_blocked() {
    if (self.attack_finished > time) return;
    T_Damage(other, self, self, self.dmg);
    self.attack_finished = time + 0.5;
}

/*
    We have two different strategies for movement here.
    For solid bobbers, we use the think function and set a velocity. This allows us to stand smoothly on the bobber and be blocked by it.
    For non solid bobbers, the engine does not like having something nonsolid that moves apparently, so instead we just set its position each frame. 
*/

// Used by non-solid bobbers
void func_bob_tick(float dt) {
    vector offs = func_bob_GetPositionForAngle(self.avelocity_x * dt);
    setorigin(self, offs);
}

// Used by solid bobbers
void func_bob_think() {
    vector offs = func_bob_GetPositionForAngle(self.avelocity_x * FUNC_BOB_THINKINTERVAL);

    vector diff = offs - self.origin;
    self.velocity = diff * (1/FUNC_BOB_THINKINTERVAL);

    self.nextthink = self.ltime + FUNC_BOB_THINKINTERVAL;
}

void func_bob_use() {
    if (self.state) {
        if (self.solid) {
            self.velocity = '0 0 0';
            self.nextthink = -1;
        }
        else {
            RemoveFrameTickEntity(self);
        }
    }
    else {
        if (self.solid)
            func_bob_think();
        else
            RegisterFrameTickEntity(self);
    }

    self.state = 1 - self.state;
}

void func_bob() {
     setmodel(self, self.model);
     setorigin(self, self.origin);

     if (!self.dest) self.dest = '0 0 64';
     if (!self.wait) self.wait = 10;
     if (!self.dmg) self.dmg = 1;
     
     self.avelocity_x = 360 / self.wait;
     self.count = 360 * self.delay;
 
     self.use = func_bob_use;
     self.tick = func_bob_tick;
     self.think = func_bob_think;
     self.blocked = func_bob_blocked;
         

    if (self.spawnflags & FUNC_BOB_NONSOLID) {
        self.movetype = MOVETYPE_NONE;
        self.solid = SOLID_NOT;
    }
    else {
        self.movetype = MOVETYPE_PUSH;
        self.solid = SOLID_BSP;
    }
    
    if (self.spawnflags & FUNC_BOB_START_ON)
        func_bob_use();
}