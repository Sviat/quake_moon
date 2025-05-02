/// ReProjectMoon-specific source file
/// Here go all functions related to in-game music functionality


float(entity emitter, float track) moon_walkman_play = // return track length
{
	switch (track)
	{
	case 0:
		sound(emitter, MOON_WALKMAN_CHANNEL, "misc/null.wav", MOON_WALKMAN_VOLUME_SILENCE, ATTN_NORM);
		return 0;
	case 1:
		sound(emitter, MOON_WALKMAN_CHANNEL, "music/bpm/01_judgement.wav", MOON_WALKMAN_VOLUME_MUSIC, MOON_WALKMAN_ATTEN_MUSIC);
		return 316;
	case 2:
		sound(emitter, MOON_WALKMAN_CHANNEL, "music/bpm/02_the_rhytm_king.wav", MOON_WALKMAN_VOLUME_MUSIC, MOON_WALKMAN_ATTEN_MUSIC);
		return 363;
	case 3:
		sound(emitter, MOON_WALKMAN_CHANNEL, "music/bpm/03_the_crypt.wav", MOON_WALKMAN_VOLUME_MUSIC, MOON_WALKMAN_ATTEN_MUSIC);
		return 297;
	case 4:
		sound(emitter, MOON_WALKMAN_CHANNEL, "music/bpm/04_corruption.wav", MOON_WALKMAN_VOLUME_MUSIC, MOON_WALKMAN_ATTEN_MUSIC);
		return 294;
	case 5:
		sound(emitter, MOON_WALKMAN_CHANNEL, "music/bpm/05_depths_of_helheim.wav", MOON_WALKMAN_VOLUME_MUSIC, MOON_WALKMAN_ATTEN_MUSIC);
		return 382;
	case 6:
		sound(emitter, MOON_WALKMAN_CHANNEL, "music/bpm/12_yggdrasil_roots.wav", MOON_WALKMAN_VOLUME_MUSIC, MOON_WALKMAN_ATTEN_MUSIC);
		return 365;
	case 7:
		sound(emitter, MOON_WALKMAN_CHANNEL, "music/bpm/07_machinations.wav", MOON_WALKMAN_VOLUME_MUSIC, MOON_WALKMAN_ATTEN_MUSIC);
		return 286;
	case 8:
		sound(emitter, MOON_WALKMAN_CHANNEL, "music/bpm/08_into_asgard.wav", MOON_WALKMAN_VOLUME_MUSIC, MOON_WALKMAN_ATTEN_MUSIC);
		return 348;
	case 9:
		sound(emitter, MOON_WALKMAN_CHANNEL, "music/bpm/09_paradox.wav", MOON_WALKMAN_VOLUME_MUSIC, MOON_WALKMAN_ATTEN_MUSIC);
		return 275;
	case 10:
		sound(emitter, MOON_WALKMAN_CHANNEL, "music/bpm/10_fight_of_the_valkyrie.wav", MOON_WALKMAN_VOLUME_MUSIC, MOON_WALKMAN_ATTEN_MUSIC);
		return 416;
	case 11:
		sound(emitter, MOON_WALKMAN_CHANNEL, "music/bpm/11_muninn_arrmoury.wav", MOON_WALKMAN_VOLUME_SHOP, MOON_WALKMAN_ATTEN_SHOP);
		return 112;
	case 12:
		sound(emitter, MOON_WALKMAN_CHANNEL, "music/bpm/06_huginn_shop.wav", MOON_WALKMAN_VOLUME_SHOP, MOON_WALKMAN_ATTEN_SHOP);
		return 88;
	default:
		return 0;
	}
};

void(entity emitter) moon_walkman_stop =
{
	moon_walkman_play(emitter, 0);
};

float(entity emitter) moon_walkman_start_music_gate = // return track length
{
	local float track;
	track = random_int(1, 10);
	return moon_walkman_play(emitter, track);
};

float(entity emitter) moon_walkman_start_music_shop = // return track length
{
	local float track;
	track = random_int(11, 12);
	return moon_walkman_play(emitter, track);
};

void() moon_walkman_think =
{
	if (time > self.next_heart)
	{
		self.next_heart = time + MOON_WALKMAN_DELAY_BETWEENTRACKS_SHOP + moon_walkman_start_music_shop(self.master); // self.master caches emitter_shop
	}

	if (time > self.next_gate)
	{
		self.next_gate = time + MOON_WALKMAN_DELAY_BETWEENTRACKS_GATE + moon_walkman_start_music_gate(self.killer); // self.killer caches emitter_gate
	}

	self.nextthink = time + MOON_WALKMAN_DELAY_BETWEENTHINKS;
	self.think = moon_walkman_think;
};

void() moon_walkman_init_think =
{
	local entity e;

	local entity emitter_gate;
	local entity emitter_shop;

	emitter_gate = find(world, classname, MOON_GATE_CLASSNAME);
	if (emitter_gate == world)
	{
		dprint("Cannot find any sound gate\n");
		return;
	}

	emitter_shop = find(world, netname, MOON_TRADE_SHOP_HEALTH_NETNAME);
	if (emitter_shop == world)
	{
		dprint("Cannot find any healthy trader\n");
		return;
	}

	e = spawn();
	e.killer = emitter_gate;
	e.master = emitter_shop;

	e.next_heart = time + MOON_WALKMAN_DELAY_FIRSTTRACK_SHOP;
	e.next_gate = time + MOON_WALKMAN_DELAY_FIRSTTRACK_GATE;

	e.think = moon_walkman_think;
	e.nextthink = time + MOON_WALKMAN_DELAY_FIRSTTHINK_MIN + (MOON_WALKMAN_DELAY_FIRSTTHINK_RANDOM * random());
};