/// ReProjectMoon-specific source file
/// Here go all global vars introduced by Moon

float waypoints_ok;     // ??
float gl_playercount;   // Active player count

// Game settings [HOST ONLY]
float sv_alwaysday;     // (Dis/En)able day/night cycle
float sv_fastmeat;      // Fast or slow spawn of monsters
float sv_noshake;       // (Dis/En)able moonquake

// Castle-wide upgrades
float up_alert;         // Re-use same param for both Upgrade and Extra health
float up_gold_value;    // Global upgrade on any Gold drop
float up_item_magic_chance; // Global upgrade on any Magical Item drop (not its properties)
float badluck_compensation; // stores flat value added to next Unique item candidate roll