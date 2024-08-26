//Decompiled code. Please respect the original copyright.
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;
void() monster_death_use;

float(entity targ, entity inflictor) CanDamage =
{
	if ((targ.movetype == MOVETYPE_PUSH))
	{
		traceline(inflictor.origin, (MON_BACKTIME * (targ.absmin + targ.absmax)), TRUE, self);
		if ((trace_fraction == WF_DEFEND))
		{
			return (TRUE);
		}
		if ((trace_ent == targ))
		{
			return (TRUE);
		}
		return (FALSE);
	}
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if ((trace_fraction == WF_DEFEND))
	{
		return (TRUE);
	}
	traceline(inflictor.origin, (targ.origin + '15 15 0'), TRUE, self);
	if ((trace_fraction == WF_DEFEND))
	{
		return (TRUE);
	}
	traceline(inflictor.origin, (targ.origin + '-15 -15 0'), TRUE, self);
	if ((trace_fraction == WF_DEFEND))
	{
		return (TRUE);
	}
	traceline(inflictor.origin, (targ.origin + '-15 15 0'), TRUE, self);
	if ((trace_fraction == WF_DEFEND))
	{
		return (TRUE);
	}
	traceline(inflictor.origin, (targ.origin + '15 -15 0'), TRUE, self);
	if ((trace_fraction == WF_DEFEND))
	{
		return (TRUE);
	}
	return (FALSE);
};

float(entity targ, entity inflictor) CanLine =
{
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if ((trace_fraction == WF_DEFEND))
	{
		return (TRUE);
	}
	traceline(inflictor.origin, (targ.origin + '15 15 0'), TRUE, self);
	if ((trace_fraction == WF_DEFEND))
	{
		return (TRUE);
	}
	traceline(inflictor.origin, (targ.origin + '-15 -15 0'), TRUE, self);
	if ((trace_fraction == WF_DEFEND))
	{
		return (TRUE);
	}
	traceline(inflictor.origin, (targ.origin + '-15 15 0'), TRUE, self);
	if ((trace_fraction == WF_DEFEND))
	{
		return (TRUE);
	}
	traceline(inflictor.origin, (targ.origin + '15 -15 0'), TRUE, self);
	if ((trace_fraction == WF_DEFEND))
	{
		return (TRUE);
	}
	return (FALSE);
};

float(entity targ, entity inflictor) CanCarefulDamage =
{
	if ((targ.movetype == MOVETYPE_PUSH))
	{
		traceline(inflictor.origin, (MON_BACKTIME * (targ.absmin + targ.absmax)), TRUE, self);
		if ((trace_fraction == WF_DEFEND))
		{
			return (TRUE);
		}
		if ((trace_ent == targ))
		{
			return (TRUE);
		}
		return (FALSE);
	}
	traceline(inflictor.origin, targ.origin, FALSE, self);
	if ((trace_fraction == WF_DEFEND))
	{
		traceline(inflictor.origin, (targ.origin + '30 30 0'), FALSE, self);
		if ((trace_fraction == WF_DEFEND))
		{
			traceline(inflictor.origin, (targ.origin + '-30 -30 0'), FALSE, self);
			if ((trace_fraction == WF_DEFEND))
			{
				traceline(inflictor.origin, (targ.origin + '-30 30 0'), FALSE, self);
				if ((trace_fraction == WF_DEFEND))
				{
					traceline(inflictor.origin, (targ.origin + '30 -30 0'), FALSE, self);
					if ((trace_fraction == WF_DEFEND))
					{
						return (TRUE);
					}
				}
			}
		}
	}
	return (FALSE);
};

void(entity targ, entity attacker) Killed =
{
	local entity oself;

	oself = self;
	self = targ;
	if ((self.health > WF_NORMAL))
	{
		self.health = WF_NORMAL;
	}
	if ((self.health < -99))
	{
		self.health = -99;
	}
	if (((self.movetype == MOVETYPE_PUSH) || (self.movetype == MOVETYPE_NONE)))
	{
		self.th_die();
		self = oself;
		return;
	}
	self.enemy = attacker;
	self.killer = attacker;
	if ((attacker.flags & FL_MONSTER))
	{
		if ((targ.classname == "player"))
		{
			ClientObituary(self, attacker);
		}
	}
	self.takedamage = DAMAGE_NO;
	self.think = SUB_Null;
	self.touch = SUB_Null;
	monster_death_use();
	self.th_die();
	self = oself;
};

void(entity targ, entity inflictor, entity attacker, float damage) T_Damage =
{
	local vector dir;
	//local entity oldself; // unused
	local float save;
	local float take;
	local float bnresist;
	local float bnamp;
	local float bnspike;
	local float bnheal;
	local float spk;
	local float gh;

	if (!targ.takedamage)
	{
		return;
	}
	damage_attacker = attacker;
	if ((attacker.super_damage_finished > time))
	{
		damage = (damage * LOGIC_DEFEND);
	}
	if ((targ != attacker))
	{
		bnresist = WF_NORMAL;
		if ((targ.magic_typeone == WF_EXTRASIZE))
		{
			bnresist = (bnresist + targ.magic_typeone_value);
		}
		if ((targ.magic_typetwo == WF_EXTRASIZE))
		{
			bnresist = (bnresist + targ.magic_typetwo_value);
		}
		if ((targ.ring_typeone == WF_EXTRASIZE))
		{
			bnresist = (bnresist + targ.ring_typeone_value);
		}
		if ((targ.ring_typetwo == WF_EXTRASIZE))
		{
			bnresist = (bnresist + targ.ring_typetwo_value);
		}
		if ((targ.mentat_bonus == WF_EXTRASIZE))
		{
			bnresist = (bnresist + GRD_PATROLTIME);
		}
		if ((targ.scroll_shie_eff > time))
		{
			bnresist = (bnresist + 15);
		}
		if ((bnresist > 75))
		{
			bnresist = 75;
		}
		if ((bnresist > WF_NORMAL))
		{
			damage = (damage - rint(percent(damage, bnresist)));
		}
		bnamp = WF_NORMAL;
		if ((attacker.magic_typeone == LOGIC_DEFEND))
		{
			bnamp = (bnamp + attacker.magic_typeone_value);
		}
		if ((attacker.magic_typetwo == LOGIC_DEFEND))
		{
			bnamp = (bnamp + attacker.magic_typetwo_value);
		}
		if ((attacker.ring_typeone == LOGIC_DEFEND))
		{
			bnamp = (bnamp + attacker.ring_typeone_value);
		}
		if ((attacker.ring_typetwo == LOGIC_DEFEND))
		{
			bnamp = (bnamp + attacker.ring_typetwo_value);
		}
		if ((attacker.stre > WF_NORMAL))
		{
			bnamp = (bnamp + (attacker.stre * CL_DEADTIME));
		}
		if ((attacker.mentat_bonus == WF_DEFEND))
		{
			bnamp = (bnamp + GRD_PATROLTIME);
		}
		if ((attacker.scroll_brut_eff > time))
		{
			bnamp = ((bnamp + 50) + (attacker.sc_brut_lvl * KEY_MOVERIGHT));
		}
		if ((bnamp > WF_NORMAL))
		{
			damage = (damage + percent(damage, bnamp));
		}
		bnspike = WF_NORMAL;
		if ((targ.magic_typeone == LOGIC_PATROL))
		{
			bnspike = (bnspike + targ.magic_typeone_value);
		}
		if ((targ.magic_typetwo == LOGIC_PATROL))
		{
			bnspike = (bnspike + targ.magic_typetwo_value);
		}
		if ((targ.ring_typeone == LOGIC_PATROL))
		{
			bnspike = (bnspike + targ.ring_typeone_value);
		}
		if ((targ.ring_typetwo == LOGIC_PATROL))
		{
			bnspike = (bnspike + targ.ring_typetwo_value);
		}
		if ((bnspike > WF_NORMAL))
		{
			if ((attacker.flags & FL_MONSTER))
			{
				if ((attacker.ability != WF_EXTRASIZE))
				{
					if ((attacker.health > WF_NORMAL))
					{
						bnspike = percent(damage, bnspike);
						T_Damage(attacker, targ, targ, bnspike);
					}
				}
			}
		}
		bnheal = WF_NORMAL;
		if ((attacker.magic_typeone == LOGIC_HUNTENEMY))
		{
			bnheal = (bnheal + attacker.magic_typeone_value);
		}
		if ((attacker.magic_typetwo == LOGIC_HUNTENEMY))
		{
			bnheal = (bnheal + attacker.magic_typetwo_value);
		}
		if ((attacker.ring_typeone == LOGIC_HUNTENEMY))
		{
			bnheal = (bnheal + attacker.ring_typeone_value);
		}
		if ((attacker.ring_typetwo == LOGIC_HUNTENEMY))
		{
			bnheal = (bnheal + attacker.ring_typetwo_value);
		}
		if ((bnheal > WF_NORMAL))
		{
			if ((attacker.health < attacker.max_health))
			{
				if ((attacker.health > WF_NORMAL))
				{
					if ((targ.flags & FL_MONSTER))
					{
						attacker.health = (attacker.health + percent(damage, bnheal));
						if ((attacker.health > attacker.max_health))
						{
							attacker.health = attacker.max_health;
						}
					}
				}
			}
		}
	}
	if ((attacker.flags & FL_MONSTER))
	{
		if (!(targ.flags & FL_MONSTER))
		{
			damage = (damage + percent(damage, attacker.damage_bonus));
		}
	}
	if ((attacker.prefix > WF_NORMAL))
	{
		if ((attacker.flags & FL_MONSTER))
		{
			if ((attacker.prefix == WF_DEFEND))
			{
				if ((random() < attacker.prefix_value))
				{
					damage = (damage * WF_EXTRASIZE);
				}
			}
			else
			{
				if ((attacker.prefix == TE_WIZSPIKE))
				{
					damage = (damage + percent(damage, attacker.prefix_value));
				}
			}
		}
	}
	if ((targ.prefix > WF_NORMAL))
	{
		if ((targ.flags & FL_MONSTER))
		{
			if ((targ.prefix == WF_EXTRASIZE))
			{
				if ((random() < targ.prefix_value))
				{
					damage = rint((damage / WF_EXTRASIZE));
				}
			}
			else
			{
				if ((targ.prefix == KEY_MOVERIGHT))
				{
					damage = (damage - rint(percent(damage, targ.prefix_value)));
				}
				else
				{
					if ((targ.prefix == TE_LIGHTNING3))
					{
						damage = (damage + percent(damage, targ.prefix_value));
					}
				}
			}
		}
	}
	if ((attacker.flags & FL_MONSTER))
	{
		if (!(targ.flags & FL_MONSTER))
		{
			if ((attacker.scroll_redu_eff > time))
			{
				damage = rint((damage - percent(damage, attacker.sc_redu_lvl)));
				if ((damage == WF_NORMAL))
				{
					return;
				}
			}
		}
	}
	save = ceil((targ.armortype * damage));
	if ((save >= targ.armorvalue))
	{
		save = targ.armorvalue;
		targ.armortype = WF_NORMAL;
		targ.items = (targ.items - (targ.items & ((IT_ARMOR1 | IT_ARMOR2) | IT_ARMOR3)));
	}
	targ.armorvalue = (targ.armorvalue - save);
	take = ceil((damage - save));
	if ((targ.flags & FL_CLIENT))
	{
		targ.dmg_take = (targ.dmg_take + take);
		targ.dmg_save = (targ.dmg_save + save);
		targ.dmg_inflictor = inflictor;
	}
	if (((inflictor != world) && (targ.classname == "player")))
	{
		dir = (targ.origin - ((inflictor.absmin + inflictor.absmax) * MON_BACKTIME));
		dir = normalize(dir);
		if ((targ.classname == "guard"))
		{
			targ.velocity = (targ.velocity + ((dir * damage) * LOGIC_HUNTENEMY));
		}
		else
		{
			targ.velocity = (targ.velocity + ((dir * damage) * KEY_MOVERIGHT));
		}
	}
	if ((targ.flags & FL_GODMODE))
	{
		return;
	}
	if ((targ.invincible_finished >= time))
	{
		if ((self.invincible_sound < time))
		{
			sound(targ, CHAN_ITEM, "items/protect3.wav", WF_DEFEND, ATTN_NORM);
			self.invincible_sound = (time + WF_EXTRASIZE);
		}
		return;
	}
	if (((targ.flags & FL_MONSTER) && (attacker.flags & FL_MONSTER)))
	{
		return;
	}
	if (((targ.classname == "guard") && (attacker.classname == "guard")))
	{
		take = (take / KEY_MOVEFORWARD);
	}
	if (((targ.classname == "player") && (attacker.classname == "guard")))
	{
		take = (take / KEY_MOVEFORWARD);
	}
	if ((targ.ability > WF_NORMAL))
	{
		if ((targ.flags & FL_MONSTER))
		{
			if ((targ.health > WF_NORMAL))
			{
				if ((targ.ability == WF_EXTRASIZE))
				{
					spk = percent(take, GRD_PATROLTIME);
					if ((spk > WF_NORMAL))
					{
						T_Damage(attacker, self, self, spk);
					}
				}
				if ((targ.ability == LOGIC_FINDDEFEND))
				{
					if ((random() < MON_BACKTIME))
					{
						take = WF_NORMAL;
						if ((self.invincible_sound < time))
						{
							if ((random() < MON_BACKTIME))
							{
								sound(targ, CHAN_ITEM, "moon/misc/stone1.wav", WF_DEFEND, ATTN_NORM);
							}
							else
							{
								sound(targ, CHAN_ITEM, "moon/misc/stone2.wav", WF_DEFEND, ATTN_NORM);
							}
							self.invincible_sound = (time + WF_DEFEND);
						}
					}
				}
			}
		}
	}
	if ((attacker.ability == LOGIC_DEFEND))
	{
		if ((attacker.flags & FL_MONSTER))
		{
			if ((attacker.health > WF_NORMAL))
			{
				if ((rint((take / WF_EXTRASIZE)) > WF_NORMAL))
				{
					attacker.health = (attacker.health + rint((take / WF_EXTRASIZE)));
					if ((attacker.health > attacker.max_health))
					{
						attacker.health = attacker.max_health;
					}
				}
			}
		}
	}
	targ.health = rint((targ.health - take));
	if ((targ.health <= WF_NORMAL))
	{
		if (((attacker.classname == "player") && (attacker.health > WF_NORMAL)))
		{
			if ((attacker.health < attacker.max_health))
			{
				if ((targ.flags & FL_MONSTER))
				{
					gh = WF_NORMAL;
					if ((attacker.magic_typeone == KEY_MOVERIGHT))
					{
						gh = (gh + attacker.magic_typeone_value);
					}
					if ((attacker.magic_typetwo == KEY_MOVERIGHT))
					{
						gh = (gh + attacker.magic_typetwo_value);
					}
					if ((attacker.ring_typeone == KEY_MOVERIGHT))
					{
						gh = (gh + attacker.ring_typeone_value);
					}
					if ((attacker.ring_typetwo == KEY_MOVERIGHT))
					{
						gh = (gh + attacker.ring_typetwo_value);
					}
					if ((gh > WF_NORMAL))
					{
						T_Heal(attacker, gh);
					}
				}
			}
		}
		if ((attacker.classname == "player"))
		{
			if ((targ.flags & FL_MONSTER))
			{
				attacker.mosterskilled = (attacker.mosterskilled + WF_DEFEND);
			}
		}
		Killed(targ, attacker);
		return;
	}
	if (((((targ.flags & FL_MONSTER) && (attacker != world)) && (attacker.flags & FL_CLIENT)) && ((targ.enemy == world) || (targ.enemy.classname == "idle_ent"))))
	{
		if (((targ != attacker) && (attacker != targ.enemy)))
		{
			if (!(attacker.flags & FL_MONSTER))
			{
				targ.enemy = attacker;
				targ.show_hostile = (time + self.hst);
			}
		}
	}
};

void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	local float points;
	local entity head;
	local vector org;

	head = findradius(inflictor.origin, (damage + GRD_DEFENDTIME));
	while (head)
	{
		if ((head != ignore))
		{
			if (head.takedamage)
			{
				org = (head.origin + ((head.mins + head.maxs) * MON_BACKTIME));
				points = (MON_BACKTIME * vlen((inflictor.origin - org)));
				if ((points < WF_NORMAL))
				{
					points = WF_NORMAL;
				}
				points = (damage - points);
				if ((head == attacker))
				{
					points = (points * MON_BACKTIME);
				}
				if ((points > WF_NORMAL))
				{
					if (CanDamage(head, inflictor))
					{
						if ((head.classname == "monster_shambler"))
						{
							T_Damage(head, inflictor, attacker, (points * MON_BACKTIME));
						}
						else
						{
							T_Damage(head, inflictor, attacker, points);
						}
					}
				}
			}
		}
		head = head.chain;
	}
};
