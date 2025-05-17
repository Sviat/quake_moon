//entity sight_entity; // unused
//float sight_entity_time; // unused

float(float v) anglemod =
{
	while (v >= 360)
		v = v - 360;
	while (v < 0)
		v = v + 360;
	return v;
};

float () CanDamagePoint =
{
	local vector	spot1, spot2;
	local entity	targ;
	// local float		chance;

	targ = self.enemy;
	// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin;

	traceline (spot1, spot2, FALSE, self);

	if (trace_ent.flags & FL_MONSTER)
		return FALSE;		// don't have a clear shot
	else return TRUE;
};


void() path_corner = { remove(self); };

/*
=============
visible
returns 1 if the entity is visible to self, even if not infront ()
=============
*/
float (entity targ) visible =
{
	local vector	spot1, spot2;

	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline (spot1, spot2, TRUE, self);	// see through other monsters

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};


/*
=============
infront
returns 1 if the entity is in front (in sight) of self
=============
*/
float(entity targ) infront =
{
	local vector	vec;
	local float		dot;

	makevectors (self.angles);
	vec = normalize (targ.origin - self.origin);
	dot = vec * v_forward;

	if ( dot > 0.3)
	{
		return TRUE;
	}
	return FALSE;
};
//=============================================================================


void(float dist) ai_forward =
{
	walkmove (self.angles_y, dist);
};

void(float dist) ai_back =
{
	walkmove ( (self.angles_y+180), dist);
};

/*
============
FacingIdeal

============
*/
float() FacingIdeal =
{
	local	float	delta;

	delta = anglemod(self.angles_y - self.ideal_yaw);
	if (delta > 45 && delta < 315)
		return FALSE;
	return TRUE;
};


//=============================================================================



/*
=============
ai_run_slide
Strafe sideways, but stay at aproximately the same range
=============
*/
void() ai_run_slide =
{
	local float	ofs;

	local float z;
	z = 3;

	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	ChangeYaw();

	if(random() < 0.05) self.lefty = 1 - self.lefty;

	if (self.lefty)
		ofs = 90;
	else
		ofs = -90;

	if (walkmove (self.ideal_yaw + ofs, z))
		return;

	self.lefty = 1 - self.lefty;

	walkmove (self.ideal_yaw - ofs, z);
};


// null functionz
void() ai_stand = {};
void(float dist) ai_walk = {};
void(float dist) ai_run = {};
void(float dist) ai_painforward = {};
void() ai_turn = {};
void(float dist) ai_pain = {};