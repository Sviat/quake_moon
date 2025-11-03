/// ReProjectMoon-specific source file
/// Here go all functions related to Shop, Market and other gold stuff


float(float price) moon_get_inflation_adjusted_cost =
{
	return price + percent(price, up_gold_value);
};

entity() moon_market_place_armor =
{
	local entity e;
	local float r;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = MOON_TRADE_MARKET_ITEM_CLASSNAME;
	e.netname = MOON_ARMOR_MARKET_NETNAME;
	e.noise1 = "items/armor1.wav";
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);

	r = random();
	if ( r < 0.36 )
	{
		moon_init_target_as_armor(e, MOON_ARMOR_GREEN_CODE, (MOON_ARMOR_GREEN_MARKET_DURABILITY_MIN + rint(random() * MOON_ARMOR_GREEN_MARKET_DURABILITY_RANDOM)));
		e.cost = rint( e.armorvalue * MOON_ARMOR_GREEN_MARKET_COSTOFONE );
		e.targetname = MOON_ARMOR_GREEN_MARKET_DISPLAYNAME;
	} else
	if ((r < 0.7))
	{
		moon_init_target_as_armor(e, MOON_ARMOR_YELLOW_CODE, (MOON_ARMOR_YELLOW_MARKET_DURABILITY_MIN + rint(random() * MOON_ARMOR_YELLOW_MARKET_DURABILITY_RANDOM)));
		e.cost = rint( e.armorvalue * MOON_ARMOR_YELLOW_MARKET_COSTOFONE );
		e.targetname = MOON_ARMOR_YELLOW_MARKET_DISPLAYNAME;
	} else {
		moon_init_target_as_armor(e, MOON_ARMOR_RED_CODE, (MOON_ARMOR_RED_MARKET_DURABILITY_MIN + rint(random() * MOON_ARMOR_RED_MARKET_DURABILITY_RANDOM)));
		e.cost = rint( e.armorvalue * MOON_ARMOR_RED_MARKET_COSTOFONE );
		e.targetname = MOON_ARMOR_RED_MARKET_DISPLAYNAME;
	}

	return e;
};

entity() moon_market_place_ammo =
{
	local entity e;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, (((self.origin + (v_forward * 47)) - '0 0 24') + (v_right * KEY_MOVERIGHT)));
	e.solid = SOLID_NOT;
	e.classname = MOON_TRADE_MARKET_ITEM_CLASSNAME;
	e.netname = MOON_AMMO_MARKET_NETNAME;
	e.skin = 0;
	setmodel(e, string_null);
	e.noise1 = "weapons/lock4.wav";
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);

	if ((random() < MOON_AMMO_MARKET_ROCKET_VS_CELL_RATIO))
	{
		moon_init_target_as_ammobox(e, MOON_AMMO_ROCKETS_CODE, ceil( MOON_AMMO_ROCKETS_MARKET_MIN + (random() * MOON_AMMO_ROCKETS_MARKET_RANDOM) ));
		e.cost = ceil(e.currentammo * MOON_AMMO_ROCKETS_MARKET_COSTOFONE);
	} else {
		moon_init_target_as_ammobox(e, MOON_AMMO_CELLS_CODE, ceil( MOON_AMMO_CELLS_MARKET_MIN + (random() * MOON_AMMO_CELLS_MARKET_RANDOM) ));
		e.cost = ceil(e.currentammo * MOON_AMMO_CELLS_MARKET_COSTOFONE);
	}

	return e;
};

entity() moon_market_place_elixir =
{
	local entity e;
	local float code;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = MOON_TRADE_MARKET_ITEM_CLASSNAME;
	e.netname = MOON_ELIXIR_MARKET_NETNAME;
	e.skin = 2; // TODO: extract
	setmodel(e, "progs/potion.mdl");
	e.noise1 = "moon/items/potion.wav";
	e.owner = self;
	code = random_int(MOON_ELIXIR_STR_CODE, MOON_ELIXIR_VIT_CODE);
	switch(code)
	{
		case MOON_ELIXIR_STR_CODE:
			e.targetname = MOON_ELIXIR_STR_NAME;
			e.healtype = MOON_ELIXIR_STR_CODE;
			e.cost = moon_get_inflation_adjusted_cost(MOON_ELIXIR_STR_COST_BASE);
			break;
		case MOON_ELIXIR_VIT_CODE:
			e.targetname = MOON_ELIXIR_VIT_NAME;
			e.healtype = MOON_ELIXIR_VIT_CODE;
			e.cost = moon_get_inflation_adjusted_cost(MOON_ELIXIR_VIT_COST_BASE);
			break;
		case MOON_ELIXIR_MAG_CODE: // TODO: implement
		case MOON_ELIXIR_INT_CODE: // TODO: implement
		default:
			break; // noop
	}
	e.count = 0;	// unused
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);

	return e;
};

entity(entity trader) moon_market_place_magic_item =
{
	local entity e;

	e = spawn();
	makevectors(trader.angles);
	setorigin(e, ((trader.origin + (v_forward * 47)) - '0 0 24'));
	// e.solid = SOLID_NOT;
	e.owner = trader;
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);

	moon_init_target_as_magic_item(e);
	e.classname = MOON_TRADE_MARKET_ITEM_CLASSNAME; // overwrite default from above

	return e;
};

entity() moon_market_place_weapon =
{
	local entity e;
	local float r;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = MOON_TRADE_MARKET_ITEM_CLASSNAME;
	e.noise1 = "weapons/pkup.wav";
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);

	r = random();
	if ( r < 0.16 )
	{
		moon_init_target_as_weapon(e, MOON_WEAPON_SUPERSHOTGUN_CODE, random_int(1, MOON_WEAPON_SUPERSHOTGUN_AMMO_MARKET));
		e.cost = rint( MOON_WEAPON_SUPERSHOTGUN_COST_MARKET + (e.currentammo * MOON_AMMO_SHELLS_COSTOFONE) );
		e.targetname = MOON_WEAPON_SUPERSHOTGUN_MARKET_DISPLAYNAME;
	} else
	if ( r < 0.33 )
	{
		moon_init_target_as_weapon(e, MOON_WEAPON_NAILGUN_CODE, random_int(1, MOON_WEAPON_NAILGUN_AMMO_MARKET));
		e.cost = rint( MOON_WEAPON_NAILGUN_COST_MARKET + (e.currentammo * MOON_AMMO_NAILS_COSTOFONE) );
		e.targetname = MOON_WEAPON_NAILGUN_MARKET_DISPLAYNAME;
	} else
	if ( r < 0.5 )
	{
		moon_init_target_as_weapon(e, MOON_WEAPON_SUPERNAILGUN_CODE, random_int(1, MOON_WEAPON_SUPERNAILGUN_AMMO_MARKET));
		e.cost = rint( MOON_WEAPON_SUPERNAILGUN_COST_MARKET + (e.currentammo * MOON_AMMO_NAILS_COSTOFONE) );
		e.targetname = MOON_WEAPON_SUPERNAILGUN_MARKET_DISPLAYNAME;
	} else
	if ( r < 0.66 )
	{
		moon_init_target_as_weapon(e, MOON_WEAPON_GRENADELAUNCHER_CODE, random_int(1, MOON_WEAPON_GRENADELAUNCHER_AMMO_MARKET));
		e.cost = rint( MOON_WEAPON_GRENADELAUNCHER_COST_MARKET + (e.currentammo * MOON_AMMO_ROCKETS_COSTOFONE) );
		e.targetname = MOON_WEAPON_GRENADELAUNCHER_MARKET_DISPLAYNAME;
	} else
	if ( r < 0.82 )
	{
		moon_init_target_as_weapon(e, MOON_WEAPON_ROCKETLAUNCHER_CODE, random_int(1, MOON_WEAPON_ROCKETLAUNCHER_AMMO_MARKET));
		e.cost = rint( MOON_WEAPON_ROCKETLAUNCHER_COST_MARKET + (e.currentammo * MOON_AMMO_ROCKETS_COSTOFONE) );
		e.targetname = MOON_WEAPON_ROCKETLAUNCHER_MARKET_DISPLAYNAME;
	} else {
		moon_init_target_as_weapon(e, MOON_WEAPON_LIGHTNING_CODE, random_int(1, MOON_WEAPON_LIGHTNING_AMMO_MARKET));
		e.cost = rint( MOON_WEAPON_LIGHTNING_COST_MARKET + (e.currentammo * MOON_AMMO_CELLS_COSTOFONE) );
		e.targetname = MOON_WEAPON_LIGHTNING_MARKET_DISPLAYNAME;
	}

	e.netname = MOON_WEAPON_MARKET_NETNAME; // overwrite value set by moon_init_target_as_weapon

	return e;
};

entity() moon_market_place_medkit_mega = // TODO: use moon_init_target_as_medkit
{
	local entity e;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, (((self.origin + (v_forward * 49)) - '0 0 24') + (v_right * KEY_MOVEFORWARD)));
	e.solid = SOLID_NOT;
	e.angles_y = anglemod((self.angles_y + MENTAT_TIME));
	e.classname = MOON_TRADE_MARKET_ITEM_CLASSNAME;
	e.netname = MOON_MEDKIT_MEGA_MARKET_NETNAME;
	e.targetname = MOON_MEDKIT_MEGA_MARKET_DISPLAYNAME;
	e.noise1 = "items/r_item2.wav";
	e.healamount = rint( MOON_MEDKIT_MEGA_MARKET_MIN + (random() * MOON_MEDKIT_MEGA_MARKET_RANDOM) );
	e.count = e.healamount;
	e.cost = (e.healamount * MOON_MEDKIT_MEGA_MARKET_COSTOFONE);
	e.owner = self;
	e.healtype = MOON_MEDKIT_MEGA_TYPE;
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);
	setmodel(e, MOON_MEDKIT_MEGA_MODEL);

	return e;
};

void(entity trader) moon_market_place_for_sale =
{
	local float r;

	r = random();
	if ( r < 0.2 )
	{
		moon_market_place_magic_item(trader);
	} else
	if ( r < 0.37 )
	{
		moon_market_place_weapon();
	} else
	if ( r < 0.52 )
	{
		moon_market_place_medkit_mega();
	} else
	if ( r < 0.7 )
	{
		moon_market_place_armor();
	} else
	if ( r < 0.83 )
	{
		moon_market_place_elixir();
	} else {
		moon_market_place_ammo();
	}
};

void() moon_buy_item_market =
{
	local entity head;
	local entity selected;
	local float min_dist;
	local float best;

	min_dist = MOON_PHYSIC_ITEMSEARCH_RADIUS;
	while ( (head = find(head, classname, MOON_TRADE_MARKET_ITEM_CLASSNAME)) )
	{
		if ((head.free == MOON_TRADE_STATE_OCCUPIED))
		{
			if ((vlen((head.origin - self.origin)) < min_dist))
			{
				min_dist = vlen((head.origin - self.origin));
				selected = head;
			}
		}
	}
	if ( selected == world ) { return; }

	if ( self.gold < selected.cost )
	{
		sprint(self, "not enough gold\n");
		sound(self, CHAN_ITEM, "misc/medkey.wav", 1, ATTN_NORM);
		return;
	}

	switch (selected.netname)
	{
		case MOON_ARMOR_MARKET_NETNAME:
			if ( (self.armortype * self.armorvalue) >= (selected.armortype * selected.armorvalue) )
			{
				sprint(self, "You \sdon't\s need it\n");
				return;
			}
			self.armortype = selected.armortype;
			self.armorvalue = selected.armorvalue;
			self.items = (((self.items & (~IT_ARMOR1)) & (~IT_ARMOR2)) & (~IT_ARMOR3)) | selected.items;

			sprint(self, "You bought {}\n", selected.targetname);
			sound(self, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
			break;
		case MOON_MEDKIT_MEGA_MARKET_NETNAME:
			if ( self.health >= (self.max_health + MOON_MEDKIT_MEGA_OVERHEAL_SOFTLIMIT) )
			{
				sprint(self, "you \sdon't\s need it\n");
				return;
			}
			if ( self.health >= CONST_QC_DISPLAY_MAX )
			{
				sprint(self, "you \sdon't\s need it\n");
				return;
			}

			if ( selected.healtype == MOON_MEDKIT_MEGA_TYPE )
			{
				moon_overheal_target_player(self, selected.healamount);
			} else {
				moon_heal_target_player(self, selected.healamount);
			}

			sprint(self, "You bought {0}\n", MOON_MEDKIT_MEGA_MARKET_DISPLAYNAME);
			sound(self, CHAN_ITEM, selected.noise1, 1, ATTN_NORM);
			break;
		case MOON_ELIXIR_MARKET_NETNAME:
			if ((selected.healtype == MOON_ELIXIR_VIT_CODE))
			{
				moon_raise_target_vitality(self, MOON_ELIXIR_VIT_VALUE);
			}
			if ((selected.healtype == MOON_ELIXIR_STR_CODE))
			{
				moon_raise_target_strength(self, MOON_ELIXIR_STR_VALUE);
			}
			sprint(self, "You bought {}\n", selected.targetname);
			sound(self, CHAN_ITEM, selected.noise1, 1, ATTN_NORM);
			break;
		case MOON_AMMO_MARKET_NETNAME:
			best = moon_get_target_best_weapon(self, TRUE); // Remember best weapon before buying ammo

			moon_target_consume_ammo_from(self, selected);

			if ( self.weapon == best ) // if had best weapon without ammo before, but have ammo now, change current to best as well
			{
				moon_swap_target_to_best_weapon(self, TRUE);
			} else {
				moon_set_target_currentammo(self);
			}

			sprint(self, "You bought");
			moon_print_target_container_ammo(self, selected);
			sprint(self, "\n");
			sound(self, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
			break;
		case MOON_WEAPON_MARKET_NETNAME:
			best = moon_get_target_best_weapon(self, TRUE); // Remember best weapon before buying ammo

			moon_target_consume_ammo_from(self, selected);

			self.items = (self.items | selected.items);

			if ( self.weapon == best ) // if had best weapon and bought better, change current to the best as well
			{
				moon_swap_target_to_best_weapon(self, TRUE);
			} else {
				moon_set_target_currentammo(self);
			}

			sprint(self, "You bought {0}\n", selected.targetname);
			sound(self, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
			break;
		case MOON_ITEM_ARMOR_NETNAME:
		case MOON_ITEM_RING_NETNAME:
			moon_target_wear_magic_item(self, selected);
			break;
	}

	if ( moon_pay_target_gold(self, selected.cost) == FALSE ) { return; }
	flash_self();

	selected.targetname = string_null;
	selected.owner.attack_finished = 0;
	selected.owner.stuck_time = 0;
	selected.owner.rstuck_time = 0;
	selected.owner.rstuck_org = selected.owner.origin;
	setmodel(selected, string_null);
	remove(selected);
};

void() moon_buy_item =
{
	local entity head;
	local entity selected;
	local float min_dist;
	local float best;
	local float tempf;

	min_dist = 150;
	while ( (head = find(head, classname, MOON_TRADE_SHOP_SPOT_CLASSNAME)) )
	{
		if ( head.free == MOON_TRADE_STATE_OCCUPIED )
		{
			if ((vlen((head.origin - self.origin)) < min_dist))
			{
				min_dist = vlen((head.origin - self.origin));
				selected = head;
			}
		}
	}
	if ( selected == world )	// If no trade stands found in shop, check black market
	{
		moon_buy_item_market();
		return;
	}

	if ( self.gold < selected.cost )
	{
		sprint(self, "not enough gold\n");
		sound(self, CHAN_ITEM, "misc/medkey.wav", 1, ATTN_NORM);
		return;
	}

	if ( selected.armortype > 0 )	// Sign of Armor
	{
		if ( (self.armortype * self.armorvalue) >= (selected.armortype * selected.armorvalue) )
		{
			sprint(self, "you \sdon't\s need it\n");
			return;
		}
		self.armortype = selected.armortype;
		self.armorvalue = selected.armorvalue;
		self.items = (((self.items & (~IT_ARMOR1)) & (~IT_ARMOR2)) & (~IT_ARMOR3)) | selected.items;

		sprint(self, "You bought shiny new {}\n", selected.targetname);
		sound(self, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
		selected.attack_finished = (time + MOON_TRADE_SPOT_ARMOR_DELAY_MIN + (random() * MOON_TRADE_SPOT_ARMOR_DELAY_RANDOM));
	} else
	if ( selected.items & IT_SUPERHEALTH ) // Sign of Medkit
	{
		if ( selected.healtype == MOON_MEDKIT_MEGA_TYPE )
		{
			if ( self.health >= (self.max_health + MOON_MEDKIT_MEGA_OVERHEAL_SOFTLIMIT) )
			{
				sprint(self, "you \sdon't\s need it\n");
				return;
			}

			moon_overheal_target_player(self, selected.healamount);
		} else {
			if ( self.health >= self.max_health )
			{
				sprint(self, "you \sdon't\s need it\n");
				return;
			}

			moon_heal_target_player(self, selected.healamount);
		}
		sprint(self, "You bought {0} and healed {1}HP\n", selected.targetname, floor_ftos(selected.healamount));
		sound(self, CHAN_ITEM, selected.noise, 1, ATTN_NORM);
		selected.attack_finished = (time + MOON_TRADE_SPOT_HEALTH_DELAY_MIN + (random() * MOON_TRADE_SPOT_HEALTH_DELAY_RANDOM));
	} else
	if ( selected.cnt == MOON_ITEM_TRADE_SIGNOF_AMMO ) // Sign of Ammo
	{
		best = moon_get_target_best_weapon(self, TRUE); // Remember best weapon before buying ammo

		moon_target_consume_ammo_from(self, selected);

		sprint(self, "You bought {0} {1}\n", floor_ftos(selected.currentammo), selected.targetname);
		sound(self, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
		tempf = MOON_TRADE_SPOT_AMMO_DELAY_MIN / clampd(1, moon_get_current_player_count(), 4);
		selected.attack_finished = (time + tempf + (random() * MOON_TRADE_SPOT_AMMO_DELAY_RANDOM)); // Ammo respawn at shop faster the more players in game

		if ( self.weapon == best ) // if had best weapon without ammo before, but have ammo now, change current to best as well
		{
			moon_swap_target_to_best_weapon(self, TRUE);
		} else {
			moon_set_target_currentammo(self); // otherwise, at least update ammo count
		}

		selected.items = 0;
		selected.ammo_cells = 0;
		selected.ammo_rockets = 0;
		selected.ammo_nails = 0;
		selected.ammo_shells = 0;
		selected.currentammo = 0;
	} else
	if ( selected.cnt == MOON_ITEM_TRADE_SIGNOF_WEAPON ) // Sign of Weapon
	{
		best = moon_get_target_best_weapon(self, TRUE); // Remember best weapon before buying weapon with ammo

		moon_target_consume_ammo_from(self, selected);

		self.items = (self.items | selected.items);

		sprint(self, "You bought {0}\n", selected.targetname);
		sound(self, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
		selected.attack_finished = (time + MOON_TRADE_SPOT_WEAPON_DELAY_MIN + (random() * MOON_TRADE_SPOT_WEAPON_DELAY_RANDOM));

		if ( self.weapon == best ) // if had best weapon before, and bought better, change current to best as well
		{
			moon_swap_target_to_best_weapon(self, TRUE);
		} else {
			moon_set_target_currentammo(self); // otherwise, at least update ammo count
		}

		selected.items = 0;
		selected.currentammo = 0;
		selected.ammo_cells = 0;
		selected.ammo_rockets = 0;
		selected.ammo_nails = 0;
		selected.ammo_shells = 0;
	}

	moon_pay_target_gold(self, selected.cost); // already checked above
	flash_self();

	setmodel(selected, string_null);
	selected.targetname = string_null;
	selected.free = MOON_TRADE_STATE_FREE;
};
