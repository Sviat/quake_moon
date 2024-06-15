//Decompiled code. Please respect the original copyright.
float DOOR_START_OPEN    = 1;
float DOOR_DONT_LINK    = 4;
float DOOR_GOLD_KEY    = 8;
float DOOR_SILVER_KEY    = 16;
float DOOR_TOGGLE    = 32;
void() door_go_down;
void() door_go_up;

void() door_blocked =
{
	T_Damage(other, self, self, self.dmg);
	if ((self.wait >= WF_NORMAL))
	{
		if ((self.state == STATE_DOWN))
		{
			door_go_up();
		}
		else
		{
			door_go_down();
		}
	}
};

void() door_hit_top =
{
	sound(self, CHAN_VOICE, self.noise1, CHSCAM_ON, ATTN_NORM);
	self.state = STATE_TOP;
	if ((self.spawnflags & DOOR_TOGGLE))
	{
		return;
	}
	self.think = door_go_down;
	self.nextthink = (self.ltime + self.wait);
};

void() door_hit_bottom =
{
	local entity e;

	sound(self, CHAN_VOICE, self.noise1, CHSCAM_ON, ATTN_NORM);
	self.state = STATE_BOTTOM;
	if ((self.classname == "gate"))
	{
		e = find(world, classname, "shoot_ent");
		while ((e != world))
		{
			if ((e.gatename == self.gatename))
			{
				e.health = CHSCAM_ON;
			}
			e = find(e, classname, "shoot_ent");
		}
	}
};

void() door_go_down =
{
	sound(self, CHAN_VOICE, self.noise2, CHSCAM_ON, ATTN_NORM);
	if (self.max_health)
	{
		if ((self.classname == "gate"))
		{
			self.takedamage = DAMAGE_AIM;
		}
		else
		{
			self.takedamage = DAMAGE_YES;
		}
		self.health = self.max_health;
	}
	self.state = STATE_DOWN;
	SUB_CalcMove(self.pos1, self.speed, door_hit_bottom);
};

void() door_go_up =
{
	if ((self.state == STATE_UP))
	{
		return;
	}
	if ((self.state == STATE_TOP))
	{
		self.nextthink = (self.ltime + self.wait);
		return;
	}
	sound(self, CHAN_VOICE, self.noise2, CHSCAM_ON, ATTN_NORM);
	self.state = STATE_UP;
	SUB_CalcMove(self.pos2, self.speed, door_hit_top);
	SUB_UseTargets();
};

void() door_fire =
{
	local entity oself;
	local entity starte;

	if ((self.owner != self))
	{
		objerror("door_fire: self.owner != self");
	}
	if (self.items)
	{
		sound(self, CHAN_VOICE, self.noise4, CHSCAM_ON, ATTN_NORM);
	}
	self.message = string_null;
	oself = self;
	if ((self.spawnflags & DOOR_TOGGLE))
	{
		if (((self.state == STATE_UP) || (self.state == STATE_TOP)))
		{
			starte = self;
			do
			{
				door_go_down();
				self = self.enemy;

			} while (((self != starte) && (self != world)));
			self = oself;
			return;
		}
	}
	starte = self;
	do
	{
		door_go_up();
		self = self.enemy;

	} while (((self != starte) && (self != world)));
	self = oself;
};

void() door_use =
{
	local entity oself;

	self.message = s_wiz;
	self.owner.message = s_wiz;
	self.enemy.message = s_wiz;
	oself = self;
	self = self.owner;
	door_fire();
	self = oself;
};

void() door_trigger_touch =
{
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	if ((time < self.attack_finished))
	{
		return;
	}
	self.attack_finished = (time + CHSCAM_ON);
	activator = other;
	self = self.owner;
	door_use();
};

void() shoot_ent_think =
{
	if ((self.health >= WF_NORMAL))
	{
		self.nextthink = CONTENT_EMPTY;
		return;
	}
	self.nextthink = (time + MON_REACTIONTIME);
	self.think = shoot_ent_think;
};

void() door_killed =
{
	local entity oself;
	local entity e;

	oself = self;
	self = self.owner;
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;
	self.wait = SVC_SETVIEWANGLES;
	door_use();
	self = oself;
	if ((self.classname == "gate"))
	{
		e = find(world, classname, "shoot_ent");
		while ((e != world))
		{
			if ((e.gatename == self.gatename))
			{
				if ((up_alert >= 1))
				{
					makechatnoise();
					bprint("Gate security alert!\n");
					e.think = shoot_ent_think;
					e.nextthink = (time + MON_CAMPERCHANCE);
				}
				e.health = CONTENT_EMPTY;
			}
			e = find(e, classname, "shoot_ent");
		}
	}
};

void() door_touch =
{
	local entity e;

	if (((other.classname != "player") && (other.classname != "guard")))
	{
		return;
	}
	if ((self.classname == "gate"))
	{
		e = find(world, classname, "shoot_ent");
		while ((e != world))
		{
			if ((e.gatename == self.gatename))
			{
				e.health = CONTENT_EMPTY;
			}
			e = find(e, classname, "shoot_ent");
		}
	}
	self.takedamage = DAMAGE_NO;
	self.wait = SVC_SETVIEWPORT;
	self.health = self.max_health;
	door_use();
};

entity(vector fmins, vector fmaxs) spawn_field =
{
	local entity trigger;
	local vector t1;
	local vector t2;

	trigger = spawn();
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = self;
	trigger.touch = door_trigger_touch;
	t1 = fmins;
	t2 = fmaxs;
	setsize(trigger, (t1 - '60 60 8'), (t2 + '60 60 8'));
	return (trigger);
};

float(entity e1, entity e2) EntitiesTouching =
{
	if ((e1.mins_x > e2.maxs_x))
	{
		return (FALSE);
	}
	if ((e1.mins_y > e2.maxs_y))
	{
		return (FALSE);
	}
	if ((e1.mins_z > e2.maxs_z))
	{
		return (FALSE);
	}
	if ((e1.maxs_x < e2.mins_x))
	{
		return (FALSE);
	}
	if ((e1.maxs_y < e2.mins_y))
	{
		return (FALSE);
	}
	if ((e1.maxs_z < e2.mins_z))
	{
		return (FALSE);
	}
	return (TRUE);
};

void() LinkDoors =
{
	local entity t;
	local entity starte;
	local vector cmins;
	local vector cmaxs;

	if (self.enemy)
	{
		return;
	}
	if ((self.spawnflags & DOOR_DONT_LINK))
	{
		self.enemy = self;
		self.owner = self;
		return;
	}
	cmins = self.mins;
	cmaxs = self.maxs;
	starte = self;
	t = self;
	do
	{
		self.owner = starte;
		if (self.health)
		{
			starte.health = self.health;
		}
		if (self.targetname)
		{
			starte.targetname = self.targetname;
		}
		if ((self.message != s_wiz))
		{
			starte.message = self.message;
		}
		t = find(t, classname, self.classname);
		if (!t)
		{
			self.enemy = starte;
			self = self.owner;
			if (self.health)
			{
				return;
			}
			if (self.targetname)
			{
				return;
			}
			if (self.items)
			{
				return;
			}
			self.owner.trigger_field = spawn_field(cmins, cmaxs);
			return;
		}
		if (EntitiesTouching(self, t))
		{
			if (t.enemy)
			{
				objerror("cross connected doors");
			}
			self.enemy = t;
			self = t;
			if ((t.mins_x < cmins_x))
			{
				cmins_x = t.mins_x;
			}
			if ((t.mins_y < cmins_y))
			{
				cmins_y = t.mins_y;
			}
			if ((t.mins_z < cmins_z))
			{
				cmins_z = t.mins_z;
			}
			if ((t.maxs_x > cmaxs_x))
			{
				cmaxs_x = t.maxs_x;
			}
			if ((t.maxs_y > cmaxs_y))
			{
				cmaxs_y = t.maxs_y;
			}
			if ((t.maxs_z > cmaxs_z))
			{
				cmaxs_z = t.maxs_z;
			}
		}

	} while (CHSCAM_ON);
};

void() func_door =
{
	if ((world.worldtype == WF_NORMAL))
	{
		precache_sound("doors/medtry.wav");
		precache_sound("doors/meduse.wav");
		self.noise3 = "doors/medtry.wav";
		self.noise4 = "doors/meduse.wav";
	}
	else
	{
		if ((world.worldtype == CHSCAM_ON))
		{
			precache_sound("doors/runetry.wav");
			precache_sound("doors/runeuse.wav");
			self.noise3 = "doors/runetry.wav";
			self.noise4 = "doors/runeuse.wav";
		}
		else
		{
			if ((world.worldtype == H_MEGA))
			{
				precache_sound("doors/basetry.wav");
				precache_sound("doors/baseuse.wav");
				self.noise3 = "doors/basetry.wav";
				self.noise4 = "doors/baseuse.wav";
			}
			else
			{
				dprint("no worldtype set!\n");
			}
		}
	}
	if ((self.sounds == WF_NORMAL))
	{
		precache_sound("misc/null.wav");
		precache_sound("misc/null.wav");
		self.noise1 = "misc/null.wav";
		self.noise2 = "misc/null.wav";
	}
	if ((self.sounds == CHSCAM_ON))
	{
		precache_sound("doors/drclos4.wav");
		precache_sound("doors/doormv1.wav");
		self.noise1 = "doors/drclos4.wav";
		self.noise2 = "doors/doormv1.wav";
	}
	if ((self.sounds == H_MEGA))
	{
		precache_sound("doors/hydro1.wav");
		precache_sound("doors/hydro2.wav");
		self.noise2 = "doors/hydro1.wav";
		self.noise1 = "doors/hydro2.wav";
	}
	if ((self.sounds == LOGIC_FINDDEFEND))
	{
		precache_sound("doors/stndr1.wav");
		precache_sound("doors/stndr2.wav");
		self.noise2 = "doors/stndr1.wav";
		self.noise1 = "doors/stndr2.wav";
	}
	if ((self.sounds == DOOR_DONT_LINK))
	{
		precache_sound("doors/ddoor1.wav");
		precache_sound("doors/ddoor2.wav");
		self.noise1 = "doors/ddoor2.wav";
		self.noise2 = "doors/ddoor1.wav";
	}
	SetMovedir();
	self.max_health = self.health;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin(self, self.origin);
	setmodel(self, self.model);
	self.classname = "door";
	self.blocked = door_blocked;
	self.use = door_use;
	if ((self.spawnflags & DOOR_SILVER_KEY))
	{
		self.items = IT_KEY1;
	}
	if ((self.spawnflags & DOOR_GOLD_KEY))
	{
		self.items = IT_KEY2;
	}
	if (!self.speed)
	{
		self.speed = 100;
	}
	if (!self.wait)
	{
		self.wait = LOGIC_FINDDEFEND;
	}
	if (!self.lip)
	{
		self.lip = KEY_MOVERIGHT;
	}
	if (!self.dmg)
	{
		self.dmg = H_MEGA;
	}
	self.pos1 = self.origin;
	self.pos2 = (self.pos1 + (self.movedir * (fabs((self.movedir * self.size)) - self.lip)));
	if ((self.spawnflags & DOOR_START_OPEN))
	{
		setorigin(self, self.pos2);
		self.pos2 = self.pos1;
		self.pos1 = self.origin;
	}
	self.state = STATE_BOTTOM;
	if (self.health)
	{
		self.takedamage = DAMAGE_YES;
		self.th_die = door_killed;
	}
	if (self.items)
	{
		self.wait = CONTENT_EMPTY;
	}
	self.touch = door_touch;
	self.think = LinkDoors;
	self.nextthink = (self.ltime + MON_CAMPERCHANCE);
};

void() func_gate =
{
	if ((world.worldtype == WF_NORMAL))
	{
		precache_sound("doors/medtry.wav");
		precache_sound("doors/meduse.wav");
		self.noise3 = "doors/medtry.wav";
		self.noise4 = "doors/meduse.wav";
	}
	else
	{
		if ((world.worldtype == CHSCAM_ON))
		{
			precache_sound("doors/runetry.wav");
			precache_sound("doors/runeuse.wav");
			self.noise3 = "doors/runetry.wav";
			self.noise4 = "doors/runeuse.wav";
		}
		else
		{
			if ((world.worldtype == H_MEGA))
			{
				precache_sound("doors/basetry.wav");
				precache_sound("doors/baseuse.wav");
				self.noise3 = "doors/basetry.wav";
				self.noise4 = "doors/baseuse.wav";
			}
			else
			{
				dprint("no worldtype set!\n");
			}
		}
	}
	if ((self.sounds == WF_NORMAL))
	{
		precache_sound("misc/null.wav");
		precache_sound("misc/null.wav");
		self.noise1 = "misc/null.wav";
		self.noise2 = "misc/null.wav";
	}
	if ((self.sounds == CHSCAM_ON))
	{
		precache_sound("doors/drclos4.wav");
		precache_sound("doors/doormv1.wav");
		self.noise1 = "doors/drclos4.wav";
		self.noise2 = "doors/doormv1.wav";
	}
	if ((self.sounds == H_MEGA))
	{
		precache_sound("doors/hydro1.wav");
		precache_sound("doors/hydro2.wav");
		self.noise2 = "doors/hydro1.wav";
		self.noise1 = "doors/hydro2.wav";
	}
	if ((self.sounds == LOGIC_FINDDEFEND))
	{
		precache_sound("doors/stndr1.wav");
		precache_sound("doors/stndr2.wav");
		self.noise2 = "doors/stndr1.wav";
		self.noise1 = "doors/stndr2.wav";
	}
	if ((self.sounds == DOOR_DONT_LINK))
	{
		precache_sound("doors/ddoor1.wav");
		precache_sound("doors/ddoor2.wav");
		self.noise1 = "doors/ddoor2.wav";
		self.noise2 = "doors/ddoor1.wav";
	}
	self.health = 200;
	SetMovedir();
	self.max_health = self.health;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin(self, self.origin);
	setmodel(self, self.model);
	self.classname = "gate";
	self.blocked = door_blocked;
	self.use = door_use;
	if (!self.speed)
	{
		self.speed = 100;
	}
	if (!self.wait)
	{
		self.wait = LOGIC_FINDDEFEND;
	}
	if (!self.lip)
	{
		self.lip = KEY_MOVERIGHT;
	}
	if (!self.dmg)
	{
		self.dmg = 76;
	}
	self.pos1 = self.origin;
	self.pos2 = (self.pos1 + (self.movedir * (fabs((self.movedir * self.size)) - self.lip)));
	if ((self.spawnflags & DOOR_START_OPEN))
	{
		setorigin(self, self.pos2);
		self.pos2 = self.pos1;
		self.pos1 = self.origin;
	}
	self.state = STATE_BOTTOM;
	if (self.health)
	{
		self.takedamage = DAMAGE_AIM;
		self.th_die = door_killed;
	}
	if (self.items)
	{
		self.wait = CONTENT_EMPTY;
	}
	self.touch = door_touch;
	self.t_width = fabs((v_up * self.size));
	self.think = LinkDoors;
	self.nextthink = (self.ltime + MON_CAMPERCHANCE);
};

void() func_door_secret =
{
	remove(self);
};
//entity stemp; // unused
//entity otemp; // unused
entity s;
//entity old; // unused
float PLAYER_ONLY    = 1;
float SILENT    = 2;

void() play_teleport =
{
	local float v;
	local string tmpstr;

	v = (random() * SVC_SETVIEWPORT);
	if ((v < CHSCAM_ON))
	{
		tmpstr = "misc/r_tele1.wav";
	}
	else
	{
		if ((v < H_MEGA))
		{
			tmpstr = "misc/r_tele2.wav";
		}
		else
		{
			if ((v < LOGIC_FINDDEFEND))
			{
				tmpstr = "misc/r_tele3.wav";
			}
			else
			{
				if ((v < DOOR_DONT_LINK))
				{
					tmpstr = "misc/r_tele4.wav";
				}
				else
				{
					tmpstr = "misc/r_tele5.wav";
				}
			}
		}
	}
	sound(self, CHAN_VOICE, tmpstr, CHSCAM_ON, ATTN_NORM);
	remove(self);
};

void(vector org) spawn_tfog =
{
	s = spawn();
	s.origin = org;
	s.nextthink = (time + MON_REACTIONTIME);
	s.think = play_teleport;
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_TELEPORT);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
};

void() tdeath_touch =
{
	if ((other == self.owner))
	{
		return;
	}
	if ((other.classname == "player"))
	{
		if ((other.invincible_finished > time))
		{
			self.classname = "teledeath2";
		}
		if ((self.owner.classname != "player"))
		{
			T_Damage(self.owner, self, self, 50000);
			return;
		}
	}
	if (other.health)
	{
		other.ability = WF_NORMAL;
		if ((other.flags & FL_MONSTER))
		{
			remove(other);
		}
		else
		{
			T_Damage(other, self, self, 10000);
		}
	}
};

void(vector org, entity death_owner) spawn_tdeath =
{
	local entity death;

	death = spawn();
	death.classname = "teledeath";
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = VEC_ORIGIN;
	setsize(death, (death_owner.mins - '1 1 1'), (death_owner.maxs + '1 1 1'));
	setorigin(death, org);
	death.touch = tdeath_touch;
	death.nextthink = (time + MON_REACTIONTIME);
	death.think = SUB_Remove;
	death.owner = death_owner;
	force_retouch = H_MEGA;
};
float PUSH_ONCE    = 1;

void() trigger_push_touch =
{
	if ((other.classname == "missile"))
	{
		if ((other.owner.flags & FL_CLIENT))
		{
			other.think = T_MissileTouch;
			other.nextthink = time;
			return;
		}
	}
	if ((other.classname == "grenade"))
	{
		if ((other.owner.flags & FL_CLIENT))
		{
			other.think = GrenadeExplode;
			other.nextthink = time;
			return;
		}
	}
	if ((other.classname == "spike"))
	{
		if ((other.owner.flags & FL_CLIENT))
		{
			remove(other);
		}
	}
	if ((((other.classname != "player") && (other.classname != "guard")) && !(other.flags & FL_ITEM)))
	{
		return;
	}
	if (((self.cnt == CHSCAM_ON) && (other.classname == "guard")))
	{
		return;
	}
	if ((other.classname == "guard"))
	{
		if ((other.flags & FL_ONGROUND))
		{
			other.flags = (other.flags - FL_ONGROUND);
		}
	}
	if (((other.health > WF_NORMAL) || (other.flags & FL_ITEM)))
	{
		other.velocity = ((self.speed * self.movedir) * SVC_SETVIEWANGLES);
	}
};

void() trigger_push =
{
	InitTrigger();
	self.touch = trigger_push_touch;
	if (!self.speed)
	{
		self.speed = 1000;
	}
};

void() trigger_reactivate =
{
	remove(self);
};

void() multi_wait =
{
	remove(self);
};

void() multi_trigger =
{
	remove(self);
};

void() multi_killed =
{
	remove(self);
};

void() multi_use =
{
	remove(self);
};

void() multi_touch =
{
	remove(self);
};

void() trigger_multiple =
{
	remove(self);
};

void() trigger_once =
{
	remove(self);
};

void() trigger_relay =
{
	remove(self);
};

void() trigger_secret =
{
	remove(self);
};

void() trigger_counter =
{
	remove(self);
};

void() info_teleport_destination =
{
	remove(self);
};

void() trigger_teleport =
{
	remove(self);
};

void() trigger_setskill =
{
	remove(self);
};

void() trigger_onlyregistered =
{
	remove(self);
};

void() trigger_hurt =
{
	remove(self);
};

void() trigger_monsterjump =
{
	remove(self);
};

void() func_button =
{
	remove(self);
};

void() func_plat =
{
	remove(self);
};

void() func_train =
{
	remove(self);
};

void() misc_teleporttrain =
{
	remove(self);
};
