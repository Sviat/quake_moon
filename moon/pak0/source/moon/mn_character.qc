/// ReProjectMoon-specific source file
/// Here go all functions managing player character's properties


float(entity target, float healamount) moon_heal_target_player = // Player heal only!
{
	if ( target.health <= 0 ) // you can't help him
	{
		return FALSE;
	}
	if ( target.health >= target.max_health )
	{
		return FALSE;
	}

	healamount = ceil(healamount);
	target.health = clamp( (target.health + healamount), target.max_health );
	target.health = clamp(target.health, CONST_QC_DISPLAY_MAX);

	if ( target.health > target.max_health )
	{
		target.items = (target.items | IT_SUPERHEALTH);
	} else {
		target.items = (target.items & ~IT_SUPERHEALTH);
	}

	return TRUE;
};

float(entity target, float healamount) moon_overheal_target_player = // Player MEGAHEALTH heal only!
{
	if ( target.health <= 0 ) // you can't help him
	{
		return FALSE;
	}
	if ( target.health >= (target.max_health + MOON_MEDKIT_MEGA_OVERHEAL_SOFTLIMIT) )
	{
		return FALSE;
	}

	healamount = ceil(healamount);
	target.health = target.health + healamount;
	target.health = clamp(target.health, CONST_QC_DISPLAY_MAX);

	if ( target.health > target.max_health )
	{
		target.items = (target.items | IT_SUPERHEALTH);
	} else {
		target.items = (target.items & ~IT_SUPERHEALTH);
	}

	return TRUE;
};

float(entity target, float decayamount) moon_decayheal_target_player = // Megahealth rot only!
{ // decayamount <= 0
	if ( target.health <= 0 ) // you can't help him
	{
		return FALSE;
	}

	if ( target.health <= target.max_health )
	{
		target.items = (target.items & ~IT_SUPERHEALTH);
		return FALSE;
	}

	decayamount = ceil(decayamount);
	target.health = clampd( target.max_health, (target.health + decayamount), CONST_QC_DISPLAY_MAX);

	return TRUE;
};

void() moon_medkit_touch = // self - medkit, other - player
{
	if ( other.classname != MOON_PLAYER_CLASSNAME ) { return; }

	if ( self.healtype == MOON_MEDKIT_MEGA_TYPE )
	{
		if ( other.health >= (other.max_health + MOON_MEDKIT_MEGA_OVERHEAL_HARDLIMIT) )
		{
			return;
		}
		if (!moon_overheal_target_player(other, self.healamount))
		{
			return;
		}
	} else {
		if (!moon_heal_target_player(other, self.healamount))
		{
			return;
		}
	}
	sprint(other, "You receive {0} health\n", floor_ftos(self.healamount));
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	flash_target(other);

	self.model = string_null;
	self.solid = SOLID_NOT;
	activator = other;
	SUB_UseTargets();
};

void(entity e, float healamount) moon_heal_target_monster =	// Monster heal only - doesnt need to fit to screen, so may lead to numbers above CONST_QC_DISPLAY_MAX
{
	e.health = e.health + healamount;
	if ( e.health > e.max_health )
	{
		e.health = e.max_health;
	}
};

float(entity target, float healamount) moon_recover_target_mana =
{
	if ( target.mana >= target.max_mana )
	{
		return FALSE;
	}

	healamount = ceil(healamount);
	target.mana = clamp( (target.mana + healamount), target.max_mana);
	target.mana = clamp(target.mana, CONST_QC_DISPLAY_MAX);

	return TRUE;
};

float(entity target, float code) moon_get_target_total_bonus_by_code =
{
	local float bonus;
	bonus = 0;
	if ( target.magic_typeone == code )
	{
		bonus = (bonus + target.magic_typeone_value);
	}
	if ( target.magic_typetwo == code )
	{
		bonus = (bonus + target.magic_typetwo_value);
	}
	if ( target.ring_typeone == code )
	{
		bonus = (bonus + target.ring_typeone_value);
	}
	if ( target.ring_typetwo == code )
	{
		bonus = (bonus + target.ring_typetwo_value);
	}
	return bonus;
};

float(entity target) moon_get_target_bonus_health =
{
	return moon_get_target_total_bonus_by_code(target, MOON_ITEM_HEALTH_CODE);
};

float(entity target) moon_get_target_total_bonus_damage =
{
	// TODO: add offensive strength influence, scroll of brut and mentat here
	return moon_get_target_total_bonus_by_code(target, MOON_ITEM_DAMAGE_CODE);
};

void(entity target, float value) moon_raise_target_max_health =
{
	target.max_health = (target.max_health + value);
	target.max_health = clampd(MOON_STAT_MAXHEALTH_MIN, target.max_health, CONST_QC_DISPLAY_MAX);
	if (value > 0)
	{
		moon_heal_target_player(target, value);
	}
};

void(entity target, float value) moon_raise_target_max_mana =
{
	target.max_mana = (target.max_mana + value);
	target.max_mana = clampd(MOON_STAT_MAXMANA_MIN, target.max_mana, CONST_QC_DISPLAY_MAX);
	if (value > 0)
	{
		moon_recover_target_mana(target, value);
	}
};

void(entity target, float value = 1) moon_raise_target_vitality =
{
	target.vit = (target.vit + value);
	moon_raise_target_max_health(target, (value*MOON_STAT_HEALTH_PER_VITALITY));
};

void(entity target, float value = 1) moon_raise_target_strength = // This is not necessary so far, but for consistency
{
	target.stre = (target.stre + value);
};

void(entity target, float value = 1) moon_raise_target_sanity =
{
	target.wiz = (target.wiz + value);
	moon_raise_target_max_mana(target, (value*MOON_STAT_MANA_PER_SANITY));
};

void(entity target, float value = 1) moon_raise_target_intuition = // This is not necessary so far, but for consistency
{
	target.intu = (target.intu + value);
};

void(entity target, float gain) moon_give_target_gold =
{
	target.gold = (target.gold + gain);

	flash_target(target);
	sprint(target, "You got {0} gold\n", floor_ftos(gain));
	sound(target, CHAN_ITEM, "moon/items/gold.wav", 1, ATTN_NORM);
};

float(entity target, float cost) moon_pay_target_gold =
{
	if ( target.gold < cost )
	{
		sprint(target, "not enough gold\n");
		return FALSE;
	}
	target.gold =  target.gold - cost;

	sprint(target, "You paid {0} gold, {1} left\n", floor_ftos(cost), floor_ftos(target.gold));
	return TRUE;
};

float(float next_lvl, float prev_exp) moon_get_experience_for_next_level =
{
	return floor( prev_exp + (next_lvl * MOON_NEXTLEVEL_MORE_PLAYERLEVEL_TIMES * MOON_NEXTLEVEL_MORE_SCALING_FACTOR) );
};

void(entity target) level_up_target =
{
	target.frags = target.lvl + 1;
	target.nextexp = moon_get_experience_for_next_level(target.frags, target.nextexp); // Increase requirement with updated level
	target.lvl = target.frags;

	if ( target.health > 0 )
	{
		if ( target.health < target.max_health )
		{
			target.health = target.max_health;
		}
	}

	target.items = (target.items | IT_KEY1);
	if ( target.lvl <= MOON_PLAYER_LEVEL_GROW_FAST )
	{
		target.point = (target.point + MOON_PLAYER_POINT_GROW_FAST);
	} else
	if ( target.lvl <= MOON_PLAYER_LEVEL_GROW_NORMAL )
	{
		target.point = (target.point + MOON_PLAYER_POINT_GROW_NORMAL);
	} else {
		target.point = (target.point + MOON_PLAYER_POINT_GROW_SLOW);
	}

	sound(target, CHAN_BODY, "moon/misc/levelup.wav", 1, ATTN_NORM);
	sprint(target, "=== Level Up! ===\n");
	sprint(target, "You are now level {0}\n", quick_ftos(target.lvl));

	if (moon_target_player_needs_tutorial(target))
	{
		sprint(target, "Get {0} experience for the next Level.\n", quick_ftos(target.nextexp));
		sprint(target, "use `stats` command to check and upgrade your stats\n");
		sprint(target, "-----------------\n");
	}
};

void(entity heart) level_up_heart =
{
	if (heart == world) { return; }

	if (heart.lvl >= MOON_HEART_MAX_LEVEL)
	{
		bprint("Congratulations! You \swon\s the game.\n");
		intermission_victory();
		return;
	}

	moon_spawn_guard();

	heart.frags = heart.lvl + 1;
	heart.nextexp = moon_get_experience_for_next_level(heart.frags, heart.nextexp); // Increase requirement with updated level
	heart.lvl = heart.frags;

	heart.max_health = (heart.max_health + MOON_HEART_HEALTH_GROW);
	heart.health = (heart.health + MOON_HEART_HEALTH_GROW);
	if (heart.health > heart.max_health)
	{
		heart.health = heart.max_health;
	}
};

void(float experience) moon_grant_all_exp =
{
	local entity heart;
	local entity e;

	if (gameover) { return; }

	heart = find(world, classname, MOON_HEART_CLASSNAME);
	if (heart != world)
	{
		heart.exp = (heart.exp + experience);
		if (heart.exp >= heart.nextexp)
		{
			level_up_heart(heart);
		}
	}

	while ( (e = find(e, classname, MOON_PLAYER_CLASSNAME)) )
	{
		e.exp = (e.exp + experience);
		if (e.exp >= e.nextexp)
		{
			level_up_target(e);
		}
	}
};