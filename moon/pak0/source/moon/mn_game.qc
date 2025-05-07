/// ReProjectMoon-specific source file
/// Here go all functions executed every frame or so inside game logic loop

// Curently there is not much to do, but for future
void(entity target, float delay = 0) moon_queue_target_for_removal
{
	target.nextthink = time + delay;
	target.think = SUB_Remove;
};

void(entity monster, float delay = 0) moon_queue_monster_for_removal
{
	moon_queue_target_for_removal(monster, delay);
	monster.solid = SOLID_NOT;
	moon_update_hud_kill();
};

void() moon_cheat_quad = // Debug only. Remove before release
{
	if (!(MOON_DEBUG & MOON_DEBUG_CHEATS_ON) ) { return; }

	self.super_time = 1;
	self.super_damage_finished = (time + 30);
	self.items = (self.items | IT_QUAD);
	self.items = (self.items | (IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING));
	self.ammo_shells = MOON_AMMO_MAX_SHELL;
	self.ammo_nails = MOON_AMMO_MAX_NAIL;
	self.ammo_rockets = MOON_AMMO_MAX_ROCKET;
	self.ammo_cells = MOON_AMMO_MAX_CELL;
	bprint("{0}: KILL KILL @_@ KILL KILL\n", self.netname);
};

void() moon_cheat_gold = // Debug only. Remove before release
{
	if (!(MOON_DEBUG & MOON_DEBUG_CHEATS_ON) ) { return; }

	self.up_cell = MOON_CONST_UNLOCKED;
	self.gold = 9999;
	flash_self();
	bprint("{0}: MONEY MONEY MONEY $_$ MONEY MONEY MONEY\n", self.netname);
};

// If player was doing nothing this frame, we can try searching something around him
//   and if there for some reasons Shop or Market items around - at least show name and cost
void() moon_handle_impulse_noop =
{
	local entity selected;
	local entity e;
	local float min_dist;
	local string rarity;

	if ( time < self.nextfind_time )
	{
		return;
	}
	self.nextfind_time = time + MOON_TIME_BETWEEN_ITEMSCANS;

	min_dist = MOON_PHYSIC_ITEMSEARCH_RADIUS;
	while ( (e = find(e, classname, MOON_TRADE_SHOP_SPOT_CLASSNAME)) ) // TODO: redo iteration by other field, that is common for both Shop and Market
	{
		if ( vlen(e.origin - self.origin) < min_dist)
		{
			min_dist = vlen(e.origin - self.origin);
			selected = e;
		}
	}
	if ( (selected != world) && (selected.targetname != "") )
	{
		centerprint(self, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{0} ({1} gold)", selected.targetname, floor_ftos(selected.cost));
		return;
	}

	e = world; // reset iterator
	min_dist = MOON_PHYSIC_ITEMSEARCH_RADIUS;
	while ( (e = find(e, classname, MOON_TRADE_MARKET_SPOT_CLASSNAME)) )
	{
		if ( vlen(e.origin - self.origin) < min_dist)
		{
			min_dist = vlen(e.origin - self.origin);
			selected = e;
		}
	}
	if ( (selected != world) && (selected.targetname != "") )
	{
		if ( (selected.netname == MOON_ITEM_ARMOR_NETNAME) || (selected.netname == MOON_ITEM_RING_NETNAME) )
		{
			rarity = moon_get_item_rarity_display(selected.magic_rarity_level);
			centerprint(self, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{0}{1}{2}{3} ({4} gold)"
							, selected.prefix_one
							, selected.targetname
							, selected.prefix_two
							, rarity
							, floor_ftos(selected.cost)
			);
		} else {
			centerprint(self, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{0} [{1}] ({2} gold)", selected.targetname, floor_ftos(selected.count), floor_ftos(selected.cost));
		}
		return;
	}
};

void(float impulse_code) moon_handle_impulse_stat =
{
	if ( self.point <= 0 )
	{
		sprint(self, "no free skill points\n");
		return;
	}

	self.point = (self.point - 1);
	switch(impulse_code)
	{
		case MOON_IMPULSE_CODE_UPSKILL_VITALITY:
			moon_raise_target_vitality(self, 1);

			sprint(self, "upgrade Vitality: {} (", quick_ftos(self.vit));
			sprint(self, MOON_ITEM_HEALTH_EFFECT, quick_ftos(self.max_health));
			sprint(self, ")\n");
			break;
		case MOON_IMPULSE_CODE_UPSKILL_STRENGTH:
			moon_raise_target_strength(self, 1);

			sprint(self, "upgrade Strength: {} (", quick_ftos(self.stre));
			sprint(self, MOON_ITEM_DAMAGE_EFFECT, quick_ftos((self.stre * MOON_STAT_DAMAGE_PER_STRENGTH) + 100));
			sprint(self, ")\n");
			break;
		case MOON_IMPULSE_CODE_UPSKILL_SANITY:
			// moon_raise_target_sanity(self, 1);
			// TODO: implement
			break;
		case MOON_IMPULSE_CODE_UPSKILL_INTUITION:
			// moon_raise_target_intuition(self, 1);
			// TODO: implement
			break;
	}

	if ( self.point <= 0 )
	{
		if ( self.items & IT_KEY1 )
		{
			self.items = (self.items - IT_KEY1);
		}
	}
};

void() moon_eprint_monsters_alive =
{
	if (!(MOON_DEBUG & MOON_DEBUG_EPRINT_MONSTERS) ) { return; }

	local entity e;
	local float found;

	dprint("== Alive monsters ==\n");

	found = FALSE;
	e = findradius(self.origin, 2025);
	while ( (e != world) )
	{
		if ( (e.classname != "waypoint") && (e.deadflag == DEAD_NO) )
		{
			eprint(e);
			found = TRUE;
		}
		e = e.chain;
	}
	if ( found ) { return; }

	found = FALSE;
	e = findradius(self.origin, 768);
	while ( (e != world) )
	{
		if ( e.classname != "waypoint" )
		{
			eprint(e);
			found = TRUE;
		}
		e = e.chain;
	}
	dprint("==    end of list ==\n");
};

void(float impulse_code) moon_handle_impulse_ui =
{
	switch(impulse_code)
	{
	case MOON_IMPULSE_CODE_DEBUG_EPRINT_MONSTERS_ALIVE:
		moon_eprint_monsters_alive();
		break;
	case MOON_IMPULSE_CODE_PRINT_STAT:
		moon_print_skills();
		break;
	case MOON_IMPULSE_CODE_UPSKILL_VITALITY:
	case MOON_IMPULSE_CODE_UPSKILL_STRENGTH:
	case MOON_IMPULSE_CODE_UPSKILL_SANITY:
	case MOON_IMPULSE_CODE_UPSKILL_INTUITION:
		moon_handle_impulse_stat(impulse_code);
		break;
	case MOON_IMPULSE_CODE_PRINT_CLI_HELP:
		moon_print_cmd_help();
		break;
	case MOON_IMPULSE_CODE_PRINT_INVENTORY:
		moon_print_inventory();
		break;
	case MOON_IMPULSE_CODE_PRINT_STATUS:
		moon_print_character_status();
		break;
	default:
		dprint("Unhandled impulse code for CLI UI {0}\n", quick_ftos(impulse_code));
	}
};

void(float impulse_code) moon_handle_impulse_server =
{
	if (self.colormap != 1)
	{
		return;
	}

	switch(self.impulse)
	{
	case MOON_IMPULSE_CODE_ALWAYSDAY:
		if (sv_alwaysday == 0)
		{
			sv_alwaysday = 1;
			moon_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "alwaysday enabled\n");
		} else {
			sv_alwaysday = 0;
			moon_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "alwaysday disabled\n");
		}
		break;
	case MOON_IMPULSE_CODE_NOSHAKE:
		if (sv_noshake == 0)
		{
			sv_noshake = 1;
			moon_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "Moonquakes disabled\n");
		} else {
			sv_noshake = 0;
			moon_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "Moonquakes enabled\n");
		}
		break;
	case MOON_IMPULSE_CODE_FASTMEAT:
		if (sv_fastmeat > 0)
		{
			sv_fastmeat = 0;
			moon_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "fastmeat disabled\n");
		} else {
			sv_fastmeat = 1;
			moon_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "fastmeat enabled\n");
		}
		break;
	case MOON_IMPULSE_CODE_SLOWMEAT:
		if (sv_fastmeat < 0)
		{
			sv_fastmeat = 0;
			moon_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "slo-owmeat disabled\n");
		} else {
			sv_fastmeat =-1;
			moon_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "slo-owmeat enabled\n");
		}
		break;
	case MOON_IMPULSE_CODE_CHEAT_QUAD:
		moon_cheat_quad();
		break;
	case MOON_IMPULSE_CODE_CHEAT_GOLD:
		moon_cheat_gold();
		break;
	default:
		dprint("Unhandled impulse code for SERVER settings {0}\n", quick_ftos(impulse_code));
	}
};

void(float impulse_code) moon_handle_impulse_client =
{
	switch(self.impulse)
	{
	case MOON_IMPULSE_CODE_NOHELP:
		if (self.cl_nohelp == 0)
		{
			self.cl_nohelp = 1;
			moon_chat_message_self(MOON_CHAT_NAME_SETTINGS, MOON_CHAT_COLOR_TECHMSG, "extra help disabled\n");
		} else {
			self.cl_nohelp = 0;
			moon_chat_message_self(MOON_CHAT_NAME_SETTINGS, MOON_CHAT_COLOR_TECHMSG, "extra help enabled\n");
		}
		break;
	case MOON_IMPULSE_CODE_SHOWFPS:
		if (self.cl_framtime == 0)
		{
			self.cl_framtime = 1;
			moon_chat_message_self(MOON_CHAT_NAME_SETTINGS, MOON_CHAT_COLOR_TECHMSG, "FPS count enabled\n");
		} else {
			self.cl_framtime = 0;
			moon_chat_message_self(MOON_CHAT_NAME_SETTINGS, MOON_CHAT_COLOR_TECHMSG, "FPS count disabled\n");
		}
		break;
	default:
		dprint("Unhandled impulse code for CLIENT settings {0}\n", quick_ftos(impulse_code));
	}
};

void(float impulse_code) moon_handle_impulse_trace =
{
	switch(impulse_code)
	{
	case MOON_IMPULSE_CODE_ITEM_PICKUP:
		moon_self_pickup_magic_item_and_clear();
		break;
	case MOON_IMPULSE_CODE_ITEM_BUY:
		moon_buy_item();
		break;
	case MOON_IMPULSE_CODE_ITEM_IDENTIFY:
		moon_identify_item();
		break;
	default:
		dprint("Unhandled impulse code for CLI UI {0}\n", quick_ftos(impulse_code));
	}
};

void() moon_handle_impulse =
{
	// TODO: killme \/ JUKEBOX CONTROLS
	if ( (self.impulse >= 220) && (self.impulse <= 232) )
	{
		moon_walkman_play(self, self.impulse - 220);
	} else //       /\
	if ( (MOON_IMPULSE_CODE_FIRST_CLI_UI <= self.impulse) && (self.impulse <= MOON_IMPULSE_CODE_LAST_CLI_UI) )
	{
		moon_handle_impulse_ui(self.impulse);
	} else
	if ( (MOON_IMPULSE_CODE_FIRST_SETTING_SERVER <= self.impulse) && (self.impulse <= MOON_IMPULSE_CODE_LAST_SETTING_SERVER) )
	{
		moon_handle_impulse_server(self.impulse);
	} else
	if ( (MOON_IMPULSE_CODE_FIRST_SETTING_CLIENT <= self.impulse) && (self.impulse <= MOON_IMPULSE_CODE_LAST_SETTING_CLIENT) )
	{
		moon_handle_impulse_client(self.impulse);
	} else
	if ( (MOON_IMPULSE_CODE_FIRST_TRACE <= self.impulse) && (self.impulse <= MOON_IMPULSE_CODE_LAST_TRACE) )
	{
		moon_handle_impulse_trace(self.impulse);
	} else {
		dprint("Impulse code {0} out of MOON's range {1}-{2}\n", quick_ftos(self.impulse), quick_ftos(MOON_IMPULSE_CODE_FIRST), quick_ftos(MOON_IMPULSE_CODE_LAST));
	}
};

void() moon_normalize_difficulty =
{
	if ( skill < MOON_DIFFICULTY_MIN )
	{
		skill = MOON_DIFFICULTY_MIN;
	}
	if ( skill > MOON_DIFFICULTY_MAX )
	{
		skill = MOON_DIFFICULTY_MAX;
	}
};

// Applicable to any unit (Player, Guard, Monster, Heart)
float(entity target) moon_do_target_natural_health_regen_tick =
{
	if ( target.natural_regen_time > time )
	{
		return target.natural_regen_time;
	}
	if ( (target.deadflag == DEAD_RESPAWNABLE) || (target.deadflag == DEAD_DEAD) )
	{
		return target.natural_regen_time;
	}

	if ( (target.natural_regen_cooldown <= 0) || (target.natural_regen_value <= 0) )
	{
		return target.natural_regen_time + MOON_TIME_BETWEEN_FAILED_CHECKS;
	}

	// needing health or not needing it, attempt is using regen -> puts cooldown
	target.natural_regen_time = time + target.natural_regen_cooldown;

	if ( (target.health <= 0) || (target.health >= target.max_health) )
	{
		return target.natural_regen_time;
	}

	T_Heal(target, target.natural_regen_value);

	return target.natural_regen_time;
};

// Applicable only to Player
float(entity target) moon_do_target_magical_health_regen_tick =
{
	local float bonus;

	if ( target.magical_regen_time > time )
	{
		return target.magical_regen_time;
	}
	if ( (target.deadflag == DEAD_RESPAWNABLE) || (target.deadflag == DEAD_DEAD) )
	{
		return target.magical_regen_time;
	}

	bonus = moon_get_target_total_bonus_by_code(target, MOON_ITEM_REGEN_CODE);
	if (bonus <= 0)
	{
		return target.magical_regen_time + MOON_TIME_BETWEEN_FAILED_CHECKS;
	}

	// needing health or not needing it, attempt is using regen -> puts cooldown
	target.magical_regen_time = time + MOON_ITEM_REGEN_COOLDOWN;

	if ( (target.health <= 0) || (target.health >= target.max_health) )
	{
		return target.magical_regen_time;
	}

	T_Heal(target, bonus);

	return target.magical_regen_time;
};