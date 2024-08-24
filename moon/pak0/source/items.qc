//Decompiled code. Please respect the original copyright.
float H_ROTTEN    = 1;
float H_MEGA      = 2;
.float healamount;
.float healtype;

void() W_SetCurrentAmmo;
void() health_touch;
void() item_megahealth_rot;
void() moon_wear_item;
void() moon_print_inventory;

float(entity e, float healamount, float ignore) T_Heal =
{
	if ((e.health <= 0))
	{
		return (0);
	}
	if ((!ignore && (e.health >= e.max_health)))
	{
		return (0);
	}
	healamount = ceil(healamount);
	e.health = (e.health + healamount);
	if ((!ignore && (e.health >= e.max_health)))
	{
		e.health = e.max_health;
	}
	e.health = clamp(e.health, CONST_QC_DISPLAY_MAX);
	return (1);
};

float(entity e, float healamount) T_Overheal =
{
	if ( e.health <= 0 )
	{
		return FALSE;
	}

	healamount = ceil(healamount);
	e.health = clamp( (e.health + healamount), CONST_QC_DISPLAY_MAX);

	return TRUE;
};

float(entity e, float healamount) T_Mana =
{
	if ((e.mana >= e.max_mana))
	{
		return (0);
	}
	healamount = ceil(healamount);
	e.mana = (e.mana + healamount);
	if ((e.mana >= e.max_mana))
	{
		e.mana = e.max_mana;
	}
	e.mana = clamp(e.mana, CONST_QC_DISPLAY_MAX);
	return (1);
};

string(float digit) moon_gets_golden_digit =
{
	switch(floor(digit))
	{
		case 0: return ("\0");
		case 1: return ("\1");
		case 2: return ("\2");
		case 3: return ("\3");
		case 4: return ("\4");
		case 5: return ("\5");
		case 6: return ("\6");
		case 7: return ("\7");
		case 8: return ("\8");
		case 9: return ("\9");
		default:
			dprint("<{}>", quick_ftos(digit)); // debug
			return MOON_GLYPH_CENTERDOT_WHITE;
	}
};

string(float digit) moon_gets_red_digit =
{
	switch(floor(digit))
	{
		case 0: return ("\xB0");
		case 1: return ("\xB1");
		case 2: return ("\xB2");
		case 3: return ("\xB3");
		case 4: return ("\xB4");
		case 5: return ("\xB5");
		case 6: return ("\xB6");
		case 7: return ("\xB7");
		case 8: return ("\xB8");
		case 9: return ("\xB9");
		default:
			dprint("<{}>", quick_ftos(digit)); // debug
			return MOON_GLYPH_CENTERDOT_WHITE;
	}
};

void(entity target, float number, string(float digit) color_func) moon_print_color_number =
{
	local float remainder;
	local float digit_count;

	digit_count = 1;
	remainder = rint(number);
	while(remainder >= 10)
	{
		digit_count = digit_count + 1;
		remainder = remainder / 10;
	}

	local float multiplier;
	multiplier = 1;
	for(float i = 1; i < digit_count; ++i)
	{
		multiplier = multiplier * 10;
	}

	local float top_part;
	remainder = rint(number);
	while(digit_count > 1)
	{
		top_part = floor(remainder / multiplier);
		remainder = remainder % multiplier;
		multiplier = multiplier / 10;
		digit_count = digit_count - 1;
		//sprint(target, "{} {} {} {} \n", ftos(number), ftos(top_part), ftos(remainder), ftos(multiplier)); // keep for debug
		sprint(target, color_func(top_part));
	}
	sprint(target, color_func(remainder));
};

void(entity target, float number) moon_print_golden_number =
{
	moon_print_color_number(target, number, moon_gets_golden_digit);
};

void(entity target, float number) moon_print_red_number =
{
	moon_print_color_number(target, number, moon_gets_red_digit);
};

void(entity target) moon_println_target_gold =
{
	moon_print_golden_number(target, target.gold);
	sprint(target, "\n");
};

void() moon_broadcast_global_gold_bonus =
{
	bprint("Global gold income now +{}%\n", floor_ftos(up_gold_value));
};

void(entity target, float gain) moon_give_target_gold =
{
	target.gold = (target.gold + gain);

	flash_target(target);
	sprint(target, "You got {} gold\n", floor_ftos(gain));
	sound(target, CHAN_ITEM, "moon/items/gold.wav", 1, ATTN_NORM);
};

float(entity target, float cost) moon_pay_target_gold =
{
	if ( target.gold < cost )
	{
		sprint(target, "not enough gold\n");
		return FALSE;
	}
	target.gold = (target.gold - cost);

	sprint(target, "You paid {} gold, {} left", floor_ftos(cost), floor_ftos(target.gold));
	return TRUE;
};

void(entity target) moon_println_target_exp =
{
	sprint(target, "Level: {}, Exp {}{}/{}{}\n", floor_ftos(target.lvl), MOON_GLYPH_BRACKET_OPEN, floor_ftos(target.exp), floor_ftos(target.nextexp), MOON_GLYPH_BRACKET_CLOSE);
};

void(entity target) moon_print_mentat_offense =
{
	sprint(target, MOON_MENTAT_OFFENSE_NAME);
	sprint(target, " (increase your damage by ");
	moon_print_golden_number(target, MOON_MENTAT_OFFENSE_VALUE);
	sprint(target, "%)");
};

void(entity target) moon_print_mentat_defense =
{
	sprint(target, MOON_MENTAT_DEFENSE_NAME);
	sprint(target, " (decrease incoming damage by ");
	moon_print_golden_number(target, MOON_MENTAT_DEFENSE_VALUE);
	sprint(target, "%)");
};

void(entity target) moon_print_mentat_speed =
{
	sprint(target, MOON_MENTAT_SPEED_NAME);
	sprint(target, " (increase your attack speed by ");
	moon_print_golden_number(target, MOON_MENTAT_SPEED_VALUE_MIN);
	sprint(target, "-");
	moon_print_golden_number(target, MOON_MENTAT_SPEED_VALUE_MAX);
	sprint(target, "%%)");
};

void(entity target, string prefix, string name, string postfix) moon_print_target_item_name =
{
	if (prefix != s_wiz)
	{
		sprint(target, prefix);
	}
	sprint(target, name);
	if (postfix != s_wiz)
	{
		sprint(target, postfix);
	}
};

void(entity target, entity owner) moon_println_target_magic_armor_name =
{
	if (owner.magic_prefixone != s_wiz)
	{
		sprint(target, owner.magic_prefixone);
	}
	sprint(target, MOON_ITEM_ARMOR_DISPLAY);
	if (owner.magic_prefixtwo != s_wiz)
	{
		sprint(target, owner.magic_prefixtwo);
	}
	sprint(target, "\n");
};

void(entity target, entity owner) moon_println_target_magic_ring_name =
{
	if (owner.ring_prefixone != s_wiz)
	{
		sprint(target, owner.ring_prefixone);
	}
	sprint(target, MOON_ITEM_RING_DISPLAY);
	if (owner.ring_prefixtwo != s_wiz)
	{
		sprint(target, owner.ring_prefixtwo);
	}
	sprint(target, "\n");
};

void(entity chat_target, entity value_target) moon_println_target_other_health =
{
	if (value_target.health < value_target.max_health)
	{
		moon_print_red_number(chat_target, value_target.health);
		sprint(chat_target, "/");
	}
	sprint(chat_target, "{}\n", floor_ftos(value_target.max_health));
};

//[byte] svcqex_chat, [byte] playercolour, [byte] textcolour, [string] playername, [string] chattext
void(string sender, float sender_color, string text) kex_chat_message_broad =
{
	WriteByte(MSG_ALL, svcqex_chat);
	WriteByte(MSG_ALL, sender_color);
	WriteByte(MSG_ALL, CONST_QEX_COLOR_TEAL);
	WriteString(MSG_ALL, sender);
	WriteString(MSG_ALL, text);
};

//[byte] svcqex_chat, [byte] playercolour, [byte] textcolour, [string] playername, [string] chattext
void(string sender, float sender_color, string text) kex_chat_message_self =
{
	local entity bak_entity;
	bak_entity = msg_entity;

	msg_entity = self;
	WriteByte(MSG_ONE, svcqex_chat);
	WriteByte(MSG_ONE, sender_color);
	WriteByte(MSG_ONE, CONST_QEX_COLOR_WHITE);
	WriteString(MSG_ONE, sender);
	WriteString(MSG_ONE, text);

	msg_entity = bak_entity;
};

entity() moon_gimme_your_heart =
{
	local entity heart;
	heart = find(world, classname, MOON_HEART_CLASSNAME);
	if ( heart != world )
	{
		return heart;
	}

	dprint("you have no heart\n");
	return world;
};

void() moon_broadcast_heart_state =
{
	local entity heart;
	heart = moon_gimme_your_heart();
	if ( heart != world )
	{
		bprint("\sHeart\s's life now ");
		if (heart.health < heart.max_health)
		{
			bprint("{}\s/\s", floor_ftos(heart.health)); // Im too lazy to duplicate print_red_number for bprint
		}
		bprint("{}\n", floor_ftos(heart.max_health));
	}
};

float(entity target, float code) moon_target_bonus_by_code =
{
	local float bonus;
	bonus = 0;
	if ((target.magic_typeone == code))
	{
		bonus = (bonus + target.magic_typeone_value);
	}
	if ((target.magic_typetwo == code))
	{
		bonus = (bonus + target.magic_typetwo_value);
	}
	if ((target.ring_typeone == code))
	{
		bonus = (bonus + target.ring_typeone_value);
	}
	if ((target.ring_typetwo == code))
	{
		bonus = (bonus + target.ring_typetwo_value);
	}
	return (bonus);
};

float(entity target) moon_get_target_bonus_health =
{
	return moon_target_bonus_by_code(target, MOON_ITEM_HEALTH_CODE);
};

float(entity target) moon_get_target_bonus_damage =
{
	return moon_target_bonus_by_code(target, MOON_ITEM_DAMAGE_CODE);
};

void(entity target, float value) moon_raise_target_max_health =
{
	target.max_health = (target.max_health + value);
	target.max_health = clamp(target.max_health, CONST_QC_DISPLAY_MAX);
	if (value > 0)
	{
		T_Heal(target, value, 0);
	} else {
		if (target.max_health < MOON_STAT_MAXHEALTH_MIN)
		{
			target.max_health = MOON_STAT_MAXHEALTH_MIN;
		}
	}
};

void(entity target, float value) moon_raise_target_max_mana =
{
	target.max_mana = (target.max_mana + value);
	target.max_mana = clamp(target.max_mana, CONST_QC_DISPLAY_MAX);
	if (value > 0)
	{
		T_Mana(other, value);
	} else {
		if (target.max_mana < MOON_STAT_MAXMANA_MIN)
		{
			target.max_mana = MOON_STAT_MAXMANA_MIN;
		}
	}
};

void(entity target, float value) moon_raise_target_vitality =
{
	target.vit = (target.vit + value);
	moon_raise_target_max_health(target, (value*MOON_STAT_HEALTH_PER_VITALITY));
};

void(entity target, float value = 1) moon_raise_target_strength = // This is not necessary so far, but for consistency
{
	target.stre = (target.stre + value);
};

void(entity target, float value) moon_raise_target_sanity =
{
	target.wiz = (target.wiz + value);
	moon_raise_target_max_mana(target, (value*MOON_STAT_MANA_PER_SANITY));
};

void(entity target, float value = 1) moon_raise_target_intuition = // This is not necessary so far, but for consistency
{
	target.intu = (target.intu + value);
};

void(entity target, entity container) moon_print_target_container_ammo =
{
	local float had_any;

	if ( container.ammo_shells )
	{
		sprint(target, " {} {}", floor_ftos(container.ammo_shells), MOON_AMMO_SHELLS_DISPLAYNAME);
		had_any = TRUE;
	}
	if ( container.ammo_nails )
	{
		sprint(target, " {} {}", floor_ftos(container.ammo_nails), MOON_AMMO_NAILS_DISPLAYNAME);
		had_any = TRUE;
	}
	if ( container.ammo_rockets )
	{
		sprint(target, " {} {}", floor_ftos(container.ammo_rockets), MOON_AMMO_ROCKETS_DISPLAYNAME);
		had_any = TRUE;
	}
	if ( container.ammo_cells )
	{
		sprint(target, " {} {}", floor_ftos(container.ammo_cells), MOON_AMMO_CELLS_DISPLAYNAME);
		had_any = TRUE;
	}

	if ( had_any != TRUE )
	{
		sprint(target, "\n");
		sprint(target, "ERROR: garbage shop have incorrect item! Report this bug and item!\n");
	}
};

void() SUB_regen =
{
	self.model = self.mdl;
	self.solid = SOLID_TRIGGER;
	sound(self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);
	setorigin(self, self.origin);
};

void() noclass =	// empty c-tor, for catching something
{
	dprint("noclass spawned at {}\n", vtos(self.origin));
	remove(self);
};

void() PlaceItem =
{
	self.mdl = self.model;
	self.flags = FL_ITEM;
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.velocity = VEC_ORIGIN;
	self.origin_z = (self.origin_z + 6);
	if (!droptofloor())
	{
		dprint("Bonus item fell out of level at {}\n", vtos(self.origin));
		remove(self);
		return;
	}
};

void() StartItem =
{
	self.nextthink = (time + MON_REACTIONTIME);
	self.think = PlaceItem;
};

float(entity emitter, float track) moon_walkman_play = // return track length
{
	switch (track)
	{
	case 0:
		sound(emitter, MOON_WALKMAN_CHANNEL, "misc/null.wav", 1, ATTN_NORM);
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
}

float(entity emitter) moon_walkman_start_music_gate =
{
	local float track;
	track = random_int(1, 10);
	return moon_walkman_play(emitter, track);
}

float(entity emitter) moon_walkman_start_music_shop =
{
	local float track;
	track = random_int(11, 12);
	return moon_walkman_play(emitter, track);
}

void() item_health = // Refactor extract consts
{
	self.touch = health_touch;
	if ((self.spawnflags & H_ROTTEN))
	{
		setmodel(self, "maps/b_bh10.bsp");
		self.noise = "items/r_item1.wav";
		self.healamount = 15;
		self.healtype = 0;
	}
	else
	{
		if ((self.spawnflags & H_MEGA))
		{
			setmodel(self, "maps/b_bh100.bsp");
			self.noise = "items/r_item2.wav";
			self.healamount = 100;
			self.healtype = 2;
		}
		else
		{
			setmodel(self, "maps/b_bh25.bsp");
			self.noise = "items/health1.wav";
			self.healamount = 25;
			self.healtype = 1;
		}
	}
	setsize(self, VEC_ORIGIN, '32 32 56');
	StartItem();
};

void() health_touch =
{
	if ((other.classname != MOON_PLAYER_CLASSNAME))
	{
		return;
	}
	if ((self.healtype == WF_EXTRASIZE))
	{
		if ((other.health >= (other.max_health + 250))) // TODO: clean later
		{
			return;
		}
		if (!T_Heal(other, self.healamount, 1))
		{
			return;
		}
	}
	else
	{
		if (!T_Heal(other, self.healamount, 0))
		{
			return;
		}
	}
	sprint(other, "You receive {} health\n", floor_ftos(self.healamount));
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	flash_target(other);
	self.model = string_null;
	self.solid = SOLID_NOT;
	if ((self.healtype == WF_EXTRASIZE))
	{
		other.items = (other.items | IT_SUPERHEALTH);
		self.nextthink = (time + LOGIC_PATROL);
		self.think = item_megahealth_rot;
		self.owner = other;
	}
	activator = other;
	SUB_UseTargets();
};

void() item_megahealth_rot =
{
	other = self.owner;
	if ((other.health > other.max_health))
	{
		other.health = (other.health - 1);
		self.nextthink = (time + 1);
		return;
	}
	other.items = (other.items & (~IT_SUPERHEALTH));
	remove(self);
};

void() armor_touch = // Refactor extract consts
{
	local float type;
	local float value;
	local float bit;

	if (other.classname != MOON_PLAYER_CLASSNAME) { return; }
	if (other.health <= 0) { return; }

	if ((self.classname == "item_armor1"))
	{
		type = 0.3;
		value = 100;
		bit = IT_ARMOR1;
	}
	if ((self.classname == "item_armor2"))
	{
		type = 0.6;
		value = 150;
		bit = IT_ARMOR2;
	}
	if ((self.classname == "item_armorInv"))
	{
		type = 0.8;
		value = 200;
		bit = IT_ARMOR3;
	}
	if (((other.armortype * other.armorvalue) >= (type * value)))
	{
		return;
	}
	other.armortype = type;
	other.armorvalue = value;
	other.items = (((other.items & (~IT_ARMOR1)) & (~IT_ARMOR2)) & (~IT_ARMOR3)) | bit;
	self.solid = SOLID_NOT;
	self.model = string_null;
	if ((deathmatch == WF_DEFEND))
	{
		self.nextthink = (time + GRD_PATROLTIME);
	}
	self.think = SUB_regen;
	sprint(other, "You got new armor\n");
	sound(other, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
	flash_target(other);
	activator = other;
	SUB_UseTargets();
};

void() item_armor1 =
{
	self.touch = armor_touch;
	precache_model("progs/armor.mdl");
	setmodel(self, "progs/armor.mdl");
	self.skin = 0;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() item_armor2 =
{
	self.touch = armor_touch;
	precache_model("progs/armor.mdl");
	setmodel(self, "progs/armor.mdl");
	self.skin = 1;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() item_armorInv =
{
	self.touch = armor_touch;
	precache_model("progs/armor.mdl");
	setmodel(self, "progs/armor.mdl");
	self.skin = 2;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void(entity target) moon_limit_target_ammo =
{
	local float max_shells;
	local float max_nails;
	max_shells = clamp( (MOON_AMMO_MAX_SHELL + (target.up_bullet * MOON_ITEM_SHELLUP_SIDEEFFECT_BONUS)), CONST_QC_DISPLAY_MAX);
	max_nails = clamp( (MOON_AMMO_MAX_NAIL + (target.up_nail * MOON_ITEM_NAILUP_SIDEEFFECT_BONUS)), CONST_QC_DISPLAY_MAX);

	target.ammo_shells = clamp(target.ammo_shells, max_shells);
	target.ammo_nails = clamp(target.ammo_nails, max_nails);
	target.ammo_rockets = clamp(target.ammo_rockets, MOON_AMMO_MAX_ROCKET);
	target.ammo_cells = clamp(target.ammo_cells, MOON_AMMO_MAX_CELL);
};

float(float w) RankForWeapon =
{
	if ((w == IT_LIGHTNING))
	{
		return (WF_DEFEND);
	}
	if ((w == IT_ROCKET_LAUNCHER))
	{
		return (WF_EXTRASIZE);
	}
	if ((w == IT_SUPER_NAILGUN))
	{
		return (LOGIC_FINDDEFEND);
	}
	if ((w == IT_GRENADE_LAUNCHER))
	{
		return (LOGIC_DEFEND);
	}
	if ((w == IT_SUPER_SHOTGUN))
	{
		return (LOGIC_PATROL);
	}
	if ((w == IT_NAILGUN))
	{
		return (LOGIC_HUNTENEMY);
	}
	return (TE_WIZSPIKE);
};

void(float old, float new) Deathmatch_Weapon =
{
	local float or;
	local float nr;

	or = RankForWeapon(self.weapon);
	nr = RankForWeapon(new);
	if ((nr < or))
	{
		self.weapon = new;
	}
};
float() W_BestWeapon;

void() weapon_touch =
{
	//local float hadammo; // unused
	local float best;
	//local float new; // unused
	local float old;
	local entity stemp;
	//local float leave; // unused

	if (!(other.flags & FL_CLIENT))
	{
		return;
	}
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	if ((other.classname != "player"))
	{
		return;
	}
	other.ammo_nails = (other.ammo_nails + self.ammo_nails);
	other.ammo_shells = (other.ammo_shells + self.ammo_shells);
	other.ammo_rockets = (other.ammo_rockets + self.ammo_rockets);
	other.ammo_cells = (other.ammo_cells + self.ammo_cells);
	moon_limit_target_ammo(other);

	if (!(other.items & self.items))
	{
		other.items = (other.items + self.items);
	}
	sprint(other, "You got the {}\n", self.netname);
	sound(other, CHAN_ITEM, "weapons/pkup.wav", WF_DEFEND, ATTN_NORM);
	flash_target(other);

	old = other.weapon;

	stemp = self;
	self = other;
	best = W_BestWeapon();
	Deathmatch_Weapon(old, stemp.items);
	W_SetCurrentAmmo();
	self = stemp;

	remove(self);
};

void() weapon_supershotgun =
{
	precache_model("progs/g_shot.mdl");
	setmodel(self, "progs/g_shot.mdl");
	self.weapon = IT_SUPER_SHOTGUN;
	self.netname = "Double-barrelled Shotgun";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() weapon_nailgun =
{
	precache_model("progs/g_nail.mdl");
	setmodel(self, "progs/g_nail.mdl");
	self.weapon = IT_NAILGUN;
	self.netname = "nailgun";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() weapon_supernailgun =
{
	precache_model("progs/g_nail2.mdl");
	setmodel(self, "progs/g_nail2.mdl");
	self.weapon = IT_SUPER_NAILGUN;
	self.netname = "Super Nailgun";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() weapon_grenadelauncher =
{
	precache_model("progs/g_rock.mdl");
	setmodel(self, "progs/g_rock.mdl");
	self.weapon = LOGIC_FINDDEFEND;
	self.netname = "Grenade Launcher";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() weapon_rocketlauncher =
{
	precache_model("progs/g_rock2.mdl");
	setmodel(self, "progs/g_rock2.mdl");
	self.weapon = LOGIC_FINDDEFEND;
	self.netname = "Rocket Launcher";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() weapon_lightning =
{
	precache_model("progs/g_light.mdl");
	setmodel(self, "progs/g_light.mdl");
	self.weapon = LOGIC_FINDDEFEND;
	self.netname = "Thunderbolt";
	self.touch = weapon_touch;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() ammo_touch =
{
	local entity stemp;
	local float best;

	if ( other.classname != MOON_PLAYER_CLASSNAME ) { return; }
	if ( other.health <= 0 ) { return; }

	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;

	other.ammo_shells = (other.ammo_shells + self.ammo_shells);
	other.ammo_nails = (other.ammo_nails + self.ammo_nails);
	other.ammo_rockets = (other.ammo_rockets + self.ammo_rockets);
	other.ammo_cells = (other.ammo_cells + self.ammo_cells);
	moon_limit_target_ammo(other);

	flash_target(other);
	if (self.ammo_shells)
	{
		sprint(other, "You picked up {} {}\n", floor_ftos(self.ammo_shells), MOON_AMMO_SHELLS_DISPLAYNAME);
	}
	if (self.ammo_nails)
	{
		sprint(other, "You picked up {} {}\n", floor_ftos(self.ammo_nails), MOON_AMMO_NAILS_DISPLAYNAME);
	}
	if (self.ammo_rockets)
	{
		sprint(other, "You picked up {} {}\n", floor_ftos(self.ammo_rockets), MOON_AMMO_ROCKETS_DISPLAYNAME);
	}
	if (self.ammo_cells)
	{
		sprint(other, "You picked up {} {}\n", floor_ftos(self.ammo_cells), MOON_AMMO_CELLS_DISPLAYNAME);
	}
	sound(other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);

	stemp = self;
	self = other;
	if (self.weapon == best)
	{
		self.weapon = W_BestWeapon();
	}
	W_SetCurrentAmmo();
	self = stemp;

	remove(self);
};

void() item_shells =
{
};

void() item_spikes =
{
};

void() item_rockets =
{
};

void() item_cells =
{
};

void() item_weapon =
{
};

void() key_touch =
{
};

void() key_setsounds =
{
};

void() item_key1 =
{
};

void() item_key2 =
{
};

void() sigil_touch =
{
};

void() item_sigil =
{
};

void() powerup_touch =
{
	//local entity stemp; // unused
	//local float best; // unused

	if ((other.classname != "player"))
	{
		return;
	}
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	sprint(other, "You got the ");
	sprint(other, self.netname);
	sprint(other, "\n");
	if (deathmatch)
	{
		self.mdl = self.model;
		if (((self.classname == "item_artifact_invulnerability") || (self.classname == "item_artifact_invisibility")))
		{
			self.nextthink = (time + (60 * LOGIC_PATROL));
		}
		else
		{
			self.nextthink = (time + 60);
		}
		self.think = SUB_regen;
	}
	sound(other, CHAN_VOICE, self.noise, WF_DEFEND, ATTN_NORM);
	flash_target(other);
	self.solid = SOLID_NOT;
	other.items = (other.items | self.items);
	self.model = string_null;
	if ((self.classname == "item_artifact_envirosuit"))
	{
		other.rad_time = WF_DEFEND;
		other.radsuit_finished = (time + 30);
	}
	if ((self.classname == "item_artifact_invulnerability"))
	{
		other.invincible_time = WF_DEFEND;
		other.invincible_finished = (time + 30);
	}
	if ((self.classname == "item_artifact_invisibility"))
	{
		other.invisible_time = WF_DEFEND;
		other.invisible_finished = (time + 30);
	}
	if ((self.classname == "item_artifact_super_damage"))
	{
		other.super_time = WF_DEFEND;
		other.super_damage_finished = (time + 30);
	}
	activator = other;
	SUB_UseTargets();
};

void() item_artifact_invulnerability =
{
	self.touch = powerup_touch;
	precache_model("progs/invulner.mdl");
	precache_sound("items/protect.wav");
	precache_sound("items/protect2.wav");
	precache_sound("items/protect3.wav");
	self.noise = "items/protect.wav";
	setmodel(self, "progs/invulner.mdl");
	self.netname = "Pentagram of Protection";
	self.items = IT_INVULNERABILITY;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	StartItem();
};

void() item_artifact_envirosuit =
{
	self.touch = powerup_touch;
	precache_model("progs/suit.mdl");
	precache_sound("items/suit.wav");
	precache_sound("items/suit2.wav");
	self.noise = "items/suit.wav";
	setmodel(self, "progs/suit.mdl");
	self.netname = "Biosuit";
	self.items = IT_SUIT;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	StartItem();
};

void() item_artifact_invisibility =
{
	self.touch = powerup_touch;
	precache_model("progs/invisibl.mdl");
	precache_sound("items/inv1.wav");
	precache_sound("items/inv2.wav");
	precache_sound("items/inv3.wav");
	self.noise = "items/inv1.wav";
	setmodel(self, "progs/invisibl.mdl");
	self.netname = "Ring of Shadows";
	self.items = IT_INVISIBILITY;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	StartItem();
};

void() item_artifact_super_damage =
{
	self.touch = powerup_touch;
	precache_model("progs/quaddama.mdl");
	precache_sound("items/damage.wav");
	precache_sound("items/damage2.wav");
	precache_sound("items/damage3.wav");
	self.noise = "items/damage.wav";
	setmodel(self, "progs/quaddama.mdl");
	self.netname = "Quad Damage";
	self.items = IT_QUAD;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	StartItem();
};

void() BackpackTouch =
{
	//local string s; // unused
	local float best;
	local float old;
	local float new;
	local entity stemp;
	//local float acount; // unused

	if ((other.classname != "player"))
	{
		return;
	}
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	sprint(other, "You get ");
	sprint(other, self.netname);
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;
	other.ammo_shells = (other.ammo_shells + self.ammo_shells);
	other.ammo_nails = (other.ammo_nails + self.ammo_nails);
	other.ammo_rockets = (other.ammo_rockets + self.ammo_rockets);
	other.ammo_cells = (other.ammo_cells + self.ammo_cells);
	new = self.items;
	if (!new)
	{
		new = other.weapon;
	}
	old = other.items;
	other.items = (other.items | new);
	moon_limit_target_ammo(other);
	sprint(other, " with ");
	if (self.ammo_shells)
	{
		sprint_ftos(other, self.ammo_shells);
		sprint(other, " shells");
	}
	else
	{
		if (self.ammo_nails)
		{
			sprint_ftos(other, self.ammo_nails);
			sprint(other, " nails");
		}
		else
		{
			if (self.ammo_rockets)
			{
				sprint_ftos(other, self.ammo_rockets);
				sprint(other, " rockets");
			}
			else
			{
				if (self.ammo_cells)
				{
					sprint_ftos(other, self.ammo_cells);
					sprint(other, " cells");
				}
			}
		}
	}
	sprint(other, "\n");
	sound(other, CHAN_ITEM, "weapons/pkup.wav", WF_DEFEND, ATTN_NORM);
	flash_target(other);
	remove(self);
	self = other;
	if (!deathmatch)
	{
		self.weapon = new;
	}
	else
	{
		Deathmatch_Weapon(old, new);
	}
	W_SetCurrentAmmo();
};

void() DropBackpack =
{
	local entity item;

	if (((self.weapon == IT_AXE) || (self.weapon == IT_SHOTGUN)))
	{
		return;
	}
	item = spawn();
	item.origin = (self.origin - '0 0 24');
	item.items = self.weapon;
	if ((item.items == IT_SUPER_SHOTGUN))
	{
		item.ammo_shells = self.ammo_shells;
		item.netname = "Double-barrelled Shotgun";
		setmodel(item, "progs/g_shot.mdl");
	}
	else
	{
		if ((item.items == IT_NAILGUN))
		{
			item.ammo_nails = self.ammo_nails;
			item.netname = "Nailgun";
			setmodel(item, "progs/g_nail.mdl");
		}
		else
		{
			if ((item.items == IT_SUPER_NAILGUN))
			{
				item.ammo_nails = self.ammo_nails;
				item.netname = "Super Nailgun";
				setmodel(item, "progs/g_nail2.mdl");
			}
			else
			{
				if ((item.items == IT_GRENADE_LAUNCHER))
				{
					item.ammo_rockets = self.ammo_rockets;
					item.netname = "Grenade Launcher";
					setmodel(item, "progs/g_rock.mdl");
				}
				else
				{
					if ((item.items == IT_ROCKET_LAUNCHER))
					{
						item.ammo_rockets = self.ammo_rockets;
						item.netname = "Rocket Launcher";
						setmodel(item, "progs/g_rock2.mdl");
					}
					else
					{
						if ((item.items == IT_LIGHTNING))
						{
							item.ammo_cells = self.ammo_cells;
							item.netname = "Thunderbolt";
							setmodel(item, "progs/g_light.mdl");
						}
						else
						{
							bprint("ERROR: Incorrect weapon in DropBackpack()\n");
							remove(item);
							return;
						}
					}
				}
			}
		}
	}
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = BackpackTouch;
	item.nextthink = (time + MENTAT_TIME);
	item.think = SUB_Remove;
};

void() aura_think =
{
	if ((self.owner.health <= WF_NORMAL))
	{
		remove(self);
		return;
	}
	if ((self.owner == world))
	{
		bprint("aura removed\n");
		remove(self);
		return;
	}
	self.origin = self.owner.origin;
	self.origin_z = (self.owner.origin_z + self.owner.mins_z);
	self.velocity = self.owner.velocity;
	self.think = aura_think;
	self.nextthink = (time + 0.05);
};

void(entity e, float aura) makeaura =
{
	local entity a;

	a = spawn();
	setorigin(a, e.origin);
	setmodel(a, "progs/aura.mdl");
	setsize(a, VEC_ORIGIN, VEC_ORIGIN);
	a.skin = WF_NORMAL;
	a.owner = e;
	a.solid = SOLID_NOT;
	a.movetype = MOVETYPE_NOCLIP;
	a.avelocity = '0 200 0';
	a.think = aura_think;
	a.nextthink = (time + 0.05);
};

void(entity e) GetPrefix =
{
	local float r;

	r = random_int(1, 28);
	switch(r)
	{
	case 1:
		e.prefix_three = " of slaughter";
		e.prefix = 1;
		e.prefix_value = 0.2;
		makeaura(e, 1);
		break;
	case 2:
		e.prefix_three = " of violence";
		e.prefix = 1;
		e.prefix_value = 0.4;
		makeaura(e, 1);
		break;
	case 3:
		e.prefix_three = " in snake armor";
		e.prefix = 2;
		e.prefix_value = 0.2;
		break;
	case 4:
		e.prefix_three = " in demon skin";
		e.prefix = 2;
		e.prefix_value = 0.5;
		e.health = (e.health * 2.5);
		e.exp = (e.exp * 2);
		break;
	case 5:
		e.prefix_three = " in bear armor";
		e.prefix = 2;
		e.prefix_value = 1;
		break;
	case 6:
		e.prefix_three = " of weakness";
		e.health = rint(e.health / 2);
		break;
	case 7:
		e.prefix_three = " the profitable"; // TODO: may be "the experienced"?
		e.exp = rint(e.exp * 1.5);
		break;
	case 8:
		e.prefix_three = " the rip";
		e.exp = 1;
		e.health = 20;
		break;
	case 9:
		e.prefix_three = " the warrior";
		e.prefix = 3;
		break;
	case 10:
		e.prefix_three = " the hunter";
		e.prefix = 3;
		break;
	case 11:
		e.prefix_three = " of regeneration";
		e.prefix = 4;
		e.prefix_value = 3;
		break;
	case 12:
		e.prefix_three = " of great reshape";
		e.prefix = 4;
		e.prefix_value = 10;
		break;
	case 13:
		e.prefix_three = " the rich";
		e.prefix = 5;
		e.prefix_value = 200;
		break;
	case 14:
		e.prefix_three = " the treasurer";
		e.prefix = 5;
		e.prefix_value = 500;
		break;
	case 15:
		e.prefix_three = " the millioner";
		e.prefix = 5;
		e.prefix_value = 1000;
		break;
	case 16:
		e.prefix_three = " the petard";
		e.prefix = 6;
		e.prefix_value = 120;
		break;
	case 17:
		e.prefix_three = " the bomb";
		e.prefix = 6;
		e.prefix_value = 220;
		break;
	case 18:
		e.prefix_three = " the nuclear";
		e.prefix = 6;
		e.prefix_value = 420;
		break;
	case 19:
		e.prefix_three = " the chosen";
		e.prefix = 7;
		e.prefix_value = 50;
		makeaura(e, 1);
		break;
	case 20:
		e.prefix_three = " of destroying";
		e.prefix = 7;
		e.prefix_value = 100;
		makeaura(e, 1);
		break;
	case 21:
		e.prefix_three = " of humiliation";
		e.prefix = 7;
		e.prefix_value = 200;
		makeaura(e, 1);
		break;
	case 22:
		e.prefix_three = " of world erasing";
		e.prefix = 7;
		e.prefix_value = 300;
		makeaura(e, 1);
		break;
	case 23:
		e.prefix_three = " of resistance";
		e.prefix = 8;
		e.prefix_value = 30;
		break;
	case 24:
		e.prefix_three = " in wood armor";
		e.prefix = 8;
		e.prefix_value = 40;
		break;
	case 25:
		e.prefix_three = " in bronze armor";
		e.prefix = 8;
		e.prefix_value = 60;
		break;
	case 26:
		e.prefix_three = " of failure";
		e.prefix = 9;
		e.prefix_value = 30;
		break;
	case 27:
		e.prefix_three = " of receive";
		e.prefix = 9;
		e.prefix_value = 60;
		break;
	case 28:
		e.prefix_three = " of cry";
		e.prefix = 9;
		e.prefix_value = 90;
		break;
	}
};

void() do_earthquake =
{
	local entity e;

	if ((self.attack_finished < time))
	{
		remove(self);
		return;
	}
	e = find(world, classname, "player");
	while (e)
	{
		if ((e.flags & FL_ONGROUND))
		{
			if ((self.radsuit_finished < time))
			{
				if (((self.attack_finished - LOGIC_PATROL) > time))
				{
					sound(e, CHAN_AUTO, "moon/ambient/quake.wav", 1, ATTN_NORM);
				}
			}
			e.flags = (e.flags - FL_ONGROUND);
			e.velocity_x = (e.velocity_x + (crandom() * self.delay));
			e.velocity_y = (e.velocity_y + (crandom() * self.delay));
			e.velocity_z = (e.velocity_z + (random() * self.delay));
		}
		e = find(e, classname, "player");
	}
	if ((self.radsuit_finished < time))
	{
		self.radsuit_finished = (time + H_ROTTEN);
	}
	self.think = do_earthquake;
	self.nextthink = ((time + MON_REACTIONTIME) - (random() * MON_CAMPERCHANCE));
};

void(float dl, float el) earthquake = // TODO: extract constants for tuning
{
	local entity e;

	if ((el < 64))
	{
		el = 64;
	}
	e = spawn();
	e.think = do_earthquake;
	e.delay = el;
	e.nextthink = (time + 1);
	e.attack_finished = ((time + dl) + (random() * dl));
};

void() misc_head = // need to find classname with same string
{
	setmodel(self, self.netname);
};

void() flr_think =
{
	if ((sv_alwaysday == 1))
	{
		lightstyle(KEY_MOVEBACK, "m");
		self.nextthink = (time + GRD_PATROLTIME);
		self.think = flr_think;
		return;
	}
	if ((self.count == H_ROTTEN))
	{
		lightstyle(KEY_MOVEBACK, "m");
	}
	if ((self.count == H_MEGA))
	{
		lightstyle(KEY_MOVEBACK, "l");
	}
	if ((self.count == LOGIC_FINDDEFEND))
	{
		lightstyle(KEY_MOVEBACK, "k");
	}
	if ((self.count == LOGIC_DEFEND))
	{
		lightstyle(KEY_MOVEBACK, "j");
	}
	if ((self.count == LOGIC_PATROL))
	{
		lightstyle(KEY_MOVEBACK, "i");
	}
	if ((self.count == LOGIC_HUNTENEMY))
	{
		lightstyle(KEY_MOVEBACK, "h");
	}
	if ((self.count == TE_WIZSPIKE))
	{
		lightstyle(KEY_MOVEBACK, "g");
	}
	if ((self.count == KEY_MOVERIGHT))
	{
		lightstyle(KEY_MOVEBACK, "f");
	}
	if ((self.count == TE_LIGHTNING3))
	{
		lightstyle(KEY_MOVEBACK, "e");
	}
	if ((self.count == TE_LAVASPLASH))
	{
		lightstyle(KEY_MOVEBACK, "d");
	}
	if ((self.count == TE_TELEPORT))
	{
		lightstyle(KEY_MOVEBACK, "c");
	}
	if ((self.count == 12))
	{
		lightstyle(KEY_MOVEBACK, "b");
	}
	if ((self.count == 13))
	{
		lightstyle(KEY_MOVEBACK, "a");
	}
	if ((self.weapon == H_ROTTEN))
	{
		self.count = (self.count + H_ROTTEN);
	}
	else
	{
		self.count = (self.count - H_ROTTEN);
	}
	if ((self.count > 13))
	{
		self.count = 13;
		self.weapon = WF_NORMAL;
		self.nextthink = (time + GRD_PATROLTIME);
	}
	else
	{
		if ((self.count < WF_NORMAL))
		{
			self.count = WF_NORMAL;
			self.weapon = H_ROTTEN;
			self.nextthink = (time + GRD_PATROLTIME);
		}
		else
		{
			self.nextthink = (time + TE_LAVASPLASH);
		}
	}
	self.think = flr_think;
};

void() flr = // need to find classname with same string
{
	lightstyle(KEY_MOVEBACK, "n");
	self.count = H_ROTTEN;
	self.weapon = H_ROTTEN;
	self.spawnflags = KEY_LOOKRIGHT;
	self.nextthink = (time + TE_LAVASPLASH);
	self.think = flr_think;
};

void() moon4_touch = // Works - dont touch
{
	local entity tmp;
	local float nextnum;
	local float nextline;

	if ((other.goalentity != self))
	{
		return;
	}
	if ((other.flags & FL_MONSTER))
	{
		if ((other.health <= WF_NORMAL))
		{
			if ((other.goalentity == self))
			{
				bprint("ERROR: Died monster tries to touch waypoint. Please report this bug\n");
				bprint("ERROR INFO:\n netname:");
				bprint(other.netname);
				bprint("\n");
				remove(other);
			}
		}
	}
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	if (((other.wantline <= WF_NORMAL) || (other.wantline > TE_WIZSPIKE)))
	{
		dprint("ERROR: movecode has requested nonexistent way ({} line was requested). Please report this bug.\n", quick_ftos(other.wantline));
	}
	if ((other.mon_logic == LOGIC_CAMPER))
	{
		if ((other.flags & FL_MONSTER))
		{
			if (((other.wantline == self.line) && (other.wantnum == self.num)))
			{
				other.goalentity = world;
				other.mon_logic = LOGIC_STANDART;
				other.camp_time = ((time + 30) + (random() * 30));
			}
		}
	}
	if (((((other.classname == "guard") && (other.wantnum == self.num)) && (other.wantline == self.line)) && (other.action > WF_NORMAL)))
	{
		if ((other.action == LOGIC_PATROL))
		{
			GeneratePatrolTarget(other);
		}
		if ((other.action == LOGIC_FINDDEFEND))
		{
			other.action = LOGIC_DEFEND;
			other.velocity = VEC_ORIGIN;
			other.think = other.th_stand;
			return;
		}
	}
	if ((other.flags & FL_MONSTER))
	{
		other.velocity = VEC_ORIGIN;
	}
	nextline = self.line;
	if (((self.line == LOGIC_HUNTENEMY) && (self.num == LOGIC_PATROL)))
	{
		if ((other.enemy.classname == "shoot_ent"))
		{
			return;
		}
	}
	if ((other.wantline == self.line))
	{
		if ((other.wantnum > self.num))
		{
			nextnum = (self.num + H_ROTTEN);
		}
		if ((other.wantnum < self.num))
		{
			nextnum = (self.num - H_ROTTEN);
		}
		if ((other.wantnum == self.num))
		{
			other.think = other.th_stand;
		}
	}
	else
	{
		if ((self.line == H_ROTTEN))
		{
			if (((self.num == 12) && ((other.wantline == LOGIC_PATROL) || (other.wantline == LOGIC_HUNTENEMY))))
			{
				nextline = LOGIC_PATROL;
				nextnum = LOGIC_DEFEND;
			}
			else
			{
				if ((other.wantline == TE_WIZSPIKE))
				{
					if ((self.num < TE_WIZSPIKE))
					{
						nextnum = (self.num + H_ROTTEN);
					}
					else
					{
						if ((self.num > TE_WIZSPIKE))
						{
							nextnum = (self.num - H_ROTTEN);
						}
						else
						{
							if ((self.num == TE_WIZSPIKE))
							{
								nextline = TE_WIZSPIKE;
								nextnum = LOGIC_PATROL;
							}
						}
					}
				}
				else
				{
					if ((other.wantline == LOGIC_FINDDEFEND))
					{
						if ((self.num < TE_LAVASPLASH))
						{
							nextnum = (self.num + H_ROTTEN);
						}
						else
						{
							if ((self.num > TE_LAVASPLASH))
							{
								nextnum = (self.num - H_ROTTEN);
							}
							else
							{
								if ((self.num == TE_LAVASPLASH))
								{
									nextline = LOGIC_FINDDEFEND;
									nextnum = H_ROTTEN;
								}
							}
						}
					}
					else
					{
						if ((other.wantline == H_MEGA))
						{
							if ((self.num < LOGIC_DEFEND))
							{
								nextnum = (self.num + H_ROTTEN);
							}
							else
							{
								if ((self.num > LOGIC_DEFEND))
								{
									nextnum = (self.num - H_ROTTEN);
								}
								else
								{
									if ((self.num == LOGIC_DEFEND))
									{
										nextline = H_MEGA;
										nextnum = H_ROTTEN;
									}
								}
							}
						}
						else
						{
							if (((other.wantline >= LOGIC_DEFEND) && (other.wantline <= LOGIC_HUNTENEMY)))
							{
								if (((self.num == LOGIC_PATROL) || (self.num == LOGIC_HUNTENEMY)))
								{
									nextline = LOGIC_DEFEND;
									nextnum = H_ROTTEN;
								}
								else
								{
									if ((self.num < LOGIC_PATROL))
									{
										nextnum = (self.num + H_ROTTEN);
									}
									else
									{
										if ((self.num > LOGIC_PATROL))
										{
											nextnum = (self.num - H_ROTTEN);
										}
									}
								}
							}
						}
					}
				}
			}
		}
		else
		{
			if ((self.line == H_MEGA))
			{
				if (((self.num == KEY_MOVERIGHT) && ((other.wantline == LOGIC_PATROL) || (other.wantline == LOGIC_HUNTENEMY))))
				{
					nextline = LOGIC_HUNTENEMY;
					nextnum = LOGIC_DEFEND;
				}
				else
				{
					if ((((other.wantline == H_ROTTEN) || (other.wantline == LOGIC_FINDDEFEND)) || (other.wantline == TE_WIZSPIKE)))
					{
						if ((self.num > H_ROTTEN))
						{
							nextnum = (self.num - H_ROTTEN);
						}
						else
						{
							if ((self.num == H_ROTTEN))
							{
								nextline = H_ROTTEN;
								nextnum = LOGIC_DEFEND;
							}
						}
					}
					else
					{
						if (((other.wantline >= LOGIC_DEFEND) && (other.wantline <= LOGIC_HUNTENEMY)))
						{
							if ((self.num < H_MEGA))
							{
								nextnum = (self.num + H_ROTTEN);
							}
							else
							{
								if ((self.num > H_MEGA))
								{
									nextnum = (self.num - H_ROTTEN);
								}
								else
								{
									if ((self.num == H_MEGA))
									{
										nextline = LOGIC_DEFEND;
										nextnum = LOGIC_PATROL;
									}
								}
							}
						}
					}
				}
			}
			else
			{
				if ((self.line == LOGIC_FINDDEFEND))
				{
					if ((((other.wantline == LOGIC_PATROL) || (other.wantline == LOGIC_HUNTENEMY)) && (self.num >= LOGIC_HUNTENEMY)))
					{
						if (((self.num == LOGIC_HUNTENEMY) || (self.num == TE_WIZSPIKE)))
						{
							nextline = LOGIC_PATROL;
							nextnum = LOGIC_DEFEND;
						}
						else
						{
							if (((self.num == KEY_MOVERIGHT) || (self.num == TE_LIGHTNING3)))
							{
								nextline = LOGIC_HUNTENEMY;
								nextnum = LOGIC_DEFEND;
							}
						}
					}
					else
					{
						if (((((other.wantline == H_MEGA) || (other.wantline == H_ROTTEN)) || ((other.wantline >= LOGIC_DEFEND) && (other.wantline <= LOGIC_HUNTENEMY))) || (other.wantline == TE_WIZSPIKE)))
						{
							if ((self.num > H_ROTTEN))
							{
								nextnum = (self.num - H_ROTTEN);
							}
							else
							{
								if ((self.num == H_ROTTEN))
								{
									nextline = H_ROTTEN;
									nextnum = TE_LAVASPLASH;
								}
							}
						}
					}
				}
				else
				{
					if ((self.line == LOGIC_DEFEND))
					{
						if (((other.wantline == H_ROTTEN) && (other.wantnum <= H_MEGA)))
						{
							if ((self.num == LOGIC_FINDDEFEND))
							{
								if ((random() < MON_BACKTIME))
								{
									nextnum = LOGIC_DEFEND;
								}
								else
								{
									nextnum = H_MEGA;
								}
							}
							else
							{
								if ((self.num < LOGIC_FINDDEFEND))
								{
									if ((self.num > H_ROTTEN))
									{
										nextnum = (self.num - H_ROTTEN);
									}
									else
									{
										if ((self.num == H_ROTTEN))
										{
											nextline = H_ROTTEN;
											nextnum = LOGIC_HUNTENEMY;
										}
									}
								}
								else
								{
									if ((self.num > LOGIC_FINDDEFEND))
									{
										if ((self.num < LOGIC_PATROL))
										{
											nextnum = (self.num + H_ROTTEN);
										}
										else
										{
											if ((self.num == LOGIC_PATROL))
											{
												nextline = H_MEGA;
												nextnum = H_MEGA;
											}
										}
									}
								}
							}
						}
						else
						{
							if ((((other.wantline == H_ROTTEN) || (other.wantline == LOGIC_FINDDEFEND)) || (other.wantline == TE_WIZSPIKE)))
							{
								if ((self.num > H_ROTTEN))
								{
									nextnum = (self.num - H_ROTTEN);
								}
								else
								{
									if ((self.num == H_ROTTEN))
									{
										nextline = H_ROTTEN;
										nextnum = LOGIC_HUNTENEMY;
									}
								}
							}
							else
							{
								if ((other.wantline == H_MEGA))
								{
									if ((self.num < LOGIC_PATROL))
									{
										nextnum = (self.num + H_ROTTEN);
									}
									else
									{
										if ((self.num == LOGIC_PATROL))
										{
											nextline = H_MEGA;
											nextnum = H_MEGA;
										}
									}
								}
								else
								{
									if (((other.wantline == LOGIC_PATROL) || (other.wantline == LOGIC_HUNTENEMY)))
									{
										if ((self.num < LOGIC_FINDDEFEND))
										{
											nextnum = (self.num + H_ROTTEN);
										}
										else
										{
											if ((self.num > LOGIC_FINDDEFEND))
											{
												nextnum = (self.num - H_ROTTEN);
											}
											else
											{
												if ((self.num == LOGIC_FINDDEFEND))
												{
													nextline = LOGIC_HUNTENEMY;
													nextnum = LOGIC_HUNTENEMY;
												}
											}
										}
									}
								}
							}
						}
					}
					else
					{
						if ((self.line == LOGIC_PATROL))
						{
							if (((other.wantline < LOGIC_PATROL) || (other.wantline == TE_WIZSPIKE)))
							{
								nextnum = (self.num + H_ROTTEN);
								if ((self.num == LOGIC_PATROL))
								{
									nextline = LOGIC_HUNTENEMY;
									nextnum = LOGIC_PATROL;
								}
							}
							else
							{
								if ((other.wantline == LOGIC_HUNTENEMY))
								{
									if ((other.wantnum < LOGIC_FINDDEFEND))
									{
										nextnum = (self.num + H_ROTTEN);
									}
									else
									{
										nextline = LOGIC_HUNTENEMY;
										nextnum = self.num;
									}
								}
							}
						}
						else
						{
							if ((self.line == LOGIC_HUNTENEMY))
							{
								if (((other.wantline < LOGIC_PATROL) || (other.wantline == TE_WIZSPIKE)))
								{
									nextnum = (self.num + H_ROTTEN);
									if ((self.num == LOGIC_HUNTENEMY))
									{
										nextline = LOGIC_DEFEND;
										nextnum = LOGIC_FINDDEFEND;
									}
								}
								else
								{
									if ((other.wantline == LOGIC_PATROL))
									{
										if ((other.wantnum < LOGIC_FINDDEFEND))
										{
											nextnum = (self.num + H_ROTTEN);
										}
										else
										{
											if ((self.num == LOGIC_HUNTENEMY))
											{
												nextnum = (self.num - H_ROTTEN);
											}
											else
											{
												nextline = LOGIC_PATROL;
												nextnum = self.num;
											}
										}
									}
								}
							}
							else
							{
								if ((self.line == TE_WIZSPIKE))
								{
									if ((self.num == LOGIC_PATROL))
									{
										nextnum = TE_WIZSPIKE;
										nextline = H_ROTTEN;
									}
									else
									{
										if ((self.wantline < TE_WIZSPIKE))
										{
											nextnum = (self.num + H_ROTTEN);
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	tmp = find(world, classname, "waypoint");
	while (tmp)
	{
		if ((tmp.num == nextnum))
		{
			if ((tmp.line == nextline))
			{
				other.goalentity = tmp;
				return;
			}
		}
		tmp = find(tmp, classname, "waypoint");
	}
};

entity() find_closest_ns =
{
	local entity e;
	local entity selected;
	local float best_waypoint_dist;

	selected = world;
	best_waypoint_dist = 99999;
	e = find(world, classname, "sale_way");
	while ((e != world))
	{
		if (CanDamage(e, self))
		{
			if ((vlen((e.origin - self.origin)) < best_waypoint_dist))
			{
				selected = e;
				best_waypoint_dist = vlen((e.origin - self.origin));
			}
		}
		e = find(e, classname, "sale_way");
	}
	return (selected);
};

float() find_ns =
{
	if ((self.goalentity.classname == "sale_way"))
	{
		return (FALSE);
	}
	self.goalentity = find_closest_ns();
	if ((self.goalentity == world))
	{
		return (FALSE);
	}
	self.ideal_yaw = vectoyaw((self.goalentity.origin - self.origin));
	return (TRUE);
};

void() PlaceWeapon =
{
	local entity e;
	local float r;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = "goody_ent";
	e.netname = "goody_weapon";
	e.noise1 = "weapons/pkup.wav";
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", H_ROTTEN, ATTN_NORM);
	r = random();
	if ((r < 0.16))
	{
		setmodel(e, "progs/g_shot.mdl");
		e.ammo_shells = rint((random() * LOGIC_PATROL));
		e.cost = (GRD_DEFENDTIME + (e.ammo_shells * H_MEGA));
		e.targetname = "Inferioity Double-barrelled Shotgun";
		e.items = IT_SUPER_SHOTGUN;
	}
	else
	{
		if ((r < 0.33))
		{
			setmodel(e, "progs/g_nail.mdl");
			e.ammo_nails = rint((random() * 30));
			e.cost = (70 + e.ammo_nails);
			e.targetname = "Inferioity Nailgun";
			e.items = IT_NAILGUN;
		}
		else
		{
			if ((r < MON_BACKTIME))
			{
				setmodel(e, "progs/g_nail2.mdl");
				e.ammo_nails = rint((random() * 30));
				e.cost = (100 + e.ammo_nails);
				e.targetname = "Inferioity Super Nailgun";
				e.items = IT_SUPER_NAILGUN;
			}
			else
			{
				if ((r < 0.66))
				{
					setmodel(e, "progs/g_rock.mdl");
					e.ammo_rockets = rint((random() * LOGIC_PATROL));
					e.cost = (150 + (e.ammo_rockets * LOGIC_FINDDEFEND));
					e.targetname = "Inferioity Grenade Launcher";
					e.items = IT_GRENADE_LAUNCHER;
				}
				else
				{
					if ((r < 0.82))
					{
						setmodel(e, "progs/g_rock2.mdl");
						e.ammo_rockets = rint((random() * LOGIC_PATROL));
						e.cost = (250 + (e.ammo_rockets * LOGIC_FINDDEFEND));
						e.targetname = "Inferioity Rocket Launcher";
						e.items = IT_ROCKET_LAUNCHER;
					}
					else
					{
						setmodel(e, "progs/g_light.mdl");
						e.ammo_cells = rint((random() * 12));
						e.cost = (400 + (e.ammo_cells * H_MEGA));
						e.targetname = "Inferioity Thunderbolt";
						e.items = IT_LIGHTNING;
					}
				}
			}
		}
	}
};

void() PlaceArmor =
{
	local entity e;
	local float r;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = "goody_ent";
	e.netname = "goody_armor";
	e.noise1 = "items/armor1.wav";
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", H_ROTTEN, ATTN_NORM);
	setmodel(e, "progs/armor.mdl");
	r = random();
	if ((r < 0.36))
	{
		e.skin = 0;
		e.armorvalue = (50 + rint((random() * 50)));
		e.armortype = 0.3;
		e.items = IT_ARMOR1;
		e.cost = rint((e.armorvalue * MON_BACKTIME));
	}
	else
	{
		if ((r < 0.7))
		{
			e.skin = 1;
			e.armorvalue = (100 + rint((random() * 50)));
			e.armortype = 0.6;
			e.items = IT_ARMOR2;
			e.cost = rint((e.armorvalue * 0.6));
		}
		else
		{
			e.skin = 2;
			e.armorvalue = (150 + rint((random() * 50)));
			e.armortype = 0.8;
			e.items = IT_ARMOR3;
			e.cost = rint((e.armorvalue * 0.7));
		}
	}
};

float(float effect_code, float effect_value) moon_calculate_effect_cost =
{
	switch(effect_code)
	{
		case MOON_ITEM_HEALTH_CODE	: return (effect_value * MOON_ITEM_HEALTH_MARKET_COST_SCALE);
		case MOON_ITEM_RESIST_CODE	: return (effect_value * MOON_ITEM_RESIST_MARKET_COST_SCALE);
		case MOON_ITEM_GOLD_CODE	: return (effect_value * MOON_ITEM_GOLD_MARKET_COST_SCALE);
		case MOON_ITEM_DAMAGE_CODE	: return (effect_value * MOON_ITEM_DAMAGE_MARKET_COST_SCALE);
		case MOON_ITEM_RETALATE_CODE: return (effect_value * MOON_ITEM_RETALATE_MARKET_COST_SCALE);
		case MOON_ITEM_VAMPIR_CODE	: return (effect_value * MOON_ITEM_VAMPIR_MARKET_COST_SCALE);
		case MOON_ITEM_REGEN_CODE	: return (effect_value * MOON_ITEM_REGEN_MARKET_COST_SCALE);
		case MOON_ITEM_CONSUME_CODE : return (effect_value * MOON_ITEM_CONSUME_MARKET_COST_SCALE);
		default: return 42;
	}
};

void(entity e) moon_calculate_magic_cost =
{
	local float ccost;

	ccost = MOON_ITEM_MARKET_COST_BASE;
	ccost = ccost + moon_calculate_effect_cost(e.magic_typeone, e.magic_typeone_value);
	ccost = ccost + moon_calculate_effect_cost(e.magic_typetwo, e.magic_typetwo_value);

	e.cost = ccost;
};

void() PlaceAmmoBox =
{
	local entity e;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, (((self.origin + (v_forward * 47)) - '0 0 24') + (v_right * KEY_MOVERIGHT)));
	e.solid = SOLID_NOT;
	e.classname = "goody_ent";
	e.netname = "goody_ammo";
	e.skin = WF_NORMAL;
	setmodel(e, s_wiz);
	e.noise1 = "weapons/lock4.wav";
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", H_ROTTEN, ATTN_NORM);
	if ((random() < 0.6))
	{
		setmodel(e, "maps/b_rock0.bsp");
		e.ammo_rockets = ceil((15 + (random() * 10)));
		e.cost = ceil((e.ammo_rockets * 6));
		e.targetname = "rockets";
	}
	else
	{
		setmodel(e, "maps/b_batt0.bsp");
		e.ammo_cells = ceil((15 + (random() * 7)));
		e.cost = ceil((e.ammo_cells * 8));
		e.targetname = "cells";
	}
};

void() PlaceElixir =
{
	local entity e;
	local float code;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = MOON_MARKET_ITEM_CLASSNAME;
	e.netname = MOON_ELIXIR_MARKET_NETNAME;
	e.skin = H_MEGA;
	setmodel(e, "progs/potion.mdl");
	e.noise1 = "moon/items/potion.wav";
	e.owner = self;
	code = random_int(MOON_ELIXIR_STR_CODE, MOON_ELIXIR_VIT_CODE);
	switch(code)
	{
		case MOON_ELIXIR_STR_CODE:
			e.targetname = MOON_ELIXIR_STR_NAME;
			e.healtype = MOON_ELIXIR_STR_CODE;
			e.cost = 3000;
			break;
		case MOON_ELIXIR_VIT_CODE:
			e.targetname = MOON_ELIXIR_VIT_NAME;
			e.healtype = MOON_ELIXIR_VIT_CODE;
			e.cost = 2000;
			break;
	}
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);
};

void() PlaceMagicItem =
{
	local entity e;
	local float z;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = "goody_ent";
	if ((random() < MON_BACKTIME))
	{
		e.netname = "armor";
		setmodel(e, "progs/armor.mdl");
		e.noise1 = "items/armor1.wav";
		e.skin = 3;
	} else {
		e.netname = "ring";
		setmodel(e, "progs/ring.mdl");
		e.noise1 = "moon/items/ring.wav";
	}
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", H_ROTTEN, ATTN_NORM);
	z = random();
	if ((z < MOON_ITEM_MAGIC_CHANCE_PREFIX))
	{
		moon_generate_magic_prefix(e);
	}
	else
	{
		if ((z < MOON_ITEM_MAGIC_CHANCE_POSTFIX))
		{
			moon_generate_magic_postfix(e);
		}
		else
		{
			moon_generate_magic_prefix(e);
			moon_generate_magic_postfix(e);
		}
	}
	moon_calculate_magic_cost(e);
};

void() PlaceMega =
{
	local entity e;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, (((self.origin + (v_forward * 49)) - '0 0 24') + (v_right * KEY_MOVEFORWARD)));
	e.solid = SOLID_NOT;
	e.angles_y = anglemod((self.angles_y + MENTAT_TIME));
	e.classname = "goody_ent";
	e.netname = "goody_mega";
	e.noise1 = "items/r_item2.wav";
	e.healamount = rint((50 + (random() * 50)));
	e.cost = (e.healamount * 0.85);
	e.owner = self;
	e.healtype = H_MEGA;
	sound(e, CHAN_ITEM, "items/itembk2.wav", H_ROTTEN, ATTN_NORM);
	setmodel(e, "maps/b_bh100.bsp");
};

void() PlaceGoody =
{
	local float r;

	r = random();
	if ((r < MON_REACTIONTIME))
	{
		PlaceMagicItem();
	}
	else
	{
		if ((r < 0.37))
		{
			PlaceWeapon();
		}
		else
		{
			if ((r < 0.52))
			{
				PlaceMega();
			}
			else
			{
				if ((r < 0.7))
				{
					PlaceArmor();
				}
				else
				{
					if ((r < 0.83))
					{
						PlaceElixir();
					}
					else
					{
						PlaceAmmoBox();
					}
				}
			}
		}
	}
	self.free = H_MEGA;
};

void() saler_stand =
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
		self.walkframe = (self.walkframe + H_ROTTEN);
		self.framtime = (time + 0.07);
	}
	self.ideal_yaw = self.cnt;
	ChangeYaw();
	if ((((self.angles_y >= (self.cnt - H_MEGA)) && (self.angles_y <= (self.cnt + H_MEGA))) && (self.free == H_ROTTEN)))
	{
		PlaceGoody();
	}
	if ((self.attack_finished < time))
	{
		self.action = H_MEGA;
		a = find(world, classname, "sale_ent");
		while (a)
		{
			if ((a.enemy == self))
			{
				a.free = TRUE;
			}
			a = find(a, classname, "sale_ent");
		}
		a = find(world, classname, "goody_ent");
		while (a)
		{
			if ((a.owner == self))
			{
				sound(self, CHAN_ITEM, a.noise1, H_ROTTEN, ATTN_NORM);
				remove(a);
			}
			a = find(a, classname, "goody_ent");
		}
		self.stuck_time = WF_NORMAL;
		self.rstuck_time = WF_NORMAL;
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
				self.spam_vector = ((v_right * ((self.goalentity.radius / H_MEGA) + ((self.goalentity.radius / H_MEGA) * random()))) * CONTENT_EMPTY);
			}
			else
			{
				self.spam_vector = (v_right * ((self.goalentity.radius / H_MEGA) + ((self.goalentity.radius / H_MEGA) * random())));
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
				stream = (self.goalentity.radius * H_MEGA);
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
		self.frame = (WF_NORMAL + self.walkframe);
		self.walkframe = (self.walkframe + H_ROTTEN);
		self.framtime = (time + 0.07);
	}
	saler_runn();
	if ((self.action == LOGIC_FINDDEFEND))
	{
		self.th_stand();
	}
};

void() spawn_saler =
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
	e.health = H_ROTTEN;
	e.yaw_speed = LOGIC_HUNTENEMY;
	e.wantnum = LOGIC_DEFEND;
	e.speed = 200;
	e.action = H_ROTTEN;
	e.attack_finished = ((time + GRD_PATROLTIME) + (GRD_PATROLTIME * random()));
	e.th_stand = saler_stand;
	e.th_run = saler_run;
	e.think = saler_stand;
	e.nextthink = time;
	e.classname = "saler";
	e.free = WF_NORMAL;
	e.cnt = CONTENT_EMPTY;
};

void() sale_think =
{
	spawn_saler();
	self.nextthink = ((time + 15) + (10 * random()));
	self.think = sale_think;
};

void() walkman_think =
{
	if (time > self.next_heart)
	{
		self.next_heart = time + MOON_WALKMAN_DELAY_BETWEENTRACKS + moon_walkman_start_music_shop(self.master); // self.master caches emitter_shop
	}

	if (time > self.next_gate)
	{
		self.next_gate = time + MOON_WALKMAN_DELAY_BETWEENTRACKS + moon_walkman_start_music_gate(self.killer); // self.killer caches emitter_gate
	}

	self.nextthink = time + 30;
	self.think = walkman_think;
};

void() sale_brain =
{
	local entity e;

	e = spawn();
	e.nextthink = ((time + 20) + (2 * random()));
	e.think = sale_think;
};

void() walkman_brain =
{
	local entity e;

	local entity emitter_gate;
	local entity emitter_shop;

	emitter_gate = find(world, classname, MOON_GATE_CLASSNAME);
	if (emitter_gate == world)
	{
		bprint("Cannot find any sound gate\n");
		return;
	}

	emitter_shop = find(world, netname, "health_trader");
	if (emitter_shop == world)
	{
		bprint("Cannot find any healthy trader\n");
		return;
	}

	e = spawn();
	e.killer = emitter_gate;
	e.master = emitter_shop;

	e.next_gate = time + 32;

	e.think = walkman_think;
	e.nextthink = (time + 10) + (20 * random());
};

void() s_touch =
{
	if ((other.goalentity != self))
	{
		return;
	}
	if ((other.classname != "saler"))
	{
		return;
	}
	other.wantnum = 2;
	other.action = 3;
	other.cnt = self.angles_y;
	other.ideal_yaw = self.angles_y;
	other.goalentity = world;
	self.enemy = other;
	self.free = FALSE;
	other.free = 1;
};

void(vector org, float ang, float nm) S =
{
	local entity e;

	e = spawn();
	setorigin(e, org);
	e.angles_y = ang;
	e.num = nm;
	e.radius = 60;
	e.free = TRUE;
	e.classname = "sale_ent";
	setsize(e, '-4 -4 0', '4 4 8');
	e.touch = s_touch;
	e.solid = SOLID_TRIGGER;
	setsize(e, '-4 -4 0', '4 4 8');
};

void() ns_touch =
{
	local entity tmp;
	local float nextnum;
	local float zzz;
	local entity ops;

	if ((other.goalentity != self))
	{
		return;
	}
	if ((other.classname != "saler"))
	{
		return;
	}
	if ((other.wantnum > self.num))
	{
		nextnum = (self.num + 1);
	}
	if ((other.wantnum < self.num))
	{
		nextnum = (self.num - 1);
	}
	if (((other.action == 2) && (self.num == 2)))
	{
		remove(other);
		return;
	}
	if ((((other.action == 1) && (self.num < 4)) || (other.action == 2)))
	{
		tmp = find(world, classname, "sale_way");
		while (tmp)
		{
			if ((tmp.num == nextnum))
			{
				other.goalentity = tmp;
				return;
			}
			tmp = find(tmp, classname, "sale_way");
		}
	}
	else
	{
		while (TRUE)
		{
			zzz = rint((random() * 5));
			ops = find(world, classname, "sale_ent");
			while (ops)
			{
				if ((ops.num == zzz))
				{
					if ((ops.free == TRUE))
					{
						other.goalentity = ops;
						return;
					}
				}
				ops = find(ops, classname, "sale_ent");
			}
		}
	}
	bprint("ERROR: ns_touch error\n");
};

void(vector org, float nm, float rd) NS =
{
	local entity e;

	e = spawn();
	setorigin(e, org);
	e.num = nm;
	e.radius = rd;
	setsize(e, VEC_HULL_MIN, VEC_HULL_MAX);
	e.touch = ns_touch;
	e.solid = SOLID_TRIGGER;
	setsize(e, VEC_HULL_MIN, VEC_HULL_MAX);
	e.classname = "sale_way";
};

void() moon_buy_item_market =
{
	local entity head;
	local entity selected;
	local float min_dist;
	local entity mega;
	local float best;

	min_dist = 100;
	while ( (head = find(head, classname, MOON_MARKET_ITEM_CLASSNAME)) )
	{
		if ((head.free == FALSE))
		{
			if ((vlen((head.origin - self.origin)) < min_dist))
			{
				min_dist = vlen((head.origin - self.origin));
				selected = head;
			}
		}
	}
	if ( selected == world ) { return; }

	if ( moon_pay_target_gold(self, selected.cost) == FALSE ) { return; }
	sprint(self, "\n"); // moon_pay_target_gold prints receipt, without line break
	flash_self();

	switch (selected.netname)
	{
		case MOON_ARMOR_MARKET_NETNAME:
			if (((self.armortype * self.armorvalue) >= (selected.armortype * selected.armorvalue)))
			{
				sprint(self, "You don't need it\n");
				return;
			}
			self.armortype = selected.armortype;
			self.armorvalue = selected.armorvalue;
			self.items = (((self.items & (~IT_ARMOR1)) & (~IT_ARMOR2)) & (~IT_ARMOR3)) | selected.items;

			sprint(self, "You bought {}\n", MOON_ARMOR_MARKET_DISPLAYNAME);
			sound(self, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
			break;
		case MOON_MEDKIT_MEGA_MARKET_NETNAME:
			if ( self.health >= (self.max_health + MOON_MEDKIT_MEGA_OVERHEAL_SOFTLIMIT) ) { return; }
			if ( self.health >= CONST_QC_DISPLAY_MAX ) { return; }

			if ((selected.healtype == H_MEGA))
			{
				T_Heal(self, selected.healamount, 1);
				if (!(self.items & IT_SUPERHEALTH))
				{
					mega = spawn();
					mega.nextthink = (time + 5);
					mega.think = item_megahealth_rot;
					mega.owner = self;
					self.items = (self.items | IT_SUPERHEALTH);
				}
			}

			sprint(self, "You bought {}\n", MOON_MEDKIT_MEGA_MARKET_DISPLAYNAME);
			sound(self, CHAN_ITEM, selected.noise1, 1, ATTN_NORM);
			break;
		case MOON_ELIXIR_MARKET_NETNAME:
			if ((selected.healtype == MOON_ELIXIR_VIT_CODE))
			{
				moon_raise_target_vitality(self, MOON_ELIXIR_VIT_VALUE);
			}
			if ((selected.healtype == MOON_ELIXIR_STR_CODE))
			{
				moon_raise_target_strength(self, MOON_ELIXIR_STR_VALUE);
			}
			sprint(self, "You bought {}\n", selected.targetname);
			sound(self, CHAN_ITEM, selected.noise1, 1, ATTN_NORM);
			break;
		case MOON_AMMO_MARKET_NETNAME:
			self.ammo_shells = (self.ammo_shells + selected.ammo_shells);
			self.ammo_nails = (self.ammo_nails + selected.ammo_nails);
			self.ammo_rockets = (self.ammo_rockets + selected.ammo_rockets);
			self.ammo_cells = (self.ammo_cells + selected.ammo_cells);
			moon_limit_target_ammo(self);

			best = W_BestWeapon(); // Remember best weapon before buying ammo

			if ( self.weapon == best ) // if had best weapon without ammo before, but have ammo now, change current to best as well
			{
				self.weapon = W_BestWeapon();
			}
			W_SetCurrentAmmo();

			sprint(self, "You bought");
			moon_print_target_container_ammo(self, selected); // moon_print_target_container_ammo prints summary, without line break
			sprint(self, "\n");
			sound(self, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
			break;
		case MOON_WEAPON_MARKET_NETNAME:
			self.ammo_shells = (self.ammo_shells + selected.ammo_shells);
			self.ammo_nails = (self.ammo_nails + selected.ammo_nails);
			self.ammo_rockets = (self.ammo_rockets + selected.ammo_rockets);
			self.ammo_cells = (self.ammo_cells + selected.ammo_cells);
			moon_limit_target_ammo(self);

			best = W_BestWeapon(); // Remember best weapon before buying
			self.items = (self.items | selected.items);

			if ( self.weapon == best ) // if had best weapon before, change current to best as well
			{
				self.weapon = W_BestWeapon();
			}
			W_SetCurrentAmmo();

			sprint(self, "You bought {}\n", selected.targetname);
			sound(self, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
			break;
		case MOON_ITEM_ARMOR_NETNAME:
		case MOON_ITEM_RING_NETNAME:
			other = selected;
			moon_wear_item();
			break;
	}

	selected.owner.attack_finished = 0;
	selected.owner.stuck_time = 0;
	selected.owner.rstuck_time = 0;
	selected.owner.rstuck_org = selected.owner.origin;
	setmodel(selected, string_null);
	remove(selected);
};

void() moon_identify_item_market =
{
	local entity head;
	local entity selected;
	local float min_dist;
	local entity temp;

	min_dist = 100;
	head = find(world, classname, "goody_ent");
	while (head)
	{
		if ((head.free == FALSE))
		{
			if ((vlen((head.origin - self.origin)) < min_dist))
			{
				min_dist = vlen((head.origin - self.origin));
				selected = head;
			}
		}
		head = find(head, classname, "goody_ent");
	}
	if ((selected != world))
	{
		sprint(self, "====== identify item ======\n");
		if ((selected.netname == "goody_armor"))
		{
			sprint(self, "Spoiled ");
			if ((selected.items & IT_ARMOR1))
			{
				sprint(self, "Green");
			}
			else
			{
				if ((selected.items & IT_ARMOR2))
				{
					sprint(self, "Yellow");
				}
				else
				{
					if ((selected.items & IT_ARMOR3))
					{
						sprint(self, "\sRed\s");
					}
				}
			}
			sprint(self, " armor");
		}
		else
		{
			if ((selected.netname == "goody_elixir"))
			{
				sprint(self, selected.targetname);
			}
			else
			{
				if ((selected.netname == "goody_ammo"))
				{
					if (selected.ammo_shells)
					{
						sprint_ftos(self, selected.ammo_shells);
						sprint(self, " shells");
					}
					if (selected.ammo_nails)
					{
						sprint_ftos(self, selected.ammo_nails);
						sprint(self, " nails");
					}
					if (selected.ammo_rockets)
					{
						sprint_ftos(self, selected.ammo_rockets);
						sprint(self, " rockets");
					}
					if (selected.ammo_cells)
					{
						sprint_ftos(self, selected.ammo_cells);
						sprint(self, " cells");
					}
				}
				else
				{
					if ((selected.netname == "goody_weapon"))
					{
						sprint(self, selected.targetname);
					}
					else
					{
						if ((selected.netname == "goody_mega"))
						{
							sprint(self, "Used megahealth");
						}
						else
						{
							if (((selected.netname == MOON_ITEM_ARMOR_NETNAME) || (selected.netname == MOON_ITEM_RING_NETNAME)))
							{
								temp = self;
								other = self;
								self = selected;
								MagicItemTouch();
								self = temp;
							}
						}
					}
				}
			}
		}

		sprint(self, "\n");
		sprint(self, "Cost: ");
		moon_print_golden_number(self, selected.cost);
		sprint(self, "\n");
	}
};

entity() FindClosestWaypoint =
{
	local entity e;
	local entity selected;
	local float best_waypoint_dist;

	selected = world;
	best_waypoint_dist = 99999997952;
	e = find(world, classname, "waypoint");
	while ((e != world))
	{
		if (CanDamage(e, self))
		{
			if ((vlen((e.origin - self.origin)) < best_waypoint_dist))
			{
				selected = e;
				best_waypoint_dist = vlen((e.origin - self.origin));
			}
		}
		e = find(e, classname, "waypoint");
	}
	return (selected);
};

float() FindWaypoint =
{
	if ((self.goalentity.classname == "waypoint"))
	{
		return (FALSE);
	}
	self.movetarget = FindClosestWaypoint();
	self.goalentity = FindClosestWaypoint();
	if ((self.goalentity == world))
	{
		return (FALSE);
	}
	self.ideal_yaw = vectoyaw((self.goalentity.origin - self.origin));
	return (TRUE);
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
				DropGold(self);
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
				DropGold(self);
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
	e.nextthink = ((time + 6) + (random() * 7));
	e.think = derrick_think;
};

void(vector where, float nuz, float linz, float flg, float rng) N =
{
	local entity e;

	e = spawn();
	e.classname = "waypoint";
	e.origin = where;
	e.num = nuz;
	e.flags = flg;
	e.line = linz;
	e.radius = rng;
	e.touch = moon4_touch;
	e.solid = SOLID_TRIGGER;
	if ((flg & WF_EXTRASIZE))
	{
		setsize(e, VEC_HULL2_MIN, VEC_HULL2_MAX);
	}
	else
	{
		setsize(e, VEC_WAY_MIN, VEC_WAY_MAX);
	}
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
			earthquake(r, (random() * 160)); // earthquake('12 0 0', (random() * 160));
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

void() set_map = // nothing to do here until all other problems are done
{
	if ((mapname != "moon4"))
	{
		return;
	}
	if (waypoints_ok)
	{
		return;
	}
	N('368.7 -133.5 -167.3', 12, H_ROTTEN, WF_DEFEND, 100);
	N('383 43.5 -184', TE_TELEPORT, H_ROTTEN, WF_NORMAL, 150);
	N('675.6 48.9 -184', TE_LAVASPLASH, H_ROTTEN, WF_NORMAL, 150);
	N('671.6 308.8 -240', TE_LIGHTNING3, H_ROTTEN, WF_NORMAL, 150);
	N('671.6 539.1 -320', KEY_MOVERIGHT, H_ROTTEN, WF_NORMAL, 150);
	N('671.6 758.1 -360', TE_WIZSPIKE, H_ROTTEN, WF_NORMAL, 150);
	N('393.1 773.3 -360', LOGIC_HUNTENEMY, H_ROTTEN, WF_NORMAL, 150);
	N('272.2 880.9 -360', LOGIC_PATROL, H_ROTTEN, WF_DEFEND, 150);
	N('10.2 900.8 -360', LOGIC_DEFEND, H_ROTTEN, WF_EXTRASIZE, 150);
	N('10.2 1128.6 -376', LOGIC_FINDDEFEND, H_ROTTEN, WF_NORMAL, 150);
	N('10.2 1455.1 -456', H_MEGA, H_ROTTEN, WF_NORMAL, 150);
	N('4.3 1675 -488', H_ROTTEN, H_ROTTEN, WF_DEFEND, 150);
	N('0 1867.8 -488', WF_NORMAL, H_ROTTEN, WF_NORMAL, 150);
	N('-361.8 -136.6 -167.3', KEY_MOVERIGHT, H_MEGA, WF_DEFEND, 100);
	N('-361.8 51.3 -184', TE_WIZSPIKE, H_MEGA, WF_NORMAL, 150);
	N('-684.3 42.9 -184', LOGIC_HUNTENEMY, H_MEGA, WF_NORMAL, 150);
	N('-684.3 296.1 -240', LOGIC_PATROL, H_MEGA, WF_NORMAL, 150);
	N('-684.3 505.2 -312', LOGIC_DEFEND, H_MEGA, WF_NORMAL, 150);
	N('-683.2 740.9 -360', LOGIC_FINDDEFEND, H_MEGA, WF_DEFEND, 150);
	N('-394.5 761.1 -360', H_MEGA, H_MEGA, WF_DEFEND, 150);
	N('-167.9 869.7 -360', H_ROTTEN, H_MEGA, WF_DEFEND, 150);
	N('926.5 34.8 -184', H_ROTTEN, LOGIC_FINDDEFEND, WF_NORMAL, 150);
	N('1223.4 31.2 -120', H_MEGA, LOGIC_FINDDEFEND, WF_NORMAL, 150);
	N('1233 343.7 -72', LOGIC_FINDDEFEND, LOGIC_FINDDEFEND, WF_NORMAL, 150);
	N('913.2 362.4 -24', LOGIC_DEFEND, LOGIC_FINDDEFEND, WF_NORMAL, 150);
	N('920.7 34.3 -24', LOGIC_PATROL, LOGIC_FINDDEFEND, WF_NORMAL, 150);
	N('704.8 -24.6 -24', LOGIC_HUNTENEMY, LOGIC_FINDDEFEND, WF_NORMAL, 150);
	N('247.7 -12.7 -24', TE_WIZSPIKE, LOGIC_FINDDEFEND, WF_DEFEND, 120);
	N('-48.6 -28.4 -24', KEY_MOVERIGHT, LOGIC_FINDDEFEND, WF_NORMAL, 120);
	N('-505.1 -30.1 -24', TE_LIGHTNING3, LOGIC_FINDDEFEND, WF_NORMAL, 120);
	N('370.3 603.6 -360', H_ROTTEN, LOGIC_DEFEND, WF_EXTRASIZE, 150);
	N('377.2 321.6 -360', H_MEGA, LOGIC_DEFEND, (WF_DEFEND + WF_EXTRASIZE), 150);
	N('-11.5 256.1 -360', LOGIC_FINDDEFEND, LOGIC_DEFEND, (WF_DEFEND + WF_EXTRASIZE), 200);
	N('-329.9 291.6 -360', LOGIC_DEFEND, LOGIC_DEFEND, (WF_DEFEND + WF_EXTRASIZE), 150);
	N('-359.6 529.3 -360', LOGIC_PATROL, LOGIC_DEFEND, WF_EXTRASIZE, 150);
	N('605.8 -1539.1 -360', H_ROTTEN, LOGIC_PATROL, WF_NORMAL, GRD_PATROLTIME);
	N('369.7 -1438.3 -360', H_MEGA, LOGIC_PATROL, WF_NORMAL, GRD_PATROLTIME);
	N('352.8 -930 -360', LOGIC_FINDDEFEND, LOGIC_PATROL, WF_NORMAL, 150);
	N('346.2 -558.8 -360', LOGIC_DEFEND, LOGIC_PATROL, WF_EXTRASIZE, 200);
	N('148.9 -312 -360', LOGIC_PATROL, LOGIC_PATROL, WF_EXTRASIZE, 150);
	N('-44.7 -1530.4 -360', H_ROTTEN, LOGIC_HUNTENEMY, WF_NORMAL, GRD_PATROLTIME);
	N('-217.7 -1434.2 -360', H_MEGA, LOGIC_HUNTENEMY, WF_NORMAL, GRD_PATROLTIME);
	N('-230.1 -930 -360', LOGIC_FINDDEFEND, LOGIC_HUNTENEMY, WF_NORMAL, 150);
	N('-256.7 -518.5 -360', LOGIC_DEFEND, LOGIC_HUNTENEMY, WF_EXTRASIZE, 200);
	N('6.1 -211 -360', LOGIC_PATROL, LOGIC_HUNTENEMY, WF_EXTRASIZE, 200);
	N('-7.1 14.3 -360', LOGIC_HUNTENEMY, LOGIC_HUNTENEMY, WF_EXTRASIZE, 200);
	N('676.8 1113.5 -360', LOGIC_PATROL, TE_WIZSPIKE, WF_NORMAL, 150);
	N('947.6 1108.1 -360', LOGIC_DEFEND, TE_WIZSPIKE, WF_NORMAL, 150);
	N('1181.5 1113.8 -360', LOGIC_FINDDEFEND, TE_WIZSPIKE, WF_NORMAL, 150);
	N('1351 1210.9 -360', H_MEGA, TE_WIZSPIKE, WF_NORMAL, 150);
	N('1523.2 1144 -360', H_ROTTEN, TE_WIZSPIKE, WF_NORMAL, 150);
	S('-1057.5 1625.1 -360', 220, WF_NORMAL);
	S('-1232.5 1625.1 -360', 270, H_ROTTEN);
	S('-1386.8 1625.1 -360', 270, H_MEGA);
	S('-1549.5 1606 -360', 305, LOGIC_FINDDEFEND);
	S('-1533.9 1435.1 -360', WF_NORMAL, LOGIC_DEFEND);
	NS('-301 1225.7 -360', H_ROTTEN, 100);
	NS('-300.2 1435.5 -360', H_MEGA, 100);
	NS('-768.8 1435.1 -360', LOGIC_FINDDEFEND, 100);
	NS('-1129.1 1441 -360', LOGIC_DEFEND, 100);
	gold_derrick('1340.9 1117.7 -360');
	game_brain();
	jesus_brain();
	sale_brain();
	walkman_brain();
	waypoints_ok = TRUE;
};

void(entity who) CheckEdge =
{
	local float yw;
	local float bl;
	local float dst;

	if (!who)
	{
		return;
	}
	dst = H_MEGA;
	movedist = dst;
	yw = vectoyaw((who.origin - self.origin));
	bl = !walkmove(yw, dst);
	if (bl)
	{
		movetogoal(dst);
	}
};

float(vector dir) botCheckForStep =
{
	local vector currentorigin;
	local vector v;
	local float currentflags;
	local float yaw;
	local float stepdistance;
	local float movedistance;

	currentorigin = self.origin;
	currentflags = self.flags;
	self.flags = (FL_ONGROUND | FL_PARTIALGROUND);
	dir = normalize(dir);
	dir_z = WF_NORMAL;
	yaw = vectoyaw(dir);
	if (walkmove(yaw, LOGIC_FINDDEFEND))
	{
		if (droptofloor()) // (droptofloor(WF_NORMAL, WF_NORMAL))
		{
			stepdistance = (self.origin_z - currentorigin_z);
			v = (self.origin - currentorigin);
			v_z = WF_NORMAL;
			movedistance = vlen(v);
			if ((((stepdistance > WF_NORMAL) && (stepdistance <= KEY_MOVEFORWARD)) && (movedistance != WF_NORMAL)))
			{
				self.flags = (currentflags | FL_PARTIALGROUND);
				return (H_ROTTEN);
			}
		}
	}
	self.flags = currentflags;
	setorigin(self, currentorigin);
	return (WF_NORMAL);
};

void(entity who) find_creature =
{
	local entity e;
	local entity sel;
	local float mindist;
	local float f;

	if ((who.next_fndcrt > time))
	{
		return;
	}
	who.next_fndcrt = (time + 0.25);
	mindist = 99999;
	f = FALSE;
	e = find(world, classname, "waypoint");
	while (e)
	{
		if (CanDamage(e, who))
		{
			if ((vlen((who.origin - e.origin)) < mindist))
			{
				mindist = vlen((who.origin - e.origin));
				self.wantnum = e.num;
				self.wantline = e.line;
				sel = e;
				f = TRUE;
			}
		}
		e = find(e, classname, "waypoint");
	}
	if ((f == TRUE))
	{
		if ((self.classname == "guard"))
		{
			if (((sel.num == self.wantnum) && (sel.line == self.wantline)))
			{
				if ((vlen((sel.origin - self.origin)) < 100))
				{
					if ((self.nextyaw < time))
					{
						self.ideal_yaw = (random() * 360);
						self.nextyaw = ((time + H_ROTTEN) + (LOGIC_FINDDEFEND * random()));
					}
					ChangeYaw();
					return;
				}
			}
			if ((self.currentammo == 0)) // Sign of ???
			{
				self.goalentity = FindClosestWaypoint();
				self.th_run();
			}
			return;
		}
	}
};

void(entity target, float armor_code, float armor_durability = -1) moon_init_target_as_armor =
{
	setmodel(target, "progs/armor.mdl");
	target.health = armor_durability;

	switch(armor_code)
	{
	case MOON_ARMOR_GREEN_CODE:
		target.items = IT_ARMOR1;
		target.skin = MOON_ARMOR_GREEN_SKIN;
		target.max_health = MOON_ARMOR_GREEN_DURABILITY;
		target.armortype = MOON_ARMOR_GREEN_RESISTANCE;
		target.cost = MOON_ARMOR_GREEN_SHOP_COST;
		break;
	case MOON_ARMOR_YELLOW_CODE:
		target.items = IT_ARMOR2;
		target.skin = MOON_ARMOR_YELLOW_SKIN;
		target.max_health = MOON_ARMOR_YELLOW_DURABILITY;
		target.armortype = MOON_ARMOR_YELLOW_RESISTANCE;
		target.cost = MOON_ARMOR_YELLOW_SHOP_COST;
		break;
	case MOON_ARMOR_RED_CODE:
		target.items = IT_ARMOR3;
		target.skin = MOON_ARMOR_RED_SKIN;
		target.max_health = MOON_ARMOR_RED_DURABILITY;
		target.armortype = MOON_ARMOR_RED_RESISTANCE;
		target.cost = MOON_ARMOR_RED_SHOP_COST;
		break;
	default:
		target.max_health = 1; // Division by zero guard
		dprint("Unknown armor code {}\n", armor_code);
	}

	// Adjust cost for damaged Armors
	target.armorvalue = ( (target.health > 0) ? target.health : target.max_health);
	target.cost = (target.cost * (target.armorvalue / target.max_health));
};

void(entity target, float medkit_code, float medkit_durability = -1) moon_init_target_as_medkit =
{
	target.health = medkit_durability;
	target.items = IT_SUPERHEALTH;

	switch(medkit_code)
	{
	case MOON_MEDKIT_SMALL_TYPE:
		setmodel(target, "maps/b_bh10.bsp");
		target.noise = "items/r_item1.wav";
		target.healtype = MOON_MEDKIT_SMALL_TYPE;
		target.max_health = MOON_MEDKIT_SMALL_VALUE;
		target.cost = MOON_MEDKIT_SMALL_COST;
		target.targetname = MOON_MEDKIT_SMALL_DISPLAYNAME;
		break;
	case MOON_MEDKIT_NORMAL_TYPE:
		setmodel(target, "maps/b_bh25.bsp");
		target.noise = "items/health1.wav";
		target.healtype = MOON_MEDKIT_NORMAL_TYPE;
		target.max_health = MOON_MEDKIT_NORMAL_VALUE;
		target.cost = MOON_MEDKIT_NORMAL_COST;
		target.targetname = MOON_MEDKIT_NORMAL_DISPLAYNAME;
		break;
	case MOON_MEDKIT_MEGA_TYPE:
		setmodel(target, "maps/b_bh100.bsp");
		target.noise = "items/r_item2.wav";
		target.healtype = MOON_MEDKIT_MEGA_TYPE;
		target.max_health = MOON_MEDKIT_MEGA_VALUE;
		target.cost = MOON_MEDKIT_MEGA_COST;
		target.targetname = MOON_MEDKIT_MEGA_DISPLAYNAME;
		break;
	default:
		target.max_health = 1; // Division by zero guard
		dprint("Unknown medkit code {}\n", medkit_code);
	}

	// Adjust cost for spoiled medkits
	target.healamount = ( (target.health > 0) ? target.health : target.max_health);
	target.cost = (target.cost * (target.healamount / target.max_health));
};

void(entity who) find_trade_spot =
{
	local entity head;
	local float r;

	while ( (head = find(head, classname, MOON_TRADE_SPOT_CLASSNAME)) )
	{
		if ( head.netname != self.netname ) { continue; }
		if ( head.free == FALSE ) { continue; }
		if ( head.attack_finished >= time ) { continue; }

		r = random();
		switch(self.netname)
		{
		case MOON_TRADE_SHOP_ARMOR_NETNAME:
			if ( r < 0.35 )
			{
				moon_init_target_as_armor(head, MOON_ARMOR_GREEN_CODE);
			} else
			if ( r < 0.75 )
			{
				moon_init_target_as_armor(head, MOON_ARMOR_YELLOW_CODE);
			} else {
				moon_init_target_as_armor(head, MOON_ARMOR_RED_CODE);
			}
			break;
		case MOON_TRADE_SHOP_HEALTH_NETNAME:
			if ( r < 0.6 )
			{
				moon_init_target_as_medkit(head, MOON_MEDKIT_SMALL_TYPE);
			} else
			if ( r < 0.9 )
			{
				moon_init_target_as_medkit(head, MOON_MEDKIT_NORMAL_TYPE);
			} else {
				moon_init_target_as_medkit(head, MOON_MEDKIT_MEGA_TYPE);
			}
			break;
		case MOON_TRADE_SHOP_AMMO_NETNAME:
			head.cnt = MOON_ITEM_TRADE_SIGNOF_AMMO;
			if ( r < 0.2 )
			{
				setmodel(head, "maps/b_shell0.bsp");
				head.ammo_shells = ceil(MOON_AMMO_SHELLS_BASE + (random() * MOON_AMMO_SHELLS_RANDOM));
				head.cost = ceil(head.ammo_shells * MOON_AMMO_SHELLS_COSTOFONE);
				head.targetname = MOON_AMMO_SHELLS_DISPLAYNAME;
			} else
			if ( r < 0.4 )
			{
				setmodel(head, "maps/b_nail0.bsp");
				head.ammo_nails = ceil(MOON_AMMO_NAILS_BASE + (random() * MOON_AMMO_NAILS_RANDOM));
				head.cost = ceil(head.ammo_nails * MOON_AMMO_NAILS_COSTOFONE);
				head.targetname = MOON_AMMO_NAILS_DISPLAYNAME;
			} else
			if ((r < 0.7))
			{
				setmodel(head, "maps/b_rock0.bsp");
				head.ammo_rockets = ceil(MOON_AMMO_ROCKETS_BASE + (random() * MOON_AMMO_ROCKETS_RANDOM));
				head.cost = ceil(head.ammo_rockets * MOON_AMMO_ROCKETS_COSTOFONE);
				head.targetname = MOON_AMMO_ROCKETS_DISPLAYNAME;
			} else {
				setmodel(head, "maps/b_batt0.bsp");
				head.ammo_cells = ceil(MOON_AMMO_CELLS_BASE + (random() * MOON_AMMO_CELLS_RANDOM));
				head.cost = ceil(head.ammo_cells * MOON_AMMO_CELLS_COSTOFONE);
				head.targetname = MOON_AMMO_CELLS_DISPLAYNAME;
			}
			break;
		case MOON_TRADE_SHOP_WEAPON_NETNAME:
			head.cnt = MOON_ITEM_TRADE_SIGNOF_WEAPON;
			if ( r < 0.15 )
			{
				setmodel(head, "progs/g_shot.mdl");
				head.ammo_shells = MOON_WEAPON_SUPERSHOTGUN_AMMO_SHOP;
				head.cost = MOON_WEAPON_SUPERSHOTGUN_COST_SHOP;
				head.targetname = MOON_WEAPON_SUPERSHOTGUN_DISPLAYNAME;
				head.items = IT_SUPER_SHOTGUN;
			} else
			if ( r < 0.3 )
			{
				setmodel(head, "progs/g_nail.mdl");
				head.ammo_nails = MOON_WEAPON_NAILGUN_AMMO_SHOP;
				head.cost = MOON_WEAPON_NAILGUN_COST_SHOP;
				head.targetname = MOON_WEAPON_NAILGUN_DISPLAYNAME;
				head.items = IT_NAILGUN;
			} else
			if ( r < 0.45 )
			{
				setmodel(head, "progs/g_nail2.mdl");
				head.ammo_nails = MOON_WEAPON_SUPERNAILGUN_AMMO_SHOP;
				head.cost = MOON_WEAPON_SUPERNAILGUN_COST_SHOP;
				head.targetname = MOON_WEAPON_SUPERNAILGUN_DISPLAYNAME;
				head.items = IT_SUPER_NAILGUN;
			} else
			if ( r < 0.6 )
			{
				setmodel(head, "progs/g_rock.mdl");
				head.ammo_rockets = MOON_WEAPON_GRENADELAUNCHER_AMMO_SHOP;
				head.cost = MOON_WEAPON_GRENADELAUNCHER_COST_SHOP;
				head.targetname = MOON_WEAPON_GRENADELAUNCHER_DISPLAYNAME;
				head.items = IT_GRENADE_LAUNCHER;
			} else
			if ( r < 0.8 )
			{
				setmodel(head, "progs/g_rock2.mdl");
				head.ammo_rockets = MOON_WEAPON_ROCKETLAUNCHER_AMMO_SHOP;
				head.cost = MOON_WEAPON_ROCKETLAUNCHER_COST_SHOP;
				head.targetname = MOON_WEAPON_ROCKETLAUNCHER_DISPLAYNAME;
				head.items = IT_ROCKET_LAUNCHER;
			} else {
				setmodel(head, "progs/g_light.mdl");
				head.ammo_cells = MOON_WEAPON_LIGHTNING_AMMO_SHOP;
				head.cost = MOON_WEAPON_LIGHTNING_COST_SHOP;
				head.targetname = MOON_WEAPON_LIGHTNING_DISPLAYNAME;
				head.items = IT_LIGHTNING;
			}
			break;
		}
		head.free = FALSE;
		sound(head, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);
	}
};

void() trader_think =
{
	if ((self.walkframe >= 5))
	{
		self.walkframe = 0;
	}
	self.frame = (6 + self.walkframe);
	self.walkframe = (self.walkframe + 1);
	if ((self.radsuit_finished < time))
	{
		find_trade_spot(self);
		self.radsuit_finished = (time + 5);
	}
	self.think = trader_think;
	self.nextthink = (time + 0.07);
};

void() monster_trader = // trader ctor(), but which?
{
	if (!self.netname)
	{
		objerror("monster_trader: no `netname` defined");
	}
	setmodel(self, "progs/player_s.mdl");

	self.solid = SOLID_SLIDEBOX;
	self.takedamage = DAMAGE_NO;
	self.frame = 14;
	self.colormap = 0;
	self.health = 100;
	self.think = trader_think;
	self.nextthink = (time + 1);
};

void() trade_spot = // trade stand spot ctor(). This spot will be populated with item for sale
{
	if (!self.netname)
	{
		objerror("trader_spot: no `netname` defined");
	}
	self.free = TRUE;
	self.classname = "trade_spot";
	self.solid = SOLID_NOT;
	self.attack_finished = ((time + 1) + (random() * 15));
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
};

void() moon_buy_item =
{
	local entity head;
	local entity selected;
	local float min_dist;
	local entity mega;
	local float best;

	min_dist = 150;
	head = find(world, classname, "trade_spot"); // First, try to find trade stands (aka shop)
	while (head)
	{
		if ((head.free == FALSE))
		{
			if ((vlen((head.origin - self.origin)) < min_dist))
			{
				min_dist = vlen((head.origin - self.origin));
				selected = head;
			}
		}
		head = find(head, classname, "trade_spot");
	}
	if ( selected == world )	// If no trade stands found, check black market
	{
		moon_buy_item_market();
		return;
	}

	if ( self.gold < selected.cost )
	{
		sprint(self, "not enough gold\n");
		return;
	}

	if ( selected.armortype > 0 )	// Sign of Armor
	{
		if (((self.armortype * self.armorvalue) >= (selected.armortype * selected.armorvalue)))
		{
			sprint(self, "you don't need it\n");
			return;
		}
		self.armortype = selected.armortype;
		self.armorvalue = selected.armorvalue;
		self.items = (((self.items & (~IT_ARMOR1)) & (~IT_ARMOR2)) & (~IT_ARMOR3)) | selected.items;
		sound(self, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
		selected.attack_finished = ((time + GRD_PATROLTIME) + (random() * GRD_PATROLTIME));
	} else
	if ( selected.items & IT_SUPERHEALTH ) // Sign of Medkit
	{
		if ( selected.healtype == MOON_MEDKIT_MEGA_TYPE )
		{
			if ( self.health >= (self.max_health + MOON_MEDKIT_MEGA_OVERHEAL_SOFTLIMIT) )
			{
				return;
			}
			T_Overheal(self, selected.healamount);
			if (!(self.items & IT_SUPERHEALTH))
			{
				mega = spawn();
				mega.nextthink = (time + 5);
				mega.think = item_megahealth_rot;
				mega.owner = self;
				self.items = (self.items | IT_SUPERHEALTH);
			}
		} else {
			if ( self.health >= self.max_health )
			{
				return;
			}
			T_Heal(self, selected.healamount, 0);
		}
		sound(self, CHAN_ITEM, selected.noise, 1, ATTN_NORM);
		selected.attack_finished = ((time + 20) + (random() * 20));
	} else
	if ( selected.cnt == MOON_ITEM_TRADE_SIGNOF_AMMO ) // Sign of Ammo
	{
		best = W_BestWeapon();
		self.ammo_shells = (self.ammo_shells + selected.ammo_shells);
		self.ammo_nails = (self.ammo_nails + selected.ammo_nails);
		self.ammo_rockets = (self.ammo_rockets + selected.ammo_rockets);
		self.ammo_cells = (self.ammo_cells + selected.ammo_cells);
		moon_limit_target_ammo(self);

		sprint(self, "You bought {} {}\n", quick_ftos(selected.ammo_shells + selected.ammo_nails + selected.ammo_rockets + selected.ammo_cells), selected.targetname);
		sound(self, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);

		if ((self.weapon == best))
		{
			self.weapon = W_BestWeapon();
		}
		W_SetCurrentAmmo();
		selected.attack_finished = ((time + 20) + (random() * 20));
		selected.ammo_cells = 0;
		selected.ammo_rockets = 0;
		selected.ammo_nails = 0;
		selected.ammo_shells = 0;
	} else
	if ( selected.cnt == MOON_ITEM_TRADE_SIGNOF_WEAPON ) // Sign of Weapon
	{
		best = W_BestWeapon();
		self.ammo_shells = (self.ammo_shells + selected.ammo_shells);
		self.ammo_nails = (self.ammo_nails + selected.ammo_nails);
		self.ammo_rockets = (self.ammo_rockets + selected.ammo_rockets);
		self.ammo_cells = (self.ammo_cells + selected.ammo_cells);
		moon_limit_target_ammo(self);
		self.items = (self.items | selected.items);

		sprint(self, "You bought {}\n", selected.targetname);
		sound(self, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);

		if ((self.weapon == best))
		{
			self.weapon = W_BestWeapon();
		}
		W_SetCurrentAmmo();
		selected.attack_finished = ((time + 20) + (random() * 20));
		selected.ammo_cells = 0;
		selected.ammo_rockets = 0;
		selected.ammo_nails = 0;
		selected.ammo_shells = 0;
	}

	self.gold = (self.gold - selected.cost);
	setmodel(selected, string_null);
	selected.free = TRUE;
	flash_self();
	sprint(self, "{} gold left\n", floor_ftos(self.gold));
};

void() moon_identify_item =
{
	local entity head;
	local entity selected;
	local float min_dist;

	min_dist = 150;
	head = find(world, classname, "trade_spot");
	while (head)
	{
		if ((head.free == FALSE))
		{
			if ((vlen((head.origin - self.origin)) < min_dist))
			{
				min_dist = vlen((head.origin - self.origin));
				selected = head;
			}
		}
		head = find(head, classname, "trade_spot");
	}
	if ( selected == world )
	{
		moon_identify_item_market();
		return;
	}

	sprint(self, "====== identified item ======\n");
	if ((selected.items & IT_ARMOR1))
	{
		sprint(self, "Green Armor");
	}
	if ((selected.items & IT_ARMOR2))
	{
		sprint(self, "Yellow Armor");
	}
	if ((selected.items & IT_ARMOR3))
	{
		sprint(self, "Red Armor");
	}
	if ( selected.cnt == MOON_ITEM_TRADE_SIGNOF_AMMO )
	{
		if (selected.ammo_shells)
		{
			sprint(self, "Box of {} shells", floor_ftos(selected.ammo_shells));
		}
		if (selected.ammo_nails)
		{
			sprint(self, "Box of {} nails", floor_ftos(selected.ammo_nails));
		}
		if (selected.ammo_rockets)
		{
			sprint(self, "Box of {} rockets", floor_ftos(selected.ammo_rockets));
		}
		if (selected.ammo_cells)
		{
			sprint(self, "Box of {} cells", floor_ftos(selected.ammo_cells));
		}
	} else
	if (selected.cnt == MOON_ITEM_TRADE_SIGNOF_WEAPON )
	{
		sprint(self, selected.targetname);
	}

	if ( selected.items & IT_SUPERHEALTH )
	{
		sprint(self, "{} +{}", selected.targetname, floor_ftos(selected.healamount));
	}
	sprint(self, ". Cost: {}\n", floor_ftos(selected.cost));
};

void() moon_print_skills =
{
	local float bonus;

	sprint(self, "======= stats =======\n");
	sprint(self, "|free points: {}", quick_ftos(self.point));
	if (self.point < 10)
	{
		sprint(self, " ");
	}
	sprint(self, "    |\n");

	bonus = moon_get_target_bonus_health(self);
	sprint(self, "| vitality: {} ({}", quick_ftos(self.vit), quick_ftos(self.max_health));

	if ((bonus > 0))
	{
		sprint(self, " (+{})", quick_ftos(bonus));
	}
	sprint(self, " max hp) |");
	if (self.point > 0)
	{
		sprint(self, " Use `skill\1` to raise");
	}
	sprint(self, "\n");

	bonus = moon_get_target_bonus_damage(self);
	if ((self.mentat_bonus == MOON_ITEM_SOME))
	{
		bonus = (bonus + MOON_MENTAT_OFFENSE_VALUE);
	}

	sprint(self, "| strength: {} ({}%", quick_ftos(self.stre), quick_ftos((self.stre * MOON_STAT_DAMAGE_PER_STRENGTH) + 100));
	if (bonus > 0)
	{
		sprint(self, " (+{}%)", quick_ftos(bonus));
	}
	sprint(self, " dmg) |");
	if (self.point > 0)
	{
		sprint(self, " Use `skill\2` to raise");
	}
	sprint(self, "\n");

	// TODO: Sanity stat
	// TODO: Intuition stat
	sprint(self, "---------------------\n");
};

void(entity e, float nm) des_scroll = // TODO: clear this mess one day
{
	local float tmp;

	sprint(e, "scroll of "); // óãòïìì ïæ ");
	if ((nm == H_ROTTEN))
	{
		sprint(e, "healing <-lvl:"); // èåáìéîç lvl:");
		sprint_ftos(e, e.sc_heal_lvl);
		sprint(e, " mana:");
		sprint_ftos(e, (LOGIC_FINDDEFEND + (e.sc_heal_lvl * H_MEGA)));
		sprint(e, " eff:");
		sprint_ftos(e, (15 + (e.sc_heal_lvl * TE_LAVASPLASH)));
		sprint(e, "->");
		sprint(e, "\n");
	}
	else
	{
		if ((nm == H_MEGA))
		{
			sprint(e, "reduction <-lvl:"); // òåäõãôéïî lvl:");
			sprint_ftos(e, e.sc_redu_lvl);
			sprint(e, " mana:"); // žmana:");
			sprint_ftos(e, (LOGIC_PATROL + (e.sc_redu_lvl * LOGIC_FINDDEFEND)));
			sprint(e, " eff:"); // žeff:");
			tmp = (25 + (e.sc_redu_lvl * LOGIC_FINDDEFEND));
			if ((tmp > 60))
			{
				tmp = 60;
			}
			sprint_ftos(e, tmp);
			sprint(e, "% time:"); // žtime:");
			sprint_ftos(e, (LOGIC_DEFEND + (e.sc_redu_lvl * H_MEGA)));
			sprint(e, "sec-targets:"); // žtargets:");
			tmp = (H_ROTTEN + rint((e.sc_redu_lvl / H_MEGA)));
			sprint_ftos(e, tmp);
			sprint(e, " range:"); // žrange:");
			tmp = ((350 + (e.sc_redu_lvl * 50)) / 100);
			sprint_ftos(e, tmp);
			sprint(e, "m->"); // Ÿ");
			sprint(e, "\n");
		}
		else
		{
			if ((nm == LOGIC_FINDDEFEND))
			{
				sprint(e, "slow <-lvl:"); // óìï÷ lvl:");
				sprint_ftos(e, e.sc_slow_lvl);
				sprint(e, " mana:");
				sprint_ftos(e, (KEY_MOVERIGHT + (e.sc_slow_lvl * H_MEGA)));
				sprint(e, " time:");
				tmp = (LOGIC_DEFEND + rint((e.sc_slow_lvl * CL_DEADTIME)));
				sprint_ftos(e, tmp);
				sprint(e, "sec-targets:");
				tmp = (H_ROTTEN + rint((e.sc_slow_lvl / LOGIC_FINDDEFEND)));
				sprint_ftos(e, tmp);
				sprint(e, " range:");
				tmp = ((350 + (e.sc_slow_lvl * 50)) / 100);
				sprint_ftos(e, tmp);
				sprint(e, "m->");
				sprint(e, "\n");
			}
		}
	}
	if ((nm == LOGIC_DEFEND))
	{
		sprint(e, "brutality <-lvl:"); // âòõôáìéôù lvl:");
		sprint_ftos(e, e.sc_brut_lvl);
		sprint(e, " mana:");
		sprint_ftos(e, (LOGIC_PATROL + (e.sc_brut_lvl * LOGIC_FINDDEFEND)));
		sprint(e, " eff:");
		sprint_ftos(e, (50 + (e.sc_brut_lvl * KEY_MOVERIGHT)));
		sprint(e, "% time:");
		sprint_ftos(e, (LOGIC_HUNTENEMY + (e.sc_brut_lvl * H_MEGA)));
		sprint(e, "sec->");
		sprint(e, "\n");
	}
};

void() Scroll_list =
{
	sprint(self, "===== scrolls =====\n");
	if ((self.sc_n1 > 0))
	{
		des_scroll(self, self.sc_n1);
	}
	if ((self.sc_n2 > 0))
	{
		des_scroll(self, self.sc_n2);
	}
	if ((self.sc_n3 > 0))
	{
		des_scroll(self, self.sc_n3);
	}
	if ((self.sc_n4 > 0))
	{
		des_scroll(self, self.sc_n4);
	}
	if ((self.sc_n5 > 0))
	{
		des_scroll(self, self.sc_n5);
	}
	sprint(self, "===================\n");
};

void() Cast_Slow = // TODO: clear this mess one day. Slow is Slow
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
	rm = (KEY_MOVERIGHT + (self.sc_redu_lvl * H_MEGA));
	tar = (H_ROTTEN + rint((self.sc_redu_lvl / LOGIC_FINDDEFEND)));
	rng = (350 + (self.sc_redu_lvl * 50));
	dur = (LOGIC_DEFEND + rint((self.sc_redu_lvl * CL_DEADTIME)));
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
			if (((head.health > WF_NORMAL) && (head != self)))
			{
				if (CanDamage(head, self))
				{
					if ((head.scroll_slow_eff < time))
					{
						if ((castcount < tar))
						{
							head.scroll_slow_eff = (time + dur);
							head.speed = rint((head.speed / H_MEGA));
							casted = TRUE;
							castcount = (castcount + H_ROTTEN);
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
		if ((self.mana < WF_NORMAL))
		{
			self.mana = WF_NORMAL;
		}
		//sound(self, CHAN_VOICE, "moon/magic/m_slow.wav", H_ROTTEN, ATTN_NORM); // missing file
		self.scroll_time = (time + MON_BACKTIME);
	}
	else
	{
		sprint(self, "no monsters in range\n");
	}
};

void() Cast_Redu = // TODO: clear this mess one day. WTF is redu?
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
	rm = (LOGIC_PATROL + (self.sc_redu_lvl * LOGIC_FINDDEFEND));
	eff = (25 + (self.sc_redu_lvl * LOGIC_FINDDEFEND));
	if ((eff > 60))
	{
		eff = 60;
	}
	tar = (H_ROTTEN + rint((self.sc_redu_lvl / H_MEGA)));
	rng = (350 + (self.sc_redu_lvl * 50));
	dur = (LOGIC_DEFEND + (self.sc_redu_lvl * H_MEGA));
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
			if (((head.health > WF_NORMAL) && (head != self)))
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
							castcount = (castcount + H_ROTTEN);
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
		if ((self.mana < WF_NORMAL))
		{
			self.mana = WF_NORMAL;
		}
		sound(self, CHAN_VOICE, "moon/misc/cast.wav", H_ROTTEN, ATTN_NORM);
		self.scroll_time = (time + MON_BACKTIME);
	}
	else
	{
		sprint(self, "no monsters in range\n");
	}
};

void() Cast_Heal = // TODO: clear this mess one day. Heal is Heal
{
	local float rm;
	local float eff;

	rm = (LOGIC_FINDDEFEND + (self.sc_heal_lvl * H_MEGA));
	eff = (15 + (self.sc_heal_lvl * TE_LAVASPLASH));
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
	//sound(self, CHAN_VOICE, "moon/magic/m_heal.wav", H_ROTTEN, ATTN_NORM); // missing file
	T_Heal(self, eff, 0);
	self.mana = (self.mana - rm);
	if ((self.mana < 0))
	{
		self.mana = 0;
	}
	self.scroll_heal_eff = (time + MON_BACKTIME);
	self.scroll_time = (time + MON_BACKTIME);
};

void() Cast_Brut = // TODO: clear this mess one day. Brutal? Damage amp
{
	local float rm;
	local float eff;
	local float dur;

	rm = (LOGIC_PATROL + (self.sc_brut_lvl * LOGIC_FINDDEFEND));
	eff = (50 + (self.sc_brut_lvl * KEY_MOVERIGHT));
	dur = (LOGIC_HUNTENEMY + (self.sc_brut_lvl * H_MEGA));
	if ((self.mana < rm))
	{
		sprint(self, "this spell requies {} mana, you have only {}\n", rm, mana);
		return;
	}
	if ((self.scroll_time > time))
	{
		return;
	}
	sound(self, CHAN_VOICE, "moon/misc/cast.wav", H_ROTTEN, ATTN_NORM);
	self.mana = (self.mana - rm);
	if ((self.mana < WF_NORMAL))
	{
		self.mana = WF_NORMAL;
	}
	self.scroll_time = (time + MON_BACKTIME);
	self.scroll_brut_eff = (time + dur); // suspicious as fuck
};

void() Cast_Shie = // TODO: clear this mess one day. Shield, not Shiet
{
	if ((self.scroll_time > time))
	{
		return;
	}
	if ((self.mana < LOGIC_FINDDEFEND))
	{
		sprint(self, "this spell requies 3 mana\n");
		return;
	}
	self.mana = (self.mana - LOGIC_FINDDEFEND);
	sound(self, CHAN_VOICE, "moon/misc/cast.wav", H_ROTTEN, ATTN_NORM);
	self.scroll_shie_eff = (time + TE_LAVASPLASH);
	self.scroll_time = (time + 0.3);
};

void() infe_eff = // Inferno effect ctor()
{
	local entity e;

	e = spawn();
	e.origin = self.origin;
	setmodel(e, "progs/s_explod.spr");
	e.think = s_explode1;
	e.nextthink = time;
	sound(e, CHAN_WEAPON, "weapons/r_exp3.wav", H_ROTTEN, ATTN_NORM);
	self.scroll_infe_eff = WF_NORMAL;
};

void() Cast_Infe = // TODO: clear this mess one day. Inferno
{
	local entity head;
	local float casted;
	local float castcount;

	if ((self.scroll_time > time))
	{
		return;
	}
	if ((self.mana < LOGIC_FINDDEFEND))
	{
		sprint(self, "this spell requies 3 mana\n");
		return;
	}
	castcount = WF_NORMAL;
	head = findradius(self.origin, 600);
	while (head)
	{
		if ((head.flags & FL_MONSTER))
		{
			if ((head.health > WF_NORMAL))
			{
				if (CanDamage(head, self))
				{
					if ((head.scroll_infe_eff < time))
					{
						if ((castcount < LOGIC_HUNTENEMY))
						{
							head.scroll_infe_eff = (time + 0.3);
							T_RadiusDamage(head, self, 80, world);
							casted = TRUE;
							castcount = (castcount + H_ROTTEN);
						}
					}
				}
			}
		}
		head = head.chain;
	}
	if ((casted == TRUE))
	{
		sound(self, CHAN_WEAPON, "weapons/r_exp3.wav", H_ROTTEN, ATTN_NORM);
		self.mana = (self.mana - LOGIC_FINDDEFEND);
		self.scroll_time = (time + MON_BACKTIME);
		return;
	}
	else
	{
		sprint(self, "no monsters in range\n");
	}
};

void() shaf_eff = // Shaft effect ctor()
{
	makevectors(self.angles);
	self.scroll_shaf_eff = WF_NORMAL;
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
	sound(self, CHAN_BODY, "weapons/lhit.wav", H_ROTTEN, ATTN_NORM);
};

void() Cast_Shaf = // TODO: clear this mess one day. Shaf is Shaft, probably thunderstrikes from skies
{
	local entity head;
	local float casted;
	local float castcount;

	if ((self.scroll_time > time))
	{
		return;
	}
	if ((self.mana < LOGIC_FINDDEFEND))
	{
		sprint(self, "this spell requies 3 mana\n");
		return;
	}
	castcount = WF_NORMAL;
	head = findradius(self.origin, 1600);
	while (head)
	{
		if ((head.flags & FL_MONSTER))
		{
			if ((head.health > WF_NORMAL))
			{
				if (CanDamage(head, self))
				{
					if ((head.scroll_infe_eff < time))
					{
						if ((castcount <= LOGIC_DEFEND))
						{
							head.scroll_shaf_eff = (time + 0.3);
							head.attack_e = self;
							T_Damage(head, self, world, 120);
							casted = TRUE;
							castcount = (castcount + H_ROTTEN);
						}
					}
				}
			}
		}
		head = head.chain;
	}
	if ((casted == TRUE))
	{
		//sound(self, CHAN_WEAPON, "moon/magic/m_thun.wav", H_ROTTEN, ATTN_NORM); // missing file
		self.scroll_time = (time + MON_BACKTIME);
		return;
	}
	else
	{
		sprint(self, "no monsters in range\n");
	}
};

void() mete_eff_th = // TODO: clear this mess one day. Meteor effect think.
{
	self.origin = (self.enemy.origin + (v_up * self.owner.mins_z));
	self.velocity = self.enemy.velocity;
	if ((self.enemy.health <= WF_NORMAL))
	{
		remove(self);
	}
	if ((self.cnt == H_ROTTEN))
	{
		self.frame = (self.frame + self.walkframe);
		self.walkframe = (self.walkframe + H_ROTTEN);
		if ((self.frame > 72))
		{
			self.cnt = H_MEGA;
		}
	}
	if ((self.cnt == H_MEGA))
	{
		self.frame = self.walkframe;
		self.walkframe = (self.walkframe + H_ROTTEN);
		if ((self.frame >= SVC_TEMPENTITY))
		{
			self.walkframe = WF_NORMAL;
		}
		if ((self.attack_finished < time))
		{
			T_Damage(self.enemy, self.owner, self, TE_WIZSPIKE);
			self.attack_finished = (time + 0.3);
		}
	}
	self.think = mete_eff_th;
	self.nextthink = (time + MON_REFRESHTIME);
};

void(entity who) mete_eff = // Meteor effect ctor()
{
	local entity e;

	e = spawn();
	setmodel(e, "progs/meteors.mdl");
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NOCLIP;
	e.origin = who.origin;
	e.frame = 47;
	e.cnt = H_ROTTEN;
	e.enemy = who;
	e.owner = self;
	e.think = mete_eff_th;
	e.nextthink = (time + 0.05);
};

void() Cast_Mete = // TODO: clear this mess one day. Mete is Meteor
{
	local entity head;

	if ((self.scroll_time > time))
	{
		return;
	}
	if ((self.mana < LOGIC_FINDDEFEND))
	{
		sprint(self, "this spell requies 3 mana\n");
		return;
	}
	head = findradius(self.origin, 800);
	while (head)
	{
		if ((head.flags & FL_MONSTER))
		{
			if ((head.health > WF_NORMAL))
			{
				if (CanDamage(head, self))
				{
					if ((head.scroll_mete_eff < time))
					{
						head.scroll_mete_eff = (time + KEY_MOVERIGHT);
						sound(self, CHAN_VOICE, "moon/misc/cast.wav", H_ROTTEN, ATTN_NORM);
						mete_eff(head);
						return;
					}
				}
			}
		}
		head = head.chain;
	}
};

void(float nm) CastN = // TODO: clear this mess one day. Missing Mete, Shaf, Shie? Here input is Spell (scroll) code
{
	if ((nm == H_ROTTEN))
	{
		Cast_Heal();
	}
	if ((nm == H_MEGA))
	{
		Cast_Redu();
	}
	if ((nm == LOGIC_FINDDEFEND))
	{
		Cast_Slow();
	}
	if ((nm == LOGIC_DEFEND))
	{
		Cast_Brut();
	}
	if ((nm == LOGIC_PATROL))
	{
		Cast_Infe();
	}
};

void(float nm) Cast = // TODO: clear this mess one day. Here input is Spell (scroll) slot
{
	if ((nm == H_ROTTEN))
	{
		if ((self.sc_n1 <= WF_NORMAL))
		{
			sprint(self, "no 1st scroll to cast\n");
			return;
		}
		CastN(self.sc_n1);
	}
	if ((nm == H_MEGA))
	{
		if ((self.sc_n2 <= WF_NORMAL))
		{
			sprint(self, "no 2nd scroll to cast\n");
			return;
		}
		CastN(self.sc_n2);
	}
	if ((nm == LOGIC_FINDDEFEND))
	{
		if ((self.sc_n3 <= WF_NORMAL))
		{
			sprint(self, "no 3rd scroll to cast\n");
			return;
		}
		CastN(self.sc_n3);
	}
	if ((nm == LOGIC_DEFEND))
	{
		if ((self.sc_n4 <= WF_NORMAL))
		{
			sprint(self, "no 4th scroll to cast\n");
			return;
		}
		CastN(self.sc_n4);
	}
	if ((nm == LOGIC_PATROL))
	{
		if ((self.sc_n5 <= WF_NORMAL))
		{
			sprint(self, "no 5th scroll to cast\n");
			return;
		}
		CastN(self.sc_n5);
	}
};

string(float level) moon_get_monster_level_prefix =
{
	if ( level < 0 )
	{
		dprint("ERROR IN moon_get_monster_level_prefix(...): provided level is negative.\n");
		return string_null;
	}
	switch(level)
	{
		case 0: return "novice ";
		case 1: return "ordinary ";
		case 2: return "promoted ";
		case 3: return "advanced ";
		case 4: return "experienced ";
		case 5: return "grim ";
		case 6: return "massive ";
		case 7: return "skillful ";
		case 8: return "incredible ";
		case 9: return "merciless ";
		case 10: return "drilled ";
		case 11: return "war ";
		case 12: return "enourmous ";
		case 13: return "powerful ";
		case 14: return "grand ";
		case 15: return "chaos ";
		case 16: return "demonical ";
		case 17: return "superior ";
		case 18: return "hurricane ";
		case 19: return "defacing ";
		case 20: return "phantom ";
		case 21: return "lord ";
		case 22: return "baron ";
		case 23: return "overlord ";
		case 24: return "warlord ";
		case 25: return "king ";
		case 26: return "plague ";
		case 27: return "storm ";
		case 28: return "shadow ";
		case 29: return "holocaust ";
		case 30: return "order ";
		case 31: return "dire ";
		case 32: return "gale ";
		case 33: return "cruel ";
		case 34: return "doom ";
		case 35: return "serious ";
		case 36: return "celestial ";
		case 37: return "terrible ";
		case 38: return "diamond ";
		case 39: return "rush ";
		case 40: return "crashing ";
		case 41: return "fanged ";
		case 42: return "thirsty ";
		case 43: return "splitter ";
		case 44: return "sunder ";
		case 45: return "rend ";
		case 46: return "reaver ";
		case 47: return "gnash ";
		case 48: return "blow ";
		case 49: return "smasher ";
		case 50: return "satan's ";
		default: return "satan's ";
	}
};

void(entity who, float l) GetMonsterPrefixLevel =
{
	who.prefix_two = moon_get_monster_level_prefix(l);
};

float(float level) moon_get_monster_wave_size_for_level =
{
	if ( level <= 1 )
	{
		return random_int(2, 5);
	}
	if ( level == 2 )
	{
		return random_int(2, 6);
	}
	if ( level == 3 )
	{
		return random_int(2, 6);
	}
	if ( level < 9 )
	{
		return random_int(3, 7);
	}
	if ( level < 18 )
	{
		return random_int(3, 8);
	}
	if ( level < 48 )
	{
		return random_int(4, 9);
	}
	//if ( level >= 48 )
	return random_int(5, 11);
};

float(float level, float player_count) moon_get_monster_wave_size =
{
	local float wave;

	wave = moon_get_monster_wave_size_for_level(level);
	if ( player_count > 1 )
	{
		wave = wave + moon_get_monster_wave_size_for_level(level - 1);
	}
	if ( player_count > 2 )
	{
		wave = wave + moon_get_monster_wave_size_for_level(level - 2);
	}
	if ( player_count > 3 )
	{
		wave = wave + moon_get_monster_wave_size_for_level(level - 3);
	}
	return wave;
};

float(float lvl) MonsterGenType =
{
	if ( lvl < MOON_MONSTER_BASELEVEL_ENFORCER )
	{
		return MOON_MONSTER_CODE_SOLDIER;
	}
	if ( lvl < MOON_MONSTER_BASELEVEL_SPIDER )
	{
		return random_int(MOON_MONSTER_CODE_SOLDIER, MOON_MONSTER_CODE_ENFORCER);
	}
	if ( lvl < MOON_MONSTER_BASELEVEL_OGRE )
	{
		return random_int(MOON_MONSTER_CODE_SOLDIER, MOON_MONSTER_CODE_SPIDER);
	}
	if ( lvl < MOON_MONSTER_BASELEVEL_SNAKE )
	{
		return random_int(MOON_MONSTER_CODE_SOLDIER, MOON_MONSTER_CODE_OGRE);
	}
	if ( lvl < MOON_MONSTER_BASELEVEL_MAGE )
	{
		return random_int(MOON_MONSTER_CODE_SOLDIER, MOON_MONSTER_CODE_SNAKE);
	}
	if ( lvl < MOON_MONSTER_BASELEVEL_SHALRATH )
	{
		return random_int(MOON_MONSTER_CODE_SOLDIER, MOON_MONSTER_CODE_MAGE);
	}
	//if ( lvl >= MOON_MONSTER_BASELEVEL_SHALRATH )
	return random_int(MOON_MONSTER_CODE_SOLDIER, MOON_MONSTER_CODE_SHALRATH);
};

void(entity spawner, float l) MonsterTable = // rename later to moon_spawn_monster
{
	local float gen;
	local float shift;
	local float shifted_lvl;

	shift = rint(random() * 3);
	shifted_lvl = l - shift;

	spawner.count = (spawner.count - 1);
	gen = MonsterGenType(l);
	switch(gen)	// TODO: split/refactor spawn_X functions to handle only specific to X stuff there
	{
	case MOON_MONSTER_CODE_SOLDIER:
		spawn_soldier(spawner, clampd(0, shifted_lvl - MOON_MONSTER_BASELEVEL_SOLDIER, 50) );
		break;
	case MOON_MONSTER_CODE_ENFORCER:
		spawn_enforcer(spawner, clampd(0, shifted_lvl - MOON_MONSTER_BASELEVEL_ENFORCER, 50));
		break;
	case MOON_MONSTER_CODE_SPIDER:
		spawn_spider(spawner, clampd(0, shifted_lvl - MOON_MONSTER_BASELEVEL_SPIDER, 50));
		break;
	case MOON_MONSTER_CODE_OGRE:
		spawn_ogre(spawner, clampd(0, shifted_lvl - MOON_MONSTER_BASELEVEL_OGRE, 50));
		break;
	case MOON_MONSTER_CODE_SNAKE:
		spawn_snake(spawner, clampd(0, shifted_lvl - MOON_MONSTER_BASELEVEL_SNAKE, 50));
		break;
	case MOON_MONSTER_CODE_MAGE:
		spawn_mage(spawner, clampd(0, shifted_lvl - MOON_MONSTER_BASELEVEL_MAGE, 50));
		break;
	case MOON_MONSTER_CODE_SHALRATH:
		spawn_shalrath(spawner, clampd(0, shifted_lvl - MOON_MONSTER_BASELEVEL_SHALRATH, 50));
		break;
	default:
		dprint("ERROR IN MonsterTable(...): gen spawns null monster\n");
	}
};

float SVC_SETVIEWPORT    = 5;
float SVC_SETVIEWANGLES    = 10;
float CHSCAM_ON    = 1;
void() Keep_cam_chasing_owner;
void(float opt) Remove_chase_cam;
float chasecam_dist    = 118;
float chasecam_zofs    = 24;

void(entity cam_owner) Start_chase_cam = // Black magic Voodoo shit
{
	local entity chase_cam;

	chase_cam = spawn();
	chase_cam.owner = cam_owner;
	chase_cam.owner.speed = (chase_cam.owner.speed | CHSCAM_ON);
	chase_cam.solid = SOLID_NOT;
	chase_cam.movetype = MOVETYPE_FLY;
	chase_cam.angles = chase_cam.owner.angles;
	setmodel(chase_cam, "progs/eyes.mdl");
	setsize(chase_cam, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(chase_cam, chase_cam.owner.origin);
	chase_cam.classname = "chase_cam";
	chase_cam.nextthink = (time + MON_CAMPERCHANCE);
	chase_cam.think = Keep_cam_chasing_owner;
	msg_entity = chase_cam.owner;
	WriteByte(MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity(MSG_ONE, chase_cam);
	chase_cam.ammo_shells = (chasecam_dist / LOGIC_FINDDEFEND);
};

void() Reable_chase_cam = // Black magic Voodoo shit
{
	self.nextthink = (time + MON_CAMPERCHANCE);
	if ((self.owner.health <= WF_NORMAL))
	{
		remove(self);
		return;
	}
	if (self.owner.waterlevel)
	{
		return;
	}
	Start_chase_cam(self.owner);
	remove(self);
};

void(float opt) Remove_chase_cam = // Black magic Voodoo shit
{
	if ((self.owner.speed & CHSCAM_ON))
	{
		self.owner.speed = (self.owner.speed - CHSCAM_ON);
	}
	setmodel(self, s_wiz);
	self.velocity = VEC_ORIGIN;
	msg_entity = self.owner;
	WriteByte(MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity(MSG_ONE, self.owner);
	if (!opt)
	{
		self.nextthink = (time + MON_CAMPERCHANCE);
		self.think = Reable_chase_cam;
	}
	else
	{
		remove(self);
	}
};

void() Keep_cam_chasing_owner = // Black magic Voodoo shit
{
	local vector goal;
	local vector dir;
	local float dist;
	local float cap;
	local float f_f;
	//local string s; // unused

	self.nextthink = (time + MON_CAMPERCHANCE);
	if (!(self.owner.speed & CHSCAM_ON))
	{
		Remove_chase_cam(TRUE);
		return;
	}
	dir_y = self.owner.v_angle_y;
	makevectors(dir);
	f_f = vlen(((v_forward * 320) - self.owner.velocity));
	dir = v_forward;
	makevectors(self.owner.v_angle);
	goal = (self.owner.origin - (v_forward * self.ammo_shells));
	if ((self.owner.v_angle_x > KEY_MOVEFORWARD))
	{
		goal = (goal + (dir * (self.owner.v_angle_x - KEY_MOVEFORWARD)));
		cap = (chasecam_zofs - (self.owner.v_angle_x - KEY_MOVEFORWARD));
		goal_z = (goal_z + cap);
		if ((goal_z < (self.owner.origin_z + GRD_PATROLTIME)))
		{
			goal_z = (self.owner.origin_z + GRD_PATROLTIME);
		}
	}
	else
	{
		goal_z = (goal_z + chasecam_zofs);
	}
	traceline(self.owner.origin, goal, FALSE, self.owner);
	if (((trace_fraction < H_ROTTEN) || (self.owner.v_angle_x < -16)))
	{
		self.ammo_shells = (KEY_MOVERIGHT + vlen((trace_endpos - self.owner.origin)));
	}
	goal = (trace_endpos + (v_forward * H_MEGA));
	traceline(goal, (goal + '0 0 32'), FALSE, self.owner);
	if ((trace_fraction < H_ROTTEN))
	{
		dir = (trace_endpos - '0 0 32');
		traceline(goal, (goal - '0 0 32'), FALSE, self.owner);
		if ((trace_fraction == H_ROTTEN))
		{
			goal = dir;
		}
	}
	dir = normalize((goal - self.origin));
	dist = vlen((goal - self.origin));
	if (visible(self.owner))
	{
		self.angles = self.owner.angles;
		cap = (dist * MON_REACTIONTIME);
		if ((cap > 5.2))
		{
			self.velocity = ((dir * dist) * 5.2);
		}
		else
		{
			if ((cap > H_ROTTEN))
			{
				self.velocity = ((dir * dist) * cap);
			}
			else
			{
				self.velocity = (dir * dist);
			}
		}
		if ((f_f > 560))
		{
			self.velocity = (self.velocity * H_MEGA);
		}
	}
	else
	{
		setorigin(self, goal);
	}
	self.ammo_shells = (self.ammo_shells + 4.5);
	if ((self.ammo_shells > chasecam_dist))
	{
		self.ammo_shells = chasecam_dist;
	}
	if ((self.oldorigin == self.origin))
	{
		if ((dist > 30))
		{
			self.ammo_nails = (self.ammo_nails + H_ROTTEN);
		}
		if ((self.ammo_nails > H_MEGA))
		{
			Start_chase_cam(self.owner);
			remove(self);
			return;
		}
	}
	self.oldorigin = self.origin;
};

void() Toggle_chase_cam =
{
	if ((self.speed & CHSCAM_ON))
	{
		self.speed = (self.speed - CHSCAM_ON);
	} else {
		self.speed = CHSCAM_ON;
		self.weaponmodel = s_wiz;
		Start_chase_cam(self);
	}
};
entity lastmspawn;

entity() MonterSpawnPoint =
{
	local entity spot;
	local entity thing;
	local float pcount;

	spot = lastmspawn;
	while (1)
	{
		spot = find(spot, classname, "info_monster_start");
		if ((spot != world))
		{
			if ((spot == lastmspawn))
			{
				return (world);
			}
			pcount = 0;
			thing = findradius(spot.origin, 80);
			while (thing)
			{
				if ((thing.flags & FL_MONSTER))
				{
					if ((thing.health > 0))
					{
						pcount = (pcount + 1);
					}
				}
				thing = thing.chain;
			}
			if ((pcount == 0))
			{
				lastmspawn = spot;
				return (spot);
			}
		}
	}
	if (!spot)
	{
		error("MonsterSpawn: no `info_monster_start` on level");
	}
	return (spot);
};

void() StartSpawning =
{
	local float player_maxlevel;

	if (gameover) { return; }
	if ( self.count <= 0 )
	{
		remove(self);
		return;
	}

	player_maxlevel = moon_get_max_player_level();
	MonsterTable(self, player_maxlevel);

	self.nextthink = (time + MOON_TIME_BETWEEN_MONSTER_SPAWN);
	self.think = StartSpawning;
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

void() ToggleSpawn =
{
	local entity spot;

	spot = find(world, classname, "info_monster_start");
	if (spot)
	{
		bprint("spot found\n");
	}
};

void() ToggleMode =
{
	local entity head;

	head = findradius(self.origin, 4000);
	while (head)
	{
		if ((head.classname == "guard"))
		{
			if ((head.health > WF_NORMAL))
			{
				moon_make_chat_noise();
				if ((head.mode == H_ROTTEN))
				{
					if ((random() < MON_BACKTIME))
					{
						//sound(head, CHAN_VOICE, "moon/talk/stay1.wav", H_ROTTEN, ATTN_NORM); // missing file
					}
					else
					{
						//sound(head, CHAN_VOICE, "moon/talk/stay2.wav", H_ROTTEN, ATTN_NORM); // missing file
					}
					head.mode = H_MEGA;
					kex_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "I will stay here\n");
				}
				else
				{
					if ((head.mode == H_MEGA))
					{
						if ((random() < MON_BACKTIME))
						{
							//sound(head, CHAN_VOICE, "moon/talk/go1.wav", H_ROTTEN, ATTN_NORM); // missing file
						}
						else
						{
							//sound(head, CHAN_VOICE, "moon/talk/go2.wav", H_ROTTEN, ATTN_NORM); // missing file
						}
						head.mode = H_ROTTEN;
						kex_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "I'm coming\n");
					}
				}
			}
		}
		head = head.chain;
	}
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

	SpawnMoster(monster_count);
	self.nextthink = time + moon_get_spawn_delay();
	self.think = brain_think;
};

void() game_brain =
{
	local entity e;

	e = spawn();
	e.nextthink = (time + MOON_MONSTER_FISRTWAVETIME_DELAY) + (random() * MOON_MONSTER_FISRTWAVETIME_RANDOM);
	e.think = brain_think;
};

void() info_monster_start = // Empty ctor()
{
};

void() shoot_ent = // ctor()
{
	self.health = 1;
};

void() moon_print_character_status =
{
	local entity heart;
	heart = find(world, classname, MOON_HEART_CLASSNAME);

	sprint(self, "======= Status =======\n");
	sprint(self, "\sHeart\s's Life: ");
	moon_println_target_other_health(self, heart);
	sprint(self, "Monsters Killed: {}\n", floor_ftos(self.mosterskilled));
	moon_println_target_exp(self);
	sprint(self, "Gold: ");
	moon_println_target_gold(self);
	sprint(self, "----------------------\n");
};

void(entity target) moon_prepare_player_entity =
{
	target.lvl = 0;
	target.exp = 0;
	target.nextexp = MOON_EXP_FIRST_LEVEL;
	target.gold = MOON_PLAYER_GOLD_INIT;
	target.max_mana = MOON_PLAYER_MANA_INIT;
	target.mana = self.max_mana;
	target.point = 0;
	target.mosterskilled = 0;
	target.up_bullet = 0;
	target.up_nail = 0;

	target.prepared = TRUE;
};

void() Prepare =
{
	if ( mapname != "moon4" )
	{
		sprint(self, "game supports only map moon4.bsp\n");
		localcmd("disconnect\n");
		return;
	}
	sv_alwaysday = 0;
	sv_fastmeat = 0;
	sv_noshake = 0;
	up_alert = 0;

	moon_prepare_player_entity(self);

	if ( waypoints_ok == FALSE )
	{
		set_map();
	}

	sprint(self, "Project MOON. Original v0.21beta created by \s3d[Power]\s\n");
	sprint(self, "ReProject MOON. Remake v{} on \sKEX Engine\s by \sSanctus-Susanin\s\n", MOON_VERSION);
	sprint(self, "type pm_help command to learn about MOON console commands\n");
};

void() moon_print_cmd_help =
{
	sprint(self, "======= help on game commands =======\n");
	sprint(self, "general prefix: `pm_`, server-side settings: `pms_`, client-side: `pmc_`\n");
	sprint(self, "{}| use `pm_identify` command to get a description of item nearby.\n", quick_ftos(MOON_IMPULSE_CODE_ITEM_IDENTIFY));
	sprint(self, "{}| use `pm_buy` command to buy closest item in the shop.\n", quick_ftos(MOON_IMPULSE_CODE_ITEM_BUY));
	sprint(self, "{}| use `pm_use` command pick up closest magical item.\n", quick_ftos(MOON_IMPULSE_CODE_ITEM_PICKUP));
	sprint(self, " {}| {}| use `pm_skill\1`/`pm_skill\2` raise skills\n", quick_ftos(MOON_IMPULSE_CODE_UPSKILL_VITALITY), quick_ftos(MOON_IMPULSE_CODE_UPSKILL_STRENGTH));
	sprint(self, " {}| use `pm_character` command to view character screen.\n", quick_ftos(MOON_IMPULSE_CODE_PRINT_STATUS));
	sprint(self, " {}| use `pm_stats` command to view screen with your stats.\n", quick_ftos(MOON_IMPULSE_CODE_PRINT_STAT));
	sprint(self, " {}| use `pm_inventory` command to view inventory screen.\n", quick_ftos(MOON_IMPULSE_CODE_PRINT_INVENTORY));
	sprint(self, "{}|{}| use `pms_fastmeat`/`pms_slowmeat` to grind faster or slower\n", quick_ftos(MOON_IMPULSE_CODE_FASTMEAT), quick_ftos(MOON_IMPULSE_CODE_SLOWMEAT));
	sprint(self, "{}| use `pms_alwaysday` to shine bright\n", quick_ftos(MOON_IMPULSE_CODE_ALWAYSDAY));
	sprint(self, "{}| use `pms_noshake` to earth without quake\n", quick_ftos(MOON_IMPULSE_CODE_NOSHAKE));
	sprint(self, "{}| use `pmc_nohelp` to reduce amount of hints\n", quick_ftos(MOON_IMPULSE_CODE_NOHELP));
	sprint(self, "{}| use `pmc_fps` to show Framerate\n", quick_ftos(MOON_IMPULSE_CODE_SHOWFPS));
	sprint(self, "use `map moon4` or `restartserver` to restart this map\n");
	sprint(self, "-------------------------------------\n");
};

void() QuadCheat =
{
	self.super_time = 1;
	self.super_damage_finished = (time + MON_CAMPTIME);
	self.items = (self.items | IT_QUAD);
	dprint("quad cheat\n");
	self.gold = 9999;
};

void(float impulse_code) moon_handle_impulse_stat =
{
	if ( self.point <= 0 )
	{
		sprint(self, "no free skill points\n");
		return;
	}

	self.point = (self.point - 1);
	switch(impulse_code)
	{
		case MOON_IMPULSE_CODE_UPSKILL_VITALITY:
			moon_raise_target_vitality(self, 1);

			sprint(self, "upgrade Vitality: {} (", quick_ftos(self.vit));
			sprint(self, MOON_ITEM_HEALTH_EFFECT, quick_ftos(self.max_health));
			sprint(self, ")\n");
			break;
		case MOON_IMPULSE_CODE_UPSKILL_STRENGTH:
			moon_raise_target_strength(self, 1);

			sprint(self, "upgrade Strength: {} (", quick_ftos(self.stre));
			sprint(self, MOON_ITEM_DAMAGE_EFFECT, quick_ftos((self.stre * MOON_STAT_DAMAGE_PER_STRENGTH) + 100));
			sprint(self, ")\n");
			break;
		case MOON_IMPULSE_CODE_UPSKILL_SANITY:
			// moon_raise_target_sanity(self, 1);
			// TODO: implement
			break;
		case MOON_IMPULSE_CODE_UPSKILL_INTUITION:
			// moon_raise_target_intuition(self, 1);
			// TODO: implement
			break;
	}

	if ( self.point <= 0 )
	{
		if ( self.items & IT_KEY1 )
		{
			self.items = (self.items - IT_KEY1);
		}
	}
};

void(float impulse_code) moon_handle_impulse_ui =
{
	switch(impulse_code)
	{
	case MOON_IMPULSE_CODE_PRINT_STAT:
		moon_print_skills();
		break;
	case MOON_IMPULSE_CODE_UPSKILL_VITALITY:
	case MOON_IMPULSE_CODE_UPSKILL_STRENGTH:
	case MOON_IMPULSE_CODE_UPSKILL_SANITY:
	case MOON_IMPULSE_CODE_UPSKILL_INTUITION:
		moon_handle_impulse_stat(impulse_code);
		break;
	case MOON_IMPULSE_CODE_PRINT_CLI_HELP:
		moon_print_cmd_help();
		break;
	case MOON_IMPULSE_CODE_PRINT_INVENTORY:
		moon_print_inventory();
		break;
	case MOON_IMPULSE_CODE_PRINT_STATUS:
		moon_print_character_status();
		break;
	default:
		dprint("Unhandled impulse code for CLI UI {}\n", impulse_code);
	}
};

void(float impulse_code) moon_handle_impulse_server =
{
	if (self.colormap != 1)
	{
		return;
	}

	switch(self.impulse)
	{
	case MOON_IMPULSE_CODE_ALWAYSDAY:
		if (sv_alwaysday == 0)
		{
			sv_alwaysday = 1;
			kex_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "alwaysday enabled\n");
		} else {
			sv_alwaysday = 0;
			kex_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "alwaysday disabled\n");
		}
		break;
	case MOON_IMPULSE_CODE_NOSHAKE:
		if (sv_noshake == 0)
		{
			sv_noshake = 1;
			kex_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "Earthquakes disabled\n");
		} else {
			sv_noshake = 0;
			kex_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "Earthquakes enabled\n");
		}
		break;
	case MOON_IMPULSE_CODE_FASTMEAT:
		if (sv_fastmeat > 0)
		{
			sv_fastmeat = 0;
			kex_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "fastmeat disabled\n");
		} else {
			sv_fastmeat = 1;
			kex_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "fastmeat enabled\n");
		}
		break;
	case MOON_IMPULSE_CODE_SLOWMEAT:
		if (sv_fastmeat < 0)
		{
			sv_fastmeat = 0;
			kex_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "slo-owmeat disabled\n");
		} else {
			sv_fastmeat =-1;
			kex_chat_message_broad(MOON_CHAT_NAME_SERVER, MOON_CHAT_COLOR_TECHMSG, "slo-owmeat enabled\n");
		}
		break;
	case MOON_IMPULSE_CODE_CHEAT_QUAD:
		QuadCheat();
		break;
	default:
		dprint("Unhandled impulse code for SERVER settings {}\n", impulse_code);
	}
};

void(float impulse_code) moon_handle_impulse_client =
{
	switch(self.impulse)
	{
	case MOON_IMPULSE_CODE_NOHELP:
		if (self.cl_nohelp == 0)
		{
			self.cl_nohelp = 1;
			kex_chat_message_self(MOON_CHAT_NAME_SETTINGS, MOON_CHAT_COLOR_TECHMSG, "extra help enabled\n");
		} else {
			self.cl_nohelp = 0;
			kex_chat_message_self(MOON_CHAT_NAME_SETTINGS, MOON_CHAT_COLOR_TECHMSG, "extra help disabled\n");
		}
		break;
	case MOON_IMPULSE_CODE_SHOWFPS:
		if (self.cl_framtime == 0)
		{
			self.cl_framtime = 1;
			kex_chat_message_self(MOON_CHAT_NAME_SETTINGS, MOON_CHAT_COLOR_TECHMSG, "FPS count enabled\n");
		} else {
			self.cl_framtime = 0;
			kex_chat_message_self(MOON_CHAT_NAME_SETTINGS, MOON_CHAT_COLOR_TECHMSG, "FPS count disabled\n");
		}
		break;
	default:
		dprint("Unhandled impulse code for CLIENT settings {}\n", impulse_code);
	}
};

void(float impulse_code) moon_handle_impulse_trace =
{
	switch(impulse_code)
	{
	case MOON_IMPULSE_CODE_ITEM_PICKUP:
		moon_wear_item();
		break;
	case MOON_IMPULSE_CODE_ITEM_BUY:
		moon_buy_item();
		break;
	case MOON_IMPULSE_CODE_ITEM_IDENTIFY:
		moon_identify_item();
		break;
	default:
		dprint("Unhandled impulse code for CLI UI {}\n", impulse_code);
	}
};

void() moonimpulse =
{
	if ( self.prepared == FALSE )
	{
		Prepare();
	}

	if ( self.impulse == MOON_IMPULSE_CODE_NOOP ) { return; }

	// TODO: killme \/ JUKEBOX CONTROLS
	if ( (self.impulse >= 220) && (self.impulse <= 232) )
	{
		moon_walkman_play(self, self.impulse - 220);
	}
	// /\

	if ( (MOON_IMPULSE_CODE_FIRST_CLI_UI <= self.impulse) && (self.impulse <= MOON_IMPULSE_CODE_LAST_CLI_UI) )
	{
		moon_handle_impulse_ui(self.impulse);
	} else
	if ( (MOON_IMPULSE_CODE_FIRST_SETTING_SERVER <= self.impulse) && (self.impulse <= MOON_IMPULSE_CODE_LAST_SETTING_SERVER) )
	{
		moon_handle_impulse_server(self.impulse);
	} else
	if ( (MOON_IMPULSE_CODE_FIRST_SETTING_CLIENT <= self.impulse) && (self.impulse <= MOON_IMPULSE_CODE_LAST_SETTING_CLIENT) )
	{
		moon_handle_impulse_client(self.impulse);
	} else
	if ( (MOON_IMPULSE_CODE_FIRST_TRACE <= self.impulse) && (self.impulse <= MOON_IMPULSE_CODE_LAST_TRACE) )
	{
		moon_handle_impulse_trace(self.impulse);
	} else {
		dprint("Impulse code {} out of Project Moon's range {}-{}\n", self.impulse, MOON_IMPULSE_CODE_FIRST, MOON_IMPULSE_CODE_LAST);
	}
};

void() MoonPreThink =
{
	if ( self.cold_time > time )
	{
		if ( self.flags & FL_ONGROUND )
		{
			if ( self.velocity_x > MOON_PHYSIC_VELOCITY_X_LIMIT_HARD )
			{
				self.velocity_x = MOON_PHYSIC_VELOCITY_X_LIMIT_SOFT;
			}
			if ( self.velocity_y > MOON_PHYSIC_VELOCITY_Y_LIMIT_HARD )
			{
				self.velocity_y = MOON_PHYSIC_VELOCITY_Y_LIMIT_SOFT;
			}
		}
	}
};

void() MonsterDead =
{
	self.solid = SOLID_NOT;
	self.think = SUB_Remove;
	self.nextthink = time + moon_get_despawn_delay();
};

void() moon_make_chat_noise =
{
	local entity p;

	p = find(world, classname, MOON_PLAYER_CLASSNAME);
	while ((p != world))
	{
		sound(p, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
		p = find(p, classname, MOON_PLAYER_CLASSNAME);
	}

	p = find(world, classname, "CameraClient");
	while ((p != world))
	{
		sound(p, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
		p = find(p, classname, "CameraClient");
	}
};

vector() GetRandomVector = // Works - dont touch
{
	local vector vec;
	local float r;

	r = random();
	if ((r < MON_BACKTIME))
	{
		if ((r < 0.25))
		{
			if ((r < 0.05))
			{
				vec = VEC_ORIGIN;
			}
			else
			{
				if ((r < MON_CAMPERCHANCE))
				{
					vec = '0 0 12';
				}
				else
				{
					if ((r < 0.15))
					{
						vec = '0 12 0';
					}
					else
					{
						if ((r < MON_REACTIONTIME))
						{
							vec = '12 0 0';
						}
						else
						{
							vec = '12 12 0';
						}
					}
				}
			}
		}
		else
		{
			if ((r < 0.3))
			{
				vec = '12 0 12';
			}
			else
			{
				if ((r < GRD_DEFENDCHANCE))
				{
					vec = '0 12 12';
				}
				else
				{
					if ((r < MON_STUCKTIME))
					{
						vec = '0 12 12';
					}
					else
					{
						if ((r < 0.45))
						{
							vec = '-12 12 0';
						}
						else
						{
							vec = '-12 12 16';
						}
					}
				}
			}
		}
	}
	else
	{
		if ((r < 0.75))
		{
			if ((r < 0.55))
			{
				vec = '0 0 16';
			}
			else
			{
				if ((r < 0.6))
				{
					vec = '12 12 -16';
				}
				else
				{
					if ((r < 0.65))
					{
						vec = '12 12 0';
					}
					else
					{
						if ((r < 0.7))
						{
							vec = '12 0 12';
						}
						else
						{
							vec = '12 0 12';
						}
					}
				}
			}
		}
		else
		{
			if ((r < 0.8))
			{
				vec = '0 0 12';
			}
			else
			{
				if ((r < 0.85))
				{
					vec = '0 0 -12';
				}
				else
				{
					if ((r < 0.9))
					{
						vec = '0 -12 0';
					}
					else
					{
						if ((r < 0.95))
						{
							vec = '-12 0 0';
						}
						else
						{
							vec = '0 0 -16';
						}
					}
				}
			}
		}
	}
	return vec;
};

float(entity targ) BotCanSeePlayer =
{
	local vector spot1;
	local vector spot2;
	local vector vec;

	spot1 = (self.origin + self.view_ofs);
	vec = GetRandomVector();
	spot2 = (targ.origin + vec);
	traceline(spot1, spot2, TRUE, self);
	if ((trace_inopen && trace_inwater))
	{
		return (FALSE);
	}
	if ((trace_fraction == H_ROTTEN))
	{
		return (TRUE);
	}
	return (FALSE);
};

void() moon_bot_warn_enemy =
{
	local float r;

	moon_make_chat_noise();
	r = random_int(1, 4);
	switch(r)
	{
	case 1:
		kex_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "INCOMING!!!\n");
		break;
	case 2:
		kex_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "They are coming!\n");
		break;
	case 3:
		kex_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "I found enemy!\n");
		break;
	case 4:
		kex_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "We are under attack!\n");
		break;
	}
};

void() bot_find_enemy = // Works - dont touch
{
	local entity head;
	local float dist;

	dist = 1500;
	head = findradius(self.origin, 1500);
	while (head)
	{
		if ((head.flags & FL_MONSTER))
		{
			if (((head.health > WF_NORMAL) && (head != self)))
			{
				if (BotCanSeePlayer(head))
				{
					find_creature(head);
					self.enemy = head;
					if ((self.guard_chat_incoming < time))
					{
						if ((random() < MON_BACKTIME))
						{
							moon_bot_warn_enemy();
						}
						self.guard_chat_incoming = (time + 30);
					}
					self.show_hostile = (time + MON_REACTIONTIME);
					self.action = LOGIC_HUNTENEMY;
					self.action_time = WF_NORMAL;
					self.th_run();
				}
			}
		}
		head = head.chain;
	}
};

void() bot_fire = // Works - dont touch
{
	if ((vlen((self.enemy.origin - self.origin)) < 550))
	{
		if ((self.shaft_time > time))
		{
			if ((self.items & IT_LIGHTNING))
			{
				self.shootframe = LOGIC_DEFEND;
				self.walkframe = WF_NORMAL;
				M_FireShaft();
				return;
			}
		}
	}
	if ((vlen((self.enemy.origin - self.origin)) < 550))
	{
		if ((random() < MON_REACTIONTIME))
		{
			if ((self.items & IT_LIGHTNING))
			{
				self.shootframe = LOGIC_DEFEND;
				self.walkframe = WF_NORMAL;
				self.t_width = (time + 0.6);
				sound(self, CHAN_WEAPON, "weapons/lstart.wav", H_ROTTEN, ATTN_NORM);
				M_FireShaft();
				self.shaft_time = ((time + H_ROTTEN) + (random() * MON_BACKTIME));
				return;
			}
		}
	}
	if ((self.items & IT_ROCKET_LAUNCHER))
	{
		self.shootframe = H_MEGA;
		self.walkframe = WF_NORMAL;
		M_FireMissile();
		return;
	}
	if ((self.items & IT_GRENADE_LAUNCHER))
	{
		if ((vlen((self.enemy.origin - self.origin)) < GRD_FIGHTDIST))
		{
			self.shootframe = H_MEGA;
			self.walkframe = WF_NORMAL;
			M_FireGrenade();
			return;
		}
	}
	if ((self.items & IT_SUPER_NAILGUN))
	{
		self.shootframe = LOGIC_DEFEND;
		self.walkframe = WF_NORMAL;
		M_FireSuperNail(self.origin);
		return;
	}
	if ((self.items & IT_SUPER_SHOTGUN))
	{
		if ((vlen((self.enemy.origin - self.origin)) < 250))
		{
			self.shootframe = H_ROTTEN;
			self.walkframe = WF_NORMAL;
			M_FireSuperShotgun();
			return;
		}
	}
	if ((self.items & IT_NAILGUN))
	{
		self.shootframe = LOGIC_DEFEND;
		self.walkframe = WF_NORMAL;
		M_FireNail(self.origin);
		return;
	}
	if ((self.items & IT_SUPER_SHOTGUN))
	{
		self.shootframe = H_ROTTEN;
		self.walkframe = WF_NORMAL;
		M_FireSuperShotgun();
		return;
	}
	self.shootframe = H_ROTTEN;
	self.walkframe = WF_NORMAL;
	M_FireShotgun();
};

void() bot_security_check =
{
	local entity head;

	if ((self.enemy != world))
	{
		return;
	}
	if ((self.oldenemy != world))
	{
		return;
	}
	head = findradius(self.origin, 1500);
	while (head)
	{
		if ((head.classname == MOON_GUARD_CLASSNAME))
		{
			if (((head.health > WF_NORMAL) && (head != self)))
			{
				if ((head.enemy != world))
				{
					if ((head.enemy.health > WF_NORMAL))
					{
						head.enemy.next_fndcrt = time;
						find_creature(head.enemy);
						self.enemy = head.enemy;
						self.show_hostile = (time + MON_REACTIONTIME);
						self.action = LOGIC_HUNTENEMY;
						self.action_time = WF_NORMAL;
						kex_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "I'm helping comrades\n");
						self.th_run();
					}
				}
			}
		}
		head = head.chain;
	}
};

void() bot_think =
{
	GenerateAction();
	if ((self.enemy == world))
	{
		bot_find_enemy();
	}
};

void() ai_evade = // Works - dont touch
{
	local float dist;
	local vector vec;
	local vector org;
	local float yw;

	if (!(self.flags & FL_ONGROUND))
	{
		return;
	}
	dist = vlen((self.enemy.origin - self.origin));
	self.flags = (self.flags - (self.flags & FL_ONGROUND));
	if ((self.next_strafe_time < time))
	{
		if ((self.frags & FL_ONGROUND))
		{
			vec = (self.enemy.origin - self.origin);
			org = self.origin;
			makevectors(self.angles);
			yw = vectoyaw((self.enemy.origin - self.origin));
			if ((random() < MON_BACKTIME))
			{
				vec = (v_right * self.speed);
			}
			else
			{
				vec = (v_right * self.speed);
			}
			if ((dist < 210))
			{
				vec = (self.origin - (self.origin - (v_forward * self.speed)));
			}
			else
			{
				if ((dist > GRD_FIGHTDIST))
				{
					vec = (self.origin - (self.origin + (v_forward * self.speed)));
				}
			}
			self.next_strafe_time = ((time + 0.3) + (MON_STUCKTIME / random()));
			self.strafe_vector = normalize(vec);
		}
	}
	if ((self.frags & FL_ONGROUND))
	{
		self.flags = (self.flags - (self.flags & FL_ONGROUND));
		CheckEdge(self.goalentity);
		self.velocity = (self.strafe_vector * self.speed);
	}
	if ((self.goalentity == world))
	{
		bprint("ERROR: guard target lost!\n");
	}
};

void() bot_ai_stand = // Works - dont touch
{
	local float dst;

	self.currentammo = 0; // Sign of ???
	dst = vlen((self.master.origin - self.origin));
	bot_think();
	self.think = bot_ai_stand;
	self.nextthink = (time + MON_REFRESHTIME);
	if ((self.framtime < time))
	{
		if ((self.shootframe >= H_ROTTEN))
		{
			if ((self.shootframe >= LOGIC_FINDDEFEND))
			{
				if ((self.walkframe >= H_MEGA))
				{
					self.shootframe = WF_NORMAL;
					self.walkframe = WF_NORMAL;
				}
				if ((self.shootframe == LOGIC_FINDDEFEND))
				{
					self.frame = (103 + self.walkframe);
				}
				else
				{
					self.frame = (105 + self.walkframe);
				}
			}
			else
			{
				if ((self.walkframe >= LOGIC_HUNTENEMY))
				{
					self.shootframe = WF_NORMAL;
					self.walkframe = WF_NORMAL;
				}
				if ((self.shootframe == H_MEGA))
				{
					self.frame = (107 + self.walkframe);
				}
				else
				{
					self.frame = (113 + self.walkframe);
				}
			}
			self.walkframe = (self.walkframe + H_ROTTEN);
			self.framtime = (time + 0.07);
		}
		else
		{
			if ((self.walkframe >= SVC_SETVIEWPORT))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (12 + self.walkframe);
			self.walkframe = (self.walkframe + H_ROTTEN);
			self.framtime = (time + 0.07);
		}
	}
	if ((self.action == LOGIC_DEFEND))
	{
		if ((self.nextyaw < time))
		{
			self.ideal_yaw = (random() * 360);
			self.nextyaw = ((time + MON_BACKTIME) + (CL_DEADTIME * random()));
		}
		ChangeYaw();
		return;
	}
	if ((self.goalentity == world))
	{
		bprint("ERROR: null guard target!\n");
	}
	if ((!self.enemy && (self.oldenemy.health > WF_NORMAL)))
	{
		find_creature(self.oldenemy);
	}
	if (self.enemy)
	{
		self.th_run();
	}
	if ((self.action != WF_NORMAL))
	{
		self.th_run();
	}
};

void() bot_prethink = // Works - dont touch
{
	if ((((self.jump_flag < -300) && (self.flags & FL_ONGROUND)) && (self.health > WF_NORMAL)))
	{
		if ((self.watertype == CONTENT_WATER))
		{
			sound(self, CHAN_BODY, "player/h2ojump.wav", H_ROTTEN, ATTN_NORM);
		}
		else
		{
			if ((self.jump_flag < -650))
			{
				T_Damage(self, world, world, SVC_SETVIEWPORT);
				sound(self, CHAN_VOICE, "player/land2.wav", H_ROTTEN, ATTN_NORM);
				self.deathtype = "falling";
			}
			else
			{
				sound(self, CHAN_VOICE, "player/land.wav", H_ROTTEN, ATTN_NORM);
			}
		}
		self.jump_flag = WF_NORMAL;
	}
	if (!(self.flags & FL_ONGROUND))
	{
		self.jump_flag = self.velocity_z;
	}
};

float(entity own) NotDamagingPlayer =
{
	traceline(own.origin, (own.enemy.origin - own.origin), FALSE, own);
	if ((trace_ent.flags & FL_CLIENT))
	{
		return (FALSE);
	}
	else
	{
		return (TRUE);
	}
};

void(float dist) bot_ai_run = // Black magic ahead
{
	local float dst;
	local vector vec;
	local float stream;
	local entity head;

	self.currentammo = 1; // Sign of ???
	dst = vlen((self.master.origin - self.origin));
	movedist = dist;
	bot_think();
	if ((self.action == WF_NORMAL))
	{
		GenerateAction();
	}
	if ((self.enemy != world))
	{
		if ((!visible(self.enemy) || (self.enemy.health <= WF_NORMAL)))
		{
			if ((self.oldenemy.health > WF_NORMAL))
			{
				self.oldenemy = self.enemy;
			}
			else
			{
				self.oldenemy = world;
			}
			self.enemy = world;
			if ((self.oldenemy != world))
			{
				if ((self.oldenemy.health > WF_NORMAL))
				{
					find_creature(self.oldenemy);
				}
				else
				{
					self.action = LOGIC_FREESTYLE;
				}
			}
			self.goalentity = FindClosestWaypoint();
			return;
		}
	}
	if (!self.enemy)
	{
		if (self.oldenemy)
		{
			if ((self.oldenemy.flags & FL_MONSTER))
			{
				if ((self.oldenemy.health > WF_NORMAL))
				{
					self.action = LOGIC_HUNTENEMY;
					find_creature(self.oldenemy);
				}
				else
				{
					self.oldenemy = world;
					self.enemy = world;
					self.action = LOGIC_FREESTYLE;
					GenerateAction();
				}
			}
		}
	}
	if (self.enemy)
	{
		self.postenemy_org = self.enemy.origin;
		find_creature(self.enemy);
		dst = vlen((self.enemy.origin - self.origin));
		self.ideal_yaw = vectoyaw((self.enemy.origin - self.origin));
		ChangeYaw();
		if ((self.attack_finished < time))
		{
			if (CanDamage(self, self.enemy))
			{
				if (NotDamagingPlayer(self))
				{
					if ((FacingIdeal() == TRUE))
					{
						self.th_missile();
					}
				}
			}
		}
		if ((dst < GRD_FIGHTDIST))
		{
			ai_evade();
			return;
		}
	}
	if (!visible(self.goalentity))
	{
		if ((random() < 0.025))
		{
			self.action = LOGIC_FREESTYLE;
			GenerateAction();
		}
	}
	if ((self.flags & FL_PARTIALGROUND))
	{
		botCheckForStep(((self.goalentity.origin - self.origin) * self.speed));
	}
	if ((self.flags & FL_ONGROUND))
	{
		vec = (self.goalentity.origin - self.origin);
		self.flags = (self.flags - (self.flags & FL_ONGROUND));
		vec_z = WF_NORMAL;
		if ((self.next_spam < time))
		{
			if ((random() < MON_BACKTIME))
			{
				self.spam_vector = ((v_right * ((self.goalentity.radius / H_MEGA) + ((self.goalentity.radius / H_MEGA) * random()))) * CONTENT_EMPTY);
			}
			else
			{
				self.spam_vector = (v_right * ((self.goalentity.radius / H_MEGA) + ((self.goalentity.radius / H_MEGA) * random())));
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
				stream = (self.goalentity.radius * H_MEGA);
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
				self.rstuck_org_z = WF_NORMAL;
			}
			self.stuck_org = self.origin;
			self.stuck_time = (time + MON_STUCKTIME);
		}
		if ((self.goalentity.origin_z < self.origin_z))
		{
			if ((self.flags & FL_PARTIALGROUND))
			{
				self.flags = (self.flags - FL_PARTIALGROUND);
			}
			self.ideal_yaw = vectoyaw(((self.goalentity.origin - self.origin) + self.spam_vector));
			if ((self.rstuck_time < time))
			{
				vec = normalize((((self.goalentity.origin - self.origin) + self.spam_vector) + self.velocity));
				vec_z = WF_NORMAL;
			}
			else
			{
				vec = normalize(self.rstuck_org);
			}
			head = findradius(self.origin, (200 + (random() * 100)));
			if (!self.enemy)
			{
				if (!self.oldenemy)
				{
					while (head)
					{
						if ((head.classname == "grenade"))
						{
							makevectors(self.angles);
							if (visible(head))
							{
								vec = ((self.origin - head.origin) + self.velocity);
								vec = (vec * self.speed);
								vec = normalize(vec);
								vec_z = WF_NORMAL;
							}
						}
						head = head.chain;
					}
				}
			}
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
		ChangeYaw();
	}
};

void() bot_run1 = // I dont want to even read that
{
	bot_ai_run(LOGIC_DEFEND);
	if ((self.framtime < time))
	{
		if ((self.shootframe >= H_ROTTEN))
		{
			if ((self.shootframe >= LOGIC_FINDDEFEND))
			{
				if ((self.walkframe >= H_MEGA))
				{
					self.shootframe = WF_NORMAL;
					self.walkframe = WF_NORMAL;
				}
				if ((self.shootframe == LOGIC_FINDDEFEND))
				{
					self.frame = (103 + self.walkframe);
				}
				else
				{
					self.frame = (105 + self.walkframe);
				}
			}
			else
			{
				if ((self.walkframe >= LOGIC_HUNTENEMY))
				{
					self.shootframe = WF_NORMAL;
					self.walkframe = WF_NORMAL;
				}
				if ((self.shootframe == H_MEGA))
				{
					self.frame = (107 + self.walkframe);
				}
				else
				{
					self.frame = (113 + self.walkframe);
				}
			}
			self.walkframe = (self.walkframe + H_ROTTEN);
			self.framtime = (time + 0.07);
		}
		else
		{
			if ((self.walkframe >= LOGIC_HUNTENEMY))
			{
				self.walkframe = WF_NORMAL;
			}
			self.frame = (LOGIC_HUNTENEMY + self.walkframe);
			self.walkframe = (self.walkframe + H_ROTTEN);
			self.framtime = (time + 0.07);
		}
	}
	self.think = bot_run1;
	self.nextthink = (time + MON_REFRESHTIME);
};

void(entity who) moon_spawn_guard_items = // Works - dont touch
{
	local float lv;

	lv = moon_get_max_player_level();
	who.items = ((who.items + IT_AXE) + IT_SHOTGUN);
	if ((lv <= 4))
	{
		who.items = (who.items | IT_ARMOR1);
		who.armorvalue = (1 + (lv * 25));
		who.armortype = 0.3;
		if ((random() < 0.3))
		{
			who.items = (who.items + IT_SUPER_SHOTGUN);
		}
		if ((random() < MON_STUCKTIME))
		{
			who.items = (who.items + IT_NAILGUN);
		}
		if ((random() < 0.15))
		{
			who.items = (who.items + IT_SUPER_NAILGUN);
		}
	}
	else
	{
		if ((lv <= 8))
		{
			who.items = (who.items | IT_ARMOR2);
			who.armorvalue = ((lv * 25) - 50);
			who.armortype = 0.6;
			if ((random() < MON_STUCKTIME))
			{
				who.items = (who.items + IT_SUPER_SHOTGUN);
			}
			if ((random() < MON_STUCKTIME))
			{
				who.items = (who.items + IT_NAILGUN);
			}
			if ((random() < MON_STUCKTIME))
			{
				who.items = (who.items + IT_SUPER_NAILGUN);
			}
			if ((random() < 0.3))
			{
				who.items = (who.items + IT_GRENADE_LAUNCHER);
			}
			if ((random() < MON_REACTIONTIME))
			{
				who.items = (who.items + IT_ROCKET_LAUNCHER);
			}
		}
		else
		{
			if ((lv <= 12))
			{
				who.items = (who.items | IT_ARMOR3);
				who.armorvalue = ((lv * 25) - 100);
				who.armortype = 0.8;
				if ((random() < MON_STUCKTIME))
				{
					who.items = (who.items + IT_SUPER_SHOTGUN);
				}
				if ((random() < MON_STUCKTIME))
				{
					who.items = (who.items + IT_NAILGUN);
				}
				if ((random() < MON_STUCKTIME))
				{
					who.items = (who.items + IT_SUPER_NAILGUN);
				}
				if ((random() < MON_BACKTIME))
				{
					who.items = (who.items + IT_GRENADE_LAUNCHER);
				}
				if ((random() < MON_BACKTIME))
				{
					who.items = (who.items + IT_ROCKET_LAUNCHER);
				}
			}
			else
			{
				who.items = (who.items + IT_ARMOR3);
				who.armorvalue = 200;
				who.armortype = 0.8;
				if ((random() < 0.9))
				{
					who.items = (who.items + IT_SUPER_SHOTGUN);
				}
				if ((random() < 0.6))
				{
					who.items = (who.items + IT_NAILGUN);
				}
				if ((random() < 0.6))
				{
					who.items = (who.items + IT_SUPER_NAILGUN);
				}
				if ((random() < 0.8))
				{
					who.items = (who.items + IT_GRENADE_LAUNCHER);
				}
				if ((random() < 0.7))
				{
					who.items = (who.items + IT_ROCKET_LAUNCHER);
				}
				if ((random() < 0.5))
				{
					who.items = (who.items + IT_LIGHTNING);
				}
			}
		}
	}
	if ((who.armorvalue > 200))
	{
		who.armorvalue = 200;
	}
	who.max_health = (MOON_GUARD_HEALTH_INIT + (MOON_GUARD_HEALTH_GROW * lv));
	who.health = who.max_health;
};

void() SpawnBot =
{
	local entity newbot;
	local entity spot;
	local vector org;

	newbot = spawn();
	newbot.solid = SOLID_SLIDEBOX;
	newbot.movetype = MOVETYPE_STEP;
	newbot.angles = self.angles;
	newbot.classname = MOON_GUARD_CLASSNAME;
	newbot.master = self;
	newbot.action = LOGIC_FREESTYLE;
	newbot.takedamage = DAMAGE_AIM;
	newbot.goalentity = world;
	newbot.movetarget = world;
	newbot.pausetime = (time + 2);
	newbot.ideal_yaw = (newbot.angles * '0 1 0');
	newbot.yaw_speed = LOGIC_HUNTENEMY;
	newbot.view_ofs = '0 0 25';
	newbot.speed = 320;
	newbot.wantline = H_ROTTEN;
	moon_spawn_guard_items(newbot);
	bprint("== a wandering guardian joins your forces ==\n");
	bprint("HP: {}. ", floor_ftos(newbot.max_health));
	if ((newbot.items & IT_ARMOR1))
	{
		bprint("Green armor");
	}
	else
	{
		if ((newbot.items & IT_ARMOR2))
		{
			bprint("Yellow armor");
		}
		else
		{
			if ((newbot.items & IT_ARMOR3))
			{
				bprint("Red armor");
			}
		}
	}
	bprint("({}). Weapons: Shot", quick_ftos(newbot.armorvalue));
	if ((newbot.items & IT_SUPER_SHOTGUN))
	{
		bprint(", Supershot");
	}
	if ((newbot.items & IT_NAILGUN))
	{
		bprint(", Nail");
	}
	if ((newbot.items & IT_SUPER_NAILGUN))
	{
		bprint(", Supernail");
	}
	if ((newbot.items & IT_GRENADE_LAUNCHER))
	{
		bprint(", GL");
	}
	if ((newbot.items & IT_ROCKET_LAUNCHER))
	{
		bprint(", RL");
	}
	if ((newbot.items & IT_LIGHTNING))
	{
		bprint(", Shaft");
	}
	bprint(".\n");
	newbot.th_stand = bot_ai_stand;
	newbot.th_run = bot_run1;
	newbot.th_die = PlayerDie;
	newbot.th_missile = bot_fire;
	newbot.team = self.team;
	newbot.flags = FL_CLIENT;
	newbot.mode = 1;
	newbot.framtime = CONTENT_EMPTY;
	newbot.frame = 14;
	newbot.blockd = FALSE;
	newbot.backdist = 100;
	newbot.angles_x = WF_NORMAL;
	newbot.angles_z = WF_NORMAL;
	newbot.skin = LOGIC_FINDDEFEND;
	setmodel(newbot, "progs/player.mdl");
	setsize(newbot, VEC_HULL_MIN, VEC_HULL_MAX);
	spot = SelectSpawnPoint();
	org = (spot.origin + '0 0 1');
	setorigin(newbot, org);
	spawn_tfog(newbot.origin);
	newbot.nextthink = (time + MON_CAMPERCHANCE);
	newbot.think = newbot.th_stand;

	kex_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "Ready to serve\n");
};

void(entity e) GeneratePatrolTarget =
{
	local float a;

	a = rint(((random() * LOGIC_HUNTENEMY) + H_ROTTEN));
	e.action = LOGIC_PATROL;
	if ((a == H_ROTTEN))
	{
		e.wantline = H_ROTTEN;
		e.wantnum = H_MEGA;
	}
	if ((a == H_MEGA))
	{
		e.wantline = H_ROTTEN;
		e.wantnum = SVC_SETVIEWANGLES;
	}
	if ((a == LOGIC_FINDDEFEND))
	{
		e.wantline = H_MEGA;
		e.wantnum = LOGIC_HUNTENEMY;
	}
	if ((a == LOGIC_DEFEND))
	{
		e.wantline = H_MEGA;
		e.wantnum = LOGIC_FINDDEFEND;
	}
	if ((a == SVC_SETVIEWPORT))
	{
		e.wantline = LOGIC_FINDDEFEND;
		e.wantnum = TE_LIGHTNING3;
	}
	if ((a == LOGIC_HUNTENEMY))
	{
		e.wantline = TE_WIZSPIKE;
		e.wantnum = LOGIC_FINDDEFEND;
	}
	if ((a == TE_WIZSPIKE))
	{
		e.wantline = LOGIC_DEFEND;
		e.wantnum = LOGIC_FINDDEFEND;
	}
};

void(entity e) GenerateDefendTarget =
{
	local entity a;

	a = find(world, classname, "waypoint");
	while (a)
	{
		if ((a.flags & WF_DEFEND))
		{
			if ((random() < 0.25))
			{
				self.action = LOGIC_FINDDEFEND;
				self.wantline = a.line;
				self.wantnum = a.num;
				return;
			}
		}
		a = find(a, classname, "waypoint");
	}
};

void() GenerateAction =
{
	if ((self.goalentity == world))
	{
		self.goalentity = FindClosestWaypoint();
	}
	if (self.enemy)
	{
		if ((self.enemy.health > WF_NORMAL))
		{
			self.action = LOGIC_HUNTENEMY;
			return;
		}
	}
	if ((self.action != LOGIC_FREESTYLE))
	{
		if ((self.action_time > time))
		{
			return;
		}
	}
	if ((random() < GRD_DEFENDCHANCE))
	{
		GenerateDefendTarget(self);
		self.action_time = (time + GRD_DEFENDTIME);
		self.goalentity = FindClosestWaypoint();
	}
	else
	{
		GeneratePatrolTarget(self);
		self.action_time = (time + GRD_PATROLTIME);
		self.goalentity = FindClosestWaypoint();
	}
};

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
		dprint("warning: monster speed overload. maxspeed: {}. Current: {}.\n", floor_ftos(self.speed), floor_ftos(vlen(self.velocity)));
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
	e = find(world, classname, "gate");
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
								a.health = H_ROTTEN;
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
		self.lefty = (H_ROTTEN - self.lefty);
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
	self.lefty = (H_ROTTEN - self.lefty);
	walkmove((self.ideal_yaw - ofs), movedist);
	*/ // supress "contains unreachable code" warning
};

void(entity who) particle_heal =
{
	local vector smes;

	smes = ((who.origin + ((v_up * 12) * crandom())) + ((v_right * 10) * crandom()));
	particle(smes, VEC_ORIGIN, 165, 25);
	particle(smes, VEC_ORIGIN, 73, 25);
};

void(entity who, float clr) particle_scroll =
{
	local vector smes;

	smes = (((who.origin + (v_up * self.maxs_z)) - ((v_up * 12) * random())) + ((v_right * LOGIC_DEFEND) * crandom()));
	particle(smes, '0 0 -20', clr, 25);
};

void() check_heal = // TODO: implement one day
{
	local entity e;

	if ((self.medic != H_ROTTEN))
	{
		return;
	}
	if ((self.radsuit_finished < time))
	{
		return;
	}
	e = mon_find_ill_mon();
	if ((e != world))
	{
		particle_heal(e);
		if ((e.health < (e.max_health - SVC_SETVIEWPORT)))
		{
			e.health = (e.health + SVC_SETVIEWPORT);
		}
		else
		{
			e.health = e.max_health;
		}
		bprint("healing...\n ");
	}
	self.radsuit_finished = (time + MON_CAMPERCHANCE);
};

void() CheckCurse = // TODO: implement one day
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
		particle(smes, '0 0 5', 15, 25);
	}
	if ((self.scroll_slow_eff > time))
	{
		particle_scroll(self, 80);
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
		particle_scroll(self, 41);
	}
	if ((self.scroll_infe_eff > time))
	{
		infe_eff();
	}
	if ((self.scroll_shaf_eff > time))
	{
		shaf_eff();
	}
};

void() mon_think =
{
	if (gameover)
	{
		return;
	}
	CheckCurse();
	if (((self.mon_logic == LOGIC_CAMPER) && (self.enemy == world)))
	{
		self.wantnum = self.camp_num;
		self.wantline = self.camp_line;
	}
	else
	{
		if ((self.melee != H_ROTTEN))
		{
			self.wantline = H_ROTTEN;
			self.wantnum = WF_NORMAL;
		}
	}
	if (((self.mon_logic == LOGIC_HUNTER) || (self.melee == H_ROTTEN)))
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
			self.th_run();
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
			self.th_run();
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
					self.th_run();
					return;
				}
			}
			if ((self.nextyaw < time))
			{
				self.ideal_yaw = (random() * 360);
				self.nextyaw = ((time + MON_STUCKTIME) + (H_ROTTEN * random()));
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

void(float dist) mon_ai_run =
{
	local vector vec;
	local float dst;
	local float stream;
	local entity e;
	local entity mx;
	local float nm;

	self.currentammo = 1; // Sign of ???
	check_heal();
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
				if ((FacingIdeal() == TRUE))
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
		if ((self.melee == H_ROTTEN))
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
			stream = ((self.goalentity.radius / H_MEGA) + ((self.goalentity.radius / H_MEGA) * random()));
			if ((vlen((self.goalentity.origin - self.origin)) < 240))
			{
				stream = rint((stream / H_MEGA));
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
				stream = (self.goalentity.radius * H_MEGA);
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
			dprint("warning: monster speed overload. maxspeed: {}. Current: {}.\n", floor_ftos(self.speed), floor_ftos(vlen(self.velocity)));
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
						nm = (nm + H_ROTTEN);
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
						e.health = H_ROTTEN;
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
				if ((FacingIdeal() == TRUE))
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

void() intermission_victory =
{
	local entity head;
	local entity pos;
	local entity temp;

	pos = find(world, classname, "info_intermission");

	head = find(world, classname, MOON_PLAYER_CLASSNAME);
	while (head)
	{
		centerprint(head, "\sVICTORY\s\n");
		sprint(head, "[VICTORY] Your glorious level is {}!\n", floor_ftos(head.lvl));
		head.view_ofs = VEC_ORIGIN;
		head.v_angle = pos.mangle;
		head.angles = pos.mangle;
		head.fixangle = TRUE;
		head.nextthink = (time + MON_BACKTIME);
		head.takedamage = DAMAGE_NO;
		head.solid = SOLID_NOT;
		head.movetype = MOVETYPE_NONE;
		head.modelindex = WF_NORMAL;
		setorigin(head, pos.origin);

		head = find(head, classname, MOON_PLAYER_CLASSNAME);
	}

	intermission_running = 2; // End of Episode screen
	intermission_exittime = (time + 10);
	WriteByte(MSG_ALL, SVC_INTERMISSION);

	head = moon_gimme_your_heart();
	if (head)
	{
		temp = self;
		self = head;
		ThrowGib("progs/gold.mdl", random() * head.max_health);
		ThrowGib("progs/gold.mdl", random() * head.max_health);
		ThrowGib("progs/gold.mdl", random() * head.max_health);
		ThrowGib("progs/gold.mdl", random() * head.max_health);
		ThrowGib("progs/gold.mdl", random() * head.max_health);
		ThrowGib("progs/gold.mdl", random() * head.max_health);
		self = temp;
	}
	gameover = TRUE;
};

void() heart_die =
{
	local entity head;
	local entity pos;

	pos = find(world, classname, "info_intermission");

	head = find(world, classname, MOON_PLAYER_CLASSNAME);
	while (head)
	{
		sprint(head, "[GAME OVER] Your tiny level was just {}!\n", floor_ftos(head.lvl));
		head.view_ofs = VEC_ORIGIN;
		head.v_angle = pos.mangle;
		head.angles = pos.mangle;
		head.fixangle = TRUE;
		head.nextthink = (time + MON_BACKTIME);
		head.takedamage = DAMAGE_NO;
		head.solid = SOLID_NOT;
		head.movetype = MOVETYPE_NONE;
		head.modelindex = WF_NORMAL;
		setorigin(head, pos.origin);

		head = find(head, classname, MOON_PLAYER_CLASSNAME);
	}

	intermission_running = 1; // Stats screen
	intermission_exittime = (time + 5);
	WriteByte(MSG_ALL, SVC_INTERMISSION);
	ThrowGib("progs/gib1.mdl", self.health);
	ThrowGib("progs/gib2.mdl", self.health);
	ThrowGib("progs/gib3.mdl", self.health);
	ThrowGib("progs/gib1.mdl", self.health);
	ThrowGib("progs/gib2.mdl", self.health);
	ThrowGib("progs/gib3.mdl", self.health);
	gameover = TRUE;
	BecomeExplosion();
};

void() heart_regen =
{
	self.health = (self.health + MOON_HEART_HEALTH_REGEN_VALUE);
	if ((self.health > self.max_health))
	{
		self.health = self.max_health;
	}
	self.nextthink = (time + MOON_HEART_HEALTH_REGEN_COOLDOWN);
};

void() heart =
{
	setmodel(self, "progs/heart.mdl");
	self.solid = SOLID_BBOX;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.takedamage = DAMAGE_AIM;
	self.health = MOON_HEART_HEALTH_INIT;
	self.max_health = MOON_HEART_HEALTH_INIT;
	self.nextexp = MOON_EXP_FIRST_LEVEL;
	self.think = heart_regen;
	self.nextthink = (time + H_ROTTEN);
	self.th_die = heart_die;
};

void(entity e) GenegateCampTarget =
{
	local float a;

	a = rint(((random() * TE_WIZSPIKE) + H_ROTTEN));
	e.mon_logic = LOGIC_CAMPER;
	if ((a == H_ROTTEN))
	{
		e.camp_line = H_MEGA;
		e.camp_num = LOGIC_HUNTENEMY;
	}
	if ((a == H_MEGA))
	{
		e.camp_line = H_ROTTEN;
		e.camp_num = TE_TELEPORT;
	}
	if ((a == LOGIC_FINDDEFEND))
	{
		e.camp_line = LOGIC_FINDDEFEND;
		e.camp_num = LOGIC_FINDDEFEND;
	}
	if ((a == LOGIC_DEFEND))
	{
		e.camp_line = LOGIC_FINDDEFEND;
		e.camp_num = LOGIC_DEFEND;
	}
	if ((a == SVC_SETVIEWPORT))
	{
		e.camp_line = LOGIC_FINDDEFEND;
		e.camp_num = SVC_SETVIEWPORT;
	}
	if ((a == LOGIC_HUNTENEMY))
	{
		e.camp_line = TE_WIZSPIKE;
		e.camp_num = H_ROTTEN;
	}
	if ((a == TE_WIZSPIKE))
	{
		e.camp_line = TE_WIZSPIKE;
		e.camp_num = H_MEGA;
	}
	if ((a == KEY_MOVERIGHT))
	{
		e.camp_line = TE_WIZSPIKE;
		e.camp_num = LOGIC_FINDDEFEND;
	}
};

void(entity receiver) moon_println_target_own_magic_item_description =
{
	local float was_printed;
	local float same_pre_and_postfix;

	was_printed = TRUE;
	same_pre_and_postfix = FALSE;
	switch(self.magic_typeone)
	{
	case MOON_ITEM_HEALTH_CODE:
		if ( self.magic_typetwo == MOON_ITEM_HEALTH_CODE )
		{
			sprint(receiver, MOON_ITEM_HEALTH_EFFECT, quick_ftos(self.magic_typeone_value + self.magic_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_HEALTH_EFFECT, quick_ftos(self.magic_typeone_value));
		}
		break;
	case MOON_ITEM_RESIST_CODE:
		if ( self.magic_typetwo == MOON_ITEM_RESIST_CODE )
		{
			sprint(receiver, MOON_ITEM_RESIST_EFFECT, quick_ftos(self.magic_typeone_value + self.magic_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_RESIST_EFFECT, quick_ftos(self.magic_typeone_value));
		}
		break;
	case MOON_ITEM_GOLD_CODE:
		if ( self.magic_typetwo == MOON_ITEM_GOLD_CODE )
		{
			sprint(receiver, MOON_ITEM_GOLD_EFFECT, quick_ftos(self.magic_typeone_value + self.magic_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_GOLD_EFFECT, quick_ftos(self.magic_typeone_value));
		}
		break;
	case MOON_ITEM_DAMAGE_CODE:
		if ( self.magic_typetwo == MOON_ITEM_DAMAGE_CODE )
		{
			sprint(receiver, MOON_ITEM_DAMAGE_EFFECT, quick_ftos(self.magic_typeone_value + self.magic_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_DAMAGE_EFFECT, quick_ftos(self.magic_typeone_value));
		}
		break;
	case MOON_ITEM_RETALATE_CODE:
		if ( self.magic_typetwo == MOON_ITEM_RETALATE_CODE )
		{
			sprint(receiver, MOON_ITEM_RETALATE_EFFECT, quick_ftos(self.magic_typeone_value + self.magic_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_RETALATE_EFFECT, quick_ftos(self.magic_typeone_value));
		}
		break;
	case MOON_ITEM_VAMPIR_CODE:
		if ( self.magic_typetwo == MOON_ITEM_VAMPIR_CODE )
		{
			sprint(receiver, MOON_ITEM_VAMPIR_EFFECT, quick_ftos(self.magic_typeone_value + self.magic_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_VAMPIR_EFFECT, quick_ftos(self.magic_typeone_value));
		}
		break;
	case MOON_ITEM_REGEN_CODE:
		if ( self.magic_typetwo == MOON_ITEM_REGEN_CODE )
		{
			sprint(receiver, MOON_ITEM_REGEN_EFFECT, quick_ftos(self.magic_typeone_value + self.magic_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_REGEN_EFFECT, quick_ftos(self.magic_typeone_value));
		}
		break;
	case MOON_ITEM_CONSUME_CODE:
		if ( self.magic_typetwo == MOON_ITEM_CONSUME_CODE )
		{
			sprint(receiver, MOON_ITEM_CONSUME_EFFECT, quick_ftos(self.magic_typeone_value + self.magic_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_CONSUME_EFFECT, quick_ftos(self.magic_typeone_value));
		}
		break;
	default:
		was_printed = FALSE;
	}

	if ( same_pre_and_postfix )
	{
		sprint(receiver, "\n");
		return;
	}

	if (was_printed)
	{
		sprint(receiver, "\n");
	}

	was_printed = TRUE;
	switch(self.magic_typetwo)
	{
	case MOON_ITEM_HEALTH_CODE:
		if ( self.magic_typeone != MOON_ITEM_HEALTH_CODE )
		{
			sprint(receiver, MOON_ITEM_HEALTH_EFFECT, quick_ftos(self.magic_typetwo_value));
		}
		break;
	case MOON_ITEM_RESIST_CODE:
		if ( self.magic_typeone != MOON_ITEM_RESIST_CODE )
		{
			sprint(receiver, MOON_ITEM_RESIST_EFFECT, quick_ftos(self.magic_typetwo_value));
		}
		break;
	case MOON_ITEM_GOLD_CODE:
		if ( self.magic_typeone != MOON_ITEM_GOLD_CODE )
		{
			sprint(receiver, MOON_ITEM_GOLD_EFFECT, quick_ftos(self.magic_typetwo_value));
		}
		break;
	case MOON_ITEM_DAMAGE_CODE:
		if ( self.magic_typeone != MOON_ITEM_DAMAGE_CODE )
		{
			sprint(receiver, MOON_ITEM_DAMAGE_EFFECT, quick_ftos(self.magic_typetwo_value));
		}
		break;
	case MOON_ITEM_RETALATE_CODE:
		if ( self.magic_typeone != MOON_ITEM_RETALATE_CODE )
		{
			sprint(receiver, MOON_ITEM_RETALATE_EFFECT, quick_ftos(self.magic_typetwo_value));
		}
		break;
	case MOON_ITEM_VAMPIR_CODE:
		if ( self.magic_typeone != MOON_ITEM_VAMPIR_CODE )
		{
			sprint(receiver, MOON_ITEM_VAMPIR_EFFECT, quick_ftos(self.magic_typetwo_value));
		}
		break;
	case MOON_ITEM_REGEN_CODE:
		if ( self.magic_typeone != MOON_ITEM_REGEN_CODE )
		{
			sprint(receiver, MOON_ITEM_REGEN_EFFECT, quick_ftos(self.magic_typetwo_value));
		}
		break;
	case MOON_ITEM_CONSUME_CODE:
		if ( self.magic_typeone != MOON_ITEM_CONSUME_CODE )
		{
			sprint(receiver, MOON_ITEM_CONSUME_EFFECT, quick_ftos(self.magic_typetwo_value));
		}
		break;
	default:
		was_printed = FALSE;
	}
	if (was_printed)
	{
		sprint(receiver, "\n");
	}
};

void(entity receiver) moon_println_target_own_magic_ring_description =
{
	local float was_printed;
	local float same_pre_and_postfix;

	was_printed = TRUE;
	same_pre_and_postfix = FALSE;
	switch(self.ring_typeone)
	{
	case MOON_ITEM_HEALTH_CODE:
		if ( self.ring_typetwo == MOON_ITEM_HEALTH_CODE )
		{
			sprint(receiver, MOON_ITEM_HEALTH_EFFECT, quick_ftos(self.ring_typeone_value + self.ring_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_HEALTH_EFFECT, quick_ftos(self.ring_typeone_value));
		}
		break;
	case MOON_ITEM_RESIST_CODE:
		if ( self.ring_typetwo == MOON_ITEM_RESIST_CODE )
		{
			sprint(receiver, MOON_ITEM_RESIST_EFFECT, quick_ftos(self.ring_typeone_value + self.ring_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_RESIST_EFFECT, quick_ftos(self.ring_typeone_value));
		}
		break;
	case MOON_ITEM_GOLD_CODE:
		if ( self.ring_typetwo == MOON_ITEM_GOLD_CODE )
		{
			sprint(receiver, MOON_ITEM_GOLD_EFFECT, quick_ftos(self.ring_typeone_value + self.ring_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_GOLD_EFFECT, quick_ftos(self.ring_typeone_value));
		}
		break;
	case MOON_ITEM_DAMAGE_CODE:
		if ( self.ring_typetwo == MOON_ITEM_DAMAGE_CODE )
		{
			sprint(receiver, MOON_ITEM_DAMAGE_EFFECT, quick_ftos(self.ring_typeone_value + self.ring_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_DAMAGE_EFFECT, quick_ftos(self.ring_typeone_value));
		}
		break;
	case MOON_ITEM_RETALATE_CODE:
		if ( self.ring_typetwo == MOON_ITEM_RETALATE_CODE )
		{
			sprint(receiver, MOON_ITEM_RETALATE_EFFECT, quick_ftos(self.ring_typeone_value + self.ring_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_RETALATE_EFFECT, quick_ftos(self.ring_typeone_value));
		}
		break;
	case MOON_ITEM_VAMPIR_CODE:
		if ( self.ring_typetwo == MOON_ITEM_VAMPIR_CODE )
		{
			sprint(receiver, MOON_ITEM_VAMPIR_EFFECT, quick_ftos(self.ring_typeone_value + self.ring_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_VAMPIR_EFFECT, quick_ftos(self.ring_typeone_value));
		}
		break;
	case MOON_ITEM_REGEN_CODE:
		if ( self.ring_typetwo == MOON_ITEM_REGEN_CODE )
		{
			sprint(receiver, MOON_ITEM_REGEN_EFFECT, quick_ftos(self.ring_typeone_value + self.ring_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_REGEN_EFFECT, quick_ftos(self.ring_typeone_value));
		}
		break;
	case MOON_ITEM_CONSUME_CODE:
		if ( self.ring_typetwo == MOON_ITEM_CONSUME_CODE )
		{
			sprint(receiver, MOON_ITEM_CONSUME_EFFECT, quick_ftos(self.ring_typeone_value + self.ring_typetwo_value));
			same_pre_and_postfix = TRUE;
		} else {
			sprint(receiver, MOON_ITEM_CONSUME_EFFECT, quick_ftos(self.ring_typeone_value));
		}
		break;
	default:
		was_printed = FALSE;
	}

	if ( same_pre_and_postfix )
	{
		sprint(receiver, "\n");
		return;
	}

	if (was_printed)
	{
		sprint(receiver, "\n");
	}

	was_printed = TRUE;
	switch(self.ring_typetwo)
	{
	case MOON_ITEM_HEALTH_CODE:
		if ( self.ring_typeone != MOON_ITEM_HEALTH_CODE )
		{
			sprint(receiver, MOON_ITEM_HEALTH_EFFECT, quick_ftos(self.ring_typetwo_value));
		}
		break;
	case MOON_ITEM_RESIST_CODE:
		if ( self.ring_typeone != MOON_ITEM_RESIST_CODE )
		{
			sprint(receiver, MOON_ITEM_RESIST_EFFECT, quick_ftos(self.ring_typetwo_value));
		}
		break;
	case MOON_ITEM_GOLD_CODE:
		if ( self.ring_typeone != MOON_ITEM_GOLD_CODE )
		{
			sprint(receiver, MOON_ITEM_GOLD_EFFECT, quick_ftos(self.ring_typetwo_value));
		}
		break;
	case MOON_ITEM_DAMAGE_CODE:
		if ( self.ring_typeone != MOON_ITEM_DAMAGE_CODE )
		{
			sprint(receiver, MOON_ITEM_DAMAGE_EFFECT, quick_ftos(self.ring_typetwo_value));
		}
		break;
	case MOON_ITEM_RETALATE_CODE:
		if ( self.ring_typeone != MOON_ITEM_RETALATE_CODE )
		{
			sprint(receiver, MOON_ITEM_RETALATE_EFFECT, quick_ftos(self.ring_typetwo_value));
		}
		break;
	case MOON_ITEM_VAMPIR_CODE:
		if ( self.ring_typeone != MOON_ITEM_VAMPIR_CODE )
		{
			sprint(receiver, MOON_ITEM_VAMPIR_EFFECT, quick_ftos(self.ring_typetwo_value));
		}
		break;
	case MOON_ITEM_REGEN_CODE:
		if ( self.ring_typeone != MOON_ITEM_REGEN_CODE )
		{
			sprint(receiver, MOON_ITEM_REGEN_EFFECT, quick_ftos(self.ring_typetwo_value));
		}
		break;
	case MOON_ITEM_CONSUME_CODE:
		if ( self.ring_typeone != MOON_ITEM_CONSUME_CODE )
		{
			sprint(receiver, MOON_ITEM_CONSUME_EFFECT, quick_ftos(self.ring_typetwo_value));
		}
		break;
	default:
		was_printed = FALSE;
	}
	if (was_printed)
	{
		sprint(receiver, "\n");
	}
};

float(float level) moon_generate_trait_prefix_code =
{
	local float r;

	if ((level <= MOON_ITEM_LVLTHRESHOLD_LOW))
	{
		r = random_int(MOON_ITEM_TRAIT_LOWERBOUND_LOW, MOON_ITEM_TRAIT_UPPERBOUND_PREFIX_LOW);
	} else
	if ((level <= MOON_ITEM_LVLTHRESHOLD_NORMAL))
	{
		r = random_int(MOON_ITEM_TRAIT_LOWERBOUND_NORMAL, MOON_ITEM_TRAIT_UPPERBOUND_PREFIX_NORMAL);
	} else
	if ((level <= MOON_ITEM_LVLTHRESHOLD_HIGH))
	{
		r = random_int(MOON_ITEM_TRAIT_LOWERBOUND_HIGH, MOON_ITEM_TRAIT_UPPERBOUND_PREFIX_HIGH);
	} else {
		r = random_int(MOON_ITEM_TRAIT_LOWERBOUND_EPIC, MOON_ITEM_TRAIT_UPPERBOUND_PREFIX_EPIC);
	}

	return (r % (MOON_ITEM_TRAIT_MAX_PREFIX + 1));
}

float(float level) moon_generate_trait_postfix_code =
{
	local float r;

	if ((level <= MOON_ITEM_LVLTHRESHOLD_LOW))
	{
		r = random_int(MOON_ITEM_TRAIT_LOWERBOUND_LOW, MOON_ITEM_TRAIT_UPPERBOUND_POSTFIX_LOW);
	} else
	if ((level <= MOON_ITEM_LVLTHRESHOLD_NORMAL))
	{
		r = random_int(MOON_ITEM_TRAIT_LOWERBOUND_NORMAL, MOON_ITEM_TRAIT_UPPERBOUND_POSTFIX_NORMAL);
	} else
	if ((level <= MOON_ITEM_LVLTHRESHOLD_HIGH))
	{
		r = random_int(MOON_ITEM_TRAIT_LOWERBOUND_HIGH, MOON_ITEM_TRAIT_UPPERBOUND_POSTFIX_HIGH);
	} else {
		r = random_int(MOON_ITEM_TRAIT_LOWERBOUND_EPIC, MOON_ITEM_TRAIT_UPPERBOUND_POSTFIX_EPIC);
	}

	return (r % (MOON_ITEM_TRAIT_MAX_POSTFIX + 1));
}

void(entity e) moon_generate_magic_prefix =
{
	local float r;
	local float mxx;

	mxx = moon_get_max_player_level();
	r = moon_generate_trait_prefix_code(mxx);
	e.magic_typeone = r % (MOON_ITEM_TRAIT_MAX_EFFECT + 1); // assuming trait fits the grid [LOW1-8,NORMAL1-8,HIGH1-8,EPIC1-8]
	switch(r)
	{
	// MOON_ITEM_HEALTH_CODE
	case MOON_ITEM_HEALTH_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):		// 1 = 1+(8*0)
		e.magic_typeone_value = random_int(MOON_ITEM_HEALTH_PREFIX_LOW_FROM, MOON_ITEM_HEALTH_PREFIX_LOW_TO);
		e.prefix_one = MOON_ITEM_HEALTH_PREFIX_LOW;
		break;
	case MOON_ITEM_HEALTH_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_NORMAL):	// 9 = 1+(8*1)
		e.magic_typeone_value = random_int(MOON_ITEM_HEALTH_PREFIX_NORMAL_FROM, MOON_ITEM_HEALTH_PREFIX_NORMAL_TO);
		e.prefix_one = MOON_ITEM_HEALTH_PREFIX_NORMAL;
		break;
	case MOON_ITEM_HEALTH_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_HIGH):		// 17 = 1+(8*2)
		e.magic_typeone_value = random_int(MOON_ITEM_HEALTH_PREFIX_HIGH_FROM, MOON_ITEM_HEALTH_PREFIX_HIGH_TO);
		e.prefix_one = MOON_ITEM_HEALTH_PREFIX_HIGH;
		break;
	case MOON_ITEM_HEALTH_PREFIX_EPIC_CODE: // keep original distribution of traits			// 23
		e.magic_typeone = MOON_ITEM_HEALTH_CODE; // out of grid, so code also needs to be changed
		e.magic_typeone_value = random_int(MOON_ITEM_HEALTH_PREFIX_EPIC_FROM, MOON_ITEM_HEALTH_PREFIX_EPIC_TO);
		e.prefix_one = MOON_ITEM_HEALTH_PREFIX_EPIC;
		break;
	// MOON_ITEM_RESIST_CODE
	case MOON_ITEM_RESIST_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):		// 2 = 2+(8*0)
		e.magic_typeone_value = random_int(MOON_ITEM_RESIST_PREFIX_LOW_FROM, MOON_ITEM_RESIST_PREFIX_LOW_TO);
		e.prefix_one = MOON_ITEM_RESIST_PREFIX_LOW;
		break;
	case MOON_ITEM_RESIST_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_NORMAL):	// 10 = 2+(8*1)
		e.magic_typeone_value = random_int(MOON_ITEM_RESIST_PREFIX_NORMAL_FROM, MOON_ITEM_RESIST_PREFIX_NORMAL_TO);
		e.prefix_one = MOON_ITEM_RESIST_PREFIX_NORMAL;
		break;
	case MOON_ITEM_RESIST_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_HIGH):		// 18 = 2+(8*2)
		e.magic_typeone_value = random_int(MOON_ITEM_RESIST_PREFIX_HIGH_FROM, MOON_ITEM_RESIST_PREFIX_HIGH_TO);
		e.prefix_one = MOON_ITEM_RESIST_PREFIX_HIGH;
		break;
	case MOON_ITEM_RESIST_PREFIX_EPIC_CODE:													// 24
		e.magic_typeone = MOON_ITEM_RESIST_CODE;
		e.magic_typeone_value = random_int(MOON_ITEM_RESIST_PREFIX_EPIC_FROM, MOON_ITEM_RESIST_PREFIX_EPIC_TO);
		e.prefix_one = MOON_ITEM_RESIST_PREFIX_EPIC;
		break;
	// MOON_ITEM_GOLD_CODE
	case MOON_ITEM_GOLD_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):			// 3 = 3+(8*0)
		e.magic_typeone_value = random_int(MOON_ITEM_GOLD_PREFIX_LOW_FROM, MOON_ITEM_GOLD_PREFIX_LOW_TO);
		e.prefix_one = MOON_ITEM_GOLD_PREFIX_LOW;
		break;
	case MOON_ITEM_GOLD_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_NORMAL):		// 11 = 3+(8*1)
		e.magic_typeone_value = random_int(MOON_ITEM_GOLD_PREFIX_NORMAL_FROM, MOON_ITEM_GOLD_PREFIX_NORMAL_TO);
		e.prefix_one = MOON_ITEM_GOLD_PREFIX_NORMAL;
		break;
	// -- NO High rarity variant -- \\
	case MOON_ITEM_GOLD_PREFIX_EPIC_CODE:													// 25
		e.magic_typeone = MOON_ITEM_GOLD_CODE;
		e.magic_typeone_value = random_int(MOON_ITEM_GOLD_PREFIX_EPIC_FROM, MOON_ITEM_GOLD_PREFIX_EPIC_TO);
		e.prefix_one = MOON_ITEM_GOLD_PREFIX_EPIC;
		break;
	// MOON_ITEM_DAMAGE_CODE
	case MOON_ITEM_DAMAGE_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):		// 4 = 4+(8*0)
		e.magic_typeone_value = random_int(MOON_ITEM_DAMAGE_PREFIX_LOW_FROM, MOON_ITEM_DAMAGE_PREFIX_LOW_TO);
		e.prefix_one = MOON_ITEM_DAMAGE_PREFIX_LOW;
		break;
	case MOON_ITEM_DAMAGE_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_NORMAL):	// 12 = 4+(8*1)
		e.magic_typeone_value = random_int(MOON_ITEM_DAMAGE_PREFIX_NORMAL_FROM, MOON_ITEM_DAMAGE_PREFIX_NORMAL_TO);
		e.prefix_one = MOON_ITEM_DAMAGE_PREFIX_NORMAL;
		break;
	case MOON_ITEM_DAMAGE_PREFIX_HIGH_CODE:													// 19
		e.magic_typeone = MOON_ITEM_DAMAGE_CODE;
		e.magic_typeone_value = random_int(MOON_ITEM_DAMAGE_PREFIX_HIGH_FROM, MOON_ITEM_DAMAGE_PREFIX_HIGH_TO);
		e.prefix_one = MOON_ITEM_DAMAGE_PREFIX_HIGH;
		break;
	// -- NO Epic rarity variant -- \\
	// MOON_ITEM_RETALATE_CODE
	case MOON_ITEM_RETALATE_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):		// 5 = 5+(8*0)
		e.magic_typeone_value = random_int(MOON_ITEM_RETALATE_PREFIX_LOW_FROM, MOON_ITEM_RETALATE_PREFIX_LOW_TO);
		e.prefix_one = MOON_ITEM_RETALATE_PREFIX_LOW;
		break;
	case MOON_ITEM_RETALATE_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_NORMAL):	// 13 = 5+(8*1)
		e.magic_typeone_value = random_int(MOON_ITEM_RETALATE_PREFIX_NORMAL_FROM, MOON_ITEM_RETALATE_PREFIX_NORMAL_TO);
		e.prefix_one = MOON_ITEM_RETALATE_PREFIX_NORMAL;
		break;
	// -- NO High rarity variant -- \\
	case MOON_ITEM_RETALATE_PREFIX_EPIC_CODE:												// 26
		e.magic_typeone = MOON_ITEM_RETALATE_CODE;
		e.magic_typeone_value = random_int(MOON_ITEM_RETALATE_PREFIX_EPIC_FROM, MOON_ITEM_RETALATE_PREFIX_EPIC_TO);
		e.prefix_one = MOON_ITEM_RETALATE_PREFIX_EPIC;
		break;
	// MOON_ITEM_VAMPIR_CODE
	case MOON_ITEM_VAMPIR_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):		// 6 = 6+(8*0)
		e.magic_typeone_value = random_int(MOON_ITEM_VAMPIR_PREFIX_LOW_FROM, MOON_ITEM_VAMPIR_PREFIX_LOW_TO);
		e.prefix_one = MOON_ITEM_VAMPIR_PREFIX_LOW;
		break;
	case MOON_ITEM_VAMPIR_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_NORMAL):	// 14 = 6+(8*1)
		e.magic_typeone_value = random_int(MOON_ITEM_VAMPIR_PREFIX_NORMAL_FROM, MOON_ITEM_VAMPIR_PREFIX_NORMAL_TO);
		e.prefix_one = MOON_ITEM_VAMPIR_PREFIX_NORMAL;
		break;
	// -- NO High rarity variant -- \\
	case MOON_ITEM_VAMPIR_PREFIX_EPIC_CODE:													// 27
		e.magic_typeone = MOON_ITEM_VAMPIR_CODE;
		e.magic_typeone_value = random_int(MOON_ITEM_VAMPIR_PREFIX_EPIC_FROM, MOON_ITEM_VAMPIR_PREFIX_EPIC_TO);
		e.prefix_one = MOON_ITEM_VAMPIR_PREFIX_EPIC;
		break;
	// MOON_ITEM_REGEN_CODE
	case MOON_ITEM_REGEN_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):		// 7 = 7+(8*0)
		e.magic_typeone_value = random_int(MOON_ITEM_REGEN_PREFIX_LOW_FROM, MOON_ITEM_REGEN_PREFIX_LOW_TO);
		e.prefix_one = MOON_ITEM_REGEN_PREFIX_LOW;
		break;
	case MOON_ITEM_REGEN_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_NORMAL):		// 15 = 7+(8*1)
		e.magic_typeone_value = random_int(MOON_ITEM_REGEN_PREFIX_NORMAL_FROM, MOON_ITEM_REGEN_PREFIX_NORMAL_TO);
		e.prefix_one = MOON_ITEM_REGEN_PREFIX_NORMAL;
		break;
	case MOON_ITEM_REGEN_PREFIX_HIGH_CODE:													// 20
		e.magic_typeone = MOON_ITEM_REGEN_CODE;
		e.magic_typeone_value = random_int(MOON_ITEM_REGEN_PREFIX_HIGH_FROM, MOON_ITEM_REGEN_PREFIX_HIGH_TO);
		e.prefix_one = MOON_ITEM_REGEN_PREFIX_HIGH;
		break;
	case MOON_ITEM_REGEN_PREFIX_EPIC_CODE:													// 22
		e.magic_typeone = MOON_ITEM_REGEN_CODE;
		e.magic_typeone_value = random_int(MOON_ITEM_REGEN_PREFIX_EPIC_FROM, MOON_ITEM_REGEN_PREFIX_EPIC_TO);
		e.prefix_one = MOON_ITEM_REGEN_PREFIX_EPIC;
		break;
	// MOON_ITEM_CONSUME_CODE
	case MOON_ITEM_CONSUME_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):		// 8 = 8+(8*0)
		e.magic_typeone_value = random_int(MOON_ITEM_CONSUME_PREFIX_LOW_FROM, MOON_ITEM_CONSUME_PREFIX_LOW_TO);
		e.prefix_one = MOON_ITEM_CONSUME_PREFIX_LOW;
		break;
	case MOON_ITEM_CONSUME_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_NORMAL):	// 16 = 8+(8*1)
		e.magic_typeone_value = random_int(MOON_ITEM_CONSUME_PREFIX_NORMAL_FROM, MOON_ITEM_CONSUME_PREFIX_NORMAL_TO);
		e.prefix_one = MOON_ITEM_CONSUME_PREFIX_NORMAL;
		break;
	case MOON_ITEM_CONSUME_PREFIX_HIGH_CODE:												// 21
		e.magic_typeone = MOON_ITEM_CONSUME_CODE;
		e.magic_typeone_value = random_int(MOON_ITEM_CONSUME_PREFIX_HIGH_FROM, MOON_ITEM_CONSUME_PREFIX_HIGH_TO);
		e.prefix_one = MOON_ITEM_CONSUME_PREFIX_HIGH;
		break;
	// -- NO Epic rarity variant -- \\
	default:
		bprint("moon_generate_magic_prefix cannot handle code {}\n", quick_ftos(r));
	}

};

void(entity e) moon_generate_magic_postfix =
{
	local float r;
	local float mxx;

	mxx = moon_get_max_player_level();
	r = moon_generate_trait_postfix_code(mxx);
	e.magic_typetwo = r % (MOON_ITEM_TRAIT_MAX_EFFECT + 1);

	switch(r)
	{
	// MOON_ITEM_HEALTH_CODE
	case MOON_ITEM_HEALTH_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):		// 1 = 1+(8*0)
		e.magic_typetwo_value = random_int(MOON_ITEM_HEALTH_POSTFIX_LOW_FROM, MOON_ITEM_HEALTH_POSTFIX_LOW_TO);
		e.prefix_two = MOON_ITEM_HEALTH_POSTFIX_LOW;
		break;
	case MOON_ITEM_HEALTH_POSTFIX_NORMAL_CODE:												// 8
		e.magic_typetwo = MOON_ITEM_HEALTH_CODE;
		e.magic_typetwo_value = random_int(MOON_ITEM_HEALTH_POSTFIX_NORMAL_FROM, MOON_ITEM_HEALTH_POSTFIX_NORMAL_TO);
		e.prefix_two = MOON_ITEM_HEALTH_POSTFIX_NORMAL;
		break;
	// -- NO High rarity variant -- \\
	// MOON_ITEM_RESIST_CODE
	case MOON_ITEM_RESIST_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):		// 2 = 2+(8*0)
		e.magic_typetwo_value = random_int(MOON_ITEM_RESIST_POSTFIX_LOW_FROM, MOON_ITEM_RESIST_POSTFIX_LOW_TO);
		e.prefix_two = MOON_ITEM_RESIST_POSTFIX_LOW;
		break;
	case MOON_ITEM_RESIST_POSTFIX_NORMAL_CODE:												// 9
		e.magic_typetwo = MOON_ITEM_RESIST_CODE;
		e.magic_typetwo_value = random_int(MOON_ITEM_RESIST_POSTFIX_NORMAL_FROM, MOON_ITEM_RESIST_POSTFIX_NORMAL_TO);
		e.prefix_two = MOON_ITEM_RESIST_POSTFIX_NORMAL;
		break;
	case MOON_ITEM_RESIST_POSTFIX_HIGH_CODE:												// 14
		e.magic_typetwo = MOON_ITEM_RESIST_CODE;
		e.magic_typetwo_value = random_int(MOON_ITEM_RESIST_POSTFIX_HIGH_FROM, MOON_ITEM_RESIST_POSTFIX_HIGH_TO);
		e.prefix_two = MOON_ITEM_RESIST_POSTFIX_HIGH;
		break;
	// MOON_ITEM_GOLD_CODE
	case MOON_ITEM_GOLD_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):			// 3 = 3+(8*0)
		e.magic_typetwo_value = random_int(MOON_ITEM_GOLD_POSTFIX_LOW_FROM, MOON_ITEM_GOLD_POSTFIX_LOW_TO);
		e.prefix_two = MOON_ITEM_GOLD_POSTFIX_LOW;
		break;
	case MOON_ITEM_GOLD_POSTFIX_NORMAL_CODE:												// 10
		e.magic_typetwo = MOON_ITEM_GOLD_CODE;
		e.magic_typetwo_value = random_int(MOON_ITEM_GOLD_POSTFIX_NORMAL_FROM, MOON_ITEM_GOLD_POSTFIX_NORMAL_TO);
		e.prefix_two = MOON_ITEM_GOLD_POSTFIX_NORMAL;
		break;
	// -- NO High rarity variant -- \\
	// MOON_ITEM_DAMAGE_CODE
	case MOON_ITEM_DAMAGE_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):		// 4 = 4+(8*0)
		e.magic_typetwo_value = random_int(MOON_ITEM_DAMAGE_POSTFIX_LOW_FROM, MOON_ITEM_DAMAGE_POSTFIX_LOW_TO);
		e.prefix_two = MOON_ITEM_DAMAGE_POSTFIX_LOW;
		break;
	case MOON_ITEM_DAMAGE_POSTFIX_NORMAL_CODE:												// 11
		e.magic_typetwo = MOON_ITEM_DAMAGE_CODE;
		e.magic_typetwo_value = random_int(MOON_ITEM_DAMAGE_POSTFIX_NORMAL_FROM, MOON_ITEM_DAMAGE_POSTFIX_NORMAL_TO);
		e.prefix_two = MOON_ITEM_DAMAGE_POSTFIX_NORMAL;
		break;
	case MOON_ITEM_DAMAGE_POSTFIX_HIGH_CODE:												// 17
		e.magic_typetwo = MOON_ITEM_DAMAGE_CODE;
		e.magic_typetwo_value = random_int(MOON_ITEM_DAMAGE_POSTFIX_HIGH_FROM, MOON_ITEM_DAMAGE_POSTFIX_HIGH_TO);
		e.prefix_two = MOON_ITEM_DAMAGE_POSTFIX_HIGH;
		break;
	// MOON_ITEM_RETALATE_CODE
	case MOON_ITEM_RETALATE_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):		// 5 = 5+(8*0)
		e.magic_typetwo_value = random_int(MOON_ITEM_RETALATE_POSTFIX_LOW_FROM, MOON_ITEM_RETALATE_POSTFIX_LOW_TO);
		e.prefix_two = MOON_ITEM_RETALATE_POSTFIX_LOW;
		break;
	case MOON_ITEM_RETALATE_POSTFIX_NORMAL_CODE:											// 12
		e.magic_typetwo = MOON_ITEM_RETALATE_CODE;
		e.magic_typetwo_value = random_int(MOON_ITEM_RETALATE_POSTFIX_NORMAL_FROM, MOON_ITEM_RETALATE_POSTFIX_NORMAL_TO);
		e.prefix_two = MOON_ITEM_RETALATE_POSTFIX_NORMAL;
		break;
	// -- NO High rarity variant -- \\
	// MOON_ITEM_VAMPIR_CODE
	case MOON_ITEM_VAMPIR_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):		// 6 = 6+(8*0)
		e.magic_typetwo_value = random_int(MOON_ITEM_VAMPIR_POSTFIX_LOW_FROM, MOON_ITEM_VAMPIR_POSTFIX_LOW_TO);
		e.prefix_two = MOON_ITEM_VAMPIR_POSTFIX_LOW;
		break;
	// -- NO Normal rarity variant -- \\
	// -- NO High rarity variant -- \\
	// MOON_ITEM_REGEN_CODE
	case MOON_ITEM_REGEN_CODE + (MOON_ITEM_TRAIT_MAX_EFFECT * MOON_ITEM_RARITY_LOW):		// 7 = 7+(8*0)
		e.magic_typetwo_value = random_int(MOON_ITEM_REGEN_POSTFIX_LOW_FROM, MOON_ITEM_REGEN_POSTFIX_LOW_TO);
		e.prefix_two = MOON_ITEM_REGEN_POSTFIX_LOW;
		break;
	case MOON_ITEM_REGEN_POSTFIX_NORMAL_CODE:												// 16
		e.magic_typetwo = MOON_ITEM_REGEN_CODE;
		e.magic_typetwo_value = random_int(MOON_ITEM_REGEN_POSTFIX_NORMAL_FROM, MOON_ITEM_REGEN_POSTFIX_NORMAL_TO);
		e.prefix_two = MOON_ITEM_REGEN_POSTFIX_NORMAL;
		break;
	// -- NO High rarity variant -- \\
	// MOON_ITEM_CONSUME_CODE
	case MOON_ITEM_CONSUME_POSTFIX_LOW_CODE:												// 13
		e.magic_typetwo = MOON_ITEM_CONSUME_CODE;
		e.magic_typetwo_value = random_int(MOON_ITEM_CONSUME_POSTFIX_LOW_FROM, MOON_ITEM_CONSUME_POSTFIX_LOW_TO);
		e.prefix_two = MOON_ITEM_CONSUME_POSTFIX_LOW;
		break;
	case MOON_ITEM_CONSUME_POSTFIX_NORMAL_CODE:												// 15
		e.magic_typetwo = MOON_ITEM_CONSUME_CODE;
		e.magic_typetwo_value = random_int(MOON_ITEM_CONSUME_POSTFIX_NORMAL_FROM, MOON_ITEM_CONSUME_POSTFIX_NORMAL_TO);
		e.prefix_two = MOON_ITEM_CONSUME_POSTFIX_NORMAL;
		break;
	// -- NO High rarity variant -- \\
	default:
		bprint("moon_generate_magic_postfix cannot handle code {}\n", quick_ftos(r));
	}
};

void() MagicItemTouch =
{
	local float l;

	if (other.classname != MOON_PLAYER_CLASSNAME) { return; }
	if (other.health <= 0) { return; }

	if (((other.next_mesg_time < time) || (other.mesg_inflictor != self)))
	{
		sprint(other, "=== magic item ===\n");
		moon_print_target_item_name(other, self.prefix_one, self.netname, self.prefix_two);
		sprint(other, "\n");
		moon_println_target_own_magic_item_description(other); // when self is item, its magic is held in same place for both Armor and Ring

		if ((other.cl_nohelp == 0))
		{
			if ((self.classname != MOON_MARKET_ITEM_CLASSNAME))
			{
				l = moon_get_max_player_level();
				if ((l < 4))
				{
					sprint(other, "Use `use` command to pick it up.\n");
				}
			}
		}
		other.next_mesg_time = (time + 4);
		other.mesg_inflictor = self;
	}
};

void() moon_wear_item = // THIS NEEDS A CLEANING
{
	local entity head;
	local entity selected;
	local float min_dist;

	min_dist = 100;
	head = find(world, classname, MOON_ITEM_MAGIC_CLASSNAME);
	while (head)
	{
		if ((vlen((head.origin - self.origin)) < min_dist))
		{
			min_dist = vlen((head.origin - self.origin));
			selected = head;
		}
		head = find(head, classname, MOON_ITEM_MAGIC_CLASSNAME);
	}
	if ((other.classname == MOON_MARKET_ITEM_CLASSNAME))
	{
		selected = other;
	}
	if ((selected != world))
	{
		if ((selected.netname == MOON_ITEM_ARMOR_NETNAME))
		{
			if ((self.wear_armor == MOON_ITEM_SOME))
			{
				if ((self.magic_typeone == MOON_ITEM_HEALTH_CODE))
				{
					self.max_health = (self.max_health - self.magic_typeone_value);
					if (!(self.items & IT_SUPERHEALTH))
					{
						if ((self.health > self.max_health))
						{
							self.health = self.max_health;
						}
					}
				}
				if ((self.magic_typetwo == MOON_ITEM_HEALTH_CODE))
				{
					self.max_health = (self.max_health - self.magic_typetwo_value);
					if (!(self.items & IT_SUPERHEALTH))
					{
						if ((self.health > self.max_health))
						{
							self.health = self.max_health;
						}
					}
				}
				self.wear_armor = WF_NORMAL;
				self.magic_typeone = WF_NORMAL;
				self.magic_typeone_value = WF_NORMAL;
				self.magic_prefixone = s_wiz;
				self.magic_typetwo = WF_NORMAL;
				self.magic_typetwo_value = WF_NORMAL;
				self.magic_prefixtwo = s_wiz;
			}
			selected.magic_prefixone = selected.prefix_one;
			selected.magic_prefixtwo = selected.prefix_two;
			sound(self, CHAN_ITEM, "items/armor1.wav", H_ROTTEN, ATTN_NORM);
			self.wear_armor = MOON_ITEM_SOME;
			if ((selected.magic_typeone > WF_NORMAL))
			{
				self.magic_typeone = selected.magic_typeone;
				self.magic_typeone_value = selected.magic_typeone_value;
				self.magic_prefixone = selected.magic_prefixone;
				if ((selected.magic_typeone == MOON_ITEM_HEALTH_CODE))
				{
					moon_raise_target_max_health(self, selected.magic_typeone_value);
				}
			}
			if ((selected.magic_typetwo > WF_NORMAL))
			{
				self.magic_typetwo = selected.magic_typetwo;
				self.magic_typetwo_value = selected.magic_typetwo_value;
				self.magic_prefixtwo = selected.magic_prefixtwo;
				if ((selected.magic_typetwo == MOON_ITEM_HEALTH_CODE))
				{
					moon_raise_target_max_health(self, selected.magic_typetwo_value);
				}
			}
			sprint(self, "\n");
			if ((selected.classname == MOON_MARKET_ITEM_CLASSNAME))
			{
				sprint(self, "You bought ");
			} else {
				sprint(self, "You put on ");
			}
			moon_print_target_item_name(self, selected.magic_prefixone, selected.netname, selected.magic_prefixtwo);
			sprint(self, "\n");
		}
		else
		{
			if ((selected.netname == MOON_ITEM_RING_NETNAME))
			{
				if ((self.wear_ring == MOON_ITEM_SOME))
				{
					if ((self.ring_typeone == MOON_ITEM_HEALTH_CODE))
					{
						self.max_health = (self.max_health - self.ring_typeone_value);
						if (!(self.items & IT_SUPERHEALTH))
						{
							if ((self.health > self.max_health))
							{
								self.health = self.max_health;
							}
						}
					}
					if ((self.ring_typetwo == MOON_ITEM_HEALTH_CODE))
					{
						self.max_health = (self.max_health - self.ring_typetwo_value);
						if (!(self.items & IT_SUPERHEALTH))
						{
							if ((self.health > self.max_health))
							{
								self.health = self.max_health;
							}
						}
					}
					self.wear_ring = WF_NORMAL;
					self.ring_typeone = WF_NORMAL;
					self.ring_typeone_value = WF_NORMAL;
					self.ring_prefixone = s_wiz;
					self.ring_typetwo = WF_NORMAL;
					self.ring_typetwo_value = WF_NORMAL;
					self.ring_prefixtwo = s_wiz;
				}
				selected.ring_prefixone = selected.prefix_one;
				selected.ring_prefixtwo = selected.prefix_two;
				selected.ring_typeone = selected.magic_typeone;
				selected.ring_typetwo = selected.magic_typetwo;
				selected.ring_typeone_value = selected.magic_typeone_value;
				selected.ring_typetwo_value = selected.magic_typetwo_value;
				sound(self, CHAN_ITEM, "moon/items/ring.wav", H_ROTTEN, ATTN_NORM);
				self.wear_ring = MOON_ITEM_SOME;
				if ((selected.ring_typeone > WF_NORMAL))
				{
					self.ring_typeone = selected.ring_typeone;
					self.ring_typeone_value = selected.ring_typeone_value;
					self.ring_prefixone = selected.ring_prefixone;
					if ((selected.ring_typeone == MOON_ITEM_HEALTH_CODE))
					{
						moon_raise_target_max_health(self, selected.ring_typeone_value);
					}
				}
				if ((selected.ring_typetwo > WF_NORMAL))
				{
					self.ring_typetwo = selected.ring_typetwo;
					self.ring_typetwo_value = selected.ring_typetwo_value;
					self.ring_prefixtwo = selected.ring_prefixtwo;
					if ((selected.ring_typetwo == MOON_ITEM_HEALTH_CODE))
					{
						moon_raise_target_max_health(self, selected.ring_typetwo_value);
					}
				}
				sprint(self, "\n");
				if ((selected.classname == MOON_MARKET_ITEM_CLASSNAME))
				{
					sprint(self, "You bought ");
				} else {
					sprint(self, "You put on ");
				}
				moon_print_target_item_name(self, selected.ring_prefixone, selected.netname, selected.ring_prefixtwo);
				sprint(self, "\n");
			}
		}
		flash_self();
		remove(selected);
	} else {
		sprint(self, "there is \sno\s items around\n");
	}
};

void() moon_print_inventory =
{
	entity e;
	float duration;
	float did_print_section;

	if ((((((self.wear_armor == MOON_ITEM_NONE) && (self.wear_ring == MOON_ITEM_NONE)) && (self.mentat_bonus == MOON_ITEM_NONE)) && (self.mentat_bonus2 == MOON_ITEM_NONE)) && (self.mentat_bonus3 == MOON_ITEM_NONE)))
	{
		sprint(self, "you have \sno\s special items\n");
		return;
	}

	did_print_section = FALSE;
	sprint(self, "==== your current items ====\n");
	if ((self.mentat_bonus == MOON_ITEM_SOME))
	{
		moon_print_mentat_offense(self);

		e = find(world, classname, MOON_MENTAT_CLASSNAME);
		while (e)
		{
			if ( (e.owner == self) && (e.mentat_bonus == MOON_ITEM_SOME) )
			{
				duration = e.attack_finished - time;
				sprint(self, " {}{}{}", MOON_GLYPH_BRACKET_OPEN, floor_ftos(duration), MOON_GLYPH_BRACKET_CLOSE);
			}
			e = find(e, classname, MOON_MENTAT_CLASSNAME);
		}
		sprint(self, "\n");
		did_print_section = TRUE;
	}
	if ((self.mentat_bonus2 == MOON_ITEM_SOME))
	{
		moon_print_mentat_defense(self);

		e = find(world, classname, MOON_MENTAT_CLASSNAME);
		while (e)
		{
			if ( (e.owner == self) && (e.mentat_bonus2 == MOON_ITEM_SOME) )
			{
				duration = e.attack_finished - time;
				sprint(self, " {}{}{}", MOON_GLYPH_BRACKET_OPEN, floor_ftos(duration), MOON_GLYPH_BRACKET_CLOSE);
			}
			e = find(e, classname, MOON_MENTAT_CLASSNAME);
		}
		sprint(self, "\n");
		did_print_section = TRUE;
	}
	if ((self.mentat_bonus3 == MOON_ITEM_SOME))
	{
		moon_print_mentat_speed(self);

		e = find(world, classname, MOON_MENTAT_CLASSNAME);
		while (e)
		{
			if ( (e.owner == self) && (e.mentat_bonus3 == MOON_ITEM_SOME) )
			{
				duration = e.attack_finished - time;
				sprint(self, " {}{}{}", MOON_GLYPH_BRACKET_OPEN, floor_ftos(duration), MOON_GLYPH_BRACKET_CLOSE);
			}
			e = find(e, classname, MOON_MENTAT_CLASSNAME);
		}
		sprint(self, "\n");
		did_print_section = TRUE;
	}

	if ( self.wear_armor == MOON_ITEM_SOME )
	{
		if (did_print_section == TRUE)
		{
			sprint(self, "--------------------------\n");
		}
		sprint(self, CONST_QC_GLYPH_SELECTION);
		moon_println_target_magic_armor_name(self, self);
		moon_println_target_own_magic_item_description(self);
	}

	if ( self.wear_ring == MOON_ITEM_SOME )
	{
		if (did_print_section == TRUE)
		{
			sprint(self, "--------------------------\n");
		}
		sprint(self, CONST_QC_GLYPH_SELECTION);
		moon_println_target_magic_ring_name(self, self);
		moon_println_target_own_magic_ring_description(self);
	}
	sprint(self, "--------------------------\n");
};

void(entity who) DropMagicArmor =
{
	local entity item;
	local float z;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	item.classname = MOON_ITEM_MAGIC_CLASSNAME;
	if ( random() < MOON_ITEM_ARMOR_VS_RING_CHANCE )
	{
		item.netname = MOON_ITEM_ARMOR_NETNAME;
		setmodel(item, "progs/armor.mdl");
		item.skin = 3;
	} else {
		item.netname = MOON_ITEM_RING_NETNAME;
		setmodel(item, "progs/ring.mdl");
	}
	setsize(item, '-16 -16 0', '16 16 48');
	item.touch = MagicItemTouch;
	item.nextthink = (time + MENTAT_TIME);
	item.think = SUB_Remove;
	z = random();
	if ( z < MOON_ITEM_MAGIC_CHANCE_PREFIX )
	{
		moon_generate_magic_prefix(item);
	}
	else
	{
		if ( z < MOON_ITEM_MAGIC_CHANCE_POSTFIX )
		{
			moon_generate_magic_postfix(item);
		}
		else
		{
			moon_generate_magic_prefix(item);
			moon_generate_magic_postfix(item);
		}
	}
};

void() UpgradeTouch =
{
	local float pl;
	local entity gate;
	local entity heart;
	local float bonus_value;

	if (other.classname != MOON_PLAYER_CLASSNAME) { return; }
	if (other.health <= 0) { return; }

	pl = moon_get_max_player_level();
	switch(self.cnt)
	{
	case MOON_ITEM_GATEALERT_CODE:
		if (up_alert < 1)
		{
			sprint(other, MOON_ITEM_GATEALERT_EFFECT);
		} else {
			sprint(other, MOON_ITEM_GATEALERT_SIDEEFFECT);
			gate = find(world, classname, MOON_GATE_CLASSNAME);
			if (gate)
			{
				gate.max_health = gate.max_health + MOON_ITEM_GATEALERT_SIDEEFFECT_BONUS;
			}
		}
		up_alert = up_alert + 1;
		break;
	case MOON_ITEM_SHELLUP_CODE:
		if (other.up_bullet < 1)
		{
			sprint(other, MOON_ITEM_SHELLUP_EFFECT);
		} else {
			sprint(other, MOON_ITEM_SHELLUP_SIDEEFFECT);
		}
		other.up_bullet = other.up_bullet + 1; // Re-use same param for both Upgrade and Extra capacity
		break;
	case MOON_ITEM_NAILUP_CODE:
		if (other.up_nail < 1)
		{
			sprint(other, MOON_ITEM_NAILUP_EFFECT);
		} else {
			sprint(other, MOON_ITEM_NAILUP_SIDEEFFECT);
		}
		other.up_nail = other.up_nail + 1; // Re-use same param for both Upgrade and Extra capacity
		break;
	case MOON_ITEM_STATUP_CODE:
		sprint(other, MOON_ITEM_STATUP_EFFECT);
		other.point = other.point + MOON_ITEM_STATUP_BONUS;
		other.items = (other.items | IT_KEY1);
		break;
	case MOON_ITEM_GUARDIAN_CODE:
		sprint(other, MOON_ITEM_GUARDIAN_EFFECT);
		SpawnBot();
		break;
	case MOON_ITEM_GLOBALGOLD_CODE:
		bonus_value = MOON_ITEM_GLOBALGOLD_BONUS_FLAT + (pl * MOON_ITEM_GLOBALGOLD_BONUS_LVLPERCENT) + (random() * MOON_ITEM_GLOBALGOLD_BONUS_RANDOM);
		sprint(other, MOON_ITEM_GLOBALGOLD_EFFECT, floor_ftos(bonus_value));

		up_gold_value = up_gold_value + bonus_value;
		moon_broadcast_global_gold_bonus();
		break;
	case MOON_ITEM_HEART_CODE:
		bonus_value = MOON_ITEM_HEART_BONUS_FLAT + (pl * MOON_ITEM_HEART_BONUS_LVLPERCENT) + (random() * MOON_ITEM_HEART_BONUS_RANDOM);
		sprint(other, MOON_ITEM_HEART_EFFECT, floor_ftos(bonus_value));

		heart = moon_gimme_your_heart();
		if ( heart != world )
		{
			heart.max_health = (heart.max_health + bonus_value);
			heart.health = (heart.health + bonus_value);
			if ( heart.health > heart.max_health )
			{
				heart.health = heart.max_health;
			}
		}
		moon_broadcast_heart_state();
		break;
	}

	sound(other, CHAN_ITEM, "moon/items/book.wav", 1, ATTN_NORM);
	flash_target(other);
	remove(self);
};

void(entity who, float val) DropBookByCode =
{
	local entity item;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.cnt = val;
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel(item, "progs/tome.mdl");
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = UpgradeTouch;
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_IMPORTANT);
	item.think = SUB_Remove;
};

void(entity who) DropBookUpgrade =
{
	local float code;
	code = random_int(MOON_ITEM_GATEALERT_CODE, MOON_ITEM_GUARDIAN_CODE);
	DropBookByCode(who, code);
};

void(entity e) prepare_item =
{
	e.velocity_z = 300;
	e.velocity_x = (-100 + (random() * 200));
	e.velocity_y = (-100 + (random() * 200));
	e.flags = FL_ITEM;
	e.solid = SOLID_TRIGGER;
	e.movetype = MOVETYPE_TOSS;
	e.angles_y = rint((random() * 360));
};

void() HPTouch =
{
	if (other.classname != MOON_PLAYER_CLASSNAME) { return; }
	if (other.health <= 0) { return; }

	if ((other.health < other.max_health))
	{
		sprint(other, "You get {} and receive {} health\n", self.netname, floor_ftos(self.healamount));
	} else {
		sprint(other, "You wasted {}\n", self.netname);
	}

	flash_target(other);
	T_Heal(other, self.healamount, 0);
	sound(other, CHAN_ITEM, "moon/items/potion.wav", 1, ATTN_NORM);
	remove(self);
};

void() ELTouch =
{
	if (other.classname != MOON_PLAYER_CLASSNAME) { return; }
	if (other.health <= 0) { return; }

	switch(floor(self.cnt))
	{
	case MOON_ELIXIR_STR_CODE:
		moon_raise_target_strength(other, MOON_ELIXIR_STR_VALUE);
		break;
	case MOON_ELIXIR_VIT_CODE:
		moon_raise_target_vitality(other, MOON_ELIXIR_VIT_VALUE);
		break;
	case MOON_ELIXIR_MAG_CODE:
		moon_raise_target_sanity(other, MOON_ELIXIR_MAG_VALUE);
		break;
	case MOON_ELIXIR_INT_CODE:
		moon_raise_target_intuition(other, MOON_ELIXIR_INT_VALUE);
		break;
	}

	flash_target(other);
	sprint(other, "You got {}\n", self.netname);
	sound(other, CHAN_ITEM, "moon/items/potion.wav", 1, ATTN_NORM);
	remove(self);
};

void(entity who) moon_spawn_drop_elixir =
{
	local entity item;
	local float pl;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	prepare_item(item);
	setmodel(item, "progs/potion.mdl");
	item.skin = H_MEGA;
	setsize(item, '-12 -12 0', '12 12 36');
	item.touch = ELTouch;
	item.nextthink = (time + 60);
	item.think = SUB_Remove;
	pl = random_int(MOON_ELIXIR_STR_CODE, MOON_ELIXIR_VIT_CODE); // TODO: when implemented, up to MOON_ELIXIR_INT_CODE
	item.cnt = pl;
	switch(pl)
	{
	case MOON_ELIXIR_STR_CODE:
		item.netname = MOON_ELIXIR_STR_NETNAME;
		break;
	case MOON_ELIXIR_VIT_CODE:
		item.netname = MOON_ELIXIR_VIT_NETNAME;
		break;
	case MOON_ELIXIR_MAG_CODE:
		item.netname = MOON_ELIXIR_MAG_NETNAME;
		break;
	case MOON_ELIXIR_INT_CODE:
		item.netname = MOON_ELIXIR_INT_NETNAME;
		break;
	}
};

void(entity who) moon_spawn_drop_potion =
{
	local entity item;
	local float pl;
	local float r;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	item.angles_y = rint((random() * 360));
	setmodel(item, "progs/potion.mdl");
	pl = moon_get_max_player_level();
	if ((pl < MOON_ITEM_LVLTHRESHOLD_POTION_LOWER))
	{
		item.healamount = rint(((random() * MOON_ITEM_POTION_SMALL_RANDOM) + MOON_ITEM_POTION_SMALL_BASE));
		item.netname = MOON_ITEM_POTION_SMALL_NETNAME;
	}
	else
	{
		if (((pl >= MOON_ITEM_LVLTHRESHOLD_POTION_LOWER) && (pl <= MOON_ITEM_LVLTHRESHOLD_POTION_UPPER)))
		{
			if ((random() < 0.6))
			{
				item.healamount = rint(((random() * MOON_ITEM_POTION_NORMAL_RANDOM) + MOON_ITEM_POTION_NORMAL_BASE));
				item.netname = MOON_ITEM_POTION_NORMAL_NETNAME;
			}
			else
			{
				item.healamount = rint(((random() * MOON_ITEM_POTION_SMALL_RANDOM) + MOON_ITEM_POTION_SMALL_BASE));
				item.netname = MOON_ITEM_POTION_SMALL_NETNAME;
			}
		}
		else
		{
			r = random();
			if ((r < 0.33))
			{
				item.healamount = rint(((random() * MOON_ITEM_POTION_NORMAL_RANDOM) + MOON_ITEM_POTION_NORMAL_BASE));
				item.netname = MOON_ITEM_POTION_NORMAL_NETNAME;
			}
			else
			{
				if ((r > 0.66))
				{
					item.healamount = rint(((random() * MOON_ITEM_POTION_SMALL_RANDOM) + MOON_ITEM_POTION_SMALL_BASE));
					item.netname = MOON_ITEM_POTION_SMALL_NETNAME;
				}
				else
				{
					item.healamount = rint(((random() * MOON_ITEM_POTION_BIG_RANDOM) + MOON_ITEM_POTION_BIG_BASE));
					item.netname = MOON_ITEM_POTION_BIG_NETNAME;
				}
			}
		}
	}
	setsize(item, '-12 -12 0', '12 12 36');
	item.touch = HPTouch;
	item.nextthink = (time + 60);
	item.think = SUB_Remove;
};

void(entity e, float n1, float n2) SCTCLP = // Praise the Omnissiah
{
	if ((n1 == CHSCAM_ON))
	{
		e.sc_n1 = n2;
	}
	else
	{
		if ((n1 == H_MEGA))
		{
			e.sc_n2 = n2;
		}
		else
		{
			if ((n1 == LOGIC_FINDDEFEND))
			{
				e.sc_n3 = n2;
			}
			else
			{
				if ((n1 == LOGIC_DEFEND))
				{
					e.sc_n4 = n2;
				}
				else
				{
					if ((n1 == SVC_SETVIEWPORT))
					{
						e.sc_n5 = n2;
					}
				}
			}
		}
	}
};

void(entity e, float sc_n, float cnn, float cn) SCTD = // God-Emperor protect me
{
	if (((sc_n == WF_NORMAL) && (cn == CHSCAM_ON)))
	{
		e.sc_heal_lvl = WF_NORMAL;
		sprint(e, "you get ");
		SCTCLP(e, cnn, cn);
		des_scroll(e, CHSCAM_ON);
	}
	else
	{
		if (((sc_n > WF_NORMAL) && (cn == CHSCAM_ON)))
		{
			e.sc_heal_lvl = (e.sc_heal_lvl + CHSCAM_ON);
			sprint(e, "You upgrade ");
			des_scroll(e, CHSCAM_ON);
		}
		else
		{
			if (((sc_n == WF_NORMAL) && (cn == H_MEGA)))
			{
				e.sc_redu_lvl = WF_NORMAL;
				sprint(e, "You get ");
				SCTCLP(e, cnn, cn);
				des_scroll(e, H_MEGA);
			}
			else
			{
				if (((sc_n > WF_NORMAL) && (cn == H_MEGA)))
				{
					e.sc_redu_lvl = (e.sc_redu_lvl + CHSCAM_ON);
					sprint(e, "You upgrade ");
					des_scroll(e, H_MEGA);
				}
				else
				{
					if (((sc_n == WF_NORMAL) && (cn == LOGIC_FINDDEFEND)))
					{
						e.sc_slow_lvl = WF_NORMAL;
						sprint(e, "You get ");
						SCTCLP(e, cnn, cn);
						des_scroll(e, LOGIC_FINDDEFEND);
					}
					else
					{
						if (((sc_n > WF_NORMAL) && (cn == LOGIC_FINDDEFEND)))
						{
							e.sc_slow_lvl = (e.sc_slow_lvl + CHSCAM_ON);
							sprint(e, "You upgrade ");
							des_scroll(e, LOGIC_FINDDEFEND);
						}
						else
						{
							if (((sc_n == WF_NORMAL) && (cn == LOGIC_DEFEND)))
							{
								e.sc_brut_lvl = WF_NORMAL;
								sprint(e, "You get ");
								SCTCLP(e, cnn, cn);
								des_scroll(e, LOGIC_DEFEND);
							}
							else
							{
								if (((sc_n > WF_NORMAL) && (cn == LOGIC_DEFEND)))
								{
									e.sc_brut_lvl = (e.sc_brut_lvl + CHSCAM_ON);
									sprint(e, "You upgrade ");
									des_scroll(e, LOGIC_DEFEND);
								}
							}
						}
					}
				}
			}
		}
	}
};

void() SCT = // ScrollTouch, Finish him
{
	if ( other.classname != MOON_PLAYER_CLASSNAME ) { return; }
	if ( other.health <= 0 ) { return; }

	if (((other.sc_n1 == WF_NORMAL) || (other.sc_n1 == self.cnt)))
	{
		SCTD(other, other.sc_n1, CHSCAM_ON, self.cnt);
	}
	else
	{
		if (((other.sc_n2 == WF_NORMAL) || (other.sc_n2 == self.cnt)))
		{
			SCTD(other, other.sc_n2, H_MEGA, self.cnt);
		}
		else
		{
			if (((other.sc_n3 == WF_NORMAL) || (other.sc_n3 == self.cnt)))
			{
				SCTD(other, other.sc_n3, LOGIC_FINDDEFEND, self.cnt);
			}
			else
			{
				if (((other.sc_n4 == WF_NORMAL) || (other.sc_n4 == self.cnt)))
				{
					SCTD(other, other.sc_n4, LOGIC_DEFEND, self.cnt);
				}
				else
				{
					if (((other.sc_n5 == WF_NORMAL) || (other.sc_n5 == self.cnt)))
					{
						SCTD(other, other.sc_n5, SVC_SETVIEWPORT, self.cnt);
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
	item.touch = SCT; // TODO: rename to ScrollTouch or similar
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_NORMAL);
	item.think = SUB_Remove;
};

void() ShardTouch =
{
	if ( other.classname != MOON_PLAYER_CLASSNAME ) { return; }
	if ( other.health <= 0 ) { return; }

	if (((!(other.items & IT_ARMOR1) && !(other.items & IT_ARMOR2)) && !(other.items & IT_ARMOR3)))
	{
		other.items = (other.items | IT_ARMOR1);
		other.armortype = MOON_ARMOR_SHARD_TYPE;
		other.armorvalue = MOON_ARMOR_SHARD_GAIN;
	} else {
		other.armorvalue = (other.armorvalue + MOON_ARMOR_SHARD_GAIN);
		if ( other.armorvalue > MOON_ARMOR_MAX_SOFT )
		{
			other.armorvalue = MOON_ARMOR_MAX_SOFT;
		}
	}
	flash_target(other);
	sound(other, CHAN_ITEM, "moon/items/shard.wav", 1, ATTN_NORM);
	remove(self);
};

void(entity who) moon_spawn_drop_armor_shard =
{
	local entity item;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	item.angles_y = rint((random() * 360));
	setmodel(item, "progs/shard.mdl");
	setsize(item, '-12 -12 0', '12 12 24');
	item.touch = ShardTouch;
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_NORMAL);
	item.think = SUB_Remove;
};

void() GoldTouch =
{
	if ( other.classname != MOON_PLAYER_CLASSNAME ) { return; }
	if ( other.health <= 0 ) { return; }

	moon_give_target_gold(other, self.gold);
	remove(self);
};

void() mentat_think =
{
	if ( self.attack_finished < (time + 3) )
	{
		if ( self.cnt == 0 )
		{
			sprint(self.owner, "{} is fading\n", self.netname);
		}
		self.cnt = 1;
	}

	if ((((self.attack_finished < time) || (self.owner.health <= 0)) || (((self.owner.mentat_bonus + self.owner.mentat_bonus2) + self.owner.mentat_bonus3) == 0)))
	{
		if( self.mentat_bonus == MOON_ITEM_SOME )
		{
			self.owner.mentat_bonus = MOON_ITEM_NONE;
		} else
		if( self.mentat_bonus2 == MOON_ITEM_SOME )
		{
			self.owner.mentat_bonus2 = MOON_ITEM_NONE;
		} else
		if( self.mentat_bonus3 == MOON_ITEM_SOME )
		{
			self.owner.mentat_bonus3 = MOON_ITEM_NONE;
		}
		remove(self);
	}

	self.nextthink = (time + 1);
	self.think = mentat_think;
};

void() MentatTouch = // this needs a serious rewrite
{ // self - touched drug, other - player, e - other drugs
	local entity e;

	if ( other.classname != MOON_PLAYER_CLASSNAME ) { return; }
	if ( other.health <= 0 ) { return; }

	flash_target(other);
	sound(other, CHAN_ITEM, "moon/items/drug.wav", 1, ATTN_NORM);

	switch(self.prefix)
	{
	case MOON_MENTAT_OFFENSE_CODE:
		moon_print_mentat_offense(other);
		sprint(other, "\n");
		self.netname = MOON_MENTAT_OFFENSE_NETNAME;

		// TL;DR: effectively this renews expiration time of previous drug of same time
		while ( (e = find(e, classname, MOON_MENTAT_CLASSNAME)) )
		{
			if ( e.owner == other )
			{
				if ( e.mentat_bonus == MOON_ITEM_SOME )
				{
					e.attack_finished = (time + MENTAT_TIME);
					remove(self);
					return;
				}
			}
		}
		self.mentat_bonus = MOON_ITEM_SOME;
		other.mentat_bonus = MOON_ITEM_SOME;
		break;
	case MOON_MENTAT_DEFENSE_CODE:
		moon_print_mentat_defense(other);
		sprint(other, "\n");
		self.netname = MOON_MENTAT_DEFENSE_NETNAME;

		// TL;DR: effectively this renews expiration time of previous drug of same time
		while ( (e = find(e, classname, MOON_MENTAT_CLASSNAME)) )
		{
			if ( e.owner == other )
			{
				if ( e.mentat_bonus2 == MOON_ITEM_SOME )
				{
					e.attack_finished = (time + MENTAT_TIME);
					remove(self);
					return;
				}
			}
		}
		self.mentat_bonus2 = MOON_ITEM_SOME;
		other.mentat_bonus2 = MOON_ITEM_SOME;
		break;
	case MOON_MENTAT_SPEED_CODE:
		moon_print_mentat_speed(other);
		sprint(other, "\n");
		self.netname = MOON_MENTAT_SPEED_NETNAME;

		// TL;DR: effectively this renews expiration time of previous drug of same time
		while ( (e = find(e, classname, MOON_MENTAT_CLASSNAME)) )
		{
			if ( e.owner == other )
			{
				if ( e.mentat_bonus3 == MOON_ITEM_SOME )
				{
					e.attack_finished = (time + MENTAT_TIME);
					remove(self);
					return;
				}
			}
		}
		self.mentat_bonus3 = MOON_ITEM_SOME;
		other.mentat_bonus3 = MOON_ITEM_SOME;
		break;
	}

	self.solid = SOLID_NOT;
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
	setmodel(self, string_null);
	self.movetype = MOVETYPE_NONE;
	self.touch = SUB_Null;
	self.origin = VEC_ORIGIN;
	self.owner = other;
	self.attack_finished = (time + MENTAT_TIME);
	self.nextthink = (time + CHSCAM_ON);
	self.think = mentat_think;
};

void(entity who) moon_spawn_drop_drug =
{
	local entity item;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.gold = (CHSCAM_ON + (random() * 125));
	item.owner = who;
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	item.classname = MOON_MENTAT_CLASSNAME;
	setmodel(item, "progs/drugs.mdl");
	item.prefix = random_int(MOON_MENTAT_OFFENSE_CODE, MOON_MENTAT_SPEED_CODE);
	item.skin = (item.prefix - 1);
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = MentatTouch;
	item.nextthink = (time + 60);
	item.think = SUB_Remove;
};

void(entity who) moon_spawn_drop_weapon =
{
	local float r;
	local entity item;

	r = random();
	item = spawn();
	item.origin = (who.origin - '0 0 24');
	if ((r < 0.15))
	{
		setmodel(item, "progs/g_shot.mdl");
		item.ammo_shells = rint((random() * MOON_WEAPON_SUPERSHOTGUN_AMMO_LOOT_RANDOM) + MOON_WEAPON_SUPERSHOTGUN_AMMO_LOOT_MIN);
		item.netname = MOON_WEAPON_SUPERSHOTGUN_DISPLAYNAME;
		item.items = IT_SUPER_SHOTGUN;
	} else
	if ((r < 0.3))
	{
		setmodel(item, "progs/g_nail.mdl");
		item.ammo_nails = rint((random() * MOON_WEAPON_NAILGUN_AMMO_LOOT_RANDOM) + MOON_WEAPON_NAILGUN_AMMO_LOOT_MIN);
		item.netname = MOON_WEAPON_NAILGUN_DISPLAYNAME;
		item.items = IT_NAILGUN;
	} else
	if ((r < 0.45))
	{
		setmodel(item, "progs/g_nail2.mdl");
		item.ammo_nails = rint((random() * MOON_WEAPON_SUPERNAILGUN_AMMO_LOOT_RANDOM) + MOON_WEAPON_SUPERNAILGUN_AMMO_LOOT_MIN);
		item.netname = MOON_WEAPON_SUPERNAILGUN_DISPLAYNAME;
		item.items = IT_SUPER_NAILGUN;
	} else
	if ((r < 0.6))
	{
		setmodel(item, "progs/g_rock.mdl");
		item.ammo_rockets = rint((random() * MOON_WEAPON_GRENADELAUNCHER_AMMO_LOOT_RANDOM) + MOON_WEAPON_GRENADELAUNCHER_AMMO_LOOT_MIN);
		item.netname = MOON_WEAPON_GRENADELAUNCHER_DISPLAYNAME;
		item.items = IT_GRENADE_LAUNCHER;
	} else
	if ((r < 0.8))
	{
		setmodel(item, "progs/g_rock2.mdl");
		item.ammo_rockets = rint((random() * MOON_WEAPON_ROCKETLAUNCHER_AMMO_LOOT_RANDOM) + MOON_WEAPON_ROCKETLAUNCHER_AMMO_LOOT_MIN);
		item.netname = MOON_WEAPON_ROCKETLAUNCHER_DISPLAYNAME;
		item.items = IT_ROCKET_LAUNCHER;
	} else {
		setmodel(item, "progs/g_light.mdl");
		item.ammo_cells = rint((random() * MOON_WEAPON_LIGHTNING_AMMO_LOOT_RANDOM) + MOON_WEAPON_LIGHTNING_AMMO_LOOT_MIN);
		item.netname = MOON_WEAPON_LIGHTNING_DISPLAYNAME;
		item.items = IT_LIGHTNING;
	}

	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.owner = who;
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = weapon_touch;
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_NORMAL);
	item.think = SUB_Remove;
};

void(entity who) DropPLGold =
{
	local entity item;

	if ( who.classname != MOON_PLAYER_CLASSNAME ) { return; }
	if ( self.gold <= 0 ) { return; }

	item = spawn();
	item.gold = who.gold;
	item.origin = (who.origin - '0 0 24');
	item.velocity_z = 350;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.owner = who;
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel(item, "progs/gold.mdl");
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = GoldTouch;
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_NORMAL);
	item.think = SUB_Remove;
};

void(entity who) DropGold =
{
	local entity item;
	local float bngld;
	local float player_maxlvl;

	player_maxlvl = moon_get_max_player_level();
	item = spawn();
	if ( who.classname == MOON_GOLD_MINE_CLASSNAME )
	{
		item.origin = (who.origin + '0 0 8');
		item.gold = ((MOON_GOLD_MINE_BASE + (MOON_GOLD_MINE_LVLPERCENT * player_maxlvl)) + (random() * (MOON_GOLD_MINE_RANDOM + (player_maxlvl * MOON_GOLD_MINE_BASE))));
	} else {
		item.origin = (who.origin - '0 0 24');
		item.gold = ((MOON_GOLD_LOOT_BASE + (MOON_GOLD_LOOT_LVLPERCENT * player_maxlvl)) + (random() * MOON_GOLD_LOOT_RANDOM));
	}
	item.gold = ceil(item.gold);

	if ( who.prefix == MOON_CREEP_GOLD_PREFIX_CODE )
	{
		item.gold = (item.gold + percent(item.gold, who.prefix_value));
	}
	item.gold = (item.gold + percent(item.gold, up_gold_value));

	bngld = moon_target_bonus_by_code(who.killer, MOON_ITEM_GOLD_CODE);
	item.gold = (item.gold + percent(item.gold, bngld));

	item.velocity_z = 350;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.owner = who;
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel(item, "progs/gold.mdl");
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = GoldTouch;
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_NORMAL);
	item.think = SUB_Remove;
};

void(entity who) DropAmmo =
{
	local entity item;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.gold = (1 + (random() * 125)); // why the fuck?
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	if ((random() < 0.3))
	{
		setmodel(item, "maps/b_shell0.bsp");
		item.ammo_shells = ceil(MOON_AMMO_SHELLS_LOOT_MIN + (random() * MOON_AMMO_SHELLS_LOOT_RANDOM));
	} else
	if ((random() < 0.6))
	{
		setmodel(item, "maps/b_nail0.bsp");
		item.ammo_nails = ceil(MOON_AMMO_NAILS_LOOT_MIN + (random() * MOON_AMMO_NAILS_LOOT_RANDOM));
	} else
	if ((random() < 0.8))
	{
		setmodel(item, "maps/b_rock0.bsp");
		item.ammo_rockets = ceil(MOON_AMMO_ROCKETS_LOOT_MIN + (random() * MOON_AMMO_ROCKETS_LOOT_RANDOM));
	} else {
		setmodel(item, "maps/b_batt0.bsp");
		item.ammo_cells = ceil(MOON_AMMO_CELLS_LOOT_MIN + (random() * MOON_AMMO_CELLS_LOOT_RANDOM));
	}

	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = ammo_touch;
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_NORMAL);
	item.think = SUB_Remove;
};

void() DropItem =
{
	local entity e;

	self.think = SUB_Null;
	self.nextthink = 0;
	if ((self.scroll_shaf_eff > time)) // Implement
	{
		shaf_eff();
	}
	if ((self.scroll_infe_eff > time)) // Implement
	{
		infe_eff();
	}

	if ( self.prefix == MOON_CREEP_BOMB_PREFIX_CODE )
	{
		e = spawn();
		e.origin = self.origin;
		T_RadiusDamage(e, self, self.prefix_value, e);
		sound(e, CHAN_VOICE, "weapons/r_exp3.wav", CHSCAM_ON, ATTN_NORM);
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_EXPLOSION);
		WriteCoord(MSG_BROADCAST, e.origin_x);
		WriteCoord(MSG_BROADCAST, e.origin_y);
		WriteCoord(MSG_BROADCAST, e.origin_z);
		setmodel(e, "progs/s_explod.spr");
		e.solid = SOLID_NOT;
		e.think = s_explode1;
		e.nextthink = time;
	}

	if ( self.prefix == MOON_CREEP_GOLD_PREFIX_CODE )
	{
		DropGold(self);
		return;
	}
	if ((random() < 0.0035))
	{
		DropBookUpgrade(self);
		return;
	} else {
		if ((random() < 0.0125))
		{
			DropBookByCode(self, MOON_ITEM_GLOBALGOLD_CODE);
			return;
		}
		if ((random() < 0.0125))
		{
			DropBookByCode(self, MOON_ITEM_HEART_CODE);
			return;
		}
	}
	if ((random() < 0.025))
	{
		DropMagicArmor(self);
		return;
	}
	if ((random() < 0.015))
	{
		moon_spawn_drop_elixir(self);
		return;
	}
	if ((random() < MON_MAGICCHANCE))
	{
		moon_spawn_drop_weapon(self);
		return;
	}
	if ((random() < MON_MAGICCHANCE))
	{
		moon_spawn_drop_armor_shard(self);
		return;
	}
	if ((random() < 0.025))
	{
		moon_spawn_drop_drug(self);
		return;
	}
	if ((random() < MON_UNIQUECHANCE))
	{
		moon_spawn_drop_potion(self);
		return;
	}
	if ((random() < MON_REACTIONTIME))
	{
		DropAmmo(self);
		return;
	}
	if ((random() < MON_BACKTIME))
	{
		DropGold(self);
		return;
	}
};

float(float l, float was) exp_table =
{
	return (was + (l * MOON_NEXTLEVEL_MORE_PLAYERLEVEL_TIMES * MOON_NEXTLEVEL_MORE_SCALING_FACTOR) );
};

void(entity target) level_up_target =
{
	target.lvl = target.lvl + 1; // Increase level first
	target.nextexp = exp_table(target.lvl, target.nextexp); // Increase requirement with updated level
	target.frags = target.lvl;

	if ((target.health > 0))
	{
		if ((target.health < target.max_health))
		{
			target.health = target.max_health;
		}
	}

	if (!(target.items & IT_KEY1))
	{
		target.items = (target.items + IT_KEY1);
	}
	if ((target.lvl <= MOON_PLAYER_LEVEL_GROW_FAST))
	{
		target.point = (target.point + MOON_PLAYER_POINT_GROW_FAST);
	} else {
		if ((target.lvl <= MOON_PLAYER_LEVEL_GROW_NORMAL))
		{
			target.point = (target.point + MOON_PLAYER_POINT_GROW_NORMAL);
		} else {
			target.point = (target.point + MOON_PLAYER_POINT_GROW_SLOW);
		}
	}

	sound(target, CHAN_BODY, "moon/misc/levelup.wav", 1, ATTN_NORM);
	sprint(target, "=== Level Up! ===\n");
	sprint(target, "You are now level {}\n", quick_ftos(target.lvl));
	sprint(target, "Get {} experience for the next Level.\n", quick_ftos(target.nextexp));

	if (target.cl_nohelp == 0)
	{
		if (target.lvl < 4)
		{
			sprint(target, "use `stats` command to check and upgrade your stats\n");
		}
	}
	if (target.lvl >= MOON_PLAYER_MAX_LEVEL)
	{
		sprint(target, "Congratulations! You \swon\s the game.\n");
		intermission_victory();
	}
	sprint(target, "-----------------\n");
};

void(entity heart) level_up_heart =
{
	SpawnBot();
	if (heart != world)
	{
		if (heart.lvl < MOON_HEART_MAX_LEVEL)
		{
			heart.lvl = heart.lvl + 1; // Increase level first
			heart.nextexp = exp_table(heart.lvl, heart.nextexp); // Increase requirement with updated level

			heart.max_health = (heart.max_health + MOON_HEART_HEALTH_GROW);
			heart.health = (heart.health + MOON_HEART_HEALTH_GROW);
			if (heart.health > heart.max_health)
			{
				heart.health = heart.max_health;
			}
		} else { // full heal on consequent level-ups after max. Should not happen in normal game
			if (heart.health > 0)
			{
				heart.health = heart.max_health;
			}
		}
	}
};

void() GiveExp =
{
	local entity e;
	local entity heart;

	if (gameover)
	{
		return;
	}

	heart = find(world, classname, MOON_HEART_CLASSNAME);
	if (heart != world)
	{
		heart.exp = (heart.exp + self.exp);
		if (heart.exp >= heart.nextexp)
		{
			level_up_heart(heart);
		}
	}

	e = find(world, classname, MOON_PLAYER_CLASSNAME);
	while (e)
	{
		e.exp = (e.exp + self.exp);
		if (e.exp >= e.nextexp)
		{
			level_up_target(e);
		}
		e = find(e, classname, MOON_PLAYER_CLASSNAME);
	}
};
