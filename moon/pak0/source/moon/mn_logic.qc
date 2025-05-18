/// ReProjectMoon-specific source file
/// Here go all map objects, spawners and their think functions
/// This should be included one of last, to reduce needs in forward declarations

/// Currently im afraid to change any name in this file, due low knowledge of map bsp

void() StartSpawning =
{
	local float player_maxlevel;

	if (gameover) { return; }
	if ( self.count <= 0 )
	{
		moon_queue_target_for_removal(self);
		return;
	}

	player_maxlevel = moon_get_max_player_level();
	moon_spawn_monster(self, player_maxlevel);

	self.nextthink = (time + MOON_TIME_BETWEEN_MONSTER_SPAWN);
};

void(float mon_count) SpawnMoster =
{
	local entity a;

	a = spawn();
	a.count = mon_count;
	a.classname = "monster_generator";
	a.think = StartSpawning;
	a.nextthink = time;
};

void() brain_think =
{
	local float player_maxlevel;
	local float player_count;
	local float monster_count;

	if ( gameover == TRUE )
	{
		remove(self);
		return;
	}

	player_maxlevel = moon_get_max_player_level();
	player_count = moon_get_current_player_count();
	monster_count = moon_get_monster_wave_size(player_maxlevel, player_count);
	moon_update_hud_monsters(monster_count);

	SpawnMoster(monster_count);
	self.nextthink = time + moon_get_spawn_delay();
	self.think = brain_think;
};

void() game_brain =
{
	local entity e;
	local entity jukebox;

	e = spawn();
	e.nextthink = (time + MOON_MONSTER_FISRTWAVETIME_DELAY) + (random() * MOON_MONSTER_FISRTWAVETIME_RANDOM);
	e.think = brain_think;

	jukebox = spawn();
	jukebox.nextthink = time + 1;
	jukebox.think = moon_walkman_init_think;
};

void() derrick_think =
{
	local entity head;

	self.nextthink = ((time + MOON_GOLD_MINE_DELAY_MIN) + (random() * MOON_GOLD_MINE_DELAY_RANDOM));
	self.think = derrick_think;

	head = findradius(self.origin, MOON_GOLD_MINE_DETECT_PLAYER_RADIUS);
	while (head)
	{
		if ( head.classname == MOON_PLAYER_CLASSNAME )
		{
			if ( head.health > 0 )
			{
				moon_spawn_drop_gold(self);
				return;
			}
		}
		head = head.chain;
	}

	head = findradius(self.origin, MOON_GOLD_MINE_DETECT_GUARD_RADIUS);
	while (head)
	{
		if ( head.classname == MOON_GUARD_CLASSNAME )
		{
			if ( head.health > 0 )
			{
				moon_spawn_drop_gold(self);
				return;
			}
		}
		head = head.chain;
	}
};

void(vector org) gold_derrick =
{
	local entity e;

	e = spawn();
	e.origin = org;
	e.classname = MOON_GOLD_MINE_CLASSNAME;
	setmodel(e, "progs/derrick.mdl");
	setsize(e, VEC_HULL_MIN, '16 16 24');
	e.solid = SOLID_BBOX;
	e.nextthink = time + MOON_GOLD_MINE_START_DELAY_MIN + (random() * MOON_GOLD_MINE_START_DELAY_RANDOM);
	e.think = derrick_think;
};

void() saler_stand = // Praise the Omnissiah!
{
	local entity a;

	self.think = saler_stand;
	self.nextthink = (time + 0.02);
	if ((self.framtime < time))
	{
		if ((self.walkframe >= LOGIC_PATROL))
		{
			self.walkframe = WF_NORMAL;
		}
		self.frame = (LOGIC_HUNTENEMY + self.walkframe);
		self.walkframe = (self.walkframe + 1);
		self.framtime = (time + 0.07);
	}
	self.ideal_yaw = self.cnt;
	ChangeYaw();
	if ((((self.angles_y >= (self.cnt - 2)) && (self.angles_y <= (self.cnt + 2))) && (self.free == MOON_TRADE_STATE_FREE)))
	{
		moon_market_place_for_sale(self);
	}
	if ((self.attack_finished < time))
	{
		self.action = 2;
		while ( (a = find(a, classname, MOON_TRADE_MARKET_SOMETHING_CLASSNAME)) )
		{
			if ( a.enemy == self ) // spot.enemy holds owner entity
			{
				a.free = MOON_TRADE_STATE_FREE;
			}
		}
		a = world; // reset iterator

		while ( (a = find(a, classname, MOON_TRADE_MARKET_SPOT_CLASSNAME)) )
		{
			if ( a.owner == self )
			{
				sound(self, CHAN_ITEM, a.noise1, 1, ATTN_NORM);
				remove(a);
			}
		}
		a = world; // reset iterator

		self.stuck_time = 0;
		self.rstuck_time = 0;
		self.rstuck_org = self.origin;
	}
	if ((self.action < LOGIC_FINDDEFEND))
	{
		if ((find_ns() == TRUE))
		{
			self.th_run();
		}
	}
};

void() saler_runn =
{
	local vector vec;
	local float stream;

	if ((self.flags & FL_ONGROUND))
	{
		self.ideal_yaw = vectoyaw((self.goalentity.origin - self.origin));
		ChangeYaw();
		vec = (self.goalentity.origin - self.origin);
		self.flags = (self.flags - (self.flags & FL_ONGROUND));
		vec_z = WF_NORMAL;
		if ((self.next_spam < time))
		{
			if ((random() < MON_BACKTIME))
			{
				self.spam_vector = ((v_right * ((self.goalentity.radius / 2) + ((self.goalentity.radius / 2) * random()))) * CONTENT_EMPTY);
			}
			else
			{
				self.spam_vector = (v_right * ((self.goalentity.radius / 2) + ((self.goalentity.radius / 2) * random())));
			}
			self.next_spam = ((time + 0.3) + (MON_BACKTIME * random()));
		}
		if ((vlen((self.goalentity.origin - self.origin)) < 120))
		{
			self.spam_vector = VEC_ORIGIN;
		}
		if ((self.stuck_time < time))
		{
			if ((vlen((self.stuck_org - self.origin)) <= MON_STUCKDIST))
			{
				vec = (self.origin - (self.origin - (v_forward * self.speed)));
				stream = (self.goalentity.radius * 2);
				if ((random() < MON_BACKTIME))
				{
					self.spam_vector = ((v_right * stream) * CONTENT_EMPTY);
				}
				else
				{
					self.spam_vector = (v_right * stream);
				}
				self.rstuck_org = (vec + self.spam_vector);
				self.rstuck_time = (time + MON_BACKTIME);
			}
			self.stuck_org = self.origin;
			self.stuck_time = (time + MON_REACTIONTIME);
		}
		if ((self.rstuck_time > time))
		{
			vec = self.rstuck_org;
		}
		else
		{
			vec = (vec + self.spam_vector);
		}
		vec = (vec + self.velocity);
		vec = normalize(vec);
		self.velocity = (vec * self.speed);
	}
};

void() saler_run =
{
	self.think = saler_run;
	self.nextthink = (time + MON_REFRESHTIME);
	if ((self.framtime < time))
	{
		if ((self.walkframe >= LOGIC_HUNTENEMY))
		{
			self.walkframe = WF_NORMAL;
		}
		self.frame = WF_NORMAL + self.walkframe;
		self.walkframe = self.walkframe + 1;
		self.framtime = time + 0.07;
	}
	saler_runn();
	if ((self.action == LOGIC_FINDDEFEND))
	{
		self.th_stand();
	}
};

void() spawn_saler = // have to clean it one day
{
	local entity e;

	e = spawn();
	e.origin = '-293.3 1201.8 -360';
	e.angles_y = MENTAT_TIME;
	setmodel(e, "progs/player_s.mdl");
	e.solid = SOLID_BBOX;
	e.movetype = MOVETYPE_STEP;
	setsize(e, VEC_HULL_MIN, VEC_HULL_MAX);
	e.takedamage = DAMAGE_NO;
	e.health = 1;
	e.yaw_speed = LOGIC_HUNTENEMY;
	e.wantnum = LOGIC_DEFEND;
	e.speed = 200;
	e.action = 1;
	e.attack_finished = ((time + 20) + (20 * random()));
	e.th_stand = saler_stand;
	e.th_run = saler_run;
	e.think = saler_stand;
	e.nextthink = time;
	e.classname = MOON_TRADER_MARKET_CLASSNAME;
	e.free = MOON_TRADE_STATE_OCCUPIED;
	e.cnt = CONTENT_EMPTY;
};

void() sale_think =
{
	spawn_saler();
	self.nextthink = ((time + 15) + (10 * random()));
	self.think = sale_think;
};

void() sale_brain =
{
	local entity e;

	e = spawn();
	e.nextthink = ((time + 20) + (2 * random()));
	e.think = sale_think;
};

void() moon_moonquake_think =
{
	local entity e;

	if ((self.attack_finished < time))
	{
		remove(self);
		return;
	}

	while ( (e = find(e, classname, MOON_PLAYER_CLASSNAME)) )
	{
		if ((e.flags & FL_ONGROUND))
		{
			if ((self.radsuit_finished < time))
			{
				if (((self.attack_finished - 5) > time))
				{
					sound(e, CHAN_AUTO, "moon/ambient/quake.wav", 1, ATTN_NORM);
				}
			}
			e.flags = (e.flags - FL_ONGROUND);
			e.velocity_x = (e.velocity_x + (crandom() * self.delay));
			e.velocity_y = (e.velocity_y + (crandom() * self.delay));
			e.velocity_z = (e.velocity_z + (random() * self.delay));
		}
	}

	if ( self.radsuit_finished < time )
	{
		self.radsuit_finished = (time + 1);

		e = find(e, classname, MOON_GOLD_MINE_CLASSNAME);
		if (e != world)
		{
			moon_spawn_drop_gold(e);
		}
	}
	self.think = moon_moonquake_think;
	self.nextthink = ((time + 0.2) - (random() * 0.1));
};

void(float dl, float el) moon_spawn_moonquake = // TODO: extract constants for tuning
{
	local entity e;

	if ((el < 64))
	{
		el = 64;
	}
	e = spawn();
	e.think = moon_moonquake_think;
	e.delay = el;
	e.nextthink = (time + 1);
	e.attack_finished = ((time + dl) + (random() * dl));
};

void() jesus_think =
{
	local float r;
	local float d;

	if ( gameover == TRUE )
	{
		remove(self);
		return;
	}

	r = rint( random() * 12 );
	if (((r >= 8) && (r <= 10)))
	{
		if (sv_noshake == 0)
		{
			moon_spawn_moonquake(r, (random() * 160)); // moon_spawn_moonquake('12 0 0', (random() * 160));
		}

		if ( random() < 0.1 )
		{
			d = rint((random() * 10));
			switch(d)
			{
				case 0: bprint("jesus: please report this bug to meteo-center :))\n"); break;
				case 1: bprint("jesus: DO NOT shake the earth, fucking demons!\n"); break;
				case 2: bprint("jesus: wow, what a frenzy!!!\n"); break;
				case 3: bprint("jesus: heh, an earth quake!\n"); break;
				case 4: bprint("jesus: quake is just a cool name for a game\n"); break;
				case 5: bprint("jesus: come to vault 13\n"); break;
				case 6: bprint("jesus: visit: http://powersite.narod.ru\n"); break;
				case 7: bprint("jesus: your castle will be your graveyard\n"); break;
				case 8: bprint("jesus: bring me 10000 gold and i'll give you invulnerability\n"); break;
				case 9: bprint("jesus: you may need time machine\n"); break;
				case 10:bprint("jesus: no comments\n"); break;
			}
			moon_make_chat_noise();
		}
	}

	self.nextthink = ((time + 60) + (60 * random()));
	self.think = jesus_think;
};

void() jesus_brain =
{
	local entity e;

	e = spawn();
	e.nextthink = ((time + 30) + (60 * random()));
	e.think = jesus_think;
};