//Decompiled code. Please respect the original copyright.
void() dog_leap1;
void() dog_run1;

void() dog_bite =
{
	local vector delta;
	local float ldmg;

	if (!self.enemy)
	{
		return;
	}
	ai_charge(SVC_SETVIEWANGLES);
	if (!CanDamage(self.enemy, self))
	{
		return;
	}
	delta = (self.enemy.origin - self.origin);
	if ((vlen(delta) > 100))
	{
		return;
	}
	ldmg = (((random() + random()) + random()) * DOOR_GOLD_KEY);
	T_Damage(self.enemy, self, self, ldmg);
};

void() Dog_JumpTouch =
{
	local float ldmg;

	if ((self.health <= WF_NORMAL))
	{
		return;
	}
	if (other.takedamage)
	{
		if ((vlen(self.velocity) > 300))
		{
			ldmg = (SVC_SETVIEWANGLES + (SVC_SETVIEWANGLES * random()));
			T_Damage(other, self, self, ldmg);
		}
	}
	if (!checkbottom(self))
	{
		if ((self.flags & FL_ONGROUND))
		{
			self.touch = SUB_Null;
			self.think = dog_leap1;
			self.nextthink = (time + MON_CAMPERCHANCE);
		}
		return;
	}
	self.touch = SUB_Null;
	self.think = dog_run1;
	self.nextthink = (time + MON_CAMPERCHANCE);
};

void() dog_stand1 = [ 69, dog_stand2 ]
{
	ai_stand();
};

void() dog_stand2 = [ 70, dog_stand3 ]
{
	ai_stand();
};

void() dog_stand3 = [ 71, dog_stand4 ]
{
	ai_stand();
};

void() dog_stand4 = [ 72, dog_stand5 ]
{
	ai_stand();
};

void() dog_stand5 = [ 73, dog_stand6 ]
{
	ai_stand();
};

void() dog_stand6 = [ 74, dog_stand7 ]
{
	ai_stand();
};

void() dog_stand7 = [ 75, dog_stand8 ]
{
	ai_stand();
};

void() dog_stand8 = [ 76, dog_stand9 ]
{
	ai_stand();
};

void() dog_stand9 = [ 77, dog_stand1 ]
{
	ai_stand();
};

void() dog_walk1 = [ 78, dog_walk2 ]
{
	if ((random() < MON_REACTIONTIME))
	{
		sound(self, CHAN_VOICE, "dog/idle.wav", START_OFF, ATTN_IDLE);
	}
	ai_walk(DOOR_GOLD_KEY);
};

void() dog_walk2 = [ 79, dog_walk3 ]
{
	ai_walk(DOOR_GOLD_KEY);
};

void() dog_walk3 = [ 80, dog_walk4 ]
{
	ai_walk(DOOR_GOLD_KEY);
};

void() dog_walk4 = [ 81, dog_walk5 ]
{
	ai_walk(DOOR_GOLD_KEY);
};

void() dog_walk5 = [ 82, dog_walk6 ]
{
	ai_walk(DOOR_GOLD_KEY);
};

void() dog_walk6 = [ 83, dog_walk7 ]
{
	ai_walk(DOOR_GOLD_KEY);
};

void() dog_walk7 = [ 84, dog_walk8 ]
{
	ai_walk(DOOR_GOLD_KEY);
};

void() dog_walk8 = [ 85, dog_walk1 ]
{
	ai_walk(DOOR_GOLD_KEY);
};

void() dog_run1 = [ 48, dog_run2 ]
{
	if ((random() < MON_REACTIONTIME))
	{
		sound(self, CHAN_VOICE, "dog/idle.wav", START_OFF, ATTN_IDLE);
	}
	ai_run(DOOR_SILVER_KEY);
};

void() dog_run2 = [ 49, dog_run3 ]
{
	ai_run(DOOR_TOGGLE);
};

void() dog_run3 = [ 50, dog_run4 ]
{
	ai_run(DOOR_TOGGLE);
};

void() dog_run4 = [ 51, dog_run5 ]
{
	ai_run(GRD_PATROLTIME);
};

void() dog_run5 = [ 52, dog_run6 ]
{
	ai_run(KEY_LOOKUP);
};

void() dog_run6 = [ 53, dog_run7 ]
{
	ai_run(DOOR_TOGGLE);
};

void() dog_run7 = [ 54, dog_run8 ]
{
	ai_run(DOOR_SILVER_KEY);
};

void() dog_run8 = [ 55, dog_run9 ]
{
	ai_run(DOOR_TOGGLE);
};

void() dog_run9 = [ 56, dog_run10 ]
{
	ai_run(DOOR_TOGGLE);
};

void() dog_run10 = [ 57, dog_run11 ]
{
	ai_run(GRD_PATROLTIME);
};

void() dog_run11 = [ 58, dog_run12 ]
{
	ai_run(KEY_LOOKUP);
};

void() dog_run12 = [ 59, dog_run1 ]
{
	ai_run(DOOR_TOGGLE);
};

void() dog_atta1 = [ 0, dog_atta2 ]
{
	ai_charge(SVC_SETVIEWANGLES);
};

void() dog_atta2 = [ 1, dog_atta3 ]
{
	ai_charge(SVC_SETVIEWANGLES);
};

void() dog_atta3 = [ 2, dog_atta4 ]
{
	ai_charge(SVC_SETVIEWANGLES);
};

void() dog_atta4 = [ 3, dog_atta5 ]
{
	sound(self, CHAN_VOICE, "dog/dattack1.wav", START_OFF, ATTN_NORM);
	dog_bite();
};

void() dog_atta5 = [ 4, dog_atta6 ]
{
	ai_charge(SVC_SETVIEWANGLES);
};

void() dog_atta6 = [ 5, dog_atta7 ]
{
	ai_charge(SVC_SETVIEWANGLES);
};

void() dog_atta7 = [ 6, dog_atta8 ]
{
	ai_charge(SVC_SETVIEWANGLES);
};

void() dog_atta8 = [ 7, dog_run1 ]
{
	ai_charge(SVC_SETVIEWANGLES);
};

void() dog_leap1 = [ 60, dog_leap2 ]
{
	ai_face();
};

void() dog_leap2 = [ 61, dog_leap3 ]
{
	ai_face();
	self.touch = Dog_JumpTouch;
	makevectors(self.angles);
	self.origin_z = (self.origin_z + START_OFF);
	self.velocity = ((v_forward * 300) + '0 0 200');
	if ((self.flags & FL_ONGROUND))
	{
		self.flags = (self.flags - FL_ONGROUND);
	}
};

void() dog_leap3 = [ 62, dog_leap4 ]
{
};

void() dog_leap4 = [ 63, dog_leap5 ]
{
};

void() dog_leap5 = [ 64, dog_leap6 ]
{
};

void() dog_leap6 = [ 65, dog_leap7 ]
{
};

void() dog_leap7 = [ 66, dog_leap8 ]
{
};

void() dog_leap8 = [ 67, dog_leap9 ]
{
};

void() dog_leap9 = [ 68, dog_leap9 ]
{
};

void() dog_pain1 = [ 26, dog_pain2 ]
{
};

void() dog_pain2 = [ 27, dog_pain3 ]
{
};

void() dog_pain3 = [ 28, dog_pain4 ]
{
};

void() dog_pain4 = [ 29, dog_pain5 ]
{
};

void() dog_pain5 = [ 30, dog_pain6 ]
{
};

void() dog_pain6 = [ 31, dog_run1 ]
{
};

void() dog_painb1 = [ 32, dog_painb2 ]
{
};

void() dog_painb2 = [ 33, dog_painb3 ]
{
};

void() dog_painb3 = [ 34, dog_painb4 ]
{
	ai_pain(DOOR_DONT_LINK);
};

void() dog_painb4 = [ 35, dog_painb5 ]
{
	ai_pain(12);
};

void() dog_painb5 = [ 36, dog_painb6 ]
{
	ai_pain(12);
};

void() dog_painb6 = [ 37, dog_painb7 ]
{
	ai_pain(SILENT);
};

void() dog_painb7 = [ 38, dog_painb8 ]
{
};

void() dog_painb8 = [ 39, dog_painb9 ]
{
	ai_pain(DOOR_DONT_LINK);
};

void() dog_painb9 = [ 40, dog_painb10 ]
{
};

void() dog_painb10 = [ 41, dog_painb11 ]
{
	ai_pain(SVC_SETVIEWANGLES);
};

void() dog_painb11 = [ 42, dog_painb12 ]
{
};

void() dog_painb12 = [ 43, dog_painb13 ]
{
};

void() dog_painb13 = [ 44, dog_painb14 ]
{
};

void() dog_painb14 = [ 45, dog_painb15 ]
{
};

void() dog_painb15 = [ 46, dog_painb16 ]
{
};

void() dog_painb16 = [ 47, dog_run1 ]
{
};

void(entity attacker, float damage) dog_pain =
{
	sound(self, CHAN_VOICE, "dog/dpain1.wav", START_OFF, ATTN_NORM);
	if ((random() > MON_BACKTIME))
	{
		dog_pain1();
	}
	else
	{
		dog_painb1();
	}
};

void() dog_die1 = [ 8, dog_die2 ]
{
};

void() dog_die2 = [ 9, dog_die3 ]
{
};

void() dog_die3 = [ 10, dog_die4 ]
{
};

void() dog_die4 = [ 11, dog_die5 ]
{
};

void() dog_die5 = [ 12, dog_die6 ]
{
};

void() dog_die6 = [ 13, dog_die7 ]
{
};

void() dog_die7 = [ 14, dog_die8 ]
{
};

void() dog_die8 = [ 15, dog_die9 ]
{
};

void() dog_die9 = [ 16, dog_die9 ]
{
};

void() dog_dieb1 = [ 17, dog_dieb2 ]
{
};

void() dog_dieb2 = [ 18, dog_dieb3 ]
{
};

void() dog_dieb3 = [ 19, dog_dieb4 ]
{
};

void() dog_dieb4 = [ 20, dog_dieb5 ]
{
};

void() dog_dieb5 = [ 21, dog_dieb6 ]
{
};

void() dog_dieb6 = [ 22, dog_dieb7 ]
{
};

void() dog_dieb7 = [ 23, dog_dieb8 ]
{
};

void() dog_dieb8 = [ 24, dog_dieb9 ]
{
};

void() dog_dieb9 = [ 25, dog_dieb9 ]
{
};

void() dog_die =
{
	if ((self.health < -35))
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", START_OFF, ATTN_NORM);
		ThrowGib("progs/gib3.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		ThrowHead("progs/h_dog.mdl", self.health);
		return;
	}
	sound(self, CHAN_VOICE, "dog/ddeath.wav", START_OFF, ATTN_NORM);
	self.solid = SOLID_NOT;
	if ((random() > MON_BACKTIME))
	{
		dog_die1();
	}
	else
	{
		dog_dieb1();
	}
};

float() CheckDogMelee =
{
	if ((enemy_range == RANGE_MELEE))
	{
		self.attack_state = AS_MELEE;
		return (TRUE);
	}
	return (FALSE);
};

float() CheckDogJump =
{
	local vector dist;
	local float d;

	if (((self.origin_z + self.mins_z) > ((self.enemy.origin_z + self.enemy.mins_z) + (0.75 * self.enemy.size_z))))
	{
		return (FALSE);
	}
	if (((self.origin_z + self.maxs_z) < ((self.enemy.origin_z + self.enemy.mins_z) + (0.25 * self.enemy.size_z))))
	{
		return (FALSE);
	}
	dist = (self.enemy.origin - self.origin);
	dist_z = WF_NORMAL;
	d = vlen(dist);
	if ((d < 80))
	{
		return (FALSE);
	}
	if ((d > 150))
	{
		return (FALSE);
	}
	return (TRUE);
};

float() DogCheckAttack =
{
	//local vector vec; // unused

	if (CheckDogMelee())
	{
		self.attack_state = AS_MELEE;
		return (TRUE);
	}
	if (CheckDogJump())
	{
		self.attack_state = AS_MISSILE;
		return (TRUE);
	}
	return (FALSE);
};

void() monster_dog =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model("progs/h_dog.mdl");
	precache_model("progs/dog.mdl");
	precache_sound("dog/dattack1.wav");
	precache_sound("dog/ddeath.wav");
	precache_sound("dog/dpain1.wav");
	precache_sound("dog/dsight.wav");
	precache_sound("dog/idle.wav");
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel(self, "progs/dog.mdl");
	setsize(self, VEC_HULL2_MIN, '32 32 40');
	self.health = 25;
	self.th_stand = dog_stand1;
	self.th_walk = dog_walk1;
	self.th_run = dog_run1;
	self.th_pain = dog_pain;
	self.th_die = dog_die;
	self.th_melee = dog_atta1;
	self.th_missile = dog_leap1;
	walkmonster_start();
};
.float inpain;

void() zomb_stand =
{
	mon_ai_stand();
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= DOOR_GOLD_KEY))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (SVC_SELLSCREEN + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			self.framtime = (time + 0.02);
		}
		else
		{
			if ((self.walkframe >= 15))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (WF_NORMAL + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			self.framtime = (time + MON_MAGICCHANCE);
		}
	}
	self.think = zomb_stand;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() zomb_run =
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
			self.frame = (SVC_SELLSCREEN + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			self.framtime = (time + 0.02);
		}
		else
		{
			if ((self.walkframe >= 18))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (15 + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			self.framtime = (time + MON_MAGICCHANCE);
		}
	}
	self.think = zomb_run;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() ZombieGrenadeTouch =
{
	if ((other == self.owner))
	{
		return;
	}
	if (other.takedamage)
	{
		T_Damage(other, self, self.owner, SVC_SETVIEWANGLES);
		sound(self, CHAN_WEAPON, "zombie/z_hit.wav", START_OFF, ATTN_NORM);
		remove(self);
		return;
	}
	sound(self, CHAN_WEAPON, "zombie/z_miss.wav", START_OFF, ATTN_NORM);
	self.velocity = VEC_ORIGIN;
	self.avelocity = VEC_ORIGIN;
	self.touch = SUB_Remove;
};

void() zomb_fire =
{
	local entity missile;
	//local entity mpuff; // unused
	local vector org;
	local vector st;

	self.shootframe = TRUE;
	self.walkframe = WF_NORMAL;
	self.attack_finished = (time + 0.9);
	sound(self, CHAN_WEAPON, "zombie/z_shot1.wav", START_OFF, ATTN_NORM);
	st = '-10 -22 30';
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	org = (((self.origin + (st_x * v_forward)) + (st_y * v_right)) + ((st_z - chasecam_zofs) * v_up));
	makevectors(self.angles);
	missile.velocity = normalize((self.enemy.origin - org));
	missile.velocity = (missile.velocity * 800);
	missile.velocity_z = 150;
	missile.avelocity = '500 600 700';
	missile.touch = ZombieGrenadeTouch;
	missile.nextthink = (time + 2.5);
	missile.think = SUB_Remove;
	setmodel(missile, "progs/zom_gib.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, org);
};

void() zomb_die1 =
{
	self.frame = (41 + self.walkframe);
	self.think = zomb_die1;
	self.nextthink = (time + 0.07);
	self.walkframe = (self.walkframe + START_OFF);
	if ((self.walkframe >= SVC_SETVIEWANGLES))
	{
		self.nextthink = CONTENT_EMPTY;
		MonsterDead();
	}
};

void() zomb_die2 =
{
	self.frame = (51 + self.walkframe);
	self.think = zomb_die2;
	self.nextthink = (time + 0.07);
	self.walkframe = (self.walkframe + START_OFF);
	if ((self.walkframe >= 12))
	{
		self.nextthink = CONTENT_EMPTY;
		MonsterDead();
	}
};

void() zomb_die =
{
	DropItem();
	GiveExp();
	self.solid = SOLID_NOT;
	if ((self.health < -35))
	{
		sound(self, CHAN_VOICE, "zombie/z_gib.wav", START_OFF, ATTN_NORM);
		ThrowHead("progs/h_zombie.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib2.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		MonsterDead();
		return;
	}
	if ((random() < MON_BACKTIME))
	{
		sound(self, CHAN_VOICE, "zombie/z_pain.wav", START_OFF, ATTN_NORM);
	}
	else
	{
		sound(self, CHAN_VOICE, "zombie/z_pain1.wav", START_OFF, ATTN_NORM);
	}
	self.walkframe = WF_NORMAL;
	if ((random() < MON_BACKTIME))
	{
		zomb_die1();
	}
	else
	{
		zomb_die2();
	}
};

void(entity e) spawn_zombie =
{
	local entity m;
	local entity spot;

	if (deathmatch)
	{
		bprint("it is a single player game\n");
		return;
	}
	spot = MonterSpawnPoint();
	m = spawn();
	m.solid = SOLID_SLIDEBOX;
	m.movetype = MOVETYPE_STEP;
	setmodel(m, "progs/monster7.mdl");
	setsize(m, VEC_HULL_MIN, '16 16 40');
	m.health = 120;
	m.speed = 200;
	m.exp = TE_LIGHTNING3;
	m.misspeed = 600;
	m.netname = "zombie";
	m.skin = WF_NORMAL;
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
	m.think = walkmonster_start;
	m.nextthink = time;
	m.th_stand = zomb_stand;
	m.th_run = zomb_run;
	m.th_die = zomb_die;
	m.th_missile = zomb_fire;
};
