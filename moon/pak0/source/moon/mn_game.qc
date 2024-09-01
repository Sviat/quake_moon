/// ReProjectMoon-specific source file
/// Here go all functions executed every frame or so inside game logic loop

// If player was doing nothing this frame, we can try searching something around him
//   and if there for some reasons Shop or Market items around - at least show name and cost
void() moon_handle_impulse_noop =
{
	local entity selected;
	local entity e;
	local float min_dist;

	min_dist = MOON_PHYSIC_ITEMSEARCH_RADIUS;
	while ( (e = find(e, classname, MOON_TRADE_SHOP_SPOT_CLASSNAME)) ) // TODO: redo iteration by other field, that is common for both Shop and Market
	{
		if ( vlen(e.origin - self.origin) < min_dist)
		{
			min_dist = vlen(e.origin - self.origin);
			selected = e;
		}
	}
	if ( (selected != world) && (selected.targetname != s_wiz) )
	{
		centerprint(self, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{} ({} gold)", selected.targetname, floor_ftos(selected.cost));
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
	if ( (selected != world) && (selected.targetname != s_wiz) )
	{
		centerprint(self, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{} ({} gold)", selected.targetname, floor_ftos(selected.cost));
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

void(float impulse_code) moon_handle_impulse_ui =
{
	switch(impulse_code)
	{
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
		dprint("Unhandled impulse code for CLI UI {}\n", impulse_code);
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
			moon_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "Earthquakes disabled\n");
		} else {
			sv_noshake = 0;
			moon_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "Earthquakes enabled\n");
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
		QuadCheat();
		break;
	default:
		dprint("Unhandled impulse code for SERVER settings {}\n", impulse_code);
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
			moon_chat_message_self(MOON_CHAT_NAME_SETTINGS, MOON_CHAT_COLOR_TECHMSG, "extra help enabled\n");
		} else {
			self.cl_nohelp = 0;
			moon_chat_message_self(MOON_CHAT_NAME_SETTINGS, MOON_CHAT_COLOR_TECHMSG, "extra help disabled\n");
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
		dprint("Unhandled impulse code for CLIENT settings {}\n", impulse_code);
	}
};

void(float impulse_code) moon_handle_impulse_trace =
{
	switch(impulse_code)
	{
	case MOON_IMPULSE_CODE_ITEM_PICKUP:
		moon_wear_item();
		break;
	case MOON_IMPULSE_CODE_ITEM_BUY:
		moon_buy_item();
		break;
	case MOON_IMPULSE_CODE_ITEM_IDENTIFY:
		moon_identify_item();
		break;
	default:
		dprint("Unhandled impulse code for CLI UI {}\n", impulse_code);
	}
};

void() moon_handle_impulse =
{
	if ( self.prepared == FALSE )
	{
		Prepare();
	}

	if ( self.impulse == MOON_IMPULSE_CODE_NOOP )
	{
		if ( self.nextfind_time < time )
		{
			moon_handle_impulse_noop();
			self.nextfind_time = time + MOON_TIME_BETWEEN_ITEMSCANS;
		}
		return;
	}

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
		dprint("Impulse code {} out of Project Moon's range {}-{}\n", self.impulse, MOON_IMPULSE_CODE_FIRST, MOON_IMPULSE_CODE_LAST);
	}
};
