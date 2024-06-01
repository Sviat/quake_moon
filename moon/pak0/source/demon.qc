//Decompiled code. Please respect the original copyright.
void() Demon_JumpTouch;

void() demon1_stand1 = [ 0, demon1_stand2 ]
{
	ai_stand();
};

void() demon1_stand2 = [ 1, demon1_stand3 ]
{
	ai_stand();
};

void() demon1_stand3 = [ 2, demon1_stand4 ]
{
	ai_stand();
};

void() demon1_stand4 = [ 3, demon1_stand5 ]
{
	ai_stand();
};

void() demon1_stand5 = [ 4, demon1_stand6 ]
{
	ai_stand();
};

void() demon1_stand6 = [ 5, demon1_stand7 ]
{
	ai_stand();
};

void() demon1_stand7 = [ 6, demon1_stand8 ]
{
	ai_stand();
};

void() demon1_stand8 = [ 7, demon1_stand9 ]
{
	ai_stand();
};

void() demon1_stand9 = [ 8, demon1_stand10 ]
{
	ai_stand();
};

void() demon1_stand10 = [ 9, demon1_stand11 ]
{
	ai_stand();
};

void() demon1_stand11 = [ 10, demon1_stand12 ]
{
	ai_stand();
};

void() demon1_stand12 = [ 11, demon1_stand13 ]
{
	ai_stand();
};

void() demon1_stand13 = [ 12, demon1_stand1 ]
{
	ai_stand();
};

void() demon1_walk1 = [ 13, demon1_walk2 ]
{
	if ((random() < MON_REACTIONTIME))
	{
		sound(self, CHAN_VOICE, "demon/idle1.wav", START_OFF, ATTN_IDLE);
	}
	ai_walk(DOOR_GOLD_KEY);
};

void() demon1_walk2 = [ 14, demon1_walk3 ]
{
	ai_walk(LOGIC_HUNTENEMY);
};

void() demon1_walk3 = [ 15, demon1_walk4 ]
{
	ai_walk(LOGIC_HUNTENEMY);
};

void() demon1_walk4 = [ 16, demon1_walk5 ]
{
	ai_walk(TE_WIZSPIKE);
};

void() demon1_walk5 = [ 17, demon1_walk6 ]
{
	ai_walk(DOOR_DONT_LINK);
};

void() demon1_walk6 = [ 18, demon1_walk7 ]
{
	ai_walk(LOGIC_HUNTENEMY);
};

void() demon1_walk7 = [ 19, demon1_walk8 ]
{
	ai_walk(SVC_SETVIEWANGLES);
};

void() demon1_walk8 = [ 20, demon1_walk1 ]
{
	ai_walk(SVC_SETVIEWANGLES);
};

void() demon1_run1 = [ 21, demon1_run2 ]
{
	if ((random() < MON_REACTIONTIME))
	{
		sound(self, CHAN_VOICE, "demon/idle1.wav", START_OFF, ATTN_IDLE);
	}
	ai_run(GRD_PATROLTIME);
};

void() demon1_run2 = [ 22, demon1_run3 ]
{
	ai_run(15);
};

void() demon1_run3 = [ 23, demon1_run4 ]
{
	ai_run(36);
};

void() demon1_run4 = [ 24, demon1_run5 ]
{
	ai_run(GRD_PATROLTIME);
};

void() demon1_run5 = [ 25, demon1_run6 ]
{
	ai_run(15);
};

void() demon1_run6 = [ 26, demon1_run1 ]
{
	ai_run(36);
};

void() demon1_jump1 = [ 27, demon1_jump2 ]
{
	ai_face();
};

void() demon1_jump2 = [ 28, demon1_jump3 ]
{
	ai_face();
};

void() demon1_jump3 = [ 29, demon1_jump4 ]
{
	ai_face();
};

void() demon1_jump4 = [ 30, demon1_jump5 ]
{
	ai_face();
	self.touch = Demon_JumpTouch;
	makevectors(self.angles);
	self.origin_z = (self.origin_z + START_OFF);
	self.velocity = ((v_forward * 600) + '0 0 250');
	if ((self.flags & FL_ONGROUND))
	{
		self.flags = (self.flags - FL_ONGROUND);
	}
};

void() demon1_jump5 = [ 31, demon1_jump6 ]
{
};

void() demon1_jump6 = [ 32, demon1_jump7 ]
{
};

void() demon1_jump7 = [ 33, demon1_jump8 ]
{
};

void() demon1_jump8 = [ 34, demon1_jump9 ]
{
};

void() demon1_jump9 = [ 35, demon1_jump10 ]
{
};

void() demon1_jump10 = [ 36, demon1_jump1 ]
{
	self.nextthink = (time + LOGIC_FINDDEFEND);
};

void() demon1_jump11 = [ 37, demon1_jump12 ]
{
};

void() demon1_jump12 = [ 38, demon1_run1 ]
{
};

void() demon1_atta1 = [ 54, demon1_atta2 ]
{
	ai_charge(DOOR_DONT_LINK);
};

void() demon1_atta2 = [ 55, demon1_atta3 ]
{
	ai_charge(WF_NORMAL);
};

void() demon1_atta3 = [ 56, demon1_atta4 ]
{
	ai_charge(WF_NORMAL);
};

void() demon1_atta4 = [ 57, demon1_atta5 ]
{
	ai_charge(START_OFF);
};

void() demon1_atta5 = [ 58, demon1_atta6 ]
{
	ai_charge(SILENT);
	Demon_Melee(200);
};

void() demon1_atta6 = [ 59, demon1_atta7 ]
{
	ai_charge(START_OFF);
};

void() demon1_atta7 = [ 60, demon1_atta8 ]
{
	ai_charge(LOGIC_HUNTENEMY);
};

void() demon1_atta8 = [ 61, demon1_atta9 ]
{
	ai_charge(DOOR_GOLD_KEY);
};

void() demon1_atta9 = [ 62, demon1_atta10 ]
{
	ai_charge(DOOR_DONT_LINK);
};

void() demon1_atta10 = [ 63, demon1_atta11 ]
{
	ai_charge(SILENT);
};

void() demon1_atta11 = [ 64, demon1_atta12 ]
{
	Demon_Melee(-200);
};

void() demon1_atta12 = [ 65, demon1_atta13 ]
{
	ai_charge(SVC_SETVIEWPORT);
};

void() demon1_atta13 = [ 66, demon1_atta14 ]
{
	ai_charge(DOOR_GOLD_KEY);
};

void() demon1_atta14 = [ 67, demon1_atta15 ]
{
	ai_charge(DOOR_DONT_LINK);
};

void() demon1_atta15 = [ 68, demon1_run1 ]
{
	ai_charge(DOOR_DONT_LINK);
};

void() demon1_pain1 = [ 39, demon1_pain2 ]
{
};

void() demon1_pain2 = [ 40, demon1_pain3 ]
{
};

void() demon1_pain3 = [ 41, demon1_pain4 ]
{
};

void() demon1_pain4 = [ 42, demon1_pain5 ]
{
};

void() demon1_pain5 = [ 43, demon1_pain6 ]
{
};

void() demon1_pain6 = [ 44, demon1_run1 ]
{
};

void(entity attacker, float damage) demon1_pain =
{
	if ((self.touch == Demon_JumpTouch))
	{
		return;
	}
	if ((self.pain_finished > time))
	{
		return;
	}
	self.pain_finished = (time + START_OFF);
	sound(self, CHAN_VOICE, "demon/dpain1.wav", START_OFF, ATTN_NORM);
	if (((random() * 200) > damage))
	{
		return;
	}
	demon1_pain1();
};

void() demon1_die1 = [ 45, demon1_die2 ]
{
	sound(self, CHAN_VOICE, "demon/ddeath.wav", START_OFF, ATTN_NORM);
};

void() demon1_die2 = [ 46, demon1_die3 ]
{
};

void() demon1_die3 = [ 47, demon1_die4 ]
{
};

void() demon1_die4 = [ 48, demon1_die5 ]
{
};

void() demon1_die5 = [ 49, demon1_die6 ]
{
};

void() demon1_die6 = [ 50, demon1_die7 ]
{
	self.solid = SOLID_NOT;
};

void() demon1_die7 = [ 51, demon1_die8 ]
{
};

void() demon1_die8 = [ 52, demon1_die9 ]
{
};

void() demon1_die9 = [ 53, demon1_die9 ]
{
};

void() demon_die =
{
	if ((self.health < -80))
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", START_OFF, ATTN_NORM);
		ThrowHead("progs/h_demon.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		return;
	}
	demon1_die1();
};

void() Demon_MeleeAttack =
{
	demon1_atta1();
};

void() monster_demon1 =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model("progs/demon.mdl");
	precache_model("progs/h_demon.mdl");
	precache_sound("demon/ddeath.wav");
	precache_sound("demon/dhit2.wav");
	precache_sound("demon/djump.wav");
	precache_sound("demon/dpain1.wav");
	precache_sound("demon/idle1.wav");
	precache_sound("demon/sight2.wav");
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel(self, "progs/demon.mdl");
	setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 300;
	self.th_stand = demon1_stand1;
	self.th_walk = demon1_walk1;
	self.th_run = demon1_run1;
	self.th_die = demon_die;
	self.th_melee = Demon_MeleeAttack;
	self.th_missile = demon1_jump1;
	self.th_pain = demon1_pain;
	walkmonster_start();
};

float() CheckDemonMelee =
{
	if ((enemy_range == RANGE_MELEE))
	{
		self.attack_state = AS_MELEE;
		return (TRUE);
	}
	return (FALSE);
};

float() CheckDemonJump =
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
	if ((d < 100))
	{
		return (FALSE);
	}
	if ((d > 200))
	{
		if ((random() < 0.9))
		{
			return (FALSE);
		}
	}
	return (TRUE);
};

float() DemonCheckAttack =
{
	local vector vec;

	if (CheckDemonMelee())
	{
		self.attack_state = AS_MELEE;
		return (TRUE);
	}
	if (CheckDemonJump())
	{
		self.attack_state = AS_MISSILE;
		sound(self, CHAN_VOICE, "demon/djump.wav", START_OFF, ATTN_NORM);
		return (TRUE);
	}
	return (FALSE);
};

void(float side) Demon_Melee =
{
	local float ldmg;
	local vector delta;

	ai_face();
	walkmove(self.ideal_yaw, 12);
	delta = (self.enemy.origin - self.origin);
	if ((vlen(delta) > 100))
	{
		return;
	}
	if (!CanDamage(self.enemy, self))
	{
		return;
	}
	sound(self, CHAN_WEAPON, "demon/dhit2.wav", START_OFF, ATTN_NORM);
	ldmg = (SVC_SETVIEWANGLES + (SVC_SETVIEWPORT * random()));
	T_Damage(self.enemy, self, self, ldmg);
	makevectors(self.angles);
	SpawnMeatSpray((self.origin + (v_forward * DOOR_SILVER_KEY)), (side * v_right));
};

void() Demon_JumpTouch =
{
	local float ldmg;

	if ((self.health <= WF_NORMAL))
	{
		return;
	}
	if (other.takedamage)
	{
		if ((vlen(self.velocity) > 400))
		{
			ldmg = (GRD_DEFENDTIME + (SVC_SETVIEWANGLES * random()));
			T_Damage(other, self, self, ldmg);
		}
	}
	if (!checkbottom(self))
	{
		if ((self.flags & FL_ONGROUND))
		{
			self.touch = SUB_Null;
			self.think = demon1_jump1;
			self.nextthink = (time + MON_CAMPERCHANCE);
		}
		return;
	}
	self.touch = SUB_Null;
	self.think = demon1_jump11;
	self.nextthink = (time + MON_CAMPERCHANCE);
};

void() sham_stand =
{
	mon_ai_stand();
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= TE_WIZSPIKE))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (68 + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
		}
		else
		{
			if ((self.walkframe >= 17))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (WF_NORMAL + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
		}
		self.framtime = (time + 0.07);
	}
	self.think = sham_stand;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() sham_run1 =
{
};

void() sham_run =
{
	mon_ai_run(MON_WALKDIST);
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= TE_WIZSPIKE))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (68 + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
		}
		else
		{
			if ((self.walkframe >= LOGIC_HUNTENEMY))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (29 + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
		}
		self.framtime = (time + 0.07);
	}
	self.think = sham_run;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() sham_smash1 = [ 35, sham_smash2 ]
{
	sound(self, CHAN_VOICE, "shambler/melee1.wav", START_OFF, ATTN_NORM);
	ai_charge(SILENT);
};

void() sham_smash2 = [ 36, sham_smash3 ]
{
	ai_charge(LOGIC_HUNTENEMY);
};

void() sham_smash3 = [ 37, sham_smash4 ]
{
	ai_charge(LOGIC_HUNTENEMY);
};

void() sham_smash4 = [ 38, sham_smash5 ]
{
	ai_charge(SVC_SETVIEWPORT);
};

void() sham_smash5 = [ 39, sham_smash6 ]
{
	ai_charge(DOOR_DONT_LINK);
};

void() sham_smash6 = [ 40, sham_smash7 ]
{
	ai_charge(START_OFF);
};

void() sham_smash7 = [ 41, sham_smash8 ]
{
	ai_charge(WF_NORMAL);
};

void() sham_smash8 = [ 42, sham_smash9 ]
{
	ai_charge(WF_NORMAL);
};

void() sham_smash9 = [ 43, sham_smash10 ]
{
	ai_charge(WF_NORMAL);
};

void() sham_smash10 = [ 44, sham_smash11 ]
{
	local vector delta;
	local float ldmg;

	if (!self.enemy)
	{
		return;
	}
	ai_charge(WF_NORMAL);
	delta = (self.enemy.origin - self.origin);
	if ((vlen(delta) > 100))
	{
		return;
	}
	if (!CanDamage(self.enemy, self))
	{
		return;
	}
	ldmg = (((random() + random()) + random()) * GRD_DEFENDTIME);
	T_Damage(self.enemy, self, self, ldmg);
	sound(self, CHAN_VOICE, "shambler/smack.wav", START_OFF, ATTN_NORM);
	SpawnMeatSpray((self.origin + (v_forward * DOOR_SILVER_KEY)), ((crandom() * 100) * v_right));
	SpawnMeatSpray((self.origin + (v_forward * DOOR_SILVER_KEY)), ((crandom() * 100) * v_right));
};

void() sham_smash11 = [ 45, sham_smash12 ]
{
	ai_charge(SVC_SETVIEWPORT);
};

void() sham_smash12 = [ 46, sham_run1 ]
{
	ai_charge(DOOR_DONT_LINK);
};

void(float side) ShamClaw =
{
	local vector delta;
	local float ldmg;

	if (!self.enemy)
	{
		return;
	}
	ai_charge(SVC_SETVIEWANGLES);
	delta = (self.enemy.origin - self.origin);
	if ((vlen(delta) > 100))
	{
		return;
	}
	ldmg = (((random() + random()) + random()) * GRD_PATROLTIME);
	T_Damage(self.enemy, self, self, ldmg);
	sound(self, CHAN_VOICE, "shambler/smack.wav", START_OFF, ATTN_NORM);
	if (side)
	{
		makevectors(self.angles);
		SpawnMeatSpray((self.origin + (v_forward * DOOR_SILVER_KEY)), (side * v_right));
	}
};

void() sham_swingl1 = [ 56, sham_swingl2 ]
{
	sound(self, CHAN_VOICE, "shambler/melee2.wav", START_OFF, ATTN_NORM);
	ai_charge(SVC_SETVIEWPORT);
};

void() sham_swingl2 = [ 57, sham_swingl3 ]
{
	ai_charge(LOGIC_FINDDEFEND);
};

void() sham_swingl3 = [ 58, sham_swingl4 ]
{
	ai_charge(TE_WIZSPIKE);
};

void() sham_swingl4 = [ 59, sham_swingl5 ]
{
	ai_charge(LOGIC_FINDDEFEND);
};

void() sham_swingl5 = [ 60, sham_swingl6 ]
{
	ai_charge(TE_WIZSPIKE);
};

void() sham_swingl6 = [ 61, sham_swingl7 ]
{
	ai_charge(TE_LIGHTNING3);
};

void() sham_swingl7 = [ 62, sham_swingl8 ]
{
	ai_charge(SVC_SETVIEWPORT);
	ShamClaw(250);
};

void() sham_swingl8 = [ 63, sham_swingl9 ]
{
	ai_charge(DOOR_DONT_LINK);
};

void() sham_swingl9 = [ 64, sham_run1 ]
{
	ai_charge(DOOR_GOLD_KEY);
	if ((random() < MON_BACKTIME))
	{
		self.think = sham_swingr1;
	}
};

void() sham_swingr1 = [ 47, sham_swingr2 ]
{
	sound(self, CHAN_VOICE, "shambler/melee1.wav", START_OFF, ATTN_NORM);
	ai_charge(START_OFF);
};

void() sham_swingr2 = [ 48, sham_swingr3 ]
{
	ai_charge(DOOR_GOLD_KEY);
};

void() sham_swingr3 = [ 49, sham_swingr4 ]
{
	ai_charge(14);
};

void() sham_swingr4 = [ 50, sham_swingr5 ]
{
	ai_charge(TE_WIZSPIKE);
};

void() sham_swingr5 = [ 51, sham_swingr6 ]
{
	ai_charge(LOGIC_FINDDEFEND);
};

void() sham_swingr6 = [ 52, sham_swingr7 ]
{
	ai_charge(LOGIC_HUNTENEMY);
};

void() sham_swingr7 = [ 53, sham_swingr8 ]
{
	ai_charge(LOGIC_HUNTENEMY);
	ShamClaw(-250);
};

void() sham_swingr8 = [ 54, sham_swingr9 ]
{
	ai_charge(LOGIC_FINDDEFEND);
};

void() sham_swingr9 = [ 55, sham_run1 ]
{
	ai_charge(START_OFF);
	ai_charge(SVC_SETVIEWANGLES);
	if ((random() < MON_BACKTIME))
	{
		self.think = sham_swingl1;
	}
};

void() sham_melee =
{
	local float chance;

	chance = random();
	if (((chance > 0.6) || (self.health == 600)))
	{
		sham_smash1();
	}
	else
	{
		if ((chance > 0.3))
		{
			sham_swingr1();
		}
		else
		{
			sham_swingl1();
		}
	}
};

void() CastLightning =
{
	local vector org;
	local vector dir;

	self.effects = (self.effects | EF_MUZZLEFLASH);
	ai_face();
	org = (self.origin + '0 0 70');
	dir = ((self.enemy.origin + '0 0 16') - org);
	dir = normalize(dir);
	traceline(org, (self.origin + (dir * 600)), TRUE, self);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING1);
	WriteEntity(MSG_BROADCAST, self);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);
	LightningDamage(org, trace_endpos, self, SVC_SETVIEWANGLES);
	sound(self, CHAN_WEAPON, "weapons/lhit.wav", START_OFF, ATTN_NORM);
	if ((random() < MON_CAMPERCHANCE))
	{
		self.attack_finished = ((time + START_OFF) + random());
	}
};

void() sham_startfire =
{
	local entity o;

	sound(self, CHAN_WEAPON, "shambler/sattck1.wav", START_OFF, ATTN_NORM);
	self.shootframe = TRUE;
	self.walkframe = WF_NORMAL;
	self.effects = (self.effects | EF_MUZZLEFLASH);
	ai_face();
	self.owner = spawn();
	o = self.owner;
	setmodel(o, "progs/s_light.mdl");
	setorigin(o, self.origin);
	o.angles = self.angles;
	o.nextthink = (time + MON_CAMPERCHANCE);
	o.think = SUB_Remove;
	CastLightning();
	self.attack_finished = (time + MON_CAMPERCHANCE);
};

void() sham_magic1 = [ 65, sham_magic2 ]
{
	ai_face();
	sound(self, CHAN_WEAPON, "shambler/sattck1.wav", START_OFF, ATTN_NORM);
};

void() sham_magic2 = [ 66, sham_magic3 ]
{
	ai_face();
};

void() sham_magic3 = [ 67, sham_magic4 ]
{
	ai_face();
	self.nextthink = (self.nextthink + MON_REACTIONTIME);
};

void() sham_magic4 = [ 68, sham_magic5 ]
{
	self.effects = (self.effects | EF_MUZZLEFLASH);
	self.owner.frame = START_OFF;
};

void() sham_magic5 = [ 69, sham_magic6 ]
{
	self.effects = (self.effects | EF_MUZZLEFLASH);
	self.owner.frame = SILENT;
};

void() sham_magic6 = [ 70, sham_magic9 ]
{
	remove(self.owner);
	CastLightning();
	sound(self, CHAN_WEAPON, "shambler/sboom.wav", START_OFF, ATTN_NORM);
};

void() sham_magic9 = [ 73, sham_magic10 ]
{
	CastLightning();
};

void() sham_magic10 = [ 74, sham_magic11 ]
{
	CastLightning();
};

void() sham_magic11 = [ 75, sham_magic12 ]
{
	if ((skill == LOGIC_FINDDEFEND))
	{
		CastLightning();
	}
};

void() sham_magic12 = [ 76, sham_run1 ]
{
};

void() sham_pain1 = [ 77, sham_pain2 ]
{
};

void() sham_pain2 = [ 78, sham_pain3 ]
{
};

void() sham_pain3 = [ 79, sham_pain4 ]
{
};

void() sham_pain4 = [ 80, sham_pain5 ]
{
};

void() sham_pain5 = [ 81, sham_pain6 ]
{
};

void() sham_pain6 = [ 82, sham_run1 ]
{
};

void() sham_death1 = [ 83, sham_death2 ]
{
};

void() sham_death2 = [ 84, sham_death3 ]
{
};

void() sham_death3 = [ 85, sham_death4 ]
{
};

void() sham_death4 = [ 86, sham_death5 ]
{
};

void() sham_death5 = [ 87, sham_death6 ]
{
};

void() sham_death6 = [ 88, sham_death7 ]
{
};

void() sham_death7 = [ 89, sham_death8 ]
{
};

void() sham_death8 = [ 90, sham_death9 ]
{
};

void() sham_death9 = [ 91, sham_death10 ]
{
};

void() sham_death10 = [ 92, sham_death11 ]
{
};

void() sham_death11 = [ 93, sham_death11 ]
{
	MonsterDead();
};

void() sham_die =
{
	DropItem();
	GiveExp();
	self.solid = SOLID_NOT;
	if ((self.health < -60))
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", START_OFF, ATTN_NORM);
		ThrowHead("progs/h_shams.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib2.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		MonsterDead();
		return;
	}
	sound(self, CHAN_VOICE, "shambler/sdeath.wav", START_OFF, ATTN_NORM);
	sham_death1();
};

void(entity e) spawn_shambler =
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
	setmodel(m, "progs/shambler.mdl");
	setsize(m, VEC_HULL2_MIN, VEC_HULL2_MAX);
	m.health = 400;
	m.speed = 220;
	m.exp = DOOR_SILVER_KEY;
	m.misspeed = 1000;
	m.netname = "shambler";
	m.origin = spot.origin;
	m.nextthink = time;
	m.think = walkmonster_start_go;
	m.angles = spot.angles;
	m.attack_finished = time;
	m.shootframe = FALSE;
	makevectors(m.angles);
	spawn_tfog((m.origin + (v_forward * GRD_PATROLTIME)));
	spawn_tdeath(m.origin, m);
	e.count = (e.count - START_OFF);
	m.th_stand = sham_stand;
	m.th_run = sham_run;
	m.th_die = sham_die;
	m.th_missile = sham_startfire;
};

void() knight_stand =
{
	mon_ai_stand();
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= SVC_SETVIEWANGLES))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (17 + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			self.framtime = (time + MON_UNIQUECHANCE);
		}
		else
		{
			if ((self.walkframe >= TE_LIGHTNING3))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (WF_NORMAL + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			self.framtime = (time + 0.07);
		}
	}
	self.think = knight_stand;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() knight_run =
{
	mon_ai_run(MON_WALKDIST);
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= SVC_SETVIEWANGLES))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (17 + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			self.framtime = (time + MON_UNIQUECHANCE);
		}
		else
		{
			if ((self.walkframe >= DOOR_GOLD_KEY))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (TE_LIGHTNING3 + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			self.framtime = (time + 0.07);
		}
	}
	self.think = knight_run;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() knight_die1 = [ 76, knight_die2 ]
{
};

void() knight_die2 = [ 77, knight_die3 ]
{
};

void() knight_die3 = [ 78, knight_die4 ]
{
};

void() knight_die4 = [ 79, knight_die5 ]
{
};

void() knight_die5 = [ 80, knight_die6 ]
{
};

void() knight_die6 = [ 81, knight_die7 ]
{
};

void() knight_die7 = [ 82, knight_die8 ]
{
};

void() knight_die8 = [ 83, knight_die9 ]
{
};

void() knight_die9 = [ 84, knight_die10 ]
{
};

void() knight_die10 = [ 85, knight_die10 ]
{
	MonsterDead();
};

void() knight_dieb1 = [ 86, knight_dieb2 ]
{
};

void() knight_dieb2 = [ 87, knight_dieb3 ]
{
};

void() knight_dieb3 = [ 88, knight_dieb4 ]
{
};

void() knight_dieb4 = [ 89, knight_dieb5 ]
{
};

void() knight_dieb5 = [ 90, knight_dieb6 ]
{
};

void() knight_dieb6 = [ 91, knight_dieb7 ]
{
};

void() knight_dieb7 = [ 92, knight_dieb8 ]
{
};

void() knight_dieb8 = [ 93, knight_dieb9 ]
{
};

void() knight_dieb9 = [ 94, knight_dieb10 ]
{
};

void() knight_dieb10 = [ 95, knight_dieb11 ]
{
};

void() knight_dieb11 = [ 96, knight_dieb11 ]
{
	MonsterDead();
};

void() knight_die =
{
	self.solid = SOLID_NOT;
	DropItem();
	GiveExp();
	if ((self.health < -40))
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", START_OFF, ATTN_NORM);
		ThrowHead("progs/h_knight.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib2.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		MonsterDead();
		return;
	}
	sound(self, CHAN_VOICE, "knight/kdeath.wav", START_OFF, ATTN_NORM);
	if ((random() < MON_BACKTIME))
	{
		knight_die1();
	}
	else
	{
		knight_dieb1();
	}
};

void() knight_atk =
{
	local vector delta;
	local float ldmg;

	if (!self.enemy)
	{
		return;
	}
	delta = (self.enemy.origin - self.origin);
	if ((vlen(delta) > 80))
	{
		return;
	}
	self.walkframe = WF_NORMAL;
	self.shootframe = START_OFF;
	sound(self, CHAN_WEAPON, "knight/sword1.wav", START_OFF, ATTN_NORM);
	ldmg = (((random() + random()) + random()) * LOGIC_FINDDEFEND);
	T_Damage(self.enemy, self, self, ldmg);
	self.attack_finished = ((time + MON_CAMPERCHANCE) + self.rfr);
};

void(entity e, float enc) spawn_knight =
{
	local entity m;
	local entity spot;
	local float unique;

	spot = MonterSpawnPoint();
	m = spawn();
	m.solid = SOLID_SLIDEBOX;
	m.movetype = MOVETYPE_STEP;
	m.takedamage = DAMAGE_AIM;
	setmodel(m, "progs/knight.mdl");
	setsize(m, VEC_HULL2_MIN, VEC_HULL2_MAX);
	m.netname = "knight";
	m.skin = WF_NORMAL;
	m.melee = START_OFF;
	m.speed = 320;
	if ((enc == WF_NORMAL))
	{
		m.health = 75;
		m.exp = 12;
		m.misspeed = 600;
		m.dmg = MON_CAMPTIME;
	}
	else
	{
		if ((enc == START_OFF))
		{
			m.health = 150;
			m.exp = DOOR_SILVER_KEY;
			m.misspeed = 800;
			m.dmg = 60;
			m.prefix_two = "punitive ";
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
		m.exp = (m.exp * SILENT);
	}
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
	m.th_stand = knight_stand;
	m.th_run = knight_run;
	m.th_missile = knight_atk;
	m.th_die = knight_die;
};
void(vector vec) SpiderMissile;

void() spid_stand =
{
	mon_ai_stand();
	if ((self.framtime < time))
	{
		if ((self.walkframe >= SVC_SETVIEWANGLES))
		{
			self.walkframe = WF_NORMAL;
		}
		self.frame = (SVC_FOUNDSECRET + self.walkframe);
		self.walkframe = (self.walkframe + START_OFF);
		self.framtime = (time + 0.07);
	}
	self.think = spid_stand;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() spid_run =
{
	mon_ai_run(MON_WALKDIST);
	if ((self.framtime < time))
	{
		if ((self.walkframe >= DOOR_GOLD_KEY))
		{
			self.walkframe = WF_NORMAL;
		}
		self.frame = (WF_NORMAL + self.walkframe);
		self.walkframe = (self.walkframe + START_OFF);
		self.framtime = (time + 0.07);
	}
	self.think = spid_run;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() spid_death1 = [ 10, spid_death3 ]
{
};
void() spid_death3;

void() spid_death2 = [ 10, spid_death3 ]
{
};

void() spid_death3 = [ 11, spid_death4 ]
{
};

void() spid_death4 = [ 12, spid_death5 ]
{
};

void() spid_death5 = [ 13, spid_death6 ]
{
};

void() spid_death6 = [ 14, spid_death7 ]
{
};

void() spid_death7 = [ 15, spid_death8 ]
{
};

void() spid_death8 = [ 16, spid_death9 ]
{
};

void() spid_death9 = [ 17, spid_death10 ]
{
};

void() spid_death10 = [ 18, spid_death11 ]
{
};

void() spid_death11 = [ 19, spid_death11 ]
{
	MonsterDead();
};

void() spid_deathb1 = [ 20, spid_deathb2 ]
{
};

void() spid_deathb2 = [ 21, spid_deathb3 ]
{
};

void() spid_deathb3 = [ 22, spid_deathb4 ]
{
};

void() spid_deathb4 = [ 23, spid_deathb5 ]
{
};

void() spid_deathb5 = [ 24, spid_deathb6 ]
{
};

void() spid_deathb6 = [ 25, spid_deathb7 ]
{
};

void() spid_deathb7 = [ 26, spid_deathb8 ]
{
};

void() spid_deathb8 = [ 27, spid_deathb8 ]
{
	MonsterDead();
};

void() spider_attack =
{
	sound(self, CHAN_VOICE, "moon/monsters/f_spider.wav", START_OFF, ATTN_NORM);
	SpiderMissile((self.enemy.origin - (v_right * DOOR_SILVER_KEY)));
	SpiderMissile((self.enemy.origin + (v_up * DOOR_GOLD_KEY)));
	SpiderMissile((self.enemy.origin + (v_right * DOOR_SILVER_KEY)));
	self.attack_finished = ((time + 0.85) + self.rfr);
	if ((self.ability == START_OFF))
	{
		SuperDamageSound();
	}
};

void() spidspk_touch =
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
		if ((self.poisoned == START_OFF))
		{
			spawn_touchpoison(TE_LIGHTNING3);
		}
		else
		{
			spawn_touchblood(TE_LIGHTNING3);
		}
		T_Damage(other, self, self.owner, TE_LIGHTNING3);
		if ((self.owner.poison == START_OFF))
		{
			if ((other.flags & FL_CLIENT))
			{
				other.poisoned = ((time + rint((self.owner.lvl / SILENT))) + DOOR_DONT_LINK);
				other.poison_dmg = (START_OFF + rint((self.owner.lvl / SVC_SETVIEWPORT)));
			}
		}
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_KNIGHTSPIKE);
		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
	}
	remove(self);
};

void(vector vec) SpiderMissile =
{
	local vector org;
	local vector dir;

	org = (((self.origin + self.mins) + (self.size * MON_BACKTIME)) + (v_forward * SVC_SETVIEWPORT));
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	dir = normalize((vec - org));
	newmis.angles = vectoangles(dir);
	newmis.touch = spidspk_touch;
	newmis.classname = "wizspike";
	newmis.think = SUB_Remove;
	newmis.nextthink = (time + LOGIC_HUNTENEMY);
	setmodel(newmis, "progs/w_spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, org);
	newmis.velocity = (dir * 800);
};

void() spider_die =
{
	self.solid = SOLID_NOT;
	DropItem();
	GiveExp();
	if ((self.health < -60))
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", START_OFF, ATTN_NORM);
		ThrowHead("progs/h_spider.mdl", self.health);
		ThrowGib("progs/spid_gib.mdl", self.health);
		ThrowGib("progs/spid_gib.mdl", self.health);
		ThrowGib("progs/spid_gib.mdl", self.health);
		MonsterDead();
		return;
	}
	sound(self, CHAN_VOICE, "moon/monsters/d_spider.wav", START_OFF, ATTN_NORM);
	if ((random() < MON_BACKTIME))
	{
		spid_death1();
	}
	else
	{
		spid_deathb1();
	}
};

void(entity e, float enc) spawn_spider =
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
	setmodel(m, "progs/monster2.mdl");
	setsize(m, '-22 -22 -24', '22 22 5');
	if ((enc < WF_NORMAL))
	{
		enc = WF_NORMAL;
	}
	m.green_blood = START_OFF;
	m.netname = "spider";
	m.speed = 225;
	m.lvl = enc;
	GetPrfx(m, enc);
	if ((enc == WF_NORMAL))
	{
		m.health = 180;
		m.exp = DOOR_GOLD_KEY;
	}
	else
	{
		if ((enc >= START_OFF))
		{
			m.health = (180 + (enc * GRD_PATROLTIME));
			m.exp = (DOOR_GOLD_KEY + (enc * SVC_SETVIEWPORT));
			if ((enc >= DOOR_DONT_LINK))
			{
				m.damage_bonus = (enc * TE_WIZSPIKE);
			}
			if ((random() > 0.6))
			{
				m.poison = START_OFF;
				m.netname = "poison spider";
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
	m.th_stand = spid_stand;
	m.th_run = spid_run;
	m.th_die = spider_die;
	m.th_missile = spider_attack;
	m.origin = spot.origin;
	m.nextthink = (time + (random() * MON_BACKTIME));
	m.think = walkmonster_start_go;
	m.angles = spot.angles;
	m.attack_finished = time;
	m.shootframe = FALSE;
	makevectors(m.angles);
	spawn_tdeath(m.origin, m);
	e.count = (e.count - START_OFF);
};

void() army_stand =
{
	mon_ai_stand();
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.continues == WF_NORMAL))
			{
				if ((self.walkframe >= DOOR_GOLD_KEY))
				{
					self.shootframe = FALSE;
					self.walkframe = WF_NORMAL;
				}
				self.frame = (37 + self.walkframe);
				if ((self.walkframe <= SVC_SETVIEWPORT))
				{
					self.framtime = (time + MON_REFRESHTIME);
				}
				else
				{
					self.framtime = (time + 0.07);
				}
			}
			else
			{
				if ((self.walkframe >= DOOR_GOLD_KEY))
				{
					self.shootframe = FALSE;
					self.walkframe = WF_NORMAL;
				}
				self.frame = (45 + self.walkframe);
				self.framtime = (time + 0.05);
			}
			self.walkframe = (self.walkframe + START_OFF);
		}
		else
		{
			if ((self.walkframe >= DOOR_GOLD_KEY))
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

void() army_run =
{
	mon_ai_run(MON_WALKDIST);
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.continues == WF_NORMAL))
			{
				if ((self.walkframe >= DOOR_GOLD_KEY))
				{
					self.shootframe = FALSE;
					self.walkframe = WF_NORMAL;
				}
				self.frame = (37 + self.walkframe);
				if ((self.walkframe <= SVC_SETVIEWPORT))
				{
					self.framtime = (time + MON_REFRESHTIME);
				}
				else
				{
					self.framtime = (time + 0.07);
				}
			}
			else
			{
				if (((self.walkframe >= DOOR_GOLD_KEY) || !visible(self.enemy)))
				{
					self.shootframe = FALSE;
					self.walkframe = WF_NORMAL;
				}
				self.frame = (45 + self.walkframe);
				self.framtime = (time + 0.05);
			}
			self.walkframe = (self.walkframe + START_OFF);
		}
		else
		{
			if ((self.walkframe >= DOOR_GOLD_KEY))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (29 + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
		}
		self.framtime = (time + 0.07);
	}
	self.think = army_run;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() army_fire =
{
	self.shootframe = TRUE;
	if ((self.continues == WF_NORMAL))
	{
		self.walkframe = WF_NORMAL;
	}
	if ((self.ability == START_OFF))
	{
		SuperDamageSound();
	}
	if ((self.items & IT_ROCKET_LAUNCHER))
	{
		M_FireHomeMissile();
		return;
	}
	if ((self.items & IT_SUPER_NAILGUN))
	{
		M_FireSuperNail((self.origin + '0 0 4'));
		return;
	}
	if ((self.items & IT_NAILGUN))
	{
		M_FireNail((self.origin + '0 0 4'));
		return;
	}
	if ((self.items & IT_SUPER_SHOTGUN))
	{
		M_FireSuperShotgun();
		return;
	}
	else
	{
		M_FireShotgun();
	}
};

void() army_die1 = [ 8, army_die2 ]
{
};

void() army_die2 = [ 9, army_die3 ]
{
};

void() army_die3 = [ 10, army_die4 ]
{
};

void() army_die4 = [ 11, army_die5 ]
{
};

void() army_die5 = [ 12, army_die6 ]
{
};

void() army_die6 = [ 13, army_die7 ]
{
};

void() army_die7 = [ 14, army_die8 ]
{
};

void() army_die8 = [ 15, army_die9 ]
{
};

void() army_die9 = [ 16, army_die10 ]
{
};

void() army_die10 = [ 17, army_die10 ]
{
	MonsterDead();
};

void() army_cdie1 = [ 18, army_cdie2 ]
{
};

void() army_cdie2 = [ 19, army_cdie3 ]
{
	ai_back(SVC_SETVIEWPORT);
};

void() army_cdie3 = [ 20, army_cdie4 ]
{
	ai_back(DOOR_DONT_LINK);
};

void() army_cdie4 = [ 21, army_cdie5 ]
{
	ai_back(13);
};

void() army_cdie5 = [ 22, army_cdie6 ]
{
	ai_back(LOGIC_FINDDEFEND);
};

void() army_cdie6 = [ 23, army_cdie7 ]
{
	ai_back(DOOR_DONT_LINK);
};

void() army_cdie7 = [ 24, army_cdie8 ]
{
};

void() army_cdie8 = [ 25, army_cdie9 ]
{
};

void() army_cdie9 = [ 26, army_cdie10 ]
{
};

void() army_cdie10 = [ 27, army_cdie11 ]
{
};

void() army_cdie11 = [ 28, army_cdie11 ]
{
	MonsterDead();
};

void() army_die =
{
	DropItem();
	GiveExp();
	if ((self.health < -35))
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", START_OFF, ATTN_NORM);
		ThrowHead("progs/h_guard.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib2.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		MonsterDead();
		return;
	}
	self.solid = SOLID_NOT;
	sound(self, CHAN_VOICE, "soldier/death1.wav", START_OFF, ATTN_NORM);
	if ((random() < MON_BACKTIME))
	{
		army_die1();
	}
	else
	{
		army_cdie1();
	}
};

void(entity e, float enc) spawn_soldier =
{
	local entity m;
	local entity spot;
	local float unique;
	local float zz;

	if ((enc < WF_NORMAL))
	{
		enc = WF_NORMAL;
	}
	spot = MonterSpawnPoint();
	if ((spot == world))
	{
		return;
	}
	m = spawn();
	m.solid = SOLID_SLIDEBOX;
	m.movetype = MOVETYPE_STEP;
	setmodel(m, "progs/monster0.mdl");
	setsize(m, VEC_HULL_MIN, '16 16 40');
	m.skin = WF_NORMAL;
	m.netname = "soldier";
	m.speed = 240;
	m.misspeed = 1000;
	if ((random() < MON_UNIQUECHANCE))
	{
		if ((enc != DOOR_DONT_LINK))
		{
			unique = rint(((random() * DOOR_DONT_LINK) + START_OFF));
		}
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
	GetPrfx(m, enc);
	if ((enc == WF_NORMAL))
	{
		m.health = MON_CAMPTIME;
		m.exp = SVC_SETVIEWPORT;
		if ((random() < MON_BACKTIME))
		{
			m.netname = "shotgun soldier";
			m.items = (m.items | IT_SHOTGUN);
		}
		else
		{
			m.netname = "nail soldier";
			m.continues = START_OFF;
			m.items = (m.items | IT_NAILGUN);
		}
	}
	else
	{
		if ((enc == START_OFF))
		{
			m.health = GRD_DEFENDTIME;
			m.exp = TE_WIZSPIKE;
			if ((random() < MON_BACKTIME))
			{
				m.continues = START_OFF;
				m.netname = "supernail soldier";
				m.items = (m.items | IT_SUPER_NAILGUN);
			}
			else
			{
				m.netname = "supershotgun soldier";
				m.items = (m.items | IT_SUPER_SHOTGUN);
			}
		}
		else
		{
			if ((enc >= SILENT))
			{
				zz = random();
				m.health = (MON_CAMPTIME + (enc * GRD_PATROLTIME));
				m.exp = (TE_WIZSPIKE + (enc * DOOR_DONT_LINK));
				if ((enc > SVC_SETVIEWPORT))
				{
					m.damage_bonus = ((enc * 15) - 75);
				}
				if ((zz < MON_REACTIONTIME))
				{
					m.netname = "shotgun soldier";
					m.items = (m.items | IT_SHOTGUN);
				}
				else
				{
					if ((zz < MON_STUCKTIME))
					{
						m.netname = "nail soldier";
						m.continues = START_OFF;
						m.items = (m.items | IT_NAILGUN);
					}
				}
				if ((zz < 0.7))
				{
					m.continues = START_OFF;
					m.netname = "supernail soldier";
					m.items = (m.items | IT_SUPER_NAILGUN);
				}
				else
				{
					m.netname = "supershotgun soldier";
					m.items = (m.items | IT_SUPER_SHOTGUN);
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
	m.origin = spot.origin;
	m.nextthink = (time + (random() * MON_BACKTIME));
	m.think = walkmonster_start_go;
	m.angles = spot.angles;
	m.attack_finished = time;
	m.shootframe = FALSE;
	makevectors(m.angles);
	spawn_tdeath(m.origin, m);
	e.count = (e.count - START_OFF);
	m.th_stand = army_stand;
	m.th_run = army_run;
	m.th_missile = army_fire;
	m.th_die = army_die;
};

void() less_stand =
{
	mon_ai_stand();
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= LOGIC_HUNTENEMY))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (26 + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			if ((self.walkframe <= DOOR_DONT_LINK))
			{
				self.framtime = (time + MON_REFRESHTIME);
			}
			else
			{
				self.framtime = (time + 0.07);
			}
		}
		else
		{
			if ((self.walkframe >= LOGIC_FINDDEFEND))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (SILENT + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			self.framtime = (time + MON_CAMPERCHANCE);
		}
	}
	self.think = less_stand;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() less_run =
{
	mon_ai_run(MON_WALKDIST);
	if ((self.framtime < time))
	{
		if ((self.shootframe == TRUE))
		{
			if ((self.walkframe >= LOGIC_HUNTENEMY))
			{
				self.shootframe = FALSE;
				self.walkframe = WF_NORMAL;
			}
			self.frame = (26 + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			if ((self.walkframe <= DOOR_DONT_LINK))
			{
				self.framtime = (time + MON_REFRESHTIME);
			}
			else
			{
				self.framtime = (time + 0.07);
			}
		}
		else
		{
			if ((self.walkframe >= SVC_SETVIEWANGLES))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (DOOR_SILVER_KEY + self.walkframe);
			self.walkframe = (self.walkframe + START_OFF);
			self.framtime = (time + 0.07);
		}
	}
	self.think = less_run;
	self.nextthink = (time + MON_REFRESHTIME);
};

void() less_fire =
{
	self.shootframe = TRUE;
	self.walkframe = WF_NORMAL;
	M_FireMissile();
};

void() less_die1 = [ 8, less_die2 ]
{
};

void() less_die2 = [ 9, less_die3 ]
{
};

void() less_die3 = [ 10, less_die4 ]
{
};

void() less_die4 = [ 11, less_die5 ]
{
};

void() less_die5 = [ 12, less_die6 ]
{
};

void() less_die6 = [ 13, less_die7 ]
{
};

void() less_die7 = [ 14, less_die8 ]
{
};

void() less_die8 = [ 15, less_die8 ]
{
	MonsterDead();
};

void() less_cdie1 = [ 32, less_cdie2 ]
{
};

void() less_cdie2 = [ 33, less_cdie3 ]
{
};

void() less_cdie3 = [ 34, less_cdie4 ]
{
};

void() less_cdie4 = [ 35, less_cdie5 ]
{
};

void() less_cdie5 = [ 36, less_cdie6 ]
{
};

void() less_cdie6 = [ 37, less_cdie7 ]
{
};

void() less_cdie7 = [ 38, less_cdie8 ]
{
};

void() less_cdie8 = [ 39, less_cdie9 ]
{
};

void() less_cdie9 = [ 40, less_cdie10 ]
{
};

void() less_cdie10 = [ 41, less_cdie11 ]
{
};

void() less_cdie11 = [ 42, less_cdie12 ]
{
};

void() less_cdie12 = [ 43, less_cdie13 ]
{
};

void() less_cdie13 = [ 44, less_cdie13 ]
{
	sound(self, CHAN_VOICE, "player/udeath.wav", START_OFF, ATTN_NORM);
	ThrowHead("progs/h_mon5.mdl", self.health);
	ThrowGib("progs/gib1.mdl", self.health);
	ThrowGib("progs/gib2.mdl", self.health);
	ThrowGib("progs/gib3.mdl", self.health);
	MonsterDead();
};

void() less_die =
{
	DropItem();
	GiveExp();
	if ((self.health < -50))
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", START_OFF, ATTN_NORM);
		ThrowHead("progs/h_mon5.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib2.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		MonsterDead();
		return;
	}
	self.solid = SOLID_NOT;
	sound(self, CHAN_VOICE, "moon/headless/die1.wav", START_OFF, ATTN_NORM);
	if ((random() < MON_BACKTIME))
	{
		less_die1();
	}
	else
	{
		less_cdie1();
	}
};

void(entity e) spawn_headless =
{
	local entity m;
	local entity spot;

	if (deathmatch)
	{
		bprint("it is a single player game\n");
		return;
	}
	spot = MonterSpawnPoint();
	if ((spot == world))
	{
		return;
	}
	m = spawn();
	m.solid = SOLID_SLIDEBOX;
	m.movetype = MOVETYPE_STEP;
	setmodel(m, "progs/monster5.mdl");
	setsize(m, VEC_HULL_MIN, '16 16 40');
	m.health = 120;
	m.speed = 240;
	m.exp = 14;
	m.misspeed = 1000;
	m.netname = "headless";
	m.skin = WF_NORMAL;
	m.items = (m.items | IT_ROCKET_LAUNCHER);
	m.origin = spot.origin;
	m.nextthink = (time + (random() * MON_BACKTIME));
	m.think = walkmonster_start_go;
	m.angles = spot.angles;
	m.attack_finished = time;
	m.shootframe = FALSE;
	makevectors(m.angles);
	spawn_tdeath(m.origin, m);
	e.count = (e.count - START_OFF);
	m.th_stand = less_stand;
	m.th_run = less_run;
	m.th_missile = less_fire;
	m.th_die = less_die;
};
