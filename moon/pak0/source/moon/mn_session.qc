/// ReProjectMoon-specific source file
/// Here go all functions that regulate game session: map change, win/lose, (dis)connect etc

void() moon_reset_globals =
{
	gl_playercount = 0;

	sv_alwaysday = 0;	// TODO: one day - preserve Settings between restarts
	sv_fastmeat = 0;
	sv_noshake = 0;

	up_alert = MOON_CONST_LOCKED;
	up_gold_value = 0;
	badluck_compensation = 0;
};

void(entity target) moon_prepare_player_entity =
{
	if (target.prepared) { return; }

	target.lvl = 0;
	target.exp = 0;
	target.nextexp = MOON_EXP_FIRST_LEVEL;
	target.gold = MOON_PLAYER_GOLD_INIT;
	target.max_health = MOON_PLAYER_HEALTH_INIT;
	target.health = target.max_health;
	target.max_mana = MOON_PLAYER_MANA_INIT;
	target.mana = target.max_mana;
	target.point = 0;
	target.mosterskilled = 0;

	target.up_axe = MOON_CONST_LOCKED;
	target.up_bullet = MOON_CONST_LOCKED;
	target.up_nail = MOON_CONST_LOCKED;
	target.up_rocket = MOON_CONST_LOCKED;
	target.up_cell = MOON_CONST_LOCKED;

	target.wear_armor = MOON_ITEM_NONE;
	target.magic_typeone = MOON_ITEM_NONE;
	target.magic_typetwo = MOON_ITEM_NONE;
	target.wear_ring = MOON_ITEM_NONE;
	target.ring_typeone = MOON_ITEM_NONE;
	target.ring_typetwo = MOON_ITEM_NONE;

	target.mentat_offense_time = 0;
	target.mentat_defense_time = 0;
	target.mentat_attackspeed_time = 0;

	target.prepared = TRUE;
};

void() moon_init_self_player = // happens with first impulse check
{
	if ( mapname != "moon4" )
	{
		sprint(self, "game supports only map moon4.bsp\n");
		localcmd("disconnect\n");
		return;
	}

	moon_prepare_player_entity(self);

	sprint(self, "Project MOON. Original v0.21beta created by \s3d[Power]\s\n");
	sprint(self, "ReProject MOON. Remake v{0} by \sSanctus-Susanin\s\n", MOON_VERSION);
	sprint(self, "Type pm_help to learn more about MOON console commands\n");
};
