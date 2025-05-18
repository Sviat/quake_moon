/// ReProjectMoon-specific source file
/// Here go all functions related to item entity initialization, loot drop etc


void(entity target, float armor_code, float armor_durability = -1) moon_init_target_as_armor =
{
	setmodel(target, "progs/armor.mdl");
	target.health = armor_durability;

	switch(armor_code)
	{
	case MOON_ARMOR_GREEN_CODE:
		target.items = IT_ARMOR1;
		target.skin = MOON_ARMOR_GREEN_SKIN;
		target.max_health = MOON_ARMOR_GREEN_DURABILITY;
		target.armortype = MOON_ARMOR_GREEN_RESISTANCE;
		target.cost = MOON_ARMOR_GREEN_SHOP_COST;
		target.targetname = MOON_ARMOR_GREEN_DISPLAYNAME;
		break;
	case MOON_ARMOR_YELLOW_CODE:
		target.items = IT_ARMOR2;
		target.skin = MOON_ARMOR_YELLOW_SKIN;
		target.max_health = MOON_ARMOR_YELLOW_DURABILITY;
		target.armortype = MOON_ARMOR_YELLOW_RESISTANCE;
		target.cost = MOON_ARMOR_YELLOW_SHOP_COST;
		target.targetname = MOON_ARMOR_YELLOW_DISPLAYNAME;
		break;
	case MOON_ARMOR_RED_CODE:
		target.items = IT_ARMOR3;
		target.skin = MOON_ARMOR_RED_SKIN;
		target.max_health = MOON_ARMOR_RED_DURABILITY;
		target.armortype = MOON_ARMOR_RED_RESISTANCE;
		target.cost = MOON_ARMOR_RED_SHOP_COST;
		target.targetname = MOON_ARMOR_RED_DISPLAYNAME;
		break;
	default:
		target.max_health = 1; // Division by zero guard
		dprint("Unknown armor code {0}\n", armor_code);
	}

	// Adjust cost for damaged Armors
	target.armorvalue = ( (target.health > 0) ? target.health : target.max_health);
	target.count = target.armorvalue; // duplicate for easier crosshair identification
	target.cost = (target.cost * (target.armorvalue / target.max_health));
};

void(entity target, float weapon_code, float ammo_count = -1) moon_init_target_as_weapon =
{
	switch(weapon_code)
	{
	case MOON_WEAPON_AXE_CODE: // never happens
	case MOON_WEAPON_SHOTGUN_CODE: // never happens
		target.currentammo = 0;
		break; // noop
	case MOON_WEAPON_SUPERSHOTGUN_CODE:
		setmodel(target, MOON_WEAPON_SUPERSHOTGUN_MODEL_TPV);
		if ( ammo_count > 0 )
		{
			target.ammo_shells = ammo_count;
		} else {
			target.ammo_shells = MOON_WEAPON_SUPERSHOTGUN_AMMO_SHOP;
		}
		target.currentammo = target.ammo_shells;
		target.cost = MOON_WEAPON_SUPERSHOTGUN_COST_SHOP;
		target.targetname = MOON_WEAPON_SUPERSHOTGUN_DISPLAYNAME; // for the Market&Shop
		target.netname = MOON_WEAPON_SUPERSHOTGUN_DISPLAYNAME; // for the Loot drop
		target.items = IT_SUPER_SHOTGUN;
		break;
	case MOON_WEAPON_NAILGUN_CODE:
		setmodel(target, MOON_WEAPON_NAILGUN_MODEL_TPV);
		if ( ammo_count > 0 )
		{
			target.ammo_nails = ammo_count;
		} else {
			target.ammo_nails = MOON_WEAPON_NAILGUN_AMMO_SHOP;
		}
		target.currentammo = target.ammo_nails;
		target.cost = MOON_WEAPON_NAILGUN_COST_SHOP;
		target.targetname = MOON_WEAPON_NAILGUN_DISPLAYNAME;
		target.netname = MOON_WEAPON_NAILGUN_DISPLAYNAME;
		target.items = IT_NAILGUN;
		break;
	case MOON_WEAPON_SUPERNAILGUN_CODE:
		setmodel(target, MOON_WEAPON_SUPERNAILGUN_MODEL_TPV);
		if ( ammo_count > 0 )
		{
			target.ammo_nails = ammo_count;
		} else {
			target.ammo_nails = MOON_WEAPON_SUPERNAILGUN_AMMO_SHOP;
		}
		target.currentammo = target.ammo_nails;
		target.cost = MOON_WEAPON_SUPERNAILGUN_COST_SHOP;
		target.targetname = MOON_WEAPON_SUPERNAILGUN_DISPLAYNAME;
		target.netname = MOON_WEAPON_SUPERNAILGUN_DISPLAYNAME;
		target.items = IT_SUPER_NAILGUN;
		break;
	case MOON_WEAPON_GRENADELAUNCHER_CODE:
		setmodel(target, MOON_WEAPON_GRENADELAUNCHER_MODEL_TPV);
		if ( ammo_count > 0 )
		{
			target.ammo_rockets = ammo_count;
		} else {
			target.ammo_rockets = MOON_WEAPON_GRENADELAUNCHER_AMMO_SHOP;
		}
		target.currentammo = target.ammo_rockets;
		target.cost = MOON_WEAPON_GRENADELAUNCHER_COST_SHOP;
		target.targetname = MOON_WEAPON_GRENADELAUNCHER_DISPLAYNAME;
		target.netname = MOON_WEAPON_GRENADELAUNCHER_DISPLAYNAME;
		target.items = IT_GRENADE_LAUNCHER;
		break;
	case MOON_WEAPON_ROCKETLAUNCHER_CODE:
		setmodel(target, MOON_WEAPON_ROCKETLAUNCHER_MODEL_TPV);
		if ( ammo_count > 0 )
		{
			target.ammo_rockets = ammo_count;
		} else {
			target.ammo_rockets = MOON_WEAPON_ROCKETLAUNCHER_AMMO_SHOP;
		}
		target.currentammo = target.ammo_rockets;
		target.cost = MOON_WEAPON_ROCKETLAUNCHER_COST_SHOP;
		target.targetname = MOON_WEAPON_ROCKETLAUNCHER_DISPLAYNAME;
		target.netname = MOON_WEAPON_ROCKETLAUNCHER_DISPLAYNAME;
		target.items = IT_ROCKET_LAUNCHER;
		break;
	case MOON_WEAPON_LIGHTNING_CODE:
		setmodel(target, MOON_WEAPON_LIGHTNING_MODEL_TPV);
		if ( ammo_count > 0 )
		{
			target.ammo_cells = ammo_count;
		} else {
			target.ammo_cells = MOON_WEAPON_LIGHTNING_AMMO_SHOP;
		}
		target.currentammo = target.ammo_cells;
		target.cost = MOON_WEAPON_LIGHTNING_COST_SHOP;
		target.targetname = MOON_WEAPON_LIGHTNING_DISPLAYNAME;
		target.netname = MOON_WEAPON_LIGHTNING_DISPLAYNAME;
		target.items = IT_LIGHTNING;
		break;
	default:
		dprint("Unknown weapon code {0}\n", weapon_code);
	}

	target.count = target.currentammo; // duplicate for easier crosshair identification
};

void(entity target, float medkit_code, float medkit_durability = -1) moon_init_target_as_medkit =
{
	target.health = medkit_durability;
	target.items = IT_SUPERHEALTH;

	switch(medkit_code)
	{
	case MOON_MEDKIT_SMALL_TYPE:
		setmodel(target, "maps/b_bh10.bsp");
		target.noise = "items/r_item1.wav";
		target.healtype = MOON_MEDKIT_SMALL_TYPE;
		target.max_health = MOON_MEDKIT_SMALL_VALUE;
		target.cost = MOON_MEDKIT_SMALL_COST;
		target.targetname = MOON_MEDKIT_SMALL_DISPLAYNAME;
		break;
	case MOON_MEDKIT_NORMAL_TYPE:
		setmodel(target, "maps/b_bh25.bsp");
		target.noise = "items/health1.wav";
		target.healtype = MOON_MEDKIT_NORMAL_TYPE;
		target.max_health = MOON_MEDKIT_NORMAL_VALUE;
		target.cost = MOON_MEDKIT_NORMAL_COST;
		target.targetname = MOON_MEDKIT_NORMAL_DISPLAYNAME;
		break;
	case MOON_MEDKIT_MEGA_TYPE:
		setmodel(target, "maps/b_bh100.bsp");
		target.noise = "items/r_item2.wav";
		target.healtype = MOON_MEDKIT_MEGA_TYPE;
		target.max_health = MOON_MEDKIT_MEGA_VALUE;
		target.cost = MOON_MEDKIT_MEGA_COST;
		target.targetname = MOON_MEDKIT_MEGA_DISPLAYNAME;
		break;
	default:
		target.max_health = 1; // Division by zero guard
		dprint("Unknown medkit code {0}\n", medkit_code);
	}

	// Adjust cost for spoiled medkits
	target.healamount = ( (target.health > 0) ? target.health : target.max_health);
	target.count = target.healamount; // duplicate for easier crosshair identification
	target.cost = (target.cost * (target.healamount / target.max_health));
};

void(entity target, float ammo_code, float ammo_count = -1) moon_init_target_as_ammobox =
{
	target.items = ammo_code;
	target.cnt = MOON_ITEM_TRADE_SIGNOF_AMMO; // sadly still used in some Shop&Market code

	switch(ammo_code)
	{
	case MOON_AMMO_SHELLS_CODE: //==IT_SHELLS:
		setmodel(target, MOON_AMMO_SHELLS_MODEL);
		if ( ammo_count > 0 )
		{
			target.ammo_shells = ammo_count;
		} else {
			target.ammo_shells = ceil(MOON_AMMO_SHELLS_BASE + (random() * MOON_AMMO_SHELLS_RANDOM));
		}
		target.currentammo = target.ammo_shells;
		target.cost = ceil(target.ammo_shells * MOON_AMMO_SHELLS_COSTOFONE);
		target.targetname = MOON_AMMO_SHELLS_DISPLAYNAME;
		break;
	case MOON_AMMO_NAILS_CODE: //==IT_NAILS:
		setmodel(target, MOON_AMMO_NAILS_MODEL);
		if ( ammo_count > 0 )
		{
			target.ammo_nails = ammo_count;
		} else {
			target.ammo_nails = ceil(MOON_AMMO_NAILS_BASE + (random() * MOON_AMMO_NAILS_RANDOM));
		}
		target.currentammo = target.ammo_nails;
		target.cost = ceil(target.ammo_nails * MOON_AMMO_NAILS_COSTOFONE);
		target.targetname = MOON_AMMO_NAILS_DISPLAYNAME;
		break;
	case MOON_AMMO_ROCKETS_CODE: //==IT_ROCKETS:
		setmodel(target, MOON_AMMO_ROCKETS_MODEL);
		if ( ammo_count > 0 )
		{
			target.ammo_rockets = ammo_count;
		} else {
			target.ammo_rockets = ceil(MOON_AMMO_ROCKETS_BASE + (random() * MOON_AMMO_ROCKETS_RANDOM));
		}
		target.currentammo = target.ammo_rockets;
		target.cost = ceil(target.ammo_rockets * MOON_AMMO_ROCKETS_COSTOFONE);
		target.targetname = MOON_AMMO_ROCKETS_DISPLAYNAME;
		break;
	case MOON_AMMO_CELLS_CODE: //==IT_CELLS:
		setmodel(target, MOON_AMMO_CELLS_MODEL);
		if ( ammo_count > 0 )
		{
			target.ammo_cells = ammo_count;
		} else {
			target.ammo_cells = ceil(MOON_AMMO_CELLS_BASE + (random() * MOON_AMMO_CELLS_RANDOM));
		}
		target.currentammo = target.ammo_cells;
		target.cost = ceil(target.ammo_cells * MOON_AMMO_CELLS_COSTOFONE);
		target.targetname = MOON_AMMO_CELLS_DISPLAYNAME;
		break;
	default:
		dprint("Unknown ammunition code {0}\n", ammo_code);
	}

	target.count = target.currentammo; // duplicate for easier crosshair identification
};

float(float level) moon_generate_trait_effect_code =
{
	if ( level < MOON_ITEM_TRAIT_CODE_THRESHOLD_LOW )
	{
		return random_int(MOON_ITEM_TRAIT_MIN_EFFECT, MOON_ITEM_TRAIT_CODE_LOW_HIGHEST);
	} else
	if ( level > MOON_ITEM_TRAIT_CODE_THRESHOLD_HIGH )
	{
		return random_int(MOON_ITEM_TRAIT_CODE_HIGH_LOWEST, MOON_ITEM_TRAIT_MAX_EFFECT);
	} else {
		return random_int(MOON_ITEM_TRAIT_MIN_EFFECT, MOON_ITEM_TRAIT_MAX_EFFECT);
	}
};

float(float level) moon_generate_trait_quality =
{
	local float shift;
	local float width;

	shift = clampd(0, level * 2 - MOON_ITEM_TRAIT_THRESHOLD_PREFIX_NORMAL, MOON_ITEM_TRAIT_THRESHOLD_PREFIX_NORMAL);
	width = 0;
	if ( level <= MOON_ITEM_TRAIT_LVLTHRESHOLD_LOWANDNORMAL )
	{
		width = MOON_ITEM_TRAIT_THRESHOLD_PREFIX_NORMAL;
	} else
	if ( level <= MOON_ITEM_TRAIT_LVLTHRESHOLD_NOEPIC )
	{
		width = MOON_ITEM_TRAIT_THRESHOLD_PREFIX_HIGH;
	} else
	if ( level <= MOON_ITEM_TRAIT_LVLTHRESHOLD_ALL )
	{
		width = MOON_ITEM_TRAIT_THRESHOLD_PREFIX_HIGH + level;
	} else
	if ( level <= MOON_ITEM_TRAIT_LVLTHRESHOLD_NOLOW )
	{
		width = MOON_ITEM_TRAIT_THRESHOLD_PREFIX_HIGH + level;
	} else { // MOON_ITEM_TRAIT_LVLTHRESHOLD_HIGHANDEPIC
		width = 50 + (level - MOON_ITEM_TRAIT_LVLTHRESHOLD_NOLOW);
	}

	return shift + rint(random() * width);
};

float(float total_quality) moon_generate_trait_prefix_rarity =
{
	if ( total_quality <= MOON_ITEM_TRAIT_THRESHOLD_PREFIX_LOW )
	{
		return MOON_ITEM_RARITY_LOW;
	} else
	if ( total_quality <= MOON_ITEM_TRAIT_THRESHOLD_PREFIX_NORMAL )
	{
		return MOON_ITEM_RARITY_NORMAL;
	} else
	if ( (total_quality + badluck_compensation) <= MOON_ITEM_TRAIT_THRESHOLD_PREFIX_HIGH )
	{
		return MOON_ITEM_RARITY_HIGH;
	} else {
		return MOON_ITEM_RARITY_EPIC;
	}
};

float(float total_quality) moon_generate_trait_postfix_rarity =
{
	if ( total_quality <= MOON_ITEM_TRAIT_THRESHOLD_POSTFIX_LOW )
	{
		return MOON_ITEM_RARITY_LOW;
	} else
	if ( total_quality <= MOON_ITEM_TRAIT_THRESHOLD_POSTFIX_NORMAL )
	{
		return MOON_ITEM_RARITY_NORMAL;
	} else
	if ( total_quality <= MOON_ITEM_TRAIT_THRESHOLD_POSTFIX_HIGH )
	{
		return MOON_ITEM_RARITY_HIGH;
	} else {
		return MOON_ITEM_RARITY_EPIC;
	}
};

void(entity e) moon_generate_magic_prefix =
{
	local float mxx;
	local float effect;
	local float rarity;

	mxx = moon_get_max_player_level();
	effect = moon_generate_trait_effect_code(mxx);
	e.magic_typeone = effect;

	e.lvl = moon_generate_trait_quality(mxx);
	rarity = moon_generate_trait_prefix_rarity(e.lvl);
	e.magic_rarity_level = e.magic_rarity_level + rarity;
	switch(effect)
	{
	case MOON_ITEM_HEALTH_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_HEALTH_PREFIX_LOW_FROM, MOON_ITEM_HEALTH_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_HEALTH_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_HEALTH_PREFIX_NORMAL_FROM, MOON_ITEM_HEALTH_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_HEALTH_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_HEALTH_PREFIX_HIGH_FROM, MOON_ITEM_HEALTH_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_HEALTH_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_HEALTH_PREFIX_EPIC_FROM, MOON_ITEM_HEALTH_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_HEALTH_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_DAMAGE_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_DAMAGE_PREFIX_LOW_FROM, MOON_ITEM_DAMAGE_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_DAMAGE_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_DAMAGE_PREFIX_NORMAL_FROM, MOON_ITEM_DAMAGE_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_DAMAGE_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_DAMAGE_PREFIX_HIGH_FROM, MOON_ITEM_DAMAGE_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_DAMAGE_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_DAMAGE_PREFIX_EPIC_FROM, MOON_ITEM_DAMAGE_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_DAMAGE_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_GOLD_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_GOLD_PREFIX_LOW_FROM, MOON_ITEM_GOLD_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_GOLD_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_GOLD_PREFIX_NORMAL_FROM, MOON_ITEM_GOLD_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_GOLD_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_GOLD_PREFIX_HIGH_FROM, MOON_ITEM_GOLD_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_GOLD_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_GOLD_PREFIX_EPIC_FROM, MOON_ITEM_GOLD_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_GOLD_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_RESIST_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_RESIST_PREFIX_LOW_FROM, MOON_ITEM_RESIST_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_RESIST_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_RESIST_PREFIX_NORMAL_FROM, MOON_ITEM_RESIST_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_RESIST_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_RESIST_PREFIX_HIGH_FROM, MOON_ITEM_RESIST_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_RESIST_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_RESIST_PREFIX_EPIC_FROM, MOON_ITEM_RESIST_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_RESIST_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_RETALATE_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_RETALATE_PREFIX_LOW_FROM, MOON_ITEM_RETALATE_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_RETALATE_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_RETALATE_PREFIX_NORMAL_FROM, MOON_ITEM_RETALATE_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_RETALATE_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_RETALATE_PREFIX_HIGH_FROM, MOON_ITEM_RETALATE_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_RETALATE_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_RETALATE_PREFIX_EPIC_FROM, MOON_ITEM_RETALATE_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_RETALATE_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_VAMPIR_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_VAMPIR_PREFIX_LOW_FROM, MOON_ITEM_VAMPIR_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_VAMPIR_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_VAMPIR_PREFIX_NORMAL_FROM, MOON_ITEM_VAMPIR_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_VAMPIR_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_VAMPIR_PREFIX_HIGH_FROM, MOON_ITEM_VAMPIR_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_VAMPIR_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_VAMPIR_PREFIX_EPIC_FROM, MOON_ITEM_VAMPIR_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_VAMPIR_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_REGEN_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_REGEN_PREFIX_LOW_FROM, MOON_ITEM_REGEN_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_REGEN_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_REGEN_PREFIX_NORMAL_FROM, MOON_ITEM_REGEN_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_REGEN_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_REGEN_PREFIX_HIGH_FROM, MOON_ITEM_REGEN_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_REGEN_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_REGEN_PREFIX_EPIC_FROM, MOON_ITEM_REGEN_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_REGEN_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_CONSUME_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_CONSUME_PREFIX_LOW_FROM, MOON_ITEM_CONSUME_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_CONSUME_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_CONSUME_PREFIX_NORMAL_FROM, MOON_ITEM_CONSUME_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_CONSUME_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_CONSUME_PREFIX_HIGH_FROM, MOON_ITEM_CONSUME_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_CONSUME_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_CONSUME_PREFIX_EPIC_FROM, MOON_ITEM_CONSUME_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_CONSUME_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_REPAIR_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_REPAIR_PREFIX_LOW_FROM, MOON_ITEM_REPAIR_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_REPAIR_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_REPAIR_PREFIX_NORMAL_FROM, MOON_ITEM_REPAIR_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_REPAIR_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_REPAIR_PREFIX_HIGH_FROM, MOON_ITEM_REPAIR_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_REPAIR_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_REPAIR_PREFIX_EPIC_FROM, MOON_ITEM_REPAIR_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_REPAIR_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_RECHARGE_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_RECHARGE_PREFIX_LOW_FROM, MOON_ITEM_RECHARGE_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_RECHARGE_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_RECHARGE_PREFIX_NORMAL_FROM, MOON_ITEM_RECHARGE_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_REPAIR_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_RECHARGE_PREFIX_HIGH_FROM, MOON_ITEM_RECHARGE_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_REPAIR_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_RECHARGE_PREFIX_EPIC_FROM, MOON_ITEM_RECHARGE_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_RECHARGE_PREFIX_EPIC;
			break;
		}
		break;
	default:
		e.magic_typeone = MOON_ITEM_NONE;
		bprint("moon_generate_magic_prefix cannot handle code {0}\n", quick_ftos(effect));
	}

	// Just adding Rarity levels works correctly, except for one case, when item has both prefix and postfix of same LOW level trait (which effectively makes it COMMON from TRASH)
	if ( (e.magic_typeone >= MOON_ITEM_SOME) && (e.magic_typetwo >= MOON_ITEM_SOME) && (e.magic_rarity_level == MOON_ITEM_RARITY_THRESHOLD_TRASH) )
	{
		e.magic_rarity_level = MOON_ITEM_RARITY_THRESHOLD_COMMON;
	}
};

void(entity e) moon_generate_magic_postfix =
{
	local float mxx;
	local float effect;
	local float rarity;

	mxx = moon_get_max_player_level();
	effect = moon_generate_trait_effect_code(mxx);
	e.magic_typetwo = effect;

	e.lvl = moon_generate_trait_quality(mxx);
	rarity = moon_generate_trait_postfix_rarity(e.lvl);

	if ( rarity == MOON_ITEM_RARITY_EPIC ) // Postfix rolled to EPIC -> chance for Unique item
	{
		if ( e.magic_rarity_level == MOON_ITEM_RARITY_EPIC ) // Postifx always generated after Prefix, so this field hold rarity of Prefix by now
		{
			badluck_compensation = 0; // Reset bonus, and wait for next chance
		} else {
			rarity = MOON_ITEM_RARITY_HIGH; // lower quality,
			badluck_compensation = badluck_compensation + MOON_ITEM_TRAIT_BADLUCKCOMPENSATION_BONUS; // but award compensation
		}
	}

	e.magic_rarity_level = e.magic_rarity_level + rarity;
	switch(effect)
	{
	case MOON_ITEM_HEALTH_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_HEALTH_POSTFIX_LOW_FROM, MOON_ITEM_HEALTH_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_HEALTH_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_HEALTH_POSTFIX_NORMAL_FROM, MOON_ITEM_HEALTH_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_HEALTH_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_HEALTH_POSTFIX_HIGH_FROM, MOON_ITEM_HEALTH_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_HEALTH_POSTFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_DAMAGE_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_DAMAGE_POSTFIX_LOW_FROM, MOON_ITEM_DAMAGE_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_DAMAGE_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_DAMAGE_POSTFIX_NORMAL_FROM, MOON_ITEM_DAMAGE_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_DAMAGE_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_DAMAGE_POSTFIX_HIGH_FROM, MOON_ITEM_DAMAGE_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_DAMAGE_POSTFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_GOLD_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_GOLD_POSTFIX_LOW_FROM, MOON_ITEM_GOLD_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_GOLD_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_GOLD_POSTFIX_NORMAL_FROM, MOON_ITEM_GOLD_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_GOLD_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_GOLD_POSTFIX_HIGH_FROM, MOON_ITEM_GOLD_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_GOLD_POSTFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_RESIST_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_RESIST_POSTFIX_LOW_FROM, MOON_ITEM_RESIST_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_RESIST_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_RESIST_POSTFIX_NORMAL_FROM, MOON_ITEM_RESIST_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_RESIST_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_RESIST_POSTFIX_HIGH_FROM, MOON_ITEM_RESIST_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_RESIST_POSTFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_RETALATE_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_RETALATE_POSTFIX_LOW_FROM, MOON_ITEM_RETALATE_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_RETALATE_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_RETALATE_POSTFIX_NORMAL_FROM, MOON_ITEM_RETALATE_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_RETALATE_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_RETALATE_POSTFIX_HIGH_FROM, MOON_ITEM_RETALATE_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_RETALATE_POSTFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_VAMPIR_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_VAMPIR_POSTFIX_LOW_FROM, MOON_ITEM_VAMPIR_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_VAMPIR_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_VAMPIR_POSTFIX_NORMAL_FROM, MOON_ITEM_VAMPIR_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_VAMPIR_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_VAMPIR_POSTFIX_HIGH_FROM, MOON_ITEM_VAMPIR_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_VAMPIR_POSTFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_REGEN_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_REGEN_POSTFIX_LOW_FROM, MOON_ITEM_REGEN_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_REGEN_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_REGEN_POSTFIX_NORMAL_FROM, MOON_ITEM_REGEN_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_REGEN_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_REGEN_POSTFIX_HIGH_FROM, MOON_ITEM_REGEN_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_REGEN_POSTFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_CONSUME_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_CONSUME_POSTFIX_LOW_FROM, MOON_ITEM_CONSUME_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_CONSUME_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_CONSUME_POSTFIX_NORMAL_FROM, MOON_ITEM_CONSUME_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_CONSUME_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_CONSUME_POSTFIX_HIGH_FROM, MOON_ITEM_CONSUME_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_CONSUME_POSTFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_REPAIR_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_REPAIR_POSTFIX_LOW_FROM, MOON_ITEM_REPAIR_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_REPAIR_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_REPAIR_POSTFIX_NORMAL_FROM, MOON_ITEM_REPAIR_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_REPAIR_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_REPAIR_POSTFIX_HIGH_FROM, MOON_ITEM_REPAIR_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_REPAIR_POSTFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_RECHARGE_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_RECHARGE_POSTFIX_LOW_FROM, MOON_ITEM_RECHARGE_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_RECHARGE_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_RECHARGE_POSTFIX_NORMAL_FROM, MOON_ITEM_RECHARGE_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_RECHARGE_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_RECHARGE_POSTFIX_HIGH_FROM, MOON_ITEM_RECHARGE_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_RECHARGE_POSTFIX_HIGH;
			break;
		}
		break;
	default:
		e.magic_typetwo = MOON_ITEM_NONE;
		bprint("moon_generate_magic_postfix cannot handle code {0}\n", quick_ftos(effect));
	}

	// Just adding Rarity levels works correctly, except for one case, when item has both prefix and postfix of same LOW level trait (which effectively makes it COMMON from TRASH)
	if ( (e.magic_typeone >= MOON_ITEM_SOME) && (e.magic_typetwo >= MOON_ITEM_SOME) && (e.magic_rarity_level == MOON_ITEM_RARITY_THRESHOLD_TRASH) )
	{
		e.magic_rarity_level = MOON_ITEM_RARITY_THRESHOLD_COMMON;
	}
};

void(entity e) moon_handle_magic_unique =
{
	if ( e.magic_rarity_level != MOON_ITEM_RARITY_THRESHOLD_UNIQUE )
	{
		return;
	}
	// roll which of Uniques
	// block that Unique from generating ever again
	// change Prefix and Postfix strings
	// change Prefix and Postfix values to maximum
	// handling of additional effects should be done on demand
	//  where it is required (i.e in damage function or heal function)
};

float(float effect_code, float effect_value) moon_calculate_effect_cost =
{
	switch(effect_code)
	{
		case MOON_ITEM_HEALTH_CODE	: return (effect_value * MOON_ITEM_HEALTH_MARKET_COST_SCALE);
		case MOON_ITEM_DAMAGE_CODE	: return (effect_value * MOON_ITEM_DAMAGE_MARKET_COST_SCALE);
		case MOON_ITEM_GOLD_CODE	: return (effect_value * MOON_ITEM_GOLD_MARKET_COST_SCALE);
		case MOON_ITEM_RESIST_CODE	: return (effect_value * MOON_ITEM_RESIST_MARKET_COST_SCALE);
		case MOON_ITEM_RETALATE_CODE: return (effect_value * MOON_ITEM_RETALATE_MARKET_COST_SCALE);
		case MOON_ITEM_VAMPIR_CODE	: return (effect_value * MOON_ITEM_VAMPIR_MARKET_COST_SCALE);
		case MOON_ITEM_REGEN_CODE	: return (effect_value * MOON_ITEM_REGEN_MARKET_COST_SCALE);
		case MOON_ITEM_CONSUME_CODE : return (effect_value * MOON_ITEM_CONSUME_MARKET_COST_SCALE);
		case MOON_ITEM_REPAIR_CODE 	: return (effect_value * MOON_ITEM_REPAIR_MARKET_COST_SCALE);
		case MOON_ITEM_RECHARGE_CODE: return (effect_value * MOON_ITEM_RECHARGE_MARKET_COST_SCALE);
		default: return 42; // should not happen
	}
};

void(entity e) moon_calculate_magic_cost =
{
	local float ccost;

	ccost = MOON_ITEM_MARKET_COST_BASE;
	ccost = ccost + moon_calculate_effect_cost(e.magic_typeone, e.magic_typeone_value);
	ccost = ccost + moon_calculate_effect_cost(e.magic_typetwo, e.magic_typetwo_value);

	e.cost = ccost;
};

void(entity target) moon_init_target_as_magic_item =
{
	local float z;

	z = random();
	if ( z < MOON_ITEM_ARMOR_VS_RING_CHANCE )
	{
		target.netname = MOON_ITEM_ARMOR_NETNAME;
		target.targetname = MOON_ITEM_ARMOR_DISPLAY;
		setmodel(target, "progs/armor.mdl");
		target.noise1 = "items/armor1.wav";
		target.skin = 3;
	} else {
		target.netname = MOON_ITEM_RING_NETNAME;
		target.targetname = MOON_ITEM_RING_DISPLAY;
		setmodel(target, "progs/ring.mdl");
		target.noise1 = "moon/items/ring.wav";
	}

	target.lvl = 0;
	target.magic_rarity_level = 0;

	z = random();
	if ( z < MOON_ITEM_MAGIC_CHANCE_PREFIX )
	{
		moon_generate_magic_prefix(target);
	} else
	if (z < MOON_ITEM_MAGIC_CHANCE_POSTFIX )
	{
		moon_generate_magic_postfix(target);
	} else {
		moon_generate_magic_prefix(target);
		moon_generate_magic_postfix(target);
		moon_handle_magic_unique(target);
	}

	moon_calculate_magic_cost(target);
};