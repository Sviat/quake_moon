//Decompiled code. Please respect the original copyright.

void() shal_stand =
{
	mon_ai_stand();
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= DOOR_GOLD_KEY))
			{
				self.shootframe = FALSE;
				self.walkframe = 0;
			}
			self.frame = (WF_NORMAL + self.walkframe); // WTF?!
			self.walkframe = (self.walkframe + 1);
			if ((self.walkframe == 1))
			{
				self.framtime = (time + MON_REFRESHTIME);
			}
			if ((self.walkframe == 2))
			{
				self.framtime = (time + 0.015);
			}
			if ((self.walkframe == 3))
			{
				self.framtime = (time + 0.02);
			}
			if ((self.walkframe == DOOR_DONT_LINK))
			{
				self.framtime = (time + 0.025);
			}
			if ((self.walkframe == SVC_SETVIEWPORT))
			{
				self.framtime = (time + MON_MAGICCHANCE);
			}
			else
			{
				self.framtime = (time + MON_UNIQUECHANCE);
			}
		}
		else
		{
			self.frame = (SVC_TEMPENTITY + self.walkframe);
			self.framtime = (time + 0.07);
		}
	}
	self.think = shal_stand;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() shal_run =
{
	mon_ai_run(MON_WALKDIST);
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= DOOR_GOLD_KEY))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (WF_NORMAL + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			self.framtime = (time + MON_UNIQUECHANCE);
		}
		else
		{
			if ((self.walkframe >= 12))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (SVC_TEMPENTITY + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			self.framtime = (time + 0.07);
		}
	}
	self.think = shal_run;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() shal_death1 = [ 16, shal_death2 ]
{
};

void() shal_death2 = [ 17, shal_death3 ]
{
};

void() shal_death3 = [ 18, shal_death4 ]
{
};

void() shal_death4 = [ 19, shal_death5 ]
{
};

void() shal_death5 = [ 20, shal_death6 ]
{
};

void() shal_death6 = [ 21, shal_death7 ]
{
};

void() shal_death7 = [ 22, shal_death7 ]
{
	MonsterDead();
};

void() shal_die =
{
	self.solid = SOLID_NOT;
	DropItem();
	GiveExp();
	if ((self.health < -90))
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
		ThrowHead("progs/h_shal.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib2.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		MonsterDead();
		return;
	}
	sound(self, CHAN_VOICE, "shalrath/death.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
	shal_death1();
};
void() ShalMissileTouch;
void() ShalHome;

void() shal_fire =
{
	local entity missile;
	local vector dir;
	local float dist;
	local float flytime;

	self.shootframe = TRUE;
	self.walkframe = WF_NORMAL;
	dir = normalize(((self.enemy.origin + '0 0 10') - self.origin));
	dist = vlen((self.enemy.origin - self.origin));
	flytime = (dist * 0.002);
	if ((flytime < MON_CAMPERCHANCE))
	{
		flytime = MON_CAMPERCHANCE;
	}
	self.effects = (self.effects | EF_MUZZLEFLASH);
	sound(self, CHAN_WEAPON, "shalrath/attack.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
	missile = spawn();
	missile.owner = self;
	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setmodel(missile, "progs/v_spike.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	missile.origin = (self.origin + '0 0 10');
	missile.velocity = (dir * 400);
	missile.avelocity = '300 300 300';
	missile.nextthink = (flytime + time);
	missile.think = ShalHome;
	missile.enemy = self.enemy;
	missile.touch = ShalMissileTouch;
	self.attack_finished = (time + 1.3);
};

void() ShalHome =
{
	local vector dir;
	local vector vtemp;

	vtemp = (self.enemy.origin + '0 0 10');
	if ((self.enemy == world))
	{
		remove(self);
		return;
	}
	if ((self.enemy.health < START_OFF))
	{
		remove(self);
		return;
	}
	dir = normalize((vtemp - self.origin));
	if ((skill == MOON_DIFFICULTY_MAX))
	{
		self.velocity = (dir * 350);
	}
	else
	{
		self.velocity = (dir * 250);
	}
	self.nextthink = (time + MON_REACTIONTIME);
	self.think = ShalHome;
};

void() ShalMissileTouch =
{
	if ((other == self.owner))
	{
		return;
	}
	T_RadiusDamage(self, self.owner, GRD_DEFENDTIME, world);
	sound(self, CHAN_WEAPON, "weapons/r_exp3.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	self.velocity = VEC_ORIGIN;
	self.touch = SUB_Null;
	setmodel(self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1();
};

entity(entity e, float enc) spawn_shalrath =
{
	local entity m;
	local entity spot;
	local float unique;

	spot = MonterSpawnPoint();
	if ((spot == world))
	{
		return world;
	}
	m = spawn();
	m.solid = SOLID_SLIDEBOX;
	m.movetype = MOVETYPE_STEP;
	setmodel(m, "progs/monster9.mdl");
	setsize(m, VEC_HULL3_MIN, VEC_HULL3_MAX);
	m.enchanced = WF_NORMAL;
	m.speed = 200;
	m.health = 300;
	m.view_ofs = '0 0 25'; // TODO: fix for each of them
	m.netname = "shalrath";
	m.skin = WF_NORMAL;
	m.misspeed = 700;
	GetMonsterPrefixLevel(m, enc);
	if ( enc == 0 )
	{
		m.health = 300;
		m.exp = 14;
		m.misspeed = 700;
	}
	else
	{
		if ( enc == 1 )
		{
			m.health = 320;
			m.exp = 15;
			m.misspeed = 800;
		}
		else
		{
			if ( enc >= 2 )
			{
				m.health = (320 + (enc * 25));
				m.exp = (14 + (enc * DOOR_DONT_LINK));
				if ((enc >= DOOR_DONT_LINK))
				{
					m.damage_bonus = (enc * DOOR_DONT_LINK);
				}
				if ((random() > 0.75))
				{
					m.netname = "rare shalrath";
					m.misspeed = 1000;
				}
			}
		}
	}
	if ((random() < MON_UNIQUECHANCE))
	{
		unique = rint(((random() * DOOR_DONT_LINK) + 1));
	}
	if ((unique == 1))
	{
		m.skin = 0;
		m.ability = 1;
		m.items = IT_QUAD;
		m.super_damage_finished = (time + 999);
		m.effects = (m.effects | EF_DIMLIGHT);
		m.prefix_one = "quaded ";
	}
	else
	{
		if ((unique == 2))
		{
			m.skin = 1;
			m.ability = 2;
			m.prefix_one = "iron ";
		}
		else
		{
			if ((unique == 3))
			{
				m.skin = 2;
				m.ability = 3;
				m.prefix_one = "stone ";
			}
			else
			{
				if ((unique == DOOR_DONT_LINK))
				{
					m.skin = 3;
					m.ability = DOOR_DONT_LINK;
					m.prefix_one = "blood ";
				}
				else
				{
					if ((unique == SVC_SETVIEWPORT))
					{
						m.ability = SVC_SETVIEWPORT;
						m.speed = 450;
						m.misspeed = 1000;
						m.prefix_one = "fast ";
					}
				}
			}
		}
	}
	if ((random() < MON_MAGICCHANCE))
	{
		GetPrefix(m);
		if ((m.skin == WF_NORMAL))
		{
			m.skin = DOOR_DONT_LINK;
		}
	}
	else
	{
		if ((random() < MON_CAMPERCHANCE))
		{
			if ((unique == WF_NORMAL))
			{
				GenegateCampTarget(m);
			}
		}
	}
	if ((unique > WF_NORMAL))
	{
		m.exp = (m.exp * 1.25);
	}
	m.th_stand = shal_stand;
	m.th_run = shal_run;
	m.th_die = shal_die;
	m.th_missile = shal_fire;
	m.origin = spot.origin;
	m.nextthink = (time + (random() * 0.3));
	m.think = walkmonster_start_go;
	m.angles = spot.angles;
	m.attack_finished = time;
	makevectors(m.angles);
	spawn_tdeath(m.origin, m);
	return m;
};

void() Mage_Cast =
{
	if ( self.mana <= 0 )
	{
		return;
	}
	if ( self.scroll_time > time )
	{
		return;
	}
	if ( self.health < self.max_health )
	{
		sound(self, CHAN_VOICE, "moon/misc/cast.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
		moon_heal_target_monster(self, 20);
		self.mana = (self.mana - 1);
		self.scroll_heal_eff = (time + 0.5);
		self.scroll_time = (time + 0.5) + (self.rfr * 2);
	} else
	if ( self.scroll_shie_eff < time )
	{
		sound(self, CHAN_VOICE, "moon/misc/cast.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
		self.mana = (self.mana - 3);
		self.scroll_shie_eff = (time + 10);
		self.scroll_time = (time + 1) + (random() * 1) + (self.rfr * 2);
	}
};

void() mage_stand =
{
	mon_ai_stand();
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= DOOR_DONT_LINK))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (43 + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
		}
		else
		{
			if ((self.walkframe >= 12))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (WF_NORMAL + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
		}
		self.framtime = (time + 0.07);
	}
	self.think = army_stand;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() mage_run =
{
	mon_ai_run(MON_WALKDIST);
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= DOOR_DONT_LINK))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (43 + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
		}
		else
		{
			if ((self.walkframe >= SVC_SETVIEWANGLES))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (12 + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
		}
		self.framtime = (time + 0.07);
	}
	self.think = mage_run;
	self.nextthink = (time + MON_REFRESHTIME);
	Mage_Cast();
};

void() mage_fire =
{
	local entity missile;
	//local vector dir; // unused
	//local float dist; // unused
	//local float flytime; // unused
	local vector org;
	local vector vec;
	local vector d;
	local vector enorg;
	local float t;
	local float zenorg;

	self.shootframe = TRUE;
	self.walkframe = WF_NORMAL;
	self.effects = (self.effects | EF_MUZZLEFLASH);
	sound(self, CHAN_WEAPON, "moon/monsters/f_mage.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
	missile = spawn();
	missile.owner = self;
	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setmodel(missile, "progs/w_ball.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, ((self.origin + '0 0 16') + (v_forward * DOOR_GOLD_KEY)));
	makevectors(self.angles);
	org = self.origin;
	enorg = self.enemy.origin;
	zenorg = ((self.enemy.origin_z + self.enemy.mins_z) - DOOR_DONT_LINK);
	traceline(self.enemy.origin, (enorg - (v_up * zenorg)), FALSE, self);
	if ((trace_fraction == START_OFF))
	{
		enorg_z = zenorg;
	}
	t = (vlen((enorg - org)) / self.misspeed);
	vec = self.enemy.velocity;
	vec_z = WF_NORMAL;
	d = ((enorg + (t * vec)) + ((v_right * 12) * crandom()));
	vec = ModAcc(vec);
	vec = normalize((d - org));
	missile.velocity = (vec * self.misspeed);
	missile.avelocity = '300 300 300';
	missile.touch = ShalMissileTouch;
	self.attack_finished = ((time + 0.85) + self.rfr);
};

void() mage_die1 = [ 22, mage_die2 ]
{
};

void() mage_die2 = [ 23, mage_die3 ]
{
};

void() mage_die3 = [ 24, mage_die4 ]
{
};

void() mage_die4 = [ 25, mage_die5 ]
{
};

void() mage_die5 = [ 26, mage_die5 ]
{
	MonsterDead();
};

void() mage_dieb1 = [ 27, mage_dieb2 ]
{
};

void() mage_dieb2 = [ 28, mage_dieb3 ]
{
};

void() mage_dieb3 = [ 29, mage_dieb4 ]
{
};

void() mage_dieb4 = [ 30, mage_dieb5 ]
{
};

void() mage_dieb5 = [ 31, mage_dieb6 ]
{
};

void() mage_dieb6 = [ 32, mage_dieb7 ]
{
};

void() mage_dieb7 = [ 33, mage_dieb8 ]
{
};

void() mage_dieb8 = [ 34, mage_dieb9 ]
{
};

void() mage_dieb9 = [ 35, mage_dieb10 ]
{
};

void() mage_dieb10 = [ 36, mage_dieb11 ]
{
};

void() mage_dieb11 = [ 37, mage_dieb12 ]
{
};

void() mage_dieb12 = [ 38, mage_dieb13 ]
{
};

void() mage_dieb13 = [ 39, mage_dieb14 ]
{
};

void() mage_dieb14 = [ 40, mage_dieb15 ]
{
};

void() mage_dieb15 = [ 41, mage_dieb16 ]
{
};

void() mage_dieb16 = [ 42, mage_dieb16 ]
{
	MonsterDead();
};

void() mage_die =
{
	DropItem();
	GiveExp();
	if ((self.health < -45))
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
		ThrowHead("progs/skull.mdl", self.health);
		ThrowGib("progs/bone.mdl", self.health);
		ThrowGib("progs/bone.mdl", self.health);
		ThrowGib("progs/bone.mdl", self.health);
		MonsterDead();
		return;
	}
	self.solid = SOLID_NOT;
	if ((random() < MON_BACKTIME))
	{
		sound(self, CHAN_VOICE, "moon/monsters/d_mage.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
	}
	else
	{
		sound(self, CHAN_VOICE, "moon/monsters/d_mage2.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
	}
	if ((random() < MON_BACKTIME))
	{
		mage_die1();
	}
	else
	{
		mage_dieb1();
	}
};

entity(entity e, float enc) spawn_mage =
{
	local entity m;
	local entity spot;
	local float unique;

	spot = MonterSpawnPoint();
	if ((spot == world))
	{
		return world;
	}
	m = spawn();
	m.solid = SOLID_SLIDEBOX;
	m.movetype = MOVETYPE_STEP;
	setmodel(m, "progs/monster3.mdl");
	setsize(m, VEC_HULL_MIN, '16 16 40');
	m.speed = 205;
	m.view_ofs = '0 0 25'; // TODO: fix for each of them
	m.netname = "mage";
	GetMonsterPrefixLevel(m, enc);
	if ((enc == 0))
	{
		m.health = 140;
		m.exp = 12;
		m.mana = GRD_PATROLTIME;
		m.misspeed = 650;
	}
	else
	{
		if ((enc >= 1))
		{
			m.health = (140 + (enc * 15));
			m.exp = (12 + (enc * DOOR_DONT_LINK));
			m.mana = (GRD_PATROLTIME + (enc * LOGIC_FINDDEFEND));
			if ((enc >= DOOR_DONT_LINK))
			{
				m.damage_bonus = (enc * TE_WIZSPIKE);
			}
			m.misspeed = (650 + (enc * MON_CAMPTIME));
		}
	}
	if ((random() < (MON_UNIQUECHANCE / 2)))
	{
		unique = rint(((random() * 1) + 1));
	}
	if ((unique == 1))
	{
		m.skin = 0;
		m.ability = 1;
		m.items = IT_QUAD;
		m.super_damage_finished = (time + 999);
		m.effects = (m.effects | EF_DIMLIGHT);
		m.prefix_one = "quaded ";
	}
	else
	{
		if ((unique == 2))
		{
			m.ability = SVC_SETVIEWPORT;
			m.speed = 450;
			m.misspeed = 1800;
			m.prefix_one = "fast ";
		}
	}
	if ((random() < MON_CAMPERCHANCE))
	{
		if ((unique == 0))
		{
			GenegateCampTarget(m);
		}
	}
	if ((unique >= 1))
	{
		m.exp = (m.exp * 1.25);
	}
	m.origin = spot.origin;
	m.nextthink = (time + (random() * MON_BACKTIME));
	m.think = walkmonster_start_go;
	m.angles = spot.angles;
	m.attack_finished = time;
	m.shootframe = FALSE;
	makevectors(m.angles);
	spawn_tdeath(m.origin, m);
	m.th_stand = mage_stand;
	m.th_run = mage_run;
	m.th_missile = mage_fire;
	m.th_die = mage_die;
	return m;
};

void() T_LaserTouch =
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
	damg = (self.dmg + (random() * SVC_SETVIEWANGLES));
	if (other.health)
	{
		T_Damage(other, self, self.owner, damg);
	}
	T_RadiusDamage(self, self.owner, 80, other);
	self.origin = (self.origin - (DOOR_GOLD_KEY * normalize(self.velocity)));
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	BecomeExplosion();
};

void() Laser_Touch =
{
	local vector org;

	if ((other == self.owner))
	{
		return;
	}
	if ((pointcontents(self.origin) == CONTENT_SKY))
	{
		remove(self);
		return;
	}
	sound(self, CHAN_WEAPON, "enforcer/enfstop.wav", START_OFF, ATTN_STATIC);
	org = (self.origin - (DOOR_GOLD_KEY * normalize(self.velocity)));
	if (other.health)
	{
		SpawnBlood(org, (self.velocity * MON_REACTIONTIME), self.dmg);
		T_Damage(other, self, self.owner, self.dmg);
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord(MSG_BROADCAST, org_x);
		WriteCoord(MSG_BROADCAST, org_y);
		WriteCoord(MSG_BROADCAST, org_z);
	}
	remove(self);
};

void(vector org, vector vec, float spd) LaunchLaser =
{
	vec = normalize(vec);
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;
	if ((self.enchanced == START_OFF))
	{
		setmodel(newmis, "progs/laser2.mdl");
		newmis.dmg = MON_CAMPTIME;
	}
	else
	{
		setmodel(newmis, "progs/laser.mdl");
		newmis.dmg = 15;
	}
	newmis.avelocity = '0 0 250';
	newmis.enchanced = self.enchanced;
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, org);
	newmis.velocity = (vec * spd);
	newmis.angles = vectoangles(newmis.velocity);
	newmis.nextthink = (time + SVC_SETVIEWPORT);
	newmis.think = SUB_Remove;
	newmis.touch = Laser_Touch;
};

void() enforcer_fire =
{
	local vector org;
	//local vector offang; // unused
	local vector vec;
	local vector d;
	local float t;

	if ((self.ability == START_OFF))
	{
		SuperDamageSound();
	}
	self.shootframe = TRUE;
	self.walkframe = WF_NORMAL;
	self.effects = (self.effects | EF_MUZZLEFLASH);
	makevectors(self.angles);
	org = (((self.origin + (v_forward * MON_CAMPTIME)) + (v_right * 6.5)) + '0 0 14');
	sound(self, CHAN_WEAPON, "enforcer/enfire.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
	t = (vlen((self.enemy.origin - org)) / self.misspeed);
	vec = self.enemy.velocity;
	vec_z = WF_NORMAL;
	d = ((self.enemy.origin + (t * vec)) + ((v_right * 12) * crandom()));
	if ((random() < MON_BACKTIME))
	{
		d = (self.enemy.origin + ((v_right * GRD_PATROLTIME) * crandom()));
	}
	vec = (d - org);
	vec = ModAcc(vec);
	vec = normalize(vec);
	LaunchLaser(org, vec, self.misspeed);
	self.attack_finished = (((time + MON_STUCKTIME) + (random() / SVC_SETVIEWANGLES)) + self.rfr);
};

void() enf_stand1 =
{
	mon_ai_stand();
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= DOOR_DONT_LINK))
			{
				self.walkframe = WF_NORMAL;
				self.shootframe = FALSE;
			}
			self.frame = (GRD_DEFENDTIME + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
		}
		else
		{
			if ((self.walkframe >= TE_WIZSPIKE))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (WF_NORMAL + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
		}
		self.framtime = (time + 0.07);
	}
	self.think = enf_stand1;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() enf_run1 =
{
	mon_ai_run(MON_WALKDIST);
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= DOOR_DONT_LINK))
			{
				self.walkframe = WF_NORMAL;
				self.shootframe = FALSE;
			}
			self.frame = (GRD_DEFENDTIME + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
		}
		else
		{
			if ((self.walkframe >= DOOR_GOLD_KEY))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (DOOR_TOGGLE + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
		}
		self.framtime = (time + 0.07);
	}
	self.think = enf_run1;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() enf_die1 = [ 7, enf_die2 ]
{
};

void() enf_die2 = [ 8, enf_die3 ]
{
};

void() enf_die3 = [ 9, enf_die4 ]
{
};

void() enf_die4 = [ 10, enf_die5 ]
{
	ai_forward(14);
};

void() enf_die5 = [ 11, enf_die6 ]
{
	ai_forward(SILENT);
};

void() enf_die6 = [ 12, enf_die7 ]
{
};

void() enf_die7 = [ 13, enf_die8 ]
{
};

void() enf_die8 = [ 14, enf_die9 ]
{
};

void() enf_die9 = [ 15, enf_die10 ]
{
	ai_forward(LOGIC_FINDDEFEND);
};

void() enf_die10 = [ 16, enf_die11 ]
{
	ai_forward(SVC_SETVIEWPORT);
};

void() enf_die11 = [ 17, enf_die12 ]
{
	ai_forward(SVC_SETVIEWPORT);
};

void() enf_die12 = [ 18, enf_die13 ]
{
	ai_forward(SVC_SETVIEWPORT);
};

void() enf_die13 = [ 19, enf_die14 ]
{
};

void() enf_die14 = [ 20, enf_die14 ]
{
	MonsterDead();
};

void() enf_fdie1 = [ 21, enf_fdie2 ]
{
};

void() enf_fdie2 = [ 22, enf_fdie3 ]
{
};

void() enf_fdie3 = [ 23, enf_fdie4 ]
{
};

void() enf_fdie4 = [ 24, enf_fdie5 ]
{
};

void() enf_fdie5 = [ 25, enf_fdie6 ]
{
};

void() enf_fdie6 = [ 26, enf_fdie7 ]
{
};

void() enf_fdie7 = [ 27, enf_fdie8 ]
{
};

void() enf_fdie8 = [ 28, enf_fdie9 ]
{
};

void() enf_fdie9 = [ 29, enf_fdie10 ]
{
};

void() enf_fdie10 = [ 30, enf_fdie11 ]
{
};

void() enf_fdie11 = [ 31, enf_fdie11 ]
{
	MonsterDead();
};

void() enf_die =
{
	self.solid = SOLID_NOT;
	DropItem();
	GiveExp();
	if ((self.health < -35))
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
		ThrowHead("progs/h_mega.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib2.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		MonsterDead();
		return;
	}
	sound(self, CHAN_VOICE, "enforcer/death1.wav", MOON_SOUND_VOLUME_DEFAULT, ATTN_NORM);
	if ((random() > MON_BACKTIME))
	{
		enf_die1();
	}
	else
	{
		enf_fdie1();
	}
};

entity(entity spawner, float enc) spawn_enforcer =
{
	local entity m;
	local entity spot;
	local float unique;

	if ((enc < WF_NORMAL))
	{
		enc = WF_NORMAL;
	}
	spot = MonterSpawnPoint();
	if ((spot == world))
	{
		return world;
	}
	m = spawn();
	m.solid = SOLID_SLIDEBOX;
	m.movetype = MOVETYPE_STEP;
	setmodel(m, "progs/monster1.mdl");
	setsize(m, VEC_HULL_MIN, '16 16 40');
	m.enchanced = 0;
	m.speed = 240;
	m.view_ofs = '0 0 25'; // TODO: fix for each of them
	m.netname = "enforcer";
	m.skin = 0;
	m.misspeed = 800;
	GetMonsterPrefixLevel(m, enc);
	if ((enc == 0))
	{
		m.health = 80;
		m.exp = SVC_SETVIEWANGLES;
		m.misspeed = 800;
	}
	else
	{
		if ((enc == 1))
		{
			m.health = MENTAT_TIME;
			m.exp = 12;
			m.misspeed = 900;
		}
		else
		{
			if ((enc >= 2))
			{
				m.health = (80 + (enc * 25));
				m.exp = (SVC_SETVIEWANGLES + (enc * DOOR_DONT_LINK));
				if ((enc >= DOOR_DONT_LINK))
				{
					m.damage_bonus = (enc * DOOR_DONT_LINK);
				}
				if ((random() > 0.6))
				{
					m.netname = "twin enforcer";
					m.enchanced = 1;
				}
			}
		}
	}
	if ((random() < MON_UNIQUECHANCE))
	{
		unique = rint(((random() * DOOR_DONT_LINK) + 1));
	}
	if ((unique == 1))
	{
		m.skin = 0;
		m.ability = 1;
		m.items = IT_QUAD;
		m.super_damage_finished = (time + 999);
		m.effects = (m.effects | EF_DIMLIGHT);
		m.prefix_one = "quaded ";
	}
	else
	{
		if ((unique == 2))
		{
			m.skin = 1;
			m.ability = 2;
			m.prefix_one = "iron ";
		}
		else
		{
			if ((unique == 3))
			{
				m.skin = 2;
				m.ability = 3;
				m.prefix_one = "stone ";
			}
			else
			{
				if ((unique == DOOR_DONT_LINK))
				{
					m.skin = 3;
					m.ability = DOOR_DONT_LINK;
					m.prefix_one = "blood ";
				}
				else
				{
					if ((unique == SVC_SETVIEWPORT))
					{
						m.ability = SVC_SETVIEWPORT;
						m.speed = 450;
						m.misspeed = 1000;
						m.prefix_one = "fast ";
					}
				}
			}
		}
	}
	if ((random() < MON_MAGICCHANCE))
	{
		GetPrefix(m);
		if ((m.skin == 0))
		{
			m.skin = DOOR_DONT_LINK;
		}
	}
	else
	{
		if ((random() < MON_CAMPERCHANCE))
		{
			if ((unique == 0))
			{
				GenegateCampTarget(m);
			}
		}
	}
	if ((unique > 0))
	{
		m.exp = (m.exp * 1.25);
	}
	m.origin = spot.origin;
	m.th_stand = enf_stand1;
	m.th_run = enf_run1;
	m.th_die = enf_die;
	m.th_missile = enforcer_fire;
	m.nextthink = (time + (random() * 0.3));
	m.think = walkmonster_start_go;
	m.angles = spot.angles;
	m.attack_finished = time;
	makevectors(m.angles);
	spawn_tdeath(m.origin, m);
	return m;
};
