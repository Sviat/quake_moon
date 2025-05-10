/// ReProjectMoon-specific source file
/// Here go all common game (and logic) definitions
// TODO: one day may be split between technical and Game Design defs?

// Syntactic sugar for function argument defaulting. Only exception to naming convention
#define false 0
#define true 1

/// These (CONST_* and MOON_CONST_*) are (preprocessor) consts
///     SAFE TO USE AS RIGHT-HAND SIDE AND/OR DEFAULT ARGUMENT

// Vanilla consts that declared only to remember them
#define CONST_QC_DISPLAY_MAX 999

#define CONST_QC_SPRINT_A "\a"			// Black cell
#define CONST_QC_SPRINT_F "\f"			// ?!?
#define CONST_QC_GLYPH_SELECTION "\r"	// Red triangle
#define CONST_QC_SPRINT_V "\v"			// White cell

#define CONST_QC_SPRINT_B_OPEN "\b"		// Red text
#define CONST_QC_SPRINT_B_CLOSE "\b"
#define CONST_QC_SPRINT_S_OPEN "\s"		// Also red text, but why two different codes?
#define CONST_QC_SPRINT_S_CLOSE "\s"

#define CONST_QC_COLLISION_WITH_EVERYTHING 0
#define CONST_QC_COLLISION_WITH_SOLID 1
#define CONST_QC_COLLISION_WITH_MONSTER_WIDE 2
// //

/// All below MUST be prefixed with MOON_

// // Quake Glyphs
#define MOON_CONST_GLYPH_WHITECELL "\x0B"		// White cell, should be cursor
#define MOON_CONST_GLYPH_SELECTION "\x0D"		// Red triangle
#define MOON_CONST_GLYPH_BRACKET_OPEN "\x10"	// Red [, also x90
#define MOON_CONST_GLYPH_BRACKET_CLOSE "\x11"	// Red ], also x91
#define MOON_CONST_GLYPH_CENTERDOT_WHITE "\x1C" // White center dot
#define MOON_CONST_GLYPH_ARROW "\x7F"			// Arrow pointing left
#define MOON_CONST_GLYPH_BLACKSQUARE "\x88"	    // Black square
#define MOON_CONST_GLYPH_REDSQUARE "\x8B"		// Red square
#define MOON_CONST_GLYPH_CENTERDOT_YELLOW "\x8E" // Yellow center dot
#define MOON_CONST_GLYPH_REDARROW "\xFF"		// Red arrow pointing left
// //

// Special Flag for Traits/ItemSlots/Upgrades with Locked->Unlocked->Level1->...->LevelN progression
#define MOON_CONST_LOCKED -1
#define MOON_CONST_UNLOCKED 0 // anything above this is the Level of that property

// Special Flag for Axe hit state (vanilla was 0/1, added 2)
#define MOON_CONST_AXE_NOT 0
#define MOON_CONST_AXE_HIT 1
#define MOON_CONST_AXE_CRIPPLE 2 // added, TODO: handling

// Max level is widely used throughout the code
#define MOON_CONST_MAXLVL 50

// // Bit flag enums for debug option
#define MOON_CONST_DEBUG_DPRINT_NONE 0              // dprint > /dev/null
#define MOON_CONST_DEBUG_DPRINT_SOME 1              // dprint > bprint, occasional: debug sprint
#define MOON_CONST_DEBUG_CPRINT_TRACEENT 2          // Every frame: centerprint target entity class, name and target
#define MOON_CONST_DEBUG_DPRINT_NEXTWAVE 4          // Every wave: dprint time till next wave
#define MOON_CONST_DEBUG_DPRINT_SPAWNED_NAMES 8     // Every wave: dprint name of each spawned monster
#define MOON_CONST_DEBUG_CHEATS_ON 16               // Allow the use of cheats
#define MOON_CONST_DEBUG_EPRINT_MONSTERS 32         // Allow eprint-ing monsters (i.e to find stuck on respawn)
// Traits later be used in playable classes
#define MOON_CONST_TRAIT_CPRINT_SEE_ALLY_HP 512     // Show ally (heart, guard) HP on crosshair
#define MOON_CONST_TRAIT_CPRINT_SEE_MONSTER_HP 1024 // Show monster HP on crosshair
// //

/// end of (preprocessor) consts

string MOON_VERSION = "0.29kf";
float MOON_DEBUG = MOON_CONST_DEBUG_DPRINT_SPAWNED_NAMES | MOON_CONST_DEBUG_CHEATS_ON | MOON_CONST_TRAIT_CPRINT_SEE_ALLY_HP | MOON_CONST_TRAIT_CPRINT_SEE_MONSTER_HP | MOON_CONST_DEBUG_EPRINT_MONSTERS;
// // Impulse codes. First 19 keep for original Q1; limit is 255; so we should line up somewhere in between
float QC_IMPULSE_CODE_NOOP = 0;
// Code range WEAPONS 1..8 - Quake defaults
float QC_IMPULSE_CODE_WEAPON_AXE = 1;
float QC_IMPULSE_CODE_WEAPON_SHOTGUN = 2;
float QC_IMPULSE_CODE_WEAPON_SUPER_SHOTGUN = 3;
float QC_IMPULSE_CODE_WEAPON_NAILGUN = 4;
float QC_IMPULSE_CODE_WEAPON_SUPER_NAILGUN = 5;
float QC_IMPULSE_CODE_WEAPON_GRENADE_LAUNCHER = 6;
float QC_IMPULSE_CODE_WEAPON_ROCKET_LAUNCHER = 7;
float QC_IMPULSE_CODE_WEAPON_LIGHTNING = 8;
// Code range for rest Quake defaults
float QC_IMPULSE_CODE_CHEAT_COMMAND = 9;
float QC_IMPULSE_CODE_CYCLE_WEAPON_FORTH = 10;
float QC_IMPULSE_CODE_SERVER_FLAGS = 11;
float QC_IMPULSE_CODE_CYCLE_WEAPON_BACK = 12;

float MOON_IMPULSE_CODE_FIRST = 32;
// Code range CLI UI 32..95
float MOON_IMPULSE_CODE_FIRST_CLI_UI = 32;
float MOON_IMPULSE_CODE_DEBUG_EPRINT_MONSTERS_ALIVE = 32;
float MOON_IMPULSE_CODE_PRINT_STAT = 40;
float MOON_IMPULSE_CODE_UPSKILL_VITALITY = 41;
float MOON_IMPULSE_CODE_UPSKILL_STRENGTH = 42;
float MOON_IMPULSE_CODE_UPSKILL_SANITY = 43;
float MOON_IMPULSE_CODE_UPSKILL_INTUITION = 44;
float MOON_IMPULSE_CODE_PRINT_CLI_HELP = 50;
float MOON_IMPULSE_CODE_PRINT_INVENTORY = 60;
float MOON_IMPULSE_CODE_PRINT_STATUS = 70;
float MOON_IMPULSE_CODE_LAST_CLI_UI = 95;
// Code range SERVER settings 96..127
float MOON_IMPULSE_CODE_FIRST_SETTING_SERVER = 96;
float MOON_IMPULSE_CODE_ALWAYSDAY = 101;
float MOON_IMPULSE_CODE_FASTMEAT = 102;
float MOON_IMPULSE_CODE_SLOWMEAT = 103;
float MOON_IMPULSE_CODE_NOSHAKE = 104;
float MOON_IMPULSE_CODE_CHEAT_QUAD = 126;
float MOON_IMPULSE_CODE_CHEAT_GOLD = 127;
float MOON_IMPULSE_CODE_LAST_SETTING_SERVER = 127;
// Code range CLIENT settings 128..159
float MOON_IMPULSE_CODE_FIRST_SETTING_CLIENT = 128;
float MOON_IMPULSE_CODE_NOHELP = 150;
float MOON_IMPULSE_CODE_SHOWFPS = 151;
float MOON_IMPULSE_CODE_LAST_SETTING_CLIENT = 159;
// Code range TRACE CROSSHAIR 160..223 (well range finder too)
float MOON_IMPULSE_CODE_FIRST_TRACE = 160;
float MOON_IMPULSE_CODE_ITEM_PICKUP = 192;
float MOON_IMPULSE_CODE_ITEM_BUY = 194;
float MOON_IMPULSE_CODE_ITEM_IDENTIFY = 196;
float MOON_IMPULSE_CODE_LAST_TRACE = 223;
//
float MOON_IMPULSE_CODE_LAST = 234;
// //

float CHSCAM_ON    = 1; // no idea

float MOON_DIFFICULTY_MIN = 0; // easy
float MOON_DIFFICULTY_MAX = 3; // nightmare

string MOON_CHAT_NAME_SERVER 	= "Server";
string MOON_CHAT_NAME_SETTINGS 	= "Settings";
string MOON_CHAT_NAME_GUARD 	= "Guardian";
float MOON_CHAT_COLOR_TECHMSG = CONST_QEX_COLOR_WHITE;
float MOON_CHAT_COLOR_SELFMSG = CONST_QEX_COLOR_GREEN;
float MOON_CHAT_COLOR_BOTMSG  = CONST_QEX_COLOR_TEAL;
float MOON_CHAT_COLOR_WARNING = CONST_QEX_COLOR_YELLOW;

// // Sound & Music
float MOON_SOUND_VOLUME_DEFAULT = 1.0;
float MOON_WALKMAN_CHANNEL = 6;
float MOON_WALKMAN_VOLUME_SILENCE = 0.0;
float MOON_WALKMAN_VOLUME_MUSIC = 0.32;
float MOON_WALKMAN_VOLUME_SHOP = 1;
float MOON_WALKMAN_ATTEN_MUSIC = 0.42;
float MOON_WALKMAN_ATTEN_SHOP = 1.0;
float MOON_WALKMAN_DELAY_FIRSTTHINK_MIN     = 10; // in seconds
float MOON_WALKMAN_DELAY_FIRSTTHINK_RANDOM  = 20; // in seconds
float MOON_WALKMAN_DELAY_FIRSTTRACK_SHOP    =  1; // in seconds
float MOON_WALKMAN_DELAY_FIRSTTRACK_GATE    = 32; // in seconds
float MOON_WALKMAN_DELAY_BETWEENTHINKS      = 30; // in seconds
float MOON_WALKMAN_DELAY_BETWEENTRACKS_SHOP = 12; // in seconds
float MOON_WALKMAN_DELAY_BETWEENTRACKS_GATE =  3; // in seconds

float MOON_PLAYER_MAX_LEVEL = MOON_CONST_MAXLVL;
float MOON_HEART_MAX_LEVEL = MOON_CONST_MAXLVL;
float MOON_EXP_FIRST_LEVEL = 40;
float MOON_NEXTLEVEL_MORE_PLAYERLEVEL_TIMES = 40;
float MOON_NEXTLEVEL_MORE_SCALING_FACTOR = 1.35;

string MOON_PLAYER_CLASSNAME = "player";
string MOON_PLAYER_DISPLAYNAME = "player";
float MOON_PLAYER_HEALTH_INIT = 100;
float MOON_PLAYER_HEALTH_REGEN_COOLDOWN = 1; // in seconds
float MOON_PLAYER_MANA_INIT = 35;	// may be change later
float MOON_PLAYER_GOLD_INIT = 300;
float MOON_PLAYER_LEVEL_GROW_FAST 	= 35;
float MOON_PLAYER_POINT_GROW_FAST 	= 5;
float MOON_PLAYER_LEVEL_GROW_NORMAL = 40;
float MOON_PLAYER_POINT_GROW_NORMAL = 4;
float MOON_PLAYER_LEVEL_GROW_SLOW 	= 50; // unnecessary, just for consistency
float MOON_PLAYER_POINT_GROW_SLOW 	= 3;
float MOON_PLAYER_LEVEL_NOMOREHELP = 4;

// Play-able classes are referred as "Chars" to not confuse with class keyword/property
string MOON_CHAR_RANGER_CLASS = "default";		// Default, manual Level-up
string MOON_CHAR_BLACK_CLASS = "black";			// Vitality-biased auto Level-up
string MOON_CHAR_DOOMED_CLASS = "doomed";		// Strength-biased auto Level-up
string MOON_CHAR_ELDER_CLASS = "elder";			// Sanity-biased auto Level-up
string MOON_CHAR_NETHER_CLASS = "nether";		// Intuition-biased auto Level-up

string MOON_CHAR_RANGER_NAME = "Ranger";
string MOON_CHAR_BLACK_NAME = "Black";
string MOON_CHAR_DOOMED_NAME = "Doomed";
string MOON_CHAR_ELDER_NAME = "Elder";
string MOON_CHAR_NETHER_NAME = "Nether";

string MOON_STAT_VITALITY_NAME = "vitality";	// Physical health (+Ax later)
string MOON_STAT_STRENGTH_NAME = "strength";	// Firearms power
string MOON_STAT_SANITY_NAME = "sanity";		// Magic health
string MOON_STAT_INTUITION_NAME = "intuition";	// Magic power

float MOON_STAT_HEALTH_PER_VITALITY = 2;
float MOON_STAT_DAMAGE_PER_STRENGTH = 1.5;
float MOON_STAT_MANA_PER_SANITY 	= 1; 	// Not finished
float MOON_STAT_POWER_PER_INTUITION	= 0.5; 	// Not finished
float MOON_STAT_MAXHEALTH_MIN       = 1;
float MOON_STAT_MAXMANA_MIN         = 0;

float MOON_RESIST_LIMIT_HARD = 75;  // in %, maximum possible damage reduction on single instance

float MOON_PHYSIC_CROSSHAIRTRACE_MAXDIST = 1200; // was 1500
float MOON_PHYSIC_ITEMSEARCH_RADIUS = 100;
float MOON_PHYSIC_VELOCITY_X_LIMIT_SOFT = 150;
float MOON_PHYSIC_VELOCITY_X_LIMIT_HARD = 160;
float MOON_PHYSIC_VELOCITY_Y_LIMIT_SOFT = 150;
float MOON_PHYSIC_VELOCITY_Y_LIMIT_HARD = 160;

float MOON_TIME_PLUS_CROSSHAIRTRACE = 0.24; // was 0.01
float MOON_TIME_TO_DISAPPEAR_TRASH = 30;
float MOON_TIME_TO_DISAPPEAR_NORMAL = 60;
float MOON_TIME_TO_DISAPPEAR_IMPORTANT = 90;
float MOON_TIME_ACTIVE_MENTAT = 90;
float MOON_TIME_BETWEEN_MONSTER_SPAWN = 0.4; // was 0.3 but for Coop MP changed to 0.4
float MOON_TIME_BETWEEN_ITEMSCANS = 1.28;
float MOON_TIME_BETWEEN_FAILED_CHECKS = 4.21;
float MOON_TIME_BETWEEN_ITEMTOUCH_ITEM_PRINT = 4.01; // dont bother Player with this item for that period
float MOON_TIME_BETWEEN_ITEMTOUCH_PLAYER_PRINT = 1.01; // dont bother Player with any item for that period

string MOON_GATE_CLASSNAME = "gate";
string MOON_GATE_ENTRY_DISPLAYNAME = "Entrance Gate";

string MOON_HEART_CLASSNAME = "heart";
string MOON_HEART_DISPLAYNAME = "Castle Heart";
string MOON_HEART_MODEL = "progs/heart.mdl";
string MOON_HEART_AIMLABEL = MOON_CONST_GLYPH_REDSQUARE" \sDONT\s "MOON_CONST_GLYPH_REDSQUARE;
float MOON_HEART_HEALTH_INIT = 200;
float MOON_HEART_HEALTH_GROW = 10;
float MOON_HEART_HEALTH_REGEN_VALUE = 1;
float MOON_HEART_HEALTH_REGEN_COOLDOWN = 1;

string MOON_GUARD_CLASSNAME = "guard";
string MOON_GUARD_DISPLAYNAME = "comrade";
float MOON_GUARD_SKIN = 3;
float MOON_GUARD_HEALTH_INIT = 100;
float MOON_GUARD_HEALTH_GROW = 25;
float MOON_GUARD_HEALTH_REGEN_VALUE = 1;
float MOON_GUARD_HEALTH_REGEN_COOLDOWN = 5;

string MOON_GOLD_BAG_MODEL = "progs/gold.mdl";

string MOON_GOLD_MINE_CLASSNAME = "derrick";
float MOON_GOLD_MINE_DETECT_PLAYER_RADIUS = 800; // was 250
float MOON_GOLD_MINE_DETECT_GUARD_RADIUS  = 400; // added in KEK port
float MOON_GOLD_MINE_DELAY_MIN = 12;
float MOON_GOLD_MINE_DELAY_RANDOM = 12;
float MOON_GOLD_MINE_BASE = 2;
float MOON_GOLD_MINE_LVLPERCENT = 2.5;
float MOON_GOLD_MINE_RANDOM = 10;

float MOON_GOLD_LOOT_BASE = 1;
float MOON_GOLD_LOOT_LVLPERCENT = 5;
float MOON_GOLD_LOOT_RANDOM = 60;

float MOON_TRADE_STATE_OCCUPIED = 0;
float MOON_TRADE_STATE_FREE = 1;
float MOON_TRADE_STATE_TRADING = 2; // only applicable to trader

string MOON_TRADER_SHOP_CLASSNAME = "monster_trader";
string MOON_TRADER_MARKET_CLASSNAME = "saler";
string MOON_TRADE_MARKET_SOMETHING_CLASSNAME = "sale_ent"; // Trader standing position?
string MOON_TRADE_SHOP_SPOT_CLASSNAME = "trade_spot"; // Shop item slot
string MOON_TRADE_MARKET_SPOT_CLASSNAME = "goody_ent"; // Black market item slot

float MOON_TRADE_SPOT_DELAY_INIT_MIN = 1;
float MOON_TRADE_SPOT_DELAY_INIT_RANDOM = 15;
string MOON_TRADER_SHOP_AMMO_NETNAME = "ammo_trader"; // trader.netname AND spot.prefix_four
float MOON_TRADE_SPOT_AMMO_DELAY_MIN = 24; // was 20, changed to 24 to have int division by 2,3,4
float MOON_TRADE_SPOT_AMMO_DELAY_RANDOM = 16; // was 20, changed compensate above
string MOON_TRADER_SHOP_ARMOR_NETNAME = "armor_trader"; // trader.netname AND spot.prefix_four
float MOON_TRADE_SPOT_ARMOR_DELAY_MIN = 20;
float MOON_TRADE_SPOT_ARMOR_DELAY_RANDOM = 20;
string MOON_TRADER_SHOP_HEALTH_NETNAME = "health_trader"; // trader.netname AND spot.prefix_four
float MOON_TRADE_SPOT_HEALTH_DELAY_MIN = 12; // was 20
float MOON_TRADE_SPOT_HEALTH_DELAY_RANDOM = 28; // was 20
string MOON_TRADER_SHOP_WEAPON_NETNAME = "weapon_trader"; // trader.netname AND spot.prefix_four
float MOON_TRADE_SPOT_WEAPON_DELAY_MIN = 24; // was 20
float MOON_TRADE_SPOT_WEAPON_DELAY_RANDOM = 26; // was 20

// Do not confuse MOON_ARMOR_ with MOON_ITEM_ARMOR, former is GreenYellowRed armor, latter is Magical Item
float MOON_ARMOR_MAX_SOFT = 300;
float MOON_ARMOR_SHARD_GAIN = 5;
float MOON_ARMOR_SHARD_TYPE = 0.3;
string MOON_ARMOR_MARKET_NETNAME = "goody_armor";
string MOON_ARMOR_MARKET_PREFIX = "damaged ";
float MOON_ARMOR_GREEN_CODE = 8192; // IT_ARMOR1;
float MOON_ARMOR_GREEN_SKIN = 0;
float MOON_ARMOR_GREEN_DURABILITY = 100;
float MOON_ARMOR_GREEN_RESISTANCE = 0.3;
float MOON_ARMOR_GREEN_SHOP_COST = 50;
float MOON_ARMOR_GREEN_MARKET_COSTOFONE = 0.5;
float MOON_ARMOR_GREEN_MARKET_DURABILITY_MIN = 50;
float MOON_ARMOR_GREEN_MARKET_DURABILITY_RANDOM = 50;
string MOON_ARMOR_GREEN_DISPLAYNAME = "Green Armor";
string MOON_ARMOR_GREEN_MARKET_DISPLAYNAME = "damaged Green Armor";
float MOON_ARMOR_YELLOW_CODE = 16384; // IT_ARMOR2;
float MOON_ARMOR_YELLOW_SKIN = 1;
float MOON_ARMOR_YELLOW_DURABILITY = 150;
float MOON_ARMOR_YELLOW_RESISTANCE = 0.6;
float MOON_ARMOR_YELLOW_SHOP_COST = 100;
float MOON_ARMOR_YELLOW_MARKET_COSTOFONE = 0.6;
float MOON_ARMOR_YELLOW_MARKET_DURABILITY_MIN = 100;
float MOON_ARMOR_YELLOW_MARKET_DURABILITY_RANDOM = 50;
string MOON_ARMOR_YELLOW_DISPLAYNAME = "Yellow Armor";
string MOON_ARMOR_YELLOW_MARKET_DISPLAYNAME = "damaged Yellow Armor";
float MOON_ARMOR_RED_CODE = 32768; // IT_ARMOR3;
float MOON_ARMOR_RED_SKIN = 2;
float MOON_ARMOR_RED_DURABILITY = 200;
float MOON_ARMOR_RED_RESISTANCE = 0.8;
float MOON_ARMOR_RED_SHOP_COST = 150;
float MOON_ARMOR_RED_MARKET_COSTOFONE = 0.7;
float MOON_ARMOR_RED_MARKET_DURABILITY_MIN = 150;
float MOON_ARMOR_RED_MARKET_DURABILITY_RANDOM = 50;
string MOON_ARMOR_RED_DISPLAYNAME = "Red Armor";
string MOON_ARMOR_RED_MARKET_DISPLAYNAME = "damaged Red Armor";

float MOON_ITEM_NONE = MOON_CONST_LOCKED;
float MOON_ITEM_SOME = MOON_CONST_UNLOCKED;

float MOON_ITEM_MAGIC_CHANCE_PREFIX = 0.3;
float MOON_ITEM_MAGIC_CHANCE_POSTFIX = 0.6; // if above this - both
float MOON_ITEM_ARMOR_VS_RING_CHANCE = 0.5;

float MOON_ITEM_TRADE_SIGNOF_AMMO 	= 2;
float MOON_ITEM_TRADE_SIGNOF_WEAPON = 3;

float MOON_ITEM_LVLTHRESHOLD_POTION_LOWER = 4;
float MOON_ITEM_LVLTHRESHOLD_POTION_UPPER = 8;

// MOON_ITEM_EFFECT -> MOON_ITEM
// (Prefix- or Postfix-) Effect rarity
float MOON_ITEM_RARITY_LOW 		= 0;
float MOON_ITEM_RARITY_NORMAL 	= 1;
float MOON_ITEM_RARITY_HIGH 	= 2;
float MOON_ITEM_RARITY_EPIC 	= 3;

// Resulting (Prefix + Postfix) rarity class
float MOON_ITEM_RARITY_THRESHOLD_TRASH = 0;
float MOON_ITEM_RARITY_THRESHOLD_COMMON = 1;
float MOON_ITEM_RARITY_THRESHOLD_UNCOMMON = 2;
float MOON_ITEM_RARITY_THRESHOLD_RARE = 3;
float MOON_ITEM_RARITY_THRESHOLD_EPIC = 4;
float MOON_ITEM_RARITY_THRESHOLD_LEGENDARY = 5;
float MOON_ITEM_RARITY_THRESHOLD_UNIQUE = 6; // EPIC Postfix only allowed for Unique (Named) items
string MOON_ITEM_RARITY_THRESHOLD_DISPLAY_TRASH = "trash";
string MOON_ITEM_RARITY_THRESHOLD_DISPLAY_COMMON = "Common";
string MOON_ITEM_RARITY_THRESHOLD_DISPLAY_UNCOMMON = "Uncommon";
string MOON_ITEM_RARITY_THRESHOLD_DISPLAY_RARE = "Rare";
string MOON_ITEM_RARITY_THRESHOLD_DISPLAY_EPIC = "EPIC";
string MOON_ITEM_RARITY_THRESHOLD_DISPLAY_LEGENDARY = MOON_CONST_GLYPH_WHITECELL;
string MOON_ITEM_RARITY_THRESHOLD_DISPLAY_UNIQUE = MOON_CONST_GLYPH_REDSQUARE;

// Dynamic Magical item grid
// Trait effect is chosen uniformaly between [MOON_ITEM_TRAIT_MIN_EFFECT, MOON_ITEM_TRAIT_MAX_EFFECT]
float MOON_ITEM_TRAIT_CODE_LOW_HIGHEST  = 6;
float MOON_ITEM_TRAIT_CODE_THRESHOLD_LOW    = 10; // after this level - do not generate HIGH tier
float MOON_ITEM_TRAIT_CODE_HIGH_LOWEST  = 4;
float MOON_ITEM_TRAIT_CODE_THRESHOLD_HIGH   = 40; // after this level - do not generate LOW tier

// Final Trait quality: Q(lvl) = P(lvl) + rand()*R(lvl)
//  (shift function) P(lvl) = clampd(0, 2*lvl - 20, 20)
//  (width function) R(lvl) = 20 / 40 / 40-55 / 40-60 / 50-80
float MOON_ITEM_TRAIT_QUALITY_MULTIPLIER_LEVEL_FLAT = 2;
float MOON_ITEM_TRAIT_QUALITY_MULTIPLIER_LEVEL_RANDOM = 1;//remove
float MOON_ITEM_TRAIT_LVLTHRESHOLD_LOWANDNORMAL = 5;
float MOON_ITEM_TRAIT_LVLTHRESHOLD_NOEPIC = 10;
float MOON_ITEM_TRAIT_LVLTHRESHOLD_ALL = 15;
float MOON_ITEM_TRAIT_LVLTHRESHOLD_NOLOW = 20;
float MOON_ITEM_TRAIT_LVLTHRESHOLD_HIGHANDEPIC = 100; // not necessary
// If Trait quality is less than threshold -> that is rarity
float MOON_ITEM_TRAIT_THRESHOLD_PREFIX_LOW = 10;        // These
float MOON_ITEM_TRAIT_THRESHOLD_PREFIX_NORMAL = 20;     //  values
float MOON_ITEM_TRAIT_THRESHOLD_PREFIX_HIGH = 40;       //   were used to balance Quality roll formula
float MOON_ITEM_TRAIT_THRESHOLD_POSTFIX_LOW = 8;        // But these
float MOON_ITEM_TRAIT_THRESHOLD_POSTFIX_NORMAL = 16;    //  values
float MOON_ITEM_TRAIT_THRESHOLD_POSTFIX_HIGH = 92;      //   are intentionally off balance

float MOON_ITEM_TRAIT_THRESHOLD_PREFIX_EPIC = 100; // not necessary, since MAX is 100, and everything between HIGH and that would be EPIC anyway
float MOON_ITEM_TRAIT_THRESHOLD_POSTFIX_EPIC = 100; // not necessary, since MAX is 100, Epic postfix => UNIQUE item, but TODO for later

float MOON_ITEM_TRAIT_BADLUCKCOMPENSATION_BONUS = 4; // added each time EPIC postfix is rolled, but prefix is not EPIC, so UNIQUE item was not generated

// MOON_ITEM_MEDKIT -> MOON_MEDKIT . Medkits can only be bought
float MOON_MEDKIT_SMALL_TYPE		= 0;
float MOON_MEDKIT_SMALL_VALUE		= 15;
float MOON_MEDKIT_SMALL_COST		= 20;
string MOON_MEDKIT_SMALL_DISPLAYNAME = "small Medkit";
float MOON_MEDKIT_NORMAL_TYPE		= 1;
float MOON_MEDKIT_NORMAL_VALUE		= 25;
float MOON_MEDKIT_NORMAL_COST		= 30;
string MOON_MEDKIT_NORMAL_DISPLAYNAME = "Medkit";
float MOON_MEDKIT_MEGA_TYPE			= 2;
float MOON_MEDKIT_MEGA_VALUE		= 100;
float MOON_MEDKIT_MEGA_COST			= 100;
float MOON_MEDKIT_MEGA_OVERHEAL_SOFTLIMIT = 150;
float MOON_MEDKIT_MEGA_OVERHEAL_HARDLIMIT = 250;
string MOON_MEDKIT_MEGA_MARKET_NETNAME = "goody_mega";
string MOON_MEDKIT_MEGA_DISPLAYNAME = "Megapack";
string MOON_MEDKIT_MEGA_MARKET_DISPLAYNAME = "degraded Megapack";
string MOON_MEDKIT_MEGA_MODEL = "maps/b_bh100.bsp";
float MOON_MEDKIT_MEGA_DECAY_VALUE = -1;
float MOON_MEDKIT_MEGA_DECAY_COOLDOWN = 1;
float MOON_MEDKIT_MEGA_MARKET_MIN = 50;
float MOON_MEDKIT_MEGA_MARKET_RANDOM = 50;
float MOON_MEDKIT_MEGA_MARKET_COSTOFONE = 0.85;

// MOON_ITEM_POTION -> MOON_POTION . Potion -> lootable medkit
string MOON_ITEM_POTION_SMALL_NETNAME = "small healing potion";
float MOON_ITEM_POTION_SMALL_BASE		= 15;
float MOON_ITEM_POTION_SMALL_RANDOM 	= 35;
string MOON_ITEM_POTION_NORMAL_NETNAME = "healing potion";
float MOON_ITEM_POTION_NORMAL_BASE 		= 35;
float MOON_ITEM_POTION_NORMAL_RANDOM 	= 65;
string MOON_ITEM_POTION_BIG_NETNAME = "big healing potion";
float MOON_ITEM_POTION_BIG_BASE 		= 65;
float MOON_ITEM_POTION_BIG_RANDOM 		= 100;

// MOON_ITEM_AMMO -> MOON_AMMO
// Player backpack soft limits
float MOON_AMMO_MAX_SHELL 	= 100;	// Initial max, before any upgrades
float MOON_AMMO_MAX_NAIL 	= 200;	// Initial max, before any upgrades
float MOON_AMMO_MAX_ROCKET 	= 100;	// Initial max, before any upgrades
float MOON_AMMO_MAX_CELL 	= 100;	// Initial max, before any upgrades
// These ammo boxes can be bought in shop, on market or looted, need to update later
string MOON_AMMO_MARKET_NETNAME = "goody_ammo";
float MOON_AMMO_MARKET_ROCKET_VS_CELL_RATIO = 0.6;
float MOON_AMMO_SHELLS_CODE     = 256; // IT_SHELLS
string MOON_AMMO_SHELLS_DISPLAYNAME = "shells";
string MOON_AMMO_SHELLS_MODEL = "maps/b_shell0.bsp";
float MOON_AMMO_SHELLS_BASE = 10;
float MOON_AMMO_SHELLS_RANDOM = 20;
float MOON_AMMO_SHELLS_COSTOFONE = 0.7;
float MOON_AMMO_SHELLS_LOOT_MIN = 10;	// was 1
float MOON_AMMO_SHELLS_LOOT_RANDOM = 26;	// was 35
float MOON_AMMO_SHELLS_MARKET_COSTOFONE = 2;
float MOON_AMMO_NAILS_CODE      = 512; // IT_NAILS
string MOON_AMMO_NAILS_DISPLAYNAME = "nails";
string MOON_AMMO_NAILS_MODEL = "maps/b_nail0.bsp";
float MOON_AMMO_NAILS_BASE = 20;
float MOON_AMMO_NAILS_RANDOM = 20;
float MOON_AMMO_NAILS_COSTOFONE = 0.8;
float MOON_AMMO_NAILS_LOOT_MIN = 11;	// was 6
float MOON_AMMO_NAILS_LOOT_RANDOM = 30;	// was 35
float MOON_AMMO_NAILS_MARKET_COSTOFONE = 1;
float MOON_AMMO_ROCKETS_CODE    = 1024; // IT_ROCKETS
string MOON_AMMO_ROCKETS_DISPLAYNAME = "rockets";
string MOON_AMMO_ROCKETS_MODEL = "maps/b_rock0.bsp";
float MOON_AMMO_ROCKETS_BASE = 5;
float MOON_AMMO_ROCKETS_RANDOM = 8;
float MOON_AMMO_ROCKETS_COSTOFONE = 3;
float MOON_AMMO_ROCKETS_LOOT_MIN = 1;
float MOON_AMMO_ROCKETS_LOOT_RANDOM = 10;
float MOON_AMMO_ROCKETS_MARKET_COSTOFONE = 6;
float MOON_AMMO_ROCKETS_MARKET_MIN = 15;
float MOON_AMMO_ROCKETS_MARKET_RANDOM = 10;
float MOON_AMMO_CELLS_CODE      = 2048; // IT_CELLS
string MOON_AMMO_CELLS_DISPLAYNAME = "cells";
string MOON_AMMO_CELLS_MODEL = "maps/b_batt0.bsp";
float MOON_AMMO_CELLS_BASE = 8;
float MOON_AMMO_CELLS_RANDOM = 8;
float MOON_AMMO_CELLS_COSTOFONE = 3.5;
float MOON_AMMO_CELLS_LOOT_MIN = 5;	// was 2
float MOON_AMMO_CELLS_LOOT_RANDOM = 13;	// was 16
float MOON_AMMO_CELLS_MARKET_COSTOFONE = 8;
float MOON_AMMO_CELLS_MARKET_MIN = 15;
float MOON_AMMO_CELLS_MARKET_RANDOM = 7;

// General properties (dmg, speed, distance)
// Ammo properties that shared for all weapons using it
float MOON_WEAPON_DAMAGEPER_SLASH = 25;         // Axe, adjusted for up_axe default -1 lowering damage
float MOON_WEAPON_DAMAGEPER_BULLET = 10;        // Shot&Supershot
float MOON_WEAPON_DAMAGEPER_NAIL = 9;           // Nailgun
float MOON_WEAPON_DAMAGEPER_SUPERNAIL = 18;     // Supernailgun
float MOON_WEAPON_PROJECTILESPEED_NAIL = 1000;  // Nail&Supernail
float MOON_WEAPON_DAMAGEPER_ROCKET_BASE = 100;  // RL
float MOON_WEAPON_DAMAGEPER_ROCKET_RANDOM = 20; // RL
float MOON_WEAPON_DAMAGEPER_SPLASH = 120;       // GL&RL
float MOON_WEAPON_DAMAGEPER_CELL = 30;          // Shaft
float MOON_WEAPON_DAMAGEPER_CELL_DISCHARGE = 35;// Shaft in water
float MOON_WEAPON_DAMAGEPER_SHAMBLERSHOT = 10;  // Shambler

float MOON_WEAPON_DAMAGE_BONUSRADIUS_SPLASH = 40; // GL&RL
float MOON_WEAPON_DAMAGE_SPLASH_MULT_SELF = 0.5;// GL&RL
float MOON_WEAPON_DAMAGE_SPLASH_MULT_SHAMBLER = 0.5; // GL&RL
float MOON_WEAPON_DISTANCE_AXE = 64;            // Axe
float MOON_WEAPON_DISTANCE_LIGHTNING = 600;     // Shaft
float MOON_WEAPON_PIERCING_LIGHTNING_NONE = 0;  // Guardian's Shaft
float MOON_WEAPON_PIERCING_LIGHTNING_SOME = 4;  // Player's Shaft

// MOON_ITEM_WEAPON -> MOON_WEAPON . Weapons can be bought and looted
string MOON_WEAPON_MARKET_NETNAME = "goody_weapon";

// Starting weapons, so they are quite special in most regards
float MOON_WEAPON_AXE_CODE = 4096; // IT_AXE
string MOON_WEAPON_AXE_DISPLAYNAME = "Blood Seeker";
string MOON_WEAPON_AXE_SHORTNAME = "ax";
string MOON_WEAPON_AXE_MODEL_FPV = "progs/v_axe.mdl";
float  MOON_WEAPON_AXE_COOLDOWN = 0.5;

float MOON_WEAPON_SHOTGUN_CODE = 1; // IT_SHOTGUN
string MOON_WEAPON_SHOTGUN_DISPLAYNAME = "Boomstick";
string MOON_WEAPON_SHOTGUN_SHORTNAME = "Shot";
string MOON_WEAPON_SHOTGUN_MODEL_FPV = "progs/v_shot.mdl";
float  MOON_WEAPON_SHOTGUN_SALVO_SIZE = 1;
float  MOON_WEAPON_SHOTGUN_COOLDOWN = 0.5;

// Obtainable through shop, market or looting
float MOON_WEAPON_SUPERSHOTGUN_CODE = 2; // IT_SUPER_SHOTGUN
string MOON_WEAPON_SUPERSHOTGUN_DISPLAYNAME = "Double-Boomstick";
string MOON_WEAPON_SUPERSHOTGUN_MARKET_DISPLAYNAME = "Inferior Double-Boomstick";
string MOON_WEAPON_SUPERSHOTGUN_SHORTNAME = "sShot";
string MOON_WEAPON_SUPERSHOTGUN_MODEL_FPV = "progs/v_shot2.mdl";
string MOON_WEAPON_SUPERSHOTGUN_MODEL_TPV = "progs/g_shot.mdl";
float  MOON_WEAPON_SUPERSHOTGUN_SALVO_SIZE = 2;
float  MOON_WEAPON_SUPERSHOTGUN_COOLDOWN = 0.7;
float  MOON_WEAPON_SUPERSHOTGUN_COST_SHOP = 50;
float  MOON_WEAPON_SUPERSHOTGUN_COST_MARKET = 40;
float  MOON_WEAPON_SUPERSHOTGUN_AMMO_SHOP = 5;
float  MOON_WEAPON_SUPERSHOTGUN_AMMO_MARKET = 5;
float  MOON_WEAPON_SUPERSHOTGUN_AMMO_LOOT_MIN = 10;
float  MOON_WEAPON_SUPERSHOTGUN_AMMO_LOOT_RANDOM = 10;

float MOON_WEAPON_NAILGUN_CODE = 4; // IT_NAILGUN
string MOON_WEAPON_NAILGUN_DISPLAYNAME = "Nailgun";
string MOON_WEAPON_NAILGUN_MARKET_DISPLAYNAME = "Inferior Nailgun";
string MOON_WEAPON_NAILGUN_SHORTNAME = "Nail";
string MOON_WEAPON_NAILGUN_MODEL_FPV = "progs/v_nail.mdl";
string MOON_WEAPON_NAILGUN_MODEL_TPV = "progs/g_nail.mdl";
float  MOON_WEAPON_NAILGUN_SALVO_SIZE = 1;
float  MOON_WEAPON_NAILGUN_COOLDOWN = 0.2;
float  MOON_WEAPON_NAILGUN_COST_SHOP = 100;
float  MOON_WEAPON_NAILGUN_COST_MARKET = 70;
float  MOON_WEAPON_NAILGUN_AMMO_SHOP = 30;
float  MOON_WEAPON_NAILGUN_AMMO_MARKET = 30;
float  MOON_WEAPON_NAILGUN_AMMO_LOOT_MIN = 25;
float  MOON_WEAPON_NAILGUN_AMMO_LOOT_RANDOM = 25;
float MOON_WEAPON_SUPERNAILGUN_CODE = 8; // IT_SUPER_NAILGUN
string MOON_WEAPON_SUPERNAILGUN_DISPLAYNAME = "Super Nailgun";
string MOON_WEAPON_SUPERNAILGUN_MARKET_DISPLAYNAME = "Inferior Super Nailgun";
string MOON_WEAPON_SUPERNAILGUN_SHORTNAME = "sNail";
string MOON_WEAPON_SUPERNAILGUN_MODEL_FPV = "progs/v_nail2.mdl";
string MOON_WEAPON_SUPERNAILGUN_MODEL_TPV = "progs/g_nail2.mdl";
float  MOON_WEAPON_SUPERNAILGUN_SALVO_SIZE = 2;
float  MOON_WEAPON_SUPERNAILGUN_COOLDOWN = 0.2;
float  MOON_WEAPON_SUPERNAILGUN_COST_SHOP = 150;
float  MOON_WEAPON_SUPERNAILGUN_COST_MARKET = 100;
float  MOON_WEAPON_SUPERNAILGUN_AMMO_SHOP = 40;	// was 30 now 40
float  MOON_WEAPON_SUPERNAILGUN_AMMO_MARKET = 30;
float  MOON_WEAPON_SUPERNAILGUN_AMMO_LOOT_MIN = 25;
float  MOON_WEAPON_SUPERNAILGUN_AMMO_LOOT_RANDOM = 25;

float MOON_WEAPON_GRENADELAUNCHER_CODE = 16; // IT_GRENADE_LAUNCHER
string MOON_WEAPON_GRENADELAUNCHER_DISPLAYNAME = "Grenade Launcher";
string MOON_WEAPON_GRENADELAUNCHER_MARKET_DISPLAYNAME = "Inferior Grenade Launcher";
string MOON_WEAPON_GRENADELAUNCHER_SHORTNAME = "GL";
string MOON_WEAPON_GRENADELAUNCHER_MODEL_FPV = "progs/v_rock.mdl";
string MOON_WEAPON_GRENADELAUNCHER_MODEL_TPV = "progs/g_rock.mdl";
float  MOON_WEAPON_GRENADELAUNCHER_SALVO_SIZE = 1;
float  MOON_WEAPON_GRENADELAUNCHER_COOLDOWN = 0.6;
float  MOON_WEAPON_GRENADELAUNCHER_COST_SHOP = 250;
float  MOON_WEAPON_GRENADELAUNCHER_COST_MARKET = 150;
float  MOON_WEAPON_GRENADELAUNCHER_AMMO_SHOP = 10;	// was 5 now 10
float  MOON_WEAPON_GRENADELAUNCHER_AMMO_MARKET = 5;
float  MOON_WEAPON_GRENADELAUNCHER_AMMO_LOOT_MIN = 5;
float  MOON_WEAPON_GRENADELAUNCHER_AMMO_LOOT_RANDOM = 10; // was 5 now 10
float MOON_WEAPON_ROCKETLAUNCHER_CODE = 32; // IT_ROCKET_LAUNCHER
string MOON_WEAPON_ROCKETLAUNCHER_DISPLAYNAME = "Rocket Launcher";
string MOON_WEAPON_ROCKETLAUNCHER_MARKET_DISPLAYNAME = "Inferior Rocket Launcher";
string MOON_WEAPON_ROCKETLAUNCHER_SHORTNAME = "RL";
string MOON_WEAPON_ROCKETLAUNCHER_MODEL_FPV = "progs/v_rock2.mdl";
string MOON_WEAPON_ROCKETLAUNCHER_MODEL_TPV = "progs/g_rock2.mdl";
float  MOON_WEAPON_ROCKETLAUNCHER_SALVO_SIZE = 1;
float  MOON_WEAPON_ROCKETLAUNCHER_COOLDOWN = 0.8;
float  MOON_WEAPON_ROCKETLAUNCHER_COST_SHOP = 350;
float  MOON_WEAPON_ROCKETLAUNCHER_COST_MARKET = 250;
float  MOON_WEAPON_ROCKETLAUNCHER_AMMO_SHOP = 5;
float  MOON_WEAPON_ROCKETLAUNCHER_AMMO_MARKET = 5;
float  MOON_WEAPON_ROCKETLAUNCHER_AMMO_LOOT_MIN = 5;
float  MOON_WEAPON_ROCKETLAUNCHER_AMMO_LOOT_RANDOM = 5;

float MOON_WEAPON_LIGHTNING_CODE = 64; // IT_LIGHTNING
string MOON_WEAPON_LIGHTNING_DISPLAYNAME = "Thunderbolt";
string MOON_WEAPON_LIGHTNING_MARKET_DISPLAYNAME = "Inferior Thunderbolt";
string MOON_WEAPON_LIGHTNING_SHORTNAME = "Shaft";
string MOON_WEAPON_LIGHTNING_MODEL_FPV = "progs/v_light.mdl";
string MOON_WEAPON_LIGHTNING_MODEL_TPV = "progs/g_light.mdl";
float  MOON_WEAPON_LIGHTNING_SALVO_SIZE = 1;
float  MOON_WEAPON_LIGHTNING_COOLDOWN = 0.1;
float  MOON_WEAPON_LIGHTNING_COST_SHOP = 500;
float  MOON_WEAPON_LIGHTNING_COST_MARKET = 400;
float  MOON_WEAPON_LIGHTNING_AMMO_SHOP = 12;
float  MOON_WEAPON_LIGHTNING_AMMO_MARKET = 12;
float  MOON_WEAPON_LIGHTNING_AMMO_LOOT_MIN = 10;
float  MOON_WEAPON_LIGHTNING_AMMO_LOOT_RANDOM = 5;

// Additional weapons from different Packs?
//
//

// MOON_ITEM_ELIXIR -> MOON_ELIXIR
string MOON_ELIXIR_CLASSNAME = "elixir";	// Unused? goody_ent?
string MOON_ELIXIR_MARKET_NETNAME = "goody_elixir";
float MOON_ELIXIR_STR_CODE = 1;
float MOON_ELIXIR_STR_VALUE 	= 1;
float MOON_ELIXIR_STR_COST_BASE 	= 2000;
string MOON_ELIXIR_STR_NETNAME 	= "elixir of STRANGE (+1 to Strength)";
string MOON_ELIXIR_STR_NAME 	= "elixir of STRANGE (+1 to Strength)";
float MOON_ELIXIR_VIT_CODE = 2;
float MOON_ELIXIR_VIT_VALUE 	= 1;
float MOON_ELIXIR_VIT_COST_BASE 	= 1500;
string MOON_ELIXIR_VIT_NETNAME 	= "elixir of VITALIKI (+1 to Vitality)";
string MOON_ELIXIR_VIT_NAME 	= "elixir of VITALIKI (+1 to Vitality)";
float MOON_ELIXIR_MAG_CODE = 3;		// Not finished
float MOON_ELIXIR_MAG_VALUE 	= 1;
float MOON_ELIXIR_MAG_COST_BASE 	= 1000;
string MOON_ELIXIR_MAG_NETNAME 	= "elixir of MAGGI (+1 to Sanity)";
string MOON_ELIXIR_MAG_NAME 	= "elixir of MAGGI (+1 to Sanity)";
float MOON_ELIXIR_INT_CODE = 4;		// Not finished
float MOON_ELIXIR_INT_VALUE 	= 1;
float MOON_ELIXIR_INT_COST_BASE 	= 500;
string MOON_ELIXIR_INT_NETNAME 	= "elixir of INTEL (+1 to Intuition)";
string MOON_ELIXIR_INT_NAME 	= "elixir of INTEL (+1 to Intuition)";

// MOON_ITEM_MENTAT -> MOON_MENTAT
string MOON_MENTAT_CLASSNAME = "mentat";
float MOON_MENTAT_OFFENSE_CODE = 1;
float MOON_MENTAT_OFFENSE_VALUE = 20;
string MOON_MENTAT_OFFENSE_NETNAME = "offensive drug";
string MOON_MENTAT_OFFENSE_NAME = "offensive drug";

float MOON_MENTAT_DEFENSE_CODE = 2;
float MOON_MENTAT_DEFENSE_VALUE = 20;
string MOON_MENTAT_DEFENSE_NETNAME = "defensive drug";
string MOON_MENTAT_DEFENSE_NAME = "defensive drug";

float MOON_MENTAT_SPEED_CODE = 3; // TODO: change this mentat to Player speed, not weapon
float MOON_MENTAT_SPEED_VALUE_AXE  = 0.5;               // attack cooldown multiplier, was 0.7
float MOON_MENTAT_SPEED_VALUE_SHOTGUN  = 0.7;           // attack cooldown multiplier
float MOON_MENTAT_SPEED_VALUE_SUPERSHOTGUN  = 0.785;    // attack cooldown multiplier
float MOON_MENTAT_SPEED_VALUE_NAILGUN  = 500;           // additional projectile speed
float MOON_MENTAT_SPEED_VALUE_GRENADELAUNCHER = 0.75;   // attack cooldown multiplier
float MOON_MENTAT_SPEED_VALUE_ROCKETLAUNCHER = 0.8125;  // attack cooldown multiplier
float MOON_MENTAT_SPEED_VALUE_LIGHTNING  = 200;         // additional ray trace distance
string MOON_MENTAT_SPEED_NETNAME = "accelerative drug";
string MOON_MENTAT_SPEED_NAME = "accelerative drug";

// // MAGIC ITEMS and EFFECTS //
string MOON_ITEM_MAGIC_CLASSNAME = "magicitem";

string MOON_ITEM_ARMOR_NETNAME = "armour";
string MOON_ITEM_ARMOR_DISPLAY = "armour";
string MOON_ITEM_ARMOR_DISPLAY_LONG = "Magical Armour";

string MOON_ITEM_RING_NETNAME = "ring";
string MOON_ITEM_RING_DISPLAY = "ring";
string MOON_ITEM_RING_DISPLAY_LONG = "Magical Ring";

float MOON_ITEM_MARKET_COST_BASE = 1;
// // list of Magical Effects, _CODE's should be in strict increasing order without gaps
float MOON_ITEM_NO_CODE = 0;

// Each effect can be used as Prefix and Postfix
//  in general Prefixes (of same effect and rarity) are more reliable (smaller range)
//  while Postfixes are more random (bigger range)
// Each effect has 4 rarity levels: LOW, NORMAL, HIGH, EPIC
// In normal situation, items will not have Postfix of EPIC rarity
//  instead, EPIC Postfix is a sign of UNIQUE item with advanced properties, that also can only be generated once in playthrough
// Each rarity level has effect value range [FROM, TO]
//  these ranges are not disjoint, so higher roll LOW can have same or little better value as lower roll NORMAL item
// Some effects may be missing one or more rarity levels in original mod. That is to be eventually filled
float MOON_ITEM_TRAIT_MIN_EFFECT        = 1;
//
float MOON_ITEM_HEALTH_CODE = 1;
float MOON_ITEM_HEALTH_MARKET_COST_SCALE = 22; // was 45. Purpose of change: overall bonus values raised for all levels, to just keep items a competetive choice, hence need to lower price scaling
string MOON_ITEM_HEALTH_EFFECT  	= "+{} to maximum health";
string MOON_ITEM_HEALTH_PREFIX_LOW   	= "Echidna ";
float MOON_ITEM_HEALTH_PREFIX_LOW_FROM = 16;    // was 12
float MOON_ITEM_HEALTH_PREFIX_LOW_TO = 32;      // was 25
string MOON_ITEM_HEALTH_PREFIX_NORMAL  	= "Viper ";
float MOON_ITEM_HEALTH_PREFIX_NORMAL_FROM = 30; // was 24
float MOON_ITEM_HEALTH_PREFIX_NORMAL_TO = 55;   // was 50
string MOON_ITEM_HEALTH_PREFIX_HIGH  	= "Razor ";
float MOON_ITEM_HEALTH_PREFIX_HIGH_FROM = 54;   // was 45
float MOON_ITEM_HEALTH_PREFIX_HIGH_TO = 72;
string MOON_ITEM_HEALTH_PREFIX_EPIC  	= "Doom ";
float MOON_ITEM_HEALTH_PREFIX_EPIC_FROM = 70;   // was 72
float MOON_ITEM_HEALTH_PREFIX_EPIC_TO = 100;    // was 101
string MOON_ITEM_HEALTH_POSTFIX_LOW  	= " of Life";
float MOON_ITEM_HEALTH_POSTFIX_LOW_FROM = 10;   // was 14
float MOON_ITEM_HEALTH_POSTFIX_LOW_TO = 38;     // was 32
string MOON_ITEM_HEALTH_POSTFIX_NORMAL 	= " of Health";
float MOON_ITEM_HEALTH_POSTFIX_NORMAL_FROM = 36;// was 28
float MOON_ITEM_HEALTH_POSTFIX_NORMAL_TO = 64;  // was 54
string MOON_ITEM_HEALTH_POSTFIX_HIGH    = " of Fortitude";
float MOON_ITEM_HEALTH_POSTFIX_HIGH_FROM = 60;  // was 50
float MOON_ITEM_HEALTH_POSTFIX_HIGH_TO = 90;    // was 80

float MOON_ITEM_DAMAGE_CODE = 2;
float MOON_ITEM_DAMAGE_MARKET_COST_SCALE = 50;
string MOON_ITEM_DAMAGE_EFFECT 		= "{}% damage amplify";
string MOON_ITEM_DAMAGE_PREFIX_LOW   	= "Brutal ";
float MOON_ITEM_DAMAGE_PREFIX_LOW_FROM = 8; // was 5
float MOON_ITEM_DAMAGE_PREFIX_LOW_TO = 24; // was 25
string MOON_ITEM_DAMAGE_PREFIX_NORMAL  	= "Battle ";
float MOON_ITEM_DAMAGE_PREFIX_NORMAL_FROM = 20;
float MOON_ITEM_DAMAGE_PREFIX_NORMAL_TO = 32;
string MOON_ITEM_DAMAGE_PREFIX_HIGH   	= "Demonic ";
float MOON_ITEM_DAMAGE_PREFIX_HIGH_FROM = 32;
float MOON_ITEM_DAMAGE_PREFIX_HIGH_TO = 40;
string MOON_ITEM_DAMAGE_PREFIX_EPIC   	= "Abyssal "; // new
float MOON_ITEM_DAMAGE_PREFIX_EPIC_FROM = 38;
float MOON_ITEM_DAMAGE_PREFIX_EPIC_TO = 48;
string MOON_ITEM_DAMAGE_POSTFIX_LOW		= " of Carnage";
float MOON_ITEM_DAMAGE_POSTFIX_LOW_FROM = 6;    // was 5
float MOON_ITEM_DAMAGE_POSTFIX_LOW_TO = 22;     // was 26
string MOON_ITEM_DAMAGE_POSTFIX_NORMAL 	= " of Violence";
float MOON_ITEM_DAMAGE_POSTFIX_NORMAL_FROM = 20;// was 25
float MOON_ITEM_DAMAGE_POSTFIX_NORMAL_TO = 35;  // was 51
string MOON_ITEM_DAMAGE_POSTFIX_HIGH 	= " of the Battlemaster";
float MOON_ITEM_DAMAGE_POSTFIX_HIGH_FROM = 32;  // was 50
float MOON_ITEM_DAMAGE_POSTFIX_HIGH_TO = 44;    // was 101

float MOON_ITEM_GOLD_CODE = 3;
float MOON_ITEM_GOLD_MARKET_COST_SCALE = 7; // was 25. Purpose of change is to make such items on marketplace a "farm guns" - cheap, giving extra gold, but no combat benefits - perfect for early game
string MOON_ITEM_GOLD_EFFECT	 	= "{}% extra gold from monsters";
string MOON_ITEM_GOLD_PREFIX_LOW   		= "Lunacy ";
float MOON_ITEM_GOLD_PREFIX_LOW_FROM = 20;
float MOON_ITEM_GOLD_PREFIX_LOW_TO = 42;
string MOON_ITEM_GOLD_PREFIX_NORMAL  	= "Fanatic ";
float MOON_ITEM_GOLD_PREFIX_NORMAL_FROM = 40;
float MOON_ITEM_GOLD_PREFIX_NORMAL_TO = 64;
string MOON_ITEM_GOLD_PREFIX_HIGH   	= "Golden ";
float MOON_ITEM_GOLD_PREFIX_HIGH_FROM = 60;
float MOON_ITEM_GOLD_PREFIX_HIGH_TO = 78;
string MOON_ITEM_GOLD_PREFIX_EPIC   	= "Brilliant "; // new
float MOON_ITEM_GOLD_PREFIX_EPIC_FROM = 75;
float MOON_ITEM_GOLD_PREFIX_EPIC_TO = 90;
string MOON_ITEM_GOLD_POSTFIX_LOW		= " of Greed";
float MOON_ITEM_GOLD_POSTFIX_LOW_FROM = 18;
float MOON_ITEM_GOLD_POSTFIX_LOW_TO = 36;
string MOON_ITEM_GOLD_POSTFIX_NORMAL 	= " of Treasure";
float MOON_ITEM_GOLD_POSTFIX_NORMAL_FROM = 35;
float MOON_ITEM_GOLD_POSTFIX_NORMAL_TO = 50;
string MOON_ITEM_GOLD_POSTFIX_HIGH      = " of Midas";
float MOON_ITEM_GOLD_POSTFIX_HIGH_FROM = 48;
float MOON_ITEM_GOLD_POSTFIX_HIGH_TO = 64;

float MOON_ITEM_RESIST_CODE = 4;
float MOON_ITEM_RESIST_MARKET_COST_SCALE = 65;
string MOON_ITEM_RESIST_EFFECT  	= "reduce damage received by {}%";
string MOON_ITEM_RESIST_PREFIX_LOW   	= "Halo ";
float MOON_ITEM_RESIST_PREFIX_LOW_FROM = 4; // was 1
float MOON_ITEM_RESIST_PREFIX_LOW_TO = 12;  // was 10
string MOON_ITEM_RESIST_PREFIX_NORMAL  	= "Blessed ";
float MOON_ITEM_RESIST_PREFIX_NORMAL_FROM = 10;
float MOON_ITEM_RESIST_PREFIX_NORMAL_TO = 19;
string MOON_ITEM_RESIST_PREFIX_HIGH   	= "Stone ";
float MOON_ITEM_RESIST_PREFIX_HIGH_FROM = 20;
float MOON_ITEM_RESIST_PREFIX_HIGH_TO = 26;
string MOON_ITEM_RESIST_PREFIX_EPIC   	= "Dragonskin ";
float MOON_ITEM_RESIST_PREFIX_EPIC_CODE = 24;
float MOON_ITEM_RESIST_PREFIX_EPIC_FROM = 25;
float MOON_ITEM_RESIST_PREFIX_EPIC_TO = 31;
string MOON_ITEM_RESIST_POSTFIX_LOW		= " of Resistance";
float MOON_ITEM_RESIST_POSTFIX_LOW_FROM = 3;
float MOON_ITEM_RESIST_POSTFIX_LOW_TO = 9;
string MOON_ITEM_RESIST_POSTFIX_NORMAL 	= " of Protection";
float MOON_ITEM_RESIST_POSTFIX_NORMAL_FROM = 10;
float MOON_ITEM_RESIST_POSTFIX_NORMAL_TO = 20;
string MOON_ITEM_RESIST_POSTFIX_HIGH 	= " of Reduction";
float MOON_ITEM_RESIST_POSTFIX_HIGH_FROM = 20;
float MOON_ITEM_RESIST_POSTFIX_HIGH_TO = 30;

float MOON_ITEM_RETALATE_CODE = 5;
float MOON_ITEM_RETALATE_MARKET_COST_SCALE = 20;
string MOON_ITEM_RETALATE_EFFECT 	= "attacker takes {}% of damage caused";
string MOON_ITEM_RETALATE_PREFIX_LOW   	= "Dread ";
float MOON_ITEM_RETALATE_PREFIX_LOW_FROM = 10;  // was 3
float MOON_ITEM_RETALATE_PREFIX_LOW_TO = 21;    // was 11
string MOON_ITEM_RETALATE_PREFIX_NORMAL = "Insane ";
float MOON_ITEM_RETALATE_PREFIX_NORMAL_FROM = 20;   // was 10
float MOON_ITEM_RETALATE_PREFIX_NORMAL_TO = 32;     // was 17
string MOON_ITEM_RETALATE_PREFIX_HIGH   = "Forbidden "; // new word
float MOON_ITEM_RETALATE_PREFIX_HIGH_FROM = 30;     // was 20
float MOON_ITEM_RETALATE_PREFIX_HIGH_TO = 50;       // was 41
string MOON_ITEM_RETALATE_PREFIX_EPIC   = "Mirror "; // new values
float MOON_ITEM_RETALATE_PREFIX_EPIC_FROM = 48;
float MOON_ITEM_RETALATE_PREFIX_EPIC_TO = 72;
string MOON_ITEM_RETALATE_POSTFIX_LOW	= " of Tenons";
float MOON_ITEM_RETALATE_POSTFIX_LOW_FROM = 8;      // was 5
float MOON_ITEM_RETALATE_POSTFIX_LOW_TO = 24;       // was 11
string MOON_ITEM_RETALATE_POSTFIX_NORMAL= " of Ruffs";
float MOON_ITEM_RETALATE_POSTFIX_NORMAL_FROM = 22;  // was 10
float MOON_ITEM_RETALATE_POSTFIX_NORMAL_TO = 38;    // was 21
string MOON_ITEM_RETALATE_POSTFIX_HIGH  = " of Revenge"; // new
float MOON_ITEM_RETALATE_POSTFIX_HIGH_FROM = 36;
float MOON_ITEM_RETALATE_POSTFIX_HIGH_TO = 64;

float MOON_ITEM_VAMPIR_CODE = 6;
float MOON_ITEM_VAMPIR_MARKET_COST_SCALE = 70;
string MOON_ITEM_VAMPIR_EFFECT 		= "{}% your damage converts to life";
string MOON_ITEM_VAMPIR_PREFIX_LOW   	= "Flesh ";
float MOON_ITEM_VAMPIR_PREFIX_LOW_FROM = 3;
float MOON_ITEM_VAMPIR_PREFIX_LOW_TO = 9;
string MOON_ITEM_VAMPIR_PREFIX_NORMAL  	= "Blood ";
float MOON_ITEM_VAMPIR_PREFIX_NORMAL_FROM = 8;
float MOON_ITEM_VAMPIR_PREFIX_NORMAL_TO = 16;
string MOON_ITEM_VAMPIR_PREFIX_HIGH   	= "Darkmage ";
float MOON_ITEM_VAMPIR_PREFIX_HIGH_FROM = 16;
float MOON_ITEM_VAMPIR_PREFIX_HIGH_TO = 26;
string MOON_ITEM_VAMPIR_PREFIX_EPIC   	= "Chthonic "; // new
float MOON_ITEM_VAMPIR_PREFIX_EPIC_FROM = 24;
float MOON_ITEM_VAMPIR_PREFIX_EPIC_TO = 36;
string MOON_ITEM_VAMPIR_POSTFIX_LOW		= " of the Leech";
float MOON_ITEM_VAMPIR_POSTFIX_LOW_FROM = 2;
float MOON_ITEM_VAMPIR_POSTFIX_LOW_TO = 10;
string MOON_ITEM_VAMPIR_POSTFIX_NORMAL  = " of Forgotten Ones"; // new
float MOON_ITEM_VAMPIR_POSTFIX_NORMAL_FROM = 9;
float MOON_ITEM_VAMPIR_POSTFIX_NORMAL_TO = 18;
string MOON_ITEM_VAMPIR_POSTFIX_HIGH    = " of Ancient Ones"; // new
float MOON_ITEM_VAMPIR_POSTFIX_HIGH_FROM = 16;
float MOON_ITEM_VAMPIR_POSTFIX_HIGH_TO = 27;

float MOON_ITEM_REGEN_CODE = 7;
float MOON_ITEM_REGEN_MARKET_COST_SCALE = 500;
float MOON_ITEM_REGEN_COOLDOWN = 1; // in seconds
string MOON_ITEM_REGEN_EFFECT  		= "replenish {} health every second";
string MOON_ITEM_REGEN_PREFIX_LOW   	= "Vein ";
float MOON_ITEM_REGEN_PREFIX_LOW_FROM = 1;
float MOON_ITEM_REGEN_PREFIX_LOW_TO = 3;
string MOON_ITEM_REGEN_PREFIX_NORMAL   	= "Great Vein ";
float MOON_ITEM_REGEN_PREFIX_NORMAL_FROM = 3;
float MOON_ITEM_REGEN_PREFIX_NORMAL_TO = 5;
string MOON_ITEM_REGEN_PREFIX_HIGH   	= "Hell's Vein ";
float MOON_ITEM_REGEN_PREFIX_HIGH_FROM = 5;
float MOON_ITEM_REGEN_PREFIX_HIGH_TO = 7;
string MOON_ITEM_REGEN_PREFIX_EPIC   	= "Magenta "; // enta Mage
float MOON_ITEM_REGEN_PREFIX_EPIC_FROM = 7;
float MOON_ITEM_REGEN_PREFIX_EPIC_TO = 9;
string MOON_ITEM_REGEN_POSTFIX_LOW		= " of Regeneration";
float MOON_ITEM_REGEN_POSTFIX_LOW_FROM = 1;
float MOON_ITEM_REGEN_POSTFIX_LOW_TO = 3;
string MOON_ITEM_REGEN_POSTFIX_NORMAL 	= " of Reshape";
float MOON_ITEM_REGEN_POSTFIX_NORMAL_FROM = 3;
float MOON_ITEM_REGEN_POSTFIX_NORMAL_TO = 5;
string MOON_ITEM_REGEN_POSTFIX_HIGH    = " of Revival"; // new
float MOON_ITEM_REGEN_POSTFIX_HIGH_FROM = 5;
float MOON_ITEM_REGEN_POSTFIX_HIGH_TO = 8;

float MOON_ITEM_CONSUME_CODE = 8;
float MOON_ITEM_CONSUME_MARKET_COST_SCALE = 100;
string MOON_ITEM_CONSUME_EFFECT		= "adds {} health after each kill";
string MOON_ITEM_CONSUME_PREFIX_LOW   	= "Brash ";
float MOON_ITEM_CONSUME_PREFIX_LOW_FROM = 2;    // was 1
float MOON_ITEM_CONSUME_PREFIX_LOW_TO = 10;     // was 6
string MOON_ITEM_CONSUME_PREFIX_NORMAL	= "Heavenly ";
float MOON_ITEM_CONSUME_PREFIX_NORMAL_FROM = 8; // was 6
float MOON_ITEM_CONSUME_PREFIX_NORMAL_TO = 14;  // was 13
string MOON_ITEM_CONSUME_PREFIX_HIGH   	= "Celestial ";
float MOON_ITEM_CONSUME_PREFIX_HIGH_FROM = 12;  // was 15
float MOON_ITEM_CONSUME_PREFIX_HIGH_TO = 20;
string MOON_ITEM_CONSUME_PREFIX_EPIC   	= "Spirit ";
float MOON_ITEM_CONSUME_PREFIX_EPIC_FROM = 20;
float MOON_ITEM_CONSUME_PREFIX_EPIC_TO = 32;
string MOON_ITEM_CONSUME_POSTFIX_LOW	= " of the Ghost";
float MOON_ITEM_CONSUME_POSTFIX_LOW_FROM = 1;   // was 2
float MOON_ITEM_CONSUME_POSTFIX_LOW_TO = 10;    // was 6
string MOON_ITEM_CONSUME_POSTFIX_NORMAL = " of the Wraith";
float MOON_ITEM_CONSUME_POSTFIX_NORMAL_FROM = 9;// was 6
float MOON_ITEM_CONSUME_POSTFIX_NORMAL_TO = 18; // was 13
string MOON_ITEM_CONSUME_POSTFIX_HIGH   = " of Edem"; // new
float MOON_ITEM_CONSUME_POSTFIX_HIGH_FROM = 18;
float MOON_ITEM_CONSUME_POSTFIX_HIGH_TO = 25;

// New effects addded after 0.21 beta:
float MOON_ITEM_REPAIR_CODE = 9;
float MOON_ITEM_REPAIR_MARKET_COST_SCALE = 50;
float MOON_ITEM_REPAIR_DELAY = 5.0; // after last damage to start repair, in seconds
float MOON_ITEM_REPAIR_VALUE = 3;   // repair increment
float MOON_ITEM_REPAIR_COOLDOWN = 1.0; // between repairs, in seconds
string MOON_ITEM_REPAIR_EFFECT		= "slowly repair armor up to {}";
string MOON_ITEM_REPAIR_PREFIX_LOW   	= "Durable ";
float MOON_ITEM_REPAIR_PREFIX_LOW_FROM = 5;
float MOON_ITEM_REPAIR_PREFIX_LOW_TO = 11; // last and first overlap intentionally
string MOON_ITEM_REPAIR_PREFIX_NORMAL	= "Selfmaintaing ";
float MOON_ITEM_REPAIR_PREFIX_NORMAL_FROM = 10;
float MOON_ITEM_REPAIR_PREFIX_NORMAL_TO = 21;
string MOON_ITEM_REPAIR_PREFIX_HIGH	    = "Blue-Taped ";
float MOON_ITEM_REPAIR_PREFIX_HIGH_FROM = 20;
float MOON_ITEM_REPAIR_PREFIX_HIGH_TO = 30;
string MOON_ITEM_REPAIR_PREFIX_EPIC	    = "Nanofiber ";
float MOON_ITEM_REPAIR_PREFIX_EPIC_FROM = 30;
float MOON_ITEM_REPAIR_PREFIX_EPIC_TO = 60;
string MOON_ITEM_REPAIR_POSTFIX_LOW		= " of the Engineer";
float MOON_ITEM_REPAIR_POSTFIX_LOW_FROM = 5;
float MOON_ITEM_REPAIR_POSTFIX_LOW_TO = 15;
string MOON_ITEM_REPAIR_POSTFIX_NORMAL 	= " of Complex Design";
float MOON_ITEM_REPAIR_POSTFIX_NORMAL_FROM = 15;
float MOON_ITEM_REPAIR_POSTFIX_NORMAL_TO = 30;
string MOON_ITEM_REPAIR_POSTFIX_HIGH 	= " of Forgotten Technology";
float MOON_ITEM_REPAIR_POSTFIX_HIGH_FROM = 30;
float MOON_ITEM_REPAIR_POSTFIX_HIGH_TO = 40;

float MOON_ITEM_RECHARGE_CODE = 10;
float MOON_ITEM_RECHARGE_MARKET_COST_SCALE = 250;
float MOON_ITEM_RECHARGE_DELAY = 5.0; // after last use to start recharge, in seconds
float MOON_ITEM_RECHARGE_VALUE = 1;   // charge increment
float MOON_ITEM_RECHARGE_COOLDOWN = 1.0; // between charges, in seconds
string MOON_ITEM_RECHARGE_EFFECT		= "slowly charge cells up to {}";
string MOON_ITEM_RECHARGE_PREFIX_LOW   	= "Absorbing ";
float MOON_ITEM_RECHARGE_PREFIX_LOW_FROM = 1;
float MOON_ITEM_RECHARGE_PREFIX_LOW_TO = 5; // last and first overlap intentionally
string MOON_ITEM_RECHARGE_PREFIX_NORMAL	= "Accumulating ";
float MOON_ITEM_RECHARGE_PREFIX_NORMAL_FROM = 4;
float MOON_ITEM_RECHARGE_PREFIX_NORMAL_TO = 8;
string MOON_ITEM_RECHARGE_PREFIX_HIGH	    = "Kinetic ";
float MOON_ITEM_RECHARGE_PREFIX_HIGH_FROM = 7;
float MOON_ITEM_RECHARGE_PREFIX_HIGH_TO = 11;
string MOON_ITEM_RECHARGE_PREFIX_EPIC	    = "Empowering ";
float MOON_ITEM_RECHARGE_PREFIX_EPIC_FROM = 10;
float MOON_ITEM_RECHARGE_PREFIX_EPIC_TO = 15;
string MOON_ITEM_RECHARGE_POSTFIX_LOW		= " of the Engineer";
float MOON_ITEM_RECHARGE_POSTFIX_LOW_FROM = 1;
float MOON_ITEM_RECHARGE_POSTFIX_LOW_TO = 6;
string MOON_ITEM_RECHARGE_POSTFIX_NORMAL 	= " of Complex Design";
float MOON_ITEM_RECHARGE_POSTFIX_NORMAL_FROM = 5;
float MOON_ITEM_RECHARGE_POSTFIX_NORMAL_TO = 11;
string MOON_ITEM_RECHARGE_POSTFIX_HIGH 	= " of Forgotten Tech";
float MOON_ITEM_RECHARGE_POSTFIX_HIGH_FROM = 10;
float MOON_ITEM_RECHARGE_POSTFIX_HIGH_TO = 16;
//
float MOON_ITEM_TRAIT_MAX_EFFECT        = 10;
// // last Effect's _CODE should not be greater than MOON_ITEM_TRAIT_MAX_EFFECT

// // list of Upgrades
// These things cannot and should be attached to Items, hence new Code sequence.
// Global - Castle - One continuous code span
float MOON_ITEM_GLOBALGOLD_CODE = 11;
float MOON_ITEM_GLOBALGOLD_BONUS_FLAT 	= 5;
float MOON_ITEM_GLOBALGOLD_BONUS_LVLPERCENT = 0.5;
float MOON_ITEM_GLOBALGOLD_BONUS_RANDOM = 7;
string MOON_ITEM_GLOBALGOLD_EFFECT 		= "Book of Treasures (global gold income increase by {}%)\n";
float MOON_ITEM_GATEALERT_CODE = 12;
string MOON_ITEM_GATEALERT_EFFECT  		= "Book of \sRed\s Alert (gate gives a signal when killed)\n";
string MOON_ITEM_GATEALERT_SIDEEFFECT 	= "Book of \sRed\s Gate (+10 max health to Gate)\n";
float MOON_ITEM_GATEALERT_SIDEEFFECT_BONUS = 10;
float MOON_ITEM_HEART_CODE = 13;
float MOON_ITEM_HEART_BONUS_FLAT 		= 5;
float MOON_ITEM_HEART_BONUS_LVLPERCENT 	= 0.25;
float MOON_ITEM_HEART_BONUS_RANDOM 		= 5;
string MOON_ITEM_HEART_EFFECT 			= "Book of Immortality (\sHeart\s life increased by {})\n";
float MOON_ITEM_GUARDIAN_CODE = 14;
string MOON_ITEM_GUARDIAN_EFFECT 		= "Book of Blind Guardian (guardian joins your army)\n";
// Personal - Ammo/Weapons - One continuous code span
float MOON_ITEM_MELEEUP_CODE = 1;
string MOON_ITEM_MELEEUP_EFFECT 		= "Book of Bruce Lee (your axe cripples)\n";
string MOON_ITEM_MELEEUP_SIDEEFFECT 	= "Book of Me Lee (+5 melee damage)\n";
float MOON_ITEM_MELEEUP_SIDEEFFECT_BONUS= 5;
float MOON_ITEM_SHELLUP_CODE = 2;
string MOON_ITEM_SHELLUP_EFFECT 		= "Book of Shell Shock (your shell attack now stronger and more concentrated)\n";
string MOON_ITEM_SHELLUP_SIDEEFFECT 	= "Book of PowerShell (+10 max shell capacity)\n";
float MOON_ITEM_SHELLUP_SIDEEFFECT_BONUS= 10;
float MOON_ITEM_NAILUP_CODE = 3;
string MOON_ITEM_NAILUP_EFFECT 			= "Book of Nail Polish (your nails attack now faster)\n";
string MOON_ITEM_NAILUP_SIDEEFFECT 		= "9 Inch Book of Nails (+20 max nail capacity)\n";
float MOON_ITEM_NAILUP_EFFECT_BONUS     = 500;
float MOON_ITEM_NAILUP_SIDEEFFECT_BONUS = 20;
float MOON_ITEM_ROCKUP_CODE = 4;
string MOON_ITEM_ROCKUP_EFFECT 			= "Book of Miss Silo (your launchers launch faster)\n";
string MOON_ITEM_ROCKUP_SIDEEFFECT 		= "Book of Miss Silo V2 (+1 max rocket capacity)\n";
float MOON_ITEM_ROCKUP_EFFECT_BONUS = 0.7;
float MOON_ITEM_ROCKUP_SIDEEFFECT_BONUS = 1;
float MOON_ITEM_CELLUP_CODE = 5;
string MOON_ITEM_CELLUP_EFFECT 			= "Book of Chain Lightning (your lightning jumps twice)\n";
string MOON_ITEM_CELLUP_SIDEEFFECT 		= "Book of Dura Cell (+2 max cell capacity)\n";
float MOON_ITEM_CELLUP_EFFECT_CHAIN_DISTANCE = 512; // PoT, max distance to next target
float MOON_ITEM_CELLUP_EFFECT_CHAIN_JUMPS = 2; // max number of jumps
float MOON_ITEM_CELLUP_EFFECT_CHAIN_COOLDOWN = 0.01; // should be small enough, to allow continued firing, but non-zero, so lightning non bouncing between 2 same targets
float MOON_ITEM_CELLUP_SIDEEFFECT_BONUS = 2;
float MOON_ITEM_STATUP_CODE = 6;
float MOON_ITEM_STATUP_BONUS 			= 5;
string MOON_ITEM_STATUP_EFFECT 			= "Book of High Five (you get \5 stats points)\n";
// // end of list of Upgrades

// // Monster related consts
string MOON_MONSTER_CLASSNAME = "monster";

float MOON_MONSTER_FISRTWAVETIME_DELAY		= 30; // for the first wave Host has no chance to use fast/slowmeat
float MOON_MONSTER_FISRTWAVETIME_RANDOM		= 30;
float MOON_MONSTER_WAVETIME_DELAY_FAST   	= 15;
float MOON_MONSTER_WAVETIME_DELAY_NORMAL 	= 30;
float MOON_MONSTER_WAVETIME_DELAY_SLOW   	= 45;
float MOON_MONSTER_WAVETIME_RANDOM_FAST   	= 35;
float MOON_MONSTER_WAVETIME_RANDOM_NORMAL 	= 30;
float MOON_MONSTER_WAVETIME_RANDOM_SLOW   	= 20;
float MOON_MONSTER_CORPSEDECAY_FACTOR   	= 2; // ~how many waves stays corpse

float MOON_MONSTER_CODE_SOLDIER 	= 1;
float MOON_MONSTER_CODE_ENFORCER 	= 2;
float MOON_MONSTER_CODE_SPIDER 		= 3;
float MOON_MONSTER_CODE_OGRE 		= 4;
float MOON_MONSTER_CODE_SNAKE 		= 5;
float MOON_MONSTER_CODE_MAGE 		= 6;
float MOON_MONSTER_CODE_SHALRATH 	= 7;
float MOON_MONSTER_BASELEVEL_SOLDIER 	= 0;
float MOON_MONSTER_BASELEVEL_ENFORCER 	= 1;
float MOON_MONSTER_BASELEVEL_SPIDER 	= 2;
float MOON_MONSTER_BASELEVEL_OGRE 		= 4;
float MOON_MONSTER_BASELEVEL_SNAKE 		= 6;
float MOON_MONSTER_BASELEVEL_MAGE 		= 8;
float MOON_MONSTER_BASELEVEL_SHALRATH 	= 15;

float MOON_MONSTER_BOUNTY_EXP_SPIDER    = 8;

float MOON_MONSTER_BOUNTY_EXP_BAREMINIMUM = 1;
float MOON_MONSTER_BOUNTY_EXP_MULT_LOW = 1.2;
float MOON_MONSTER_BOUNTY_EXP_MULT_NORMAL = 1.5;
float MOON_MONSTER_BOUNTY_EXP_MULT_HIGH = 2.0;
float MOON_MONSTER_BOUNTY_EXP_MULT_HUGE = 4.0;

float MOON_MONSTER_UNIQUE_CHANCE = 0.04;
float MOON_MONSTER_MAGIC_CHANCE = 0.03;

float MOON_MONSTER_TRAIT_NO                 = 0;
// .ability traits
float MOON_MONSTER_TRAIT_QUADDAMAGE         = 1;
float MOON_MONSTER_TRAIT_QUADDAMAGE_SKIN            = 0;
string MOON_MONSTER_TRAIT_QUADDAMAGE_DISPLAY        = "quaded ";
float MOON_MONSTER_TRAIT_IRON               = 2;
float MOON_MONSTER_TRAIT_IRON_SKIN                  = 1;
string MOON_MONSTER_TRAIT_IRON_DISPLAY              = "iron ";
string MOON_MONSTER_TRAIT_IRON_DESCRIPTION          = "takes only {}% damage from each instance";
float MOON_MONSTER_TRAIT_IRON_DAMAGERECEIVED        = 20;
float MOON_MONSTER_TRAIT_STONE              = 3;
float MOON_MONSTER_TRAIT_STONE_SKIN                 = 2;
string MOON_MONSTER_TRAIT_STONE_DISPLAY             = "stone ";
string MOON_MONSTER_TRAIT_STONE_DESCRIPTION         = "50% chance to not take damage";
float MOON_MONSTER_TRAIT_STONE_PROC                 = 0.5;
float MOON_MONSTER_TRAIT_BLOOD              = 4;
float MOON_MONSTER_TRAIT_BLOOD_SKIN                 = 3;
string MOON_MONSTER_TRAIT_BLOOD_DISPLAY             = "blood ";
string MOON_MONSTER_TRAIT_BLOOD_DESCRIPTION         = "heals for 50% of damage";
float MOON_MONSTER_TRAIT_BLOOD_HEALRATIO            = 0.5;
float MOON_MONSTER_TRAIT_FAST               = 5;
string MOON_MONSTER_TRAIT_FAST_DISPLAY              = "fast ";
float MOON_MONSTER_TRAIT_FAST_MOVESPEED             = 450;
float MOON_MONSTER_TRAIT_FAST_MISSILESPEED          = 1800;

// .prefix traits
float MOON_MONSTER_TRAIT_DOUBLEDAMAGE       = 1;
string MOON_MONSTER_TRAIT_DOUBLEDAMAGE_LOW_DISPLAY      = " of slaughter";
float MOON_MONSTER_TRAIT_DOUBLEDAMAGE_LOW_PROC          = 0.2;
string MOON_MONSTER_TRAIT_DOUBLEDAMAGE_NORMAL_DISPLAY   = " of violence";
float MOON_MONSTER_TRAIT_DOUBLEDAMAGE_NORMAL_PROC       = 0.4;
float MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE   = 2;
string MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE_LOW_DISPLAY      = " in snake skin";
float MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE_LOW_PROC          = 0.2;
string MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE_NORMAL_DISPLAY   = " in demon skin";
float MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE_NORMAL_PROC       = 0.5;
string MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE_HUGE_DISPLAY     = " in bear skin";
float MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE_HUGE_PROC         = 1.0;
float MOON_MONSTER_TRAIT_HUNTER             = 3; // Always try to kill player (not implemented)
string MOON_MONSTER_TRAIT_HUNTER_LOW_DISPLAY                = " the warrior";
string MOON_MONSTER_TRAIT_HUNTER_NORMAL_DISPLAY             = " the hunter";
float MOON_MONSTER_TRAIT_REGEN              = 4;
string MOON_MONSTER_TRAIT_REGEN_LOW_DISPLAY                 = " of regeneration";
float MOON_MONSTER_TRAIT_REGEN_LOW_VALUE                    = 3;
string MOON_MONSTER_TRAIT_REGEN_NORMAL_DISPLAY              = " of great reshape";
float MOON_MONSTER_TRAIT_REGEN_NORMAL_VALUE                 = 10;
float MOON_MONSTER_TRAIT_EXTRA_GOLD         = 5;
string MOON_MONSTER_TRAIT_EXTRA_GOLD_LOW_DISPLAY            = " the rich";
float MOON_MONSTER_TRAIT_EXTRA_GOLD_LOW_VALUE               = 200;
string MOON_MONSTER_TRAIT_EXTRA_GOLD_NORMAL_DISPLAY         = " the treasurer";
float MOON_MONSTER_TRAIT_EXTRA_GOLD_NORMAL_VALUE            = 500;
string MOON_MONSTER_TRAIT_EXTRA_GOLD_HIGH_DISPLAY           = " the millioner";
float MOON_MONSTER_TRAIT_EXTRA_GOLD_HIGH_VALUE              = 1000;
float MOON_MONSTER_TRAIT_SUICIDE            = 6;
string MOON_MONSTER_TRAIT_SUICIDE_LOW_DISPLAY               = " the petard";
float MOON_MONSTER_TRAIT_SUICIDE_LOW_VALUE                  = 120;
string MOON_MONSTER_TRAIT_SUICIDE_NORMAL_DISPLAY            = " the bomb";
float MOON_MONSTER_TRAIT_SUICIDE_NORMAL_VALUE               = 240; // was 220
string MOON_MONSTER_TRAIT_SUICIDE_HIGH_DISPLAY              = " the nuclear";
float MOON_MONSTER_TRAIT_SUICIDE_HIGH_VALUE                 = 480; // was 420
float MOON_MONSTER_TRAIT_EXTRA_DAMAGE       = 7;
string MOON_MONSTER_TRAIT_EXTRA_DAMAGE_LOW_DISPLAY      = " the chosen";
float MOON_MONSTER_TRAIT_EXTRA_DAMAGE_LOW_BONUSPERCENT  = 50;
string MOON_MONSTER_TRAIT_EXTRA_DAMAGE_NORMAL_DISPLAY   = " the destroying";
float MOON_MONSTER_TRAIT_EXTRA_DAMAGE_NORMAL_BONUSPERCENT = 100;
string MOON_MONSTER_TRAIT_EXTRA_DAMAGE_HIGH_DISPLAY     = " of humiliation";
float MOON_MONSTER_TRAIT_EXTRA_DAMAGE_HIGH_BONUSPERCENT = 200;
string MOON_MONSTER_TRAIT_EXTRA_DAMAGE_HUGE_DISPLAY     = " of world erasing";
float MOON_MONSTER_TRAIT_EXTRA_DAMAGE_HUGE_BONUSPERCENT = 300;
float MOON_MONSTER_TRAIT_RESISTANCE         = 8;
string MOON_MONSTER_TRAIT_RESISTANCE_LOW_DISPLAY        = " of resistance";
float MOON_MONSTER_TRAIT_RESISTANCE_LOW_BONUSPERCENT    = 30;
string MOON_MONSTER_TRAIT_RESISTANCE_NORMAL_DISPLAY     = " in wood armor";
float MOON_MONSTER_TRAIT_RESISTANCE_NORMAL_BONUSPERCENT = 40;
string MOON_MONSTER_TRAIT_RESISTANCE_HIGH_DISPLAY       = " in bronze armor";
float MOON_MONSTER_TRAIT_RESISTANCE_HIGH_BONUSPERCENT   = 60;
float MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE= 9;
string MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE_LOW_DISPLAY        = " of failure";
float MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE_LOW_BONUSPERCENT    = 30;
string MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE_NORMAL_DISPLAY     = " of receive";
float MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE_NORMAL_BONUSPERCENT = 60;
string MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE_HIGH_DISPLAY       = " of cry";
float MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE_HIGH_BONUSPERCENT   = 90;
float MOON_MONSTER_TRAIT_FRIENDLY_FIRE      = 10;
string MOON_MONSTER_TRAIT_FRIENDLY_FIRE_LOW_DISPLAY     = " the scoundrel";
float MOON_MONSTER_TRAIT_FRIENDLY_FIRE_LOW_MULTIPLIER   = 0.2;

// traits applied on spawn only
float MOON_MONSTER_TRAIT_REDUCED_HEALTH     = 11;
string MOON_MONSTER_TRAIT_REDUCED_HEALTH_DISPLAY        = " of weakness";
float MOON_MONSTER_TRAIT_REDUCED_HEALTH_MULTIPLIER      = 0.5;
float MOON_MONSTER_TRAIT_EXTRA_BOUNTY_EXP   = 12;
string MOON_MONSTER_TRAIT_EXTRA_BOUNTY_EXP_DISPLAY      = " the guru";
float MOON_MONSTER_TRAIT_EXTRA_BOUNTY_EXP_MULTIPLIER    = 1.5;
float MOON_MONSTER_TRAIT_LOWHEALTH          = 13;
string MOON_MONSTER_TRAIT_LOWHEALTH_DISPLAY             = " the misery";
float MOON_MONSTER_TRAIT_LOWHEALTH_VALUE                = 20;

// aura types
float MOON_MONSTER_TRAIT_AURA_TYPE_DOUBLEDAMAGE = 1; // unused
float MOON_MONSTER_TRAIT_AURA_TYPE_EXTRADAMAGE = 2; // unused

// // end of Monster related consts
