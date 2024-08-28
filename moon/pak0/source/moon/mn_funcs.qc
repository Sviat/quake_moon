/// ReProjectMoon-specific source file
/// Here go all common functions related to random, ftos and similar
/// No needs to prefix with moon_ Math functions

// // Forward declarations:
// ???
float(float weapon, float ammo) W_EnoughAmmoToShoot;
float(entity target, float healamount, float ignore = 0) T_Heal;
void(entity target, float armor_code, float armor_durability = -1) moon_init_target_as_armor;
float(entity target, float code) moon_get_target_total_bonus_by_code;
void() QuadCheat;
void() Prepare;
void() moon_set_map_moon4;
float(entity emitter, float track) moon_walkman_play;

// CUI
void() moon_print_cmd_help;
void() moon_print_character_status;
void() moon_print_skills;
void() moon_print_inventory;
void() moon_identify_item;
void() moon_buy_item;
void() moon_wear_item;

// Character
void(entity target, float value) moon_raise_target_vitality;
void(entity target, float value = 1) moon_raise_target_strength;
void(entity target, float value) moon_raise_target_sanity;
void(entity target, float value = 1) moon_raise_target_intuition;
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
	float min;
	float random_max;
	float delay;

	if ( sv_fastmeat > 0 )
	{
		min = MOON_MONSTER_WAVETIME_DELAY_FAST;
		random_max = MOON_MONSTER_WAVETIME_RANDOM_FAST;

	} else
	if ( sv_fastmeat < 0 )
	{
		min = MOON_MONSTER_WAVETIME_DELAY_SLOW;
		random_max = MOON_MONSTER_WAVETIME_DELAY_SLOW;
	} else {
		min = MOON_MONSTER_WAVETIME_DELAY_NORMAL;
		random_max = MOON_MONSTER_WAVETIME_RANDOM_NORMAL;
	}

	delay = min + (random() * random_max);

	if ( MOON_DEBUG & MOON_DEBUG_DPRINT_NEXTWAVE)
	{
		dprint("delay {}-{}, next in: {}\n", quick_ftos(min), quick_ftos(min+random_max), quick_ftos(delay));
	} // debug wave timer

	return delay;
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

// Replace kex_chat_message_X with console for two reasons:
//   1) in case i ever decide to port on other Engine
//   2) in MP matches nobody saw these messages for some reasons. May be name should of one of players, not some random bots
void(string sender, float sender_color, string text) moon_chat_message_broad =
{
	bprint("{}: {}\n", sender, text);
};

void(string sender, float sender_color, string text) moon_chat_message_self =
{
	sprint(self, "{}: {}\n", sender, text);
};
// //