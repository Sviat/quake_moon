//Decompiled code. Please respect the original copyright.
void() player_run;
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
	return ((H_MEGA * (random() - MON_BACKTIME)));
};

void() W_FireAxe =
{
	local vector source;
	local vector org;

	makevectors(self.v_angle);
	source = (self.origin + '0 0 16');
	traceline(source, (source + (v_forward * KEY_LOOKUP)), FALSE, self);
	if ((trace_fraction == CHSCAM_ON))
	{
		return;
	}
	org = (trace_endpos - (v_forward * LOGIC_DEFEND));
	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = CHSCAM_ON;
		SpawnBlood(org, VEC_ORIGIN, GRD_PATROLTIME);
		T_Damage(trace_ent, self, self, GRD_PATROLTIME);
	}
	else
	{
		sound(self, CHAN_WEAPON, "player/axhit2.wav", CHSCAM_ON, ATTN_NORM);
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
	//local entity mpuff; // unused

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;
	makevectors(self.angles);
	missile.velocity = vel;
	missile.velocity_z = ((missile.velocity_z + 250) + (50 * random()));
	missile.avelocity = '3000 1000 2000';
	missile.nextthink = (time + CHSCAM_ON);
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

	if ((other.green_blood == CHSCAM_ON))
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
	multi_damage = WF_NORMAL;
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
	if ((hit != multi_ent))
	{
		ApplyMultiDamage();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
	{
		multi_damage = (multi_damage + damage);
	}
};

void(float damage, vector dir) TraceAttack =
{
	local vector vel;
	local vector org;

	vel = normalize(((dir + (v_up * crandom())) + (v_right * crandom())));
	vel = (vel + (H_MEGA * trace_plane_normal));
	vel = (vel * 200);
	org = (trace_endpos - (dir * LOGIC_DEFEND));
	if (trace_ent.takedamage)
	{
		if ((trace_ent.green_blood == CHSCAM_ON))
		{
			SpawnPoison(org, (vel * MON_REACTIONTIME), damage);
		}
		else
		{
			SpawnBlood(org, (vel * MON_REACTIONTIME), damage);
		}
		AddMultiDamage(trace_ent, damage);
	}
	else
	{
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
	while ((shotcount > WF_NORMAL))
	{
		direction = ((dir + ((crandom() * spread_x) * v_right)) + ((crandom() * spread_y) * v_up));
		traceline(src, (src + (direction * IT_CELLS)), FALSE, self);
		if ((trace_fraction != CHSCAM_ON))
		{
			TraceAttack(LOGIC_DEFEND, direction);
		}
		shotcount = (shotcount - CHSCAM_ON);
	}
	ApplyMultiDamage();
};

void() W_FireShotgun =
{
	local vector dir;

	sound(self, CHAN_WEAPON, "weapons/guncock.wav", CHSCAM_ON, ATTN_NORM);
	self.punchangle_x = CONTENT_SOLID;
	self.ammo_shells = (self.ammo_shells - CHSCAM_ON);
	self.currentammo = (self.ammo_shells - CHSCAM_ON);
	dir = aim(self, 100000);
	if ((self.up_bullet >= 1)) // Re-use same param for both Upgrade and Extra capacity
	{
		FireBullets(TE_WIZSPIKE, dir, '0.02 0.02 0');
	}
	else
	{
		FireBullets(LOGIC_HUNTENEMY, dir, '0.04 0.04 0');
	}
};

void() W_FireSuperShotgun =
{
	local vector dir;

	if ((self.currentammo == CHSCAM_ON))
	{
		W_FireShotgun();
		return;
	}
	sound(self, CHAN_WEAPON, "weapons/shotgn2.wav", CHSCAM_ON, ATTN_NORM);
	self.punchangle_x = CONTENT_SLIME;
	self.ammo_shells = (self.ammo_shells - H_MEGA);
	self.currentammo = (self.ammo_shells - H_MEGA);
	dir = aim(self, 100000);
	if ((self.up_bullet >= 1)) // Re-use same param for both Upgrade and Extra capacity
	{
		FireBullets(KEY_MOVEFORWARD, dir, '0.06 0.04 0');
	}
	else
	{
		FireBullets(14, dir, '0.14 0.08 0');
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
	damg = (100 + (random() * GRD_PATROLTIME));
	if (other.health)
	{
		if ((other.classname == "monster_shambler"))
		{
			damg = (damg * MON_BACKTIME);
		}
		T_Damage(other, self, self.owner, damg);
	}
	T_RadiusDamage(self, self.owner, 120, other);
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
	//local entity mpuff; // unused

	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", CHSCAM_ON, ATTN_NORM);
	self.ammo_rockets = (self.ammo_rockets - CHSCAM_ON);
	self.currentammo = (self.ammo_rockets - CHSCAM_ON);
	self.punchangle_x = CONTENT_SOLID;
	missile = spawn();
	missile.owner = self;
	traceline((self.origin + '0 0 16'), (('0 0 16' + self.origin) + (v_forward * IT_CELLS)), FALSE, self);
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

void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity e1;
	local entity e2;
	local vector f;

	f = (p2 - p1);
	normalize(f);
	f_x = (WF_NORMAL - f_y);
	f_y = f_x;
	f_z = WF_NORMAL;
	f = (f * KEY_MOVEFORWARD);
	e2 = world;
	e1 = world;
	traceline(p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, (damage * LOGIC_DEFEND));
		T_Damage(trace_ent, from, from, damage);
		if ((self.classname == "player"))
		{
			if ((other.classname == "player"))
			{
				trace_ent.velocity_z = (trace_ent.velocity_z + 400);
			}
		}
	}
	e1 = trace_ent;
	traceline((p1 + f), (p2 + f), FALSE, self);
	if (((trace_ent != e1) && trace_ent.takedamage))
	{
		particle(trace_endpos, '0 0 100', 225, (damage * LOGIC_DEFEND));
		T_Damage(trace_ent, from, from, damage);
	}
	e2 = trace_ent;
	traceline((p1 - f), (p2 - f), FALSE, self);
	if ((((trace_ent != e1) && (trace_ent != e2)) && trace_ent.takedamage))
	{
		particle(trace_endpos, '0 0 100', 225, (damage * LOGIC_DEFEND));
		T_Damage(trace_ent, from, from, damage);
	}
};

void() W_FireLightning =
{
	local vector org;
	local float cells;

	if ((self.ammo_cells < CHSCAM_ON))
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		return;
	}
	if ((self.waterlevel > CHSCAM_ON))
	{
		cells = self.ammo_cells;
		self.ammo_cells = WF_NORMAL;
		W_SetCurrentAmmo();
		T_RadiusDamage(self, self, (35 * cells), world);
		return;
	}
	if ((self.t_width < time))
	{
		sound(self, CHAN_WEAPON, "weapons/lhit.wav", CHSCAM_ON, ATTN_NORM);
		self.t_width = (time + 0.6);
	}
	self.punchangle_x = CONTENT_SOLID;
	self.ammo_cells = (self.ammo_cells - CHSCAM_ON);
	self.currentammo = (self.ammo_cells - CHSCAM_ON);
	org = (self.origin + '0 0 16');
	if ((self.mentat_bonus3 == CHSCAM_ON))
	{
		traceline(org, (org + (v_forward * 800)), TRUE, self);
	}
	else
	{
		traceline(org, (org + (v_forward * 600)), TRUE, self);
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
	LightningDamage(self.origin, (trace_endpos + (v_forward * LOGIC_DEFEND)), self, MON_CAMPTIME);
};

void() GrenadeExplode =
{
	T_RadiusDamage(self, self.owner, 120, world);
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
	//local entity mpuff; // unused

	self.ammo_rockets = (self.ammo_rockets - CHSCAM_ON);
	self.currentammo = (self.ammo_rockets - CHSCAM_ON);
	sound(self, CHAN_WEAPON, "weapons/grenade.wav", CHSCAM_ON, ATTN_NORM);
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
	}
	else
	{
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
	spds = 1000;
	if ((self.mentat_bonus3 == CHSCAM_ON))
	{
		spds = (spds + GRD_FIGHTDIST);
	}
	if ((self.up_nail >= 1)) // Re-use same param for both Upgrade and Extra capacity
	{
		spds = (spds + GRD_FIGHTDIST);
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
	}
	else
	{
		setmodel(newmis, "progs/s_spike.mdl");
	}
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, org);
	spds = 1000;
	if ((self.mentat_bonus3 == CHSCAM_ON))
	{
		spds = (spds + GRD_FIGHTDIST);
	}
	if ((self.up_nail >= 1)) // Re-use same param for both Upgrade and Extra capacity
	{
		spds = (spds + GRD_FIGHTDIST);
	}
	newmis.velocity = (dir * spds);
};

void() W_FireSuperSpikes =
{
	local vector dir;
	//local entity old; // unused

	sound(self, CHAN_WEAPON, "weapons/spike2.wav", CHSCAM_ON, ATTN_NORM);
	self.attack_finished = (time + MON_REACTIONTIME);
	self.ammo_nails = (self.ammo_nails - H_MEGA);
	self.currentammo = (self.ammo_nails - H_MEGA);
	dir = aim(self, 1000);
	launch_sspike((self.origin + '0 0 16'), dir);
	self.punchangle_x = CONTENT_SOLID;
};

void(float ox) W_FireSpikes =
{
	local vector dir;
	//local entity old; // unused

	makevectors(self.v_angle);
	if (((self.ammo_nails >= H_MEGA) && (self.weapon == IT_SUPER_NAILGUN)))
	{
		W_FireSuperSpikes();
		return;
	}
	if ((self.ammo_nails < CHSCAM_ON))
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		return;
	}
	sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", CHSCAM_ON, ATTN_NORM);
	self.attack_finished = (time + MON_REACTIONTIME);
	self.ammo_nails = (self.ammo_nails - CHSCAM_ON);
	self.currentammo = (self.ammo_nails - CHSCAM_ON);
	dir = aim(self, 1000);
	launch_spike(((self.origin + '0 0 16') + (v_right * ox)), dir);
	self.punchangle_x = CONTENT_SOLID;
};
.float hit_z;

void() spike_touch =
{
	//local float rand; // unused

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
		spawn_touchblood(TE_LIGHTNING3);
		T_Damage(other, self, self.owner, TE_LIGHTNING3);
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
		spawn_touchblood(18);
		T_Damage(other, self, self.owner, 18);
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
	if ((self.weapon == IT_AXE))
	{
		self.currentammo = WF_NORMAL;
		self.weaponmodel = "progs/v_axe.mdl";
		self.weaponframe = WF_NORMAL;
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			self.currentammo = self.ammo_shells;
			self.weaponmodel = "progs/v_shot.mdl";
			self.weaponframe = WF_NORMAL;
			self.items = (self.items | IT_SHELLS);
		}
		else
		{
			if ((self.weapon == IT_SUPER_SHOTGUN))
			{
				self.currentammo = self.ammo_shells;
				self.weaponmodel = "progs/v_shot2.mdl";
				self.weaponframe = WF_NORMAL;
				self.items = (self.items | IT_SHELLS);
			}
			else
			{
				if ((self.weapon == IT_NAILGUN))
				{
					self.currentammo = self.ammo_nails;
					self.weaponmodel = "progs/v_nail.mdl";
					self.weaponframe = WF_NORMAL;
					self.items = (self.items | IT_NAILS);
				}
				else
				{
					if ((self.weapon == IT_SUPER_NAILGUN))
					{
						self.currentammo = self.ammo_nails;
						self.weaponmodel = "progs/v_nail2.mdl";
						self.weaponframe = WF_NORMAL;
						self.items = (self.items | IT_NAILS);
					}
					else
					{
						if ((self.weapon == IT_GRENADE_LAUNCHER))
						{
							self.currentammo = self.ammo_rockets;
							self.weaponmodel = "progs/v_rock.mdl";
							self.weaponframe = WF_NORMAL;
							self.items = (self.items | IT_ROCKETS);
						}
						else
						{
							if ((self.weapon == IT_ROCKET_LAUNCHER))
							{
								self.currentammo = self.ammo_rockets;
								self.weaponmodel = "progs/v_rock2.mdl";
								self.weaponframe = WF_NORMAL;
								self.items = (self.items | IT_ROCKETS);
							}
							else
							{
								if ((self.weapon == IT_LIGHTNING))
								{
									self.currentammo = self.ammo_cells;
									self.weaponmodel = "progs/v_light.mdl";
									self.weaponframe = WF_NORMAL;
									self.items = (self.items | IT_CELLS);
								}
								else
								{
									self.currentammo = WF_NORMAL;
									self.weaponmodel = s_wiz;
									self.weaponframe = WF_NORMAL;
								}
							}
						}
					}
				}
			}
		}
	}
	if ((self.speed & CHSCAM_ON))
	{
		self.weaponmodel = s_wiz;
	}
};

float() W_BestWeapon =
{
	local float it;

	it = self.items;
	if ((((self.waterlevel <= CHSCAM_ON) && (self.ammo_cells >= CHSCAM_ON)) && (it & IT_LIGHTNING)))
	{
		return (IT_LIGHTNING);
	}
	if (((self.ammo_nails >= H_MEGA) && (it & IT_SUPER_NAILGUN)))
	{
		return (IT_SUPER_NAILGUN);
	}
	if (((self.ammo_shells >= H_MEGA) && (it & IT_SUPER_SHOTGUN)))
	{
		return (IT_SUPER_SHOTGUN);
	}
	if (((self.ammo_nails >= CHSCAM_ON) && (it & IT_NAILGUN)))
	{
		return (IT_NAILGUN);
	}
	if (((self.ammo_shells >= CHSCAM_ON) && (it & IT_SHOTGUN)))
	{
		return (IT_SHOTGUN);
	}
	return (IT_AXE);
};

float() W_CheckNoAmmo =
{
	if ((self.currentammo > WF_NORMAL))
	{
		return (TRUE);
	}
	if ((self.weapon == IT_AXE))
	{
		return (TRUE);
	}
	self.weapon = W_BestWeapon();
	W_SetCurrentAmmo();
	return (FALSE);
};
void() player_axe1;
void() player_axeb1;
void() player_axec1;
void() player_axed1;
void() player_shot1;
void() player_nail1;
void() player_light1;
void() player_rocket1;

void() W_Attack =
{
	local float r;

	if (!W_CheckNoAmmo())
	{
		return;
	}
	makevectors(self.v_angle);
	self.show_hostile = (time + CHSCAM_ON);
	if ((self.weapon == IT_AXE))
	{
		sound(self, CHAN_WEAPON, "weapons/ax1.wav", CHSCAM_ON, ATTN_NORM);
		r = random();
		if ((r < 0.25))
		{
			player_axe1();
		}
		else
		{
			if ((r < MON_BACKTIME))
			{
				player_axeb1();
			}
			else
			{
				if ((r < 0.75))
				{
					player_axec1();
				}
				else
				{
					player_axed1();
				}
			}
		}
		if ((self.mentat_bonus3 == CHSCAM_ON))
		{
			self.attack_finished = (time + GRD_DEFENDCHANCE);
		}
		else
		{
			self.attack_finished = (time + MON_BACKTIME);
		}
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			player_shot1();
			W_FireShotgun();
			if ((self.mentat_bonus3 == CHSCAM_ON))
			{
				self.attack_finished = (time + GRD_DEFENDCHANCE);
			}
			else
			{
				self.attack_finished = (time + MON_BACKTIME);
			}
		}
		else
		{
			if ((self.weapon == IT_SUPER_SHOTGUN))
			{
				player_shot1();
				W_FireSuperShotgun();
				if ((self.mentat_bonus3 == CHSCAM_ON))
				{
					self.attack_finished = (time + 0.55);
				}
				else
				{
					self.attack_finished = (time + 0.7);
				}
			}
			else
			{
				if ((self.weapon == IT_NAILGUN))
				{
					player_nail1();
				}
				else
				{
					if ((self.weapon == IT_SUPER_NAILGUN))
					{
						player_nail1();
					}
					else
					{
						if ((self.weapon == IT_GRENADE_LAUNCHER))
						{
							player_rocket1();
							W_FireGrenade();
							if ((self.mentat_bonus3 == CHSCAM_ON))
							{
								self.attack_finished = (time + 0.45);
							}
							else
							{
								self.attack_finished = (time + 0.6);
							}
						}
						else
						{
							if ((self.weapon == IT_ROCKET_LAUNCHER))
							{
								player_rocket1();
								W_FireRocket();
								if ((self.mentat_bonus3 == CHSCAM_ON))
								{
									self.attack_finished = (time + 0.65);
								}
								else
								{
									self.attack_finished = (time + 0.8);
								}
							}
							else
							{
								if ((self.weapon == IT_LIGHTNING))
								{
									player_light1();
									self.attack_finished = (time + MON_CAMPERCHANCE);
									sound(self, CHAN_AUTO, "weapons/lstart.wav", CHSCAM_ON, ATTN_NORM);
								}
							}
						}
					}
				}
			}
		}
	}
};

void() W_ChangeWeapon =
{
	local float it;
	local float am;
	local float fl;

	it = self.items;
	am = 0;
	switch(self.impulse)
	{
	case 1:
		fl = IT_AXE;
		break;
	case 2:
		fl = IT_SHOTGUN;
		if ((self.ammo_shells < 1))
		{
			am = 1;
		}
		break;
	case 3:
		fl = IT_SUPER_SHOTGUN;
		if ((self.ammo_shells < 2))
		{
			am = 1;
		}
		break;
	case 4:
		fl = IT_NAILGUN;
		if ((self.ammo_nails < 1))
		{
			am = 1;
		}
		break;
	case 5:
		fl = IT_SUPER_NAILGUN;
		if ((self.ammo_nails < 2))
		{
			am = 1;
		}
		break;
	case 6:
		fl = IT_GRENADE_LAUNCHER;
		if ((self.ammo_rockets < 1))
		{
			am = 1;
		}
		break;
	case 7:
		fl = IT_ROCKET_LAUNCHER;
		if ((self.ammo_rockets < 1))
		{
			am = 1;
		}
		break;
	case 8:
		fl = IT_LIGHTNING;
		if ((self.ammo_cells < 1))
		{
			am = 1;
		}
		break;
	}

	self.impulse = 0;
	if (!(self.items & fl))
	{
		sprint(self, "no weapon.\n");
		return;
	}
	if (am)
	{
		sprint(self, "not enough ammo.\n");
		return;
	}
	self.weapon = fl;
	W_SetCurrentAmmo();
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
	self.impulse = WF_NORMAL;
	W_SetCurrentAmmo();
};

void() CycleWeaponCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = WF_NORMAL;
	while (CHSCAM_ON)
	{
		am = WF_NORMAL;
		if ((self.weapon == IT_LIGHTNING))
		{
			self.weapon = IT_AXE;
		}
		else
		{
			if ((self.weapon == IT_AXE))
			{
				self.weapon = IT_SHOTGUN;
				if ((self.ammo_shells < CHSCAM_ON))
				{
					am = CHSCAM_ON;
				}
			}
			else
			{
				if ((self.weapon == IT_SHOTGUN))
				{
					self.weapon = IT_SUPER_SHOTGUN;
					if ((self.ammo_shells < H_MEGA))
					{
						am = CHSCAM_ON;
					}
				}
				else
				{
					if ((self.weapon == IT_SUPER_SHOTGUN))
					{
						self.weapon = IT_NAILGUN;
						if ((self.ammo_nails < CHSCAM_ON))
						{
							am = CHSCAM_ON;
						}
					}
					else
					{
						if ((self.weapon == IT_NAILGUN))
						{
							self.weapon = IT_SUPER_NAILGUN;
							if ((self.ammo_nails < H_MEGA))
							{
								am = CHSCAM_ON;
							}
						}
						else
						{
							if ((self.weapon == IT_SUPER_NAILGUN))
							{
								self.weapon = IT_GRENADE_LAUNCHER;
								if ((self.ammo_rockets < CHSCAM_ON))
								{
									am = CHSCAM_ON;
								}
							}
							else
							{
								if ((self.weapon == IT_GRENADE_LAUNCHER))
								{
									self.weapon = IT_ROCKET_LAUNCHER;
									if ((self.ammo_rockets < CHSCAM_ON))
									{
										am = CHSCAM_ON;
									}
								}
								else
								{
									if ((self.weapon == IT_ROCKET_LAUNCHER))
									{
										self.weapon = IT_LIGHTNING;
										if ((self.ammo_cells < CHSCAM_ON))
										{
											am = CHSCAM_ON;
										}
									}
								}
							}
						}
					}
				}
			}
		}
		if (((it & self.weapon) && (am == WF_NORMAL)))
		{
			W_SetCurrentAmmo();
			return;
		}
	}
};

void() CycleWeaponReverseCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = WF_NORMAL;
	while (CHSCAM_ON)
	{
		am = WF_NORMAL;
		if ((self.weapon == IT_LIGHTNING))
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if ((self.ammo_rockets < CHSCAM_ON))
			{
				am = CHSCAM_ON;
			}
		}
		else
		{
			if ((self.weapon == IT_ROCKET_LAUNCHER))
			{
				self.weapon = IT_GRENADE_LAUNCHER;
				if ((self.ammo_rockets < CHSCAM_ON))
				{
					am = CHSCAM_ON;
				}
			}
			else
			{
				if ((self.weapon == IT_GRENADE_LAUNCHER))
				{
					self.weapon = IT_SUPER_NAILGUN;
					if ((self.ammo_nails < H_MEGA))
					{
						am = CHSCAM_ON;
					}
				}
				else
				{
					if ((self.weapon == IT_SUPER_NAILGUN))
					{
						self.weapon = IT_NAILGUN;
						if ((self.ammo_nails < CHSCAM_ON))
						{
							am = CHSCAM_ON;
						}
					}
					else
					{
						if ((self.weapon == IT_NAILGUN))
						{
							self.weapon = IT_SUPER_SHOTGUN;
							if ((self.ammo_shells < H_MEGA))
							{
								am = CHSCAM_ON;
							}
						}
						else
						{
							if ((self.weapon == IT_SUPER_SHOTGUN))
							{
								self.weapon = IT_SHOTGUN;
								if ((self.ammo_shells < CHSCAM_ON))
								{
									am = CHSCAM_ON;
								}
							}
							else
							{
								if ((self.weapon == IT_SHOTGUN))
								{
									self.weapon = IT_AXE;
								}
								else
								{
									if ((self.weapon == IT_AXE))
									{
										self.weapon = IT_LIGHTNING;
										if ((self.ammo_cells < CHSCAM_ON))
										{
											am = CHSCAM_ON;
										}
									}
								}
							}
						}
					}
				}
			}
		}
		if (((it & self.weapon) && (am == WF_NORMAL)))
		{
			W_SetCurrentAmmo();
			return;
		}
	}
};

void() ServerflagsCommand =
{
	serverflags = ((serverflags * 2) + 1);
};

void() ImpulseCommands =
{
	if (((self.impulse >= 1) && (self.impulse <= 8)))
	{
		W_ChangeWeapon();
	}
	if ((self.impulse == 9))
	{
		CheatCommand();
	}
	if ((self.impulse == 10))
	{
		CycleWeaponCommand();
	}
	if ((self.impulse == 11))
	{
		ServerflagsCommand();
	}
	if ((self.impulse == 12))
	{
		CycleWeaponReverseCommand();
	}
	moonimpulse();
	self.impulse = 0;
};

void() W_WeaponFrame =
{
	if ((time < self.attack_finished))
	{
		return;
	}
	ImpulseCommands();
	if (self.button0)
	{
		SuperDamageSound();
		W_Attack();
	}
};

void() SuperDamageSound =
{
	if ((self.super_damage_finished > time))
	{
		if ((self.super_sound < time))
		{
			self.super_sound = (time + CHSCAM_ON);
			sound(self, CHAN_BODY, "items/damage3.wav", CHSCAM_ON, ATTN_NORM);
		}
	}
	return;
};

vector(vector dir) ModAcc =
{
	if ((self.acc >= LOGIC_FINDDEFEND))
	{
		return (dir);
	}
	dir = (dir + (((LOGIC_FINDDEFEND - self.acc) * crandom()) * '0.06 0 0'));
	dir = (dir + (((LOGIC_FINDDEFEND - self.acc) * crandom()) * '0 0.06 0'));
	return (dir);
};

void() M_FireGrenade =
{
	local entity missile;
	//local entity mpuff; // unused
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
	sound(self, CHAN_WEAPON, "weapons/grenade.wav", CHSCAM_ON, ATTN_NORM);
	self.misspeed = 600;
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
	makevectors(self.angles);
	src = ((self.origin + (v_right * -8)) + '0 0 16');
	org = self.enemy.origin;
	if ((self.classname == "guard"))
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
	}
	else
	{
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
	if ((self.ability == CHSCAM_ON))
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
	if ((self.enemy.health < CHSCAM_ON))
	{
		T_MissileTouch();
		return;
	}
	dir = ModAcc(dir);
	dir = normalize((vtemp - self.origin));
	self.velocity = (dir * 800);
	self.angles = vectoangles(self.velocity);
	self.nextthink = (time + MON_CAMPERCHANCE);
	self.think = HomingMissile;
};

void() M_FireHomeMissile =
{
	local entity missile;
	local vector dir;
	local float dist;
	//local float flytime; // unused

	dir = normalize(((self.enemy.origin + '0 0 10') - self.origin));
	dist = vlen((self.enemy.origin - self.origin));
	self.effects = (self.effects | EF_MUZZLEFLASH);
	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", CHSCAM_ON, ATTN_NORM);
	if ((self.ability == CHSCAM_ON))
	{
		SuperDamageSound();
	}
	missile = spawn();
	missile.owner = self;
	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setmodel(missile, "progs/missile.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	missile.origin = ((self.origin + '0 0 16') + (v_forward * KEY_MOVERIGHT));
	missile.velocity = (dir * 1000);
	missile.angles = vectoangles(missile.velocity);
	missile.avelocity = VEC_ORIGIN;
	missile.nextthink = (time + MON_CAMPERCHANCE);
	missile.think = HomingMissile;
	missile.enemy = self.enemy;
	missile.touch = T_MissileTouch;
	self.attack_finished = (((time + CHSCAM_ON) + (random() / SVC_SETVIEWANGLES)) + self.rfr);
};

void() M_FireMissile =
{
	local entity missile;
	//local entity mpuff; // unused
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
	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", CHSCAM_ON, ATTN_NORM);
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
	if ((trace_fraction == CHSCAM_ON))
	{
		enorg_z = zenorg;
	}
	if ((vlen(self.enemy.velocity) <= 160))
	{
		vlen((enorg - org));
		t = (vlen((enorg - org)) / (self.misspeed * H_MEGA));
	}
	else
	{
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
	if ((self.ability == CHSCAM_ON))
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

	sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", CHSCAM_ON, ATTN_NORM);
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
	self.attack_finished = (time + MON_CAMPERCHANCE);
	if ((random() < MON_MAGICCHANCE))
	{
		self.attack_finished = ((time + MON_BACKTIME) + self.rfr);
	}
	launch_spike(org, vec);
	if ((self.ability == CHSCAM_ON))
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
	self.attack_finished = (time + MON_CAMPERCHANCE);
	if ((random() < MON_MAGICCHANCE))
	{
		self.attack_finished = ((time + MON_BACKTIME) + self.rfr);
	}
	launch_sspike((org + '0 0 8'), vec);
	if ((self.ability == CHSCAM_ON))
	{
		SuperDamageSound();
	}
};

void() M_FireShotgun =
{
	local vector dir;
	local entity en;

	sound(self, CHAN_WEAPON, "weapons/guncock.wav", CHSCAM_ON, ATTN_NORM);
	en = self.enemy;
	dir = (((en.origin - self.origin) - (en.velocity * 0.07)) + ((v_right * 15) * crandom()));
	dir = ModAcc(dir);
	dir = normalize(dir);
	FireBullets(LOGIC_DEFEND, dir, '0.1 0.1 0');
	self.attack_finished = (((time + MON_BACKTIME) + (random() / SVC_SETVIEWANGLES)) + self.rfr);
	if ((self.ability == CHSCAM_ON))
	{
		SuperDamageSound();
	}
};

void() M_FireSuperShotgun =
{
	local vector dir;
	local entity en;

	sound(self, CHAN_WEAPON, "weapons/shotgn2.wav", CHSCAM_ON, ATTN_NORM);
	en = self.enemy;
	dir = (((en.origin - self.origin) - (en.velocity * 0.07)) + ((v_right * 15) * crandom()));
	dir = ModAcc(dir);
	dir = normalize(dir);
	FireBullets(14, dir, '0.14 0.08 0');
	self.attack_finished = (((time + 0.6) + (random() / SVC_SETVIEWANGLES)) + self.rfr);
	if ((self.ability == CHSCAM_ON))
	{
		SuperDamageSound();
	}
};

void() M_FireShaft =
{
	local vector org;
	local vector dir;

	self.effects = (self.effects | EF_MUZZLEFLASH);
	if ((self.t_width < time))
	{
		sound(self, CHAN_WEAPON, "weapons/lhit.wav", CHSCAM_ON, ATTN_NORM);
		self.t_width = (time + 0.6);
	}
	org = (self.origin + '0 0 8');
	dir = (((self.enemy.origin + '0 0 8') - org) + ((v_right * GRD_DEFENDTIME) * crandom()));
	dir = ModAcc(dir);
	dir = normalize(dir);
	traceline(org, (self.origin + (dir * 600)), TRUE, self);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity(MSG_BROADCAST, self);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);
	LightningDamage(org, trace_endpos, self, MON_CAMPTIME);
	self.attack_finished = (time + MON_CAMPERCHANCE);
	if ((random() < MON_MAGICCHANCE))
	{
		self.attack_finished = ((time + 0.3) + self.rfr);
	}
	if ((self.ability == CHSCAM_ON))
	{
		SuperDamageSound();
	}
};
