/// ReProjectMoon-specific source file
/// Here go all functions that communicate with user through console prints (Console UI)


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
	sprint(target, "Level: {0}, Exp {1}{2}/{3}{4}\n", floor_ftos(target.lvl), MOON_CONST_GLYPH_BRACKET_OPEN, floor_ftos(target.exp), floor_ftos(target.nextexp), MOON_CONST_GLYPH_BRACKET_CLOSE);
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
	sprint(target, " (improve weapon attack or projectile speed)");
};

void(entity subject) moon_bprint_describe_player =
{
	bprint("{0} {1}, lvl [{2}], HP: {3}", subject.prefix_one, subject.netname, floor_ftos(subject.lvl), floor_ftos(subject.health));
	if ( subject.health != subject.max_health )
	{
		bprint("/{0}", floor_ftos(subject.max_health));
	}
	bprint(" in ");
	if ( subject.items & IT_ARMOR3 )
	{
		bprint(MOON_ARMOR_RED_DISPLAYNAME);
	} else
	if ( subject.items & IT_ARMOR2 )
	{
		bprint(MOON_ARMOR_YELLOW_DISPLAYNAME);
	} else
	if ( subject.items & IT_ARMOR1 )
	{
		bprint(MOON_ARMOR_GREEN_DISPLAYNAME);
	}
	bprint("({0}).\n", floor_ftos(subject.armorvalue));

	bprint("Weapons: {0}", MOON_WEAPON_SHOTGUN_SHORTNAME);
	if ( subject.items & IT_SUPER_SHOTGUN ) 	{ bprint(", {0}", MOON_WEAPON_SUPERSHOTGUN_SHORTNAME); }
	if ( subject.items & IT_NAILGUN ) 			{ bprint(", {0}", MOON_WEAPON_NAILGUN_SHORTNAME); }
	if ( subject.items & IT_SUPER_NAILGUN ) 	{ bprint(", {0}", MOON_WEAPON_SUPERNAILGUN_SHORTNAME); }
	if ( subject.items & IT_GRENADE_LAUNCHER ) 	{ bprint(", {0}", MOON_WEAPON_GRENADELAUNCHER_SHORTNAME); }
	if ( subject.items & IT_ROCKET_LAUNCHER ) 	{ bprint(", {0}", MOON_WEAPON_ROCKETLAUNCHER_SHORTNAME); }
	if ( subject.items & IT_LIGHTNING ) 		{ bprint(", {0}", MOON_WEAPON_LIGHTNING_SHORTNAME); }
	bprint(".\n");
};

void(entity target, string prefix, string name, string postfix) moon_print_target_item_name =
{
	if (prefix != "")
	{
		sprint(target, prefix);
	}
	sprint(target, name);
	if (postfix != "")
	{
		sprint(target, postfix);
	}
};

void(entity target, float rarity_level) moon_print_target_item_rarity = // duplicates moon_lookup_item_rarity_display, but thats more eco-friendly
{
	switch(rarity_level)
	{
	case MOON_ITEM_RARITY_THRESHOLD_TRASH:
		sprint(target, " {0}{1}{2}", MOON_CONST_GLYPH_BRACKET_OPEN, MOON_ITEM_RARITY_THRESHOLD_DISPLAY_TRASH, MOON_CONST_GLYPH_BRACKET_CLOSE);
		break;
	case MOON_ITEM_RARITY_THRESHOLD_COMMON:
		sprint(target, " {0}{1}{2}", MOON_CONST_GLYPH_BRACKET_OPEN, MOON_ITEM_RARITY_THRESHOLD_DISPLAY_COMMON, MOON_CONST_GLYPH_BRACKET_CLOSE);
		break;
	case MOON_ITEM_RARITY_THRESHOLD_UNCOMMON:
		sprint(target, " {0}{1}{2}", MOON_CONST_GLYPH_BRACKET_OPEN, MOON_ITEM_RARITY_THRESHOLD_DISPLAY_UNCOMMON, MOON_CONST_GLYPH_BRACKET_CLOSE);
		break;
	case MOON_ITEM_RARITY_THRESHOLD_RARE:
		sprint(target, " {0}{1}{2}", MOON_CONST_GLYPH_BRACKET_OPEN, MOON_ITEM_RARITY_THRESHOLD_DISPLAY_RARE, MOON_CONST_GLYPH_BRACKET_CLOSE);
		break;
	case MOON_ITEM_RARITY_THRESHOLD_EPIC:
		sprint(target, " {0}{1}{2}", MOON_CONST_GLYPH_BRACKET_OPEN, MOON_ITEM_RARITY_THRESHOLD_DISPLAY_EPIC, MOON_CONST_GLYPH_BRACKET_CLOSE);
		break;
	case MOON_ITEM_RARITY_THRESHOLD_LEGENDARY:
		sprint(target, " {0}{1}{2}", MOON_CONST_GLYPH_BRACKET_OPEN, MOON_ITEM_RARITY_THRESHOLD_DISPLAY_LEGENDARY, MOON_CONST_GLYPH_BRACKET_CLOSE);
		break;
	case MOON_ITEM_RARITY_THRESHOLD_UNIQUE:
		sprint(target, " {0}{1}{2}", MOON_CONST_GLYPH_BRACKET_OPEN, MOON_ITEM_RARITY_THRESHOLD_DISPLAY_UNIQUE, MOON_CONST_GLYPH_BRACKET_CLOSE);
		break;
	default:
		break;
	}
};

void(entity target, entity owner) moon_println_target_magic_armor_name =
{
    moon_print_target_item_name(target, owner.magic_prefixone, MOON_ITEM_ARMOR_DISPLAY, owner.magic_prefixtwo);
	moon_print_target_item_rarity(target, owner.magic_rarity_level);
	sprint(target, "\n");
};

void(entity target, entity owner) moon_println_target_magic_ring_name =
{
    moon_print_target_item_name(target, owner.ring_prefixone, MOON_ITEM_RING_DISPLAY, owner.ring_prefixtwo);
	moon_print_target_item_rarity(target, owner.ring_rarity_level);
	sprint(target, "\n");
};

void(entity target, entity container) moon_print_target_container_ammo =
{
	local float had_any;

	if ( container.ammo_shells )
	{
		sprint(target, " {0} {1}", floor_ftos(container.ammo_shells), MOON_AMMO_SHELLS_DISPLAYNAME);
		had_any = TRUE;
	}
	if ( container.ammo_nails )
	{
		sprint(target, " {0} {1}", floor_ftos(container.ammo_nails), MOON_AMMO_NAILS_DISPLAYNAME);
		had_any = TRUE;
	}
	if ( container.ammo_rockets )
	{
		sprint(target, " {0} {1}", floor_ftos(container.ammo_rockets), MOON_AMMO_ROCKETS_DISPLAYNAME);
		had_any = TRUE;
	}
	if ( container.ammo_cells )
	{
		sprint(target, " {0} {1}", floor_ftos(container.ammo_cells), MOON_AMMO_CELLS_DISPLAYNAME);
		had_any = TRUE;
	}

	if ( had_any != TRUE )
	{
		sprint(target, "\n");
		sprint(target, "ERROR: container have no ammo! Report this bug and item!\n");
	}
};

void(entity target, float effect_code, float effect_value) moon_println_target_magic_effect =
{
	if (!effect_code) { return; }

	switch(effect_code)
	{
	case MOON_ITEM_HEALTH_CODE:
        sprint(target, MOON_ITEM_HEALTH_EFFECT, floor_ftos(effect_value));
		break;
	case MOON_ITEM_RESIST_CODE:
        sprint(target, MOON_ITEM_RESIST_EFFECT, floor_ftos(effect_value));
		break;
	case MOON_ITEM_GOLD_CODE:
        sprint(target, MOON_ITEM_GOLD_EFFECT, floor_ftos(effect_value));
		break;
	case MOON_ITEM_DAMAGE_CODE:
        sprint(target, MOON_ITEM_DAMAGE_EFFECT, floor_ftos(effect_value));
		break;
	case MOON_ITEM_RETALATE_CODE:
        sprint(target, MOON_ITEM_RETALATE_EFFECT, floor_ftos(effect_value));
		break;
	case MOON_ITEM_VAMPIR_CODE:
        sprint(target, MOON_ITEM_VAMPIR_EFFECT, floor_ftos(effect_value));
		break;
	case MOON_ITEM_REGEN_CODE:
        sprint(target, MOON_ITEM_REGEN_EFFECT, floor_ftos(effect_value));
		break;
	case MOON_ITEM_CONSUME_CODE:
        sprint(target, MOON_ITEM_CONSUME_EFFECT, floor_ftos(effect_value));
		break;
	case MOON_ITEM_REPAIR_CODE:
        sprint(target, MOON_ITEM_REPAIR_EFFECT, floor_ftos(effect_value));
		break;
	default:
		dprint("Unknown effect code {}\n", effect_code);
		return; // Avoid newline
    }

    sprint(target, "\n");
};

// This is called magic item, not magic armor, since sometimes rings properties are stored in common fields of magic_X
void(entity target, entity item) moon_println_target_magic_item_description =
{
	if (item.magic_typeone == item.magic_typetwo)
	{
		moon_println_target_magic_effect(target, item.magic_typeone, item.magic_typeone_value + item.magic_typetwo_value);
	} else {
		moon_println_target_magic_effect(target, item.magic_typeone, item.magic_typeone_value);
		moon_println_target_magic_effect(target, item.magic_typetwo, item.magic_typetwo_value);
	}
};

void(entity target, entity item) moon_println_target_magic_ring_description =
{
	if (item.ring_typeone == item.ring_typetwo)
	{
		moon_println_target_magic_effect(target, item.ring_typeone, item.ring_typeone_value + item.ring_typetwo_value);
	} else {
		moon_println_target_magic_effect(target, item.ring_typeone, item.ring_typeone_value);
		moon_println_target_magic_effect(target, item.ring_typetwo, item.ring_typetwo_value);
	}
};

void(entity target) moon_println_target_own_magic_item_description =
{
	moon_println_target_magic_item_description(target, self);
};

void(entity target) moon_println_target_own_magic_ring_description =
{
	moon_println_target_magic_ring_description(target, self);
};

void() moon_print_inventory =
{
	float duration;
	float did_print_section;

	if ( (self.wear_armor == MOON_ITEM_NONE) && (self.wear_ring == MOON_ITEM_NONE)
	  && (self.mentat_offense_time <= time)
	  && (self.mentat_defense_time <= time)
	  && (self.mentat_attackspeed_time <= time ) )
	{
		sprint(self, "you have \sno\s special items\n");
		return;
	}

	did_print_section = FALSE;
	sprint(self, "==== your current items ====\n");
	if ( self.mentat_offense_time > time )
	{
		moon_print_mentat_offense(self);
		duration = self.mentat_offense_time - time;
		sprint(self, " {0}{1}{2}\n", MOON_CONST_GLYPH_BRACKET_OPEN, floor_ftos(duration), MOON_CONST_GLYPH_BRACKET_CLOSE);
		did_print_section = TRUE;
	}
	if ( self.mentat_defense_time > time )
	{
		moon_print_mentat_defense(self);
		duration = self.mentat_defense_time - time;
		sprint(self, " {0}{1}{2}\n", MOON_CONST_GLYPH_BRACKET_OPEN, floor_ftos(duration), MOON_CONST_GLYPH_BRACKET_CLOSE);
		did_print_section = TRUE;
	}
	if ( self.mentat_attackspeed_time > time )
	{
		moon_print_mentat_speed(self);
		duration = self.mentat_attackspeed_time - time;
		sprint(self, " {0}{1}{2}\n", MOON_CONST_GLYPH_BRACKET_OPEN, floor_ftos(duration), MOON_CONST_GLYPH_BRACKET_CLOSE);
		did_print_section = TRUE;
	}

	if ( self.wear_armor == MOON_ITEM_SOME )
	{
		if (did_print_section == TRUE)
		{
			sprint(self, "--------------------------\n");
		}
		sprint(self, CONST_QC_GLYPH_SELECTION);
		moon_println_target_magic_armor_name(self, self);
		moon_println_target_own_magic_item_description(self);
	}

	if ( self.wear_ring == MOON_ITEM_SOME )
	{
		if (did_print_section == TRUE)
		{
			sprint(self, "--------------------------\n");
		}
		sprint(self, CONST_QC_GLYPH_SELECTION);
		moon_println_target_magic_ring_name(self, self);
		moon_println_target_own_magic_ring_description(self);
	}
	sprint(self, "--------------------------\n");
};

void() moon_print_character_status =
{
	local entity heart;
	heart = find(world, classname, MOON_HEART_CLASSNAME);
    if ( heart == world ) { return; }

	sprint(self, "======= Status =======\n");
	sprint(self, "\sHeart\s's Life: ");
	moon_println_target_other_health(self, heart);
	sprint(self, "Monsters Killed: {}\n", floor_ftos(self.mosterskilled));
	moon_println_target_exp(self);
	sprint(self, "Gold: ");
	moon_println_target_gold(self);
	sprint(self, "----------------------\n");
};

void() moon_print_cmd_help =
{
	sprint(self, "======= help on game commands =======\n");
	sprint(self, "general prefix: `pm_`, server-side settings: `pms_`, client-side: `pmc_`\n");
	sprint(self, "{}| use `pm_identify` (v) command to get a description of item nearby.\n", quick_ftos(MOON_IMPULSE_CODE_ITEM_IDENTIFY));
	sprint(self, "{}| use `pm_buy` (f) command to buy closest item in the shop.\n", quick_ftos(MOON_IMPULSE_CODE_ITEM_BUY));
	sprint(self, "{}| use `pm_use` (e) command pick up closest magical item.\n", quick_ftos(MOON_IMPULSE_CODE_ITEM_PICKUP));
	sprint(self, " {0}| {1}| use `pm_skill\1`/`pm_skill\2` raise skills\n", quick_ftos(MOON_IMPULSE_CODE_UPSKILL_VITALITY), quick_ftos(MOON_IMPULSE_CODE_UPSKILL_STRENGTH));
	sprint(self, " {}| use `pm_character` (c) command to view character screen.\n", quick_ftos(MOON_IMPULSE_CODE_PRINT_STATUS));
	sprint(self, " {}| use `pm_stats` (t) command to view screen with your stats.\n", quick_ftos(MOON_IMPULSE_CODE_PRINT_STAT));
	sprint(self, " {}| use `pm_inventory` (x) command to view inventory screen.\n", quick_ftos(MOON_IMPULSE_CODE_PRINT_INVENTORY));
	sprint(self, "{0}|{1}| use `pms_fastmeat`/`pms_slowmeat` to grind faster or slower\n", quick_ftos(MOON_IMPULSE_CODE_FASTMEAT), quick_ftos(MOON_IMPULSE_CODE_SLOWMEAT));
	sprint(self, "{}| use `pms_alwaysday` to shine bright\n", quick_ftos(MOON_IMPULSE_CODE_ALWAYSDAY));
	sprint(self, "{}| use `pms_noshake` to earth without quake\n", quick_ftos(MOON_IMPULSE_CODE_NOSHAKE));
	sprint(self, "{}| use `pmc_nohelp` to reduce amount of hints\n", quick_ftos(MOON_IMPULSE_CODE_NOHELP));
	sprint(self, "{}| use `pmc_fps` to show Framerate\n", quick_ftos(MOON_IMPULSE_CODE_SHOWFPS));
	sprint(self, "use `map moon4` or `restartserver` to restart this map\n");
	sprint(self, "-------------------------------------\n");
};

void(entity item, entity subject) moon_identify_magic_item_by_subject =
{
	if (subject.classname != MOON_PLAYER_CLASSNAME) { return; }
	if (subject.health <= 0) { return; }

	if ( (item.next_mesg_time < time) && (subject.next_mesg_time < time) )
	{
		sprint(subject, "=== magic item ===\n");
		moon_print_target_item_name(subject, item.prefix_one, item.netname, item.prefix_two);
		moon_print_target_item_rarity(subject, item.magic_rarity_level);
		sprint(subject, "\n");
		moon_println_target_own_magic_item_description(subject); // when touching item, its magic is held in same place for both Armor and Ring

		if ( moon_target_player_needs_tutorial(subject) )
		{
			if ( item.classname == MOON_TRADE_MARKET_SPOT_CLASSNAME )
			{
				sprint(subject, "Use `buy` (default: `F`) command to buy it.\n");
			} else {
				sprint(subject, "Use `use` (default: `E`) command to pick it up.\n");
			}
		}

		item.next_mesg_time = time + MOON_TIME_BETWEEN_ITEMTOUCH_ITEM_PRINT;
		subject.next_mesg_time = time + MOON_TIME_BETWEEN_ITEMTOUCH_PLAYER_PRINT;
	}
};

void() moon_magic_item_touch = // self - magic item, other - player
{
	moon_identify_magic_item_by_subject(self, other);
};

void(entity item, entity subject) moon_identify_shop_item_by_subject =
{
	sprint(subject, "======== shop item ========\n");
	if ( item.items & IT_ARMOR1 )
	{
		sprint(subject, MOON_ARMOR_GREEN_DISPLAYNAME);
	}
	if ( item.items & IT_ARMOR2 )
	{
		sprint(subject, MOON_ARMOR_YELLOW_DISPLAYNAME);
	}
	if ( item.items & IT_ARMOR3 )
	{
		sprint(subject, MOON_ARMOR_RED_DISPLAYNAME);
	}
	if ( item.items & IT_SUPERHEALTH )
	{
		sprint(subject, "{0} +{1}", item.targetname, floor_ftos(item.healamount));
	}
	if ( item.cnt == MOON_ITEM_TRADE_SIGNOF_AMMO )
	{
		sprint(subject, "Box of");
		moon_print_target_container_ammo(subject, item);
	} else
	if ( item.cnt == MOON_ITEM_TRADE_SIGNOF_WEAPON )
	{
		sprint(subject, item.targetname);
	}

	sprint(subject, ". Cost: {0}\n", floor_ftos(item.cost));
};

void(entity item, entity subject) moon_identify_market_item_by_subject =
{
	sprint(subject, "======= market item =======\n");
	if ( item.netname == MOON_ARMOR_MARKET_NETNAME )
	{
		sprint(subject, item.targetname);
	} else
	if ( item.netname == MOON_ELIXIR_MARKET_NETNAME )
	{
		sprint(subject, item.targetname);
	} else
	if ( item.netname == MOON_AMMO_MARKET_NETNAME )
	{
		sprint(subject, "{0} {1}", floor_ftos(item.currentammo), item.targetname);
	} else
	if ( item.netname == MOON_WEAPON_MARKET_NETNAME )
	{
		sprint(subject, item.targetname);
	} else
	if ( item.netname == MOON_MEDKIT_MEGA_MARKET_NETNAME )
	{
		sprint(subject, item.targetname);
	} else
	if ( (item.netname == MOON_ITEM_ARMOR_NETNAME) || (item.netname == MOON_ITEM_RING_NETNAME) )
	{
		moon_identify_magic_item_by_subject(subject, other);
	}
	sprint(subject, "\n");

	sprint(subject, "Cost: ");
	moon_print_golden_number(subject, item.cost);
	sprint(subject, "\n");
};

void() moon_identify_items_in_radius =
{
	local entity head;
	local entity selected;
	local float min_dist;

	min_dist = MOON_PHYSIC_ITEMSEARCH_RADIUS;
	head = world;
	while ( (head = find(head, classname, MOON_ITEM_MAGIC_CLASSNAME)) )
	{
		if ( vlen(head.origin - self.origin) < min_dist )
		{
			min_dist = vlen(head.origin - self.origin);
			selected = head;
		}
	}
	if ( selected != world )
	{
		moon_identify_magic_item_by_subject(selected, self);
		return;
	}

	min_dist = MOON_PHYSIC_SHOPITEMSEARCH_RADIUS;
	head = world;
	while ( (head = find(head, classname, MOON_TRADE_SHOP_SPOT_CLASSNAME)) )
	{
		if ( head.free == MOON_TRADE_STATE_OCCUPIED )
		{
			if ( vlen(head.origin - self.origin) < min_dist )
			{
				min_dist = vlen(head.origin - self.origin);
				selected = head;
			}
		}
	}
	if ( selected != world )
	{
		moon_identify_shop_item_by_subject(selected, self);
		return;
	}

	min_dist = MOON_PHYSIC_SHOPITEMSEARCH_RADIUS;
	head = world;
	while ( (head = find(head, classname, MOON_TRADE_MARKET_SPOT_CLASSNAME)) )
	{
		if ( head.free == MOON_TRADE_STATE_OCCUPIED )
		{
			if ( vlen((head.origin - self.origin)) < min_dist )
			{
				min_dist = vlen( head.origin - self.origin );
				selected = head;
			}
		}
	}
	if ( selected != world )
	{
		moon_identify_market_item_by_subject(selected, self);
		return;
	}

	sprint(self, "Nothing to identify.\n");
};

void() moon_print_skills =
{
	local float bonus;

	sprint(self, "======= stats =======\n");
	sprint(self, "|free points: {0}", quick_ftos(self.point));
	if ( self.point < 10 )
	{
		sprint(self, " ");
	}
	sprint(self, "    |\n");

	bonus = moon_get_target_bonus_health(self);
	sprint(self, "| vitality: {0} ({1}", quick_ftos(self.vit), quick_ftos(self.max_health));

	if ( bonus > 0 )
	{
		sprint(self, " (+{0})", quick_ftos(bonus));
	}
	sprint(self, " max hp) |");
	if ( moon_target_player_needs_tutorial(self) && (self.point > 0) )
	{
		sprint(self, " Use `skill\1` to raise");
	}
	sprint(self, "\n");

	bonus = moon_get_target_total_bonus_damage(self);
	if ( self.mentat_offense_time > time )
	{
		bonus = (bonus + MOON_MENTAT_OFFENSE_VALUE);
	}

	sprint(self, "| strength: {0} ({1}%", quick_ftos(self.stre), quick_ftos((self.stre * MOON_STAT_DAMAGE_PER_STRENGTH) + 100));
	if (bonus > 0)
	{
		sprint(self, " (+{0}%)", quick_ftos(bonus));
	}
	sprint(self, " dmg) |");
	if ( moon_target_player_needs_tutorial(self) && (self.point > 0) )
	{
		sprint(self, " Use `skill\2` to raise");
	}
	sprint(self, "\n");

	// TODO: Sanity stat
	// TODO: Intuition stat
	sprint(self, "---------------------\n");
};

void() moon_broadcast_heart_state =
{
	local entity heart;
	heart = moon_gimme_your_heart();
	if ( heart != world )
	{
		bprint("\sHeart\s's life now ");
		moon_println_all_other_health(heart);
	}
};