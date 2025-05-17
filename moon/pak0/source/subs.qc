/*  Copyright (C) 1996-2022 id Software LLC

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

void() SUB_Null = {};

void() SUB_Remove = {remove(self);};


/*
QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.
*/
void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors(self.angles);
		self.movedir = v_forward;
	}

	self.angles = '0 0 0';
};

/*
================
InitTrigger
================
*/
void() InitTrigger =
{
	// trigger angles are used for one-way touches.  An angle of 0 is assumed
	// to mean no restrictions, so use a yaw of 360 instead.
	if (self.angles != '0 0 0')
		SetMovedir ();

	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = string_null;
};

/*
=============
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
===============
*/
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
	local entity	stemp;
	stemp = self;
	self = ent;

	SUB_CalcMove (tdest, tspeed, func);
	self = stemp;
};

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
	local vector	vdestdelta;
	local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}

	// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;

	// calculate length of vector
	len = vlen (vdestdelta);

	// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	if (traveltime < 0.1)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}

	// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

	// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// qcc won't take vec/float
};

/*
============
After moving, set origin to exact final destination
============
*/
void()  SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;

	if (self.think1)
		self.think1();
};


/*
=============
SUB_CalcAngleMove

calculate self.avelocity and self.nextthink to reach destangle from
self.angles rotating

The calling function should make sure self.think is valid
===============
*/
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
	local entity		stemp;
	stemp = self;
	self = ent;
	SUB_CalcAngleMove (destangle, tspeed, func);
	self = stemp;
};

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
	local vector	destdelta;
	local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");

	// set destdelta to the vector needed to move
	destdelta = destangle - self.angles;

	// calculate length of vector
	len = vlen (destdelta);

	// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

	// scale the destdelta vector by the time spent traveling to get velocity
	self.avelocity = destdelta * (1 / traveltime);

	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
};

/*
============
After rotating, set angle to exact final angle
============
*/
void() SUB_CalcAngleMoveDone =
{
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;

	if (self.think1)
		self.think1();
};


//=============================================================================

void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove(self);
};

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/
void() SUB_UseTargets =
{
	local entity t, act, stemp, otemp;

//
// check for a delay
//
	if (self.delay)
	{
		// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		return;
	}


//
// print the message
//
	if (activator.classname == "player" && self.message != string_null)
	{
		centerprint (activator, self.message);

		if (!self.noise)
			sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

	//
	// kill the killtagets
	//
	if (self.killtarget != string_null)
	{
		t = find (world, targetname, self.killtarget);

		while( t )
		{
			remove (t);
			t = find (t, targetname, self.killtarget);
		}
	}

	//
	// fire targets
	//
	if (self.target != string_null)
	{
		act = activator;
		t = find (world, targetname, self.target);
		while( t )
		{
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if (self.use != SUB_Null)
			{
				if (self.use)
				self.use ();
			}
			self = stemp;
			other = otemp;
			activator = act;
			t = find (t, targetname, self.target);
		}
	}
};

/*
in nightmare mode, all attack_finished times become 0
some monsters refire twice automatically
update: not anymore! it makes nightmare too easy
*/

void(float normal) SUB_AttackFinished =
{
	self.cnt = 0;		// refire count for nightmare

	//if (skill != 3)
		self.attack_finished = time + normal;
};

float (entity targ) visible;

void (void() thinkst) SUB_CheckRefire =
{
	if (skill != 3)
		return;

	if (self.cnt == 1)
		return;

	if (!visible (self.enemy))
		return;

	self.cnt = 1;
	self.think = thinkst;
};

// // All stuff below is decompiling placing all stuff in one file. Should not be here
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
