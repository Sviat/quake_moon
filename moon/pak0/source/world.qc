//Decompiled code. Please respect the original copyright.
void() InitBodyQue;

void() main =
{
	dprint("main function\n");
	precache_file("progs.dat");
	precache_file("gfx.wad");
	precache_file("quake.rc");
	precache_file("default.cfg");
	precache_file("end1.bin");
	precache_file2("end2.bin");
	precache_file("demo1.dem");
	precache_file("demo2.dem");
	precache_file("demo3.dem");
	precache_file("gfx/palette.lmp");
	precache_file("gfx/colormap.lmp");
	precache_file2("gfx/pop.lmp");
	precache_file("gfx/complete.lmp");
	precache_file("gfx/inter.lmp");
	precache_file("gfx/ranking.lmp");
	precache_file("gfx/vidmodes.lmp");
	precache_file("gfx/finale.lmp");
	precache_file("gfx/conback.lmp");
	precache_file("gfx/qplaque.lmp");
	precache_file("gfx/menudot1.lmp");
	precache_file("gfx/menudot2.lmp");
	precache_file("gfx/menudot3.lmp");
	precache_file("gfx/menudot4.lmp");
	precache_file("gfx/menudot5.lmp");
	precache_file("gfx/menudot6.lmp");
	precache_file("gfx/menuplyr.lmp");
	precache_file("gfx/bigbox.lmp");
	precache_file("gfx/dim_modm.lmp");
	precache_file("gfx/dim_drct.lmp");
	precache_file("gfx/dim_ipx.lmp");
	precache_file("gfx/dim_tcp.lmp");
	precache_file("gfx/dim_mult.lmp");
	precache_file("gfx/mainmenu.lmp");
	precache_file("gfx/box_tl.lmp");
	precache_file("gfx/box_tm.lmp");
	precache_file("gfx/box_tr.lmp");
	precache_file("gfx/box_ml.lmp");
	precache_file("gfx/box_mm.lmp");
	precache_file("gfx/box_mm2.lmp");
	precache_file("gfx/box_mr.lmp");
	precache_file("gfx/box_bl.lmp");
	precache_file("gfx/box_bm.lmp");
	precache_file("gfx/box_br.lmp");
	precache_file("gfx/sp_menu.lmp");
	precache_file("gfx/ttl_sgl.lmp");
	precache_file("gfx/ttl_main.lmp");
	precache_file("gfx/ttl_cstm.lmp");
	precache_file("gfx/mp_menu.lmp");
	precache_file("gfx/netmen1.lmp");
	precache_file("gfx/netmen2.lmp");
	precache_file("gfx/netmen3.lmp");
	precache_file("gfx/netmen4.lmp");
	precache_file("gfx/netmen5.lmp");
	precache_file("gfx/sell.lmp");
	precache_file("gfx/help0.lmp");
	precache_file("gfx/help1.lmp");
	precache_file("gfx/help2.lmp");
	precache_file("gfx/help3.lmp");
	precache_file("gfx/help4.lmp");
	precache_file("gfx/help5.lmp");
	precache_file("gfx/pause.lmp");
	precache_file("gfx/loading.lmp");
	precache_file("gfx/p_option.lmp");
	precache_file("gfx/p_load.lmp");
	precache_file("gfx/p_save.lmp");
	precache_file("gfx/p_multi.lmp");
	precache_sound("misc/menu1.wav");
	precache_sound("misc/menu2.wav");
	precache_sound("misc/menu3.wav");
	precache_sound("ambience/water1.wav");
	precache_sound("ambience/wind2.wav");
	precache_file("maps/start.bsp");
	precache_file("maps/e1m1.bsp");
	precache_file("maps/e1m2.bsp");
	precache_file("maps/e1m3.bsp");
	precache_file("maps/e1m4.bsp");
	precache_file("maps/e1m5.bsp");
	precache_file("maps/e1m6.bsp");
	precache_file("maps/e1m7.bsp");
	precache_file("maps/e1m8.bsp");
	precache_file2("gfx/pop.lmp");
	precache_file2("maps/e2m1.bsp");
	precache_file2("maps/e2m2.bsp");
	precache_file2("maps/e2m3.bsp");
	precache_file2("maps/e2m4.bsp");
	precache_file2("maps/e2m5.bsp");
	precache_file2("maps/e2m6.bsp");
	precache_file2("maps/e2m7.bsp");
	precache_file2("maps/e3m1.bsp");
	precache_file2("maps/e3m2.bsp");
	precache_file2("maps/e3m3.bsp");
	precache_file2("maps/e3m4.bsp");
	precache_file2("maps/e3m5.bsp");
	precache_file2("maps/e3m6.bsp");
	precache_file2("maps/e3m7.bsp");
	precache_file2("maps/e4m1.bsp");
	precache_file2("maps/e4m2.bsp");
	precache_file2("maps/e4m3.bsp");
	precache_file2("maps/e4m4.bsp");
	precache_file2("maps/e4m5.bsp");
	precache_file2("maps/e4m6.bsp");
	precache_file2("maps/e4m7.bsp");
	precache_file2("maps/e4m8.bsp");
	precache_file2("maps/end.bsp");
	precache_file2("maps/dm1.bsp");
	precache_file2("maps/dm2.bsp");
	precache_file2("maps/dm3.bsp");
	precache_file2("maps/dm4.bsp");
	precache_file2("maps/dm5.bsp");
	precache_file2("maps/dm6.bsp");
};
entity lastspawn;

void() worldspawn =
{
	lastspawn = world;
	InitBodyQue();
	if ((self.model == "maps/e1m8.bsp"))
	{
		cvar_set("sv_gravity", "100");
	}
	else
	{
		cvar_set("sv_gravity", "800");
	}
	W_Precache();
	precache_sound("demon/dland2.wav");
	precache_sound("misc/h2ohit1.wav");
	precache_sound("items/itembk2.wav");
	precache_sound("player/plyrjmp8.wav");
	precache_sound("player/land.wav");
	precache_sound("player/land2.wav");
	precache_sound("player/drown1.wav");
	precache_sound("player/drown2.wav");
	precache_sound("player/gasp1.wav");
	precache_sound("player/gasp2.wav");
	precache_sound("player/h2odeath.wav");
	precache_sound("misc/talk.wav");
	precache_sound("player/teledth1.wav");
	precache_sound("misc/r_tele1.wav");
	precache_sound("misc/r_tele2.wav");
	precache_sound("misc/r_tele3.wav");
	precache_sound("misc/r_tele4.wav");
	precache_sound("misc/r_tele5.wav");
	precache_sound("weapons/lock4.wav");
	precache_sound("weapons/pkup.wav");
	precache_sound("items/armor1.wav");
	precache_sound("weapons/lhit.wav");
	precache_sound("weapons/lstart.wav");
	precache_sound("items/damage3.wav");
	precache_sound("misc/power.wav");
	precache_sound("player/gib.wav");
	precache_sound("player/udeath.wav");
	precache_sound("player/tornoff2.wav");
	precache_sound("player/pain1.wav");
	precache_sound("player/pain2.wav");
	precache_sound("player/pain3.wav");
	precache_sound("player/pain4.wav");
	precache_sound("player/pain5.wav");
	precache_sound("player/pain6.wav");
	precache_sound("player/death1.wav");
	precache_sound("player/death2.wav");
	precache_sound("player/death3.wav");
	precache_sound("player/death4.wav");
	precache_sound("player/death5.wav");
	precache_sound("weapons/ax1.wav");
	precache_sound("player/axhit1.wav");
	precache_sound("player/axhit2.wav");
	precache_sound("player/h2ojump.wav");
	precache_sound("player/slimbrn2.wav");
	precache_sound("player/inh2o.wav");
	precache_sound("player/inlava.wav");
	precache_sound("misc/outwater.wav");
	precache_sound("player/lburn1.wav");
	precache_sound("player/lburn2.wav");
	precache_sound("misc/water1.wav");
	precache_sound("misc/water2.wav");
	precache_model("progs/player.mdl");
	precache_model("progs/eyes.mdl");
	precache_model("progs/h_player.mdl");
	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");
	precache_model("progs/s_bubble.spr");
	precache_model("progs/s_explod.spr");
	precache_model("progs/v_axe.mdl");
	precache_model("progs/v_shot.mdl");
	precache_model("progs/v_nail.mdl");
	precache_model("progs/v_rock.mdl");
	precache_model("progs/v_shot2.mdl");
	precache_model("progs/v_nail2.mdl");
	precache_model("progs/v_rock2.mdl");
	precache_model("progs/bolt.mdl");
	precache_model("progs/bolt2.mdl");
	precache_model("progs/bolt3.mdl");
	precache_model("progs/lavaball.mdl");
	precache_model("progs/missile.mdl");
	precache_model("progs/grenade.mdl");
	precache_model("progs/spike.mdl");
	precache_model("progs/s_spike.mdl");
	precache_model("progs/backpack.mdl");
	precache_model("progs/zom_gib.mdl");
	precache_model("progs/v_light.mdl");
	lightstyle(WF_NORMAL, "m");
	lightstyle(CHSCAM_ON, "mmnmmommommnonmmonqnmmo");
	lightstyle(H_MEGA, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	lightstyle(LOGIC_FINDDEFEND, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
	lightstyle(LOGIC_DEFEND, "mamamamamama");
	lightstyle(SVC_SETVIEWPORT, "jklmnopqrstuvwxyzyxwvutsrqponmlkj");
	lightstyle(LOGIC_HUNTENEMY, "nmonqnmomnmomomno");
	lightstyle(TE_WIZSPIKE, "mmmaaaabcdefgmmmmaaaammmaamm");
	lightstyle(KEY_MOVERIGHT, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
	lightstyle(TE_LIGHTNING3, "aaaaaaaazzzzzzzz");
	lightstyle(SVC_SETVIEWANGLES, "mmamammmmammamamaaamammma");
	lightstyle(TE_TELEPORT, "abcdefghijklmnopqrrqponmlkjihgfedcba");
	lightstyle(63, "a");
};

void() StartFrame =
{
	teamplay = cvar("teamplay");
	skill = cvar("skill");
	framecount = (framecount + CHSCAM_ON);
};
entity bodyque_head;

void() bodyque =
{
};

void() InitBodyQue =
{
	//local entity e; // unused

	bodyque_head = spawn();
	bodyque_head.classname = "bodyque";
	bodyque_head.owner = spawn();
	bodyque_head.owner.classname = "bodyque";
	bodyque_head.owner.owner = spawn();
	bodyque_head.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner = spawn();
	bodyque_head.owner.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner.owner = bodyque_head;
};

void(entity ent) CopyToBodyQue =
{
	bodyque_head.angles = ent.angles;
	bodyque_head.model = ent.model;
	bodyque_head.modelindex = ent.modelindex;
	bodyque_head.frame = ent.frame;
	bodyque_head.colormap = ent.colormap;
	bodyque_head.movetype = ent.movetype;
	bodyque_head.velocity = ent.velocity;
	bodyque_head.flags = WF_NORMAL;
	setorigin(bodyque_head, ent.origin);
	setsize(bodyque_head, ent.mins, ent.maxs);
	bodyque_head = bodyque_head.owner;
};
void(entity attacker, float damage) player_pain;
void() player_stand1;
void(vector org, entity death_owner) spawn_tdeath;
float modelindex_eyes;
float modelindex_player;

void() ClientBan =
{
	sprint(self, "you was banned. too late join, game already started\n");
	stuffcmd(self, "wait;wait;wait;disconnect\n");
};

void() info_intermission =
{
};

void() SetChangeParms =
{
	SetNewParms();
};

void() SetNewParms =
{
	parm1 = (IT_SHOTGUN | IT_AXE);
	parm2 = 100;
	parm3 = WF_NORMAL;
	parm4 = 25;
	parm5 = WF_NORMAL;
	parm6 = WF_NORMAL;
	parm7 = WF_NORMAL;
	parm8 = CHSCAM_ON;
	parm9 = WF_NORMAL;
};

void() DecodeLevelParms =
{
	SetNewParms();
	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weapon = parm8;
	self.armortype = (parm9 * MON_REFRESHTIME);
};

entity() FindIntermission =
{
	local	entity spot;
	local	float cyc;

	// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");

			if (!spot)
				spot = find (spot, classname, "info_intermission");

			cyc = cyc - 1;
		}

		return spot;
	}

	// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;

	// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	objerror ("FindIntermission: no spot");
	return world;
};
string nextmap;

void() GotoNextMap =
{
	changelevel(mapname);
};

void() ExitIntermission =
{
	intermission_exittime = (time + CHSCAM_ON);
	intermission_running = (intermission_running + CHSCAM_ON);
	GotoNextMap();
};

void() IntermissionThink =
{
	if ((time < intermission_exittime))
	{
		return;
	}
	if (((!self.button0 && !self.button1) && !self.button2))
	{
		return;
	}
	ExitIntermission();
};

void() execute_changelevel =
{
	local entity pos;
	local entity h;

	self.avelocity = VEC_ORIGIN;
	self.velocity = VEC_ORIGIN;
	intermission_running = CHSCAM_ON;
	intermission_exittime = (time + SVC_SETVIEWANGLES);
	WriteByte(MSG_ALL, SVC_CDTRACK);
	WriteByte(MSG_ALL, LOGIC_FINDDEFEND);
	WriteByte(MSG_ALL, LOGIC_FINDDEFEND);
	pos = FindIntermission();
	h = find(world, classname, "player");
	while ((h != world))
	{
		h.view_ofs = VEC_ORIGIN;
		h.v_angle = pos.mangle;
		h.angles = pos.mangle;
		h.fixangle = TRUE;
		h.nextthink = (time + MON_BACKTIME);
		h.takedamage = DAMAGE_NO;
		h.solid = SOLID_NOT;
		h.movetype = MOVETYPE_NONE;
		h.modelindex = WF_NORMAL;
		setorigin(h, pos.origin);
		other = find(h, classname, "player");
	}
	WriteByte(MSG_ALL, SVC_INTERMISSION);
};

void() changelevel_touch =
{
	//local entity pos; // unused

	if ((other.classname != "player"))
	{
		return;
	}
	if (((cvar("noexit") == CHSCAM_ON) || ((cvar("noexit") == H_MEGA) && (mapname != "start"))))
	{
		T_Damage(other, self, self, 50000);
		return;
	}
	if ((coop || deathmatch))
	{
		bprint(other.netname);
		bprint(" exited the level\n");
	}
	nextmap = self.map;
	SUB_UseTargets();
	if (((self.spawnflags & CHSCAM_ON) && (deathmatch == WF_NORMAL)))
	{
		GotoNextMap();
		return;
	}
	self.touch = SUB_Null;
	self.think = execute_changelevel;
	self.nextthink = (time + MON_CAMPERCHANCE);
};

void() trigger_changelevel =
{
	if (!self.map)
	{
		objerror("chagnelevel trigger doesn't have map");
	}
	InitTrigger();
	self.touch = changelevel_touch;
};
void() set_suicide_frame;

void() respawn =
{
	AddToQue(self);
	setspawnparms(self);
	PutClientInServer();
};

void() ClientKill =
{
	self.modelindex = modelindex_player;
	self.health = CONTENT_EMPTY;
	self.think = PlayerDie;
	self.nextthink = time;
};

float(vector v) CheckSpawnPoint =
{
	return (FALSE);
};

entity() SelectSpawnPoint =
{
	local entity spot;
	local entity thing;
	local float pcount;

	spot = find(world, classname, "testplayerstart");
	if (spot)
	{
		return (spot);
	}
	spot = lastspawn;
	while (CHSCAM_ON)
	{
		spot = find(spot, classname, "info_player_deathmatch");
		if ((spot != world))
		{
			if ((spot == lastspawn))
			{
				return (lastspawn);
			}
			pcount = WF_NORMAL;
			thing = findradius(spot.origin, KEY_MOVEBACK);
			while (thing)
			{
				if ((thing.classname == "player"))
				{
					pcount = (pcount + CHSCAM_ON);
				}
				thing = thing.chain;
			}
			if ((pcount == WF_NORMAL))
			{
				lastspawn = spot;
				return (spot);
			}
		}
	}
	if (serverflags)
	{
		spot = find(world, classname, "info_player_start2");
		if (spot)
		{
			return (spot);
		}
	}
	spot = find(world, classname, "info_player_start");
	if (!spot)
	{
		error("PutClientInServer: no info_player_start on level");
	}
	return (spot);
};

void() PutClientInServer =
{
	local entity spot;

	spot = SelectSpawnPoint();
	self.velocity = VEC_ORIGIN;
	self.classname = "player";
	if ((self.think == ClientBan))
	{
		return;
	}
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = WF_NORMAL;
	self.health_magic_regen_time = WF_NORMAL;
	if ((self.max_health <= WF_NORMAL))
	{
		self.max_health = 100;
	}
	self.flags = FL_CLIENT;
	self.super_damage_finished = WF_NORMAL;
	self.gold = WF_NORMAL;
	self.radsuit_finished = WF_NORMAL;
	self.invisible_finished = WF_NORMAL;
	self.invincible_finished = WF_NORMAL;
	self.effects = WF_NORMAL;
	self.invincible_time = WF_NORMAL;
	self.mentat_bonus = WF_NORMAL;
	self.mentat_bonus2 = WF_NORMAL;
	self.mentat_bonus3 = WF_NORMAL;
	DecodeLevelParms();
	W_SetCurrentAmmo();
	self.attack_finished = (time + MON_CAMPERCHANCE);
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	self.deadflag = DEAD_NO;
	self.pausetime = WF_NORMAL;
	self.origin = (spot.origin + '0 0 1');
	self.angles = spot.angles;
	self.fixangle = TRUE;
	setmodel(self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;
	setmodel(self, "progs/player.mdl");
	modelindex_player = self.modelindex;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.view_ofs = '0 0 22';
	player_stand1();
	makevectors(self.angles);
	spawn_tfog((self.origin + (v_forward * GRD_PATROLTIME)));
	spawn_tdeath(self.origin, self);
	if ((self.point > WF_NORMAL))
	{
		self.items = (self.items + IT_KEY1);
	}
	self.health = self.max_health;
};

void() info_player_start =
{
};

void() info_player_start2 =
{
};

void() testplayerstart =
{
};

void() info_player_deathmatch =
{
};

void() info_player_coop =
{
};

void() NextLevel =
{
};

void() CheckRules =
{
};

void() PlayerDeathThink =
{
	//local entity old_self; // unused
	local float forward;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen(self.velocity);
		forward = (forward - GRD_PATROLTIME);
		if ((forward <= WF_NORMAL))
		{
			self.velocity = VEC_ORIGIN;
		}
		else
		{
			self.velocity = (forward * normalize(self.velocity));
		}
	}
	if ((self.dead_time > time))
	{
		return;
	}
	if ((self.deadflag == DEAD_DEAD))
	{
		if (((self.button2 || self.button1) || self.button0))
		{
			return;
		}
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}
	if (((!self.button2 && !self.button1) && !self.button0))
	{
		return;
	}
	self.button0 = WF_NORMAL;
	self.button1 = WF_NORMAL;
	self.button2 = WF_NORMAL;
	respawn();
};

void() PlayerJump =
{
	//local vector start; // unused
	//local vector end; // unused

	if ((self.flags & FL_WATERJUMP))
	{
		return;
	}
	if ((self.waterlevel >= H_MEGA))
	{
		if ((self.watertype == CONTENT_WATER))
		{
			self.velocity_z = 100;
		}
		else
		{
			if ((self.watertype == CONTENT_SLIME))
			{
				self.velocity_z = 80;
			}
			else
			{
				self.velocity_z = 50;
			}
		}
		if ((self.swim_flag < time))
		{
			self.swim_flag = (time + CHSCAM_ON);
			if ((random() < MON_BACKTIME))
			{
				sound(self, CHAN_BODY, "misc/water1.wav", CHSCAM_ON, ATTN_NORM);
			}
			else
			{
				sound(self, CHAN_BODY, "misc/water2.wav", CHSCAM_ON, ATTN_NORM);
			}
		}
		return;
	}
	if (!(self.flags & FL_ONGROUND))
	{
		return;
	}
	if (!(self.flags & FL_JUMPRELEASED))
	{
		return;
	}
	self.flags = (self.flags - (self.flags & FL_JUMPRELEASED));
	self.flags = (self.flags - FL_ONGROUND);
	self.button2 = WF_NORMAL;
	sound(self, CHAN_BODY, "player/plyrjmp8.wav", CHSCAM_ON, ATTN_NORM);
	self.velocity_z = (self.velocity_z + 270);
};
.float dmgtime;

void() WaterMove =
{
	if ((self.movetype == MOVETYPE_NOCLIP))
	{
		return;
	}
	if ((self.health < WF_NORMAL))
	{
		return;
	}
	if ((self.waterlevel != LOGIC_FINDDEFEND))
	{
		if ((self.air_finished < time))
		{
			sound(self, CHAN_VOICE, "player/gasp2.wav", CHSCAM_ON, ATTN_NORM);
		}
		else
		{
			if ((self.air_finished < (time + TE_LIGHTNING3)))
			{
				sound(self, CHAN_VOICE, "player/gasp1.wav", CHSCAM_ON, ATTN_NORM);
			}
		}
		self.air_finished = (time + 12);
		self.dmg = H_MEGA;
	}
	else
	{
		if ((self.air_finished < time))
		{
			if ((self.pain_finished < time))
			{
				self.dmg = (self.dmg + H_MEGA);
				if ((self.dmg > 15))
				{
					self.dmg = SVC_SETVIEWANGLES;
				}
				T_Damage(self, world, world, self.dmg);
				self.pain_finished = (time + CHSCAM_ON);
			}
		}
	}
	if (!self.waterlevel)
	{
		if ((self.flags & FL_INWATER))
		{
			sound(self, CHAN_BODY, "misc/outwater.wav", CHSCAM_ON, ATTN_NORM);
			self.flags = (self.flags - FL_INWATER);
		}
		return;
	}
	if ((self.watertype == CONTENT_LAVA))
	{
		if ((self.dmgtime < time))
		{
			if ((self.radsuit_finished > time))
			{
				self.dmgtime = (time + CHSCAM_ON);
			}
			else
			{
				self.dmgtime = (time + MON_REACTIONTIME);
			}
			T_Damage(self, world, world, (SVC_SETVIEWANGLES * self.waterlevel));
		}
	}
	else
	{
		if ((self.watertype == CONTENT_SLIME))
		{
			if (((self.dmgtime < time) && (self.radsuit_finished < time)))
			{
				self.dmgtime = (time + CHSCAM_ON);
				T_Damage(self, world, world, (LOGIC_DEFEND * self.waterlevel));
			}
		}
	}
	if (!(self.flags & FL_INWATER))
	{
		if ((self.watertype == CONTENT_LAVA))
		{
			sound(self, CHAN_BODY, "player/inlava.wav", CHSCAM_ON, ATTN_NORM);
		}
		if ((self.watertype == CONTENT_WATER))
		{
			sound(self, CHAN_BODY, "player/inh2o.wav", CHSCAM_ON, ATTN_NORM);
		}
		if ((self.watertype == CONTENT_SLIME))
		{
			sound(self, CHAN_BODY, "player/slimbrn2.wav", CHSCAM_ON, ATTN_NORM);
		}
		self.flags = (self.flags + FL_INWATER);
		self.dmgtime = WF_NORMAL;
	}
	if (!(self.flags & FL_WATERJUMP))
	{
		self.velocity = (self.velocity - (((0.8 * self.waterlevel) * frametime) * self.velocity));
	}
};

void() CheckWaterJump =
{
	local vector start;
	local vector end;

	makevectors(self.angles);
	start = self.origin;
	start_z = (start_z + KEY_MOVERIGHT);
	v_forward_z = WF_NORMAL;
	normalize(v_forward);
	end = (start + (v_forward * chasecam_zofs));
	traceline(start, end, TRUE, self);
	if ((trace_fraction < CHSCAM_ON))
	{
		start_z = ((start_z + self.maxs_z) - KEY_MOVERIGHT);
		end = (start + (v_forward * chasecam_zofs));
		self.movedir = (trace_plane_normal * -50);
		traceline(start, end, TRUE, self);
		if ((trace_fraction == CHSCAM_ON))
		{
			self.flags = (self.flags | FL_WATERJUMP);
			self.velocity_z = 225;
			self.flags = (self.flags - (self.flags & FL_JUMPRELEASED));
			self.teleport_time = (time + H_MEGA);
			return;
		}
	}
};

void() CheckCrosshair =
{
	if ((self.console_time > time))
	{
		return;
	}
	self.console_time = (time + MON_REACTIONTIME);
	traceline(self.origin, (self.origin + (v_forward * 1500)), FALSE, self);
	if ((trace_ent.flags & FL_MONSTER))
	{
		centerprint5(self, trace_ent.prefix_one, trace_ent.prefix_two, trace_ent.netname, trace_ent.prefix_three, trace_ent.prefix_four);
	}
	else
	{
		centerprint(self, s_wiz);
	}
};

void() proc_health_magic_regen_time =
{
	if ((self.health_magic_regen_time > time))
	{
		return;
	}
	if (((self.deadflag == DEAD_RESPAWNABLE) || (self.deadflag == DEAD_DEAD)))
	{
		return;
	}
	if (((self.health <= WF_NORMAL) || (self.health >= self.max_health)))
	{
		return;
	}
	if ((self.magic_typeone == TE_WIZSPIKE))
	{
		T_Heal(self, self.magic_typeone_value, WF_NORMAL);
	}
	if ((self.magic_typetwo == TE_WIZSPIKE))
	{
		T_Heal(self, self.magic_typetwo_value, WF_NORMAL);
	}
	if ((self.ring_typeone == TE_WIZSPIKE))
	{
		T_Heal(self, self.ring_typeone_value, WF_NORMAL);
	}
	if ((self.ring_typetwo == TE_WIZSPIKE))
	{
		T_Heal(self, self.ring_typetwo_value, WF_NORMAL);
	}
	self.health_magic_regen_time = (time + CHSCAM_ON);
};

void() regen_life =
{
	if (((self.deadflag == DEAD_RESPAWNABLE) || (self.deadflag == DEAD_DEAD)))
	{
		return;
	}
	if ((self.rgn_time > time))
	{
		return;
	}
	if ((self.max_health <= self.health))
	{
		return;
	}
	if ((self.skl_rgn == WF_NORMAL))
	{
		return;
	}
	if ((self.health <= WF_NORMAL))
	{
		return;
	}
	self.health = (self.health + CHSCAM_ON);
	self.rgn_time = (time + self.skl_rgn);
};

void() regen_mana =
{
	if (((self.deadflag == DEAD_RESPAWNABLE) || (self.deadflag == DEAD_DEAD)))
	{
		return;
	}
	if ((self.rgnm_time > time))
	{
		return;
	}
	if ((self.max_mana <= self.mana))
	{
		return;
	}
	self.mana = (self.mana + SVC_SETVIEWPORT);
	self.rgnm_time = (time + CHSCAM_ON);
};

void() check_poison =
{
	if (((self.deadflag == DEAD_RESPAWNABLE) || (self.deadflag == DEAD_DEAD)))
	{
		return;
	}
	if ((self.next_poison > time))
	{
		return;
	}
	if ((self.health > self.poison_dmg))
	{
		self.health = (self.health - self.poison_dmg);
	}
	else
	{
		self.health = CHSCAM_ON;
	}
	SpawnPoison(self.origin, '0 0 -1', (self.poison_dmg * LOGIC_FINDDEFEND));
	self.next_poison = (time + 0.7);
};

void() check_spells =
{
	local vector smes;

	if ((self.scroll_heal_eff > time))
	{
		smes = (((self.origin + (v_up * self.maxs_z)) - ((v_up * LOGIC_HUNTENEMY) * random())) + ((v_right * LOGIC_DEFEND) * crandom()));
		particle(smes, '0 0 -20', 165, 25);
	}
	if ((self.scroll_brut_eff > time))
	{
		smes = ((self.origin + (v_up * self.mins_z)) + ((v_right * LOGIC_DEFEND) * crandom()));
		particle(smes, '0 0 5', 200, 25);
	}
	if ((self.scroll_shie_eff > time))
	{
		smes = ((self.origin + (v_up * self.mins_z)) + ((v_right * LOGIC_DEFEND) * crandom()));
		particle(smes, '0 0 5', MON_CAMPTIME, 25);
	}
};

void() PlayerPreThink =
{
	//local float mspeed; // unused
	//local float aspeed; // unused
	//local float r; // unused

	if ((cvar("sv_maxspeed") > 400))
	{
		cvar_set("sv_maxspeed", "400");
	}
	if ((cvar("sv_gravity") != 800))
	{
		cvar_set("sv_gravity", "800");
	}
	if (intermission_running)
	{
		IntermissionThink();
		return;
	}
	if ((self.cl_framtime == CHSCAM_ON))
	{
		if ((self.frmtm <= time))
		{
			self.frmes = (self.frmes + CHSCAM_ON);
			sprint(self, "{} fps\n", floor_ftos(self.frmes));
			self.frmtm = (time + CHSCAM_ON);
			self.frmes = WF_NORMAL;
		}
		self.frmes = (self.frmes + CHSCAM_ON);
	}
	if ((self.view_ofs == VEC_ORIGIN))
	{
		return;
	}
	makevectors(self.v_angle);
	CheckRules();
	WaterMove();
	if ((self.deadflag >= DEAD_DEAD))
	{
		PlayerDeathThink();
		return;
	}
	CheckCrosshair();
	regen_life();
	regen_mana();
	check_spells();
	if (((((self.magic_typeone == TE_WIZSPIKE) || (self.magic_typetwo == TE_WIZSPIKE)) || (self.ring_typetwo == TE_WIZSPIKE)) || (self.ring_typeone == TE_WIZSPIKE)))
	{
		proc_health_magic_regen_time();
	}
	if ((self.poisoned > time))
	{
		check_poison();
	}
	if ((self.waterlevel == H_MEGA))
	{
		CheckWaterJump();
	}
	if ((self.deadflag == DEAD_DYING))
	{
		return;
	}
	if (self.button2)
	{
		PlayerJump();
	}
	else
	{
		self.flags = (self.flags | FL_JUMPRELEASED);
	}
	if ((time < self.pausetime))
	{
		self.velocity = VEC_ORIGIN;
	}
	if ((((time > self.attack_finished) && (self.currentammo == WF_NORMAL)) && (self.weapon != IT_AXE)))
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
	}
};

void() CheckPowerups =
{
	if ((self.health <= WF_NORMAL))
	{
		return;
	}
	if (self.invisible_finished)
	{
		if ((self.invisible_sound < time))
		{
			sound(self, CHAN_AUTO, "items/inv3.wav", MON_BACKTIME, ATTN_IDLE);
			self.invisible_sound = (time + ((random() * LOGIC_FINDDEFEND) + CHSCAM_ON));
		}
		if ((self.invisible_finished < (time + LOGIC_FINDDEFEND)))
		{
			if ((self.invisible_time == CHSCAM_ON))
			{
				sprint(self, "Ring of Shadows magic is fading\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/inv2.wav", CHSCAM_ON, ATTN_NORM);
				self.invisible_time = (time + CHSCAM_ON);
			}
			if ((self.invisible_time < time))
			{
				self.invisible_time = (time + CHSCAM_ON);
				stuffcmd(self, "bf\n");
			}
		}
		if ((self.invisible_finished < time))
		{
			self.items = (self.items - IT_INVISIBILITY);
			self.invisible_finished = WF_NORMAL;
			self.invisible_time = WF_NORMAL;
		}
		self.frame = WF_NORMAL;
		self.modelindex = modelindex_eyes;
	}
	else
	{
		self.modelindex = modelindex_player;
	}
	if (self.invincible_finished)
	{
		if ((self.invincible_finished < (time + LOGIC_FINDDEFEND)))
		{
			if ((self.invincible_time == CHSCAM_ON))
			{
				sprint(self, "Protection is almost burned out\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/protect2.wav", CHSCAM_ON, ATTN_NORM);
				self.invincible_time = (time + CHSCAM_ON);
			}
			if ((self.invincible_time < time))
			{
				self.invincible_time = (time + CHSCAM_ON);
				stuffcmd(self, "bf\n");
			}
		}
		if ((self.invincible_finished < time))
		{
			self.items = (self.items - IT_INVULNERABILITY);
			self.invincible_time = WF_NORMAL;
			self.invincible_finished = WF_NORMAL;
		}
		if ((self.invincible_finished > time))
		{
			self.effects = (self.effects | EF_DIMLIGHT);
		}
		else
		{
			self.effects = (self.effects - (self.effects & EF_DIMLIGHT));
		}
	}
	if (self.super_damage_finished)
	{
		if ((self.super_damage_finished < (time + LOGIC_FINDDEFEND)))
		{
			if ((self.super_time == CHSCAM_ON))
			{
				sprint(self, "Quad Damage is wearing off\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/damage2.wav", CHSCAM_ON, ATTN_NORM);
				self.super_time = (time + CHSCAM_ON);
			}
			if ((self.super_time < time))
			{
				self.super_time = (time + CHSCAM_ON);
				stuffcmd(self, "bf\n");
			}
		}
		if ((self.super_damage_finished < time))
		{
			self.items = (self.items - IT_QUAD);
			self.super_damage_finished = WF_NORMAL;
			self.super_time = WF_NORMAL;
		}
		if ((self.super_damage_finished > time))
		{
			self.effects = (self.effects | EF_DIMLIGHT);
		}
		else
		{
			self.effects = (self.effects - (self.effects & EF_DIMLIGHT));
		}
	}
	if (self.radsuit_finished)
	{
		self.air_finished = (time + 12);
		if ((self.radsuit_finished < (time + LOGIC_FINDDEFEND)))
		{
			if ((self.rad_time == CHSCAM_ON))
			{
				sprint(self, "Air supply in Biosuit expiring\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/suit2.wav", CHSCAM_ON, ATTN_NORM);
				self.rad_time = (time + CHSCAM_ON);
			}
			if ((self.rad_time < time))
			{
				self.rad_time = (time + CHSCAM_ON);
				stuffcmd(self, "bf\n");
			}
		}
		if ((self.radsuit_finished < time))
		{
			self.items = (self.items - IT_SUIT);
			self.rad_time = WF_NORMAL;
			self.radsuit_finished = WF_NORMAL;
		}
	}
};

void() PlayerPostThink =
{
	//local float mspeed; // unused
	//local float aspeed; // unused
	//local float r; // unused

	if ((self.view_ofs == VEC_ORIGIN))
	{
		return;
	}
	if (self.deadflag)
	{
		return;
	}
	W_WeaponFrame();
	if ((((self.jump_flag < -300) && (self.flags & FL_ONGROUND)) && (self.health > WF_NORMAL)))
	{
		if ((self.watertype == CONTENT_WATER))
		{
			sound(self, CHAN_BODY, "player/h2ojump.wav", CHSCAM_ON, ATTN_NORM);
		}
		else
		{
			if ((self.jump_flag < -650))
			{
				T_Damage(self, world, world, SVC_SETVIEWPORT);
				sound(self, CHAN_VOICE, "player/land2.wav", CHSCAM_ON, ATTN_NORM);
				self.deathtype = "falling";
			}
			else
			{
				sound(self, CHAN_VOICE, "player/land.wav", CHSCAM_ON, ATTN_NORM);
			}
		}
		self.jump_flag = WF_NORMAL;
	}
	if (!(self.flags & FL_ONGROUND))
	{
		self.jump_flag = self.velocity_z;
	}
	CheckPowerups();
};

void() ClientConnect =
{
	local entity e;

	bprint(self.netname);
	bprint(" entered the game\n");
	e = find(world, classname, "player");
	while (e)
	{
		if ((e.exp > WF_NORMAL))
		{
			bprint(self.netname);
			bprint(" banned. too late join. (can join only after map restart)\n");
			self.think = ClientBan;
			self.nextthink = (time + H_MEGA);
		}
		e = find(e, classname, "player");
	}
	if (intermission_running)
	{
		ExitIntermission();
	}
};

void() ClientDisconnect =
{
	if (gameover)
	{
		return;
	}
	bprint(self.netname);
	bprint(" left the game with ");
	bprint(ftos(self.frags));
	bprint(" frags\n");
	sound(self, CHAN_BODY, "player/tornoff2.wav", CHSCAM_ON, ATTN_NONE);
	set_suicide_frame();
};

void(entity targ, entity attacker) ClientObituary =
{
	bprint(targ.netname);
	bprint(" was slain by ");
	bprint(attacker.prefix_one);
	bprint(attacker.prefix_two);
	bprint(attacker.netname);
	bprint(attacker.prefix_three);
	bprint(attacker.prefix_four);
	bprint("\n");
};

void() removebody =
{
	self.think = SUB_Remove;
	self.nextthink = time + moon_get_spawn_delay();
};

void() playe_die_ax1 = [ 0, playe_die_ax2 ]
{
};

void() playe_die_ax2 = [ 1, playe_die_ax3 ]
{
};

void() playe_die_ax3 = [ 2, playe_die_ax4 ]
{
};

void() playe_die_ax4 = [ 3, playe_die_ax5 ]
{
};

void() playe_die_ax5 = [ 4, playe_die_ax6 ]
{
};

void() playe_die_ax6 = [ 5, playe_die_ax7 ]
{
};

void() playe_die_ax7 = [ 6, playe_die_ax8 ]
{
};

void() playe_die_ax8 = [ 7, removebody ]
{
};

void() playe_died1 = [ 8, playe_died2 ]
{
};

void() playe_died2 = [ 9, playe_died3 ]
{
};

void() playe_died3 = [ 10, playe_died4 ]
{
};

void() playe_died4 = [ 11, playe_died5 ]
{
};

void() playe_died5 = [ 12, playe_died6 ]
{
};

void() playe_died6 = [ 13, playe_died7 ]
{
};

void() playe_died7 = [ 14, playe_died8 ]
{
};

void() playe_died8 = [ 15, playe_died9 ]
{
};

void() playe_died9 = [ 16, removebody ]
{
};

void() DieUnhead =
{
	local entity e;

	e = spawn();
	setmodel(e, "progs/player_n.mdl");
	e.origin = self.origin;
	e.solid = SOLID_NOT;
	setsize(e, VEC_HULL_MIN, VEC_HULL_MAX);
	e.angles = self.angles;
	e.angles_x = WF_NORMAL;
	e.flags = self.flags;
	e.movetype = MOVETYPE_TOSS;
	e.colormap = self.colormap;
	e.velocity_x = (100 * crandom());
	e.velocity_y = (100 * crandom());
	e.velocity_z = WF_NORMAL;
	if ((self.weapon == IT_AXE))
	{
		e.think = playe_die_ax1;
	} else {
		e.think = playe_died1;
	}
	e.nextthink = time;
	ThrowHead("progs/h_player.mdl", self.health);
	self.deadflag = DEAD_DEAD;
	sound(self, CHAN_VOICE, "player/gib.wav", CHSCAM_ON, ATTN_NONE);
	if ((self.classname == MOON_GUARD_CLASSNAME))
	{
		self.think = SUB_Remove;
		self.nextthink = time + moon_get_spawn_delay();
	}
};
