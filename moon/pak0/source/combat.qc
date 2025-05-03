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

void(entity targ, entity inflictor, entity attacker, float damage) T_Damage = // REFACTOR NEXT
{
	local vector dir;
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
		damage = (damage * 4);
	}
	if ((targ != attacker))
	{
		bnresist = 0;
		bnresist = (bnresist + moon_get_target_total_bonus_by_code(targ, MOON_ITEM_RESIST_CODE));
		if ( targ.mentat_defense_time > time )
		{
			bnresist = (bnresist + MOON_MENTAT_DEFENSE_VALUE);
		}
		if ((targ.scroll_shie_eff > time))
		{
			bnresist = (bnresist + 15);
		}
		if ( bnresist > MOON_RESIST_LIMIT_HARD )
		{
			bnresist = MOON_RESIST_LIMIT_HARD;
		}
		if ( bnresist > 0 )
		{
			damage = (damage - rint(percent(damage, bnresist)));
		}
		bnamp = 0;
		bnamp = (bnamp + moon_get_target_total_bonus_by_code(attacker, MOON_ITEM_DAMAGE_CODE));
		if ( attacker.stre > 0 ) // may be add negative strength debuf too??
		{
			bnamp = (bnamp + (attacker.stre * MOON_STAT_DAMAGE_PER_STRENGTH));
		}
		if ( attacker.mentat_offense_time > time )
		{
			bnamp = (bnamp + MOON_MENTAT_OFFENSE_VALUE);
		}
		if ((attacker.scroll_brut_eff > time))
		{
			bnamp = ((bnamp + 50) + (attacker.sc_brut_lvl * KEY_MOVERIGHT));
		}
		if ((bnamp > 0))
		{
			damage = (damage + percent(damage, bnamp));
		}
		bnspike = 0;
		bnspike = (bnspike + moon_get_target_total_bonus_by_code(targ, MOON_ITEM_RETALATE_CODE));
		if ((bnspike > 0))
		{
			if ((attacker.flags & FL_MONSTER))
			{
				if ((attacker.ability != 2))
				{
					if ((attacker.health > 0))
					{
						bnspike = percent(damage, bnspike);
						T_Damage(attacker, targ, targ, bnspike);
					}
				}
			}
		}
		bnheal = 0;
		bnheal = (bnheal + moon_get_target_total_bonus_by_code(attacker, MOON_ITEM_VAMPIR_CODE));
		if ( bnheal > 0 )
		{
			if ( attacker.health > 0 )
			{
				if ( targ.flags & FL_MONSTER )
				{
					bnheal = percent(damage, bnheal);
					T_Heal(attacker, bnheal);
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

		if ( attacker.prefix == MOON_MONSTER_TRAIT_DOUBLEDAMAGE )
		{
			if ( random() < attacker.prefix_value )
			{
				damage = (damage * 2);
			}
		} else
		if ( attacker.prefix == MOON_MONSTER_TRAIT_EXTRA_DAMAGE )
		{
			damage = (damage + percent(damage, attacker.prefix_value));
		}
	}

	if ( targ.flags & FL_MONSTER )
	{
		if ( targ.prefix == MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE )
		{
			if ( random() < targ.prefix_value )
			{
				damage = rint(damage / 2);
			}
		} else
		if ( targ.prefix == MOON_MONSTER_TRAIT_RESISTANCE )
		{
			damage = damage - rint(percent(damage, targ.prefix_value));
		} else
		if ( targ.prefix == MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE )
		{
			damage = damage + rint(percent(damage, targ.prefix_value));
		}
	}

	if ( attacker.flags & FL_MONSTER )
	{
		if (!(targ.flags & FL_MONSTER))
		{
			if ((attacker.scroll_redu_eff > time)) // attacker under effect of REDUCE DAMAGE magic
			{
				damage = rint((damage - percent(damage, attacker.sc_redu_lvl)));
				if ( damage <= 0 )
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
		targ.armortype = 0;
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

	if ( (inflictor != world) && (targ.classname == MOON_PLAYER_CLASSNAME) )
	{
		dir = (targ.origin - ((inflictor.absmin + inflictor.absmax) * MON_BACKTIME));
		dir = normalize(dir);
		if ( targ.classname == MOON_GUARD_CLASSNAME )
		{
			targ.velocity = (targ.velocity + ((dir * damage) * 6));
		} else {
			targ.velocity = (targ.velocity + ((dir * damage) * 8));
		}
	}

	if ( targ.flags & FL_GODMODE )
	{
		return;
	}

	if ( targ.invincible_finished >= time )
	{
		if ((self.invincible_sound < time))
		{
			sound(targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = (time + 2);
		}
		return;
	}

	if ( (targ.flags & FL_MONSTER) && (attacker.flags & FL_MONSTER) )
	{
		// TODO: use MOON_MONSTER_TRAIT_FRIENDLY_FIRE here
		return;
	}

	if ( attacker.classname == MOON_GUARD_CLASSNAME )
	{
		if ( targ.classname == MOON_GUARD_CLASSNAME )
		{
			take = rint(take / 16);
		}
		if ( targ.classname == MOON_PLAYER_CLASSNAME )
		{
			take = rint(take / 16);
		}
	}

	if ( (targ.flags & FL_MONSTER) && (targ.health > 0) )
	{
		if ( targ.ability == MOON_MONSTER_TRAIT_IRON )
		{
			spk = percent(take, MOON_MONSTER_TRAIT_IRON_DAMAGERECEIVED);
			if ( spk > 0 )
			{
				T_Damage(attacker, targ, targ, spk);
			}
		}
		if ( targ.ability == MOON_MONSTER_TRAIT_STONE )
		{
			if ( random() < MOON_MONSTER_TRAIT_STONE_PROC )
			{
				take = 0;
				if ( targ.invincible_sound < time )
				{
					if ( random() < 0.5 )
					{
						sound(targ, CHAN_ITEM, "moon/misc/stone1.wav", 1, ATTN_NORM);
					} else {
						sound(targ, CHAN_ITEM, "moon/misc/stone2.wav", 1, ATTN_NORM);
					}
					targ.invincible_sound = (time + 1);
				}
			}
		}
	}

	if ( (attacker.flags & FL_MONSTER) && (attacker.health > 0) )
	{
		if ( attacker.ability == MOON_MONSTER_TRAIT_BLOOD )
		{
			spk = rint(take * MOON_MONSTER_TRAIT_BLOOD_HEALRATIO);
			moon_heal_target_monster(attacker, spk); // easy to heal for 0 than do IF check
		}
	}

	targ.health = rint( targ.health - take );
	if ( targ.health <= 0 )
	{
		if ( attacker.classname == MOON_PLAYER_CLASSNAME )
		{
			if ( (attacker.health > 0) && (attacker.health < attacker.max_health) )
			{
				gh = moon_get_target_total_bonus_by_code(attacker, MOON_ITEM_CONSUME_CODE);
				if (!(targ.flags & FL_MONSTER) )
				{
					gh = rint(gh / 2); // restore even for killing teammates, but less
				}
				if ( gh > 0 )
				{
					T_Heal(attacker, gh);
				}
			}
			if ( targ.flags & FL_MONSTER )
			{
				attacker.mosterskilled = (attacker.mosterskilled + 1);
			}
		}

		Killed(targ, attacker);
		return;
	}

	if (((((targ.flags & FL_MONSTER) && (attacker != world)) && (attacker.flags & FL_CLIENT)) && ((targ.enemy == world) || (targ.enemy.classname == "idle_ent"))))
	{
		if ( (targ != attacker) && (attacker != targ.enemy) )
		{
			if (!(attacker.flags & FL_MONSTER))
			{
				targ.enemy = attacker;
				targ.show_hostile = (time + targ.hst);
			}
		}
	}
};

void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	local float points;
	local entity head;
	local vector org;

	head = findradius(inflictor.origin, (damage + MOON_WEAPON_DAMAGE_BONUSRADIUS_SPLASH));
	while (head)
	{
		if ((head != ignore))
		{
			if (head.takedamage)
			{
				org = (head.origin + ((head.mins + head.maxs) * 0.5));
				points = (0.5 * vlen((inflictor.origin - org)));
				if ((points < 0))
				{
					points = 0;
				}
				points = (damage - points);
				if ((head == attacker))
				{
					points = (points * MOON_WEAPON_DAMAGE_SPLASH_MULT_SELF);
				}
				if ((points > 0))
				{
					if (CanDamage(head, inflictor))
					{
						if ((head.classname == "monster_shambler"))
						{
							T_Damage(head, inflictor, attacker, (points * MOON_WEAPON_DAMAGE_SPLASH_MULT_SHAMBLER));
						} else {
							T_Damage(head, inflictor, attacker, points);
						}
					}
				}
			}
		}
		head = head.chain;
	}
};
