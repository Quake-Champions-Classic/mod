/*
==========================
MG1: FUNC HURT
==========================
*/

const float FUNC_HURT_START_ON = 1;

void func_hurt_touch() {
	if (!self.state)
        return;
	if (other.health <= 0)
        return;
	if (!other.takedamage)
        return;
	if (!(other.flags & (FL_CLIENT | FL_MONSTER)))
        return;
	if (self.attack_finished > time)
        return;
	
	T_Damage(other, self, world, self.dmg);
	self.attack_finished = time + self.wait;
}

void func_hurt_use() {
	self.state = 1 - self.state;
	self.attack_finished = 0;
}

// QUAKED func_hurt (0 .5 .8) ?
// Hurts alive things when they touch it
void func_hurt() {
	setmodel(self, self.model);
	setorigin(self, self.origin);
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.touch = func_hurt_touch;
	self.use = func_hurt_use;

	if (!self.dmg)
        self.dmg = 10;
	if (!self.wait)
        self.wait = 0.2;

	if (self.spawnflags & FUNC_HURT_START_ON)
		self.state = 1;
}