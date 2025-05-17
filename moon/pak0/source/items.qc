//Decompiled code. Please respect the original copyright.
float H_ROTTEN    = 1;
float H_MEGA      = 2;
// .float healamount; 	// moved into mn_entity.qc for a while, remove after rename
// .float healtype; 	// moved into mn_entity.qc for a while, remove after rename

void() health_touch;

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
	self.mdl = self.model;		// so it can be restored on respawn
	self.flags = FL_ITEM;		// make extra wide
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.velocity = VEC_ORIGIN;
	self.origin_z = (self.origin_z + 6);
	if (!droptofloor())
	{
		dprint("Bonus item fell out of level at {0}\n", vtos(self.origin));
		remove(self);
		return;
	}
};

void() StartItem =
{
	self.nextthink = (time + 0.2);
	self.think = PlaceItem;
};

//
// T_Heal: add health to an entity, limiting health to max_health
// "ignore" will ignore max_health limit
//
float (entity e, float healamount, float ignore) T_Heal = // UNUSED, see: moon_heal_target_player
{
	if (e.health <= 0)
		return 0;

	if ((!ignore) && (e.health >= e.max_health))
		return 0;

	healamount = ceil(healamount);

	e.health = e.health + healamount;

	if ((!ignore) && (e.health >= e.max_health))
		e.health = e.max_health;

	if (e.health > 250)
		e.health = 250;

	return 1;
};

void() item_health = // keep as close to vanilla as possible
{
	self.touch = moon_medkit_touch; // was health_touch
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

void() item_megahealth_rot = // UNUSED
{
	other = self.owner;

	if (other.health > other.max_health)
	{
		other.health = other.health - 1;
		self.nextthink = time + 1;
		return;
	}

	// 	it is possible for a player to die and respawn between rots, so don't
	// 	just blindly subtract the flag off

	other.items = other.items - (other.items & IT_SUPERHEALTH);
	remove(self);
};

void() health_touch = // UNUSED, see: moon_medkit_touch
{
	local	string	s;

	if (other.classname != "player")
		return;

	if (self.healtype == 2) // Megahealth?  Ignore max_health...
	{
		if (other.health >= other.max_health + 250)
			return;
		if (!T_Heal(other, self.healamount, 1))
			return;
	}
	else
	{
		if (!T_Heal(other, self.healamount, 0))
			return;
	}

	sprint(other, "You receive ");
	s = ftos(self.healamount);
	sprint(other, s);
	sprint(other, " health\n");

	// health touch sound
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);

	stuffcmd (other, "bf\n");

	self.model = string_null;
	self.solid = SOLID_NOT;

	// Megahealth = rot down the player's super health
	if (self.healtype == 2)
	{
		other.items = other.items | IT_SUPERHEALTH;
		self.nextthink = time + 5;
		self.think = item_megahealth_rot;
		self.owner = other;
	}

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
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

void() weapon_touch = // self - weapon, other - player
{
	local float best;

	if (!(other.flags & FL_CLIENT))
	{
		return;
	}

	if ( other.classname != MOON_PLAYER_CLASSNAME ) { return; }
	if ( other.health <= 0 ) { return; }

	best = moon_get_target_best_weapon(other);

	moon_target_consume_ammo_from(other, self);

	other.items = (other.items | self.items);

	sprint(other, "You got the {0}\n", self.netname);
	sound(other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	flash_other();

	if ( other.weapon == best )
	{
		moon_swap_target_to_best_weapon(other);
	} else {
		moon_set_target_currentammo(other);
	}

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

void() ammo_touch = // self - ammobox, other - player
{
	local float best;

	if ( other.classname != MOON_PLAYER_CLASSNAME ) { return; }
	if ( other.health <= 0 ) { return; }

	best = moon_get_target_best_weapon(other); // remember best weapon before getting additional ammo

	moon_target_consume_ammo_from(other, self);

	flash_target(other);
	sprint(other, "You picked up {0} {1}\n", floor_ftos(self.currentammo), self.netname);
	sound(other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);

	if (other.weapon == best)
	{
		moon_swap_target_to_best_weapon(other);
	} else {
		moon_set_target_currentammo(other);
	}

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

void() BackpackTouch = // self - backpack, other - player
{
	local float best;
	local float new;

	if ( other.classname != MOON_PLAYER_CLASSNAME ) { return; }
	if ( other.health <= 0 ) { return; }

	best = moon_get_target_best_weapon(other); // remember best weapon before getting additional ammo

	moon_target_consume_ammo_from(other, self);
	other.items = other.items | self.items;

	flash_target(other);
	sprint(other, "You get {} with", self.netname);
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

	new = self.items; // remember what weapon was in Backpack
	if (!new)
	{
		new = other.weapon; // fallback to what Player has as a weapon
	}

	if (other.weapon == best)
	{
		moon_swap_target_to_best_weapon(other);
	} else {
		moon_set_target_currentammo(other);
	}

	remove(self);
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
	target.count = target.armorvalue; // duplicate for easier crosshair identification
	target.cost = (target.cost * (target.armorvalue / target.max_health));
};

void(entity target, float weapon_code, float ammo_count = -1) moon_init_target_as_weapon =
{
	switch(weapon_code)
	{
	case MOON_WEAPON_AXE_CODE: // never happens
	case MOON_WEAPON_SHOTGUN_CODE: // never happens
		target.currentammo = 0;
		break; // noop
	case MOON_WEAPON_SUPERSHOTGUN_CODE:
		setmodel(target, MOON_WEAPON_SUPERSHOTGUN_MODEL_TPV);
		if ( ammo_count > 0 )
		{
			target.ammo_shells = ammo_count;
		} else {
			target.ammo_shells = MOON_WEAPON_SUPERSHOTGUN_AMMO_SHOP;
		}
		target.currentammo = target.ammo_shells;
		target.cost = MOON_WEAPON_SUPERSHOTGUN_COST_SHOP;
		target.targetname = MOON_WEAPON_SUPERSHOTGUN_DISPLAYNAME; // for the Market&Shop
		target.netname = MOON_WEAPON_SUPERSHOTGUN_DISPLAYNAME; // for the Loot drop
		target.items = IT_SUPER_SHOTGUN;
		break;
	case MOON_WEAPON_NAILGUN_CODE:
		setmodel(target, MOON_WEAPON_NAILGUN_MODEL_TPV);
		if ( ammo_count > 0 )
		{
			target.ammo_nails = ammo_count;
		} else {
			target.ammo_nails = MOON_WEAPON_NAILGUN_AMMO_SHOP;
		}
		target.currentammo = target.ammo_nails;
		target.cost = MOON_WEAPON_NAILGUN_COST_SHOP;
		target.targetname = MOON_WEAPON_NAILGUN_DISPLAYNAME;
		target.netname = MOON_WEAPON_NAILGUN_DISPLAYNAME;
		target.items = IT_NAILGUN;
		break;
	case MOON_WEAPON_SUPERNAILGUN_CODE:
		setmodel(target, MOON_WEAPON_SUPERNAILGUN_MODEL_TPV);
		if ( ammo_count > 0 )
		{
			target.ammo_nails = ammo_count;
		} else {
			target.ammo_nails = MOON_WEAPON_SUPERNAILGUN_AMMO_SHOP;
		}
		target.currentammo = target.ammo_nails;
		target.cost = MOON_WEAPON_SUPERNAILGUN_COST_SHOP;
		target.targetname = MOON_WEAPON_SUPERNAILGUN_DISPLAYNAME;
		target.netname = MOON_WEAPON_SUPERNAILGUN_DISPLAYNAME;
		target.items = IT_SUPER_NAILGUN;
		break;
	case MOON_WEAPON_GRENADELAUNCHER_CODE:
		setmodel(target, MOON_WEAPON_GRENADELAUNCHER_MODEL_TPV);
		if ( ammo_count > 0 )
		{
			target.ammo_rockets = ammo_count;
		} else {
			target.ammo_rockets = MOON_WEAPON_GRENADELAUNCHER_AMMO_SHOP;
		}
		target.currentammo = target.ammo_rockets;
		target.cost = MOON_WEAPON_GRENADELAUNCHER_COST_SHOP;
		target.targetname = MOON_WEAPON_GRENADELAUNCHER_DISPLAYNAME;
		target.netname = MOON_WEAPON_GRENADELAUNCHER_DISPLAYNAME;
		target.items = IT_GRENADE_LAUNCHER;
		break;
	case MOON_WEAPON_ROCKETLAUNCHER_CODE:
		setmodel(target, MOON_WEAPON_ROCKETLAUNCHER_MODEL_TPV);
		if ( ammo_count > 0 )
		{
			target.ammo_rockets = ammo_count;
		} else {
			target.ammo_rockets = MOON_WEAPON_ROCKETLAUNCHER_AMMO_SHOP;
		}
		target.currentammo = target.ammo_rockets;
		target.cost = MOON_WEAPON_ROCKETLAUNCHER_COST_SHOP;
		target.targetname = MOON_WEAPON_ROCKETLAUNCHER_DISPLAYNAME;
		target.netname = MOON_WEAPON_ROCKETLAUNCHER_DISPLAYNAME;
		target.items = IT_ROCKET_LAUNCHER;
		break;
	case MOON_WEAPON_LIGHTNING_CODE:
		setmodel(target, MOON_WEAPON_LIGHTNING_MODEL_TPV);
		if ( ammo_count > 0 )
		{
			target.ammo_cells = ammo_count;
		} else {
			target.ammo_cells = MOON_WEAPON_LIGHTNING_AMMO_SHOP;
		}
		target.currentammo = target.ammo_cells;
		target.cost = MOON_WEAPON_LIGHTNING_COST_SHOP;
		target.targetname = MOON_WEAPON_LIGHTNING_DISPLAYNAME;
		target.netname = MOON_WEAPON_LIGHTNING_DISPLAYNAME;
		target.items = IT_LIGHTNING;
		break;
	default:
		dprint("Unknown weapon code {0}\n", weapon_code);
	}

	target.count = target.currentammo; // duplicate for easier crosshair identification
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
		dprint("Unknown medkit code {0}\n", medkit_code);
	}

	// Adjust cost for spoiled medkits
	target.healamount = ( (target.health > 0) ? target.health : target.max_health);
	target.count = target.healamount; // duplicate for easier crosshair identification
	target.cost = (target.cost * (target.healamount / target.max_health));
};

// This should be used for both loot drop, shop and market spots
void(entity target, float ammo_code, float ammo_count = -1) moon_init_target_as_ammobox =
{
	target.items = ammo_code;
	target.cnt = MOON_ITEM_TRADE_SIGNOF_AMMO; // sadly still used in some Shop&Market code

	switch(ammo_code)
	{
	case MOON_AMMO_SHELLS_CODE: //==IT_SHELLS:
		setmodel(target, MOON_AMMO_SHELLS_MODEL);
		if ( ammo_count > 0 )
		{
			target.ammo_shells = ammo_count;
		} else {
			target.ammo_shells = ceil(MOON_AMMO_SHELLS_BASE + (random() * MOON_AMMO_SHELLS_RANDOM));
		}
		target.currentammo = target.ammo_shells;
		target.cost = ceil(target.ammo_shells * MOON_AMMO_SHELLS_COSTOFONE);
		target.targetname = MOON_AMMO_SHELLS_DISPLAYNAME;
		break;
	case MOON_AMMO_NAILS_CODE: //==IT_NAILS:
		setmodel(target, MOON_AMMO_NAILS_MODEL);
		if ( ammo_count > 0 )
		{
			target.ammo_nails = ammo_count;
		} else {
			target.ammo_nails = ceil(MOON_AMMO_NAILS_BASE + (random() * MOON_AMMO_NAILS_RANDOM));
		}
		target.currentammo = target.ammo_nails;
		target.cost = ceil(target.ammo_nails * MOON_AMMO_NAILS_COSTOFONE);
		target.targetname = MOON_AMMO_NAILS_DISPLAYNAME;
		break;
	case MOON_AMMO_ROCKETS_CODE: //==IT_ROCKETS:
		setmodel(target, MOON_AMMO_ROCKETS_MODEL);
		if ( ammo_count > 0 )
		{
			target.ammo_rockets = ammo_count;
		} else {
			target.ammo_rockets = ceil(MOON_AMMO_ROCKETS_BASE + (random() * MOON_AMMO_ROCKETS_RANDOM));
		}
		target.currentammo = target.ammo_rockets;
		target.cost = ceil(target.ammo_rockets * MOON_AMMO_ROCKETS_COSTOFONE);
		target.targetname = MOON_AMMO_ROCKETS_DISPLAYNAME;
		break;
	case MOON_AMMO_CELLS_CODE: //==IT_CELLS:
		setmodel(target, MOON_AMMO_CELLS_MODEL);
		if ( ammo_count > 0 )
		{
			target.ammo_cells = ammo_count;
		} else {
			target.ammo_cells = ceil(MOON_AMMO_CELLS_BASE + (random() * MOON_AMMO_CELLS_RANDOM));
		}
		target.currentammo = target.ammo_cells;
		target.cost = ceil(target.ammo_cells * MOON_AMMO_CELLS_COSTOFONE);
		target.targetname = MOON_AMMO_CELLS_DISPLAYNAME;
		break;
	default:
		dprint("Unknown ammunition code {0}\n", ammo_code);
	}

	target.count = target.currentammo; // duplicate for easier crosshair identification
};

entity() moon_market_place_armor =
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

	return e;
};

entity() moon_market_place_ammo =
{
	local entity e;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, (((self.origin + (v_forward * 47)) - '0 0 24') + (v_right * KEY_MOVERIGHT)));
	e.solid = SOLID_NOT;
	e.classname = MOON_TRADE_MARKET_SPOT_CLASSNAME;
	e.netname = MOON_AMMO_MARKET_NETNAME;
	e.skin = 0;
	setmodel(e, string_null);
	e.noise1 = "weapons/lock4.wav";
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);

	if ((random() < MOON_AMMO_MARKET_ROCKET_VS_CELL_RATIO))
	{
		moon_init_target_as_ammobox(e, MOON_AMMO_ROCKETS_CODE, ceil( MOON_AMMO_ROCKETS_MARKET_MIN + (random() * MOON_AMMO_ROCKETS_MARKET_RANDOM) ));
		e.cost = ceil(e.currentammo * MOON_AMMO_ROCKETS_MARKET_COSTOFONE);
	} else {
		moon_init_target_as_ammobox(e, MOON_AMMO_CELLS_CODE, ceil( MOON_AMMO_CELLS_MARKET_MIN + (random() * MOON_AMMO_CELLS_MARKET_RANDOM) ));
		e.cost = ceil(e.currentammo * MOON_AMMO_CELLS_MARKET_COSTOFONE);
	}

	return e;
};

entity() moon_market_place_elixir =
{
	local entity e;
	local float code;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = MOON_TRADE_MARKET_SPOT_CLASSNAME;
	e.netname = MOON_ELIXIR_MARKET_NETNAME;
	e.skin = 2; // TODO: extract
	setmodel(e, "progs/potion.mdl");
	e.noise1 = "moon/items/potion.wav";
	e.owner = self;
	code = random_int(MOON_ELIXIR_STR_CODE, MOON_ELIXIR_VIT_CODE);
	switch(code)
	{
		case MOON_ELIXIR_STR_CODE:
			e.targetname = MOON_ELIXIR_STR_NAME;
			e.healtype = MOON_ELIXIR_STR_CODE;
			e.cost = moon_get_inflation_adjusted_cost(MOON_ELIXIR_STR_COST_BASE);
			break;
		case MOON_ELIXIR_VIT_CODE:
			e.targetname = MOON_ELIXIR_VIT_NAME;
			e.healtype = MOON_ELIXIR_VIT_CODE;
			e.cost = moon_get_inflation_adjusted_cost(MOON_ELIXIR_VIT_COST_BASE);
			break;
		case MOON_ELIXIR_MAG_CODE: // TODO: implement
		case MOON_ELIXIR_INT_CODE: // TODO: implement
		default:
			break; // noop
	}
	e.count = 0;	// unused
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);

	return e;
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

float(float level) moon_generate_trait_quality = // return int in range [MAXLEVEL, 2*MAXLEVEL]
{
	local float shift;
	local float width;

	shift = clampd(0, level * 2 - MOON_ITEM_TRAIT_THRESHOLD_PREFIX_NORMAL, MOON_ITEM_TRAIT_THRESHOLD_PREFIX_NORMAL);
	width = 0;
	if ( level <= MOON_ITEM_TRAIT_LVLTHRESHOLD_LOWANDNORMAL )
	{
		width = MOON_ITEM_TRAIT_THRESHOLD_PREFIX_NORMAL;
	} else
	if ( level <= MOON_ITEM_TRAIT_LVLTHRESHOLD_NOEPIC )
	{
		width = MOON_ITEM_TRAIT_THRESHOLD_PREFIX_HIGH;
	} else
	if ( level <= MOON_ITEM_TRAIT_LVLTHRESHOLD_ALL )
	{
		width = MOON_ITEM_TRAIT_THRESHOLD_PREFIX_HIGH + level;
	} else
	if ( level <= MOON_ITEM_TRAIT_LVLTHRESHOLD_NOLOW )
	{
		width = MOON_ITEM_TRAIT_THRESHOLD_PREFIX_HIGH + level;
	} else { // MOON_ITEM_TRAIT_LVLTHRESHOLD_HIGHANDEPIC
		width = 50 + (level - MOON_ITEM_TRAIT_LVLTHRESHOLD_NOLOW);
	}

	return shift + rint(random() * width);
};

float(float level) moon_generate_trait_prefix_rarity =
{
	local float total_quality;
	total_quality = moon_generate_trait_quality(level);

	if ( total_quality <= MOON_ITEM_TRAIT_THRESHOLD_PREFIX_LOW )
	{
		return MOON_ITEM_RARITY_LOW;
	} else
	if ( total_quality <= MOON_ITEM_TRAIT_THRESHOLD_PREFIX_NORMAL )
	{
		return MOON_ITEM_RARITY_NORMAL;
	} else
	if ( (total_quality + badluck_compensation) <= MOON_ITEM_TRAIT_THRESHOLD_PREFIX_HIGH )
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

	if ( total_quality <= MOON_ITEM_TRAIT_THRESHOLD_POSTFIX_LOW )
	{
		return MOON_ITEM_RARITY_LOW;
	} else
	if ( total_quality <= MOON_ITEM_TRAIT_THRESHOLD_POSTFIX_NORMAL )
	{
		return MOON_ITEM_RARITY_NORMAL;
	} else
	if ( total_quality <= MOON_ITEM_TRAIT_THRESHOLD_POSTFIX_HIGH )
	{
		return MOON_ITEM_RARITY_HIGH;
	} else {
		return MOON_ITEM_RARITY_EPIC;
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
			e.magic_typeone_value = random_int(MOON_ITEM_DAMAGE_PREFIX_HIGH_FROM, MOON_ITEM_DAMAGE_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_DAMAGE_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_DAMAGE_PREFIX_EPIC_FROM, MOON_ITEM_DAMAGE_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_DAMAGE_PREFIX_EPIC;
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
			e.magic_typeone_value = random_int(MOON_ITEM_GOLD_PREFIX_NORMAL_FROM, MOON_ITEM_GOLD_PREFIX_NORMAL_TO);
			e.prefix_one = MOON_ITEM_GOLD_PREFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_GOLD_PREFIX_HIGH_FROM, MOON_ITEM_GOLD_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_GOLD_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_GOLD_PREFIX_EPIC_FROM, MOON_ITEM_GOLD_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_GOLD_PREFIX_EPIC;
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
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_RETALATE_PREFIX_HIGH_FROM, MOON_ITEM_RETALATE_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_RETALATE_PREFIX_HIGH;
			break;
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
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typeone_value = random_int(MOON_ITEM_VAMPIR_PREFIX_HIGH_FROM, MOON_ITEM_VAMPIR_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_VAMPIR_PREFIX_HIGH;
			break;
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
			e.magic_typeone_value = random_int(MOON_ITEM_CONSUME_PREFIX_HIGH_FROM, MOON_ITEM_CONSUME_PREFIX_HIGH_TO);
			e.prefix_one = MOON_ITEM_CONSUME_PREFIX_HIGH;
			break;
		case MOON_ITEM_RARITY_EPIC:
			e.magic_typeone_value = random_int(MOON_ITEM_CONSUME_PREFIX_EPIC_FROM, MOON_ITEM_CONSUME_PREFIX_EPIC_TO);
			e.prefix_one = MOON_ITEM_CONSUME_PREFIX_EPIC;
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
		e.magic_typeone = MOON_ITEM_NONE;
		bprint("moon_generate_magic_prefix cannot handle code {0}\n", quick_ftos(effect));
	}

	// Just adding Rarity levels works correctly, except for one case, when item has both prefix and postfix of same LOW level trait (which effectively makes it COMMON from TRASH)
	if ( (e.magic_typeone >= MOON_ITEM_SOME) && (e.magic_typetwo >= MOON_ITEM_SOME) && (e.magic_rarity_level == MOON_ITEM_RARITY_THRESHOLD_TRASH) )
	{
		e.magic_rarity_level = MOON_ITEM_RARITY_THRESHOLD_COMMON;
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

	rarity = moon_generate_trait_postfix_rarity(mxx);

	if ( rarity == MOON_ITEM_RARITY_EPIC ) // Postfix rolled to EPIC -> chance for Unique item
	{
		if ( e.magic_rarity_level == MOON_ITEM_RARITY_EPIC ) // Postifx always generated after Prefix, so this field hold rarity of Prefix by now
		{
			badluck_compensation = 0; // Reset bonus, and wait for next chance
		} else {
			rarity = MOON_ITEM_RARITY_HIGH; // lower quality,
			badluck_compensation = badluck_compensation + MOON_ITEM_TRAIT_BADLUCKCOMPENSATION_BONUS; // but award compensation
		}
	}

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
			e.magic_typetwo_value = random_int(MOON_ITEM_HEALTH_POSTFIX_NORMAL_FROM, MOON_ITEM_HEALTH_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_HEALTH_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_HEALTH_POSTFIX_HIGH_FROM, MOON_ITEM_HEALTH_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_HEALTH_POSTFIX_HIGH;
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
	case MOON_ITEM_GOLD_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_GOLD_POSTFIX_LOW_FROM, MOON_ITEM_GOLD_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_GOLD_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_GOLD_POSTFIX_NORMAL_FROM, MOON_ITEM_GOLD_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_GOLD_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_GOLD_POSTFIX_HIGH_FROM, MOON_ITEM_GOLD_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_GOLD_POSTFIX_HIGH;
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
	case MOON_ITEM_RETALATE_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_RETALATE_POSTFIX_LOW_FROM, MOON_ITEM_RETALATE_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_RETALATE_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_RETALATE_POSTFIX_NORMAL_FROM, MOON_ITEM_RETALATE_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_RETALATE_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_RETALATE_POSTFIX_HIGH_FROM, MOON_ITEM_RETALATE_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_RETALATE_POSTFIX_HIGH;
			break;
		}
		break;
	case MOON_ITEM_VAMPIR_CODE:
		switch(rarity)
		{
		case MOON_ITEM_RARITY_LOW:
			e.magic_typetwo_value = random_int(MOON_ITEM_VAMPIR_POSTFIX_LOW_FROM, MOON_ITEM_VAMPIR_POSTFIX_LOW_TO);
			e.prefix_two = MOON_ITEM_VAMPIR_POSTFIX_LOW;
			break;
		case MOON_ITEM_RARITY_NORMAL:
			e.magic_typetwo_value = random_int(MOON_ITEM_VAMPIR_POSTFIX_NORMAL_FROM, MOON_ITEM_VAMPIR_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_VAMPIR_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_VAMPIR_POSTFIX_HIGH_FROM, MOON_ITEM_VAMPIR_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_VAMPIR_POSTFIX_HIGH;
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
			e.magic_typetwo_value = random_int(MOON_ITEM_REGEN_POSTFIX_NORMAL_FROM, MOON_ITEM_REGEN_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_REGEN_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_REGEN_POSTFIX_HIGH_FROM, MOON_ITEM_REGEN_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_REGEN_POSTFIX_HIGH;
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
			e.magic_typetwo_value = random_int(MOON_ITEM_CONSUME_POSTFIX_NORMAL_FROM, MOON_ITEM_CONSUME_POSTFIX_NORMAL_TO);
			e.prefix_two = MOON_ITEM_CONSUME_POSTFIX_NORMAL;
			break;
		case MOON_ITEM_RARITY_HIGH:
			e.magic_typetwo_value = random_int(MOON_ITEM_CONSUME_POSTFIX_HIGH_FROM, MOON_ITEM_CONSUME_POSTFIX_HIGH_TO);
			e.prefix_two = MOON_ITEM_CONSUME_POSTFIX_HIGH;
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
		e.magic_typetwo = MOON_ITEM_NONE;
		bprint("moon_generate_magic_postfix cannot handle code {0}\n", quick_ftos(effect));
	}

	// Just adding Rarity levels works correctly, except for one case, when item has both prefix and postfix of same LOW level trait (which effectively makes it COMMON from TRASH)
	if ( (e.magic_typeone >= MOON_ITEM_SOME) && (e.magic_typetwo >= MOON_ITEM_SOME) && (e.magic_rarity_level == MOON_ITEM_RARITY_THRESHOLD_TRASH) )
	{
		e.magic_rarity_level = MOON_ITEM_RARITY_THRESHOLD_COMMON;
	}
};

void(entity e) moon_handle_magic_unique =
{
	if ( e.magic_rarity_level != MOON_ITEM_RARITY_THRESHOLD_UNIQUE )
	{
		return;
	}
	// roll which of Uniques
	// block that Unique from generating ever again
	// change Prefix and Postfix strings
	// change Prefix and Postfix values to maximum
	// handling of additional effects should be done on demand
	//  where it is required (i.e in damage function or heal function)
};

void(entity target) moon_init_target_as_magic_item =
{
	local float z;

	z = random();
	if ( z < MOON_ITEM_ARMOR_VS_RING_CHANCE )
	{
		target.netname = MOON_ITEM_ARMOR_NETNAME;
		target.targetname = MOON_ITEM_ARMOR_DISPLAY;
		setmodel(target, "progs/armor.mdl");
		target.noise1 = "items/armor1.wav";
		target.skin = 3;
	} else {
		target.netname = MOON_ITEM_RING_NETNAME;
		target.targetname = MOON_ITEM_RING_DISPLAY;
		setmodel(target, "progs/ring.mdl");
		target.noise1 = "moon/items/ring.wav";
	}

	z = random();
	if ( z < MOON_ITEM_MAGIC_CHANCE_PREFIX )
	{
		moon_generate_magic_prefix(target);
	} else
	if (z < MOON_ITEM_MAGIC_CHANCE_POSTFIX )
	{
		moon_generate_magic_postfix(target);
	} else {
		moon_generate_magic_prefix(target);
		moon_generate_magic_postfix(target);
		moon_handle_magic_unique(target);
	}

	moon_calculate_magic_cost(target);
};

entity() moon_market_place_magic_item =
{
	local entity e;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = MOON_TRADE_MARKET_SPOT_CLASSNAME;
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);

	moon_init_target_as_magic_item(e);

	return e;
};

entity() moon_market_place_weapon =
{
	local entity e;
	local float r;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = MOON_TRADE_MARKET_SPOT_CLASSNAME;
	e.noise1 = "weapons/pkup.wav";
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);

	r = random();
	if ( r < 0.16 )
	{
		moon_init_target_as_weapon(e, MOON_WEAPON_SUPERSHOTGUN_CODE, random_int(1, MOON_WEAPON_SUPERSHOTGUN_AMMO_MARKET));
		e.cost = rint( MOON_WEAPON_SUPERSHOTGUN_COST_MARKET + (e.currentammo * MOON_AMMO_SHELLS_COSTOFONE) );
		e.targetname = MOON_WEAPON_SUPERSHOTGUN_MARKET_DISPLAYNAME;
	} else
	if ( r < 0.33 )
	{
		moon_init_target_as_weapon(e, MOON_WEAPON_NAILGUN_CODE, random_int(1, MOON_WEAPON_NAILGUN_AMMO_MARKET));
		e.cost = rint( MOON_WEAPON_NAILGUN_COST_MARKET + (e.currentammo * MOON_AMMO_NAILS_COSTOFONE) );
		e.targetname = MOON_WEAPON_NAILGUN_MARKET_DISPLAYNAME;
	} else
	if ( r < 0.5 )
	{
		moon_init_target_as_weapon(e, MOON_WEAPON_SUPERNAILGUN_CODE, random_int(1, MOON_WEAPON_SUPERNAILGUN_AMMO_MARKET));
		e.cost = rint( MOON_WEAPON_SUPERNAILGUN_COST_MARKET + (e.currentammo * MOON_AMMO_NAILS_COSTOFONE) );
		e.targetname = MOON_WEAPON_SUPERNAILGUN_MARKET_DISPLAYNAME;
	} else
	if ( r < 0.66 )
	{
		moon_init_target_as_weapon(e, MOON_WEAPON_GRENADELAUNCHER_CODE, random_int(1, MOON_WEAPON_GRENADELAUNCHER_AMMO_MARKET));
		e.cost = rint( MOON_WEAPON_GRENADELAUNCHER_COST_MARKET + (e.currentammo * MOON_AMMO_ROCKETS_COSTOFONE) );
		e.targetname = MOON_WEAPON_GRENADELAUNCHER_MARKET_DISPLAYNAME;
	} else
	if ( r < 0.82 )
	{
		moon_init_target_as_weapon(e, MOON_WEAPON_ROCKETLAUNCHER_CODE, random_int(1, MOON_WEAPON_ROCKETLAUNCHER_AMMO_MARKET));
		e.cost = rint( MOON_WEAPON_ROCKETLAUNCHER_COST_MARKET + (e.currentammo * MOON_AMMO_ROCKETS_COSTOFONE) );
		e.targetname = MOON_WEAPON_ROCKETLAUNCHER_MARKET_DISPLAYNAME;
	} else {
		moon_init_target_as_weapon(e, MOON_WEAPON_LIGHTNING_CODE, random_int(1, MOON_WEAPON_LIGHTNING_AMMO_MARKET));
		e.cost = rint( MOON_WEAPON_LIGHTNING_COST_MARKET + (e.currentammo * MOON_AMMO_CELLS_COSTOFONE) );
		e.targetname = MOON_WEAPON_LIGHTNING_MARKET_DISPLAYNAME;
	}

	e.netname = MOON_WEAPON_MARKET_NETNAME; // overwrite value set by moon_init_target_as_weapon

	return e;
};

entity() moon_market_place_medkit_mega =
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
	e.count = e.healamount;
	e.cost = (e.healamount * MOON_MEDKIT_MEGA_MARKET_COSTOFONE);
	e.owner = self;
	e.healtype = MOON_MEDKIT_MEGA_TYPE;
	sound(e, CHAN_ITEM, "items/itembk2.wav", 1, ATTN_NORM);
	setmodel(e, MOON_MEDKIT_MEGA_MODEL);

	return e;
};

void(entity trader) PlaceGoody =
{
	local float r;

	r = random();
	if ( r < 0.2 )
	{
		moon_market_place_magic_item();
	} else
	if ( r < 0.37 )
	{
		moon_market_place_weapon();
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

	trader.free = MOON_TRADE_STATE_TRADING;
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
	if ((((self.angles_y >= (self.cnt - H_MEGA)) && (self.angles_y <= (self.cnt + H_MEGA))) && (self.free == MOON_TRADE_STATE_FREE)))
	{
		PlaceGoody(self);
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

void() s_touch = // self - market spot, other - market trader
{
	if ((other.goalentity != self))
	{
		return;
	}
	if ((other.classname != MOON_TRADER_MARKET_CLASSNAME))
	{
		return;
	}
	other.wantnum = 2;
	other.action = 3;
	other.cnt = self.angles_y;
	other.ideal_yaw = self.angles_y;
	other.goalentity = world;
	self.enemy = other;
	self.free = MOON_TRADE_STATE_OCCUPIED;
	other.free = MOON_TRADE_STATE_FREE;
};

void(vector org, float ang, float nm) S =
{
	local entity e;

	e = spawn();
	setorigin(e, org);
	e.angles_y = ang;
	e.num = nm;
	e.radius = 60;
	e.free = MOON_TRADE_STATE_FREE;
	e.classname = MOON_TRADE_MARKET_SOMETHING_CLASSNAME;
	setsize(e, '-4 -4 0', '4 4 8');
	e.touch = s_touch;
	e.solid = SOLID_TRIGGER;
	setsize(e, '-4 -4 0', '4 4 8');
};

void() ns_touch = // self - waypoint, other - market trader
{
	local entity tmp;
	local float nextnum;
	local float zzz;
	local entity ops;

	if ((other.goalentity != self))
	{
		return;
	}
	if ((other.classname != MOON_TRADER_MARKET_CLASSNAME))
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
			ops = find(world, classname, MOON_TRADE_MARKET_SOMETHING_CLASSNAME);
			while (ops)
			{
				if ((ops.num == zzz))
				{
					if ((ops.free == MOON_TRADE_STATE_FREE))
					{
						other.goalentity = ops;
						return;
					}
				}
				ops = find(ops, classname, MOON_TRADE_MARKET_SOMETHING_CLASSNAME);
			}
		}
	}
	bprint("ERROR: ns_touch error\n");
};

void(vector org, float nm, float rd) NS = // black market waypoints for Trader
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
	local float best;

	min_dist = MOON_PHYSIC_ITEMSEARCH_RADIUS;
	while ( (head = find(head, classname, MOON_TRADE_MARKET_SPOT_CLASSNAME)) )
	{
		if ((head.free == MOON_TRADE_STATE_OCCUPIED))
		{
			if ((vlen((head.origin - self.origin)) < min_dist))
			{
				min_dist = vlen((head.origin - self.origin));
				selected = head;
			}
		}
	}
	if ( selected == world ) { return; }

	if ( self.gold < selected.cost )
	{
		sprint(self, "not enough gold\n");
		sound(self, CHAN_ITEM, "misc/medkey.wav", 1, ATTN_NORM);
		return;
	}

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
			if ( self.health >= (self.max_health + MOON_MEDKIT_MEGA_OVERHEAL_SOFTLIMIT) )
			{
				sprint(self, "you \sdon't\s need it\n");
				return;
			}
			if ( self.health >= CONST_QC_DISPLAY_MAX )
			{
				sprint(self, "you \sdon't\s need it\n");
				return;
			}

			if ( selected.healtype == H_MEGA )
			{
				moon_overheal_target_player(self, selected.healamount);
			} else {
				moon_heal_target_player(self, selected.healamount);
			}

			sprint(self, "You bought {0}\n", MOON_MEDKIT_MEGA_MARKET_DISPLAYNAME);
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
			best = moon_get_target_best_weapon(self, TRUE); // Remember best weapon before buying ammo

			moon_target_consume_ammo_from(self, selected);

			if ( self.weapon == best ) // if had best weapon without ammo before, but have ammo now, change current to best as well
			{
				moon_swap_target_to_best_weapon(self, TRUE);
			} else {
				moon_set_target_currentammo(self);
			}

			sprint(self, "You bought");
			moon_print_target_container_ammo(self, selected);
			sprint(self, "\n");
			sound(self, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
			break;
		case MOON_WEAPON_MARKET_NETNAME:
			best = moon_get_target_best_weapon(self, TRUE); // Remember best weapon before buying ammo

			moon_target_consume_ammo_from(self, selected);

			self.items = (self.items | selected.items);

			if ( self.weapon == best ) // if had best weapon and bought better, change current to the best as well
			{
				moon_swap_target_to_best_weapon(self, TRUE);
			} else {
				moon_set_target_currentammo(self);
			}

			sprint(self, "You bought {0}\n", selected.targetname);
			sound(self, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
			break;
		case MOON_ITEM_ARMOR_NETNAME:
		case MOON_ITEM_RING_NETNAME:
			moon_target_wear_magic_item(self, selected);
			break;
	}

	if ( moon_pay_target_gold(self, selected.cost) == FALSE ) { return; }
	flash_self();

	selected.targetname = string_null;
	selected.owner.attack_finished = 0;
	selected.owner.stuck_time = 0;
	selected.owner.rstuck_time = 0;
	selected.owner.rstuck_org = selected.owner.origin;
	setmodel(selected, string_null);
	remove(selected);
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

void(entity trader) find_trade_spot =
{
	local entity head;
	local float r;

	while ( (head = find(head, classname, MOON_TRADE_SHOP_SPOT_CLASSNAME)) )
	{
		if ( head.prefix_four != trader.netname ) { continue; }
		if ( head.free == MOON_TRADE_STATE_OCCUPIED ) { continue; }
		if ( head.attack_finished >= time ) { continue; } // spot.attack_finished is time for next trade spots own (re-)fill check

		r = random();
		switch(trader.netname)
		{
		case MOON_TRADER_SHOP_ARMOR_NETNAME:
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
		case MOON_TRADER_SHOP_HEALTH_NETNAME:
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
		case MOON_TRADER_SHOP_AMMO_NETNAME:
			head.cnt = MOON_ITEM_TRADE_SIGNOF_AMMO;
			if ( r < 0.1 ) 	// was 0.2
			{
				moon_init_target_as_ammobox(head, MOON_AMMO_SHELLS_CODE);
			} else
			if ( r < 0.4 )	// was 0.4
			{
				moon_init_target_as_ammobox(head, MOON_AMMO_NAILS_CODE);
			} else
			if ( r < 0.7 )	// was 0.7
			{
				moon_init_target_as_ammobox(head, MOON_AMMO_ROCKETS_CODE);
			} else {
				moon_init_target_as_ammobox(head, MOON_AMMO_CELLS_CODE);
			}
			break;
		case MOON_TRADER_SHOP_WEAPON_NETNAME:
			head.cnt = MOON_ITEM_TRADE_SIGNOF_WEAPON;
			if ( r < 0.15 )
			{
				moon_init_target_as_weapon(head, MOON_WEAPON_SUPERSHOTGUN_CODE);
			} else
			if ( r < 0.3 )
			{
				moon_init_target_as_weapon(head, MOON_WEAPON_NAILGUN_CODE);
			} else
			if ( r < 0.45 )
			{
				moon_init_target_as_weapon(head, MOON_WEAPON_SUPERNAILGUN_CODE);
			} else
			if ( r < 0.6 )
			{
				moon_init_target_as_weapon(head, MOON_WEAPON_GRENADELAUNCHER_CODE);
			} else
			if ( r < 0.8 )
			{
				moon_init_target_as_weapon(head, MOON_WEAPON_ROCKETLAUNCHER_CODE);
			} else {
				moon_init_target_as_weapon(head, MOON_WEAPON_LIGHTNING_CODE);
			}
			break;
		}
		head.free = MOON_TRADE_STATE_OCCUPIED;
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
	self.free = MOON_TRADE_STATE_FREE;
	self.classname = MOON_TRADE_SHOP_SPOT_CLASSNAME;
	self.prefix_four = self.netname; // self.netname keeps linked Trader .netname, but we will use .netname later
	self.solid = SOLID_NOT;
	self.attack_finished = ( time + MOON_TRADE_SPOT_DELAY_INIT_MIN + (random() * MOON_TRADE_SPOT_DELAY_INIT_RANDOM) );
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
};

void() moon_buy_item =
{
	local entity head;
	local entity selected;
	local float min_dist;
	local float best;
	local float tempf;

	min_dist = 150;
	while ( (head = find(head, classname, MOON_TRADE_SHOP_SPOT_CLASSNAME)) )
	{
		if ( head.free == MOON_TRADE_STATE_OCCUPIED )
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
		sound(self, CHAN_ITEM, "misc/medkey.wav", 1, ATTN_NORM);
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
				sprint(self, "you \sdon't\s need it\n");
				return;
			}

			moon_overheal_target_player(self, selected.healamount);
		} else {
			if ( self.health >= self.max_health )
			{
				sprint(self, "you \sdon't\s need it\n");
				return;
			}

			moon_heal_target_player(self, selected.healamount);
		}
		sprint(self, "You bought {0} and healed {1}HP\n", selected.targetname, floor_ftos(selected.healamount));
		sound(self, CHAN_ITEM, selected.noise, 1, ATTN_NORM);
		selected.attack_finished = (time + MOON_TRADE_SPOT_HEALTH_DELAY_MIN + (random() * MOON_TRADE_SPOT_HEALTH_DELAY_RANDOM));
	} else
	if ( selected.cnt == MOON_ITEM_TRADE_SIGNOF_AMMO ) // Sign of Ammo
	{
		best = moon_get_target_best_weapon(self, TRUE); // Remember best weapon before buying ammo

		moon_target_consume_ammo_from(self, selected);

		sprint(self, "You bought {0} {1}\n", floor_ftos(selected.currentammo), selected.targetname);
		sound(self, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
		tempf = MOON_TRADE_SPOT_AMMO_DELAY_MIN / clampd(1, moon_get_current_player_count(), 4);
		selected.attack_finished = (time + tempf + (random() * MOON_TRADE_SPOT_AMMO_DELAY_RANDOM)); // Ammo respawn at shop faster the more players in game

		if ( self.weapon == best ) // if had best weapon without ammo before, but have ammo now, change current to best as well
		{
			moon_swap_target_to_best_weapon(self, TRUE);
		} else {
			moon_set_target_currentammo(self); // otherwise, at least update ammo count
		}

		selected.items = 0;
		selected.ammo_cells = 0;
		selected.ammo_rockets = 0;
		selected.ammo_nails = 0;
		selected.ammo_shells = 0;
		selected.currentammo = 0;
	} else
	if ( selected.cnt == MOON_ITEM_TRADE_SIGNOF_WEAPON ) // Sign of Weapon
	{
		best = moon_get_target_best_weapon(self, TRUE); // Remember best weapon before buying weapon with ammo

		moon_target_consume_ammo_from(self, selected);

		self.items = (self.items | selected.items);

		sprint(self, "You bought {0}\n", selected.targetname);
		sound(self, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
		selected.attack_finished = (time + MOON_TRADE_SPOT_WEAPON_DELAY_MIN + (random() * MOON_TRADE_SPOT_WEAPON_DELAY_RANDOM));

		if ( self.weapon == best ) // if had best weapon before, and bought better, change current to best as well
		{
			moon_swap_target_to_best_weapon(self, TRUE);
		} else {
			moon_set_target_currentammo(self); // otherwise, at least update ammo count
		}

		selected.items = 0;
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
	selected.free = MOON_TRADE_STATE_FREE;
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

	lv = who.lvl;
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

	newbot.classname = MOON_GUARD_CLASSNAME;
	newbot.prefix_one = MOON_GUARD_DISPLAYNAME;
	newbot.netname = moon_lookup_random_client_name();
	newbot.lvl = moon_get_max_player_level();

	moon_spawn_guard_items(newbot);
	bprint("== a wandering guardian joins your forces ==\n");
	moon_bprint_describe_player(newbot);

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
	newbot.skin = MOON_GUARD_SKIN;
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
			target.ring_rarity_level = MOON_ITEM_RARITY_THRESHOLD_TRASH;
			target.ring_typeone = MOON_ITEM_NONE;
			target.ring_typeone_value = 0;
			target.ring_prefixone = "";
			target.ring_typetwo = MOON_ITEM_NONE;
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

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	item.classname = MOON_ITEM_MAGIC_CLASSNAME;

	moon_init_target_as_magic_item(item);

	setsize(item, '-16 -16 0', '16 16 48');
	item.touch = moon_magic_item_touch;
	item.nextthink = (time + MOON_TIME_TO_DISAPPEAR_IMPORTANT);
	item.think = SUB_Remove;

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

void() HPTouch = // self - HP potion, other - player
{
	if (other.classname != MOON_PLAYER_CLASSNAME) { return; }
	if (other.health <= 0) { return; }

	if ( moon_heal_target_player(other, self.healamount) )
	{
		flash_target(other);
		sprint(other, "You get {0} and receive {1} health\n", self.netname, floor_ftos(self.healamount));
	} else {
		sprint(other, "You wasted {0}\n", self.netname);
	}

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
	if ( r < 0.15 )
	{
		moon_init_target_as_weapon(item, MOON_WEAPON_SUPERSHOTGUN_CODE, rint((random() * MOON_WEAPON_SUPERSHOTGUN_AMMO_LOOT_RANDOM) + MOON_WEAPON_SUPERSHOTGUN_AMMO_LOOT_MIN));
	} else
	if ( r < 0.3 )
	{
		moon_init_target_as_weapon(item, MOON_WEAPON_NAILGUN_CODE, rint((random() * MOON_WEAPON_NAILGUN_AMMO_LOOT_RANDOM) + MOON_WEAPON_NAILGUN_AMMO_LOOT_MIN));
	} else
	if ( r < 0.45 )
	{
		moon_init_target_as_weapon(item, MOON_WEAPON_SUPERNAILGUN_CODE, rint((random() * MOON_WEAPON_SUPERNAILGUN_AMMO_LOOT_RANDOM) + MOON_WEAPON_SUPERNAILGUN_AMMO_LOOT_MIN));
	} else
	if ( r < 0.6 )
	{
		moon_init_target_as_weapon(item, MOON_WEAPON_GRENADELAUNCHER_CODE, rint((random() * MOON_WEAPON_GRENADELAUNCHER_AMMO_LOOT_RANDOM) + MOON_WEAPON_GRENADELAUNCHER_AMMO_LOOT_MIN));
	} else
	if ( r < 0.8 )
	{
		moon_init_target_as_weapon(item, MOON_WEAPON_ROCKETLAUNCHER_CODE, rint((random() * MOON_WEAPON_ROCKETLAUNCHER_AMMO_LOOT_RANDOM) + MOON_WEAPON_ROCKETLAUNCHER_AMMO_LOOT_MIN));
	} else {
		moon_init_target_as_weapon(item, MOON_WEAPON_LIGHTNING_CODE, rint((random() * MOON_WEAPON_LIGHTNING_AMMO_LOOT_RANDOM) + MOON_WEAPON_LIGHTNING_AMMO_LOOT_MIN));
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

	// KILLME
	if ( random() < 0.17 )
	{
		spawned_object = moon_spawn_drop_magic_item(self);
		spawned_object.nextthink = (time + MOON_TIME_TO_DISAPPEAR_TRASH);
	}
	//

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

void() GiveExp = // this used in so many monster classes
{
	moon_grant_all_exp(self.exp); // so easier to put a wrapper here
};