/// ReProjectMoon-specific source file
/// Here go all functions used by world.qc on server launch
/// This should be LAST of moon includes in "progs.src", right before all vanilla includes go
/// 	to know of all existing maps and reduce needs in forward declarations

void() moon_precache_monsters =
{
	precache_model2("progs/monster1.mdl");
	precache_model2("progs/laser.mdl");
	precache_model2("progs/laser2.mdl");
	precache_sound2("enforcer/death1.wav");
	precache_sound2("enforcer/enfire.wav");
	precache_sound2("enforcer/enfstop.wav");
	precache_sound2("shalrath/attack.wav");
	precache_sound2("shalrath/attack2.wav");
	precache_sound2("shalrath/death.wav");
	precache_sound2("shambler/melee1.wav");
	precache_sound2("shambler/melee2.wav");
	precache_sound2("shambler/smack.wav");
	precache_sound2("shambler/sattck1.wav");
	precache_sound2("shambler/sboom.wav");
	precache_sound2("shambler/sdeath.wav");
	precache_sound2("zombie/z_hit.wav");
	precache_sound2("zombie/z_miss.wav");
	precache_sound2("zombie/z_shot1.wav");
	precache_sound2("zombie/z_gib.wav");
	precache_sound2("zombie/z_pain.wav");
	precache_sound2("zombie/z_pain1.wav");
	precache_model("progs/aura.mdl");
	precache_model("progs/shard.mdl");
	precache_model("progs/monster0.mdl");
	precache_model("progs/monster2.mdl");
	precache_model("progs/monster3.mdl");
	precache_model("progs/monster4.mdl");
	precache_model("progs/monster5.mdl");
	precache_model("progs/monster7.mdl");
	precache_model("progs/monster8.mdl");
	precache_model("progs/monster9.mdl");
	precache_model("progs/spid_gib.mdl");
	precache_model("progs/h_spider.mdl");
	precache_model("progs/w_spike.mdl");
	precache_model("progs/v_spike.mdl");
	precache_model("progs/h_mage.mdl");
	precache_model("progs/w_ball.mdl");
	precache_model("progs/spine.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/skull.mdl");
	precache_model("progs/h_guard.mdl");
	precache_model("progs/h_ogre.mdl");
	precache_model("progs/grenade.mdl");
	precache_model("progs/h_shal.mdl");
	precache_model("progs/uzi.mdl");
	precache_model("progs/knight.mdl");
	precache_model("progs/h_knight.mdl");
	precache_model("progs/s_light.mdl");
	precache_model("progs/shambler.mdl");
	precache_sound("ogre/ogdth.wav");
	precache_sound("ogre/ogsawatk.wav");
	precache_sound("knight/kdeath.wav");
	precache_sound("knight/khurt.wav");
	precache_sound("knight/ksight.wav");
	precache_sound("knight/sword1.wav");
	precache_sound("knight/sword2.wav");
	precache_sound("knight/idle.wav");
	precache_sound("soldier/death1.wav");
	precache_sound("soldier/sattck1.wav");
	//precache_sound("moon/headless/die1.wav"); // missing file
	precache_sound("moon/monsters/d_spider.wav");
	precache_sound("moon/monsters/f_spider.wav");
	precache_sound("moon/monsters/d_snake.wav");
	precache_sound("moon/monsters/d_mage.wav");
	precache_sound("moon/monsters/d_mage2.wav");
	precache_sound("moon/monsters/f_mage.wav");
};

void() moon_precache_items =
{
	precache_model2("progs/h_mega.mdl");
	precache_model("maps/b_bh100.bsp");
	precache_model("maps/b_bh25.bsp");
	precache_model("maps/b_bh10.bsp");
	precache_model("maps/b_shell0.bsp");
	precache_model("maps/b_nail0.bsp");
	precache_model("maps/b_batt0.bsp");
	precache_model("maps/b_rock0.bsp");
	precache_model("progs/g_shot.mdl");
	precache_model("progs/g_nail.mdl");
	precache_model("progs/g_nail2.mdl");
	precache_model("progs/g_rock.mdl");
	precache_model("progs/g_rock2.mdl");
	precache_model("progs/g_light.mdl");
	precache_model("progs/armor.mdl");
	precache_model("progs/ring.mdl");
	precache_model("progs/drugs.mdl");
	precache_model("progs/potion.mdl");
	precache_model("progs/heart.mdl");
	precache_model("progs/s_spikeb.mdl");
	precache_model("progs/player_s.mdl");
	precache_model("progs/player_n.mdl");
	precache_model("progs/gold.mdl");
	precache_model("progs/h_hellkn.mdl");
	precache_model("progs/h_shams.mdl");
	precache_model("progs/tome.mdl");
	precache_model("progs/derrick.mdl");
	precache_sound("items/r_item1.wav");
	precache_sound("items/r_item2.wav");
	precache_sound("items/health1.wav");
	precache_sound("items/armor1.wav");
	precache_sound("misc/medkey.wav");
	precache_sound("misc/null.wav"); // Null to clear channel
	precache_sound("moon/ambient/quake.wav");
	precache_sound("moon/items/ring.wav");
	precache_sound("moon/items/shard.wav");
	precache_sound("moon/items/drug.wav");
	precache_sound("moon/items/potion.wav");
	precache_sound("moon/items/scroll.wav");
	precache_sound("moon/items/gold.wav");
	precache_sound("moon/items/book.wav");
	precache_sound("moon/misc/levelup.wav");
	precache_sound("moon/misc/alert.wav");
	precache_sound("moon/misc/stone1.wav");
	precache_sound("moon/misc/stone2.wav");
	precache_sound("moon/misc/cast.wav");
};

void() moon_precache_extras =
{
	precache_model("progs/scroll.mdl");
	precache_model("progs/meteors.mdl");
	//precache_sound("moon/magic/m_slow.wav"); // missing
	//precache_sound("moon/magic/m_heal.wav"); // missing
	//precache_sound("moon/magic/m_thun.wav"); // missing
	//precache_sound("moon/talk/stay1.wav"); // missing
	//precache_sound("moon/talk/stay2.wav"); // missing
	//precache_sound("moon/talk/go1.wav"); // missing
	//precache_sound("moon/talk/go2.wav"); // missing
};

void() moon_precache_musics =
{
	// // BPM
	precache_sound("music/bpm/01_judgement.wav");
	precache_sound("music/bpm/02_the_rhytm_king.wav");
	precache_sound("music/bpm/03_the_crypt.wav");
	precache_sound("music/bpm/04_corruption.wav");
	precache_sound("music/bpm/05_depths_of_helheim.wav");
	precache_sound("music/bpm/06_huginn_shop.wav");
	precache_sound("music/bpm/07_machinations.wav");
	precache_sound("music/bpm/08_into_asgard.wav");
	precache_sound("music/bpm/09_paradox.wav");
	precache_sound("music/bpm/10_fight_of_the_valkyrie.wav");
	precache_sound("music/bpm/11_muninn_arrmoury.wav");
	precache_sound("music/bpm/12_yggdrasil_roots.wav");
};

void() moon_precache =
{
	moon_precache_items();
	moon_precache_monsters();
	moon_precache_extras();
	moon_precache_musics();
};

void() moon_reset_globals =
{
	gl_playercount = 0;

	sv_alwaysday = 0;	// TODO: one day - preserve Settings between restarts
	sv_fastmeat = 0;
	sv_noshake = 0;

	up_alert = MOON_CONST_LOCKED;
	up_gold_value = 0;
	up_item_magic_chance = 0;
	badluck_compensation = 0;
};

void() moon_start_map =
{
	moon_reset_globals();

	if ( mapname == "moon4" )
	{
		moon_set_map_moon4();
	}

	if ( mapname != "moon4" )
	{
		sprint(self, "game supports only map moon4.bsp\n");
		localcmd("disconnect\n");
		return;
	}
};