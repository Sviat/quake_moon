/// ReProjectMoon-specific source file
/// Here go all functions that communicate with user through console prints (Console UI)

string(float digit) moon_gets_golden_digit =
{
	switch(floor(digit))
	{
		case 0: return ("\0");
		case 1: return ("\1");
		case 2: return ("\2");
		case 3: return ("\3");
		case 4: return ("\4");
		case 5: return ("\5");
		case 6: return ("\6");
		case 7: return ("\7");
		case 8: return ("\8");
		case 9: return ("\9");
		default:
			dprint("<{}>", quick_ftos(digit)); // debug
			return MOON_GLYPH_CENTERDOT_WHITE;
	}
};

string(float digit) moon_gets_red_digit =
{
	switch(floor(digit))
	{
		case 0: return ("\xB0");
		case 1: return ("\xB1");
		case 2: return ("\xB2");
		case 3: return ("\xB3");
		case 4: return ("\xB4");
		case 5: return ("\xB5");
		case 6: return ("\xB6");
		case 7: return ("\xB7");
		case 8: return ("\xB8");
		case 9: return ("\xB9");
		default:
			dprint("<{}>", quick_ftos(digit)); // debug
			return MOON_GLYPH_CENTERDOT_WHITE;
	}
};

void(entity print_target, string print_text) moon_print_func_target =
{
	sprint(print_target, print_text);
};

void(entity print_target, string print_text) moon_print_func_all =
{
	bprint(print_text); // print_target unused
};

void(entity print_target, string print_text) moon_print_func_debug =
{
	dprint(print_text); // print_target unused
};

void(entity target, float number, string(float digit) color_func, void(entity print_target, string print_text) print_func) moon_funcprint_color_number =
{
	local float remainder;
	local float digit_count;

	digit_count = 1;
	remainder = rint(number);
	while(remainder >= 10)
	{
		digit_count = digit_count + 1;
		remainder = remainder / 10;
	}

	local float multiplier;
	multiplier = 1;
	for(float i = 1; i < digit_count; ++i)
	{
		multiplier = multiplier * 10;
	}

	local float top_part;
	remainder = rint(number);
	while(digit_count > 1)
	{
		top_part = floor(remainder / multiplier);
		remainder = remainder % multiplier;
		multiplier = multiplier / 10;
		digit_count = digit_count - 1;
		print_func(target, color_func(top_part));
	}
	print_func(target, color_func(remainder));
};

void(entity target, float number, string(float digit) color_func) moon_print_color_number =
{
    moon_funcprint_color_number(target, number, color_func, moon_print_func_target);
};

void(float number, string(float digit) color_func) moon_print_all_color_number =
{
    moon_funcprint_color_number(world, number, color_func, moon_print_func_all);
};

void(float number, string(float digit) color_func) moon_print_debug_color_number =
{
    moon_funcprint_color_number(world, number, color_func, moon_print_func_debug);
};

void(entity target, float number) moon_print_golden_number =
{
	moon_print_color_number(target, number, moon_gets_golden_digit);
};

void(entity target, float number) moon_print_red_number =
{
	moon_print_color_number(target, number, moon_gets_red_digit);
};

void(float number) moon_print_all_golden_number =
{
	moon_print_all_color_number(number, moon_gets_golden_digit);
};

void(float number) moon_print_all_red_number =
{
	moon_print_all_color_number(number, moon_gets_red_digit);
};

void(entity target) moon_println_target_gold =
{
	moon_print_golden_number(target, target.gold);
	sprint(target, "\n");
};

void() moon_println_all_global_gold_bonus =
{
	bprint("Global gold income now +");
    moon_print_all_golden_number(up_gold_value);
    bprint("%\n");
};

void(entity chat_target, entity value_target) moon_println_target_other_health =
{
	if (value_target.health < value_target.max_health)
	{
		moon_print_red_number(chat_target, value_target.health);
		sprint(chat_target, "/");
	}
	sprint(chat_target, "{}\n", floor_ftos(value_target.max_health));
};

void(entity value_target) moon_println_all_other_health =
{
    if (value_target.health < value_target.max_health)
    {
        moon_print_all_red_number(value_target.health);
        bprint("/");
    }
    bprint("{}\n", floor_ftos(value_target.max_health));
};

void(entity target) moon_println_target_exp =
{
	sprint(target, "Level: {}, Exp {}{}/{}{}\n", floor_ftos(target.lvl), MOON_GLYPH_BRACKET_OPEN, floor_ftos(target.exp), quick_ftos(ceil(target.nextexp)), MOON_GLYPH_BRACKET_CLOSE);
};

void(entity target) moon_print_mentat_offense =
{
	sprint(target, MOON_MENTAT_OFFENSE_NAME);
	sprint(target, " (increase your damage by ");
	moon_print_golden_number(target, MOON_MENTAT_OFFENSE_VALUE);
	sprint(target, "%)");
};

void(entity target) moon_print_mentat_defense =
{
	sprint(target, MOON_MENTAT_DEFENSE_NAME);
	sprint(target, " (decrease incoming damage by ");
	moon_print_golden_number(target, MOON_MENTAT_DEFENSE_VALUE);
	sprint(target, "%)");
};

void(entity target) moon_print_mentat_speed =
{
	sprint(target, MOON_MENTAT_SPEED_NAME);
	sprint(target, " (increase your attack speed by ");
	moon_print_golden_number(target, MOON_MENTAT_SPEED_VALUE_MIN);
	sprint(target, "-");
	moon_print_golden_number(target, MOON_MENTAT_SPEED_VALUE_MAX);
	sprint(target, "%%)");
};

void(entity target, string prefix, string name, string postfix) moon_print_target_item_name =
{
	if (prefix != s_wiz)
	{
		sprint(target, prefix);
	}
	sprint(target, name);
	if (postfix != s_wiz)
	{
		sprint(target, postfix);
	}
};

void(entity target, entity owner) moon_println_target_magic_armor_name =
{
    moon_print_target_item_name(target, owner.magic_prefixone, MOON_ITEM_ARMOR_DISPLAY, owner.magic_prefixtwo);
	sprint(target, "\n");
};

void(entity target, entity owner) moon_println_target_magic_ring_name =
{
    moon_print_target_item_name(target, owner.magic_prefixone, MOON_ITEM_RING_DISPLAY, owner.magic_prefixtwo);
	sprint(target, "\n");
};

void(entity target, entity container) moon_print_target_container_ammo =
{
	local float had_any;

	if ( container.ammo_shells )
	{
		sprint(target, " {} {}", floor_ftos(container.ammo_shells), MOON_AMMO_SHELLS_DISPLAYNAME);
		had_any = TRUE;
	}
	if ( container.ammo_nails )
	{
		sprint(target, " {} {}", floor_ftos(container.ammo_nails), MOON_AMMO_NAILS_DISPLAYNAME);
		had_any = TRUE;
	}
	if ( container.ammo_rockets )
	{
		sprint(target, " {} {}", floor_ftos(container.ammo_rockets), MOON_AMMO_ROCKETS_DISPLAYNAME);
		had_any = TRUE;
	}
	if ( container.ammo_cells )
	{
		sprint(target, " {} {}", floor_ftos(container.ammo_cells), MOON_AMMO_CELLS_DISPLAYNAME);
		had_any = TRUE;
	}

	if ( had_any != TRUE )
	{
		sprint(target, "\n");
		sprint(target, "ERROR: garbage shop have incorrect item! Report this bug and item!\n");
	}
};