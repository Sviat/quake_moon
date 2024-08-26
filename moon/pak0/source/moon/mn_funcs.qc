/// ReProjectMoon-specific source file
/// Here go all common functions related to random, ftos and similar
/// No needs to prefix with moon_ Math functions

// // Forward declarations:
float(float weapon, float ammo) W_EnoughAmmoToShoot;
float(entity target, float healamount, float ignore = 0) T_Heal;
void() moon_wear_item;
void() moon_print_inventory;
float(entity target, float code) moon_get_target_total_bonus_by_code;
// // end of Forward declarations

// FYI: QC random() function returns a value in [0, 1] range (INCLUSIVE)
float(float min, float max) random_int = // result in [min, max] range. N.B! including both sides
{
	return rint( (random() * (max - min)) + min );
};

float(float value, float max) clamp =
{
	if (value > max) { return max; }
	return value;
};

float(float min, float value, float max) clampd =
{
	if (value < min) { return min; }
	if (value > max) { return max; }
	return value;
};

void() flash_self =
{
	stuffcmd(self, "bf\n");
};

void() flash_other =
{
	stuffcmd(other, "bf\n");
};

void(entity target) flash_target =
{
	stuffcmd(target, "bf\n");
};

string(float f) floor_ftos =
{
	return ftos(floor(f));
};

string(float f) quick_ftos =
{
	return ftos(f);
};

void(entity who, float f) sprint_ftos = // TODO: slowly get rid of it
{
	local string str;

	str = ftos(floor(f));
	sprint(who, str);
};

float(float n1, float n2) percent =
{
	local float a;

	a = rint(((n1 * n2) / 100));
	return (a);
};

float() moon_get_max_player_level =
{
	local entity e;
	local float maxlvl;

	maxlvl = 0;
	while ( (e = find(e, classname, MOON_PLAYER_CLASSNAME)) )
	{
		if ( e.lvl > maxlvl )
		{
			maxlvl = e.lvl;
		}
	}
	return maxlvl;
};

float() moon_get_current_player_count =
{
	local entity e;
	local float count;

	count = 0;
	while ( (e = find(e, classname, MOON_PLAYER_CLASSNAME)) )
	{
		if (e.prepared == TRUE)
		{
			count = count + 1;
		}
	}
	return count;
};

float() moon_get_spawn_delay =
{
	float temp;
	if ( sv_fastmeat > 0 )
	{
		temp = MOON_MONSTER_WAVETIME_DELAY_FAST + (random() * MOON_MONSTER_WAVETIME_RANDOM_FAST);
		dprint("fastmeat {}-{}, delay: {}\n", quick_ftos(MOON_MONSTER_WAVETIME_DELAY_FAST), quick_ftos(MOON_MONSTER_WAVETIME_RANDOM_FAST), quick_ftos(temp));
		return temp;
	}

	if ( sv_fastmeat < 0 )
	{
		temp = MOON_MONSTER_WAVETIME_DELAY_SLOW + (random() * MOON_MONSTER_WAVETIME_RANDOM_SLOW);
		dprint("slowmeat {}-{}, delay: {}\n", quick_ftos(MOON_MONSTER_WAVETIME_DELAY_SLOW), quick_ftos(MOON_MONSTER_WAVETIME_RANDOM_SLOW), quick_ftos(temp));
		return temp;
	}

	temp = MOON_MONSTER_WAVETIME_DELAY_NORMAL + (random() * MOON_MONSTER_WAVETIME_RANDOM_NORMAL);
	dprint("justmeat {}-{}, delay: {}\n", quick_ftos(MOON_MONSTER_WAVETIME_DELAY_NORMAL), quick_ftos(MOON_MONSTER_WAVETIME_RANDOM_NORMAL), quick_ftos(temp));
	return temp;
};

float() moon_get_despawn_delay =
{
	if ( sv_fastmeat > 0 )
	{
		return (MOON_MONSTER_WAVETIME_DELAY_FAST + MOON_MONSTER_WAVETIME_RANDOM_FAST) * MOON_MONSTER_CORPSEDECAY_FACTOR;
	}

	if ( sv_fastmeat < 0 )
	{
		return (MOON_MONSTER_WAVETIME_DELAY_SLOW + MOON_MONSTER_WAVETIME_RANDOM_SLOW) * MOON_MONSTER_CORPSEDECAY_FACTOR;
	}

	return (MOON_MONSTER_WAVETIME_DELAY_NORMAL + MOON_MONSTER_WAVETIME_RANDOM_NORMAL) * MOON_MONSTER_CORPSEDECAY_FACTOR;
};

void(entity e) moon_add_to_queue =
{
	local entity z;

	z = spawn();
	z.origin = e.origin;
	z.angles = e.angles;
	setmodel(z, e.model);
	z.frame = e.frame;
	z.colormap = e.colormap;
	z.flags = e.flags;
	z.movetype = MOVETYPE_TOSS;
	z.solid = SOLID_NOT;
	z.velocity = e.velocity;
	z.think = SUB_Remove;
	z.nextthink = time + moon_get_despawn_delay();
};