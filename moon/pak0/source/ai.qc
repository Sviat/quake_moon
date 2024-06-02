//Decompiled code. Please respect the original copyright.
//entity sight_entity; // unused
//float sight_entity_time; // unused

float(float v) anglemod =
{
	while ((v >= 360))
	{
		v = (v - 360);
	}
	while ((v < WF_NORMAL))
	{
		v = (v + 360);
	}
	return (v);
};

float() CanDamagePoint =
{
	local vector spot1;
	local vector spot2;
	local entity targ;
	//local float chance; // unused

	targ = self.enemy;
	spot1 = (self.origin + self.view_ofs);
	spot2 = targ.origin;
	traceline(spot1, spot2, FALSE, self);
	if ((trace_ent.flags & FL_MONSTER))
	{
		return (FALSE);
	}
	else
	{
		return (TRUE);
	}
};

void() path_corner =
{
	remove(self);
};

float(entity targ) visible =
{
	local vector spot1;
	local vector spot2;

	spot1 = (self.origin + self.view_ofs);
	spot2 = (targ.origin + targ.view_ofs);
	traceline(spot1, spot2, TRUE, self);
	if ((trace_inopen && trace_inwater))
	{
		return (FALSE);
	}
	if ((trace_fraction == WF_DEFEND))
	{
		return (TRUE);
	}
	return (FALSE);
};

float(entity targ) infront =
{
	local vector vec;
	local float dot;

	makevectors(self.angles);
	vec = normalize((targ.origin - self.origin));
	dot = (vec * v_forward);
	if ((dot > 0.3))
	{
		return (TRUE);
	}
	return (FALSE);
};

void(float dist) ai_forward =
{
	walkmove(self.angles_y, dist);
};

void(float dist) ai_back =
{
	walkmove((self.angles_y + 180), dist);
};

float() FacingIdeal =
{
	local float delta;
	local float gamma;

	delta = anglemod(self.angles_y);
	gamma = vectoyaw((self.enemy.origin - self.origin));
	if ((gamma >= 360))
	{
		gamma = (gamma - 360);
	}
	if ((delta >= 360))
	{
		delta = (delta - 360);
	}
	if ((gamma > delta))
	{
		if (((gamma - delta) < 25))
		{
			return (TRUE);
		}
	}
	if ((gamma < delta))
	{
		if (((delta - gamma) < 25))
		{
			return (TRUE);
		}
	}
	return (FALSE);
};

void() ai_run_slide =
{
	local float ofs;
	local float z;

	z = LOGIC_FINDDEFEND;
	self.ideal_yaw = vectoyaw((self.enemy.origin - self.origin));
	ChangeYaw();
	if ((random() < 0.05))
	{
		self.lefty = (WF_DEFEND - self.lefty);
	}
	if (self.lefty)
	{
		ofs = MENTAT_TIME;
	}
	else
	{
		ofs = -90;
	}
	if (walkmove((self.ideal_yaw + ofs), z))
	{
		return;
	}
	self.lefty = (WF_DEFEND - self.lefty);
	walkmove((self.ideal_yaw - ofs), z);
};

void() ai_stand =
{
};

void(float dist) ai_walk =
{
};

void(float dist) ai_run =
{
};

void(float dist) ai_painforward =
{
};

void() ai_turn =
{
};

void(float dist) ai_pain =
{
};
