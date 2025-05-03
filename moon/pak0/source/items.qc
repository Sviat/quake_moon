//Decompiled code. Please respect the original copyright.
float H_ROTTEN    = 1;
float H_MEGA      = 2;
.float healamount;
.float healtype;

void() W_SetCurrentAmmo;
void() health_touch;
void() item_megahealth_rot;

float(entity target, float healamount, float ignore = 0) T_Heal = // Player heal only!
{
	if ((target.health <= 0))
	{
		return (0);
	}
	if ((!ignore && (target.health >= target.max_health)))
	{
		return (0);
	}

	healamount = ceil(healamount);
	target.health = (target.health + healamount);
	if ((!ignore && (target.health >= target.max_health)))
	{
		target.health = target.max_health;
	}
	target.health = clamp(target.health, CONST_QC_DISPLAY_MAX); //  If Monster heal will be necessary in future, change that
	return (1);
};

float(entity e, float healamount) T_Overheal = // may be put overheal rot here?
{
	if ( e.health <= 0 )
	{
		return FALSE;
	}

	healamount = ceil(healamount);
	e.health = clamp( (e.health + healamount), CONST_QC_DISPLAY_MAX);

	return TRUE;
};

void(entity e, float healamount) moon_heal_target_monster =
{
	e.health = e.health + healamount;
	if ( e.health > e.max_health )
	{
		e.health = e.max_health;
	}
};

float(entity e, float healamount) T_Mana =
{
	if ((e.mana >= e.max_mana))
	{
		return FALSE;
	}

	healamount = ceil(healamount);
	e.mana = (e.mana + healamount);
	if ((e.mana >= e.max_mana))
	{
		e.mana = e.max_mana;
	}
	e.mana = clamp(e.mana, CONST_QC_DISPLAY_MAX);
	return TRUE;
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

	sprint(target, "You paid {0} gold, {1} left\n", floor_ftos(cost), floor_ftos(target.gold));
	return TRUE;
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
		moon_println_all_other_health(heart);
	}
};

float(entity target, float code) moon_get_target_total_bonus_by_code =
{
	local float bonus;
	bonus = 0;
	if ( target.magic_typeone == code )
	{
		bonus = (bonus + target.magic_typeone_value);
	}
	if ( target.magic_typetwo == code )
	{
		bonus = (bonus + target.magic_typetwo_value);
	}
	if ( target.ring_typeone == code )
	{
		bonus = (bonus + target.ring_typeone_value);
	}
	if ( target.ring_typetwo == code )
	{
		bonus = (bonus + target.ring_typetwo_value);
	}
	return bonus;
};

float(entity target) moon_get_target_bonus_health =
{
	return moon_get_target_total_bonus_by_code(target, MOON_ITEM_HEALTH_CODE);
};

float(entity target) moon_get_target_bonus_damage =
{
	return moon_get_target_total_bonus_by_code(target, MOON_ITEM_DAMAGE_CODE);
};

void(entity target, float value) moon_raise_target_max_health =
{
	target.max_health = (target.max_health + value);
	target.max_health = clampd(MOON_STAT_MAXHEALTH_MIN, target.max_health, CONST_QC_DISPLAY_MAX);
	if (value > 0)
	{
		T_Heal(target, value);
	}
};

void(entity target, float value) moon_raise_target_max_mana =
{
	target.max_mana = (target.max_mana + value);
	target.max_mana = clampd(MOON_STAT_MAXMANA_MIN, target.max_mana, CONST_QC_DISPLAY_MAX);
	if (value > 0)
	{
		T_Mana(target, value);
	}
};

void(entity target, float value = 1) moon_raise_target_vitality =
{
	target.vit = (target.vit + value);
	moon_raise_target_max_health(target, (value*MOON_STAT_HEALTH_PER_VITALITY));
};

void(entity target, float value = 1) moon_raise_target_strength = // This is not necessary so far, but for consistency
{
	target.stre = (target.stre + value);
};

void(entity target, float value = 1) moon_raise_target_sanity =
{
	target.wiz = (target.wiz + value);
	moon_raise_target_max_mana(target, (value*MOON_STAT_MANA_PER_SANITY));
};

void(entity target, float value = 1) moon_raise_target_intuition = // This is not necessary so far, but for consistency
{
	target.intu = (target.intu + value);
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
	self.nextthink = (time + 0.2);
	self.think = PlaceItem;
};

// UNUSED?!
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

// UNUSED?!
void() health_touch =
{
	if ( other.classname != MOON_PLAYER_CLASSNAME ) { return; }

	if ( self.healtype == MOON_MEDKIT_MEGA_TYPE )
	{
		if ( other.health >= (other.max_health + MOON_MEDKIT_MEGA_OVERHEAL_HARDLIMIT) )
		{
			return;
		}
		if (!T_Overheal(other, self.healamount))
		{
			return;
		}
	} else {
		if (!T_Heal(other, self.healamount))
		{
			return;
		}
	}
	sprint(other, "You receive {} health\n", floor_ftos(self.healamount));
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	flash_target(other);

	self.model = string_null;
	self.solid = SOLID_NOT;
	if ( self.healtype == MOON_MEDKIT_MEGA_TYPE )
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
	if ( other.health > other.max_health )
	{
		other.health = (other.health - 1);
		self.nextthink = (time + 1);
		return;
	}
	other.items = (other.items & (~IT_SUPERHEALTH));
	remove(self);
};

// UNUSED?!
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

// UNUSED?!
void() item_armor1 =
{
	self.touch = armor_touch;
	precache_model("progs/armor.mdl");
	setmodel(self, "progs/armor.mdl");
	self.skin = 0;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

// UNUSED?!
void() item_armor2 =
{
	self.touch = armor_touch;
	precache_model("progs/armor.mdl");
	setmodel(self, "progs/armor.mdl");
	self.skin = 1;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

// UNUSED?!
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
	local float max_cells;
	local float max_rockets;

	max_shells = clampd( MOON_AMMO_MAX_SHELL, (MOON_AMMO_MAX_SHELL + (target.up_bullet * MOON_ITEM_SHELLUP_SIDEEFFECT_BONUS)), CONST_QC_DISPLAY_MAX);
	max_nails = clampd( MOON_AMMO_MAX_NAIL, (MOON_AMMO_MAX_NAIL + (target.up_nail * MOON_ITEM_NAILUP_SIDEEFFECT_BONUS)), CONST_QC_DISPLAY_MAX);
	max_rockets = clampd( MOON_AMMO_MAX_ROCKET, (MOON_AMMO_MAX_ROCKET + (target.up_rocket * MOON_ITEM_ROCKUP_SIDEEFFECT_BONUS)), CONST_QC_DISPLAY_MAX);
	max_cells = clampd( MOON_AMMO_MAX_CELL, (MOON_AMMO_MAX_CELL + (target.up_cell * MOON_ITEM_CELLUP_SIDEEFFECT_BONUS)), CONST_QC_DISPLAY_MAX);

	target.ammo_shells = clamp(target.ammo_shells, max_shells);
	target.ammo_nails = clamp(target.ammo_nails, max_nails);
	target.ammo_rockets = clamp(target.ammo_rockets, max_rockets);
	target.ammo_cells = clamp(target.ammo_cells, max_cells);

	target.currentammo = clamp(target.currentammo, CONST_QC_DISPLAY_MAX);
};

float(float w) RankForWeapon =
{
	if ((w == IT_LIGHTNING))
	{
		return (1);
	}
	if ((w == IT_ROCKET_LAUNCHER))
	{
		return (2);
	}
	if ((w == IT_SUPER_NAILGUN))
	{
		return (3);
	}
	if ((w == IT_GRENADE_LAUNCHER))
	{
		return (4);
	}
	if ((w == IT_SUPER_SHOTGUN))
	{
		return (5);
	}
	if ((w == IT_NAILGUN))
	{
		return (6);
	}
	return (7);
};

// UNUSED?!
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

// UNUSED?!
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

// UNUSED?!
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

// UNUSED?!
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

// UNUSED?!
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

// UNUSED?!
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

// UNUSED?!
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
		sprint(other, "You picked up {0} {1}\n", floor_ftos(self.ammo_shells), MOON_AMMO_SHELLS_DISPLAYNAME);
	}
	if (self.ammo_nails)
	{
		sprint(other, "You picked up {0} {1}\n", floor_ftos(self.ammo_nails), MOON_AMMO_NAILS_DISPLAYNAME);
	}
	if (self.ammo_rockets)
	{
		sprint(other, "You picked up {0} {1}\n", floor_ftos(self.ammo_rockets), MOON_AMMO_ROCKETS_DISPLAYNAME);
	}
	if (self.ammo_cells)
	{
		sprint(other, "You picked up {0} {1}\n", floor_ftos(self.ammo_cells), MOON_AMMO_CELLS_DISPLAYNAME);
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
	local float best;
	local float old;
	local float new;
	local entity stemp;

	if ( other.classname != MOON_PLAYER_CLASSNAME ) { return; }
	if ( other.health <= 0 ) { return; }

	stemp = self;
	self = other;
	best = W_BestWeapon(); // remember best weapon before getting ammo
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

	flash_target(other);
	sprint(other, "You get {} with ", self.netname);
	if (self.ammo_shells)
	{
		sprint(other, " {0} {1}", floor_ftos(self.ammo_shells), MOON_AMMO_SHELLS_DISPLAYNAME);
	}
	if (self.ammo_nails)
	{
		sprint(other, " {0} {1}", floor_ftos(self.ammo_nails), MOON_AMMO_NAILS_DISPLAYNAME);
	}
	if (self.ammo_rockets)
	{
		sprint(other, " {0} {1}", floor_ftos(self.ammo_rockets), MOON_AMMO_ROCKETS_DISPLAYNAME);
	}
	if (self.ammo_cells)
	{
		sprint(other, " {0} {1}", floor_ftos(self.ammo_cells), MOON_AMMO_CELLS_DISPLAYNAME);
	}
	sprint(other, "\n");
	sound(other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);

	remove(self);
	self = other;
	if (!deathmatch)
	{
		self.weapon = new;
	} else {
		Deathmatch_Weapon(old, new);
	}
	W_SetCurrentAmmo();
};

void() DropBackpack =
{
	local entity item;

	if ( (self.weapon == IT_AXE) || (self.weapon == IT_SHOTGUN) )
	{
		return;
	}

	item = spawn();
	item.origin = (self.origin - '0 0 24');
	item.items = self.weapon;

	switch(item.items)
	{
	case IT_SUPER_SHOTGUN:
		item.ammo_shells = self.ammo_shells;
		item.currentammo = item.ammo_shells;
		item.netname = MOON_WEAPON_SUPERSHOTGUN_DISPLAYNAME;
		setmodel(item, MOON_WEAPON_SUPERSHOTGUN_MODEL_TPV);
		break;
	case IT_NAILGUN:
		item.ammo_nails = self.ammo_nails;
		item.currentammo = item.ammo_nails;
		item.netname = MOON_WEAPON_NAILGUN_DISPLAYNAME;
		setmodel(item, MOON_WEAPON_NAILGUN_MODEL_TPV);
		break;
	case IT_SUPER_NAILGUN:
		item.ammo_nails = self.ammo_nails;
		item.currentammo = item.ammo_nails;
		item.netname = MOON_WEAPON_SUPERNAILGUN_DISPLAYNAME;
		setmodel(item, MOON_WEAPON_SUPERNAILGUN_MODEL_TPV);
		break;
	case IT_GRENADE_LAUNCHER:
		item.ammo_rockets = self.ammo_rockets;
		item.currentammo = item.ammo_rockets;
		item.netname = MOON_WEAPON_GRENADELAUNCHER_DISPLAYNAME;
		setmodel(item, MOON_WEAPON_GRENADELAUNCHER_MODEL_TPV);
		break;
	case IT_ROCKET_LAUNCHER:
		item.ammo_rockets = self.ammo_rockets;
		item.currentammo = item.ammo_rockets;
		item.netname = MOON_WEAPON_ROCKETLAUNCHER_DISPLAYNAME;
		setmodel(item, MOON_WEAPON_ROCKETLAUNCHER_MODEL_TPV);
		break;
	case IT_LIGHTNING:
		item.ammo_cells = self.ammo_cells;
		item.currentammo = item.ammo_cells;
		item.netname = MOON_WEAPON_LIGHTNING_DISPLAYNAME;
		setmodel(item, MOON_WEAPON_LIGHTNING_MODEL_TPV);
		break;
	default:
		dprint("ERROR: Incorrect weapon in DropBackpack()\n");
		remove(item);
		return;
	}

	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = BackpackTouch;
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_IMPORTANT);
	item.think = SUB_Remove;
};

void() aura_think =
{
	if ( self.owner.health <= 0 )
	{
		remove(self);
		return;
	}
	if ( self.owner == world )
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
	a.skin = 0;
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
		e.prefix = MOON_MONSTER_TRAIT_DOUBLEDAMAGE;
		e.prefix_three = MOON_MONSTER_TRAIT_DOUBLEDAMAGE_LOW_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_DOUBLEDAMAGE_LOW_PROC;
		e.exp = rint(e.exp * MOON_MONSTER_BOUNTY_EXP_MULT_LOW);
		makeaura(e, MOON_MONSTER_TRAIT_AURA_TYPE_DOUBLEDAMAGE);
		break;
	case 2:
		e.prefix = MOON_MONSTER_TRAIT_DOUBLEDAMAGE;
		e.prefix_three = MOON_MONSTER_TRAIT_DOUBLEDAMAGE_NORMAL_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_DOUBLEDAMAGE_NORMAL_PROC;
		e.exp = rint(e.exp * MOON_MONSTER_BOUNTY_EXP_MULT_NORMAL);
		makeaura(e, MOON_MONSTER_TRAIT_AURA_TYPE_DOUBLEDAMAGE);
		break;
	case 3:
		e.prefix = MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE;
		e.prefix_three = MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE_LOW_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE_LOW_PROC;
		e.exp = rint(e.exp * MOON_MONSTER_BOUNTY_EXP_MULT_LOW);
		break;
	case 4:
		e.prefix = MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE;
		e.prefix_three = MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE_NORMAL_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE_NORMAL_PROC;
		e.health = (e.health * 2.5);
		e.exp = rint(e.exp * MOON_MONSTER_BOUNTY_EXP_MULT_HIGH);
		break;
	case 5:
		e.prefix = MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE;
		e.prefix_three = MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE_HUGE_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_ABSORBHALFDAMAGE_HUGE_PROC;
		e.exp = rint(e.exp * MOON_MONSTER_BOUNTY_EXP_MULT_HUGE);
		break;
	case 6:
		e.prefix = MOON_MONSTER_TRAIT_REDUCED_HEALTH; // prefix since 0.29
		e.prefix_three = MOON_MONSTER_TRAIT_REDUCED_HEALTH_DISPLAY;
		e.health = rint(e.health * MOON_MONSTER_TRAIT_REDUCED_HEALTH_MULTIPLIER);
		break;
	case 7:
		e.prefix = MOON_MONSTER_TRAIT_EXTRA_BOUNTY_EXP; // prefix since 0.29
		e.prefix_three = MOON_MONSTER_TRAIT_EXTRA_BOUNTY_EXP_DISPLAY;
		e.exp = rint(e.exp * MOON_MONSTER_BOUNTY_EXP_MULT_NORMAL);
		break;
	case 8:
		e.prefix = MOON_MONSTER_TRAIT_LOWHEALTH; // prefix since 0.29
		e.prefix_three = MOON_MONSTER_TRAIT_LOWHEALTH_DISPLAY;
		e.health = MOON_MONSTER_TRAIT_LOWHEALTH_VALUE;
		e.exp = MOON_MONSTER_BOUNTY_EXP_BAREMINIMUM;
		break;
	case 9:
		e.prefix = MOON_MONSTER_TRAIT_HUNTER; // unused, unknown
		e.prefix_three = MOON_MONSTER_TRAIT_HUNTER_LOW_DISPLAY;
		break;
	case 10:
		e.prefix = MOON_MONSTER_TRAIT_HUNTER; // unused, unknown
		e.prefix_three = MOON_MONSTER_TRAIT_HUNTER_NORMAL_DISPLAY;
		break;
	case 11:
		e.prefix = MOON_MONSTER_TRAIT_REGEN; // unused
		e.prefix_three = MOON_MONSTER_TRAIT_REGEN_LOW_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_REGEN_LOW_VALUE;
		break;
	case 12:
		e.prefix = MOON_MONSTER_TRAIT_REGEN; // unused
		e.prefix_three = MOON_MONSTER_TRAIT_REGEN_NORMAL_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_REGEN_NORMAL_VALUE;
		break;
	case 13:
		e.prefix = MOON_MONSTER_TRAIT_EXTRA_GOLD;
		e.prefix_three = MOON_MONSTER_TRAIT_EXTRA_GOLD_LOW_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_EXTRA_GOLD_LOW_VALUE;
		break;
	case 14:
		e.prefix = MOON_MONSTER_TRAIT_EXTRA_GOLD;
		e.prefix_three = MOON_MONSTER_TRAIT_EXTRA_GOLD_NORMAL_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_EXTRA_GOLD_NORMAL_VALUE;
		break;
	case 15:
		e.prefix = MOON_MONSTER_TRAIT_EXTRA_GOLD;
		e.prefix_three = MOON_MONSTER_TRAIT_EXTRA_GOLD_HIGH_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_EXTRA_GOLD_HIGH_VALUE;
		break;
	case 16:
		e.prefix = MOON_MONSTER_TRAIT_SUICIDE;
		e.prefix_three = MOON_MONSTER_TRAIT_SUICIDE_LOW_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_SUICIDE_LOW_VALUE;
		break;
	case 17:
		e.prefix = MOON_MONSTER_TRAIT_SUICIDE;
		e.prefix_three = MOON_MONSTER_TRAIT_SUICIDE_NORMAL_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_SUICIDE_NORMAL_VALUE;
		break;
	case 18:
		e.prefix = MOON_MONSTER_TRAIT_SUICIDE;
		e.prefix_three = MOON_MONSTER_TRAIT_SUICIDE_HIGH_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_SUICIDE_HIGH_VALUE;
		break;
	case 19:
		e.prefix = MOON_MONSTER_TRAIT_EXTRA_DAMAGE;
		e.prefix_three = MOON_MONSTER_TRAIT_EXTRA_DAMAGE_LOW_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_EXTRA_DAMAGE_LOW_BONUSPERCENT;
		e.exp = rint(e.exp * MOON_MONSTER_BOUNTY_EXP_MULT_LOW);
		makeaura(e, MOON_MONSTER_TRAIT_AURA_TYPE_EXTRADAMAGE);
		break;
	case 20:
		e.prefix = MOON_MONSTER_TRAIT_EXTRA_DAMAGE;
		e.prefix_three = MOON_MONSTER_TRAIT_EXTRA_DAMAGE_NORMAL_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_EXTRA_DAMAGE_NORMAL_BONUSPERCENT;
		e.exp = rint(e.exp * MOON_MONSTER_BOUNTY_EXP_MULT_NORMAL);
		makeaura(e, MOON_MONSTER_TRAIT_AURA_TYPE_EXTRADAMAGE);
		break;
	case 21:
		e.prefix = MOON_MONSTER_TRAIT_EXTRA_DAMAGE;
		e.prefix_three = MOON_MONSTER_TRAIT_EXTRA_DAMAGE_HIGH_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_EXTRA_DAMAGE_HIGH_BONUSPERCENT;
		e.exp = rint(e.exp * MOON_MONSTER_BOUNTY_EXP_MULT_HIGH);
		makeaura(e, MOON_MONSTER_TRAIT_AURA_TYPE_EXTRADAMAGE);
		break;
	case 22:
		e.prefix = MOON_MONSTER_TRAIT_EXTRA_DAMAGE;
		e.prefix_three = MOON_MONSTER_TRAIT_EXTRA_DAMAGE_HUGE_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_EXTRA_DAMAGE_HUGE_BONUSPERCENT;
		e.exp = rint(e.exp * MOON_MONSTER_BOUNTY_EXP_MULT_HUGE);
		makeaura(e, MOON_MONSTER_TRAIT_AURA_TYPE_EXTRADAMAGE);
		break;
	case 23:
		e.prefix = MOON_MONSTER_TRAIT_RESISTANCE;
		e.prefix_three = MOON_MONSTER_TRAIT_RESISTANCE_LOW_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_RESISTANCE_LOW_BONUSPERCENT;
		e.exp = rint(e.exp * MOON_MONSTER_BOUNTY_EXP_MULT_LOW);
		break;
	case 24:
		e.prefix = MOON_MONSTER_TRAIT_RESISTANCE;
		e.prefix_three = MOON_MONSTER_TRAIT_RESISTANCE_NORMAL_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_RESISTANCE_NORMAL_BONUSPERCENT;
		e.exp = rint(e.exp * MOON_MONSTER_BOUNTY_EXP_MULT_NORMAL);
		break;
	case 25:
		e.prefix = MOON_MONSTER_TRAIT_RESISTANCE;
		e.prefix_three = MOON_MONSTER_TRAIT_RESISTANCE_HIGH_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_RESISTANCE_HIGH_BONUSPERCENT;
		e.exp = rint(e.exp * MOON_MONSTER_BOUNTY_EXP_MULT_HIGH);
		break;
	case 26:
		e.prefix = MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE;
		e.prefix_three = MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE_LOW_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE_LOW_BONUSPERCENT;
		break;
	case 27:
		e.prefix = MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE;
		e.prefix_three = MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE_NORMAL_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE_NORMAL_BONUSPERCENT;
		break;
	case 28:
		e.prefix = MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE;
		e.prefix_three = MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE_HIGH_DISPLAY;
		e.prefix_value = MOON_MONSTER_TRAIT_EXTRA_RECEIVEDAMAGE_HIGH_BONUSPERCENT;
		e.exp = MOON_MONSTER_BOUNTY_EXP_BAREMINIMUM;
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
	self.think = do_earthquake;
	self.nextthink = ((time + 0.2) - (random() * 0.1));
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

void() misc_head = // ctor() of something
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

void() moon4_touch = // Works - dont touch. 500 lines of pure pleasure
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

void() PlaceWeapon = // TODO: refactor next
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

void() moon_market_place_armor =
{
	local entity e;
	local float r;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = MOON_TRADE_MARKET_SPOT_CLASSNAME;
	e.netname = MOON_ARMOR_MARKET_NETNAME;
	e.noise1 = "items/armor1.wav";
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);

	r = random();
	if ( r < 0.36 )
	{
		moon_init_target_as_armor(e, MOON_ARMOR_GREEN_CODE, (MOON_ARMOR_GREEN_MARKET_DURABILITY_MIN + rint(random() * MOON_ARMOR_GREEN_MARKET_DURABILITY_RANDOM)));
		e.cost = rint( e.armorvalue * MOON_ARMOR_GREEN_MARKET_COSTOFONE );
		e.targetname = MOON_ARMOR_GREEN_MARKET_DISPLAYNAME;
	} else
	if ((r < 0.7))
	{
		moon_init_target_as_armor(e, MOON_ARMOR_YELLOW_CODE, (MOON_ARMOR_YELLOW_MARKET_DURABILITY_MIN + rint(random() * MOON_ARMOR_YELLOW_MARKET_DURABILITY_RANDOM)));
		e.cost = rint( e.armorvalue * MOON_ARMOR_YELLOW_MARKET_COSTOFONE );
		e.targetname = MOON_ARMOR_YELLOW_MARKET_DISPLAYNAME;
	} else {
		moon_init_target_as_armor(e, MOON_ARMOR_RED_CODE, (MOON_ARMOR_RED_MARKET_DURABILITY_MIN + rint(random() * MOON_ARMOR_RED_MARKET_DURABILITY_RANDOM)));
		e.cost = rint( e.armorvalue * MOON_ARMOR_RED_MARKET_COSTOFONE );
		e.targetname = MOON_ARMOR_RED_MARKET_DISPLAYNAME;
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
		case MOON_ITEM_REPAIR_CODE 	: return (effect_value * MOON_ITEM_REPAIR_MARKET_COST_SCALE);
		case MOON_ITEM_RECHARGE_CODE: return (effect_value * MOON_ITEM_RECHARGE_MARKET_COST_SCALE);
		default: return 42; // should not happen
	}
};

void() moon_market_place_ammo =
{
	local entity e;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, (((self.origin + (v_forward * 47)) - '0 0 24') + (v_right * KEY_MOVERIGHT)));
	e.solid = SOLID_NOT;
	e.classname = MOON_TRADE_MARKET_SPOT_CLASSNAME;
	e.netname = MOON_AMMO_MARKET_NETNAME;
	e.skin = 0;
	setmodel(e, s_wiz);
	e.noise1 = "weapons/lock4.wav";
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);

	if ((random() < MOON_AMMO_MARKET_ROCKET_VS_CELL_RATIO))
	{
		setmodel(e, MOON_AMMO_ROCKETS_MODEL);
		e.ammo_rockets = ceil( MOON_AMMO_ROCKETS_MARKET_MIN + (random() * MOON_AMMO_ROCKETS_MARKET_RANDOM) );
		e.currentammo = e.ammo_rockets;
		e.cost = ceil(e.currentammo * MOON_AMMO_ROCKETS_MARKET_COSTOFONE);
		e.targetname = MOON_AMMO_ROCKETS_DISPLAYNAME;
	} else {
		setmodel(e, MOON_AMMO_CELLS_MODEL);
		e.ammo_cells = ceil( MOON_AMMO_CELLS_MARKET_MIN + (random() * MOON_AMMO_CELLS_MARKET_RANDOM) );
		e.currentammo = e.ammo_cells;
		e.cost = ceil(e.currentammo * MOON_AMMO_CELLS_MARKET_COSTOFONE);
		e.targetname = MOON_AMMO_CELLS_DISPLAYNAME;
	}
};

void() moon_market_place_elixir =
{
	local entity e;
	local float code;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = MOON_TRADE_MARKET_SPOT_CLASSNAME;
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
			e.cost = 3000; // TODO: lower base price but multply by 100%+GoldBonus to take inflation into account
			break;
		case MOON_ELIXIR_VIT_CODE:
			e.targetname = MOON_ELIXIR_VIT_NAME;
			e.healtype = MOON_ELIXIR_VIT_CODE;
			e.cost = 2000; // TODO: lower base price but multply by 100%+GoldBonus to take inflation into account
			break;
	}
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);
};

void(entity e) moon_calculate_magic_cost =
{
	local float ccost;

	ccost = MOON_ITEM_MARKET_COST_BASE;
	ccost = ccost + moon_calculate_effect_cost(e.magic_typeone, e.magic_typeone_value);
	ccost = ccost + moon_calculate_effect_cost(e.magic_typetwo, e.magic_typetwo_value);

	e.cost = ccost;
};

float(float level) moon_generate_trait_quality =
{
	return level * MOON_ITEM_TRAIT_QUALITY_MULTIPLIER_LEVEL
		 + random() * MOON_ITEM_TRAIT_QUALITY_MULTIPLIER_RANDOM;
};

float(float level) moon_generate_trait_prefix_rarity =
{
	local float total_quality;
	total_quality = moon_generate_trait_quality(level);

	if ( total_quality < MOON_ITEM_TRAIT_THRESHOLD_PREFIX_LOW )
	{
		return MOON_ITEM_RARITY_LOW;
	} else
	if ( total_quality < MOON_ITEM_TRAIT_THRESHOLD_PREFIX_NORMAL )
	{
		return MOON_ITEM_RARITY_NORMAL;
	} else
	if ( total_quality < MOON_ITEM_TRAIT_THRESHOLD_PREFIX_HIGH )
	{
		return MOON_ITEM_RARITY_HIGH;
	} else {
		return MOON_ITEM_RARITY_EPIC;
	}
};

float(float level) moon_generate_trait_postfix_rarity =
{
	local float total_quality;
	total_quality = moon_generate_trait_quality(level);

	if ( total_quality < MOON_ITEM_TRAIT_THRESHOLD_POSTFIX_LOW )
	{
		return MOON_ITEM_RARITY_LOW;
	} else
	if ( total_quality < MOON_ITEM_TRAIT_THRESHOLD_POSTFIX_NORMAL )
	{
		return MOON_ITEM_RARITY_NORMAL;
	} else
	if ( total_quality < MOON_ITEM_TRAIT_THRESHOLD_POSTFIX_HIGH )
	{
		return MOON_ITEM_RARITY_HIGH;
	} else {
		return MOON_ITEM_RARITY_HIGH;
		// return MOON_ITEM_RARITY_EPIC; // disable, until Unique items implemented
	}
};

float(float level) moon_generate_trait_effect_code =
{
	if ( level < MOON_ITEM_TRAIT_CODE_THRESHOLD_LOW )
	{
		return random_int(MOON_ITEM_TRAIT_MIN_EFFECT, MOON_ITEM_TRAIT_CODE_LOW_HIGHEST);
	} else
	if ( level > MOON_ITEM_TRAIT_CODE_THRESHOLD_HIGH )
	{
		return random_int(MOON_ITEM_TRAIT_CODE_HIGH_LOWEST, MOON_ITEM_TRAIT_MAX_EFFECT);
	} else {
		return random_int(MOON_ITEM_TRAIT_MIN_EFFECT, MOON_ITEM_TRAIT_MAX_EFFECT);
	}
};

void(entity e) moon_generate_magic_prefix =
{
	local float mxx;
	local float effect;
	local float rarity;

	mxx = moon_get_max_player_level();
	effect = moon_generate_trait_effect_code(mxx);
	e.magic_typeone = effect;

	rarity = moon_generate_trait_prefix_rarity(mxx);
	e.magic_rarity_level = e.magic_rarity_level + rarity;
	switch(effect)
	{
	case MOON_ITEM_HEALTH_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_HEALTH_PREFIX_LOW_FROM, MOON_ITEM_HEALTH_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_HEALTH_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_HEALTH_PREFIX_NORMAL_FROM, MOON_ITEM_HEALTH_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_HEALTH_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_HEALTH_PREFIX_HIGH_FROM, MOON_ITEM_HEALTH_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_HEALTH_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_HEALTH_PREFIX_EPIC_FROM, MOON_ITEM_HEALTH_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_HEALTH_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_RESIST_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_RESIST_PREFIX_LOW_FROM, MOON_ITEM_RESIST_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_RESIST_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_RESIST_PREFIX_NORMAL_FROM, MOON_ITEM_RESIST_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_RESIST_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_RESIST_PREFIX_HIGH_FROM, MOON_ITEM_RESIST_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_RESIST_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_RESIST_PREFIX_EPIC_FROM, MOON_ITEM_RESIST_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_RESIST_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_GOLD_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_GOLD_PREFIX_LOW_FROM, MOON_ITEM_GOLD_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_GOLD_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
		case MOON_ITEM_RARITY_HIGH: // -- There were NO High rarity variant -- \\
			e.magic_typeone_value = random_int(MOON_ITEM_GOLD_PREFIX_NORMAL_FROM, MOON_ITEM_GOLD_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_GOLD_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_GOLD_PREFIX_EPIC_FROM, MOON_ITEM_GOLD_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_GOLD_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_DAMAGE_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_DAMAGE_PREFIX_LOW_FROM, MOON_ITEM_DAMAGE_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_DAMAGE_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_DAMAGE_PREFIX_NORMAL_FROM, MOON_ITEM_DAMAGE_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_DAMAGE_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
		case MOON_ITEM_RARITY_EPIC: // -- There were NO Epic rarity variant -- \\
			e.magic_typeone_value = random_int(MOON_ITEM_DAMAGE_PREFIX_HIGH_FROM, MOON_ITEM_DAMAGE_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_DAMAGE_PREFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_RETALATE_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_RETALATE_PREFIX_LOW_FROM, MOON_ITEM_RETALATE_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_RETALATE_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_RETALATE_PREFIX_NORMAL_FROM, MOON_ITEM_RETALATE_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_RETALATE_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH: // -- There were NO High rarity variant -- \\
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_RETALATE_PREFIX_EPIC_FROM, MOON_ITEM_RETALATE_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_RETALATE_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_VAMPIR_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_VAMPIR_PREFIX_LOW_FROM, MOON_ITEM_VAMPIR_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_VAMPIR_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_VAMPIR_PREFIX_NORMAL_FROM, MOON_ITEM_VAMPIR_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_VAMPIR_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH: // -- There were NO High rarity variant -- \\
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_VAMPIR_PREFIX_EPIC_FROM, MOON_ITEM_VAMPIR_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_VAMPIR_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_REGEN_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_REGEN_PREFIX_LOW_FROM, MOON_ITEM_REGEN_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_REGEN_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_REGEN_PREFIX_NORMAL_FROM, MOON_ITEM_REGEN_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_REGEN_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_REGEN_PREFIX_HIGH_FROM, MOON_ITEM_REGEN_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_REGEN_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_REGEN_PREFIX_EPIC_FROM, MOON_ITEM_REGEN_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_REGEN_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_CONSUME_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_CONSUME_PREFIX_LOW_FROM, MOON_ITEM_CONSUME_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_CONSUME_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_CONSUME_PREFIX_NORMAL_FROM, MOON_ITEM_CONSUME_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_CONSUME_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
		case MOON_ITEM_RARITY_EPIC: // -- There were NO Epic rarity variant -- \\
			e.magic_typeone_value = random_int(MOON_ITEM_CONSUME_PREFIX_HIGH_FROM, MOON_ITEM_CONSUME_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_CONSUME_PREFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_REPAIR_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_REPAIR_PREFIX_LOW_FROM, MOON_ITEM_REPAIR_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_REPAIR_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_REPAIR_PREFIX_NORMAL_FROM, MOON_ITEM_REPAIR_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_REPAIR_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_REPAIR_PREFIX_HIGH_FROM, MOON_ITEM_REPAIR_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_REPAIR_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_REPAIR_PREFIX_EPIC_FROM, MOON_ITEM_REPAIR_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_REPAIR_PREFIX_EPIC;
			break;
		}
		break;
	case MOON_ITEM_RECHARGE_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typeone_value = random_int(MOON_ITEM_RECHARGE_PREFIX_LOW_FROM, MOON_ITEM_RECHARGE_PREFIX_LOW_TO);
			e.prefix_one = MOON_ITEM_RECHARGE_PREFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typeone_value = random_int(MOON_ITEM_RECHARGE_PREFIX_NORMAL_FROM, MOON_ITEM_RECHARGE_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_REPAIR_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_RECHARGE_PREFIX_HIGH_FROM, MOON_ITEM_RECHARGE_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_REPAIR_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_RECHARGE_PREFIX_EPIC_FROM, MOON_ITEM_RECHARGE_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_RECHARGE_PREFIX_EPIC;
			break;
		}
		break;
	default:
		bprint("moon_generate_magic_prefix cannot handle code {}\n", quick_ftos(effect));
	}

};

void(entity e) moon_generate_magic_postfix =
{
	local float mxx;
	local float effect;
	local float rarity;

	mxx = moon_get_max_player_level();
	effect = moon_generate_trait_effect_code(mxx);
	e.magic_typetwo = effect;

	rarity = moon_generate_trait_prefix_rarity(mxx);
	e.magic_rarity_level = e.magic_rarity_level + rarity;
	switch(effect)
	{
	case MOON_ITEM_HEALTH_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_HEALTH_POSTFIX_LOW_FROM, MOON_ITEM_HEALTH_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_HEALTH_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
		case MOON_ITEM_RARITY_HIGH: // -- There were NO High rarity variant -- \\
			e.magic_typetwo_value = random_int(MOON_ITEM_HEALTH_POSTFIX_NORMAL_FROM, MOON_ITEM_HEALTH_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_HEALTH_POSTFIX_NORMAL;
			break;
		}
		break;
	case MOON_ITEM_RESIST_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_RESIST_POSTFIX_LOW_FROM, MOON_ITEM_RESIST_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_RESIST_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_RESIST_POSTFIX_NORMAL_FROM, MOON_ITEM_RESIST_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_RESIST_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_RESIST_POSTFIX_HIGH_FROM, MOON_ITEM_RESIST_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_RESIST_POSTFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_GOLD_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_GOLD_POSTFIX_LOW_FROM, MOON_ITEM_GOLD_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_GOLD_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
		case MOON_ITEM_RARITY_HIGH: // -- There were NO High rarity variant -- \\
			e.magic_typetwo_value = random_int(MOON_ITEM_GOLD_POSTFIX_NORMAL_FROM, MOON_ITEM_GOLD_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_GOLD_POSTFIX_NORMAL;
			break;
		}
		break;
	case MOON_ITEM_DAMAGE_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_DAMAGE_POSTFIX_LOW_FROM, MOON_ITEM_DAMAGE_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_DAMAGE_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_DAMAGE_POSTFIX_NORMAL_FROM, MOON_ITEM_DAMAGE_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_DAMAGE_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_DAMAGE_POSTFIX_HIGH_FROM, MOON_ITEM_DAMAGE_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_DAMAGE_POSTFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_RETALATE_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_RETALATE_POSTFIX_LOW_FROM, MOON_ITEM_RETALATE_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_RETALATE_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
		case MOON_ITEM_RARITY_HIGH: // -- There were NO High rarity variant -- \\
			e.magic_typetwo_value = random_int(MOON_ITEM_RETALATE_POSTFIX_NORMAL_FROM, MOON_ITEM_RETALATE_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_RETALATE_POSTFIX_NORMAL;
			break;
		}
		break;
	case MOON_ITEM_VAMPIR_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
		case MOON_ITEM_RARITY_NORMAL: // -- There were NO Normal rarity variant -- \\
		case MOON_ITEM_RARITY_HIGH: // -- There were NO High rarity variant -- \\
			e.magic_typetwo_value = random_int(MOON_ITEM_VAMPIR_POSTFIX_LOW_FROM, MOON_ITEM_VAMPIR_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_VAMPIR_POSTFIX_LOW;
			break;
		}
		break;
	case MOON_ITEM_REGEN_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_REGEN_POSTFIX_LOW_FROM, MOON_ITEM_REGEN_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_REGEN_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
		case MOON_ITEM_RARITY_HIGH: // -- There were NO High rarity variant -- \\
			e.magic_typetwo_value = random_int(MOON_ITEM_REGEN_POSTFIX_NORMAL_FROM, MOON_ITEM_REGEN_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_REGEN_POSTFIX_NORMAL;
			break;
		}
		break;
	case MOON_ITEM_CONSUME_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_CONSUME_POSTFIX_LOW_FROM, MOON_ITEM_CONSUME_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_CONSUME_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
		case MOON_ITEM_RARITY_HIGH: // -- There were NO High rarity variant -- \\
			e.magic_typetwo_value = random_int(MOON_ITEM_CONSUME_POSTFIX_NORMAL_FROM, MOON_ITEM_CONSUME_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_CONSUME_POSTFIX_NORMAL;
			break;
		}
		break;
	case MOON_ITEM_REPAIR_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_REPAIR_POSTFIX_LOW_FROM, MOON_ITEM_REPAIR_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_REPAIR_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_REPAIR_POSTFIX_NORMAL_FROM, MOON_ITEM_REPAIR_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_REPAIR_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_REPAIR_POSTFIX_HIGH_FROM, MOON_ITEM_REPAIR_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_REPAIR_POSTFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_RECHARGE_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_RECHARGE_POSTFIX_LOW_FROM, MOON_ITEM_RECHARGE_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_RECHARGE_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_RECHARGE_POSTFIX_NORMAL_FROM, MOON_ITEM_RECHARGE_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_RECHARGE_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_RECHARGE_POSTFIX_HIGH_FROM, MOON_ITEM_RECHARGE_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_RECHARGE_POSTFIX_HIGH;
			break;
		}
		break;
	default:
		bprint("moon_generate_magic_postfix cannot handle code {}\n", quick_ftos(effect));
	}
};

void() moon_market_place_magic_item =
{
	local entity e;
	local float z;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = MOON_TRADE_MARKET_SPOT_CLASSNAME;
	if ( random() < MOON_ITEM_ARMOR_VS_RING_CHANCE )
	{
		e.netname = MOON_ITEM_ARMOR_NETNAME;
		e.targetname = MOON_ITEM_ARMOR_DISPLAY_LONG;
		setmodel(e, "progs/armor.mdl");
		e.noise1 = "items/armor1.wav";
		e.skin = 3;
	} else {
		e.netname = MOON_ITEM_RING_NETNAME;
		e.targetname = MOON_ITEM_RING_DISPLAY_LONG;
		setmodel(e, "progs/ring.mdl");
		e.noise1 = "moon/items/ring.wav";
	}
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);

	z = random();
	if ( z < MOON_ITEM_MAGIC_CHANCE_PREFIX )
	{
		moon_generate_magic_prefix(e);
	} else
	if (z < MOON_ITEM_MAGIC_CHANCE_POSTFIX )
	{
		moon_generate_magic_postfix(e);
	} else {
		moon_generate_magic_prefix(e);
		moon_generate_magic_postfix(e);
	}

	moon_calculate_magic_cost(e);
};

void() moon_market_place_medkit_mega =
{
	local entity e;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, (((self.origin + (v_forward * 49)) - '0 0 24') + (v_right * KEY_MOVEFORWARD)));
	e.solid = SOLID_NOT;
	e.angles_y = anglemod((self.angles_y + MENTAT_TIME));
	e.classname = MOON_TRADE_MARKET_SPOT_CLASSNAME;
	e.netname = MOON_MEDKIT_MEGA_MARKET_NETNAME;
	e.targetname = MOON_MEDKIT_MEGA_MARKET_DISPLAYNAME;
	e.noise1 = "items/r_item2.wav";
	e.healamount = rint( MOON_MEDKIT_MEGA_MARKET_MIN + (random() * MOON_MEDKIT_MEGA_MARKET_RANDOM) );
	e.cost = (e.healamount * MOON_MEDKIT_MEGA_MARKET_COSTOFONE);
	e.owner = self;
	e.healtype = MOON_MEDKIT_MEGA_TYPE;
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);
	setmodel(e, MOON_MEDKIT_MEGA_MODEL);
};

void() PlaceGoody =
{
	local float r;

	r = random();
	if ( r < 0.2 )
	{
		moon_market_place_magic_item();
	} else
	if ( r < 0.37 )
	{
		PlaceWeapon();
	} else
	if ( r < 0.52 )
	{
		moon_market_place_medkit_mega();
	} else
	if ( r < 0.7 )
	{
		moon_market_place_armor();
	} else
	if ( r < 0.83 )
	{
		moon_market_place_elixir();
	} else {
		moon_market_place_ammo();
	}

	self.free = 2;
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
		self.action = 2;
		while ( (a = find(a, classname, MOON_TRADE_MARKET_SOMETHING_CLASSNAME)) )
		{
			if ( a.enemy == self )
			{
				a.free = TRUE;
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
	e.health = H_ROTTEN;
	e.yaw_speed = LOGIC_HUNTENEMY;
	e.wantnum = LOGIC_DEFEND;
	e.speed = 200;
	e.action = H_ROTTEN;
	e.attack_finished = ((time + 20) + (20 * random()));
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

void() sale_brain =
{
	local entity e;

	e = spawn();
	e.nextthink = ((time + 20) + (2 * random()));
	e.think = sale_think;
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

	min_dist = MOON_PHYSIC_ITEMSEARCH_RADIUS;
	while ( (head = find(head, classname, MOON_TRADE_MARKET_SPOT_CLASSNAME)) )
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
	flash_self();

	switch (selected.netname)
	{
		case MOON_ARMOR_MARKET_NETNAME:
			if ( (self.armortype * self.armorvalue) >= (selected.armortype * selected.armorvalue) )
			{
				sprint(self, "You \sdon't\s need it\n");
				return;
			}
			self.armortype = selected.armortype;
			self.armorvalue = selected.armorvalue;
			self.items = (((self.items & (~IT_ARMOR1)) & (~IT_ARMOR2)) & (~IT_ARMOR3)) | selected.items;

			sprint(self, "You bought {}\n", selected.targetname);
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
			moon_target_wear_magic_item(self, selected);
			break;
	}

	selected.targetname = string_null;
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

	min_dist = MOON_PHYSIC_ITEMSEARCH_RADIUS;
	while ( (head = find(head, classname, MOON_TRADE_MARKET_SPOT_CLASSNAME)) )
	{
		if ( head.free == FALSE )
		{
			if ( vlen((head.origin - self.origin)) < min_dist )
			{
				min_dist = vlen( head.origin - self.origin );
				selected = head;
			}
		}
	}
	if ( selected != world )
	{
		sprint(self, "====== identify item ======\n");
		if ( selected.netname == MOON_ARMOR_MARKET_NETNAME )
		{
			sprint(self, selected.targetname);
		} else
		if ( selected.netname == MOON_ELIXIR_MARKET_NETNAME )
		{
			sprint(self, selected.targetname);
		} else
		if ( selected.netname == MOON_AMMO_MARKET_NETNAME )
		{
			sprint(self, "{0} {1}", floor_ftos(selected.currentammo), selected.targetname);
		} else
		if ( selected.netname == MOON_WEAPON_MARKET_NETNAME )
		{
			sprint(self, selected.targetname);
		} else
		if ( selected.netname == MOON_MEDKIT_MEGA_MARKET_NETNAME )
		{
			sprint(self, selected.targetname);
		} else
		if ( (selected.netname == MOON_ITEM_ARMOR_NETNAME) || (selected.netname == MOON_ITEM_RING_NETNAME) )
		{
			temp = other;
			other = self;
			self = selected;
			MagicItemTouch();
			self = other;
			other = temp;
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

// KEEP THIS FUNCTION HERE FOR A WHILE SINCE IT REFERENCES TONS OF OTHERS!!!
void() moon_set_map_moon4 = // nothing to do here until all other problems are done
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
	moon_reset_globals();
	waypoints_ok = TRUE;
};
//

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
		target.targetname = MOON_ARMOR_GREEN_DISPLAYNAME;
		break;
	case MOON_ARMOR_YELLOW_CODE:
		target.items = IT_ARMOR2;
		target.skin = MOON_ARMOR_YELLOW_SKIN;
		target.max_health = MOON_ARMOR_YELLOW_DURABILITY;
		target.armortype = MOON_ARMOR_YELLOW_RESISTANCE;
		target.cost = MOON_ARMOR_YELLOW_SHOP_COST;
		target.targetname = MOON_ARMOR_YELLOW_DISPLAYNAME;
		break;
	case MOON_ARMOR_RED_CODE:
		target.items = IT_ARMOR3;
		target.skin = MOON_ARMOR_RED_SKIN;
		target.max_health = MOON_ARMOR_RED_DURABILITY;
		target.armortype = MOON_ARMOR_RED_RESISTANCE;
		target.cost = MOON_ARMOR_RED_SHOP_COST;
		target.targetname = MOON_ARMOR_RED_DISPLAYNAME;
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

void(entity trader) find_trade_spot =
{
	local entity head;
	local float r;

	while ( (head = find(head, classname, MOON_TRADE_SHOP_SPOT_CLASSNAME)) )
	{
		if ( head.netname != trader.netname ) { continue; }
		if ( head.free == FALSE ) { continue; }
		if ( head.attack_finished >= time ) { continue; } // spot.attack_finished is time for next trade spots own (re-)fill check

		r = random();
		switch(trader.netname)
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
			if ( r < 0.1 ) 	// was 0.2
			{
				setmodel(head, MOON_AMMO_SHELLS_MODEL);
				head.ammo_shells = ceil(MOON_AMMO_SHELLS_BASE + (random() * MOON_AMMO_SHELLS_RANDOM));
				head.currentammo = head.ammo_shells;
				head.cost = ceil(head.ammo_shells * MOON_AMMO_SHELLS_COSTOFONE);
				head.targetname = MOON_AMMO_SHELLS_DISPLAYNAME;
			} else
			if ( r < 0.4 )	// was 0.4
			{
				setmodel(head, MOON_AMMO_NAILS_MODEL);
				head.ammo_nails = ceil(MOON_AMMO_NAILS_BASE + (random() * MOON_AMMO_NAILS_RANDOM));
				head.currentammo = head.ammo_nails;
				head.cost = ceil(head.ammo_nails * MOON_AMMO_NAILS_COSTOFONE);
				head.targetname = MOON_AMMO_NAILS_DISPLAYNAME;
			} else
			if ((r < 0.7))	// was 0.7
			{
				setmodel(head, MOON_AMMO_ROCKETS_MODEL);
				head.ammo_rockets = ceil(MOON_AMMO_ROCKETS_BASE + (random() * MOON_AMMO_ROCKETS_RANDOM));
				head.currentammo = head.ammo_rockets;
				head.cost = ceil(head.ammo_rockets * MOON_AMMO_ROCKETS_COSTOFONE);
				head.targetname = MOON_AMMO_ROCKETS_DISPLAYNAME;
			} else {
				setmodel(head, MOON_AMMO_CELLS_MODEL);
				head.ammo_cells = ceil(MOON_AMMO_CELLS_BASE + (random() * MOON_AMMO_CELLS_RANDOM));
				head.currentammo = head.ammo_cells;
				head.cost = ceil(head.ammo_cells * MOON_AMMO_CELLS_COSTOFONE);
				head.targetname = MOON_AMMO_CELLS_DISPLAYNAME;
			}
			break;
		case MOON_TRADE_SHOP_WEAPON_NETNAME:
			head.cnt = MOON_ITEM_TRADE_SIGNOF_WEAPON;
			if ( r < 0.15 )
			{
				setmodel(head, MOON_WEAPON_SUPERSHOTGUN_MODEL_TPV);
				head.ammo_shells = MOON_WEAPON_SUPERSHOTGUN_AMMO_SHOP;
				head.currentammo = head.ammo_shells;
				head.cost = MOON_WEAPON_SUPERSHOTGUN_COST_SHOP;
				head.targetname = MOON_WEAPON_SUPERSHOTGUN_DISPLAYNAME;
				head.items = IT_SUPER_SHOTGUN;
			} else
			if ( r < 0.3 )
			{
				setmodel(head, MOON_WEAPON_NAILGUN_MODEL_TPV);
				head.ammo_nails = MOON_WEAPON_NAILGUN_AMMO_SHOP;
				head.currentammo = head.ammo_nails;
				head.cost = MOON_WEAPON_NAILGUN_COST_SHOP;
				head.targetname = MOON_WEAPON_NAILGUN_DISPLAYNAME;
				head.items = IT_NAILGUN;
			} else
			if ( r < 0.45 )
			{
				setmodel(head, MOON_WEAPON_SUPERNAILGUN_MODEL_TPV);
				head.ammo_nails = MOON_WEAPON_SUPERNAILGUN_AMMO_SHOP;
				head.currentammo = head.ammo_nails;
				head.cost = MOON_WEAPON_SUPERNAILGUN_COST_SHOP;
				head.targetname = MOON_WEAPON_SUPERNAILGUN_DISPLAYNAME;
				head.items = IT_SUPER_NAILGUN;
			} else
			if ( r < 0.6 )
			{
				setmodel(head, MOON_WEAPON_GRENADELAUNCHER_MODEL_TPV);
				head.ammo_rockets = MOON_WEAPON_GRENADELAUNCHER_AMMO_SHOP;
				head.currentammo = head.ammo_rockets;
				head.cost = MOON_WEAPON_GRENADELAUNCHER_COST_SHOP;
				head.targetname = MOON_WEAPON_GRENADELAUNCHER_DISPLAYNAME;
				head.items = IT_GRENADE_LAUNCHER;
			} else
			if ( r < 0.8 )
			{
				setmodel(head, MOON_WEAPON_ROCKETLAUNCHER_MODEL_TPV);
				head.ammo_rockets = MOON_WEAPON_ROCKETLAUNCHER_AMMO_SHOP;
				head.currentammo = head.ammo_rockets;
				head.cost = MOON_WEAPON_ROCKETLAUNCHER_COST_SHOP;
				head.targetname = MOON_WEAPON_ROCKETLAUNCHER_DISPLAYNAME;
				head.items = IT_ROCKET_LAUNCHER;
			} else {
				setmodel(head, MOON_WEAPON_LIGHTNING_MODEL_TPV);
				head.ammo_cells = MOON_WEAPON_LIGHTNING_AMMO_SHOP;
				head.currentammo = head.ammo_cells;
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
	if ( self.walkframe >= 5 )
	{
		self.walkframe = 0;
	}
	self.frame = (6 + self.walkframe);
	self.walkframe = (self.walkframe + 1);
	if ( self.radsuit_finished < time )
	{
		find_trade_spot(self);
		self.radsuit_finished = (time + 5); // trader.radsuit_finished is time for next traders trade spots (re-)fill check
	}
	self.think = trader_think;
	self.nextthink = (time + 0.47);	// was (time + 0.07)
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
	self.classname = MOON_TRADE_SHOP_SPOT_CLASSNAME;
	self.solid = SOLID_NOT;
	self.attack_finished = ( time + MOON_TRADE_SPOT_DELAY_INIT_MIN + (random() * MOON_TRADE_SPOT_DELAY_INIT_RANDOM) );
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
};

void() moon_buy_item =
{
	local entity head;
	local entity selected;
	local float min_dist;
	local entity mega;
	local float best;
	local float tempf;

	min_dist = 150;
	while ( (head = find(head, classname, MOON_TRADE_SHOP_SPOT_CLASSNAME)) )
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
	if ( selected == world )	// If no trade stands found in shop, check black market
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
		if ( (self.armortype * self.armorvalue) >= (selected.armortype * selected.armorvalue) )
		{
			sprint(self, "you \sdon't\s need it\n");
			return;
		}
		self.armortype = selected.armortype;
		self.armorvalue = selected.armorvalue;
		self.items = (((self.items & (~IT_ARMOR1)) & (~IT_ARMOR2)) & (~IT_ARMOR3)) | selected.items;

		sprint(self, "You bought shiny new {}\n", selected.targetname);
		sound(self, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
		selected.attack_finished = (time + MOON_TRADE_SPOT_ARMOR_DELAY_MIN + (random() * MOON_TRADE_SPOT_ARMOR_DELAY_RANDOM));
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
				sprint(self, "you \sdon't\s need it\n");
				return;
			}
			T_Heal(self, selected.healamount, 0);
		}
		sprint(self, "You bought {0} and healed {1}HP\n", selected.targetname, floor_ftos(selected.healamount));
		sound(self, CHAN_ITEM, selected.noise, 1, ATTN_NORM);
		selected.attack_finished = (time + MOON_TRADE_SPOT_HEALTH_DELAY_MIN + (random() * MOON_TRADE_SPOT_HEALTH_DELAY_RANDOM));
	} else
	if ( selected.cnt == MOON_ITEM_TRADE_SIGNOF_AMMO ) // Sign of Ammo
	{
		best = W_BestWeapon();
		self.ammo_shells = (self.ammo_shells + selected.ammo_shells);
		self.ammo_nails = (self.ammo_nails + selected.ammo_nails);
		self.ammo_rockets = (self.ammo_rockets + selected.ammo_rockets);
		self.ammo_cells = (self.ammo_cells + selected.ammo_cells);
		moon_limit_target_ammo(self);

		sprint(self, "You bought {0} {1}\n", floor_ftos(selected.currentammo), selected.targetname);
		sound(self, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
		tempf = MOON_TRADE_SPOT_AMMO_DELAY_MIN / clampd(1, moon_get_current_player_count(), 4);
		selected.attack_finished = (time + tempf + (random() * MOON_TRADE_SPOT_AMMO_DELAY_RANDOM)); // Ammo respawn at shop faster the more players in game

		if ( self.weapon == best )
		{
			self.weapon = W_BestWeapon();
		}
		W_SetCurrentAmmo();
		selected.currentammo = 0;
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
		selected.attack_finished = (time + MOON_TRADE_SPOT_WEAPON_DELAY_MIN + (random() * MOON_TRADE_SPOT_WEAPON_DELAY_RANDOM));

		if ( self.weapon == best )
		{
			self.weapon = W_BestWeapon();
		}
		W_SetCurrentAmmo();
		selected.currentammo = 0;
		selected.ammo_cells = 0;
		selected.ammo_rockets = 0;
		selected.ammo_nails = 0;
		selected.ammo_shells = 0;
	}

	moon_pay_target_gold(self, selected.cost); // already checked above
	flash_self();

	setmodel(selected, string_null);
	selected.targetname = string_null;
	selected.free = TRUE;
};

void() moon_identify_item =
{
	local entity head;
	local entity selected;
	local float min_dist;

	min_dist = 150;
	head = find(world, classname, MOON_TRADE_SHOP_SPOT_CLASSNAME);
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
		head = find(head, classname, MOON_TRADE_SHOP_SPOT_CLASSNAME);
	}
	if ( selected == world )
	{
		moon_identify_item_market();
		return;
	}

	sprint(self, "====== identified item ======\n");
	if ( selected.items & IT_ARMOR1 )
	{
		sprint(self, MOON_ARMOR_GREEN_DISPLAYNAME);
	}
	if ( selected.items & IT_ARMOR2 )
	{
		sprint(self, MOON_ARMOR_YELLOW_DISPLAYNAME);
	}
	if ( selected.items & IT_ARMOR3 )
	{
		sprint(self, MOON_ARMOR_RED_DISPLAYNAME);
	}
	if ( selected.items & IT_SUPERHEALTH )
	{
		sprint(self, "{0} +{1}", selected.targetname, floor_ftos(selected.healamount));
	}

	if ( selected.cnt == MOON_ITEM_TRADE_SIGNOF_AMMO )
	{
		sprint(self, "Box of");
		moon_print_target_container_ammo(self, selected);
	} else
	if ( selected.cnt == MOON_ITEM_TRADE_SIGNOF_WEAPON )
	{
		sprint(self, selected.targetname);
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
	sprint(self, "| vitality: {0} ({1}", quick_ftos(self.vit), quick_ftos(self.max_health));

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
	if ( self.mentat_offense_time > time )
	{
		bonus = (bonus + MOON_MENTAT_OFFENSE_VALUE);
	}

	sprint(self, "| strength: {0} ({1}%", quick_ftos(self.stre), quick_ftos((self.stre * MOON_STAT_DAMAGE_PER_STRENGTH) + 100));
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

string(float level) moon_get_monster_level_prefix =
{
	if ( level < 0 )
	{
		return "n00bie ";
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

float(float count, float difficulty) moon_clamp_monster_wave_size_for_difficulty =
{
	if ( difficulty <= MOON_DIFFICULTY_MIN )
	{
		if ( count > 3 )
		{
			return 3;
		}
	}
	if ( difficulty >= MOON_DIFFICULTY_MAX )
	{
		if ( count < 3 )
		{
			return 3;
		}
	}
	return count;
};

float(float level) moon_get_monster_wave_size_for_player =
{
	local float wave;

	wave = moon_get_monster_wave_size_for_level(level);
	wave = moon_clamp_monster_wave_size_for_difficulty(wave, skill);

	return wave;
};

float(float level, float player_count) moon_get_monster_wave_size =
{
	local float wave;

	wave = moon_get_monster_wave_size_for_player(level); // Initial wave size for Single player

	// Adjust wave size for Multiplayer. If necessary - later use individual player level, not maximum
	if ( player_count > 1 )
	{
		wave = wave + moon_get_monster_wave_size_for_player(level - 1);
	}
	if ( player_count > 2 )
	{
		wave = wave + moon_get_monster_wave_size_for_player(level - 2);
	}
	if ( player_count > 3 )
	{
		wave = wave + moon_get_monster_wave_size_for_player(level - 3);
	}

	return wave;
};

float(float lvl) moon_get_monster_spawn_type =
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

void(entity spawner, float player_level) moon_spawn_monster =
{
	local float monster_type;
	local float random_shift;
	local float player_level_adjusted;
	local entity monster;

	random_shift = rint(random() * 3);
	player_level_adjusted = player_level - random_shift; // may be add skill here (so -3 random compensated by +3 nightmare)?

	spawner.count = (spawner.count - 1);
	monster_type = moon_get_monster_spawn_type(player_level);
	// moon_spawn_monster_entity();
	switch(monster_type)	// TODO: split/refactor spawn_X functions to handle only specific to X stuff there
	{
	case MOON_MONSTER_CODE_SOLDIER:
		monster = spawn_soldier(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_SOLDIER, 50) );
		break;
	case MOON_MONSTER_CODE_ENFORCER:
		monster = spawn_enforcer(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_ENFORCER, 50));
		break;
	case MOON_MONSTER_CODE_SPIDER:
		monster = spawn_spider(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_SPIDER, 50));
		break;
	case MOON_MONSTER_CODE_OGRE:
		monster = spawn_ogre(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_OGRE, 50));
		break;
	case MOON_MONSTER_CODE_SNAKE:
		monster = spawn_snake(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_SNAKE, 50));
		break;
	case MOON_MONSTER_CODE_MAGE:
		monster = spawn_mage(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_MAGE, 50));
		break;
	case MOON_MONSTER_CODE_SHALRATH:
		monster = spawn_shalrath(spawner, clampd(0, player_level_adjusted - MOON_MONSTER_BASELEVEL_SHALRATH, 50));
		break;
	default:
		dprint("ERROR IN moon_spawn_monster(...): monster_type spawns null monster\n");
		return;
	}
	moon_debug_println_object_name(monster); // Debug only
};

float SVC_SETVIEWPORT    = 5;
float SVC_SETVIEWANGLES    = 10;
float chasecam_dist    = 118;
float chasecam_zofs    = 24;

void() Keep_cam_chasing_owner; // forward declaration
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
	setmodel(self, string_null);
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
		self.weaponmodel = string_null;
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
		bprint("MonsterSpawn: no `info_monster_start` on level");
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
					moon_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "I will stay here\n");
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
						moon_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "I'm coming\n");
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

void() info_monster_start = // Empty ctor()
{
};

void() shoot_ent = // ctor()
{
	self.health = 1;
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
	moon_queue_monster_for_removal(self, moon_get_despawn_delay());
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
		moon_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "INCOMING!!!\n");
		break;
	case 2:
		moon_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "They are coming!\n");
		break;
	case 3:
		moon_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "I found enemy!\n");
		break;
	case 4:
		moon_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "We are under attack!\n");
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
						moon_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "I'm helping comrades\n");
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
	moon_do_target_natural_health_regen_tick(self);
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
	if ( trace_ent.flags & FL_CLIENT )
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

void() moon_spawn_guard =
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
	newbot.action = 0;
	newbot.takedamage = DAMAGE_AIM;
	newbot.goalentity = world;
	newbot.movetarget = world;
	newbot.pausetime = (time + 2);
	newbot.ideal_yaw = (newbot.angles * '0 1 0');
	newbot.yaw_speed = 6;
	newbot.view_ofs = '0 0 25';
	newbot.speed = 320;
	newbot.wantline = 1;
	newbot.natural_regen_cooldown = MOON_GUARD_HEALTH_REGEN_COOLDOWN;
	newbot.natural_regen_value = MOON_GUARD_HEALTH_REGEN_VALUE;
	newbot.natural_regen_time = 0;

	moon_spawn_guard_items(newbot);
	bprint("== a wandering guardian joins your forces ==\n"); // refactor to more generic decribe functions
	bprint("HP: {}. ", floor_ftos(newbot.max_health));
	if ( newbot.items & IT_ARMOR3 )
	{
		bprint(MOON_ARMOR_RED_DISPLAYNAME);
	} else
	if ( newbot.items & IT_ARMOR2 )
	{
		bprint(MOON_ARMOR_YELLOW_DISPLAYNAME);
	} else
	if ( newbot.items & IT_ARMOR1 )
	{
		bprint(MOON_ARMOR_GREEN_DISPLAYNAME);
	}
	bprint("({}).\n", floor_ftos(newbot.armorvalue));

	bprint("Weapons: Shot");
	if ( newbot.items & IT_SUPER_SHOTGUN ) 		{ bprint(", Supershot"); }
	if ( newbot.items & IT_NAILGUN ) 			{ bprint(", Nail"); }
	if ( newbot.items & IT_SUPER_NAILGUN ) 		{ bprint(", Supernail"); }
	if ( newbot.items & IT_GRENADE_LAUNCHER ) 	{ bprint(", GL"); }
	if ( newbot.items & IT_ROCKET_LAUNCHER ) 	{ bprint(", RL"); }
	if ( newbot.items & IT_LIGHTNING ) 			{ bprint(", Shaft"); }
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
	newbot.skin = 3;
	setmodel(newbot, "progs/player.mdl");
	setsize(newbot, VEC_HULL_MIN, VEC_HULL_MAX);
	spot = SelectSpawnPoint();
	org = (spot.origin + '0 0 1');
	setorigin(newbot, org);
	spawn_tfog(newbot.origin);
	newbot.nextthink = (time + 0.1);
	newbot.think = newbot.th_stand;

	moon_chat_message_broad(MOON_CHAT_NAME_GUARD, MOON_CHAT_COLOR_BOTMSG, "Ready to serve\n");
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
		if ((self.melee != H_ROTTEN))
		{
			self.wantline = H_ROTTEN;
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

void() intermission_victory = // Verify it works
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

	gameover = TRUE;
	intermission_running = 1; // Stats screen
	intermission_exittime = (time + 5);
	WriteByte(MSG_ALL, SVC_INTERMISSION);
	ThrowGib("progs/gib1.mdl", random_zc(self.max_health / 2));
	ThrowGib("progs/gib2.mdl", random_zc(self.max_health / 2));
	ThrowGib("progs/gib3.mdl", random_zc(self.max_health / 2));
	ThrowGib("progs/gib1.mdl", random_zc(self.max_health / 2));
	ThrowGib("progs/gib2.mdl", random_zc(self.max_health / 2));
	ThrowGib("progs/gib3.mdl", random_zc(self.max_health / 2));
	BecomeExplosion();
};

void() moon_heart_think =
{
	self.nextthink = moon_do_target_natural_health_regen_tick(self);
};

void() heart = // ctor()
{
	setmodel(self, MOON_HEART_MODEL);
	self.solid = SOLID_BBOX;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.takedamage = DAMAGE_AIM;
	self.max_health = MOON_HEART_HEALTH_INIT;
	self.health = self.max_health;
	self.nextexp = MOON_EXP_FIRST_LEVEL;
	self.natural_regen_cooldown = MOON_HEART_HEALTH_REGEN_COOLDOWN;
	self.natural_regen_value = MOON_HEART_HEALTH_REGEN_VALUE;
	self.natural_regen_time = 0;

	self.classname = MOON_HEART_CLASSNAME;
	self.netname = MOON_HEART_DISPLAYNAME;
	self.th_die = heart_die;
	self.think = moon_heart_think;
	self.nextthink = time + 1;
};

void(entity e) GenegateCampTarget = // NOT TODAY
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

void() MagicItemTouch =
{
	if (other.classname != MOON_PLAYER_CLASSNAME) { return; }
	if (other.health <= 0) { return; }

	if (((other.next_mesg_time < time) || (other.mesg_inflictor != self)))
	{
		sprint(other, "=== magic item ===\n");
		moon_print_target_item_name(other, self.prefix_one, self.netname, self.prefix_two);
		moon_print_target_item_rarity(other, self.magic_rarity_level);
		sprint(other, "\n");
		moon_println_target_own_magic_item_description(other); // when self is item, its magic is held in same place for both Armor and Ring

		if ( moon_target_player_needs_tutorial(other) )
		{
			if ((self.classname != MOON_TRADE_MARKET_SPOT_CLASSNAME))
			{
				sprint(other, "Use `use` (default: `E`) command to pick it up.\n");
			}
		}

		other.next_mesg_time = (time + 4);
		other.mesg_inflictor = self;
	}
};

void(entity target, float effect_code, float effect_value) moon_handle_magic_effect_lost_max_health =
{
	if ( effect_code == MOON_ITEM_HEALTH_CODE )
	{
		target.max_health = (target.max_health - effect_value);
		if (!(target.items & IT_SUPERHEALTH) )
		{
			if ( target.health > target.max_health )
			{
				target.health = target.max_health;
			}
		}
	}
};

void(entity target, entity selected) moon_target_wear_magic_item =
{
	sprint(target, "You put on ");
	if ( selected.netname == MOON_ITEM_ARMOR_NETNAME )
	{
		if ( target.wear_armor == MOON_ITEM_SOME )
		{
			moon_handle_magic_effect_lost_max_health(target, target.magic_typeone, target.magic_typeone_value);
			moon_handle_magic_effect_lost_max_health(target, target.magic_typetwo, target.magic_typetwo_value);
			target.magic_rarity_level = MOON_ITEM_RARITY_THRESHOLD_TRASH;
			target.magic_typeone = MOON_ITEM_NONE;
			target.magic_typeone_value = 0;
			target.magic_prefixone = "";
			target.magic_typetwo = MOON_ITEM_NONE;
			target.magic_typetwo_value = 0;
			target.magic_prefixtwo = "";
		}
		selected.magic_prefixone = selected.prefix_one;	// wtf, why not fill magic_prefix on item spawn?
		selected.magic_prefixtwo = selected.prefix_two;	// wtf, why not fill magic_prefix on item spawn?
		sound(target, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
		target.wear_armor = MOON_ITEM_SOME;
		target.magic_rarity_level = selected.magic_rarity_level;
		if ( selected.magic_typeone >= MOON_ITEM_SOME )
		{
			target.magic_typeone = selected.magic_typeone;
			target.magic_typeone_value = selected.magic_typeone_value;
			target.magic_prefixone = selected.magic_prefixone;
			if ( selected.magic_typeone == MOON_ITEM_HEALTH_CODE )
			{
				moon_raise_target_max_health(target, selected.magic_typeone_value);
			}
		}
		if ( selected.magic_typetwo >= MOON_ITEM_SOME )
		{
			target.magic_typetwo = selected.magic_typetwo;
			target.magic_typetwo_value = selected.magic_typetwo_value;
			target.magic_prefixtwo = selected.magic_prefixtwo;
			if ( selected.magic_typetwo == MOON_ITEM_HEALTH_CODE )
			{
				moon_raise_target_max_health(target, selected.magic_typetwo_value);
			}
		}
		moon_print_target_item_name(target, selected.magic_prefixone, selected.netname, selected.magic_prefixtwo);
		sprint(target, "\n");
	} else
	if ( selected.netname == MOON_ITEM_RING_NETNAME )
	{
		if ( target.wear_ring == MOON_ITEM_SOME )
		{
			moon_handle_magic_effect_lost_max_health(target, target.ring_typeone, target.ring_typeone_value);
			moon_handle_magic_effect_lost_max_health(target, target.ring_typetwo, target.ring_typetwo_value);
			target.ring_rarity_level = 0;
			target.ring_typeone = 0;
			target.ring_typeone_value = 0;
			target.ring_prefixone = "";
			target.ring_typetwo = 0;
			target.ring_typetwo_value = 0;
			target.ring_prefixtwo = "";
		}
		selected.ring_rarity_level = selected.magic_rarity_level;
		selected.ring_prefixone = selected.prefix_one;
		selected.ring_prefixtwo = selected.prefix_two;
		selected.ring_typeone = selected.magic_typeone;
		selected.ring_typetwo = selected.magic_typetwo;
		selected.ring_typeone_value = selected.magic_typeone_value;
		selected.ring_typetwo_value = selected.magic_typetwo_value;
		sound(target, CHAN_ITEM, "moon/items/ring.wav", 1, ATTN_NORM);
		target.wear_ring = MOON_ITEM_SOME;
		target.ring_rarity_level = selected.ring_rarity_level;
		if ( selected.ring_typeone >= MOON_ITEM_SOME )
		{
			target.ring_typeone = selected.ring_typeone;
			target.ring_typeone_value = selected.ring_typeone_value;
			target.ring_prefixone = selected.ring_prefixone;
			if ( selected.ring_typeone == MOON_ITEM_HEALTH_CODE )
			{
				moon_raise_target_max_health(target, selected.ring_typeone_value);
			}
		}
		if ( selected.ring_typetwo >= MOON_ITEM_SOME )
		{
			target.ring_typetwo = selected.ring_typetwo;
			target.ring_typetwo_value = selected.ring_typetwo_value;
			target.ring_prefixtwo = selected.ring_prefixtwo;
			if ( selected.ring_typetwo == MOON_ITEM_HEALTH_CODE )
			{
				moon_raise_target_max_health(target, selected.ring_typetwo_value);
			}
		}
		moon_print_target_item_name(target, selected.ring_prefixone, selected.netname, selected.ring_prefixtwo);
		sprint(target, "\n");
	}
	flash_self();
};

void() moon_self_pickup_magic_item_and_clear =
{
	local entity head;
	local entity selected;
	local float min_dist;

	min_dist = MOON_PHYSIC_ITEMSEARCH_RADIUS;
	while ( (head = find(head, classname, MOON_ITEM_MAGIC_CLASSNAME)) )
	{
		if ( vlen(head.origin - self.origin) < min_dist)
		{
			min_dist = vlen(head.origin - self.origin);
			selected = head;
		}
	}
	if ( selected == world )
	{
		sprint(self, "there are \sno\s magic items around\n");
		return;
	}
	moon_target_wear_magic_item(self, selected);
	remove(selected);
};

entity(entity who) moon_spawn_drop_magic_item =
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
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_IMPORTANT);
	item.think = SUB_Remove;

	z = random();
	if ( z < MOON_ITEM_MAGIC_CHANCE_PREFIX )
	{
		moon_generate_magic_prefix(item);
	} else
	if ( z < MOON_ITEM_MAGIC_CHANCE_POSTFIX )
	{
		moon_generate_magic_postfix(item);
	} else {
		moon_generate_magic_prefix(item);
		moon_generate_magic_postfix(item);
	}

	return item;
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
	case MOON_ITEM_GLOBALGOLD_CODE:
		bonus_value = MOON_ITEM_GLOBALGOLD_BONUS_FLAT + (pl * MOON_ITEM_GLOBALGOLD_BONUS_LVLPERCENT) + (random() * MOON_ITEM_GLOBALGOLD_BONUS_RANDOM);
		sprint(other, MOON_ITEM_GLOBALGOLD_EFFECT, floor_ftos(bonus_value));

		up_gold_value = up_gold_value + bonus_value;
		moon_println_all_global_gold_bonus();
		break;
	case MOON_ITEM_GATEALERT_CODE:
		if (up_alert == MOON_CONST_LOCKED)
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
	case MOON_ITEM_GUARDIAN_CODE:
		sprint(other, MOON_ITEM_GUARDIAN_EFFECT);
		moon_spawn_guard();
		break;
	case MOON_ITEM_MELEEUP_CODE:
		if (other.up_axe == MOON_CONST_LOCKED)
		{
			sprint(other, MOON_ITEM_MELEEUP_EFFECT);
		} else {
			sprint(other, MOON_ITEM_MELEEUP_SIDEEFFECT);
		}
		other.up_axe = other.up_axe + 1;
		break;
	case MOON_ITEM_SHELLUP_CODE:
		if (other.up_bullet == MOON_CONST_LOCKED)
		{
			sprint(other, MOON_ITEM_SHELLUP_EFFECT);
		} else {
			sprint(other, MOON_ITEM_SHELLUP_SIDEEFFECT);
		}
		other.up_bullet = other.up_bullet + 1;
		break;
	case MOON_ITEM_NAILUP_CODE:
		if (other.up_nail == MOON_CONST_LOCKED)
		{
			sprint(other, MOON_ITEM_NAILUP_EFFECT);
		} else {
			sprint(other, MOON_ITEM_NAILUP_SIDEEFFECT);
		}
		other.up_nail = other.up_nail + 1;
		break;
	case MOON_ITEM_ROCKUP_CODE:
		if (other.up_rocket == MOON_CONST_LOCKED)
		{
			sprint(other, MOON_ITEM_ROCKUP_EFFECT);
		} else {
			sprint(other, MOON_ITEM_ROCKUP_SIDEEFFECT);
		}
		other.up_rocket = other.up_rocket + 1;
		break;
	case MOON_ITEM_CELLUP_CODE:
		if (other.up_cell == MOON_CONST_LOCKED)
		{
			sprint(other, MOON_ITEM_CELLUP_EFFECT);
		} else {
			sprint(other, MOON_ITEM_CELLUP_SIDEEFFECT);
		}
		other.up_cell = other.up_cell + 1;
		break;
	case MOON_ITEM_STATUP_CODE:
		sprint(other, MOON_ITEM_STATUP_EFFECT);
		other.point = other.point + MOON_ITEM_STATUP_BONUS;
		other.items = (other.items | IT_KEY1);
		break;
	}

	sound(other, CHAN_ITEM, "moon/items/book.wav", 1, ATTN_NORM);
	flash_target(other);
	remove(self);
};

void(entity who, float upgrade_code) DropBookByCode =
{
	local entity item;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.cnt = upgrade_code;
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel(item, "progs/tome.mdl");
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = UpgradeTouch;
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_IMPORTANT);
	item.think = SUB_Remove;
};

void(entity who) moon_spawn_drop_book_upgrade_player =
{
	local float code;
	code = random_int(MOON_ITEM_MELEEUP_CODE, MOON_ITEM_STATUP_CODE);
	DropBookByCode(who, code);
};

void(entity who) moon_spawn_drop_book_upgrade_castle =
{
	local float code;
	code = random_int(MOON_ITEM_GLOBALGOLD_CODE, MOON_ITEM_GUARDIAN_CODE);
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
		sprint(other, "You get {0} and receive {1} health\n", self.netname, floor_ftos(self.healamount));
	} else {
		sprint(other, "You wasted {0}\n", self.netname);
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
	sprint(other, "You got {0}\n", self.netname);
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
	item.skin = 2;
	setsize(item, '-12 -12 0', '12 12 36');
	item.touch = ELTouch;
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_NORMAL);
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

void(entity item) moon_fill_potion_with_heal =
{
	local float pl;
	local float r;

	pl = moon_get_max_player_level();

	if ( pl < MOON_ITEM_LVLTHRESHOLD_POTION_LOWER )
	{
		item.healamount = rint( (random() * MOON_ITEM_POTION_SMALL_RANDOM) + MOON_ITEM_POTION_SMALL_BASE );
		item.netname = MOON_ITEM_POTION_SMALL_NETNAME;
		return;
	}

	if ( (pl >= MOON_ITEM_LVLTHRESHOLD_POTION_LOWER) && (pl <= MOON_ITEM_LVLTHRESHOLD_POTION_UPPER) )
	{
		if ((random() < 0.6))
		{
			item.healamount = rint( (random() * MOON_ITEM_POTION_NORMAL_RANDOM) + MOON_ITEM_POTION_NORMAL_BASE );
			item.netname = MOON_ITEM_POTION_NORMAL_NETNAME;
		} else {
			item.healamount = rint( (random() * MOON_ITEM_POTION_SMALL_RANDOM) + MOON_ITEM_POTION_SMALL_BASE );
			item.netname = MOON_ITEM_POTION_SMALL_NETNAME;
		}
		return;
	}

	r = random();
	if ( r < 0.33 )
	{
		item.healamount = rint( (random() * MOON_ITEM_POTION_SMALL_RANDOM) + MOON_ITEM_POTION_SMALL_BASE );
		item.netname = MOON_ITEM_POTION_SMALL_NETNAME;
	} else
	if ( r <= 0.66 )
	{
		item.healamount = rint( (random() * MOON_ITEM_POTION_NORMAL_RANDOM) + MOON_ITEM_POTION_NORMAL_BASE );
		item.netname = MOON_ITEM_POTION_NORMAL_NETNAME;
	} else {
		item.healamount = rint( (random() * MOON_ITEM_POTION_BIG_RANDOM) + MOON_ITEM_POTION_BIG_BASE );
		item.netname = MOON_ITEM_POTION_BIG_NETNAME;
	}
};

void(entity who) moon_spawn_drop_potion =
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
	setmodel(item, "progs/potion.mdl");
	setsize(item, '-12 -12 0', '12 12 36');
	moon_fill_potion_with_heal(item);
	item.touch = HPTouch;
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

void() MentatTouch =
{ // self - touched drug, other - player
	if ( other.classname != MOON_PLAYER_CLASSNAME ) { return; }
	if ( other.health <= 0 ) { return; }

	flash_target(other);
	sound(other, CHAN_ITEM, "moon/items/drug.wav", 1, ATTN_NORM);

	switch(self.prefix)
	{
	case MOON_MENTAT_OFFENSE_CODE:
		moon_print_mentat_offense(other);
		sprint(other, "\n");
		other.mentat_offense_time = (time + MOON_TIME_ACTIVE_MENTAT);
		break;
	case MOON_MENTAT_DEFENSE_CODE:
		moon_print_mentat_defense(other);
		sprint(other, "\n");
		other.mentat_defense_time = (time + MOON_TIME_ACTIVE_MENTAT);
		break;
	case MOON_MENTAT_SPEED_CODE:
		moon_print_mentat_speed(other);
		sprint(other, "\n");
		other.mentat_attackspeed_time = (time + MOON_TIME_ACTIVE_MENTAT);
		break;
	}
	remove(self);
};

void(entity who) moon_spawn_drop_drug =
{
	local entity item;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.gold = (1 + (random() * 125)); // wtf?!
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
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_NORMAL);
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

void(entity who) moon_drop_player_gold =
{
	local entity item;

	if ( who.classname != MOON_PLAYER_CLASSNAME ) { return; }
	if ( who.gold <= 0 ) { return; }

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
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_IMPORTANT);
	item.think = SUB_Remove;
};

void(entity who) moon_spawn_drop_gold =
{
	local entity item;
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

	// The stuff below is crazy. It increases gold amount with each applied factor.
	// So it is multiplicative (SIC!) bonus, not additive!
	// Proper way should be separating base gold and accumulating bonus, then applying it once
	if ( who.prefix == MOON_MONSTER_TRAIT_EXTRA_GOLD )
	{
		item.gold = (item.gold + percent(item.gold, who.prefix_value));
	}
	item.gold = (item.gold + percent(item.gold, up_gold_value));
	item.gold = (item.gold + percent(item.gold, moon_get_target_total_bonus_by_code(who.killer, MOON_ITEM_GOLD_CODE)));
	// End of crazy shit
	item.gold = ceil(item.gold);

	item.velocity_z = 350;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.owner = who;
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel(item, MOON_GOLD_BAG_MODEL);
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = GoldTouch;
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_NORMAL);
	item.think = SUB_Remove;
};

void(entity who) moon_spawn_drop_ammo =
{
	local entity item;
	local float z;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.gold = (1 + (random() * 125)); // why the fuck?
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;

	z = random();
	if ( z < 0.3 )
	{
		setmodel(item, MOON_AMMO_SHELLS_MODEL);
		item.netname = MOON_AMMO_SHELLS_DISPLAYNAME;
		item.ammo_shells = ceil(MOON_AMMO_SHELLS_LOOT_MIN + (random() * MOON_AMMO_SHELLS_LOOT_RANDOM));
		item.currentammo = item.ammo_shells;
	} else
	if ( z < 0.72 )
	{
		setmodel(item, MOON_AMMO_NAILS_MODEL);
		item.netname = MOON_AMMO_NAILS_DISPLAYNAME;
		item.ammo_nails = ceil(MOON_AMMO_NAILS_LOOT_MIN + (random() * MOON_AMMO_NAILS_LOOT_RANDOM));
		item.currentammo = item.ammo_nails;
	} else
	if ( z < 0.944 )
	{
		setmodel(item, MOON_AMMO_ROCKETS_MODEL);
		item.netname = MOON_AMMO_ROCKETS_DISPLAYNAME;
		item.ammo_rockets = ceil(MOON_AMMO_ROCKETS_LOOT_MIN + (random() * MOON_AMMO_ROCKETS_LOOT_RANDOM));
		item.currentammo = item.ammo_rockets;
	} else {
		setmodel(item, MOON_AMMO_CELLS_MODEL);
		item.netname = MOON_AMMO_CELLS_DISPLAYNAME;
		item.ammo_cells = ceil(MOON_AMMO_CELLS_LOOT_MIN + (random() * MOON_AMMO_CELLS_LOOT_RANDOM));
		item.currentammo = item.ammo_cells;
	}

	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = ammo_touch;
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_NORMAL);
	item.think = SUB_Remove;
};

void() DropItem =
{
	local entity e;
	local entity spawned_object;

	self.think = SUB_Null;
	self.nextthink = 0;
	if ((self.scroll_shaf_eff > time)) // Implement
	{
		moon_magic_effect_thunder();
	}
	if ((self.scroll_infe_eff > time)) // Implement
	{
		moon_magic_effect_inferno();
	}

	if ( self.prefix == MOON_MONSTER_TRAIT_SUICIDE )
	{
		e = spawn();
		e.origin = self.origin;
		T_RadiusDamage(e, self, self.prefix_value, e);
		sound(e, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_EXPLOSION);
		WriteCoord(MSG_BROADCAST, e.origin_x);
		WriteCoord(MSG_BROADCAST, e.origin_y);
		WriteCoord(MSG_BROADCAST, e.origin_z);
		setmodel(e, "progs/s_explod.spr"); // BecomeExplosion() ?
		e.solid = SOLID_NOT;
		e.think = s_explode1;
		e.nextthink = time;
	}

	if ( self.prefix == MOON_MONSTER_TRAIT_EXTRA_GOLD )
	{
		moon_spawn_drop_gold(self);
		return;
	}
	if ((random() < 0.0035))
	{
		moon_spawn_drop_book_upgrade_player(self);
		return;
	}
	if ((random() < 0.0125))
	{
		moon_spawn_drop_book_upgrade_castle(self);
		return;
	}
	if ((random() < 0.025))
	{
		moon_spawn_drop_magic_item(self);
		return;
	}
	if ((random() < 0.015))
	{
		moon_spawn_drop_elixir(self);
		return;
	}
	if ((random() < 0.03))
	{
		moon_spawn_drop_weapon(self);
		return;
	}
	if ((random() < 0.03))
	{
		moon_spawn_drop_armor_shard(self);
		return;
	}
	if ((random() < 0.025))
	{
		moon_spawn_drop_drug(self);
		return;
	}
	if ((random() < 0.04))
	{
		moon_spawn_drop_potion(self);
		return;
	}
	if ((random() < 0.2))
	{
		moon_spawn_drop_ammo(self);
		return;
	}
	if ((random() < 0.5))
	{
		moon_spawn_drop_gold(self);
		return;
	}
};

float(float l, float was) exp_table =
{
	return floor(was + (l * MOON_NEXTLEVEL_MORE_PLAYERLEVEL_TIMES * MOON_NEXTLEVEL_MORE_SCALING_FACTOR) );
};

void(entity target) level_up_target =
{
	target.lvl = target.lvl + 1; // Increase level first
	target.nextexp = exp_table(target.lvl, target.nextexp); // Increase requirement with updated level
	target.frags = target.lvl;

	if ( target.health > 0 )
	{
		if ( target.health < target.max_health )
		{
			target.health = target.max_health;
		}
	}

	target.items = (target.items | IT_KEY1);
	if ( target.lvl <= MOON_PLAYER_LEVEL_GROW_FAST )
	{
		target.point = (target.point + MOON_PLAYER_POINT_GROW_FAST);
	} else
	if ( target.lvl <= MOON_PLAYER_LEVEL_GROW_NORMAL )
	{
		target.point = (target.point + MOON_PLAYER_POINT_GROW_NORMAL);
	} else {
		target.point = (target.point + MOON_PLAYER_POINT_GROW_SLOW);
	}

	sound(target, CHAN_BODY, "moon/misc/levelup.wav", 1, ATTN_NORM);
	sprint(target, "=== Level Up! ===\n");
	sprint(target, "You are now level {0}\n", quick_ftos(target.lvl));

	if (moon_target_player_needs_tutorial(target))
	{
		sprint(target, "Get {0} experience for the next Level.\n", quick_ftos(target.nextexp));
		sprint(target, "use `stats` command to check and upgrade your stats\n");
		sprint(target, "-----------------\n");
	}
};

void(entity heart) level_up_heart =
{
	if (heart == world) { return; }

	if (heart.lvl >= MOON_HEART_MAX_LEVEL)
	{
		bprint("Congratulations! You \swon\s the game.\n");
		intermission_victory();
		return;
	}

	moon_spawn_guard();

	heart.lvl = heart.lvl + 1; // Increase level first
	heart.nextexp = exp_table(heart.lvl, heart.nextexp); // Increase requirement with updated level

	heart.max_health = (heart.max_health + MOON_HEART_HEALTH_GROW);
	heart.health = (heart.health + MOON_HEART_HEALTH_GROW);
	if (heart.health > heart.max_health)
	{
		heart.health = heart.max_health;
	}
};

void(float experience) moon_grant_all_exp =
{
	local entity heart;
	local entity e;

	if (gameover) { return; }

	heart = find(world, classname, MOON_HEART_CLASSNAME);
	if (heart != world)
	{
		heart.exp = (heart.exp + experience);
		if (heart.exp >= heart.nextexp)
		{
			level_up_heart(heart);
		}
	}

	while ( (e = find(e, classname, MOON_PLAYER_CLASSNAME)) )
	{
		e.exp = (e.exp + experience);
		if (e.exp >= e.nextexp)
		{
			level_up_target(e);
		}
	}
};

void() GiveExp = // this used in so many monster classes
{
	moon_grant_all_exp(self.exp); // so easier to put a wrapper here
};