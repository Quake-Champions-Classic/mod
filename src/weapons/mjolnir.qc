void() HIP_LightningThink = {
	vector org, dst, vec;
	entity head, selected;
	float cur_dist, head_dist, dot, dam, oldstate;

	if (time > self.delay) {
		if (self.enemy != world)
			self.enemy.struck_by_mjolnir = 0;
		remove(self);
		return;
	}

	oldstate = self.state;
	if (self.state == 0) {
		// look in our immediate vicinity
		self.enemy = world;
		selected = world;
		cur_dist = self.distance;
		head = findradius(self.owner.origin, self.distance);
		while (head) {
			if (!(head.flags & FL_NOTARGET) && ((head.flags & FL_MONSTER) || (head.flags & FL_CLIENT))) {
				if ((visible(head)) && (head != self.owner.owner) && (head.health > 0)) {
					head_dist = vlen(head.origin - self.lastvictim.origin);
					if ((head_dist < cur_dist) && (head.struck_by_mjolnir == 0)) {
						selected = head;
						cur_dist = head_dist;
					}
				}
			}
			head = head.chain;
		}

		if (selected != world) {
			self.state = 1;
			self.enemy = selected;
			self.enemy.struck_by_mjolnir = 1;
		}
		else {
			vector end;

			makevectors(self.v_angle);
			org = self.owner.origin;
			end = org + v_forward * 200;
			end = end + (((400 * random()) - 200) * v_right);

			traceline(org, end, TRUE, self);

			WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
			WriteEntity(MSG_BROADCAST, self);
			WriteCoord(MSG_BROADCAST, org_x);
			WriteCoord(MSG_BROADCAST, org_y);
			WriteCoord(MSG_BROADCAST, org_z);
			WriteCoord(MSG_BROADCAST, trace_endpos_x);
			WriteCoord(MSG_BROADCAST, trace_endpos_y);
			WriteCoord(MSG_BROADCAST, trace_endpos_z);

			self.nextthink = time + 0.1;
			return;
		}
	}

	org = self.lastvictim.origin;
	dst = self.enemy.absmin + 0.25 * (self.enemy.absmax - self.enemy.absmin);
	dst = dst + (random() * 0.5 * (self.enemy.absmax - self.enemy.absmin));
	traceline(org, dst, TRUE, self.owner.owner);

	if (trace_fraction != 1.0 || self.enemy.health <= 0) {
		self.enemy.struck_by_mjolnir = 0;
		self.state = 0;
		self.nextthink = time + 0.1;
		return;
	}

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity(MSG_BROADCAST, self);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);
	vec = normalize(self.enemy.origin - self.owner.origin);
	dot = vec * self.owner.movedir;

	head = self;
	self = self.owner.owner;
	if (oldstate == 0)
		dam = 80;
	else
		dam = 30;
	if (dot > 0.3)
        LightningDamage(org, trace_endpos, self, dam);
	else
        LightningDamage(org, trace_endpos, self, dam * 0.5);    
	self = head;

	self.nextthink = time + 0.2;
};

void(entity prev, entity own, float dst) HIP_SpawnMjolnirLightning = {
	entity light;
	// spawn actual lightning
	light = spawn();
	light.delay = time + 0.8;
	light.state = 0;
	light.lastvictim = prev;
	light.distance = dst;
	light.owner = own;
	light.v_angle = self.angles;
	light.v_angle_x = 0;
	light.v_angle_z = 0;
	light.origin = own.origin;
	light.think = HIP_LightningThink;
	light.nextthink = time;
};

void() HIP_SpawnMjolnirBase = {
	entity light;
	// spawn lightning base
	light = spawn();
	light.origin = trace_endpos;
	light.flags = 0;
	light.owner = self;
	light.struck_by_mjolnir = 1;
	light.think = SUB_Remove;
	light.nextthink = time + 1;
	sound(light, CHAN_AUTO, "hipweap/mjolslap.wav", 1, ATTN_NORM);
	sound(light, CHAN_WEAPON, "hipweap/mjolhit.wav", 1, ATTN_NORM);
	makevectors(self.v_angle);
	light.movedir = v_forward;
	HIP_SpawnMjolnirLightning(light, light, 350);
	HIP_SpawnMjolnirLightning(light, light, 350);
	HIP_SpawnMjolnirLightning(light, light, 350);
	HIP_SpawnMjolnirLightning(light, light, 350);
};

void() HIP_FireMjolnirLightning = {
	float cells;

	// explode if under water
	if (self.waterlevel > 1) {
		cells = self.ammo_cells;
		self.ammo_cells = 0;
      	discharged = 1;
		T_RadiusDamage(self, self, 35*cells, world);
      	discharged = 0;
		W_SetCurrentAmmo ();
		return;
	}

   	self.currentammo = self.ammo_cells = self.ammo_cells - 15;
	HIP_SpawnMjolnirBase();
};

void() HIP_FireMjolnir = {
	vector org, source;
	float damage;

	self.attack_finished = time + 0.4;
	source = self.origin + '0 0 16';

	makevectors(self.v_angle);
	traceline(source, source + v_forward * 32, FALSE, self);
	if (trace_fraction == 1.0 && self.ammo_cells >= 15) {
		source = source + v_forward * 32;
		traceline(source , source - v_up * 50, FALSE, self);
		if (trace_fraction > 0.3 && trace_fraction < 1.0) {
			HIP_FireMjolnirLightning();
			self.attack_finished = time + 1.5;
			return;
		}
	}

	org = trace_endpos - v_forward * 4;

	if (trace_ent.takedamage) {
		damage = 50;
		if (trace_ent.classname == "monster_zombie")
			damage = 70;
		trace_ent.axhitme = 1;
		SpawnBlood(org, v_forward, damage);
		T_Damage(trace_ent, self, self, damage);
	}
	else {  // hit wall
		if (trace_fraction != 1.0) {
			sound(self, CHAN_WEAPON, "hipweap/mjoltink.wav", 1, ATTN_NORM);
			WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte(MSG_BROADCAST, TE_GUNSHOT);
			WriteCoord(MSG_BROADCAST, org_x);
			WriteCoord(MSG_BROADCAST, org_y);
			WriteCoord(MSG_BROADCAST, org_z);
		}
		else
			sound(self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
	}
	self.attack_finished = time + 0.4;
};

/*
================
PICKUP
================
*/
void() weapon_mjolnir = {
	qcc_weapon_railgun();
	self.classname = "qcc_weapon_railgun";
	/*
	precache_model("progs/g_hammer.mdl");
	setmodel(self, "progs/g_hammer.mdl");
	self.weapon = 4;
	self.netname = "$qc_mjolnir";
	self.items = IT_MJOLNIR;
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
	*/
};