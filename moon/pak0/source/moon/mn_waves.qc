/// ReProjectMoon-specific source file
/// Here go all functions related to spawning and managing creep waves


float(float lvl) moon_get_monster_wave_size_for_level =
{
	if ( lvl <= 1 )
	{
		return random_int(2, 5);
	}
	if ( lvl == 2 )
	{
		return random_int(2, 6);
	}
	if ( lvl == 3 )
	{
		return random_int(2, 6);
	}
	if ( lvl < 9 )
	{
		return random_int(3, 7);
	}
	if ( lvl < 18 )
	{
		return random_int(3, 8);
	}
	if ( lvl < 48 )
	{
		return random_int(4, 9);
	}
	//if ( lvl >= 48 )
	return random_int(5, 11);
};

void(entity who, float lvl) moon_set_monster_prefix_for_level =
{
	who.prefix_two = moon_lookup_monster_level_prefix(lvl);
};

float(float count, float difficulty) moon_clamp_monster_wave_size_for_difficulty =
{
	if ( difficulty <= MOON_DIFFICULTY_MIN )
	{
		if ( count > 3 )
		{
			return 3;
		}
	}
	if ( difficulty >= MOON_DIFFICULTY_MAX )
	{
		if ( count < 3 )
		{
			return 3;
		}
	}
	return count;
};

float(float lvl) moon_get_monster_wave_size_for_player =
{
	local float wave;

	wave = moon_get_monster_wave_size_for_level(lvl);
	wave = moon_clamp_monster_wave_size_for_difficulty(wave, skill);

	return wave;
};

float(float lvl, float player_count) moon_get_monster_wave_size =
{
	local float wave;

	wave = moon_get_monster_wave_size_for_player(lvl); // Initial wave size for Single player

	// Adjust wave size for Multiplayer. If necessary - later use individual player lvl, not maximum
	if ( player_count > 1 )
	{
		wave = wave + moon_get_monster_wave_size_for_player(lvl - 1);
	}
	if ( player_count > 2 )
	{
		wave = wave + moon_get_monster_wave_size_for_player(lvl - 2);
	}
	if ( player_count > 3 )
	{
		wave = wave + moon_get_monster_wave_size_for_player(lvl - 3);
	}

	return wave;
};

float(float lvl) moon_get_monster_spawn_type =
{
	if ( lvl < MOON_MONSTER_BASELEVEL_ENFORCER )
	{
		return MOON_MONSTER_CODE_SOLDIER;
	}
	if ( lvl < MOON_MONSTER_BASELEVEL_SPIDER )
	{
		return random_int(MOON_MONSTER_CODE_SOLDIER, MOON_MONSTER_CODE_ENFORCER);
	}
	if ( lvl < MOON_MONSTER_BASELEVEL_OGRE )
	{
		return random_int(MOON_MONSTER_CODE_SOLDIER, MOON_MONSTER_CODE_SPIDER);
	}
	if ( lvl < MOON_MONSTER_BASELEVEL_SNAKE )
	{
		return random_int(MOON_MONSTER_CODE_SOLDIER, MOON_MONSTER_CODE_OGRE);
	}
	if ( lvl < MOON_MONSTER_BASELEVEL_MAGE )
	{
		return random_int(MOON_MONSTER_CODE_SOLDIER, MOON_MONSTER_CODE_SNAKE);
	}
	if ( lvl < MOON_MONSTER_BASELEVEL_SHALRATH )
	{
		return random_int(MOON_MONSTER_CODE_SOLDIER, MOON_MONSTER_CODE_MAGE);
	}
	//if ( lvl >= MOON_MONSTER_BASELEVEL_SHALRATH )
	return random_int(MOON_MONSTER_CODE_SOLDIER, MOON_MONSTER_CODE_SHALRATH);
};

void(entity spawner, float player_level) moon_spawn_monster =
{
	local float monster_type;
	local float random_shift;
	local float player_level_adjusted;
	local entity monster;

	random_shift = random_int(0, skill);
	player_level_adjusted = player_level - random_shift;

	spawner.count = (spawner.count - 1);
	monster_type = moon_get_monster_spawn_type(player_level);
	// moon_spawn_monster_entity();
	switch(monster_type)	// TODO: split/refactor spawn_X functions to handle only specific to X stuff there
	{
	case MOON_MONSTER_CODE_SOLDIER:
		monster = spawn_soldier(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_SOLDIER, MOON_CONST_MAXLVL) );
		break;
	case MOON_MONSTER_CODE_ENFORCER:
		monster = spawn_enforcer(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_ENFORCER, MOON_CONST_MAXLVL));
		break;
	case MOON_MONSTER_CODE_SPIDER:
		monster = spawn_spider(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_SPIDER, MOON_CONST_MAXLVL));
		break;
	case MOON_MONSTER_CODE_OGRE:
		monster = spawn_ogre(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_OGRE, MOON_CONST_MAXLVL));
		break;
	case MOON_MONSTER_CODE_SNAKE:
		monster = spawn_snake(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_SNAKE, MOON_CONST_MAXLVL));
		break;
	case MOON_MONSTER_CODE_MAGE:
		monster = spawn_mage(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_MAGE, MOON_CONST_MAXLVL));
		break;
	case MOON_MONSTER_CODE_SHALRATH:
		monster = spawn_shalrath(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_SHALRATH, MOON_CONST_MAXLVL));
		break;
	default:
		dprint("ERROR IN moon_spawn_monster(...): monster_type spawns null monster\n");
		return;
	}

	monster.flags = (self.flags | FL_MONSTER); // should be in // moon_spawn_monster_entity();
	monster.classname = MOON_MONSTER_CLASSNAME; // should be in // moon_spawn_monster_entity();
	moon_debug_println_object_name(monster); // Debug only
};