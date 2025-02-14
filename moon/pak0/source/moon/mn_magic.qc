/// ReProjectMoon-specific source file
/// Here go all functions for castable Magic - effects, scrolls etc (not magic items, like armor and ring)

void() moon_magic_cast_spell_slow = // TODO: clear this mess one day. Slow is Slow
{
	local float rm;
	local float dur;
	local float tar;
	local float rng;
	local float casted;
	local float castcount;
	local entity head;

	if ((self.scroll_time > time))
	{
		return;
	}
	rm = (8 + (self.sc_redu_lvl * 2));
	tar = (1 + rint((self.sc_redu_lvl / 3)));
	rng = (350 + (self.sc_redu_lvl * 50));
	dur = (4 + rint((self.sc_redu_lvl * 1.5)));
	if ((self.mana < rm))
	{
		sprint(self, "this spell requies {} mana, you have only {}\n", rm, mana);
		return;
	}
	head = findradius(self.origin, rng);
	while (head)
	{
		if ((head.flags & FL_MONSTER))
		{
			if (((head.health > 0) && (head != self)))
			{
				if (CanDamage(head, self))
				{
					if ((head.scroll_slow_eff < time))
					{
						if ((castcount < tar))
						{
							head.scroll_slow_eff = (time + dur);
							head.speed = rint((head.speed / 2));
							casted = TRUE;
							castcount = (castcount + 1);
						}
					}
				}
			}
		}
		head = head.chain;
	}
	if ((casted == TRUE))
	{
		self.mana = (self.mana - rm);
		if ((self.mana < 0))
		{
			self.mana = 0;
		}
		//sound(self, CHAN_VOICE, "moon/magic/m_slow.wav", 1, ATTN_NORM); // missing file
		self.scroll_time = (time + 0.5);
	}
	else
	{
		sprint(self, "no monsters in range\n");
	}
};

void() moon_magic_cast_spell_curse = // TODO: clear this mess one day. WTF is redu?
{
	local float rm;
	local float eff;
	local float dur;
	local float tar;
	local float rng;
	local float casted;
	local float castcount;
	local entity head;

	if ((self.scroll_time > time))
	{
		return;
	}
	rm = (5 + (self.sc_redu_lvl * 3));
	eff = (25 + (self.sc_redu_lvl * 3));
	if ((eff > 60))
	{
		eff = 60;
	}
	tar = (1 + rint((self.sc_redu_lvl / 2)));
	rng = (350 + (self.sc_redu_lvl * 50));
	dur = (4 + (self.sc_redu_lvl * 2));
	if ((self.mana < rm))
	{
		sprint(self, "this spell requies {} mana, you have only {}\n", rm, mana);
		return;
	}
	head = findradius(self.origin, rng);
	while (head)
	{
		if ((head.flags & FL_MONSTER))
		{
			if (((head.health > 0) && (head != self)))
			{
				if (CanDamage(head, self))
				{
					if ((head.scroll_redu_eff < time))
					{
						if ((castcount < tar))
						{
							head.scroll_redu_eff = (time + dur);
							head.sc_redu_lvl = eff;
							casted = TRUE;
							castcount = (castcount + 1);
						}
					}
				}
			}
		}
		head = head.chain;
	}
	if ((casted == TRUE))
	{
		self.mana = (self.mana - rm);
		if ((self.mana < 0))
		{
			self.mana = 0;
		}
		sound(self, CHAN_VOICE, "moon/misc/cast.wav", 1, ATTN_NORM);
		self.scroll_time = (time + 0.5);
	}
	else
	{
		sprint(self, "no monsters in range\n");
	}
};

void() moon_magic_cast_spell_heal = // TODO: clear this mess one day. Heal is Heal
{
	local float rm;
	local float eff;

	rm = (3 + (self.sc_heal_lvl * 2));
	eff = (15 + (self.sc_heal_lvl * 10));
	if ((self.mana < rm))
	{
		sprint(self, "this spell requies {} mana\n", floor_ftos(rm));
		return;
	}
	if ((self.health >= self.max_health))
	{
		sprint(self, "your life already at maximum\n");
		return;
	}
	if ((self.scroll_time > time))
	{
		return;
	}
	//sound(self, CHAN_VOICE, "moon/magic/m_heal.wav", 1, ATTN_NORM); // missing file
	T_Heal(self, eff, 0);
	self.mana = (self.mana - rm);
	if ((self.mana < 0))
	{
		self.mana = 0;
	}
	self.scroll_heal_eff = (time + 0.5);
	self.scroll_time = (time + 0.5);
};

void() moon_magic_cast_spell_brutality = // TODO: clear this mess one day. Brutal? Damage amp
{
	local float rm;
	local float eff;
	local float dur;

	rm = (5 + (self.sc_brut_lvl * 3));
	eff = (50 + (self.sc_brut_lvl * 8));
	dur = (6 + (self.sc_brut_lvl * 2));
	if ((self.mana < rm))
	{
		sprint(self, "this spell requies {} mana, you have only {}\n", rm, mana);
		return;
	}
	if ((self.scroll_time > time))
	{
		return;
	}
	sound(self, CHAN_VOICE, "moon/misc/cast.wav", 1, ATTN_NORM);
	self.mana = (self.mana - rm);
	if ((self.mana < 0))
	{
		self.mana = 0;
	}
	self.scroll_time = (time + 0.5);
	self.scroll_brut_eff = (time + dur); // suspicious as fuck
};

void() moon_magic_cast_spell_shield = // TODO: clear this mess one day. Shield, not Shiet
{
	if ((self.scroll_time > time))
	{
		return;
	}
	if ((self.mana < 3))
	{
		sprint(self, "this spell requies 3 mana\n");
		return;
	}
	self.mana = (self.mana - 3);
	sound(self, CHAN_VOICE, "moon/misc/cast.wav", 1, ATTN_NORM);
	self.scroll_shie_eff = (time + 10);
	self.scroll_time = (time + 0.3);
};

void() moon_magic_effect_inferno = // Inferno effect ctor()
{
	local entity e;

	e = spawn();
	e.origin = self.origin;
	setmodel(e, "progs/s_explod.spr");
	e.think = s_explode1;
	e.nextthink = time;
	sound(e, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.scroll_infe_eff = 0;
};

void() moon_magic_cast_spell_inferno = // TODO: clear this mess one day. Inferno
{
	local entity head;
	local float casted;
	local float castcount;

	if ((self.scroll_time > time))
	{
		return;
	}
	if ((self.mana < 3))
	{
		sprint(self, "this spell requies 3 mana\n");
		return;
	}
	castcount = 0;
	head = findradius(self.origin, 600);
	while (head)
	{
		if ((head.flags & FL_MONSTER))
		{
			if ((head.health > 0))
			{
				if (CanDamage(head, self))
				{
					if ((head.scroll_infe_eff < time))
					{
						if ((castcount < 6))
						{
							head.scroll_infe_eff = (time + 0.3);
							T_RadiusDamage(head, self, 80, world);
							casted = TRUE;
							castcount = (castcount + 1);
						}
					}
				}
			}
		}
		head = head.chain;
	}
	if ((casted == TRUE))
	{
		sound(self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
		self.mana = (self.mana - 3);
		self.scroll_time = (time + 0.5);
		return;
	}
	else
	{
		sprint(self, "no monsters in range\n");
	}
};

void() moon_magic_effect_thunder = // Shaft effect ctor()
{
	makevectors(self.angles);
	self.scroll_shaf_eff = 0;
	self.effects = (self.effects | EF_MUZZLEFLASH);
	traceline((self.origin + (v_up * self.mins_z)), (self.origin + (v_up * 800)), TRUE, self);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING3);
	WriteEntity(MSG_BROADCAST, self);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);
	sound(self, CHAN_BODY, "weapons/lhit.wav", 1, ATTN_NORM);
};

void() moon_magic_cast_spell_thunder = // TODO: clear this mess one day. Shaf is Shaft, probably thunderstrikes from skies
{
	local entity head;
	local float casted;
	local float castcount;

	if ((self.scroll_time > time))
	{
		return;
	}
	if ((self.mana < 3))
	{
		sprint(self, "this spell requies 3 mana\n");
		return;
	}
	castcount = 0;
	head = findradius(self.origin, 1600);
	while (head)
	{
		if ((head.flags & FL_MONSTER))
		{
			if ((head.health > 0))
			{
				if (CanDamage(head, self))
				{
					if ((head.scroll_infe_eff < time))
					{
						if ((castcount <= 4))
						{
							head.scroll_shaf_eff = (time + 0.3);
							head.attack_e = self;
							T_Damage(head, self, world, 120);
							casted = TRUE;
							castcount = (castcount + 1);
						}
					}
				}
			}
		}
		head = head.chain;
	}
	if ((casted == TRUE))
	{
		//sound(self, CHAN_WEAPON, "moon/magic/m_thun.wav", 1, ATTN_NORM); // missing file
		self.scroll_time = (time + 0.5);
		return;
	}
	else
	{
		sprint(self, "no monsters in range\n");
	}
};

void() moon_magic_effect_meteor_think = // TODO: clear this mess one day. Meteor effect think.
{
	self.origin = (self.enemy.origin + (v_up * self.owner.mins_z));
	self.velocity = self.enemy.velocity;
	if ((self.enemy.health <= 0))
	{
		remove(self);
	}
	if ((self.cnt == 1))
	{
		self.frame = (self.frame + self.walkframe);
		self.walkframe = (self.walkframe + 1);
		if ((self.frame > 72))
		{
			self.cnt = 2;
		}
	}
	if ((self.cnt == 2))
	{
		self.frame = self.walkframe;
		self.walkframe = (self.walkframe + 1);
		if ((self.frame >= 23))
		{
			self.walkframe = 0;
		}
		if ((self.attack_finished < time))
		{
			T_Damage(self.enemy, self.owner, self, 7);
			self.attack_finished = (time + 0.3);
		}
	}
	self.think = moon_magic_effect_meteor_think;
	self.nextthink = (time + 0.01);
};

void(entity who) moon_magic_apply_effect_meteor = // Meteor effect ctor()
{
	local entity e;

	e = spawn();
	setmodel(e, "progs/meteors.mdl");
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NOCLIP;
	e.origin = who.origin;
	e.frame = 47;
	e.cnt = 1;
	e.enemy = who;
	e.owner = self;
	e.think = moon_magic_effect_meteor_think;
	e.nextthink = (time + 0.05);
};

void() moon_magic_cast_spell_meteor = // TODO: clear this mess one day. Mete is Meteor
{
	local entity head;

	if ((self.scroll_time > time))
	{
		return;
	}
	if ((self.mana < 3))
	{
		sprint(self, "this spell requies 3 mana\n");
		return;
	}
	head = findradius(self.origin, 800);
	while (head)
	{
		if ((head.flags & FL_MONSTER))
		{
			if ((head.health > 0))
			{
				if (CanDamage(head, self))
				{
					if ((head.scroll_mete_eff < time))
					{
						head.scroll_mete_eff = (time + 8);
						sound(self, CHAN_VOICE, "moon/misc/cast.wav", 1, ATTN_NORM);
						moon_magic_apply_effect_meteor(head);
						return;
					}
				}
			}
		}
		head = head.chain;
	}
};

void(float nm) moon_magic_cast_spell = // TODO: clear this mess one day. Missing Mete, Shaf, Shie? Here input is Spell (scroll) code
{
	if ((nm == 1))
	{
		moon_magic_cast_spell_heal();
	}
	if ((nm == 2))
	{
		moon_magic_cast_spell_curse();
	}
	if ((nm == 3))
	{
		moon_magic_cast_spell_slow();
	}
	if ((nm == 4))
	{
		moon_magic_cast_spell_brutality();
	}
	if ((nm == 5))
	{
		moon_magic_cast_spell_inferno();
	}
    // below are codes new to ReProject
	if ((nm == 6))
	{
		moon_magic_cast_spell_thunder();
	}
	if ((nm == 7))
	{
		moon_magic_cast_spell_meteor();
	}
	if ((nm == 8))
	{
		moon_magic_cast_spell_shield();
	}
};

void(float nm) moon_magic_try_cast_spell = // TODO: clear this mess one day. Here input is Spell (scroll) slot
{
	if ((nm == 1))
	{
		if ((self.sc_n1 <= 0))
		{
			sprint(self, "no 1st scroll to cast\n");
			return;
		}
		moon_magic_cast_spell(self.sc_n1);
	}
	if ((nm == 2))
	{
		if ((self.sc_n2 <= 0))
		{
			sprint(self, "no 2nd scroll to cast\n");
			return;
		}
		moon_magic_cast_spell(self.sc_n2);
	}
	if ((nm == 3))
	{
		if ((self.sc_n3 <= 0))
		{
			sprint(self, "no 3rd scroll to cast\n");
			return;
		}
		moon_magic_cast_spell(self.sc_n3);
	}
	if ((nm == 4))
	{
		if ((self.sc_n4 <= 0))
		{
			sprint(self, "no 4th scroll to cast\n");
			return;
		}
		moon_magic_cast_spell(self.sc_n4);
	}
	if ((nm == 5))
	{
		if ((self.sc_n5 <= 0))
		{
			sprint(self, "no 5th scroll to cast\n");
			return;
		}
		moon_magic_cast_spell(self.sc_n5);
	}
};

void(entity e, float nm) moon_target_magic_detail_println = // TODO: clear this mess one day
{
	local float tmp;

	sprint(e, "scroll of "); // óãòïìì ïæ ");
	if ((nm == 1))
	{
		sprint(e, "healing <-lvl:"); // èåáìéîç lvl:");
		sprint(e, ftos(e.sc_heal_lvl));
		sprint(e, " mana:");
		sprint(e, ftos(3 + (e.sc_heal_lvl * 2)));
		sprint(e, " eff:");
		sprint(e, ftos(15 + (e.sc_heal_lvl * 10)));
		sprint(e, "->");
		sprint(e, "\n");
	}
	else
	{
		if ((nm == 2))
		{
			sprint(e, "reduction <-lvl:"); // òåäõãôéïî lvl:");
			sprint(e, ftos(e.sc_redu_lvl));
			sprint(e, " mana:"); // žmana:");
			sprint(e, ftos(5 + (e.sc_redu_lvl * 3)));
			sprint(e, " eff:"); // žeff:");
			tmp = (25 + (e.sc_redu_lvl * 3));
			if ((tmp > 60))
			{
				tmp = 60;
			}
			sprint(e, ftos(tmp));
			sprint(e, "% time:"); // žtime:");
			sprint(e, ftos(4 + (e.sc_redu_lvl * 2)));
			sprint(e, "sec-targets:"); // žtargets:");
			tmp = (1 + rint((e.sc_redu_lvl / 2)));
			sprint(e, ftos(tmp));
			sprint(e, " range:"); // žrange:");
			tmp = ((350 + (e.sc_redu_lvl * 50)) / 100);
			sprint(e, ftos(tmp));
			sprint(e, "m->"); // Ÿ");
			sprint(e, "\n");
		}
		else
		{
			if ((nm == 3))
			{
				sprint(e, "slow <-lvl:"); // óìï÷ lvl:");
				sprint(e, ftos(e.sc_slow_lvl));
				sprint(e, " mana:");
				sprint(e, ftos(8 + (e.sc_slow_lvl * 2)));
				sprint(e, " time:");
				tmp = (4 + rint((e.sc_slow_lvl * 1.5)));
				sprint(e, ftos(tmp));
				sprint(e, "sec-targets:");
				tmp = (1 + rint((e.sc_slow_lvl / 3)));
				sprint(e, ftos(tmp));
				sprint(e, " range:");
				tmp = ((350 + (e.sc_slow_lvl * 50)) / 100);
				sprint(e, ftos(tmp));
				sprint(e, "m->");
				sprint(e, "\n");
			}
		}
	}
	if ((nm == 4))
	{
		sprint(e, "brutality <-lvl:"); // âòõôáìéôù lvl:");
		sprint(e, ftos(e.sc_brut_lvl));
		sprint(e, " mana:");
		sprint(e, ftos(5 + (e.sc_brut_lvl * 3)));
		sprint(e, " eff:");
		sprint(e, ftos(50 + (e.sc_brut_lvl * 8)));
		sprint(e, "% time:");
		sprint(e, ftos(6 + (e.sc_brut_lvl * 2)));
		sprint(e, "sec->");
		sprint(e, "\n");
	}
};

void() moon_target_println_scrolls =
{
	sprint(self, "===== scrolls =====\n");
	if ((self.sc_n1 > 0))
	{
		moon_target_magic_detail_println(self, self.sc_n1);
	}
	if ((self.sc_n2 > 0))
	{
		moon_target_magic_detail_println(self, self.sc_n2);
	}
	if ((self.sc_n3 > 0))
	{
		moon_target_magic_detail_println(self, self.sc_n3);
	}
	if ((self.sc_n4 > 0))
	{
		moon_target_magic_detail_println(self, self.sc_n4);
	}
	if ((self.sc_n5 > 0))
	{
		moon_target_magic_detail_println(self, self.sc_n5);
	}
	sprint(self, "===================\n");
};

void(entity e, float n1, float n2) moon_target_magic_scroll_upgrade = // Praise the Omnissiah
{
	if ((n1 == 1))
	{
		e.sc_n1 = n2;
	}
	else
	{
		if ((n1 == 2))
		{
			e.sc_n2 = n2;
		}
		else
		{
			if ((n1 == 3))
			{
				e.sc_n3 = n2;
			}
			else
			{
				if ((n1 == 4))
				{
					e.sc_n4 = n2;
				}
				else
				{
					if ((n1 == 5))
					{
						e.sc_n5 = n2;
					}
				}
			}
		}
	}
};

void(entity e, float sc_n, float cnn, float cn) moon_target_magic_scroll_pickup = // God-Emperor protect me
{
	if (((sc_n == 0) && (cn == 1)))
	{
		e.sc_heal_lvl = 0;
		sprint(e, "you get ");
		moon_target_magic_scroll_upgrade(e, cnn, cn);
		moon_target_magic_detail_println(e, 1);
	}
	else
	{
		if (((sc_n > 0) && (cn == 1)))
		{
			e.sc_heal_lvl = (e.sc_heal_lvl + 1);
			sprint(e, "You upgrade ");
			moon_target_magic_detail_println(e, 1);
		}
		else
		{
			if (((sc_n == 0) && (cn == 2)))
			{
				e.sc_redu_lvl = 0;
				sprint(e, "You get ");
				moon_target_magic_scroll_upgrade(e, cnn, cn);
				moon_target_magic_detail_println(e, 2);
			}
			else
			{
				if (((sc_n > 0) && (cn == 2)))
				{
					e.sc_redu_lvl = (e.sc_redu_lvl + 1);
					sprint(e, "You upgrade ");
					moon_target_magic_detail_println(e, 2);
				}
				else
				{
					if (((sc_n == 0) && (cn == 3)))
					{
						e.sc_slow_lvl = 0;
						sprint(e, "You get ");
						moon_target_magic_scroll_upgrade(e, cnn, cn);
						moon_target_magic_detail_println(e, 3);
					}
					else
					{
						if (((sc_n > 0) && (cn == 3)))
						{
							e.sc_slow_lvl = (e.sc_slow_lvl + 1);
							sprint(e, "You upgrade ");
							moon_target_magic_detail_println(e, 3);
						}
						else
						{
							if (((sc_n == 0) && (cn == 4)))
							{
								e.sc_brut_lvl = 0;
								sprint(e, "You get ");
								moon_target_magic_scroll_upgrade(e, cnn, cn);
								moon_target_magic_detail_println(e, 4);
							}
							else
							{
								if (((sc_n > 0) && (cn == 4)))
								{
									e.sc_brut_lvl = (e.sc_brut_lvl + 1);
									sprint(e, "You upgrade ");
									moon_target_magic_detail_println(e, 4);
								}
							}
						}
					}
				}
			}
		}
	}
};

void() moon_magic_scroll_touch = // ScrollTouch, Finish him
{
	if ( other.classname != MOON_PLAYER_CLASSNAME ) { return; }
	if ( other.health <= 0 ) { return; }

	if (((other.sc_n1 == 0) || (other.sc_n1 == self.cnt)))
	{
		moon_target_magic_scroll_pickup(other, other.sc_n1, 1, self.cnt);
	}
	else
	{
		if (((other.sc_n2 == 0) || (other.sc_n2 == self.cnt)))
		{
			moon_target_magic_scroll_pickup(other, other.sc_n2, 2, self.cnt);
		}
		else
		{
			if (((other.sc_n3 == 0) || (other.sc_n3 == self.cnt)))
			{
				moon_target_magic_scroll_pickup(other, other.sc_n3, 3, self.cnt);
			}
			else
			{
				if (((other.sc_n4 == 0) || (other.sc_n4 == self.cnt)))
				{
					moon_target_magic_scroll_pickup(other, other.sc_n4, 4, self.cnt);
				}
				else
				{
					if (((other.sc_n5 == 0) || (other.sc_n5 == self.cnt)))
					{
						moon_target_magic_scroll_pickup(other, other.sc_n5, 5, self.cnt);
					}
					else
					{
						return;
					}
				}
			}
		}
	}
	flash_target(other);
	sound(other, CHAN_ITEM, "moon/items/scroll.wav", 1, ATTN_NORM);
	remove(self);
};

void(entity who) moon_spawn_drop_scroll =
{
	local entity item;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.flags = FL_ITEM;
	item.cnt = rint((1 + (random() * 3)));	// TODO: put here Scroll code const
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	item.angles_y = rint((random() * 360));
	setmodel(item, "progs/scroll.mdl");
	setsize(item, '-16 -16 0', '16 16 48');
	item.touch = moon_magic_scroll_touch;
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_NORMAL);
	item.think = SUB_Remove;
};

void(entity who) moon_particle_heal = // TODO: find out wtf, then find better name
{
	local vector smes;

	smes = ((who.origin + ((v_up * 12) * crandom())) + ((v_right * 10) * crandom()));
	particle(smes, VEC_ORIGIN, 165, 25);
	particle(smes, VEC_ORIGIN, 73, 25);
};

void(entity who, float clr) moon_particle_scroll = // TODO: find out wtf, then find better name
{
	local vector smes;

	smes = (((who.origin + (v_up * self.maxs_z)) - ((v_up * 12) * random())) + ((v_right * 4) * crandom()));
	particle(smes, '0 0 -20', clr, 25);
};

void() moon_monster_apply_effect_self = // TODO: implement one day
{
	local vector smes;

	if ((self.scroll_heal_eff > time))
	{
		smes = (((self.origin + (v_up * self.maxs_z)) - ((v_up * 6) * random())) + ((v_right * 4) * crandom()));
		particle(smes, '0 0 -20', 165, 25);
	}
	if ((self.scroll_brut_eff > time))
	{
		smes = ((self.origin + (v_up * self.mins_z)) + ((v_right * 4) * crandom()));
		particle(smes, '0 0 5', 200, 25);
	}
	if ((self.scroll_shie_eff > time))
	{
		smes = ((self.origin + (v_up * self.mins_z)) + ((v_right * 4) * crandom()));
		particle(smes, '0 0 5', 15, 25);
	}
	if ((self.scroll_slow_eff > time))
	{
		moon_particle_scroll(self, 80);
	}
	else
	{
		if ((self.mx_speed != self.speed))
		{
			self.speed = self.mx_speed;
		}
	}
	if ((self.scroll_redu_eff > time))
	{
		moon_particle_scroll(self, 41);
	}
	if ((self.scroll_infe_eff > time))
	{
		moon_magic_effect_inferno();
	}
	if ((self.scroll_shaf_eff > time))
	{
		moon_magic_effect_thunder();
	}
};