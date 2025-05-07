/// ReProjectMoon-specific source file
/// Here go all functions that imitate look-up in name, loot or whatever tables
/// Split pure lookup functions (`string(float)`) and other that rolls a die and calls pure lookup
/// 	but open question how to keep boundary range in sync with switch-case?


string(float r) moon_lookup_client_name =
{
	switch(r)
	{
	// id
	case 0: return "Dave";
	case 1: return "John";
	case 2: return "Michael";
	case 3: return "John";
	case 4: return "Adrian";
	case 5: return "Kevin";
	case 6: return "Paul";
	case 7: return "John";
	case 8: return "Sandy";
	case 9: return "Erican"; // am
	case 10: return "Tim";
	case 11: return "Jay";
	case 12: return "Mike";
	case 13: return "Donn";
	case 14: return "Todd";
	case 15: return "Barrett";
	case 16: return "Shawn";
	case 17: return "Trent";
	case 18: return "Sean";
	case 19: return "Raymond";
	case 20: return "Delorie";
	case 21: return "Andy";
	case 22: return "Lance";
	case 23: return "Chris";
	case 24: return "Todd";
	case 25: return "Terje";
	case 26: return "Charles";
	case 27: return "Jon";
	case 28: return "Billy";
	case 29: return "Synt"; // rillium; just to pad till round number
	// Rogue - DoE
	case 30: return "Peter";
	case 31: return "Jim";
	case 32: return "Steve";
	case 33: return "Cameron";
	case 34: return "Rich";
	case 35: return "Steven";
	case 36: return "James";
	case 37: return "Jim";
	case 38: return "Dave";
	case 39: return "Rogue"; // just to pad till round number
	// Hipnotic - SoA
	case 30: return "Mark";
	case 31: return "Jim";
	case 32: return "Robert";
	case 33: return "Tom";
	case 34: return "Michael";
	case 35: return "Jim";
	case 36: return "Harry";
	case 37: return "Matt";
	case 38: return "Mackey";
	case 39: return "Jimmy";
	// Machine - DotP/DotM
	case 40: return "Christian";
	case 41: return "Andrew";
	case 42: return "Tom";
	case 43: return "Kevin";
	case 44: return "Oscar";
	case 45: return "Kristoffer";
	case 46: return "Erik";
	case 47: return "Anton";
	case 48: return "Iuliu";
	case 49: return "Abi";
	case 50: return "Dennis";
	case 51: return "Pierre";
	case 52: return "Jens";
	case 53: return "Jerk";
	// BGS - Da
	case 54: return "John";
	case 55: return "Dean";
	// Night
	case 56: return "Stephen";
	case 57: return "Alix";
	case 58: return "Larry";
	case 59: return "Karlee";
	case 60: return "Daniel";
	// KEX
	case 61: return "Samuel";
	case 62: return "James";
	case 63: return "Edward";
	case 64: return "Dimitris";
	case 65: return "Daniel";
	case 66: return "Alex";
	case 67: return "Lexi";
	case 68: return "Sebastian";
	case 69: return "Eric";
	case 70: return "Max";
	case 71: return "Alison";
	case 72: return "Leo";
	case 73: return "James";
	case 74: return "Adam";
	case 75: return "Raul";
	case 76: return "Jonatan";
	case 77: return "Ryan";
	// Re-id
	case 78: return "Marty";
	case 79: return "Robert";
	case 80: return "Mike";
	case 81: return "Adam";
	case 82: return "Kevin";
	case 83: return "John";
	case 84: return "Eric";
	case 85: return "Mike";
	case 86: return "Gina";
	case 87: return "Ryne";
	case 88: return "Mikey";
	case 89: return "Ian";
	case 90: return "Jason";
	case 91: return "Ben";
	case 92: return "Jeff";
	case 93: return "Donn";
	case 94: return "Charles";
	case 95: return "Duncan";
	case 96: return "Alexander";
	case 97: return "Zachary";
	case 98: return "Joe";
	case 99: return "Mason";
	default: return "Petrovich";
	}
};
string() moon_lookup_random_client_name =
{
	local float r;
	r = random_int(1, 99); // keep this range in sync with moon_lookup_client_name above
	return moon_lookup_client_name(r);
};

string(float level) moon_lookup_monster_level_prefix =
{
	switch(level)
	{
	case 0: return "novice ";
	case 1: return "ordinary ";
	case 2: return "promoted ";
	case 3: return "advanced ";
	case 4: return "experienced ";
	case 5: return "grim ";
	case 6: return "massive ";
	case 7: return "skillful ";
	case 8: return "incredible ";
	case 9: return "merciless ";
	case 10: return "drilled ";
	case 11: return "war ";
	case 12: return "enourmous ";
	case 13: return "powerful ";
	case 14: return "grand ";
	case 15: return "chaos ";
	case 16: return "demonical ";
	case 17: return "superior ";
	case 18: return "hurricane ";
	case 19: return "defacing ";
	case 20: return "phantom ";
	case 21: return "lord ";
	case 22: return "baron ";
	case 23: return "overlord ";
	case 24: return "warlord ";
	case 25: return "king ";
	case 26: return "plague ";
	case 27: return "storm ";
	case 28: return "shadow ";
	case 29: return "holocaust ";
	case 30: return "order ";
	case 31: return "dire ";
	case 32: return "gale ";
	case 33: return "cruel ";
	case 34: return "doom ";
	case 35: return "serious ";
	case 36: return "celestial ";
	case 37: return "terrible ";
	case 38: return "diamond ";
	case 39: return "rush ";
	case 40: return "crashing ";
	case 41: return "fanged ";
	case 42: return "thirsty ";
	case 43: return "splitter ";
	case 44: return "sunder ";
	case 45: return "rend ";
	case 46: return "reaver ";
	case 47: return "gnash ";
	case 48: return "blow ";
	case 49: return "smasher ";
	case 50: return "satan's ";
	default: return "n00bie ";
	}
};

string(float rarity_level) moon_lookup_item_rarity_display =
{
	switch(rarity_level)
	{
	case MOON_ITEM_RARITY_THRESHOLD_TRASH:		return MOON_ITEM_RARITY_THRESHOLD_DISPLAY_TRASH;
	case MOON_ITEM_RARITY_THRESHOLD_COMMON:		return MOON_ITEM_RARITY_THRESHOLD_DISPLAY_COMMON;
	case MOON_ITEM_RARITY_THRESHOLD_UNCOMMON: 	return MOON_ITEM_RARITY_THRESHOLD_DISPLAY_UNCOMMON;
	case MOON_ITEM_RARITY_THRESHOLD_RARE:		return MOON_ITEM_RARITY_THRESHOLD_DISPLAY_RARE;
	case MOON_ITEM_RARITY_THRESHOLD_EPIC:		return MOON_ITEM_RARITY_THRESHOLD_DISPLAY_EPIC;
	case MOON_ITEM_RARITY_THRESHOLD_LEGENDARY:	return MOON_ITEM_RARITY_THRESHOLD_DISPLAY_LEGENDARY;
	case MOON_ITEM_RARITY_THRESHOLD_UNIQUE:		return MOON_ITEM_RARITY_THRESHOLD_DISPLAY_UNIQUE;
	default:
		break;
	}

	return "";
};