// // Copied from https://github.com/fte-team/fteqw/blob/1f9f3635f0aef3b2eed6b40e35fcf6223c6ad533/engine/common/protocol.h#L362
//QuakeEx(aka: rerelease) svcs.
//	these are not really documented anywhere. we're trying to stick with protocol 15 (because that's the only documented protocol it supports properly thanks to demos)
//	however we still need some special case svcs
//  (there's also some problematic c2s differences too)
#define svcqex_updateping			46	// [byte] slot, [signed_qe] ping
#define svcqex_updatesocial			47	// [byte] slot, 8 bytes of unknown
#define svcqex_updateplinfo			48	// [byte] slot, [leb128] health, [leb128] armour
#define svcqex_locprint				49	// uses qe's localised string formatting, otherwise treat as svc_print.
#define svcqex_servervars			50	// [leb128] changedvalues, [???] value...
#define svcqex_seq					51	// [leb128] input sequence ack
#define svcqex_achievement			52	// [string] codename
#define svcqex_chat					53	// [byte] svcqex_chat, [byte] playercolour, [byte] textcolour, [string] playername, [string] chattext // new from FTE
#define svcqex_levelcompleted		54
#define svcqex_backtolobby			55
#define svcqex_localsound			56
#define svcqex_prompt				57
#define svcqex_loccenterprint		58	// [string] codename
// //

// https://quakewiki.org/wiki/EXT_CSQC_System_Globals_Fields_and_Builtins_List
// stats
// 0 - 31 are reserved for standard engine stats
// 32 - 128 are for QuakeC modders
float STAT_HEALTH           = 0;
float STAT_WEAPONMODEL      = 2;
float STAT_AMMO             = 3;
float STAT_ARMOR            = 4;
float STAT_WEAPONFRAME      = 5;
float STAT_SHELLS           = 6;
float STAT_NAILS            = 7;
float STAT_ROCKETS          = 8;
float STAT_CELLS            = 9;
float STAT_ACTIVEWEAPON     = 10;
float STAT_TOTALSECRETS     = 11;
float STAT_TOTALMONSTERS    = 12;
float STAT_SECRETS          = 13; // bumped on client side by svc_foundsecret
float STAT_MONSTERS         = 14; // bumped by svc_killedmonster
float STAT_ITEMS            = 15; // self.items bitmask from server
float STAT_VIEWHEIGHT       = 16;