/// ReProjectMoon-specific source file
/// Here go all functions that regulate game session: map change, win/lose, (dis)connect etc

void() moon_reset_globals =
{
	gl_playercount = 0;
	sv_alwaysday = 0;
	sv_fastmeat = 0;
	sv_noshake = 0;
	up_alert = 0;
};

void(entity target) moon_prepare_player_entity =
{
	target.lvl = 0;
	target.exp = 0;
	target.nextexp = MOON_EXP_FIRST_LEVEL;
	target.gold = MOON_PLAYER_GOLD_INIT;
	target.max_mana = MOON_PLAYER_MANA_INIT;
	target.mana = self.max_mana;
	target.point = 0;
	target.mosterskilled = 0;
	target.up_bullet = 0;
	target.up_nail = 0;

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

	moon_prepare_player_entity(self); // extract to PutClientInServer

	sprint(self, "Project MOON. Original v0.21beta created by \s3d[Power]\s\n");
	sprint(self, "ReProject MOON. Remake v{} on \sKEX Engine\s by \sSanctus-Susanin\s\n", MOON_VERSION);
	sprint(self, "type pm_help to learn more about MOON console commands\n");
};
