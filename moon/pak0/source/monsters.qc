//Decompiled code. Please respect the original copyright.

void() monster_use =
{
};

void() monster_death_use =
{
};

void() walkmonster_start_go =
{
	moon_normalize_difficulty();

	self.max_health = self.health;
	self.origin_z = (self.origin_z + CHSCAM_ON);
	droptofloor();
	if (!walkmove(0, 0))
	{
		dprint("walkmonster in wall at: ");
		dprint(vtos(self.origin));
		dprint("\n");
	}
	self.takedamage = DAMAGE_AIM;
	self.ideal_yaw = (self.angles * '0 1 0');
	if (!self.yaw_speed)
	{
		self.yaw_speed = TE_LIGHTNING3;
	}
	if (!self.min_attack_dist)
	{
		self.min_attack_dist = 3000;
	}
	self.view_ofs = '0 0 25';
	self.acc = (MOON_DIFFICULTY_MAX - skill);
	self.hst = (MON_BACKTIME - (skill / KEY_MOVERIGHT));
	self.rfr = (0.6 - (skill / SVC_SETVIEWPORT));
	self.mx_speed = self.speed;
	self.use = monster_use;
	self.flags = (self.flags | FL_MONSTER);
	self.classname = MOON_MONSTER_CLASSNAME;
	self.th_stand();
	self.nextthink = (self.nextthink + (random() * MON_BACKTIME));
};

void() walkmonster_start =
{
	self.nextthink = (self.nextthink + MON_REFRESHTIME);
	self.think = walkmonster_start_go;
	self.max_health = self.health;
	self.classname = MOON_MONSTER_CLASSNAME;
};

void() flymonster_start_go =
{
	self.takedamage = DAMAGE_AIM;
	self.ideal_yaw = (self.angles * '0 1 0');
	if (!self.yaw_speed)
	{
		self.yaw_speed = SVC_SETVIEWANGLES;
	}
	self.view_ofs = '0 0 25';
	self.use = monster_use;
	self.flags = (self.flags | FL_FLY);
	self.flags = (self.flags | FL_MONSTER);
	if (!walkmove(WF_NORMAL, WF_NORMAL))
	{
		dprint("flymonster in wall at: ");
		dprint(vtos(self.origin));
		dprint("\n");
	}
	if (self.target)
	{
		self.movetarget = find(world, targetname, self.target);
		self.goalentity = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint("Monster can't find target at ");
			dprint(vtos(self.origin));
			dprint("\n");
		}
		if ((self.movetarget.classname == "path_corner"))
		{
			self.th_walk();
		}
		else
		{
			self.pausetime = 100000000;
		}
		self.th_stand();
	}
	else
	{
		self.pausetime = 100000000;
		self.th_stand();
	}
};

void() flymonster_start =
{
	self.nextthink = (self.nextthink + (random() * MON_BACKTIME));
	self.think = flymonster_start_go;
	// total_monsters = (total_monsters + 1); // Moon can count monsters itself
};

void() swimmonster_start_go =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	self.takedamage = DAMAGE_AIM;
	// total_monsters = (total_monsters + 1); // Moon can count monsters itself
	self.ideal_yaw = (self.angles * '0 1 0');
	if (!self.yaw_speed)
	{
		self.yaw_speed = SVC_SETVIEWANGLES;
	}
	self.view_ofs = '0 0 10';
	self.use = monster_use;
	self.flags = (self.flags | FL_SWIM);
	self.flags = (self.flags | FL_MONSTER);
	if (self.target)
	{
		self.movetarget = find(world, targetname, self.target);
		self.goalentity = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint("Monster can't find target at ");
			dprint(vtos(self.origin));
			dprint("\n");
		}
		self.ideal_yaw = vectoyaw((self.goalentity.origin - self.origin));
		self.th_walk();
	}
	else
	{
		self.pausetime = 100000000;
		self.th_stand();
	}
	self.nextthink = (self.nextthink + (random() * MON_BACKTIME));
};

void() swimmonster_start =
{
	self.nextthink = (self.nextthink + (random() * MON_BACKTIME));
	self.think = swimmonster_start_go;
	// total_monsters = (total_monsters + 1); // Moon can count monsters itself
};
