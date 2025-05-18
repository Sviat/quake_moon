/// ReProjectMoon-specific source file
/// Here go all functions shared for Monster or Bot AI
/// Below is merge of refactored decompiled code and Moon source


entity() find_closest_ns =
{
	local entity e;
	local entity selected;
	local float best_waypoint_dist;

	selected = world;
	best_waypoint_dist = 99999;
	e = find(world, classname, "sale_way");
	while ((e != world))
	{
		if (CanDamage(e, self))
		{
			if ((vlen((e.origin - self.origin)) < best_waypoint_dist))
			{
				selected = e;
				best_waypoint_dist = vlen((e.origin - self.origin));
			}
		}
		e = find(e, classname, "sale_way");
	}
	return (selected);
};

float() find_ns =
{
	if ((self.goalentity.classname == "sale_way"))
	{
		return (FALSE);
	}
	self.goalentity = find_closest_ns();
	if ((self.goalentity == world))
	{
		return (FALSE);
	}
	self.ideal_yaw = vectoyaw((self.goalentity.origin - self.origin));
	return (TRUE);
};

void() ns_touch = // self - waypoint, other - market trader
{
	local entity tmp;
	local float nextnum;
	local float zzz;
	local entity ops;

	if ((other.goalentity != self))
	{
		return;
	}
	if ((other.classname != MOON_TRADER_MARKET_CLASSNAME))
	{
		return;
	}
	if ((other.wantnum > self.num))
	{
		nextnum = (self.num + 1);
	}
	if ((other.wantnum < self.num))
	{
		nextnum = (self.num - 1);
	}
	if (((other.action == 2) && (self.num == 2)))
	{
		remove(other);
		return;
	}
	if ((((other.action == 1) && (self.num < 4)) || (other.action == 2)))
	{
		tmp = find(world, classname, "sale_way");
		while (tmp)
		{
			if ((tmp.num == nextnum))
			{
				other.goalentity = tmp;
				return;
			}
			tmp = find(tmp, classname, "sale_way");
		}
	}
	else
	{
		while (TRUE)
		{
			zzz = rint((random() * 5));
			ops = find(world, classname, MOON_TRADE_MARKET_SOMETHING_CLASSNAME);
			while (ops)
			{
				if ((ops.num == zzz))
				{
					if ((ops.free == MOON_TRADE_STATE_FREE))
					{
						other.goalentity = ops;
						return;
					}
				}
				ops = find(ops, classname, MOON_TRADE_MARKET_SOMETHING_CLASSNAME);
			}
		}
	}
	bprint("ERROR: ns_touch error\n");
};

void(vector org, float nm, float rd) NS = // black market waypoints for Trader
{
	local entity e;

	e = spawn();
	setorigin(e, org);
	e.num = nm;
	e.radius = rd;
	setsize(e, VEC_HULL_MIN, VEC_HULL_MAX);
	e.touch = ns_touch;
	e.solid = SOLID_TRIGGER;
	setsize(e, VEC_HULL_MIN, VEC_HULL_MAX);
	e.classname = "sale_way";
};

void() s_touch = // self - market spot, other - market trader
{
	if ((other.goalentity != self))
	{
		return;
	}
	if ((other.classname != MOON_TRADER_MARKET_CLASSNAME))
	{
		return;
	}
	other.wantnum = 2;
	other.action = 3;
	other.cnt = self.angles_y;
	other.ideal_yaw = self.angles_y;
	other.goalentity = world;
	self.enemy = other;
	self.free = MOON_TRADE_STATE_OCCUPIED;
	other.free = MOON_TRADE_STATE_FREE;
};

void(vector org, float ang, float nm) S =
{
	local entity e;

	e = spawn();
	setorigin(e, org);
	e.angles_y = ang;
	e.num = nm;
	e.radius = 60;
	e.free = MOON_TRADE_STATE_FREE;
	e.classname = MOON_TRADE_MARKET_SOMETHING_CLASSNAME;
	setsize(e, '-4 -4 0', '4 4 8');
	e.touch = s_touch;
	e.solid = SOLID_TRIGGER;
	setsize(e, '-4 -4 0', '4 4 8');
};

/*
============
FacingIdeal
============
*/
float() moon_is_self_facing_ideal =
{
	local float delta;
	local float gamma;

	delta = anglemod(self.angles_y);
	gamma = vectoyaw(self.enemy.origin - self.origin);
	if(gamma >= 360) gamma = gamma - 360;
	if(delta >= 360) delta = delta - 360;

	if(gamma > delta)
	if((gamma - delta) < 25)
		return TRUE;

	if(gamma < delta)
	if((delta - gamma) < 25)
		return TRUE;

	return FALSE;
};

vector() moon_get_randomly_selected_shift_vector = // Get one of predefined 3D shift vectors for aiming around the target
{
	local vector vec;
	local float r;

	r = random();
	if (r < 0.5)
	{
		if (r < 0.25)
		{
			if (r < 0.05)
				vec = '0 0 0';
			else if (r < 0.1)
				vec = '0 0 12';
			else if (r < 0.15)
				vec = '0 12 0';
			else if (r < 0.2)
				vec = '12 0 0';
			else
				vec = '12 12 0';
		} else {
			if (r < 0.3)
				vec = '12 0 12';
			else if (r < 0.35)
				vec = '0 12 12';
			else if (r < 0.4)
				vec = '0 12 12';
			else if (r < 0.45)
				vec = '-12 12 0';
			else
				vec = '-12 12 16';
		}
	} else {
		if (r < 0.75)
		{
			if (r < 0.55)
				vec = '0 0 16';
			else if (r < 0.6)
				vec = '12 12 -16';
			else if (r < 0.65)
				vec = '12 12 0';
			else if (r < 0.7)
				vec = '12 0 12';
			else
				vec = '12 0 12';
		} else {
			if (r < 0.8)
				vec = '0 0 12';
			else if (r < 0.85)
				vec = '0 0 -12';
			else if (r < 0.9)
				vec ='0 -12 0';
			else if (r < 0.95)
				vec = '-12 0 0';
			else
				vec = '0 0 -16';
		}
	}
	return vec;
};

float(entity targ) BotCanSeePlayer =
{
	local vector spot1;
	local vector spot2;
	local vector vec;

	spot1 = self.origin + self.view_ofs;

	vec = moon_get_randomly_selected_shift_vector();
	spot2 = targ.origin + vec;

	traceline(spot1, spot2, TRUE, self);	// see through other monsters

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};

entity() FindClosestWaypoint =
{
	local entity e;
	local entity selected;
	local float best_waypoint_dist;

	selected = world;
	best_waypoint_dist = CONST_QC_BIGFUCKINGINT;
	e = find(world, classname, "waypoint");
	while ((e != world))
	{
		if (CanDamage(e, self))
		{
			if ((vlen((e.origin - self.origin)) < best_waypoint_dist))
			{
				selected = e;
				best_waypoint_dist = vlen((e.origin - self.origin));
			}
		}
		e = find(e, classname, "waypoint");
	}
	return (selected);
};

float() FindWaypoint =
{
	if ( self.goalentity.classname == "waypoint" )
	{
		return FALSE;
	}

	self.movetarget = FindClosestWaypoint();
	self.goalentity = FindClosestWaypoint();
	if ( self.goalentity == world )
	{
		return FALSE;
	}

	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	return TRUE;
};

// -===========================================================-
// Project MOON
// New monster ai improvement
// Created by 3d[Power]
// -===========================================================-

/* =============
Check Edge
Go up the stairs
==============*/

void(entity who) CheckEdge = // olde
{
	local float yw,bl,dst;

	if(!who)
		return;

	//	if(vlen(self.velocity) >= (self.speed / 1.4))
	//		return;
	// who is a goal

	dst = 2;
	movedist = dst;
	yw = vectoyaw(who.origin - self.origin);
	bl = !walkmove(yw, dst);
	if (bl)
		movetogoal(dst);
};

// new climb stairs routine. the trick is, to use FL_PARTIALGROUND flag
// for climbing in air.
float(vector dir) botCheckForStep =
{
	local vector currentorigin;
	local vector v;
	local float currentflags;
	local float yaw;
	local float stepdistance;
	local float movedistance;

	currentorigin = self.origin;
	currentflags = self.flags;
	self.flags = FL_ONGROUND | FL_PARTIALGROUND;
	dir = normalize(dir);
	dir_z = 0;
	yaw = vectoyaw(dir);
	if(walkmove(yaw, 3))
	{
		if(droptofloor()) // was droptofloor(0,0)
		{
			stepdistance = self.origin_z - currentorigin_z;
			v = self.origin - currentorigin;
			v_z = 0;
			movedistance = vlen(v);
			if((stepdistance > 0 && stepdistance <= 16) && movedistance != 0)
			{
				self.flags = currentflags | FL_PARTIALGROUND;
				return 1;
			}
		}
	}
	self.flags = currentflags;
	setorigin(self, currentorigin);
	return 0;
};

/* ==============
  find_creature
Routine to calculate position of "who"
===============*/

void(entity who) find_creature =
{
	local entity e;
	local entity sel;
	local float mindist;
	local float f;

	if ( who.next_fndcrt > time )
	{
		return;
	}
	who.next_fndcrt = (time + 0.25);

	mindist = 99999;
	f = FALSE;

	e = find(world, classname, "waypoint");
	while(e)
	{
		if(CanDamage(e, who))
		if(vlen(who.origin - e.origin) < mindist)
		{
			mindist = vlen(who.origin - e.origin);
			self.wantnum = e.num;
			self.wantline = e.line;
			sel = e;
			f = TRUE;
		}
		e = find(e, classname, "waypoint");
	}
	if(f == TRUE)
	if(self.classname == "guard")
	{
		if(sel.num == self.wantnum && sel.line == self.wantline)
		if(vlen(sel.origin - self.origin) < 100)
		{
			if(self.nextyaw < time)
			{
				self.ideal_yaw = random() * 360;
				self.nextyaw = time + 1 + 3*random();
			}
			ChangeYaw();
			return;
		}
		if(self.currentammo == 0) // used as SIGN OF?
		{
			self.goalentity = FindClosestWaypoint();
			self.th_run();
		}
		return;
	}
	//	else bprint("who is unaccessible!\n");
};