//Decompiled code. Please respect the original copyright.

void(vector org, vector vel, float damage) SpawnBlood;
void() SuperDamageSound;

void() W_Precache =
{
	precache_sound("weapons/r_exp3.wav");
	precache_sound("weapons/rocket1i.wav");
	precache_sound("weapons/sgun1.wav");
	precache_sound("weapons/guncock.wav");
	precache_sound("weapons/ric1.wav");
	precache_sound("weapons/ric2.wav");
	precache_sound("weapons/ric3.wav");
	precache_sound("weapons/spike2.wav");
	precache_sound("weapons/tink1.wav");
	precache_sound("weapons/grenade.wav");
	precache_sound("weapons/bounce.wav");
	precache_sound("weapons/shotgn2.wav");
	moon_precache();
};

float() crandom =
{
	return ((2 * (random() - 0.5)));
};

void() W_FireAxe =
{
	local vector source;
	local vector org;

	makevectors(self.v_angle);
	source = (self.origin + '0 0 16');
	traceline(source, (source + (v_forward * MOON_WEAPON_DISTANCE_AXE)), FALSE, self);
	if ( trace_fraction == 1 )
	{
		return;
	}

	org = (trace_endpos - (v_forward * 4));
	if (trace_ent.takedamage)
	{
		SpawnBlood(org, VEC_ORIGIN, GRD_PATROLTIME);
		trace_ent.axhitme = MOON_CONST_AXE_HIT;
		if ( self.up_axe >= MOON_CONST_UNLOCKED )
		{
			trace_ent.axhitme = MOON_CONST_AXE_CRIPPLE;
		}
		T_Damage(trace_ent, self, self, MOON_WEAPON_DAMAGEPER_SLASH + (self.up_axe * MOON_ITEM_MELEEUP_SIDEEFFECT_BONUS));
	} else {
		sound(self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord(MSG_BROADCAST, org_x);
		WriteCoord(MSG_BROADCAST, org_y);
		WriteCoord(MSG_BROADCAST, org_z);
	}
};

vector() wall_velocity =
{
	local vector vel;

	vel = normalize(self.velocity);
	vel = normalize(((vel + (v_up * (random() - MON_BACKTIME))) + (v_right * (random() - MON_BACKTIME))));
	vel = (vel + (H_MEGA * trace_plane_normal));
	vel = (vel * 200);
	return (vel);
};

void(vector org, vector vel) SpawnMeatSpray =
{
	local entity missile;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;
	makevectors(self.angles);
	missile.velocity = vel;
	missile.velocity_z = ((missile.velocity_z + 250) + (50 * random()));
	missile.avelocity = '3000 1000 2000';
	missile.nextthink = (time + 1);
	missile.think = SUB_Remove;
	setmodel(missile, "progs/zom_gib.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, org);
};

void(vector org, vector vel, float damage) SpawnPoison =
{
	particle(org, (vel * MON_CAMPERCHANCE), 56, (damage * H_MEGA));
};

void(float damage) spawn_touchpoison =
{
	local vector vel;

	vel = (wall_velocity() * MON_REACTIONTIME);
	SpawnPoison((self.origin + (vel * MON_REFRESHTIME)), vel, damage);
};

void(vector org, vector vel, float damage) SpawnBlood =
{
	particle(org, (vel * MON_CAMPERCHANCE), 73, (damage * H_MEGA));
};

void(float damage) spawn_touchblood =
{
	local vector vel;

	if ( other.green_blood == TRUE )
	{
		spawn_touchpoison(damage);
		return;
	}
	vel = (wall_velocity() * MON_REACTIONTIME);
	SpawnBlood((self.origin + (vel * MON_REFRESHTIME)), vel, damage);
};

void(vector org, vector vel) SpawnChunk =
{
	particle(org, (vel * 0.02), WF_NORMAL, SVC_SETVIEWANGLES);
};
entity multi_ent;
float multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
	{
		return;
	}
	T_Damage(multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
	{
		return;
	}

	if ( hit != multi_ent )
	{
		ApplyMultiDamage();
		multi_damage = damage;
		multi_ent = hit;
	} else {
		multi_damage = (multi_damage + damage);
	}
};

void(float damage, vector dir) TraceAttack =
{
	local vector vel;
	local vector org;

	vel = normalize(((dir + (v_up * crandom())) + (v_right * crandom())));
	vel = (vel + (2 * trace_plane_normal));
	vel = (vel * 200);
	org = (trace_endpos - (dir * 4));
	if (trace_ent.takedamage)
	{
		if ( trace_ent.green_blood == TRUE )
		{
			SpawnPoison(org, (vel * 0.2), damage);
		} else {
			SpawnBlood(org, (vel * 0.2), damage);
		}
		AddMultiDamage(trace_ent, damage);
	} else {
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord(MSG_BROADCAST, org_x);
		WriteCoord(MSG_BROADCAST, org_y);
		WriteCoord(MSG_BROADCAST, org_z);
	}
};

void(float shotcount, vector dir, vector spread) FireBullets =
{
	local vector direction;
	local vector src;

	makevectors(self.v_angle);
	src = (self.origin + (v_forward * SVC_SETVIEWANGLES));
	src_z = (self.absmin_z + (self.size_z * 0.7));

	ClearMultiDamage();
	while ( shotcount > 0 )
	{
		direction = ((dir + ((crandom() * spread_x) * v_right)) + ((crandom() * spread_y) * v_up));
		traceline(src, (src + (direction * 2048)), FALSE, self);
		if ((trace_fraction != 1))
		{
			TraceAttack(LOGIC_DEFEND, direction);
		}
		shotcount = (shotcount - 1);
	}
	ApplyMultiDamage();
};

void() W_FireShotgun =
{
	local vector dir;

	sound(self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);
	self.punchangle_x = CONTENT_SOLID;
	self.ammo_shells = (self.ammo_shells - MOON_WEAPON_SHOTGUN_SALVO_SIZE);
	self.currentammo = self.ammo_shells; // Fixed
	dir = aim(self, 100000);

	if ( self.up_bullet == MOON_CONST_LOCKED ) // Re-use same param for both Upgrade and Extra capacity
	{
		FireBullets(6, dir, '0.04 0.04 0');
	} else {
		FireBullets(7, dir, '0.02 0.02 0');
	}
};

void() W_FireSuperShotgun =
{
	local vector dir;

	if ( self.currentammo < MOON_WEAPON_SUPERSHOTGUN_SALVO_SIZE )
	{
		W_FireShotgun();
		return;
	}

	sound(self, CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
	self.punchangle_x = -4;
	self.ammo_shells = (self.ammo_shells - MOON_WEAPON_SUPERSHOTGUN_SALVO_SIZE);
	self.currentammo = self.ammo_shells; // Fixed
	dir = aim(self, 100000);

	if ( self.up_bullet == MOON_CONST_LOCKED ) // Re-use same param for both Upgrade and Extra capacity
	{
		FireBullets(14, dir, '0.14 0.08 0');
	} else {
		FireBullets(16, dir, '0.06 0.04 0');
	}
};

void() s_explode1 = [ 0, s_explode2 ]
{
};

void() s_explode2 = [ 1, s_explode3 ]
{
};

void() s_explode3 = [ 2, s_explode4 ]
{
};

void() s_explode4 = [ 3, s_explode5 ]
{
};

void() s_explode5 = [ 4, s_explode6 ]
{
};

void() s_explode6 = [ 5, SUB_Remove ]
{
};

void() BecomeExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = VEC_ORIGIN;
	self.touch = SUB_Null;
	setmodel(self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1();
};

void() T_MissileTouch =
{
	local float damg;

	if ((other == self.owner))
	{
		return;
	}
	if ((pointcontents(self.origin) == CONTENT_SKY))
	{
		remove(self);
		return;
	}

	damg = (MOON_WEAPON_DAMAGEPER_ROCKET_BASE + (random() * MOON_WEAPON_DAMAGEPER_ROCKET_RANDOM));
	if (other.health)
	{
		if ((other.classname == "monster_shambler"))
		{
			damg = (damg * 0.5);
		}
		T_Damage(other, self, self.owner, damg);
	}

	T_RadiusDamage(self, self.owner, MOON_WEAPON_DAMAGEPER_SPLASH, other);
	self.origin = (self.origin - (KEY_MOVERIGHT * normalize(self.velocity)));
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	self.classname = "exploded";
	BecomeExplosion();
};

void() W_FireRocket =
{
	local entity missile;

	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
	self.ammo_rockets = (self.ammo_rockets - MOON_WEAPON_ROCKETLAUNCHER_SALVO_SIZE);
	self.currentammo = self.ammo_rockets; // Fixed
	self.punchangle_x = CONTENT_SOLID;
	missile = spawn();
	missile.owner = self;
	traceline((self.origin + '0 0 16'), (('0 0 16' + self.origin) + (v_forward * 2048)), FALSE, self);
	ExplodeAlert(missile, trace_endpos);
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
	makevectors(self.v_angle);
	missile.velocity = aim(self, 1000);
	missile.avelocity = '0 0 200';
	missile.velocity = (missile.velocity * 900);
	missile.angles = vectoangles(missile.velocity);
	missile.touch = T_MissileTouch;
	missile.nextthink = (time + SVC_SETVIEWPORT);
	missile.think = SUB_Remove;
	setmodel(missile, "progs/missile.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, ((self.origin + (v_forward * KEY_MOVERIGHT)) + '0 0 16'));
};

void(vector source, vector destination, entity target, entity attacker, entity inflictor, float damage) LightningDamageSparks =
{
	local entity target_second;
	local vector f;

	// WTF Black magic
	f = (destination - source);
	normalize(f);
	f_x = (0 - f_y);
	f_y = f_x;
	f_z = 0;
	f = (f * 16);
	// end of WTF Black magic

	traceline((source + f), (destination + f), CONST_QC_COLLISION_WITH_EVERYTHING, inflictor);
	target_second = trace_ent;
	if ( (trace_ent != target) && (trace_ent.takedamage) )
	{
		particle(trace_endpos, '0 0 100', 225, (damage * 4));
		T_Damage(trace_ent, inflictor, attacker, damage);
	}

	traceline((source - f), (destination - f), CONST_QC_COLLISION_WITH_EVERYTHING, inflictor);
	if ( (trace_ent != target) && (trace_ent != target_second) && (trace_ent.takedamage) )
	{
		particle(trace_endpos, '0 0 100', 225, (damage * 4));
		T_Damage(trace_ent, inflictor, attacker, damage);
	}
};

entity(vector source, vector destination, entity attacker, entity inflictor, float damage, float bolt_type, float piercing_strength = 0) moon_trace_lightning_bolt =
{
	local entity object_hit;

	if ( attacker.t_width < time )
	{
		sound(attacker, CHAN_WEAPON, "weapons/lhit.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
		attacker.t_width = (time + 0.6);
	}

	traceline(source, destination, CONST_QC_COLLISION_WITH_MONSTER_WIDE, inflictor);
	object_hit = trace_ent;

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, bolt_type);
	WriteEntity(MSG_BROADCAST, inflictor);
	WriteCoord(MSG_BROADCAST, source_x);
	WriteCoord(MSG_BROADCAST, source_y);
	WriteCoord(MSG_BROADCAST, source_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);

	if (trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, (damage * 4));
		T_Damage(trace_ent, attacker, attacker, damage);
		if ( (attacker.classname == MOON_PLAYER_CLASSNAME) && (trace_ent.classname == MOON_PLAYER_CLASSNAME) )
		{
			trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}

	if ( piercing_strength > 0 )
	{
		LightningDamageSparks(source, trace_endpos + (v_forward * piercing_strength), object_hit, attacker, attacker, damage);
	}

	return object_hit;
};

entity(vector source, vector destination, entity attacker) moon_trace_lightning_bolt_shambler =
{
	return moon_trace_lightning_bolt(source, destination, attacker, attacker, MOON_WEAPON_DAMAGEPER_SHAMBLERSHOT, TE_LIGHTNING1, MOON_WEAPON_PIERCING_LIGHTNING_NONE);
};

entity(vector source, vector destination, entity attacker, entity inflictor, float piercing_strength = 0) moon_trace_lightning_bolt_shaft =
{
	return moon_trace_lightning_bolt(source, destination, attacker, inflictor, MOON_WEAPON_DAMAGEPER_CELL, TE_LIGHTNING2, piercing_strength);
};

void(entity attacker, entity target, float max_distance, float jump_count = 0) moon_trace_lightning_bolt_chain =
{
	local entity head;
	local entity target_next;
	local entity target_alternative;
	local entity target_desperate;
	local float temp_dist;
	local float min_dist_enemy;
	local float min_dist_friend;
	local float min_dist_heart;

	attacker.lightning_chained_time = time + MOON_ITEM_CELLUP_EFFECT_CHAIN_COOLDOWN; // just to not bounce back to unsuspecting player
	target.lightning_chained_time = time + MOON_ITEM_CELLUP_EFFECT_CHAIN_COOLDOWN;

	if ( jump_count <= 0 )
	{
		// dprint("ChainLightning: {0} used all jumps\n", target.netname);
		return;
	}

	target_next = world;
	target_alternative = world;
	target_desperate = world;

	min_dist_enemy = max_distance;
	min_dist_friend = max_distance;
	min_dist_heart = max_distance;
	head = findradius(target.origin, max_distance);
	while (head)
	{
		if ( (!head.takedamage) || (head.health <= 0) || (time < head.lightning_chained_time) )
		{
			head = head.chain;
			continue;
		}
		if (!moon_can_trace_object(target, head) )
		{
			head = head.chain;
			continue;
		}

		temp_dist = vlen(head.origin - target.origin);

		if ( (head.flags & FL_MONSTER) || (head.classname == MOON_MONSTER_CLASSNAME) )
		{
			if (min_dist_enemy > temp_dist)
			{
				min_dist_enemy = temp_dist;
				target_next = head;
			}
		}

		if ( (head.classname == MOON_GUARD_CLASSNAME) || (head.classname == MOON_PLAYER_CLASSNAME) )
		{
			if (min_dist_friend > temp_dist)
			{
				min_dist_friend = temp_dist;
				target_alternative = head;
			}
		}

		if ( (head.classname == MOON_HEART_CLASSNAME) )
		{
			if (min_dist_heart > temp_dist)
			{
				min_dist_heart = temp_dist;
				target_desperate = head;
			}
		}

		head = head.chain;
	}

	if (target_next == world)
	{
		target_next = target_alternative;
	}
	if (target_next == world)
	{
		target_next = target_desperate;
	}
	if (target_next == world)
	{
		// dprint("ChainLightning: no body around\n");
		return;
	}
	// dprint("ChainLightning: {0} zaps {1}, jumps left {2}\n", target.netname, target_next.netname, floor_ftos(jump_count-1));

	moon_trace_lightning_bolt_shaft(target.origin, ((target_next.absmin + target_next.absmax) * 0.5), attacker, target, MOON_WEAPON_PIERCING_LIGHTNING_NONE); // do actual damage

	moon_trace_lightning_bolt_chain(attacker, target_next, (max_distance/2), (jump_count-1)); // Recursive dive
};

void() W_FireLightning =
{
	local vector org;
	local float cells;
	local float distance;
	local entity target_hit;

	if ( self.ammo_cells < MOON_WEAPON_LIGHTNING_SALVO_SIZE )
	{
		moon_swap_target_to_best_weapon(self);
		return;
	}

	if ( self.waterlevel > 1 )
	{
		cells = self.ammo_cells;
		self.ammo_cells = 0;
		moon_set_target_currentammo(self);
		T_RadiusDamage(self, self, (MOON_WEAPON_DAMAGEPER_CELL_DISCHARGE * cells), world);
		return;
	}

	self.punchangle_x = CONTENT_SOLID;
	self.ammo_cells = (self.ammo_cells - MOON_WEAPON_LIGHTNING_SALVO_SIZE);
	self.currentammo = self.ammo_cells; // Fixed

	org = (self.origin + '0 0 16');

	if ( self.mentat_attackspeed_time > time )
	{
		distance = MOON_WEAPON_DISTANCE_LIGHTNING + MOON_MENTAT_SPEED_VALUE_LIGHTNING;
	} else {
		distance = MOON_WEAPON_DISTANCE_LIGHTNING;
	}

	target_hit = moon_trace_lightning_bolt_shaft(org, (org + ( v_forward * distance )), self, self, MOON_WEAPON_PIERCING_LIGHTNING_SOME);

	if ( (self.up_cell >= MOON_CONST_UNLOCKED) && (target_hit != world) && (target_hit.takedamage) )
	{
		moon_trace_lightning_bolt_chain(self, target_hit, MOON_ITEM_CELLUP_EFFECT_CHAIN_DISTANCE, MOON_ITEM_CELLUP_EFFECT_CHAIN_JUMPS);
	}
};

void() GrenadeExplode =
{
	T_RadiusDamage(self, self.owner, MOON_WEAPON_DAMAGEPER_SPLASH, world);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	BecomeExplosion();
};

void() GrenadeTouch =
{
	if ((other == self.owner))
	{
		return;
	}
	if ((other.takedamage == DAMAGE_AIM))
	{
		GrenadeExplode();
		return;
	}
	sound(self, CHAN_WEAPON, "weapons/bounce.wav", CHSCAM_ON, ATTN_NORM);
	if ((self.velocity == VEC_ORIGIN))
	{
		self.avelocity = VEC_ORIGIN;
	}
};

void() W_FireGrenade =
{
	local entity missile;

	self.ammo_rockets = (self.ammo_rockets - MOON_WEAPON_GRENADELAUNCHER_SALVO_SIZE);
	self.currentammo = self.ammo_rockets; // Fixed
	sound(self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);
	self.punchangle_x = CONTENT_SOLID;
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
	makevectors(self.v_angle);
	if (self.v_angle_x)
	{
		missile.velocity = ((((v_forward * 600) + (v_up * 200)) + ((crandom() * v_right) * SVC_SETVIEWANGLES)) + ((crandom() * v_up) * SVC_SETVIEWANGLES));
	} else {
		missile.velocity = aim(self, 10000);
		missile.velocity = (missile.velocity * 600);
		missile.velocity_z = 200;
	}
	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = GrenadeTouch;
	missile.nextthink = (time + 2.5);
	missile.think = GrenadeExplode;
	setmodel(missile, "progs/grenade.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, self.origin);
};
void() spike_touch;
void() superspike_touch;

void(vector org, vector dir) launch_spike =
{
	local float spds;

	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.angles = vectoangles(dir);
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = (time + LOGIC_HUNTENEMY);
	setmodel(newmis, "progs/spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, org);
	spds = MOON_WEAPON_PROJECTILESPEED_NAIL;
	if ( self.mentat_attackspeed_time > time )
	{
		spds = (spds + MOON_MENTAT_SPEED_VALUE_NAILGUN);
	}
	if ( self.up_nail >= MOON_CONST_UNLOCKED )
	{
		spds = (spds + MOON_ITEM_NAILUP_EFFECT_BONUS);
	}
	newmis.velocity = (dir * spds);
};

void(vector org, vector dir) launch_sspike =
{
	local float spds;

	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.angles = vectoangles(dir);
	newmis.touch = superspike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = (time + LOGIC_HUNTENEMY);
	if ((self.black_spike == CHSCAM_ON))
	{
		setmodel(newmis, "progs/s_spikeb.mdl");
		newmis.black_spike = CHSCAM_ON;
	} else {
		setmodel(newmis, "progs/s_spike.mdl");
	}
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, org);
	spds = MOON_WEAPON_PROJECTILESPEED_NAIL;
	if ( self.mentat_attackspeed_time > time )
	{
		spds = (spds + MOON_MENTAT_SPEED_VALUE_NAILGUN);
	}
	if ( self.up_nail >= MOON_CONST_UNLOCKED )
	{
		spds = (spds + MOON_ITEM_NAILUP_EFFECT_BONUS);
	}
	newmis.velocity = (dir * spds);
};

void() W_FireSuperSpikes =
{
	local vector dir;

	sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = (time + MOON_WEAPON_SUPERNAILGUN_COOLDOWN);
	self.ammo_nails = (self.ammo_nails - MOON_WEAPON_SUPERNAILGUN_SALVO_SIZE);
	self.currentammo = self.ammo_nails; // Fixed
	dir = aim(self, 1000);
	launch_sspike((self.origin + '0 0 16'), dir);
	self.punchangle_x = CONTENT_SOLID;
};

void(float ox) W_FireSpikes =
{
	local vector dir;

	makevectors(self.v_angle);
	if (((self.ammo_nails >= MOON_WEAPON_SUPERNAILGUN_SALVO_SIZE) && (self.weapon == IT_SUPER_NAILGUN)))
	{
		W_FireSuperSpikes();
		return;
	}
	if ((self.ammo_nails < MOON_WEAPON_NAILGUN_SALVO_SIZE))
	{
		moon_swap_target_to_best_weapon(self);
		return;
	}

	sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = (time + MOON_WEAPON_NAILGUN_COOLDOWN);
	self.ammo_nails = (self.ammo_nails - MOON_WEAPON_NAILGUN_SALVO_SIZE);
	self.currentammo = self.ammo_nails; // Fixed
	dir = aim(self, 1000);
	launch_spike(((self.origin + '0 0 16') + (v_right * ox)), dir);
	self.punchangle_x = CONTENT_SOLID;
};
.float hit_z;

void() spike_touch =
{
	if ((other == self.owner))
	{
		return;
	}
	if ((other.solid == SOLID_TRIGGER))
	{
		return;
	}
	if ((pointcontents(self.origin) == CONTENT_SKY))
	{
		remove(self);
		return;
	}
	if (other.takedamage)
	{
		spawn_touchblood(MOON_WEAPON_DAMAGEPER_NAIL);
		T_Damage(other, self, self.owner, MOON_WEAPON_DAMAGEPER_NAIL);
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		if ((self.classname == "wizspike"))
		{
			WriteByte(MSG_BROADCAST, TE_WIZSPIKE);
		}
		else
		{
			if ((self.classname == "knightspike"))
			{
				WriteByte(MSG_BROADCAST, TE_KNIGHTSPIKE);
			}
			else
			{
				WriteByte(MSG_BROADCAST, TE_SPIKE);
			}
		}
		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
	}
	remove(self);
};

void() superspike_touch =
{
	//local float rand; // unused
	local vector dir;

	if ((other == self.owner))
	{
		return;
	}
	if ((other.solid == SOLID_TRIGGER))
	{
		return;
	}
	if ((pointcontents(self.origin) == CONTENT_SKY))
	{
		remove(self);
		return;
	}
	if (other.takedamage)
	{
		spawn_touchblood(MOON_WEAPON_DAMAGEPER_SUPERNAIL);
		T_Damage(other, self, self.owner, MOON_WEAPON_DAMAGEPER_SUPERNAIL);
		if ((self.black_spike == CHSCAM_ON))
		{
			dir = (other.origin - (self.origin * MON_BACKTIME));
			dir = normalize(dir);
			if ((other.flags & FL_ONGROUND))
			{
				if ((other.flags & FL_CLIENT))
				{
					other.flags = (other.flags - FL_ONGROUND);
				}
			}
			other.velocity = (other.velocity + (dir * 250));
		}
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
	}
	remove(self);
};

void() W_SetCurrentAmmo =
{
	player_run();
	self.items = (self.items - (self.items & (((IT_SHELLS | IT_NAILS) | IT_ROCKETS) | IT_CELLS)));

	switch(self.weapon)
	{
	case IT_AXE:
		self.currentammo = 0;
		self.weaponmodel = MOON_WEAPON_AXE_MODEL_FPV;
		self.weaponframe = WF_NORMAL;
		break;
	case IT_SHOTGUN:
		self.currentammo = self.ammo_shells;
		self.weaponmodel = MOON_WEAPON_SHOTGUN_MODEL_FPV;
		self.weaponframe = WF_NORMAL;
		self.items = (self.items | IT_SHELLS);
		break;
	case IT_SUPER_SHOTGUN:
		self.currentammo = self.ammo_shells;
		self.weaponmodel = MOON_WEAPON_SUPERSHOTGUN_MODEL_FPV;
		self.weaponframe = WF_NORMAL;
		self.items = (self.items | IT_SHELLS);
		break;
	case IT_NAILGUN:
		self.currentammo = self.ammo_nails;
		self.weaponmodel = MOON_WEAPON_NAILGUN_MODEL_FPV;
		self.weaponframe = WF_NORMAL;
		self.items = (self.items | IT_NAILS);
		break;
	case IT_SUPER_NAILGUN:
		self.currentammo = self.ammo_nails;
		self.weaponmodel = MOON_WEAPON_SUPERNAILGUN_MODEL_FPV;
		self.weaponframe = WF_NORMAL;
		self.items = (self.items | IT_NAILS);
		break;
	case IT_GRENADE_LAUNCHER:
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = MOON_WEAPON_GRENADELAUNCHER_MODEL_FPV;
		self.weaponframe = WF_NORMAL;
		self.items = (self.items | IT_ROCKETS);
		break;
	case IT_ROCKET_LAUNCHER:
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = MOON_WEAPON_ROCKETLAUNCHER_MODEL_FPV;
		self.weaponframe = WF_NORMAL;
		self.items = (self.items | IT_ROCKETS);
		break;
	case IT_LIGHTNING:
		self.currentammo = self.ammo_cells;
		self.weaponmodel = MOON_WEAPON_LIGHTNING_MODEL_FPV;
		self.weaponframe = WF_NORMAL;
		self.items = (self.items | IT_CELLS);
		break;
	default:
		self.currentammo = 0;
		self.weaponmodel = string_null;
		self.weaponframe = WF_NORMAL;
	}

	if ( self.speed & CHSCAM_ON )
	{
		self.weaponmodel = string_null;
	}
};

float(float weapon, float ammo) W_EnoughAmmoToShoot =
{
	switch(weapon)
	{
	case IT_AXE:
		return (TRUE);
	case IT_SHOTGUN:
		return ((ammo >= 1) ? TRUE : FALSE);
	case IT_SUPER_SHOTGUN:
		return ((ammo >= 2) ? TRUE : FALSE);
	case IT_NAILGUN:
		return ((ammo >= 1) ? TRUE : FALSE);
	case IT_SUPER_NAILGUN:
		return ((ammo >= 2) ? TRUE : FALSE);
	case IT_GRENADE_LAUNCHER:
		return ((ammo >= 1) ? TRUE : FALSE);
	case IT_ROCKET_LAUNCHER:
		return ((ammo >= 1) ? TRUE : FALSE);
	case IT_LIGHTNING:
		return ((ammo >= 1) ? TRUE : FALSE);
	default:
		return (FALSE);
	}
};

float() W_BestWeapon =
{
	local float it;

	it = self.items;
	if ( (self.waterlevel <= 1) && (it & IT_LIGHTNING) && (W_EnoughAmmoToShoot(IT_LIGHTNING, self.ammo_cells)) )
	{
		return (IT_LIGHTNING);
	}
	if ( (it & IT_SUPER_NAILGUN) && W_EnoughAmmoToShoot(IT_SUPER_NAILGUN, self.ammo_nails) )
	{
		return (IT_SUPER_NAILGUN);
	}
	if ( (it & IT_SUPER_SHOTGUN) && W_EnoughAmmoToShoot(IT_SUPER_SHOTGUN, self.ammo_shells) )
	{
		return (IT_SUPER_SHOTGUN);
	}
	if ( (it & IT_NAILGUN) && W_EnoughAmmoToShoot(IT_NAILGUN, self.ammo_nails))
	{
		return (IT_NAILGUN);
	}
	if ( (it & IT_SHOTGUN) && W_EnoughAmmoToShoot(IT_SHOTGUN, self.ammo_shells) )
	{
		return (IT_SHOTGUN);
	}
	return (IT_AXE);
};

float() W_CheckNoAmmo =
{
	if ( self.currentammo > 0 )
	{
		return TRUE;
	}
	if ( self.weapon == IT_AXE )
	{
		return TRUE;
	}

	moon_swap_target_to_best_weapon(self);
	if ( self.currentammo <= 0 )
	{
		moon_swap_target_to_best_weapon(self, TRUE);
	}

	return FALSE;
};

void() player_axe1;
void() player_axeb1;
void() player_axec1;
void() player_axed1;
void() player_shot1;
void() player_nail1;
void() player_light1;
void() player_rocket1;

void() W_Attack = // Player attack handling
{
	local float r;
	local float delay;

	if (!W_CheckNoAmmo())
	{
		return;
	}
	makevectors(self.v_angle);
	self.show_hostile = (time + 1);

	switch(self.weapon)
	{
	case IT_AXE:
		sound(self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		r = random();
		if ( r < 0.25 )
		{
			player_axe1();
		} else
		if ( r < 0.5 )
		{
			player_axeb1();
		} else
		if ( r < 0.75 )
		{
			player_axec1();
		} else {
			player_axed1();
		}

		delay = MOON_WEAPON_AXE_COOLDOWN;
		if ( self.mentat_attackspeed_time > time )
		{
			delay = delay * MOON_MENTAT_SPEED_VALUE_AXE;
		}
		break;
	case IT_SHOTGUN:
		player_shot1();
		W_FireShotgun();

		delay = MOON_WEAPON_SHOTGUN_COOLDOWN;
		if ( self.mentat_attackspeed_time > time )
		{
			delay = delay * MOON_MENTAT_SPEED_VALUE_SHOTGUN;
		}
		break;
	case IT_SUPER_SHOTGUN:
		player_shot1();
		W_FireSuperShotgun();

		delay = MOON_WEAPON_SUPERSHOTGUN_COOLDOWN;
		if ( self.mentat_attackspeed_time > time )
		{
			delay = delay * MOON_MENTAT_SPEED_VALUE_SUPERSHOTGUN;
		}
		break;
	case IT_NAILGUN:
		player_nail1();
		delay = MOON_WEAPON_NAILGUN_COOLDOWN;
		break;
	case IT_SUPER_NAILGUN:
		player_nail1();
		delay = MOON_WEAPON_SUPERNAILGUN_COOLDOWN;
		break;
	case IT_GRENADE_LAUNCHER:
		player_rocket1();
		W_FireGrenade();

		delay = MOON_WEAPON_GRENADELAUNCHER_COOLDOWN;
		if ( self.mentat_attackspeed_time > time )
		{
			delay = delay * MOON_MENTAT_SPEED_VALUE_GRENADELAUNCHER;
		}
		if ( self.up_rocket >= MOON_CONST_UNLOCKED )
		{
			delay = delay * MOON_ITEM_ROCKUP_EFFECT_BONUS;
		}
		break;
	case IT_ROCKET_LAUNCHER:
		player_rocket1();
		W_FireRocket();

		delay = MOON_WEAPON_ROCKETLAUNCHER_COOLDOWN;
		if ( self.mentat_attackspeed_time > time )
		{
			delay = delay * MOON_MENTAT_SPEED_VALUE_ROCKETLAUNCHER;
		}
		if ( self.up_rocket >= MOON_CONST_UNLOCKED )
		{
			delay = delay * MOON_ITEM_ROCKUP_EFFECT_BONUS;
		}
		break;
	case IT_LIGHTNING:
		player_light1();
		sound(self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
		delay = MOON_WEAPON_LIGHTNING_COOLDOWN;
		break;
	default:
		delay = 0;
	}

	self.attack_finished = time + delay;
};

void() W_ChangeWeapon =
{
	local float no_ammo;
	local float fl;

	no_ammo = FALSE;
	switch(self.impulse)
	{
	case QC_IMPULSE_CODE_WEAPON_AXE:
		fl = IT_AXE;
		break;
	case QC_IMPULSE_CODE_WEAPON_SHOTGUN:
		fl = IT_SHOTGUN;
		if ( self.ammo_shells < MOON_WEAPON_SHOTGUN_SALVO_SIZE )
		{
			no_ammo = TRUE;
		}
		break;
	case QC_IMPULSE_CODE_WEAPON_SUPER_SHOTGUN:
		fl = IT_SUPER_SHOTGUN;
		if ( self.ammo_shells < MOON_WEAPON_SUPERSHOTGUN_SALVO_SIZE )
		{
			no_ammo = TRUE;
		}
		break;
	case QC_IMPULSE_CODE_WEAPON_NAILGUN:
		fl = IT_NAILGUN;
		if ( self.ammo_nails < MOON_WEAPON_NAILGUN_SALVO_SIZE )
		{
			no_ammo = TRUE;
		}
		break;
	case QC_IMPULSE_CODE_WEAPON_SUPER_NAILGUN:
		fl = IT_SUPER_NAILGUN;
		if ( self.ammo_nails < MOON_WEAPON_SUPERNAILGUN_SALVO_SIZE )
		{
			no_ammo = TRUE;
		}
		break;
	case QC_IMPULSE_CODE_WEAPON_GRENADE_LAUNCHER:
		fl = IT_GRENADE_LAUNCHER;
		if ( self.ammo_rockets < MOON_WEAPON_GRENADELAUNCHER_SALVO_SIZE )
		{
			no_ammo = TRUE;
		}
		break;
	case QC_IMPULSE_CODE_WEAPON_ROCKET_LAUNCHER:
		fl = IT_ROCKET_LAUNCHER;
		if ( self.ammo_rockets < MOON_WEAPON_ROCKETLAUNCHER_SALVO_SIZE )
		{
			no_ammo = TRUE;
		}
		break;
	case QC_IMPULSE_CODE_WEAPON_LIGHTNING:
		fl = IT_LIGHTNING;
		if ( self.ammo_cells < MOON_WEAPON_LIGHTNING_SALVO_SIZE )
		{
			no_ammo = TRUE;
		}
		break;
	}

	self.impulse = QC_IMPULSE_CODE_NOOP;
	if (!(self.items & fl))
	{
		sprint(self, "no weapon.\n");
		return;
	}

	if (no_ammo)
	{
		sprint(self, "not enough ammo.\n");
		return;
	}

	moon_select_target_weapon(self, fl);
};

void() CheatCommand =
{
	if ((deathmatch || coop))
	{
		return;
	}
	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.ammo_cells = 200;
	self.items = (((((((self.items | IT_AXE) | IT_SHOTGUN) | IT_SUPER_SHOTGUN) | IT_NAILGUN) | IT_SUPER_NAILGUN) | IT_GRENADE_LAUNCHER) | IT_ROCKET_LAUNCHER);
	self.items = (self.items | IT_LIGHTNING);
	self.weapon = IT_ROCKET_LAUNCHER;
	self.impulse = 0;
	W_SetCurrentAmmo();
};

void() CycleWeaponCommand =
{
	local float it;
	local float current_weapon;
	local float no_ammo;

	self.impulse = QC_IMPULSE_CODE_NOOP;

	it = self.items;
	current_weapon = self.weapon;
	while (TRUE)
	{
		no_ammo = FALSE;
		switch(current_weapon)
		{
		case IT_AXE:
			current_weapon = IT_SHOTGUN;
			if ( self.ammo_shells < MOON_WEAPON_SHOTGUN_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		case IT_SHOTGUN:
			current_weapon = IT_SUPER_SHOTGUN;
			if ( self.ammo_shells < MOON_WEAPON_SUPERSHOTGUN_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		case IT_SUPER_SHOTGUN:
			current_weapon = IT_NAILGUN;
			if ( self.ammo_nails < MOON_WEAPON_NAILGUN_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		case IT_NAILGUN:
			current_weapon = IT_SUPER_NAILGUN;
			if ( self.ammo_nails < MOON_WEAPON_SUPERNAILGUN_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		case IT_SUPER_NAILGUN:
			current_weapon = IT_GRENADE_LAUNCHER;
			if ( self.ammo_rockets < MOON_WEAPON_GRENADELAUNCHER_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		case IT_GRENADE_LAUNCHER:
			current_weapon = IT_ROCKET_LAUNCHER;
			if ( self.ammo_rockets < MOON_WEAPON_ROCKETLAUNCHER_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		case IT_ROCKET_LAUNCHER:
			current_weapon = IT_LIGHTNING;
			if ( self.ammo_cells < MOON_WEAPON_LIGHTNING_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		case IT_LIGHTNING:
			current_weapon = IT_AXE;
			break;
		}

		if (current_weapon == self.weapon) // for future when AXE would be available
		{
			return;
		}

		if ( (it & current_weapon) && (no_ammo == FALSE) ) // this will work at least once, if AXE in inventory
		{
			moon_select_target_weapon(self, current_weapon);
			return;
		}
	}
};

void() CycleWeaponReverseCommand =
{
	local float it;
	local float current_weapon;
	local float no_ammo;

	self.impulse = QC_IMPULSE_CODE_NOOP;

	it = self.items;
	current_weapon = self.weapon;
	while (TRUE)
	{
		no_ammo = FALSE;
		switch(current_weapon)
		{
		case IT_AXE:
			current_weapon = IT_LIGHTNING;
			if ( self.ammo_cells < MOON_WEAPON_LIGHTNING_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		case IT_SHOTGUN:
			current_weapon = IT_AXE;
			break;
		case IT_SUPER_SHOTGUN:
			current_weapon = IT_SHOTGUN;
			if ( self.ammo_shells < MOON_WEAPON_SHOTGUN_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		case IT_NAILGUN:
			current_weapon = IT_SUPER_SHOTGUN;
			if ( self.ammo_shells < MOON_WEAPON_SUPERSHOTGUN_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		case IT_SUPER_NAILGUN:
			current_weapon = IT_NAILGUN;
			if ( self.ammo_nails < MOON_WEAPON_NAILGUN_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		case IT_GRENADE_LAUNCHER:
			current_weapon = IT_SUPER_NAILGUN;
			if ( self.ammo_nails < MOON_WEAPON_SUPERNAILGUN_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		case IT_ROCKET_LAUNCHER:
			current_weapon = IT_GRENADE_LAUNCHER;
			if ( self.ammo_rockets < MOON_WEAPON_GRENADELAUNCHER_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		case IT_LIGHTNING:
			current_weapon = IT_ROCKET_LAUNCHER;
			if ( self.ammo_rockets < MOON_WEAPON_ROCKETLAUNCHER_SALVO_SIZE )
			{
				no_ammo = TRUE;
			}
			break;
		}

		if (current_weapon == self.weapon) // for future when AXE would be available
		{
			return;
		}

		if ( (it & current_weapon) && (no_ammo == FALSE) ) // this will work at least once, if AXE in inventory
		{
			moon_select_target_weapon(self, current_weapon);
			return;
		}
	}
};

void() ServerflagsCommand = // WTF?!
{
	if ((deathmatch || coop))
	{
		return;
	}
	serverflags = ((serverflags * 2) + 1);
};

void() ImpulseCommands =
{
	if ( (self.impulse >= QC_IMPULSE_CODE_WEAPON_AXE) && (self.impulse <= QC_IMPULSE_CODE_WEAPON_LIGHTNING) )
	{
		W_ChangeWeapon();
	} else
	if ((self.impulse == QC_IMPULSE_CODE_CHEAT_COMMAND))
	{
		CheatCommand();
	} else
	if ((self.impulse == QC_IMPULSE_CODE_CYCLE_WEAPON_FORTH))
	{
		CycleWeaponCommand();
	} else
	if ((self.impulse == QC_IMPULSE_CODE_SERVER_FLAGS))
	{
		ServerflagsCommand();
	} else
	if ((self.impulse == QC_IMPULSE_CODE_CYCLE_WEAPON_BACK))
	{
		CycleWeaponReverseCommand();
	} else {
		moon_handle_impulse();
	}

	self.impulse = QC_IMPULSE_CODE_NOOP;
};

void() W_WeaponFrame =
{
	if ( time < self.attack_finished )
	{
		return;
	}

	if ( self.impulse == QC_IMPULSE_CODE_NOOP )
	{
		moon_handle_impulse_noop();
	} else {
		ImpulseCommands();
	}

	if ( self.button0 )
	{
		SuperDamageSound();
		W_Attack();
	}
};

void() SuperDamageSound =
{
	if ( self.super_damage_finished > time )
	{
		if ( self.super_sound < time )
		{
			self.super_sound = (time + 1);
			sound(self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
};

vector(vector dir) ModAcc =
{
	if ( self.acc >= 3 )
	{
		return (dir);
	}
	dir = (dir + (((3 - self.acc) * random_nzc()) * '0.06 0 0'));
	dir = (dir + (((3 - self.acc) * random_nzc()) * '0 0.06 0'));
	return (dir);
};

void() M_FireGrenade =
{
	local entity missile;
	local vector vec;
	local vector src;
	local vector org;
	local vector d;
	local float t;
	local float zvel;
	local float zminus;

	self.shootframe = TRUE;
	self.walkframe = WF_NORMAL;
	self.effects = (self.effects | EF_MUZZLEFLASH);
	sound(self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);
	self.misspeed = 600;
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
	makevectors(self.angles);

	src = ((self.origin + (v_right * -8)) + '0 0 16');
	org = self.enemy.origin;
	if ( self.classname == MOON_GUARD_CLASSNAME )
	{
		src = (self.origin + '0 0 16');
		if ((self.enemy.classname == "spider"))
		{
			org = (self.enemy.origin - '0 0 16');
		}
	}

	if ((vlen(self.enemy.velocity) <= 160))
	{
		vlen((org - src));
		t = (vlen((org - src)) / (self.misspeed * H_MEGA));
	} else {
		t = (vlen((org - src)) / self.misspeed);
	}

	vec = self.enemy.velocity;
	vec_z = WF_NORMAL;
	d = (org + (t * vec));
	vec = (d - src);
	vec = ModAcc(vec);
	missile.velocity = normalize(vec);
	missile.velocity = (missile.velocity * self.misspeed);
	zminus = vlen((org - src));
	zminus = (zminus / 300);
	zvel = (org_z - src_z);
	missile.velocity_z = (200 + ((zvel * 2.2) / zminus));
	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = GrenadeTouch;
	missile.dmg = self.dmg;
	missile.nextthink = (time + 2.5);
	missile.think = GrenadeExplode;
	setmodel(missile, "progs/grenade.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, src);
	self.attack_finished = ((time + 0.7) + self.rfr);
	if ( self.ability == 1 )
	{
		SuperDamageSound();
	}
};

void() HomingMissile =
{
	local vector dir;
	local vector vtemp;

	if (((self.enemy.classname == MOON_HEART_CLASSNAME) || (self.enemy.classname == "shoot_ent")))
	{
		vtemp = self.enemy.origin;
	}
	else
	{
		if ((vlen((self.enemy.origin - self.origin)) < 160))
		{
			vtemp = (self.enemy.origin + '0 0 -28');
		}
		else
		{
			vtemp = (self.enemy.origin + '0 0 5');
		}
	}
	if ( self.enemy.health < 1 )
	{
		T_MissileTouch();
		return;
	}
	dir = ModAcc(dir);
	dir = normalize((vtemp - self.origin));
	self.velocity = (dir * 800);
	self.angles = vectoangles(self.velocity);
	self.nextthink = (time + 0.1);
	self.think = HomingMissile;
};

void() M_FireHomeMissile =
{
	local entity missile;
	local vector dir;
	local float dist;

	dir = normalize(((self.enemy.origin + '0 0 10') - self.origin));
	dist = vlen((self.enemy.origin - self.origin));
	self.effects = (self.effects | EF_MUZZLEFLASH);
	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
	if ( self.ability == 1 )
	{
		SuperDamageSound();
	}
	missile = spawn();
	missile.owner = self;
	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setmodel(missile, "progs/missile.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	missile.origin = ((self.origin + '0 0 16') + (v_forward * 8));
	missile.velocity = (dir * 1000);
	missile.angles = vectoangles(missile.velocity);
	missile.avelocity = VEC_ORIGIN;
	missile.nextthink = (time + 0.1);
	missile.think = HomingMissile;
	missile.enemy = self.enemy;
	missile.touch = T_MissileTouch;
	self.attack_finished = (((time + 1) + (random() / 10)) + self.rfr);
};

void() M_FireMissile =
{
	local entity missile;
	local vector org;
	local vector vec;
	local vector d;
	local vector enorg;
	local float t;
	local float zenorg;

	if (!self.misspeed)
	{
		self.misspeed = 1000;
	}
	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
	makevectors(self.v_angle);
	missile.touch = T_MissileTouch;
	missile.nextthink = (time + SVC_SETVIEWPORT);
	missile.think = SUB_Remove;
	missile.avelocity = '0 0 200';
	setmodel(missile, "progs/missile.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, ((self.origin + (v_forward * KEY_MOVERIGHT)) + '0 0 16'));
	self.effects = (self.effects | EF_MUZZLEFLASH);
	makevectors(self.angles);
	org = self.origin;
	enorg = self.enemy.origin;
	zenorg = (self.enemy.origin_z + self.enemy.mins_z);
	traceline(self.enemy.origin, (enorg - (v_up * zenorg)), FALSE, self);
	if ((trace_fraction == 1))
	{
		enorg_z = zenorg;
	}

	if ((vlen(self.enemy.velocity) <= 160))
	{
		vlen((enorg - org));
		t = (vlen((enorg - org)) / (self.misspeed * H_MEGA));
	} else {
		t = (vlen((enorg - org)) / self.misspeed);
	}
	vec = self.enemy.velocity;
	vec_z = WF_NORMAL;
	d = ((enorg + (t * vec)) + ((v_right * 12) * crandom()));
	vec = ModAcc(vec);
	vec = normalize((d - org));
	missile.velocity = (vec * self.misspeed);
	missile.angles = vectoangles(missile.velocity);
	self.attack_finished = (((time + 0.8) + (random() / SVC_SETVIEWANGLES)) + self.rfr);
	if ((self.ability == 1))
	{
		SuperDamageSound();
	}
};

void(vector org) M_FireNail =
{
	local vector vec;
	local vector d;
	local vector en;
	local float t;

	sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	en = self.enemy.origin;
	t = (vlen((en - org)) / 1000);
	vec = self.enemy.velocity;
	vec_z = WF_NORMAL;
	d = (en + (t * vec));
	if ((random() < MON_REACTIONTIME))
	{
		d = (en + ((v_right * KEY_MOVERIGHT) * crandom()));
	}
	vec = (d - org);
	vec = ModAcc(vec);
	vec = normalize(vec);

	self.attack_finished = (time + 0.1);
	if ( random() < MON_MAGICCHANCE )
	{
		self.attack_finished = ((time + 0.5) + self.rfr);
	}

	launch_spike(org, vec);
	if ((self.ability == 1))
	{
		SuperDamageSound();
	}
};

void(vector org) M_FireSuperNail =
{
	local vector vec;
	local vector d;
	local vector en;
	local float t;

	sound(self, CHAN_WEAPON, "weapons/spike2.wav", CHSCAM_ON, ATTN_NORM);
	en = self.enemy.origin;
	t = (vlen((en - org)) / 1000);
	vec = self.enemy.velocity;
	vec_z = WF_NORMAL;
	d = (en + (t * vec));
	if ((random() < MON_REACTIONTIME))
	{
		d = (en + ((v_right * KEY_MOVERIGHT) * crandom()));
	}
	vec = (d - org);
	vec = ModAcc(vec);
	vec = normalize(vec);

	self.attack_finished = (time + 0.1);
	if ( random() < MON_MAGICCHANCE )
	{
		self.attack_finished = ((time + 0.5) + self.rfr);
	}

	launch_sspike((org + '0 0 8'), vec);
	if ( self.ability == 1 )
	{
		SuperDamageSound();
	}
};

void() M_FireShotgun =
{
	local vector dir;
	local entity en;

	sound(self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);
	en = self.enemy;
	dir = (((en.origin - self.origin) - (en.velocity * 0.07)) + ((v_right * 15) * crandom()));
	dir = ModAcc(dir);
	dir = normalize(dir);
	FireBullets(4, dir, '0.1 0.1 0');
	self.attack_finished = (((time + 0.5) + (random() / SVC_SETVIEWANGLES)) + self.rfr);
	if ( self.ability == 1 )
	{
		SuperDamageSound();
	}
};

void() M_FireSuperShotgun =
{
	local vector dir;
	local entity en;

	sound(self, CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
	en = self.enemy;
	dir = (((en.origin - self.origin) - (en.velocity * 0.07)) + ((v_right * 15) * crandom()));
	dir = ModAcc(dir);
	dir = normalize(dir);
	FireBullets(14, dir, '0.14 0.08 0');
	self.attack_finished = (((time + 0.6) + (random() / SVC_SETVIEWANGLES)) + self.rfr);
	if ( self.ability == 1 )
	{
		SuperDamageSound();
	}
};

void() M_FireShaft = // W_FireLightning but for Guardian bots
{
	local vector org;
	local vector dir;

	self.effects = (self.effects | EF_MUZZLEFLASH);

	org = (self.origin + '0 0 8');
	dir = (((self.enemy.origin + '0 0 8') - org) + ((v_right * GRD_DEFENDTIME) * crandom()));
	dir = ModAcc(dir);
	dir = normalize(dir);

	moon_trace_lightning_bolt_shaft(org, (org + (dir * MOON_WEAPON_DISTANCE_LIGHTNING)), self, self, MOON_WEAPON_PIERCING_LIGHTNING_NONE);

	self.attack_finished = (time + MOON_WEAPON_LIGHTNING_COOLDOWN);
	if ((random() < 0.03))
	{
		self.attack_finished = ((time + 0.3) + self.rfr);
	}

	if ( self.ability == 1 )
	{
		SuperDamageSound();
	}
};
