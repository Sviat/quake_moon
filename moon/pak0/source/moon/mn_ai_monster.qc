/// ReProjectMoon-specific source file
/// Here go all functions related to AI monster behavior
/// Below is merge of refactored decompiled code and Moon source


void() ExplodeAlert_think =
{
	if (!self.owner)
	{
		remove(self);
	}
	if ((self.owner == world))
	{
		remove(self);
	}
	if ((self.owner.classname == "exploded"))
	{
		remove(self);
	}
	self.think = ExplodeAlert_think;
	self.nextthink = (time + 0.25);
};

void(entity own, vector org) ExplodeAlert =
{
	local entity missile;

	missile = spawn();
	missile.movetype = MOVETYPE_NONE;
	missile.solid = SOLID_TRIGGER;
	missile.classname = "explode";
	missile.owner = own;
	missile.think = ExplodeAlert_think;
	missile.nextthink = time;
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, org);
};

void() mon_evade = // full of black magic
{
	//local float dist; // unused
	local vector vec;
	local vector org;
	//local entity e; // unused
	local float yw;
	local entity head;

	self.flags = (self.flags - (self.flags & FL_ONGROUND));
	makevectors(self.angles);
	if ((self.next_strafe_time < time))
	{
		vec = (self.enemy.origin - self.origin);
		yw = vectoyaw((self.enemy.origin - self.origin));
		vec = org;
		if ((random() < MON_BACKTIME))
		{
			vec = (((v_right * self.speed) * CONTENT_EMPTY) - (v_forward * 100));
		}
		else
		{
			vec = ((v_right * self.speed) - (v_forward * 100));
		}
		if ((self.enemy.classname == MOON_HEART_CLASSNAME))
		{
			if ((random() < MON_BACKTIME))
			{
				if ((vlen((self.enemy.origin - self.origin)) > 300))
				{
					vec = ((self.enemy.origin - self.origin) * self.speed);
				}
			}
			if ((random() < MON_BACKTIME))
			{
				if ((vlen((self.enemy.origin - self.origin)) < 200))
				{
					vec = ((self.enemy.origin + self.origin) * self.speed);
				}
			}
		}
		if ((mapname == "moon4"))
		{
			if ((self.enemy.classname == "shoot_ent"))
			{
				if (((self.origin_x < -360) || (self.origin_x > GRD_FIGHTDIST)))
				{
					vec = (('10 -700 -360' - self.origin) * self.speed);
					self.velocity = VEC_ORIGIN;
					self.next_strafe_time = ((time + 0.3) + (MON_STUCKTIME / random()));
				}
				if ((self.origin_y < -840))
				{
					self.enemy = world;
					self.movetarget = world;
					self.goalentity = world;
					FindWaypoint();
					return;
				}
				if ((self.origin_y > -240))
				{
					vec = (('10 -700 -360' - self.origin) * self.speed);
					self.velocity = VEC_ORIGIN;
					self.next_strafe_time = ((time + 0.3) + (MON_STUCKTIME / random()));
				}
				if ((random() < MON_BACKTIME))
				{
					if ((vlen((self.enemy.origin - self.origin)) > 600))
					{
						vec = ((self.enemy.origin - self.origin) * self.speed);
						self.velocity = VEC_ORIGIN;
						self.next_strafe_time = ((time + 0.3) + (MON_STUCKTIME / random()));
					}
				}
				if ((random() < MON_BACKTIME))
				{
					if ((vlen((self.enemy.origin - self.origin)) < 200))
					{
						self.velocity = VEC_ORIGIN;
						vec = ((self.enemy.origin + self.origin) * self.speed);
						self.next_strafe_time = ((time + 0.3) + (MON_STUCKTIME / random()));
					}
				}
			}
		}
		vec = (vec + self.velocity);
		self.strafe_vector = normalize(vec);
		self.strafe_vector_z = WF_NORMAL;
		self.next_strafe_time = ((time + 0.3) + (MON_STUCKTIME / random()));
	}
	head = findradius(self.origin, 200);
	while (head)
	{
		if (((head.classname == "grenade") || (head.classname == "explode")))
		{
			if ((head.owner.flags & FL_CLIENT))
			{
				vec = ((self.origin - head.origin) + self.velocity);
				vec = (vec * self.speed);
				self.strafe_vector = normalize(vec);
				self.strafe_vector_z = WF_NORMAL;
			}
		}
		head = head.chain;
	}
	self.velocity = (self.strafe_vector * self.speed);

	if ( rint(vlen(self.velocity)) > rint(self.speed) )
	{
		dprint("warning: monster speed overload. maxspeed: {0}. Current: {1}.\n", floor_ftos(self.speed), floor_ftos(vlen(self.velocity)));
	}
	if (!CanDamage(self.enemy, self))
	{
		self.enemy = world;
		self.movetarget = world;
		self.goalentity = world;
		FindWaypoint();
	}
	botCheckForStep((self.origin - self.velocity));
};

void() mon_find_player =
{
	local entity e;
	local entity pl;
	local entity sel;
	local entity plsel;
	local float mindist;
	local float f;

	if ((self.nextfind_time > time))
	{
		return;
	}
	mindist = 99999;
	f = FALSE;
	pl = find(world, classname, "player");
	while (pl)
	{
		if ((vlen((pl.origin - self.origin)) < mindist))
		{
			if ((pl.health > WF_NORMAL))
			{
				mindist = vlen((pl.origin - self.origin));
				plsel = pl;
			}
		}
		pl = find(pl, classname, "player");
	}
	if ((plsel == world))
	{
		return;
	}
	bprint("player found\n");
	mindist = 99999;
	e = find(world, classname, "waypoint");
	while (e)
	{
		if (CanDamage(e, plsel))
		{
			if ((vlen((plsel.origin - e.origin)) < mindist))
			{
				mindist = vlen((plsel.origin - e.origin));
				sel = e;
			}
		}
		e = find(e, classname, "waypoint");
	}
	if ((sel == world))
	{
		return;
	}
	self.wantnum = sel.num;
	self.wantline = sel.line;
	self.nextfind_time = (time + 0.75);
};

void() MaybeShootGate =
{
	local entity e;
	local entity a;

	if ((self.next_gate > time))
	{
		return;
	}
	self.next_gate = (time + 0.12);
	e = find(world, classname, MOON_GATE_CLASSNAME);
	if (e)
	{ // black magic ahead
		if ((e.health > WF_NORMAL))
		{
			a = find(world, classname, "shoot_ent");
			if (a)
			{
				if ((a.gatename == e.gatename))
				{
					if ((a.health > WF_NORMAL))
					{
						if ((vlen((a.origin - self.origin)) < 650))
						{
							if (CanDamage(a, self))
							{
								a.health = 1;
								self.enemy = a;
								return;
							}
						}
					}
				}
			}
		}
	}
	return;
};

float() MaybeShootHeart =
{
	local entity e;

	if ((self.next_heart > time))
	{
		return (FALSE);
	}
	self.next_heart = (time + 0.1324);
	if ((self.enemy.classname == MOON_HEART_CLASSNAME))
	{
		return (FALSE);
	}
	e = find(world, classname, MOON_HEART_CLASSNAME);
	if (e)
	{
		if ((e.health > WF_NORMAL))
		{
			if ((vlen((e.origin - self.origin)) < 250))
			{
				if (CanDamage(e, self))
				{
					self.enemy = e;
					return (TRUE);
				}
			}
		}
	}
	return (FALSE);
};

void() mon_find_enemy =
{
	local entity head;
	//local entity selected; // unused
	local float dist;

	if (((self.enemy != world) && (self.enemy.classname != "idle_ent")))
	{
		return;
	}
	dist = 1500;
	head = findradius(self.origin, 1500);
	while (head)
	{
		if ((head.flags & FL_CLIENT))
		{
			if (!(head.flags & FL_NOTARGET))
			{
				if (((head.health > WF_NORMAL) && (head != self)))
				{
					if (BotCanSeePlayer(head))
					{
						self.enemy = head;
						self.camp_time = WF_NORMAL;
						self.show_hostile = ((time + self.hst) + (random() / 10));
					}
				}
			}
		}
		head = head.chain;
	}
};

entity() mon_find_ill_mon =
{
	local entity head;
	local entity selected;
	local float dist;
	local float mindist;

	if (self.enemy)
	{
		return (world); // return;
	}
	dist = 1500;
	mindist = 99999;
	selected = world;
	head = findradius(self.origin, 1500);
	while (head)
	{
		if ((head.flags & FL_MONSTER))
		{
			if (((head.health > WF_NORMAL) && (head != self)))
			{
				if (BotCanSeePlayer(head))
				{
					if ((head.health < head.max_health))
					{
						if ((vlen((head.origin - self.origin)) < mindist))
						{
							selected = head;
							mindist = vlen((head.origin - self.origin));
						}
					}
				}
			}
		}
		head = head.chain;
	}
	if ((selected != world))
	{
		return (selected);
	}
	if ((self.health < self.max_health))
	{
		if ((self.health > WF_NORMAL))
		{
			return (self);
		}
		else
		{
			return (world);
		}
	}

	return (world); // shouldnt happen, supress "not all control paths return a value"
};

void() mon_run_slide =
{
	return; // disabled by original creator
	//local float ofs; // unused
	/*
	if ((random() < 0.05))
	{
		self.lefty = (1 - self.lefty);
	}
	ChangeYaw();
	if (self.lefty)
	{
		ofs = MENTAT_TIME;
	}
	else
	{
		ofs = -90;
	}
	if (walkmove((self.ideal_yaw + ofs), movedist))
	{
		return;
	}
	self.lefty = (1 - self.lefty);
	walkmove((self.ideal_yaw - ofs), movedist);
	*/ // supress "contains unreachable code" warning
};

void() mon_think = // Some stack overflow detected on FTE engine here (mon_think -> army_run -> mon_ai_run -> army_stand -> mon_ai_stand -> army_run)
{
	if (gameover)
	{
		return;
	}
	moon_monster_apply_effect_self();
	if (((self.mon_logic == LOGIC_CAMPER) && (self.enemy == world)))
	{
		self.wantnum = self.camp_num;
		self.wantline = self.camp_line;
	}
	else
	{
		if ((self.melee != 1))
		{
			self.wantline = 1;
			self.wantnum = WF_NORMAL;
		}
	}
	if (((self.mon_logic == LOGIC_HUNTER) || (self.melee == 1)))
	{
		mon_find_player();
	}
	if (!visible(self.goalentity))
	{
		if (self.goalentity)
		{
			self.movetarget = world;
			self.goalentity = world;
		}
	}
	MaybeShootGate();
	MaybeShootHeart();
	mon_find_enemy();
	if ((((self.currentammo == 0) && (gameover == FALSE)) && (self.camp_time < time)))
	{
		if (FindWaypoint())
		{
			self.th_run(); // Infinite loop possibility: run from stand
		}
	}
};

void() mon_ai_stand =
{
	local float dst;

	self.currentammo = 0; // Sign of ???
	if (!gameover)
	{
		dst = vlen((self.goalentity.origin - self.origin));
		visible(self.goalentity);
		if ((visible(self.goalentity) && (self.goalentity.classname == "waypoint")))
		{
			self.ideal_yaw = vectoyaw((self.goalentity.origin - self.origin));
			self.currentammo = 1; // Sign of ???
			self.th_run(); // Infinite loop possibility: run from stand
			return;
		}
		mon_think();
		if ((self.camp_time > time))
		{
			if (self.enemy)
			{
				if ((self.mon_logic == LOGIC_STANDART))
				{
					self.camp_time = CONTENT_EMPTY;
					self.currentammo = 1; // Sign of ???
					self.th_run(); // Infinite loop possibility: run from stand
					return;
				}
			}
			if ((self.nextyaw < time))
			{
				self.ideal_yaw = (random() * 360);
				self.nextyaw = ((time + MON_STUCKTIME) + (1 * random()));
			}
			ChangeYaw();
		}
	}
	self.velocity = VEC_ORIGIN;
};

void() idle_ent_think =
{
	if (((((((self.attack_finished < time) || (self.owner.enemy != self)) || (self.enemy.health <= WF_NORMAL)) || (self.owner.health <= WF_NORMAL)) || !self.enemy) || !self.owner))
	{
		if (self.owner)
		{
			if ((self.owner.enemy == self))
			{
				self.owner.enemy = world;
			}
		}
		remove(self);
		return;
	}
	self.nextthink = (time + MON_CAMPERCHANCE);
	self.think = idle_ent_think;
};

void(entity who) moon_monster_medic_try_heal = // TODO: implement one day
{
	local entity target;

	if ( who.medic != 1 ) // not used yet
	{
		return;
	}
	if ( who.radsuit_finished < time )
	{
		return;
	}

	target = mon_find_ill_mon();
	if ((target != world))
	{
		moon_particle_heal(target);
		target.health = target.health + 5;
		if ( target.health > target.max_health )
		{
			target.health = target.max_health;
		}
		bprint("healing...\n ");
	}
	who.radsuit_finished = (time + 0.1);
};

void(float dist) mon_ai_run = // OMNISSIAH save our souls!
{
	local vector vec;
	local float dst;
	local float stream;
	local entity e;
	local entity mx;
	local float nm;

	self.currentammo = 1; // Sign of ???
	moon_monster_medic_try_heal(self);
	CheckEdge(self.goalentity);
	if (((gameover == TRUE) || (self.camp_time > time)))
	{
		if (self.enemy)
		{
			self.camp_time = WF_NORMAL;
		}
		self.th_stand();
		return;
	}
	mon_think();
	if (((self.goalentity == world) || !visible(self.goalentity)))
	{
		FindWaypoint();
		return;
	}
	dst = vlen((self.goalentity.origin - self.origin));
	movedist = dist;
	if (((self.enemy.classname == "shoot_ent") || (self.enemy.classname == MOON_HEART_CLASSNAME)))
	{
		self.ideal_yaw = vectoyaw((self.enemy.origin - self.origin));
		ChangeYaw();
		if (CanCarefulDamage(self, self.enemy))
		{
			if ((self.show_hostile < time))
			{
				if ((moon_FacingIdeal() == TRUE))
				{
					if ((self.attack_finished < time))
					{
						self.th_missile();
					}
					else
					{
						self.ideal_yaw = vectoyaw((self.enemy.origin - self.origin));
						ChangeYaw();
					}
				}
			}
		}
		if (((self.enemy == world) || (self.enemy.health <= WF_NORMAL)))
		{
			self.enemy = world;
		}
		mon_evade();
		return;
	}
	if ((self.flags & FL_PARTIALGROUND))
	{
		botCheckForStep(((self.goalentity.origin - self.origin) * self.speed));
	}
	if ((self.flags & FL_ONGROUND))
	{
		if ((self.melee == 1))
		{
			if ((vlen((self.enemy.origin - self.origin)) < 222))
			{
				CheckEdge(self.enemy);
				self.flags = (self.flags - (self.flags & FL_ONGROUND));
				vec = normalize((self.enemy.origin - self.origin));
				self.velocity = (vec * self.speed);
				self.ideal_yaw = vectoyaw((self.enemy.origin - self.origin));
				ChangeYaw();
				return;
			}
		}
		vec = (self.goalentity.origin - self.origin);
		self.flags = (self.flags - (self.flags & FL_ONGROUND));
		vec_z = WF_NORMAL;
		if ((self.next_spam < time))
		{
			stream = ((self.goalentity.radius / 2) + ((self.goalentity.radius / 2) * random()));
			if ((vlen((self.goalentity.origin - self.origin)) < 240))
			{
				stream = rint((stream / 2));
			}
			if ((stream > self.speed))
			{
				stream = self.speed;
			}
			if ((random() < MON_BACKTIME))
			{
				self.spam_vector = ((v_right * stream) * CONTENT_EMPTY);
			}
			else
			{
				self.spam_vector = (v_right * stream);
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
			self.stuck_time = (time + MON_STUCKTIME);
		}
		if ((self.rstuck_time > time))
		{
			vec = self.rstuck_org;
		}
		else
		{
			vec = (vec + self.spam_vector);
		}
		vec = normalize(vec);
		if ((self.goalentity.origin_z < self.origin_z))
		{
			if ((self.flags & FL_PARTIALGROUND))
			{
				self.flags = (self.flags - FL_PARTIALGROUND);
			}
			self.ideal_yaw = vectoyaw(((self.goalentity.origin - self.origin) + self.spam_vector));
			if ((self.enemy.classname == "shoot_ent"))
			{
				self.spam_vector = (v_right * 1000);
			}
			vec = normalize((((self.goalentity.origin - self.origin) + self.spam_vector) + self.velocity));
			vec_z = WF_NORMAL;
		}
		else
		{
			self.ideal_yaw = vectoyaw((self.goalentity.origin - self.origin));
			vec = (self.goalentity.origin - self.origin);
			if ((self.rstuck_time > time))
			{
				vec = self.rstuck_org;
			}
			else
			{
				vec = (vec + self.spam_vector);
			}
			vec = normalize(vec);
			vec_z = WF_NORMAL;
			if (!(self.flags & FL_PARTIALGROUND))
			{
				self.flags = (self.flags + FL_PARTIALGROUND);
			}
		}
		self.velocity = (vec * self.speed);

		if ( rint(vlen(self.velocity)) > rint(self.speed) )
		{
			dprint("warning: monster speed overload. maxspeed: {0}. Current: {1}.\n", floor_ftos(self.speed), floor_ftos(vlen(self.velocity)));
		}
	}
	if (self.enemy)
	{
		if (!CanDamage(self, self.enemy))
		{
			if ((self.enemy.flags & FL_CLIENT))
			{
				if ((self.mon_logic != LOGIC_CAMPER))
				{
					nm = WF_NORMAL;
					mx = find(world, classname, "idle_ent");
					while (mx)
					{
						nm = (nm + 1);
						mx = find(mx, classname, "idle_ent");
						if ((nm >= IDLE_MAX))
						{
							self.enemy = world;
							return;
						}
					}
					if ((self.enemy != world))
					{
						e = spawn();
						setorigin(e, self.postenemy_org);
						e.nextthink = (time + MON_CAMPERCHANCE);
						e.attack_finished = (time + IDLE_TIME);
						e.think = idle_ent_think;
						e.health = 1;
						e.enemy = self.enemy;
						e.owner = self;
						e.classname = "idle_ent";
						self.oldenemy = e;
						self.enemy = e;
						self.show_hostile = WF_NORMAL;
					}
				}
				else
				{
					self.enemy = world;
				}
			}
			return;
		}
		if (CanDamage(self, self.enemy))
		{
			if ((self.enemy.health > WF_NORMAL))
			{
				if ((moon_FacingIdeal() == TRUE))
				{
					if ((self.show_hostile < time))
					{
						if ((self.attack_finished < time))
						{
							self.th_missile();
						}
					}
				}
			}
		}
		if ((self.enemy.health <= WF_NORMAL))
		{
			self.enemy = world;
		}
		if ((self.enemy.flags & FL_CLIENT))
		{
			if ((self.postenemy_time < time))
			{
				self.postenemy_org = self.enemy.origin;
				self.postenemy_time = (time + 0.08);
			}
		}
		self.ideal_yaw = vectoyaw((self.enemy.origin - self.origin));
	}
	else
	{
		self.ideal_yaw = vectoyaw((self.goalentity.origin - self.origin));
	}
	ChangeYaw();
};