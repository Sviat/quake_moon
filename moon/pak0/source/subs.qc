//Decompiled code. Please respect the original copyright.

void() SUB_Null =
{
};

void() SUB_Remove =
{
	remove(self);
};

void() SetMovedir =
{
	if ((self.angles == '0 -1 0'))
	{
		self.movedir = '0 0 1';
	}
	else
	{
		if ((self.angles == '0 -2 0'))
		{
			self.movedir = '0 0 -1';
		}
		else
		{
			makevectors(self.angles);
			self.movedir = v_forward;
		}
	}
	self.angles = VEC_ORIGIN;
};

void() InitTrigger =
{
	if ((self.angles != VEC_ORIGIN))
	{
		SetMovedir();
	}
	self.solid = SOLID_TRIGGER;
	setmodel(self, self.model);
	self.movetype = MOVETYPE_NONE;
	self.modelindex = WF_NORMAL;
	self.model = s_wiz;
};

void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
	local entity stemp;

	stemp = self;
	self = ent;
	SUB_CalcMove(tdest, tspeed, func);
	self = stemp;
};

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
	local vector vdestdelta;
	local float len;
	local float traveltime;

	if (!tspeed)
	{
		objerror("No speed is defined!");
	}
	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;
	if ((tdest == self.origin))
	{
		self.velocity = VEC_ORIGIN;
		self.nextthink = (self.ltime + MON_CAMPERCHANCE);
		return;
	}
	vdestdelta = (tdest - self.origin);
	len = vlen(vdestdelta);
	traveltime = (len / tspeed);
	if ((traveltime < MON_CAMPERCHANCE))
	{
		self.velocity = VEC_ORIGIN;
		self.nextthink = (self.ltime + MON_CAMPERCHANCE);
		return;
	}
	self.nextthink = (self.ltime + traveltime);
	self.velocity = (vdestdelta * (WF_DEFEND / traveltime));
};

void() SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	self.velocity = VEC_ORIGIN;
	self.nextthink = CONTENT_EMPTY;
	if (self.think1)
	{
		self.think1();
	}
};

void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
	local entity stemp;

	stemp = self;
	self = ent;
	SUB_CalcAngleMove(destangle, tspeed, func);
	self = stemp;
};

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
	local vector destdelta;
	local float len;
	local float traveltime;

	if (!tspeed)
	{
		objerror("No speed is defined!");
	}
	destdelta = (destangle - self.angles);
	len = vlen(destdelta);
	traveltime = (len / tspeed);
	self.nextthink = (self.ltime + traveltime);
	self.avelocity = (destdelta * (WF_DEFEND / traveltime));
	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
};

void() SUB_CalcAngleMoveDone =
{
	self.angles = self.finalangle;
	self.avelocity = VEC_ORIGIN;
	self.nextthink = CONTENT_EMPTY;
	if (self.think1)
	{
		self.think1();
	}
};

void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets();
	remove(self);
};

void() SUB_UseTargets =
{
	local entity t;
	local entity stemp;
	local entity otemp;
	local entity act;

	if (self.delay)
	{
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = (time + self.delay);
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		return;
	}
	if (((activator.classname == "player") && (self.message != s_wiz)))
	{
		centerprint(activator, self.message);
		if (!self.noise)
		{
			sound(activator, CHAN_VOICE, "misc/talk.wav", WF_DEFEND, ATTN_NORM);
		}
	}
	if (self.killtarget)
	{
		t = world;
		do
		{
			t = find(t, targetname, self.killtarget);
			if (!t)
			{
				return;
			}
			remove(t);

		} while (WF_DEFEND);
	}
	if (self.target)
	{
		act = activator;
		t = world;
		do
		{
			t = find(t, targetname, self.target);
			if (!t)
			{
				return;
			}
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if ((self.use != SUB_Null))
			{
				if (self.use)
				{
					self.use();
				}
			}
			self = stemp;
			other = otemp;
			activator = act;

		} while (WF_DEFEND);
	}
};

void(float normal) SUB_AttackFinished =
{
	self.cnt = WF_NORMAL;
	if ((skill != MOON_DIFFICULTY_MAX))
	{
		self.attack_finished = (time + normal);
	}
};
float(entity targ) visible;

void(void() thinkst) SUB_CheckRefire =
{
	if ((skill != MOON_DIFFICULTY_MAX))
	{
		return;
	}
	if ((self.cnt == WF_DEFEND))
	{
		return;
	}
	if (!visible(self.enemy))
	{
		return;
	}
	self.cnt = WF_DEFEND;
	self.think = thinkst;
};
float(float v) anglemod;
void() sham_smash1;
void() sham_swingr1;
void() sham_swingl1;
float() DemonCheckAttack;
void(float side) Demon_Melee;
void() ai_face;
float enemy_vis;
//float enemy_infront; // unused
float enemy_range;
//float enemy_yaw; // unused

float() CheckAttack =
{
	local vector spot1;
	local vector spot2;
	local entity targ;
	local float chance;

	targ = self.enemy;
	spot1 = (self.origin + self.view_ofs);
	spot2 = (targ.origin + targ.view_ofs);
	traceline(spot1, spot2, FALSE, self);
	if ((trace_ent != targ))
	{
		return (FALSE);
	}
	if ((trace_inopen && trace_inwater))
	{
		return (FALSE);
	}
	if ((enemy_range == RANGE_MELEE))
	{
		if (self.th_melee)
		{
			self.th_melee();
			return (TRUE);
		}
	}
	if (!self.th_missile)
	{
		return (FALSE);
	}
	if ((time < self.attack_finished))
	{
		return (FALSE);
	}
	if ((enemy_range == RANGE_FAR))
	{
		return (FALSE);
	}
	if ((enemy_range == RANGE_MELEE))
	{
		chance = 0.9;
		self.attack_finished = WF_NORMAL;
	}
	else
	{
		if ((enemy_range == RANGE_NEAR))
		{
			if (self.th_melee)
			{
				chance = MON_REACTIONTIME;
			}
			else
			{
				chance = MON_STUCKTIME;
			}
		}
		else
		{
			if ((enemy_range == RANGE_MID))
			{
				if (self.th_melee)
				{
					chance = 0.05;
				}
				else
				{
					chance = MON_CAMPERCHANCE;
				}
			}
			else
			{
				chance = WF_NORMAL;
			}
		}
	}
	if ((random() < chance))
	{
		self.th_missile();
		SUB_AttackFinished((WF_EXTRASIZE * random()));
		return (TRUE);
	}
	return (FALSE);
};

void() ai_face =
{
	self.ideal_yaw = vectoyaw((self.enemy.origin - self.origin));
	ChangeYaw();
};
float(entity targ) infront;

void(float d) ai_charge =
{
};

void() ai_charge_side =
{
	local vector dtemp;
	local float heading;

	self.ideal_yaw = vectoyaw((self.enemy.origin - self.origin));
	ChangeYaw();
	makevectors(self.angles);
	dtemp = (self.enemy.origin - (MON_CAMPTIME * v_right));
	heading = vectoyaw((dtemp - self.origin));
	walkmove(heading, GRD_PATROLTIME);
};

void() ai_melee =
{
	local vector delta;
	local float ldmg;

	if (!self.enemy)
	{
		return;
	}
	delta = (self.enemy.origin - self.origin);
	if ((vlen(delta) > 60))
	{
		return;
	}
	ldmg = (((random() + random()) + random()) * LOGIC_FINDDEFEND);
	T_Damage(self.enemy, self, self, ldmg);
};

void() ai_melee_side =
{
	local vector delta;
	local float ldmg;

	if (!self.enemy)
	{
		return;
	}
	ai_charge_side();
	delta = (self.enemy.origin - self.origin);
	if ((vlen(delta) > 60))
	{
		return;
	}
	if (!CanDamage(self.enemy, self))
	{
		return;
	}
	ldmg = (((random() + random()) + random()) * LOGIC_FINDDEFEND);
	T_Damage(self.enemy, self, self, ldmg);
};

void() SoldierCheckAttack =
{
};

float() ShamCheckAttack =
{
	local vector spot1;
	local vector spot2;
	local entity targ;
	//local float chance; // unused

	if ((enemy_range == RANGE_MELEE))
	{
		if (CanDamage(self.enemy, self))
		{
			self.attack_state = AS_MELEE;
			return (TRUE);
		}
	}
	if ((time < self.attack_finished))
	{
		return (FALSE);
	}
	if (!enemy_vis)
	{
		return (FALSE);
	}
	targ = self.enemy;
	spot1 = (self.origin + self.view_ofs);
	spot2 = (targ.origin + targ.view_ofs);
	if ((vlen((spot1 - spot2)) > 600))
	{
		return (FALSE);
	}
	traceline(spot1, spot2, FALSE, self);
	if ((trace_inopen && trace_inwater))
	{
		return (FALSE);
	}
	if ((trace_ent != targ))
	{
		return (FALSE);
	}
	if ((enemy_range == RANGE_FAR))
	{
		return (FALSE);
	}
	self.attack_state = AS_MISSILE;
	SUB_AttackFinished((WF_EXTRASIZE + (WF_EXTRASIZE * random())));
	return (TRUE);
};

float() OgreCheckAttack =
{
	local vector spot1;
	local vector spot2;
	local entity targ;
	local float chance;

	if ((enemy_range == RANGE_MELEE))
	{
		if (CanDamage(self.enemy, self))
		{
			self.attack_state = AS_MELEE;
			return (TRUE);
		}
	}
	if ((time < self.attack_finished))
	{
		return (FALSE);
	}
	if (!enemy_vis)
	{
		return (FALSE);
	}
	targ = self.enemy;
	spot1 = (self.origin + self.view_ofs);
	spot2 = (targ.origin + targ.view_ofs);
	traceline(spot1, spot2, FALSE, self);
	if ((trace_inopen && trace_inwater))
	{
		return (FALSE);
	}
	if ((trace_ent != targ))
	{
		return (FALSE);
	}
	if ((time < self.attack_finished))
	{
		return (FALSE);
	}
	if ((enemy_range == RANGE_FAR))
	{
		return (FALSE);
	}
	else
	{
		if ((enemy_range == RANGE_NEAR))
		{
			chance = MON_CAMPERCHANCE;
		}
		else
		{
			if ((enemy_range == RANGE_MID))
			{
				chance = 0.05;
			}
			else
			{
				chance = WF_NORMAL;
			}
		}
	}
	self.attack_state = AS_MISSILE;
	SUB_AttackFinished((WF_DEFEND + (WF_EXTRASIZE * random())));
	return (TRUE);
};
