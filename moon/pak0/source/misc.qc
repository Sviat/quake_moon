//Decompiled code. Please respect the original copyright.

void() info_null =
{
	remove(self);
};

void() info_notnull =
{
};
float START_OFF    = 1;

void() light_use =
{
	if ((self.spawnflags & START_OFF))
	{
		lightstyle(self.style, "m");
		self.spawnflags = (self.spawnflags - START_OFF);
	}
	else
	{
		lightstyle(self.style, "a");
		self.spawnflags = (self.spawnflags + START_OFF);
	}
};

void() light =
{
	if (!self.targetname)
	{
		remove(self);
		return;
	}
	if ((self.style >= DOOR_TOGGLE))
	{
		self.use = light_use;
		if ((self.spawnflags & START_OFF))
		{
			lightstyle(self.style, "a");
		}
		else
		{
			lightstyle(self.style, "m");
		}
	}
};

void() light_fluoro =
{
	if ((self.style >= DOOR_TOGGLE))
	{
		self.use = light_use;
		if ((self.spawnflags & START_OFF))
		{
			lightstyle(self.style, "a");
		}
		else
		{
			lightstyle(self.style, "m");
		}
	}
	precache_sound("ambience/fl_hum1.wav");
	ambientsound(self.origin, "ambience/fl_hum1.wav", MON_BACKTIME, ATTN_STATIC);
};

void() light_fluorospark =
{
	if (!self.style)
	{
		self.style = SVC_SETVIEWANGLES;
	}
	precache_sound("ambience/buzz1.wav");
	ambientsound(self.origin, "ambience/buzz1.wav", MON_BACKTIME, ATTN_STATIC);
};

void() light_globe =
{
	precache_model("progs/s_light.spr");
	setmodel(self, "progs/s_light.spr");
	makestatic(self);
};

void() FireAmbient =
{
	precache_sound("ambience/fire1.wav");
	ambientsound(self.origin, "ambience/fire1.wav", MON_BACKTIME, ATTN_STATIC);
};

void() light_torch_small_walltorch =
{
	precache_model("progs/flame.mdl");
	setmodel(self, "progs/flame.mdl");
	FireAmbient();
};

void() light_boxed_torch =
{
	precache_model("progs/onwlflm.mdl");
	setmodel(self, "progs/onwlflm.mdl");
	FireAmbient();
	makestatic(self);
};

void() light_flame_large_yellow =
{
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");
	self.frame = CHSCAM_ON;
	FireAmbient();
	makestatic(self);
};

void() light_flame_small_yellow =
{
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");
	FireAmbient();
	makestatic(self);
};

void() light_flame_small_white =
{
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");
	FireAmbient();
	makestatic(self);
};

void() func_wall_use =
{
	self.frame = (CHSCAM_ON - self.frame);
};

void() func_wall =
{
	self.angles = VEC_ORIGIN;
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel(self, self.model);
};

void() func_illusionary =
{
	self.angles = VEC_ORIGIN;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel(self, self.model);
	makestatic();
};

void() ambient_suck_wind =
{
	precache_sound("ambience/suck1.wav");
	ambientsound(self.origin, "ambience/suck1.wav", CHSCAM_ON, ATTN_STATIC);
};

void() ambient_drone =
{
	precache_sound("ambience/drone6.wav");
	ambientsound(self.origin, "ambience/drone6.wav", MON_BACKTIME, ATTN_STATIC);
};

void() ambient_flouro_buzz =
{
	precache_sound("ambience/buzz1.wav");
	ambientsound(self.origin, "ambience/buzz1.wav", CHSCAM_ON, ATTN_STATIC);
};

void() ambient_drip =
{
	precache_sound("ambience/drip1.wav");
	ambientsound(self.origin, "ambience/drip1.wav", MON_BACKTIME, ATTN_STATIC);
};

void() ambient_comp_hum =
{
	precache_sound("ambience/comp1.wav");
	ambientsound(self.origin, "ambience/comp1.wav", CHSCAM_ON, ATTN_STATIC);
};

void() ambient_thunder =
{
	precache_sound("ambience/thunder1.wav");
	ambientsound(self.origin, "ambience/thunder1.wav", MON_BACKTIME, ATTN_STATIC);
};

void() ambient_light_buzz =
{
	precache_sound("ambience/fl_hum1.wav");
	ambientsound(self.origin, "ambience/fl_hum1.wav", MON_BACKTIME, ATTN_STATIC);
};

void() ambient_swamp1 =
{
	precache_sound("ambience/swamp1.wav");
	ambientsound(self.origin, "ambience/swamp1.wav", MON_BACKTIME, ATTN_STATIC);
};

void() ambient_swamp2 =
{
	precache_sound("ambience/swamp2.wav");
	ambientsound(self.origin, "ambience/swamp2.wav", MON_BACKTIME, ATTN_STATIC);
};

void() misc_fireball =
{
	remove(self);
};

void() misc_explobox =
{
	remove(self);
};

void() misc_explobox2 =
{
	remove(self);
};

void() trap_spikeshooter =
{
	remove(self);
};

void() trap_shooter =
{
	remove(self);
};

void() air_bubbles =
{
	remove(self);
};

void() bubble_bob =
{
	remove(self);
};

void() viewthing =
{
	remove(self);
};

void() func_episodegate =
{
	remove(self);
};

void() func_bossgate =
{
	remove(self);
};

void() misc_noisemaker =
{
	remove(self);
};

void() ogre_fire =
{
	local entity missile;
	local entity mpuff;
	local vector vec;
	local vector src;
	local vector d;
	local float t;
	local float zvel;
	local float zminus;

	self.shootframe = TRUE;
	self.walkframe = WF_NORMAL;
	self.effects = (self.effects | EF_MUZZLEFLASH);
	sound(self, CHAN_WEAPON, "weapons/grenade.wav", CHSCAM_ON, ATTN_NORM);
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
	makevectors(self.angles);
	src = ((self.origin + (v_right * -8)) + '0 0 16');
	if ((vlen(self.enemy.velocity) <= 160))
	{
		vlen((self.enemy.origin - src));
		t = (vlen((self.enemy.origin - src)) / (self.misspeed * H_MEGA));
	}
	else
	{
		t = (vlen((self.enemy.origin - src)) / self.misspeed);
	}
	vec = self.enemy.velocity;
	vec_z = WF_NORMAL;
	d = (self.enemy.origin + (t * vec));
	vec = (d - src);
	vec = ModAcc(vec);
	missile.velocity = normalize(vec);
	missile.velocity = (missile.velocity * self.misspeed);
	zminus = vlen((self.enemy.origin - self.origin));
	zminus = (zminus / 300);
	zvel = (self.enemy.origin_z - self.origin_z);
	missile.velocity_z = (200 + ((zvel * 2.2) / zminus));
	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = GrenadeTouch;
	missile.dmg = self.dmg;
	missile.nextthink = (time + 2.5);
	missile.think = GrenadeExplode;
	setmodel(missile, "progs/grenade.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, self.origin);
	self.attack_finished = ((time + 0.7) + self.rfr);
	if ((self.ability == CHSCAM_ON))
	{
		SuperDamageSound();
	}
};

void(float side) chainsaw =
{
	local vector delta;
	local float ldmg;

	if (!self.enemy)
	{
		return;
	}
	if (!CanDamage(self.enemy, self))
	{
		return;
	}
	ai_charge(SVC_SETVIEWANGLES);
	delta = (self.enemy.origin - self.origin);
	if ((vlen(delta) > 100))
	{
		return;
	}
	ldmg = (((random() + random()) + random()) * DOOR_DONT_LINK);
	T_Damage(self.enemy, self, self, ldmg);
	if (side)
	{
		makevectors(self.angles);
		if ((side == CHSCAM_ON))
		{
			SpawnMeatSpray((self.origin + (v_forward * DOOR_SILVER_KEY)), ((crandom() * 100) * v_right));
		}
		else
		{
			SpawnMeatSpray((self.origin + (v_forward * DOOR_SILVER_KEY)), (side * v_right));
		}
	}
};

void() ogre_stand =
{
	mon_ai_stand();
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= KEY_MOVERIGHT))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (69 + self.walkframe);
			self.walkframe = (self.walkframe + CHSCAM_ON);
		}
		else
		{
			if ((self.walkframe >= TE_LIGHTNING3))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (WF_NORMAL + self.walkframe);
			self.walkframe = (self.walkframe + CHSCAM_ON);
		}
		self.framtime = (time + 0.07);
	}
	self.think = ogre_stand;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() ogre_run =
{
	mon_ai_run(MON_WALKDIST);
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= KEY_MOVERIGHT))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (69 + self.walkframe);
			self.walkframe = (self.walkframe + CHSCAM_ON);
		}
		else
		{
			if ((self.walkframe >= KEY_MOVERIGHT))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (TE_LIGHTNING3 + self.walkframe);
			self.walkframe = (self.walkframe + CHSCAM_ON);
		}
		self.framtime = (time + 0.07);
	}
	self.think = ogre_run;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() ogre_die1 = [ 45, ogre_die2 ]
{
};

void() ogre_die2 = [ 46, ogre_die3 ]
{
};

void() ogre_die3 = [ 47, ogre_die4 ]
{
};

void() ogre_die4 = [ 48, ogre_die5 ]
{
};

void() ogre_die5 = [ 49, ogre_die6 ]
{
};

void() ogre_die6 = [ 50, ogre_die7 ]
{
};

void() ogre_die7 = [ 51, ogre_die8 ]
{
};

void() ogre_die8 = [ 52, ogre_die9 ]
{
};

void() ogre_die9 = [ 53, ogre_die10 ]
{
};

void() ogre_die10 = [ 54, ogre_die11 ]
{
};

void() ogre_die11 = [ 55, ogre_die12 ]
{
};

void() ogre_die12 = [ 56, ogre_die13 ]
{
};

void() ogre_die13 = [ 57, ogre_die14 ]
{
};

void() ogre_die14 = [ 58, ogre_die14 ]
{
	MonsterDead();
};

void() ogre_bdie1 = [ 59, ogre_bdie2 ]
{
};

void() ogre_bdie2 = [ 60, ogre_bdie3 ]
{
	ai_forward(SVC_SETVIEWPORT);
};

void() ogre_bdie3 = [ 61, ogre_bdie4 ]
{
};

void() ogre_bdie4 = [ 62, ogre_bdie5 ]
{
	ai_forward(CHSCAM_ON);
};

void() ogre_bdie5 = [ 63, ogre_bdie6 ]
{
	ai_forward(LOGIC_FINDDEFEND);
};

void() ogre_bdie6 = [ 64, ogre_bdie7 ]
{
	ai_forward(TE_WIZSPIKE);
};

void() ogre_bdie7 = [ 65, ogre_bdie8 ]
{
	ai_forward(25);
};

void() ogre_bdie8 = [ 66, ogre_bdie9 ]
{
};

void() ogre_bdie9 = [ 67, ogre_bdie10 ]
{
};

void() ogre_bdie10 = [ 68, ogre_bdie10 ]
{
	MonsterDead();
};

void() ogre_die =
{
	self.solid = SOLID_NOT;
	DropItem();
	if ((random() < MON_CAMPERCHANCE))
	{
		DropItem();
	}
	GiveExp();
	if ((self.health < -80))
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", CHSCAM_ON, ATTN_NORM);
		ThrowHead("progs/h_ogre.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		MonsterDead();
		return;
	}
	sound(self, CHAN_VOICE, "ogre/ogdth.wav", CHSCAM_ON, ATTN_NORM);
	if ((random() < MON_BACKTIME))
	{
		ogre_die1();
	}
	else
	{
		ogre_bdie1();
	}
};

void() ogre_melee =
{
};

void(entity e, float enc) spawn_ogre =
{
	local entity m;
	local entity spot;
	local float unique;

	spot = MonterSpawnPoint();
	if ((spot == world))
	{
		return;
	}
	m = spawn();
	m.solid = SOLID_SLIDEBOX;
	m.movetype = MOVETYPE_STEP;
	setmodel(m, "progs/monster4.mdl");
	setsize(m, VEC_HULL2_MIN, VEC_HULL2_MAX);
	if ((enc < WF_NORMAL))
	{
		enc = WF_NORMAL;
	}
	m.netname = "ogre";
	m.skin = WF_NORMAL;
	m.speed = 230;
	GetPrfx(m, enc);
	if ((enc == WF_NORMAL))
	{
		m.health = 200;
		m.exp = 12;
		m.misspeed = 600;
	}
	else
	{
		if ((enc >= CHSCAM_ON))
		{
			m.health = (200 + (enc * 25));
			m.exp = (12 + (enc * LOGIC_HUNTENEMY));
			if ((enc >= DOOR_DONT_LINK))
			{
				m.damage_bonus = (enc * TE_WIZSPIKE);
			}
			if ((random() < 0.6))
			{
				m.misspeed = 600;
			}
			else
			{
				m.misspeed = 800;
				m.netname = "dread ogre";
			}
		}
	}
	if ((random() < MON_UNIQUECHANCE))
	{
		unique = rint(((random() * DOOR_DONT_LINK) + CHSCAM_ON));
	}
	if ((unique == CHSCAM_ON))
	{
		m.skin = WF_NORMAL;
		m.ability = CHSCAM_ON;
		m.items = IT_QUAD;
		m.super_damage_finished = (time + 999);
		m.effects = (m.effects | EF_DIMLIGHT);
		m.prefix_one = "quaded ";
	}
	else
	{
		if ((unique == SILENT))
		{
			m.skin = CHSCAM_ON;
			m.ability = SILENT;
			m.prefix_one = "iron ";
		}
		else
		{
			if ((unique == LOGIC_FINDDEFEND))
			{
				m.skin = SILENT;
				m.ability = LOGIC_FINDDEFEND;
				m.prefix_one = "stone ";
			}
			else
			{
				if ((unique == DOOR_DONT_LINK))
				{
					m.skin = LOGIC_FINDDEFEND;
					m.ability = DOOR_DONT_LINK;
					m.prefix_one = "blood ";
				}
				else
				{
					if ((unique == SVC_SETVIEWPORT))
					{
						m.ability = SVC_SETVIEWPORT;
						m.speed = 450;
						m.misspeed = 1800;
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
	if ((unique >= CHSCAM_ON))
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
	e.count = (e.count - CHSCAM_ON);
	m.th_stand = ogre_stand;
	m.th_run = ogre_run;
	m.th_die = ogre_die;
	m.th_missile = ogre_fire;
};

void() snake_stand =
{
	mon_ai_stand();
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= SVC_SETVIEWPORT))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (14 + self.walkframe);
			self.walkframe = (self.walkframe + CHSCAM_ON);
			self.framtime = (time + 0.05);
		}
		else
		{
			if ((self.walkframe >= LOGIC_HUNTENEMY))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (37 + self.walkframe);
			self.walkframe = (self.walkframe + CHSCAM_ON);
			self.framtime = (time + 0.09);
		}
	}
	self.think = snake_stand;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() snake_run =
{
	mon_ai_run(MON_WALKDIST);
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= SVC_SETVIEWPORT))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (14 + self.walkframe);
			self.walkframe = (self.walkframe + CHSCAM_ON);
			self.framtime = (time + 0.05);
		}
		else
		{
			if ((self.walkframe >= 14))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (WF_NORMAL + self.walkframe);
			self.walkframe = (self.walkframe + CHSCAM_ON);
			self.framtime = (time + 0.07);
		}
	}
	self.think = snake_run;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() snake_death1 = [ 21, snake_death2 ]
{
};

void() snake_death2 = [ 22, snake_death3 ]
{
};

void() snake_death3 = [ 23, snake_death4 ]
{
};

void() snake_death4 = [ 24, snake_death5 ]
{
};

void() snake_death5 = [ 25, snake_death6 ]
{
};

void() snake_death6 = [ 26, snake_death7 ]
{
};

void() snake_death7 = [ 27, snake_death8 ]
{
};

void() snake_death8 = [ 28, snake_death9 ]
{
};

void() snake_death9 = [ 29, snake_death10 ]
{
};

void() snake_death10 = [ 30, snake_death10 ]
{
	MonsterDead();
};

void() snake_dead1 = [ 31, snake_dead2 ]
{
};

void() snake_dead2 = [ 32, snake_dead3 ]
{
};

void() snake_dead3 = [ 33, snake_dead4 ]
{
};

void() snake_dead4 = [ 34, snake_dead5 ]
{
};

void() snake_dead5 = [ 35, snake_dead6 ]
{
};

void() snake_dead6 = [ 36, snake_dead6 ]
{
	MonsterDead();
};

void() snake_fire =
{
	if ((self.shootframe != TRUE))
	{
		self.walkframe = CHSCAM_ON;
		self.shootframe = TRUE;
	}
	makevectors(self.angles);
	if ((self.cnt == CHSCAM_ON))
	{
		self.cnt = CONTENT_EMPTY;
	}
	else
	{
		self.cnt = CHSCAM_ON;
	}
	M_FireSuperNail((((self.origin + (v_up * DOOR_GOLD_KEY)) + (v_forward * DOOR_GOLD_KEY)) + ((v_right * 14) * self.cnt)));
	if ((random() < MON_MAGICCHANCE))
	{
		self.attack_finished = ((time + MON_BACKTIME) + self.rfr);
	}
	else
	{
		self.attack_finished = (time + MON_CAMPERCHANCE);
	}
};

void() snake_die =
{
	DropItem();
	GiveExp();
	self.solid = SOLID_NOT;
	if ((self.health < -55))
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", CHSCAM_ON, ATTN_NORM);
		FakeThrowHead("progs/uzi.mdl", self.health);
		FakeThrowHead("progs/uzi.mdl", self.health);
		ThrowGib("progs/gib2.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		remove(self);
		return;
	}
	sound(self, CHAN_VOICE, "moon/monsters/d_snake.wav", CHSCAM_ON, ATTN_NORM);
	if ((random() < MON_BACKTIME))
	{
		snake_death1();
	}
	else
	{
		snake_dead1();
	}
};

void(entity e, float enc) spawn_snake =
{
	local entity m;
	local entity spot;
	local float unique;

	spot = MonterSpawnPoint();
	if ((spot == world))
	{
		return;
	}
	m = spawn();
	m.solid = SOLID_SLIDEBOX;
	m.movetype = MOVETYPE_STEP;
	setmodel(m, "progs/monster8.mdl");
	setsize(m, '-22 -22 -24', '22 22 48');
	m.speed = 220;
	if ((enc < WF_NORMAL))
	{
		enc = WF_NORMAL;
	}
	m.green_blood = CHSCAM_ON;
	m.netname = "snake";
	m.lvl = enc;
	GetPrfx(m, enc);
	if ((enc == WF_NORMAL))
	{
		m.health = 140;
		m.exp = DOOR_GOLD_KEY;
	}
	else
	{
		if ((enc >= CHSCAM_ON))
		{
			m.health = (140 + (enc * GRD_PATROLTIME));
			m.exp = (DOOR_GOLD_KEY + (enc * SVC_SETVIEWPORT));
			if ((enc >= DOOR_DONT_LINK))
			{
				m.damage_bonus = (enc * TE_WIZSPIKE);
			}
			if ((random() > 0.6))
			{
				m.black_spike = START_OFF;
				m.netname = "pulse snake";
			}
		}
	}
	if ((random() < MON_UNIQUECHANCE))
	{
		unique = rint(((random() * DOOR_DONT_LINK) + START_OFF));
	}
	if ((unique == START_OFF))
	{
		m.skin = WF_NORMAL;
		m.ability = START_OFF;
		m.items = IT_QUAD;
		m.super_damage_finished = (time + 999);
		m.effects = (m.effects | EF_DIMLIGHT);
		m.prefix_one = "quaded ";
	}
	else
	{
		if ((unique == SILENT))
		{
			m.skin = START_OFF;
			m.ability = SILENT;
			m.prefix_one = "iron ";
		}
		else
		{
			if ((unique == LOGIC_FINDDEFEND))
			{
				m.skin = SILENT;
				m.ability = LOGIC_FINDDEFEND;
				m.prefix_one = "stone ";
			}
			else
			{
				if ((unique == DOOR_DONT_LINK))
				{
					m.skin = LOGIC_FINDDEFEND;
					m.ability = DOOR_DONT_LINK;
					m.prefix_one = "blood ";
				}
				else
				{
					if ((unique == SVC_SETVIEWPORT))
					{
						m.ability = SVC_SETVIEWPORT;
						m.speed = 450;
						m.misspeed = 1800;
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
	if ((unique >= START_OFF))
	{
		m.exp = (m.exp * 1.25);
	}
	m.th_stand = snake_stand;
	m.th_run = snake_run;
	m.th_die = snake_die;
	m.th_missile = snake_fire;
	m.origin = spot.origin;
	m.nextthink = (time + (random() * MON_BACKTIME));
	m.think = walkmonster_start_go;
	m.angles = spot.angles;
	m.attack_finished = time;
	m.shootframe = FALSE;
	makevectors(m.angles);
	spawn_tfog((m.origin + (v_forward * GRD_PATROLTIME)));
	spawn_tdeath(m.origin, m);
	e.count = (e.count - START_OFF);
};
