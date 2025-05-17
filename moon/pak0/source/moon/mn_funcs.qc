/// ReProjectMoon-specific source file
/// Here go all common functions related to random, ftos and similar
/// No needs to prefix Math functions with moon_

// // Forward declarations:
// Default QC func unchanged, just forward declared
void() player_run;
// SORT OUT
void() intermission_victory;
void() moon_make_chat_noise;
void(entity who) moon_spawn_drop_gold;
void() moon_set_map_moon4;

// moon/mn_character
float(entity target, float healamount) moon_heal_target_player;
float(entity target, float healamount) moon_overheal_target_player;
float(entity target, float decayamount) moon_decayheal_target_player;
void() moon_medkit_touch;
void(entity target, float healamount) moon_heal_target_monster;
float(entity target, float healamount) moon_recover_target_mana;
float(entity target, float code) moon_get_target_total_bonus_by_code;
float(entity target) moon_get_target_bonus_health;
float(entity target) moon_get_target_total_bonus_damage;
void(entity target, float value = 1) moon_raise_target_vitality;
void(entity target, float value = 1) moon_raise_target_strength;
void(entity target, float value = 1) moon_raise_target_sanity;
void(entity target, float value = 1) moon_raise_target_intuition;

// moon/mn_cui
void() moon_print_cmd_help;
void() moon_print_character_status;
void() moon_print_skills;
void() moon_print_inventory;
void() moon_identify_items_in_radius;
void() moon_buy_item;
void(entity subject) moon_bprint_describe_player;
string(float rarity_level) moon_lookup_item_rarity_display;
void(entity target, string prefix, string name, string postfix) moon_print_target_item_name;
void(entity target, float rarity_level) moon_print_target_item_rarity;

// moon/mn_game
void(entity target, float delay = 0) moon_queue_target_for_removal;
float(entity target) moon_do_target_natural_health_regen_tick;
float(entity target) moon_do_target_magical_health_regen_tick;
float(entity target) moon_do_target_magical_repair_tick;
float(entity target) moon_do_target_magical_recharge_tick;

// moon/mn_items?
void() moon_self_pickup_magic_item_and_clear;
void(entity target, entity selected) moon_target_wear_magic_item;

// Base of base: damage, heal, move
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage;
float(entity subject, entity object) moon_can_trace_object;
entity(vector source, vector destination, entity attacker) moon_trace_lightning_bolt_shambler;
entity(vector source, vector destination, entity attacker, entity inflictor, float piercing_strength = 0) moon_trace_lightning_bolt_shaft;
void(entity attacker, entity target, float max_distance, float jump_count = 0) moon_trace_lightning_bolt_chain;

// Bots (Guards and Monsters) logic
void(entity who) moon_particle_heal;
// Guard logic
void() moon_spawn_guard;

// Monster logic
void() moon_monster_apply_effect_self;

// moon/mn_music
void() moon_walkman_init_think; // used in Map init
float(entity emitter, float track) moon_walkman_play; // used by Impulse handler

// moon/mn_waves
entity(entity spawner, float level) moon_spawn_monster_entity {return world;}; // TODO: Implement
void(entity e, float enc) spawn_knight; // unused so far
entity(entity e, float enc) spawn_soldier;
entity(entity e, float enc) spawn_enforcer;
entity(entity e, float enc) spawn_spider;
entity(entity e, float enc) spawn_ogre;
entity(entity e, float enc) spawn_snake;
entity(entity e, float enc) spawn_mage;
entity(entity e, float enc) spawn_shalrath;

// moon/mn_weapons
void(entity target) moon_limit_target_ammo;
void(entity target, entity object) moon_target_consume_ammo_from;
float(entity target, float include_dangerous = false) moon_get_target_best_weapon;
float(entity target, float wpn) moon_select_target_weapon;
float(entity target, float include_dangerous = false) moon_swap_target_to_best_weapon;
// TODO: add functions to use ammo

// // end of Forward declarations

// // Randoms
// FYI: QC random() function returns a value in [0, 1] range (INCLUSIVE)
float(float min, float max) random_int = // result in [min, max] range. N.B! including both sides
{
	return rint( (random() * (max - min)) + min );
};
float() random_nzc = // normalized zero-centric [-1, +1] range
{
	return ( 2 * (random() - 0.5) );
};
float(float scale = 1) random_zc = // scaled zero-centric [-x, +x] range
{
	return scale * ( 2 * (random() - 0.5) );
};
// // end of Randoms

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
//

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
	return gl_playercount;
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

	if ( MOON_DEBUG & MOON_CONST_DEBUG_DPRINT_NEXTWAVE)
	{
		dprint("Next wave in: {0} (delay {1}-{2})\n", floor_ftos(delay), quick_ftos(min), quick_ftos(min+random_max));
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

void(entity object) moon_debug_println_object_name =
{
	if ( object == world ) { return; }

	if ( MOON_DEBUG & MOON_CONST_DEBUG_DPRINT_SPAWNED_NAMES)
	{
		bprint("Spawned {0}{1}{2}{3}{4}\n", object.prefix_one, object.prefix_two, object.netname, object.prefix_three, object.prefix_four);
	}

	// if ( (MOON_DEBUG & MOON_CONST_DEBUG_EPRINT_MONSTERS) )
	// {
	// 	eprint(object);
	// }
};

// Replace kex_chat_message_X with console for two reasons:
//   1) in case i ever decide to port on other Engine
//   2) in MP matches nobody saw these messages for some reasons. May be name should of one of players, not some random bots
void(string sender, float sender_color, string text) moon_chat_message_broad =
{
	bprint("{0}: {1}\n", sender, text);
};

void(string sender, float sender_color, string text) moon_chat_message_self =
{
	sprint(self, "{0}: {1}\n", sender, text);
};
// //

void(float count = 1) moon_update_hud_kill =
{
	killed_monsters = killed_monsters + count;

	WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
};

// Simpler version than update_hud_totals in subs_soc
void(float count = 1) moon_update_hud_monsters =
{
	total_monsters = total_monsters + count;

	WriteByte (MSG_ALL, SVC_UPDATESTAT);
	WriteByte (MSG_ALL, STAT_TOTALMONSTERS);
	WriteLong (MSG_ALL, total_monsters);
};

float(entity subject, entity object) moon_can_trace_object =
{
	if ( object.movetype == MOVETYPE_PUSH )
	{
		traceline(subject.origin, (0.5 * (object.absmin + object.absmax)), CONST_QC_COLLISION_WITH_SOLID, subject);
		if ( trace_fraction == 1 )
		{
			return (TRUE);
		}
		if ( trace_ent == object )
		{
			return (TRUE);
		}
		return (FALSE);
	}

	traceline(subject.origin, object.origin, CONST_QC_COLLISION_WITH_SOLID, subject);
	if ( trace_fraction == 1 )
	{
		return (TRUE);
	}

	traceline(subject.origin, (object.origin + '15 15 0'), CONST_QC_COLLISION_WITH_SOLID, subject);
	if ( trace_fraction == 1 )
	{
		return (TRUE);
	}

	traceline(subject.origin, (object.origin + '-15 -15 0'), CONST_QC_COLLISION_WITH_SOLID, subject);
	if ( trace_fraction == 1 )
	{
		return (TRUE);
	}

	traceline(subject.origin, (object.origin + '-15 15 0'), CONST_QC_COLLISION_WITH_SOLID, subject);
	if ( trace_fraction == 1 )
	{
		return (TRUE);
	}

	traceline(subject.origin, (object.origin + '15 -15 0'), CONST_QC_COLLISION_WITH_SOLID, subject);
	if ( trace_fraction == 1 )
	{
		return (TRUE);
	}

	return (FALSE);
};

float(entity target) moon_target_player_needs_tutorial =
{
	if ( (target.cl_nohelp == 0) && (target.lvl < MOON_PLAYER_LEVEL_NOMOREHELP) )
	{
		return TRUE;
	}
	return FALSE;
};

entity() moon_gimme_your_heart =
{
	local entity heart;
	heart = find(world, classname, MOON_HEART_CLASSNAME);
	if ( heart != world )
	{
		return heart;
	}

	dprint("you have no heart\n");
	return world;
};