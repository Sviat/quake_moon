/// ReProjectMoon-specific source file
/// Here go all functions related to Shop, Market and other gold stuff


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

float(float price) moon_get_inflation_adjusted_cost =
{
	return price + percent(price, up_gold_value);
};
