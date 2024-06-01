//Decompiled code. Please respect the original copyright.
void() W_SetCurrentAmmo;

void() SUB_regen =
{
	self.model = self.mdl;
	self.solid = SOLID_TRIGGER;
	sound(self, CHAN_VOICE, "items/itembk2.wav", WF_DEFEND, ATTN_NORM);
	setorigin(self, self.origin);
};

void() noclass =
{
	dprint("noclass spawned at");
	dprint(vtos(self.origin));
	dprint("\n");
	remove(self);
};

void() PlaceItem =
{
	local float oldz;

	self.mdl = self.model;
	self.flags = FL_ITEM;
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.velocity = VEC_ORIGIN;
	self.origin_z = (self.origin_z + LOGIC_HUNTENEMY);
	oldz = self.origin_z;
	if (!droptofloor())
	{
		dprint("Bonus item fell out of level at ");
		dprint(vtos(self.origin));
		dprint("\n");
		remove(self);
		return;
	}
};

void() StartItem =
{
	self.nextthink = (time + MON_REACTIONTIME);
	self.think = PlaceItem;
};

float(entity e, float healamount, float ignore) T_Heal =
{
	if ((e.health <= WF_NORMAL))
	{
		return (WF_NORMAL);
	}
	if ((!ignore && (e.health >= e.max_health)))
	{
		return (WF_NORMAL);
	}
	healamount = ceil(healamount);
	e.health = (e.health + healamount);
	if ((!ignore && (e.health >= e.max_health)))
	{
		e.health = e.max_health;
	}
	if ((e.health > 999))
	{
		e.health = 999;
	}
	return (WF_DEFEND);
};

float(entity e, float healamount) T_Mana =
{
	if ((e.mana >= e.max_mana))
	{
		return (WF_NORMAL);
	}
	healamount = ceil(healamount);
	e.mana = (e.mana + healamount);
	if ((e.mana >= e.max_mana))
	{
		e.mana = e.max_mana;
	}
	return (WF_DEFEND);
};
float H_ROTTEN    = 1;
float H_MEGA    = 2;
.float healamount;
.float healtype;
void() health_touch;
void() item_megahealth_rot;

void() item_health =
{
	self.touch = health_touch;
	if ((self.spawnflags & H_ROTTEN))
	{
		setmodel(self, "maps/b_bh10.bsp");
		self.noise = "items/r_item1.wav";
		self.healamount = 15;
		self.healtype = WF_NORMAL;
	}
	else
	{
		if ((self.spawnflags & H_MEGA))
		{
			setmodel(self, "maps/b_bh100.bsp");
			self.noise = "items/r_item2.wav";
			self.healamount = 100;
			self.healtype = WF_EXTRASIZE;
		}
		else
		{
			setmodel(self, "maps/b_bh25.bsp");
			self.noise = "items/health1.wav";
			self.healamount = 25;
			self.healtype = WF_DEFEND;
		}
	}
	setsize(self, VEC_ORIGIN, '32 32 56');
	StartItem();
};

void() health_touch =
{
	local float amount;
	local string s;

	if ((other.classname != "player"))
	{
		return;
	}
	if ((self.healtype == WF_EXTRASIZE))
	{
		if ((other.health >= (other.max_health + 250)))
		{
			return;
		}
		if (!T_Heal(other, self.healamount, WF_DEFEND))
		{
			return;
		}
	}
	else
	{
		if (!T_Heal(other, self.healamount, WF_NORMAL))
		{
			return;
		}
	}
	sprint(other, "You receive ");
	s = ftos(self.healamount);
	sprint(other, s);
	sprint(other, " health\n");
	sound(other, CHAN_ITEM, self.noise, WF_DEFEND, ATTN_NORM);
	stuffcmd(other, "bf\n");
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
		other.health = (other.health - WF_DEFEND);
		self.nextthink = (time + WF_DEFEND);
		return;
	}
	other.items = (other.items - (other.items & IT_SUPERHEALTH));
	remove(self);
};

void() armor_touch =
{
	local float type;
	local float value;
	local float bit;

	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	if ((other.classname != "player"))
	{
		return;
	}
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
	other.items = ((other.items - (other.items & ((IT_ARMOR1 | IT_ARMOR2) | IT_ARMOR3))) + bit);
	self.solid = SOLID_NOT;
	self.model = string_null;
	if ((deathmatch == WF_DEFEND))
	{
		self.nextthink = (time + GRD_PATROLTIME);
	}
	self.think = SUB_regen;
	sprint(other, "You got armor\n");
	sound(other, CHAN_ITEM, "items/armor1.wav", WF_DEFEND, ATTN_NORM);
	stuffcmd(other, "bf\n");
	activator = other;
	SUB_UseTargets();
};

void() item_armor1 =
{
	self.touch = armor_touch;
	precache_model("progs/armor.mdl");
	setmodel(self, "progs/armor.mdl");
	self.skin = WF_NORMAL;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() item_armor2 =
{
	self.touch = armor_touch;
	precache_model("progs/armor.mdl");
	setmodel(self, "progs/armor.mdl");
	self.skin = WF_DEFEND;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() item_armorInv =
{
	self.touch = armor_touch;
	precache_model("progs/armor.mdl");
	setmodel(self, "progs/armor.mdl");
	self.skin = WF_EXTRASIZE;
	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
};

void() bound_other_ammo =
{
	if ((other.ammo_shells > 100))
	{
		other.ammo_shells = 100;
	}
	if ((other.ammo_nails > 200))
	{
		other.ammo_nails = 200;
	}
	if ((other.ammo_rockets > 100))
	{
		other.ammo_rockets = 100;
	}
	if ((other.ammo_cells > 100))
	{
		other.ammo_cells = 100;
	}
};

void() bound_self_ammo =
{
	if ((self.ammo_shells > 100))
	{
		self.ammo_shells = 100;
	}
	if ((self.ammo_nails > 200))
	{
		self.ammo_nails = 200;
	}
	if ((self.ammo_rockets > 100))
	{
		self.ammo_rockets = 100;
	}
	if ((self.ammo_cells > 100))
	{
		self.ammo_cells = 100;
	}
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
	local float hadammo;
	local float best;
	local float new;
	local float old;
	local entity stemp;
	local float leave;

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
	if (!(other.items & self.items))
	{
		other.items = (other.items + self.items);
	}
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;
	sprint(other, "You got the ");
	sprint(other, self.netname);
	sprint(other, "\n");
	sound(other, CHAN_ITEM, "weapons/pkup.wav", WF_DEFEND, ATTN_NORM);
	stuffcmd(other, "bf\n");
	bound_other_ammo();
	old = other.weapon;
	stemp = self;
	self = other;
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
	local string s;

	if ((other.classname != "player"))
	{
		return;
	}
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;
	other.ammo_shells = (other.ammo_shells + self.ammo_shells);
	other.ammo_nails = (other.ammo_nails + self.ammo_nails);
	other.ammo_rockets = (other.ammo_rockets + self.ammo_rockets);
	other.ammo_cells = (other.ammo_cells + self.ammo_cells);
	bound_other_ammo();
	if (self.ammo_shells)
	{
		sprint(other, "You get ");
		s = ftos(self.ammo_shells);
		sprint(other, s);
		sprint(other, " shells");
	}
	if (self.ammo_nails)
	{
		sprint(other, "You get ");
		s = ftos(self.ammo_nails);
		sprint(other, s);
		sprint(other, " nails");
	}
	if (self.ammo_rockets)
	{
		sprint(other, "You get ");
		s = ftos(self.ammo_rockets);
		sprint(other, s);
		sprint(other, " rockets");
	}
	if (self.ammo_cells)
	{
		sprint(other, "You get ");
		s = ftos(self.ammo_cells);
		sprint(other, s);
		sprint(other, " cells");
	}
	sprint(other, "\n");
	sound(other, CHAN_ITEM, "weapons/lock4.wav", WF_DEFEND, ATTN_NORM);
	stuffcmd(other, "bf\n");
	if ((other.weapon == best))
	{
		stemp = self;
		self = other;
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		self = stemp;
	}
	stemp = self;
	self = other;
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
	local entity stemp;
	local float best;

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
	stuffcmd(other, "bf\n");
	self.solid = SOLID_NOT;
	other.items = (other.items | self.items);
	self.model = string_null;
	if ((self.classname == "item_artifact_envirosuit"))
	{
		other.rad_time = WF_DEFEND;
		other.radsuit_finished = (time + MON_CAMPTIME);
	}
	if ((self.classname == "item_artifact_invulnerability"))
	{
		other.invincible_time = WF_DEFEND;
		other.invincible_finished = (time + MON_CAMPTIME);
	}
	if ((self.classname == "item_artifact_invisibility"))
	{
		other.invisible_time = WF_DEFEND;
		other.invisible_finished = (time + MON_CAMPTIME);
	}
	if ((self.classname == "item_artifact_super_damage"))
	{
		other.super_time = WF_DEFEND;
		other.super_damage_finished = (time + MON_CAMPTIME);
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
	local string s;
	local float best;
	local float old;
	local float new;
	local entity stemp;
	local float acount;

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
	bound_other_ammo();
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
	stuffcmd(other, "bf\n");
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

	r = rint(((random() * 26) + WF_DEFEND));
	if ((r == WF_DEFEND))
	{
		e.prefix_three = " of slaughter";
		makeaura(e, WF_DEFEND);
		e.prefix_value = MON_REACTIONTIME;
		e.prefix = WF_DEFEND;
	}
	else
	{
		if ((r == WF_EXTRASIZE))
		{
			e.prefix_three = " of violence";
			makeaura(e, WF_DEFEND);
			e.prefix_value = MON_STUCKTIME;
			e.prefix = WF_DEFEND;
		}
		else
		{
			if ((r == LOGIC_FINDDEFEND))
			{
				e.prefix_three = " in snake armor";
				e.prefix_value = MON_REACTIONTIME;
				e.prefix = WF_EXTRASIZE;
			}
			else
			{
				if ((r == LOGIC_DEFEND))
				{
					e.prefix_three = " in demon skin";
					e.prefix_value = MON_BACKTIME;
					e.health = (e.health * 2.5);
					e.exp = (e.exp * WF_EXTRASIZE);
					e.prefix = WF_EXTRASIZE;
				}
				else
				{
					if ((r == LOGIC_PATROL))
					{
						e.prefix_three = " in bear armor";
						e.prefix_value = WF_DEFEND;
						e.prefix = WF_EXTRASIZE;
					}
					else
					{
						if ((r == LOGIC_HUNTENEMY))
						{
							e.prefix_three = " of weakness";
							e.health = rint((e.health / WF_EXTRASIZE));
						}
						else
						{
							if ((r == TE_WIZSPIKE))
							{
								e.prefix_three = " the profitable";
								e.exp = rint((e.exp * CL_DEADTIME));
							}
							else
							{
								if ((r == KEY_MOVERIGHT))
								{
									e.prefix_three = " the rip";
									e.exp = WF_DEFEND;
									e.health = GRD_PATROLTIME;
								}
								else
								{
									if ((r == TE_LIGHTNING3))
									{
										e.prefix_three = " the warrior";
										e.prefix = LOGIC_FINDDEFEND;
									}
									else
									{
										if ((r == TE_LAVASPLASH))
										{
											e.prefix_three = " the hunter";
											e.prefix = LOGIC_FINDDEFEND;
										}
										else
										{
											if ((r == TE_TELEPORT))
											{
												e.prefix_three = " of regeneration";
												e.prefix = LOGIC_DEFEND;
												e.prefix_value = LOGIC_FINDDEFEND;
											}
											else
											{
												if ((r == 12))
												{
													e.prefix_three = " of great reshape";
													e.prefix = LOGIC_DEFEND;
													e.prefix_value = TE_LAVASPLASH;
												}
												else
												{
													if ((r == 13))
													{
														e.prefix_three = " the rich";
														e.prefix = LOGIC_PATROL;
														e.prefix_value = 200;
													}
													else
													{
														if ((r == 14))
														{
															e.prefix_three = " the treasurer";
															e.prefix = LOGIC_PATROL;
															e.prefix_value = GRD_FIGHTDIST;
														}
														else
														{
															if ((r == 15))
															{
																e.prefix_three = " the millioner";
																e.prefix = LOGIC_PATROL;
																e.prefix_value = 1000;
															}
															else
															{
																if ((r == KEY_MOVEFORWARD))
																{
																	e.prefix_three = " the petard";
																	e.prefix = LOGIC_HUNTENEMY;
																	e.prefix_value = 120;
																}
																else
																{
																	if ((r == 17))
																	{
																		e.prefix_three = " the bomb";
																		e.prefix = LOGIC_HUNTENEMY;
																		e.prefix_value = 220;
																	}
																	else
																	{
																		if ((r == 18))
																		{
																			e.prefix_three = " the nuclear";
																			e.prefix = LOGIC_HUNTENEMY;
																			e.prefix_value = 420;
																		}
																		else
																		{
																			if ((r == 19))
																			{
																				makeaura(e, H_ROTTEN);
																				e.prefix_three = " the chosen";
																				e.prefix = TE_WIZSPIKE;
																				e.prefix_value = 50;
																			}
																			else
																			{
																				if ((r == GRD_PATROLTIME))
																				{
																					makeaura(e, H_ROTTEN);
																					e.prefix_three = " of destroying";
																					e.prefix = TE_WIZSPIKE;
																					e.prefix_value = 100;
																				}
																				else
																				{
																					if ((r == 21))
																					{
																						makeaura(e, H_ROTTEN);
																						e.prefix_three = " of humiliation";
																						e.prefix = TE_WIZSPIKE;
																						e.prefix_value = 200;
																					}
																					else
																					{
																						if ((r == 22))
																						{
																							makeaura(e, H_ROTTEN);
																							e.prefix_three = " of world erasing";
																							e.prefix = TE_WIZSPIKE;
																							e.prefix_value = 300;
																						}
																						else
																						{
																							if ((r == SVC_TEMPENTITY))
																							{
																								e.prefix_three = " of resistance";
																								e.prefix = KEY_MOVERIGHT;
																								e.prefix_value = MON_CAMPTIME;
																							}
																							else
																							{
																								if ((r == 24))
																								{
																									e.prefix_three = " in wood armor";
																									e.prefix = KEY_MOVERIGHT;
																									e.prefix_value = GRD_DEFENDTIME;
																								}
																								else
																								{
																									if ((r == 25))
																									{
																										e.prefix_three = " in bronze armor";
																										e.prefix = KEY_MOVERIGHT;
																										e.prefix_value = 60;
																									}
																									else
																									{
																										if ((r == 26))
																										{
																											e.prefix_three = " of failure";
																											e.prefix = TE_LIGHTNING3;
																											e.prefix_value = MON_CAMPTIME;
																										}
																										else
																										{
																											if ((r == SVC_KILLEDMONSTER))
																											{
																												e.prefix_three = " of receive";
																												e.prefix = TE_LIGHTNING3;
																												e.prefix_value = 60;
																											}
																											else
																											{
																												if ((r == SVC_FOUNDSECRET))
																												{
																													e.prefix_three = " of cry";
																													e.prefix = TE_LIGHTNING3;
																													e.prefix_value = MENTAT_TIME;
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
								}
							}
						}
					}
				}
			}
		}
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
					sound(e, CHAN_AUTO, "moon/ambient/quake.wav", H_ROTTEN, ATTN_NORM);
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

void(float dl, float el) earthquake =
{
	local entity e;

	if ((el < KEY_LOOKUP))
	{
		el = KEY_LOOKUP;
	}
	e = spawn();
	e.think = do_earthquake;
	e.delay = el;
	e.nextthink = (time + H_ROTTEN);
	e.attack_finished = ((time + dl) + (random() * dl));
};

void() misc_head =
{
	setmodel(self, self.netname);
};

void() flr_think =
{
	if ((sv_alwaysday == H_ROTTEN))
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

void() flr =
{
	lightstyle(KEY_MOVEBACK, "n");
	self.count = H_ROTTEN;
	self.weapon = H_ROTTEN;
	self.spawnflags = KEY_LOOKRIGHT;
	self.nextthink = (time + TE_LAVASPLASH);
	self.think = flr_think;
};

void() moon4_touch =
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
		bprint("ERROR: movecode has requested nonexistent way (");
		bprint_ftos(other.wantline);
		bprint(" line was requested). Please report this bug.\n");
	}
	if ((other.mon_logic == LOGIC_CAMPER))
	{
		if ((other.flags & FL_MONSTER))
		{
			if (((other.wantline == self.line) && (other.wantnum == self.num)))
			{
				other.goalentity = world;
				other.mon_logic = LOGIC_STANDART;
				other.camp_time = ((time + MON_CAMPTIME) + (random() * MON_CAMPTIME));
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
			e.ammo_nails = rint((random() * MON_CAMPTIME));
			e.cost = (70 + e.ammo_nails);
			e.targetname = "Inferioity Nailgun";
			e.items = IT_NAILGUN;
		}
		else
		{
			if ((r < MON_BACKTIME))
			{
				setmodel(e, "progs/g_nail2.mdl");
				e.ammo_nails = rint((random() * MON_CAMPTIME));
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
		e.skin = WF_NORMAL;
		e.armorvalue = (50 + rint((random() * 50)));
		e.armortype = 0.3;
		e.items = IT_ARMOR1;
		e.cost = rint((e.armorvalue * MON_BACKTIME));
	}
	else
	{
		if ((r < 0.7))
		{
			e.skin = H_ROTTEN;
			e.armorvalue = (100 + rint((random() * 50)));
			e.armortype = 0.6;
			e.items = IT_ARMOR2;
			e.cost = rint((e.armorvalue * 0.6));
		}
		else
		{
			e.skin = H_MEGA;
			e.armorvalue = (150 + rint((random() * 50)));
			e.armortype = 0.8;
			e.items = IT_ARMOR3;
			e.cost = rint((e.armorvalue * 0.7));
		}
	}
};

void(entity e) GenerateMagicCost =
{
	local float ccost;

	ccost = H_ROTTEN;
	if ((e.magic_typeone == H_ROTTEN))
	{
		ccost = (ccost + (e.magic_typeone_value * 45));
	}
	if ((e.magic_typeone == H_MEGA))
	{
		ccost = (ccost + (e.magic_typeone_value * 65));
	}
	if ((e.magic_typeone == LOGIC_FINDDEFEND))
	{
		ccost = (ccost + (e.magic_typeone_value * 25));
	}
	if ((e.magic_typeone == LOGIC_DEFEND))
	{
		ccost = (ccost + (e.magic_typeone_value * 50));
	}
	if ((e.magic_typeone == LOGIC_PATROL))
	{
		ccost = (ccost + (e.magic_typeone_value * GRD_PATROLTIME));
	}
	if ((e.magic_typeone == LOGIC_HUNTENEMY))
	{
		ccost = (ccost + (e.magic_typeone_value * 70));
	}
	if ((e.magic_typeone == TE_WIZSPIKE))
	{
		ccost = (ccost + (e.magic_typeone_value * GRD_FIGHTDIST));
	}
	if ((e.magic_typeone == KEY_MOVERIGHT))
	{
		ccost = (ccost + (e.magic_typeone_value * 100));
	}
	if ((e.magic_typetwo == H_ROTTEN))
	{
		ccost = (ccost + (e.magic_typetwo_value * 45));
	}
	if ((e.magic_typetwo == H_MEGA))
	{
		ccost = (ccost + (e.magic_typetwo_value * 65));
	}
	if ((e.magic_typetwo == LOGIC_FINDDEFEND))
	{
		ccost = (ccost + (e.magic_typetwo_value * 25));
	}
	if ((e.magic_typetwo == LOGIC_DEFEND))
	{
		ccost = (ccost + (e.magic_typetwo_value * 50));
	}
	if ((e.magic_typetwo == LOGIC_PATROL))
	{
		ccost = (ccost + (e.magic_typetwo_value * GRD_PATROLTIME));
	}
	if ((e.magic_typetwo == LOGIC_HUNTENEMY))
	{
		ccost = (ccost + (e.magic_typetwo_value * 70));
	}
	if ((e.magic_typetwo == TE_WIZSPIKE))
	{
		ccost = (ccost + (e.magic_typetwo_value * GRD_FIGHTDIST));
	}
	if ((e.magic_typetwo == KEY_MOVERIGHT))
	{
		ccost = (ccost + (e.magic_typetwo_value * 100));
	}
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
		e.ammo_rockets = ceil((15 + (random() * TE_LAVASPLASH)));
		e.cost = ceil((e.ammo_rockets * LOGIC_HUNTENEMY));
		e.targetname = "rockets";
	}
	else
	{
		setmodel(e, "maps/b_batt0.bsp");
		e.ammo_cells = ceil((15 + (random() * TE_WIZSPIKE)));
		e.cost = ceil((e.ammo_cells * KEY_MOVERIGHT));
		e.targetname = "cells";
	}
};

void() PlaceElixir =
{
	local entity e;

	e = spawn();
	makevectors(self.angles);
	setorigin(e, ((self.origin + (v_forward * 47)) - '0 0 24'));
	e.solid = SOLID_NOT;
	e.classname = "goody_ent";
	e.netname = "goody_elixir";
	e.skin = H_MEGA;
	setmodel(e, "progs/potion.mdl");
	e.noise1 = "moon/items/potion.wav";
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", H_ROTTEN, ATTN_NORM);
	if ((random() < MON_BACKTIME))
	{
		e.targetname = "ÂÏÈ¯ÈÚ†ÔÊ†ˆÈÙ·ÏÈÙ˘ (+1 to vitality)";
		e.healtype = WF_NORMAL;
		e.cost = 2000;
	}
	else
	{
		e.targetname = "ÂÏÈ¯ÈÚ†ÔÊ†ÛÙÚÂÓÁÙË (+1 to strength)";
		e.healtype = H_ROTTEN;
		e.cost = 3000;
	}
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
		e.netname = "·ÚÌÔÚ";
		setmodel(e, "progs/armor.mdl");
		e.skin = LOGIC_FINDDEFEND;
		e.noise1 = "items/armor1.wav";
	}
	else
	{
		e.netname = "ÚÈÓÁ";
		setmodel(e, "progs/ring.mdl");
		e.noise1 = "moon/items/ring.wav";
	}
	e.owner = self;
	sound(e, CHAN_ITEM, "items/itembk2.wav", H_ROTTEN, ATTN_NORM);
	z = random();
	if ((z < 0.3))
	{
		GenerateMagic(e);
	}
	else
	{
		if ((z < 0.6))
		{
			GenerateMagic2(e);
		}
		else
		{
			GenerateMagic(e);
			GenerateMagic2(e);
		}
	}
	GenerateMagicCost(e);
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
	self.nextthink = ((time + 15) + (TE_LAVASPLASH * random()));
	self.think = sale_think;
};

void() sale_brain =
{
	local entity e;

	e = spawn();
	e.nextthink = ((time + GRD_PATROLTIME) + (H_MEGA * random()));
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
	other.wantnum = H_MEGA;
	other.action = LOGIC_FINDDEFEND;
	other.cnt = self.angles_y;
	other.ideal_yaw = self.angles_y;
	other.goalentity = world;
	self.enemy = other;
	self.free = FALSE;
	other.free = H_ROTTEN;
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
		nextnum = (self.num + H_ROTTEN);
	}
	if ((other.wantnum < self.num))
	{
		nextnum = (self.num - H_ROTTEN);
	}
	if (((other.action == H_MEGA) && (self.num == H_MEGA)))
	{
		remove(other);
		return;
	}
	if ((((other.action == H_ROTTEN) && (self.num < LOGIC_DEFEND)) || (other.action == H_MEGA)))
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
		while (H_ROTTEN)
		{
			zzz = rint((random() * LOGIC_PATROL));
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

void() buy_goody =
{
	local entity head;
	local entity selected;
	local float min_dist;
	local entity mega;
	local float best;

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
		if ((self.gold < selected.cost))
		{
			sprint(self, "not enough gold\n");
			return;
		}
		if ((selected.netname == "goody_armor"))
		{
			if (((self.armortype * self.armorvalue) >= (selected.armortype * selected.armorvalue)))
			{
				sprint(self, "you don't need it\n");
				return;
			}
			self.armortype = selected.armortype;
			self.armorvalue = selected.armorvalue;
			self.items = ((self.items - (self.items & ((IT_ARMOR1 | IT_ARMOR2) | IT_ARMOR3))) + selected.items);
			sound(self, CHAN_ITEM, "items/armor1.wav", H_ROTTEN, ATTN_NORM);
		}
		else
		{
			if ((selected.netname == "goody_mega"))
			{
				if ((self.health >= (self.max_health + 150)))
				{
					return;
				}
				if ((self.health >= 999))
				{
					return;
				}
				if ((selected.healtype == H_MEGA))
				{
					T_Heal(self, selected.healamount, H_ROTTEN);
					if (!(self.items & IT_SUPERHEALTH))
					{
						mega = spawn();
						mega.nextthink = (time + LOGIC_PATROL);
						mega.think = item_megahealth_rot;
						mega.owner = self;
						self.items = (self.items | IT_SUPERHEALTH);
					}
				}
				sound(self, CHAN_ITEM, selected.noise1, H_ROTTEN, ATTN_NORM);
			}
			else
			{
				if ((selected.netname == "goody_elixir"))
				{
					sprint(self, "You buy ");
					sprint(self, selected.targetname);
					sprint(self, "\n");
					sound(self, CHAN_ITEM, selected.noise1, H_ROTTEN, ATTN_NORM);
					if ((selected.healtype == WF_NORMAL))
					{
						self.vit = (self.vit + H_ROTTEN);
						self.max_health = (self.max_health + H_MEGA);
						T_Heal(self, H_MEGA, WF_NORMAL);
					}
					if ((selected.healtype == H_ROTTEN))
					{
						self.stre = (self.stre + H_ROTTEN);
					}
				}
				else
				{
					if ((selected.netname == "goody_ammo"))
					{
						best = W_BestWeapon();
						self.ammo_shells = (self.ammo_shells + selected.ammo_shells);
						self.ammo_nails = (self.ammo_nails + selected.ammo_nails);
						self.ammo_rockets = (self.ammo_rockets + selected.ammo_rockets);
						self.ammo_cells = (self.ammo_cells + selected.ammo_cells);
						bound_self_ammo();
						if (selected.ammo_shells)
						{
							sprint(self, "You buy ");
							sprint_ftos(self, selected.ammo_shells);
							sprint(self, " shells\n");
						}
						else
						{
							if (selected.ammo_nails)
							{
								sprint(self, "You buy ");
								sprint_ftos(self, selected.ammo_nails);
								sprint(self, " nails\n");
							}
							else
							{
								if (selected.ammo_rockets)
								{
									sprint(self, "You buy ");
									sprint_ftos(self, selected.ammo_rockets);
									sprint(self, " rockets\n");
								}
								else
								{
									if (selected.ammo_cells)
									{
										sprint(self, "You buy ");
										sprint_ftos(self, selected.ammo_cells);
										sprint(self, " cells\n");
									}
									else
									{
										sprint(self, "ERROR: garbage shop have incorrect items! Report this bug!\n");
									}
								}
							}
						}
						sound(self, CHAN_ITEM, "weapons/lock4.wav", H_ROTTEN, ATTN_NORM);
						if ((self.weapon == best))
						{
							self.weapon = W_BestWeapon();
							W_SetCurrentAmmo();
						}
						W_SetCurrentAmmo();
					}
					else
					{
						if (((selected.netname == "·ÚÌÔÚ") || (selected.netname == "ÚÈÓÁ")))
						{
							other = selected;
							wearitem();
						}
						else
						{
							if ((selected.netname == "goody_weapon"))
							{
								best = W_BestWeapon();
								self.ammo_shells = (self.ammo_shells + selected.ammo_shells);
								self.ammo_nails = (self.ammo_nails + selected.ammo_nails);
								self.ammo_rockets = (self.ammo_rockets + selected.ammo_rockets);
								self.ammo_cells = (self.ammo_cells + selected.ammo_cells);
								bound_self_ammo();
								self.items = (self.items | selected.items);
								sprint(self, "You buy ");
								sprint(self, selected.targetname);
								sprint(self, "\n");
								sound(self, CHAN_ITEM, "weapons/pkup.wav", H_ROTTEN, ATTN_NORM);
								if ((self.weapon == best))
								{
									self.weapon = W_BestWeapon();
								}
								W_SetCurrentAmmo();
							}
						}
					}
				}
			}
		}
		selected.owner.attack_finished = WF_NORMAL;
		selected.owner.stuck_time = WF_NORMAL;
		selected.owner.rstuck_time = WF_NORMAL;
		selected.owner.rstuck_org = selected.owner.origin;
		self.gold = (self.gold - selected.cost);
		setmodel(selected, string_null);
		stuffcmd(self, "bf\n");
		sprint_ftos(self, self.gold);
		sprint(self, " gold left\n");
		remove(selected);
	}
};

void() indefy_goody =
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
		sprint(self, "====== ÈÓ‰ÂÊ˘†ÈÙÂÌ ======\n");
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
						sprint(self, "Red");
					}
				}
			}
			sprint(self, " armor. Cost: ");
		}
		else
		{
			if ((selected.netname == "goody_elixir"))
			{
				sprint(self, selected.targetname);
				sprint(self, ". Cost: ");
			}
			else
			{
				if ((selected.netname == "goody_ammo"))
				{
					if (selected.ammo_shells)
					{
						sprint_ftos(self, selected.ammo_shells);
						sprint(self, " shells. Cost: ");
					}
					if (selected.ammo_nails)
					{
						sprint_ftos(self, selected.ammo_nails);
						sprint(self, " nails. Cost: ");
					}
					if (selected.ammo_rockets)
					{
						sprint_ftos(self, selected.ammo_rockets);
						sprint(self, " rockets. Cost: ");
					}
					if (selected.ammo_cells)
					{
						sprint_ftos(self, selected.ammo_cells);
						sprint(self, " cells. Cost: ");
					}
				}
				else
				{
					if ((selected.netname == "goody_weapon"))
					{
						sprint(self, selected.targetname);
						sprint(self, ". Cost: ");
					}
					else
					{
						if ((selected.netname == "goody_mega"))
						{
							sprint(self, "Used megahealth. Cost: ");
						}
						else
						{
							if (((selected.netname == "·ÚÌÔÚ") || (selected.netname == "ÚÈÓÁ")))
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
		if (((selected.netname != "·ÚÌÔÚ") && (selected.netname != "ÚÈÓÁ")))
		{
			sprint_ftos(self, selected.cost);
			sprint(self, "\n");
		}
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

	self.nextthink = ((time + 12) + (random() * 12));
	self.think = derrick_think;
	head = findradius(self.origin, 250);
	while (head)
	{
		if ((head.classname == "player"))
		{
			if ((head.health > WF_NORMAL))
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
	e.classname = "derrick";
	setmodel(e, "progs/derrick.mdl");
	setsize(e, VEC_HULL_MIN, '16 16 24');
	e.solid = SOLID_BBOX;
	e.nextthink = ((time + LOGIC_HUNTENEMY) + (random() * TE_WIZSPIKE));
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

	if ((gameover == TRUE))
	{
		remove(self);
		return;
	}
	if ((random() < AMBIENT_RATE))
	{
		r = rint((random() * 12));
		if (((r >= KEY_MOVERIGHT) && (r <= TE_LAVASPLASH)))
		{
			earthquake('12 0 0', (random() * 160));
			if ((random() < MON_CAMPERCHANCE))
			{
				d = rint((random() * TE_LIGHTNING3));
				if ((d == WF_NORMAL))
				{
					bprint("jesus: please report this bug to meteo-center :))\n");
				}
				else
				{
					if ((d == H_ROTTEN))
					{
						bprint("jesus: DO NOT shake the earth, fucking demons!\n");
					}
					else
					{
						if ((d == H_MEGA))
						{
							bprint("jesus: wow, what a frenzy!!!\n");
						}
						else
						{
							if ((d == LOGIC_FINDDEFEND))
							{
								bprint("jesus: heh, an earth quake!\n");
							}
							else
							{
								if ((d == LOGIC_DEFEND))
								{
									bprint("jesus: quake is just a cool name for a game\n");
								}
								else
								{
									if ((d == LOGIC_PATROL))
									{
										bprint("jesus: come to vault 13\n");
									}
									else
									{
										if ((d == LOGIC_HUNTENEMY))
										{
											bprint("jesus: visit: http://powersite.narod.ru\n");
										}
										else
										{
											if ((d == TE_WIZSPIKE))
											{
												bprint("jesus: your castle will be your graveyard\n");
											}
											else
											{
												if ((d == KEY_MOVERIGHT))
												{
													bprint("jesus: bring me 10000 gold and i'll give you invulnerability\n");
												}
											}
										}
									}
								}
							}
						}
					}
				}
				makechatnoise();
			}
		}
	}
	self.nextthink = ((time + 60) + (60 * random()));
	self.think = jesus_think;
};

void() jesus_brain =
{
	local entity e;

	e = spawn();
	e.nextthink = ((time + MON_CAMPTIME) + (60 * random()));
	e.think = jesus_think;
};

void() set_map =
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
		if (droptofloor(WF_NORMAL, WF_NORMAL))
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
			if ((self.currentammo == WF_NORMAL))
			{
				self.goalentity = FindClosestWaypoint();
				self.th_run();
			}
			return;
		}
	}
};

void(entity who) find_trade_spot =
{
	local entity head;
	local float r;

	head = find(world, classname, "trade_spot");
	while (head)
	{
		if ((head.netname == self.netname))
		{
			if ((head.free == TRUE))
			{
				if ((head.attack_finished < time))
				{
					r = random();
					if ((self.netname == "armor_trader"))
					{
						setmodel(head, "progs/armor.mdl");
						if ((r < GRD_DEFENDCHANCE))
						{
							head.skin = WF_NORMAL;
							head.armorvalue = 100;
							head.armortype = 0.3;
							head.items = IT_ARMOR1;
							head.cost = 50;
						}
						else
						{
							if ((r < 0.75))
							{
								head.skin = H_ROTTEN;
								head.armorvalue = 150;
								head.armortype = 0.6;
								head.items = IT_ARMOR2;
								head.cost = 100;
							}
							else
							{
								head.skin = H_MEGA;
								head.armorvalue = 200;
								head.armortype = 0.8;
								head.items = IT_ARMOR3;
								head.cost = 150;
							}
						}
					}
					else
					{
						if ((self.netname == "health_trader"))
						{
							if ((r < 0.6))
							{
								setmodel(head, "maps/b_bh10.bsp");
								head.noise = "items/r_item1.wav";
								head.healamount = 15;
								head.healtype = WF_NORMAL;
								head.cost = GRD_PATROLTIME;
								head.items = IT_SUPERHEALTH;
							}
							else
							{
								if ((r < 0.9))
								{
									setmodel(head, "maps/b_bh25.bsp");
									head.noise = "items/health1.wav";
									head.healamount = 25;
									head.healtype = H_ROTTEN;
									head.cost = MON_CAMPTIME;
									head.items = IT_SUPERHEALTH;
								}
								else
								{
									setmodel(head, "maps/b_bh100.bsp");
									head.noise = "items/r_item2.wav";
									head.healamount = 100;
									head.healtype = H_MEGA;
									head.cost = 100;
									head.items = IT_SUPERHEALTH;
								}
							}
						}
						else
						{
							if ((self.netname == "ammo_trader"))
							{
								head.cnt = H_MEGA;
								if ((r < MON_REACTIONTIME))
								{
									setmodel(head, "maps/b_shell0.bsp");
									head.ammo_shells = ceil((TE_LAVASPLASH + (random() * GRD_PATROLTIME)));
									head.cost = ceil((head.ammo_shells * 0.7));
								}
								else
								{
									if ((r < MON_STUCKTIME))
									{
										setmodel(head, "maps/b_nail0.bsp");
										head.ammo_nails = ceil((GRD_PATROLTIME + (random() * GRD_PATROLTIME)));
										head.cost = ceil((head.ammo_nails * 0.8));
									}
									else
									{
										if ((r < 0.7))
										{
											setmodel(head, "maps/b_rock0.bsp");
											head.ammo_rockets = ceil((LOGIC_PATROL + (random() * KEY_MOVERIGHT)));
											head.cost = ceil((head.ammo_rockets * LOGIC_FINDDEFEND));
										}
										else
										{
											setmodel(head, "maps/b_batt0.bsp");
											head.ammo_cells = ceil((KEY_MOVERIGHT + (random() * KEY_MOVERIGHT)));
											head.cost = ceil((head.ammo_cells * 3.5));
										}
									}
								}
							}
							else
							{
								if ((self.netname == "weapon_trader"))
								{
									head.cnt = LOGIC_FINDDEFEND;
									if ((r < 0.15))
									{
										setmodel(head, "progs/g_shot.mdl");
										head.ammo_shells = LOGIC_PATROL;
										head.cost = 50;
										head.targetname = "Double-barrelled Shotgun";
										head.items = IT_SUPER_SHOTGUN;
									}
									else
									{
										if ((r < 0.3))
										{
											setmodel(head, "progs/g_nail.mdl");
											head.ammo_nails = MON_CAMPTIME;
											head.cost = 100;
											head.targetname = "Nailgun";
											head.items = IT_NAILGUN;
										}
										else
										{
											if ((r < 0.45))
											{
												setmodel(head, "progs/g_nail2.mdl");
												head.ammo_nails = MON_CAMPTIME;
												head.cost = 150;
												head.targetname = "Super Nailgun";
												head.items = IT_SUPER_NAILGUN;
											}
											else
											{
												if ((r < 0.6))
												{
													setmodel(head, "progs/g_rock.mdl");
													head.ammo_rockets = LOGIC_PATROL;
													head.cost = 250;
													head.targetname = "Grenade Launcher";
													head.items = IT_GRENADE_LAUNCHER;
												}
												else
												{
													if ((r < 0.8))
													{
														setmodel(head, "progs/g_rock2.mdl");
														head.ammo_rockets = LOGIC_PATROL;
														head.cost = 350;
														head.targetname = "Rocket Launcher";
														head.items = IT_ROCKET_LAUNCHER;
													}
													else
													{
														setmodel(head, "progs/g_light.mdl");
														head.ammo_cells = 12;
														head.cost = GRD_FIGHTDIST;
														head.targetname = "Thunderbolt";
														head.items = IT_LIGHTNING;
													}
												}
											}
										}
									}
								}
							}
						}
					}
					head.free = FALSE;
					sound(head, CHAN_VOICE, "items/itembk2.wav", H_ROTTEN, ATTN_NORM);
				}
			}
		}
		head = find(head, classname, "trade_spot");
	}
};

void() trader_think =
{
	if ((self.walkframe >= LOGIC_PATROL))
	{
		self.walkframe = WF_NORMAL;
	}
	self.frame = (LOGIC_HUNTENEMY + self.walkframe);
	self.walkframe = (self.walkframe + H_ROTTEN);
	if ((self.radsuit_finished < time))
	{
		find_trade_spot(self);
		self.radsuit_finished = (time + LOGIC_PATROL);
	}
	self.think = trader_think;
	self.nextthink = (time + 0.07);
};

void() monster_trader =
{
	if (!self.netname)
	{
		objerror("monster_trader: no `netname` defined");
	}
	setmodel(self, "progs/player_s.mdl");
	self.solid = SOLID_SLIDEBOX;
	self.takedamage = DAMAGE_NO;
	self.frame = 14;
	self.colormap = WF_NORMAL;
	self.health = 100;
	self.think = trader_think;
	self.nextthink = (time + H_ROTTEN);
};

void() trade_spot =
{
	if (!self.netname)
	{
		objerror("trader_spot: no `netname` defined");
	}
	self.free = TRUE;
	self.classname = "trade_spot";
	self.solid = SOLID_NOT;
	self.attack_finished = ((time + H_ROTTEN) + (random() * 15));
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
};

void() bye_item =
{
	local entity head;
	local entity selected;
	local float min_dist;
	local entity mega;
	local float best;

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
	if ((selected != world))
	{
		if ((self.gold < selected.cost))
		{
			sprint(self, "not enough gold\n");
			return;
		}
		if ((selected.armortype > WF_NORMAL))
		{
			if (((self.armortype * self.armorvalue) >= (selected.armortype * selected.armorvalue)))
			{
				sprint(self, "you don't need it\n");
				return;
			}
			self.armortype = selected.armortype;
			self.armorvalue = selected.armorvalue;
			self.items = ((self.items - (self.items & ((IT_ARMOR1 | IT_ARMOR2) | IT_ARMOR3))) + selected.items);
			sound(self, CHAN_ITEM, "items/armor1.wav", H_ROTTEN, ATTN_NORM);
			selected.attack_finished = ((time + GRD_PATROLTIME) + (random() * GRD_PATROLTIME));
		}
		else
		{
			if ((selected.items & IT_SUPERHEALTH))
			{
				if ((self.health >= (self.max_health + 150)))
				{
					return;
				}
				if ((selected.healtype < H_MEGA))
				{
					if ((self.health >= self.max_health))
					{
						return;
					}
					T_Heal(self, selected.healamount, WF_NORMAL);
				}
				else
				{
					if ((selected.healtype == H_MEGA))
					{
						T_Heal(self, selected.healamount, H_ROTTEN);
						if (!(self.items & IT_SUPERHEALTH))
						{
							mega = spawn();
							mega.nextthink = (time + LOGIC_PATROL);
							mega.think = item_megahealth_rot;
							mega.owner = self;
							self.items = (self.items | IT_SUPERHEALTH);
						}
					}
				}
				sound(self, CHAN_ITEM, selected.noise, H_ROTTEN, ATTN_NORM);
				selected.attack_finished = ((time + GRD_PATROLTIME) + (random() * GRD_PATROLTIME));
			}
			else
			{
				if ((selected.cnt == H_MEGA))
				{
					best = W_BestWeapon();
					self.ammo_shells = (self.ammo_shells + selected.ammo_shells);
					self.ammo_nails = (self.ammo_nails + selected.ammo_nails);
					self.ammo_rockets = (self.ammo_rockets + selected.ammo_rockets);
					self.ammo_cells = (self.ammo_cells + selected.ammo_cells);
					bound_self_ammo();
					if (selected.ammo_shells)
					{
						sprint(self, "You buy ");
						sprint_ftos(self, selected.ammo_shells);
						sprint(self, " shells\n");
					}
					else
					{
						if (selected.ammo_nails)
						{
							sprint(self, "You buy ");
							sprint_ftos(self, selected.ammo_nails);
							sprint(self, " nails\n");
						}
						else
						{
							if (selected.ammo_rockets)
							{
								sprint(self, "You buy ");
								sprint_ftos(self, selected.ammo_rockets);
								sprint(self, " rockets\n");
							}
							else
							{
								if (selected.ammo_cells)
								{
									sprint(self, "You buy ");
									sprint_ftos(self, selected.ammo_cells);
									sprint(self, " cells\n");
								}
								else
								{
									sprint(self, "ERROR: shop have incorrect items! Report this bug!\n");
								}
							}
						}
					}
					sound(self, CHAN_ITEM, "weapons/lock4.wav", H_ROTTEN, ATTN_NORM);
					if ((self.weapon == best))
					{
						self.weapon = W_BestWeapon();
						W_SetCurrentAmmo();
					}
					W_SetCurrentAmmo();
					selected.attack_finished = ((time + GRD_PATROLTIME) + (random() * GRD_PATROLTIME));
					selected.ammo_cells = WF_NORMAL;
					selected.ammo_rockets = WF_NORMAL;
					selected.ammo_nails = WF_NORMAL;
					selected.ammo_shells = WF_NORMAL;
				}
				else
				{
					if ((selected.cnt == LOGIC_FINDDEFEND))
					{
						best = W_BestWeapon();
						self.ammo_shells = (self.ammo_shells + selected.ammo_shells);
						self.ammo_nails = (self.ammo_nails + selected.ammo_nails);
						self.ammo_rockets = (self.ammo_rockets + selected.ammo_rockets);
						self.ammo_cells = (self.ammo_cells + selected.ammo_cells);
						bound_self_ammo();
						self.items = (self.items | selected.items);
						sprint(self, "You buy ");
						sprint(self, selected.targetname);
						sprint(self, "\n");
						sound(self, CHAN_ITEM, "weapons/pkup.wav", H_ROTTEN, ATTN_NORM);
						if ((self.weapon == best))
						{
							self.weapon = W_BestWeapon();
						}
						W_SetCurrentAmmo();
						selected.attack_finished = ((time + GRD_PATROLTIME) + (random() * GRD_PATROLTIME));
						selected.ammo_cells = WF_NORMAL;
						selected.ammo_rockets = WF_NORMAL;
						selected.ammo_nails = WF_NORMAL;
						selected.ammo_shells = WF_NORMAL;
					}
				}
			}
		}
		self.gold = (self.gold - selected.cost);
		setmodel(selected, string_null);
		selected.free = TRUE;
		stuffcmd(self, "bf\n");
		sprint_ftos(self, self.gold);
		sprint(self, " gold left\n");
	}
	else
	{
		buy_goody();
	}
};

void() indefy_item =
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
	if ((selected != world))
	{
		sprint(self, "====== ÈÓ‰ÂÊ˘†ÈÙÂÌ ======\n");
		if ((selected.items & IT_ARMOR1))
		{
			sprint(self, "Green Armor. Cost: ");
		}
		if ((selected.items & IT_ARMOR2))
		{
			sprint(self, "Yellow Armor. Cost: ");
		}
		if ((selected.items & IT_ARMOR3))
		{
			sprint(self, "Red Armor. Cost: ");
		}
		if ((selected.cnt == H_MEGA))
		{
			if (selected.ammo_shells)
			{
				sprint_ftos(self, selected.ammo_shells);
				sprint(self, " shells. Cost: ");
			}
			if (selected.ammo_nails)
			{
				sprint_ftos(self, selected.ammo_nails);
				sprint(self, " nails. Cost: ");
			}
			if (selected.ammo_rockets)
			{
				sprint_ftos(self, selected.ammo_rockets);
				sprint(self, " rockets. Cost: ");
			}
			if (selected.ammo_cells)
			{
				sprint_ftos(self, selected.ammo_cells);
				sprint(self, " cells. Cost: ");
			}
		}
		else
		{
			if ((selected.cnt == LOGIC_FINDDEFEND))
			{
				sprint(self, selected.targetname);
				sprint(self, ". Cost: ");
			}
		}
		if ((selected.items & IT_SUPERHEALTH))
		{
			sprint(self, "Medikit +");
			sprint_ftos(self, selected.healamount);
			sprint(self, ". Cost: ");
		}
		sprint_ftos(self, selected.cost);
		sprint(self, "\n");
	}
	else
	{
		indefy_goody();
	}
};

void() print_skills =
{
	local float bonusdmg;

	sprint(self, "\n====== ÛÙ·ÙÛ ======\n");
	sprint(self, "= stats points: ");
	sprint_ftos(self, self.point);
	if ((self.point < TE_LAVASPLASH))
	{
		sprint(self, " =\n");
	}
	else
	{
		sprint(self, "=\n");
	}
	sprint(self, "-------------------\n");
	sprint(self, "ˆÈÙ·ÏÈÙ˘∫ ");
	sprint_ftos(self, self.vit);
	sprint(self, " (");
	sprint_ftos(self, self.max_health);
	bonusdmg = WF_NORMAL;
	if ((self.magic_typeone == H_ROTTEN))
	{
		bonusdmg = (bonusdmg + self.magic_typeone_value);
	}
	if ((self.magic_typetwo == H_ROTTEN))
	{
		bonusdmg = (bonusdmg + self.magic_typetwo_value);
	}
	if ((self.ring_typeone == H_ROTTEN))
	{
		bonusdmg = (bonusdmg + self.ring_typeone_value);
	}
	if ((self.ring_typetwo == H_ROTTEN))
	{
		bonusdmg = (bonusdmg + self.ring_typetwo_value);
	}
	if ((bonusdmg > WF_NORMAL))
	{
		sprint(self, " (+");
		sprint_ftos(self, bonusdmg);
		sprint(self, ")");
	}
	if ((self.point <= WF_NORMAL))
	{
		sprint(self, " max life)\n");
	}
	else
	{
		sprint(self, " max life). use ¢ÛÎÈÏÏ±¢ to add\n");
	}
	sprint(self, "ÛÙÚÂÓÁÙË∫ ");
	sprint_ftos(self, self.stre);
	sprint(self, " (");
	sprint_ftos(self, ((self.stre * CL_DEADTIME) + 100));
	bonusdmg = WF_NORMAL;
	if ((self.magic_typeone == LOGIC_DEFEND))
	{
		bonusdmg = (bonusdmg + self.magic_typeone_value);
	}
	if ((self.magic_typetwo == LOGIC_DEFEND))
	{
		bonusdmg = (bonusdmg + self.magic_typetwo_value);
	}
	if ((self.ring_typeone == LOGIC_DEFEND))
	{
		bonusdmg = (bonusdmg + self.ring_typeone_value);
	}
	if ((self.ring_typetwo == LOGIC_DEFEND))
	{
		bonusdmg = (bonusdmg + self.ring_typetwo_value);
	}
	if ((self.mentat_bonus == H_ROTTEN))
	{
		bonusdmg = (bonusdmg + GRD_PATROLTIME);
	}
	if ((bonusdmg > WF_NORMAL))
	{
		sprint(self, "% (+");
		sprint_ftos(self, bonusdmg);
		sprint(self, "%)");
	}
	else
	{
		sprint(self, "%");
	}
	if ((self.point <= WF_NORMAL))
	{
		sprint(self, " damage)\n");
	}
	else
	{
		sprint(self, " damage). use ¢ÛÎÈÏÏ≤¢ to add\n");
	}
	sprint(self, "===================\n");
};

void() skill_impulse =
{
	if ((self.impulse == GRD_PATROLTIME))
	{
		print_skills();
		return;
	}
	if ((self.point <= WF_NORMAL))
	{
		sprint(self, "no stats points\n");
		return;
	}
	if ((self.impulse == 21))
	{
		self.max_health = (self.max_health + H_MEGA);
		if ((self.max_health > 999))
		{
			self.max_health = 999;
		}
		T_Heal(self, H_MEGA, WF_NORMAL);
		self.vit = (self.vit + H_ROTTEN);
		sprint(self, "upgraded: ˆÈÙ·ÏÈÙ˘∫ ");
		sprint_ftos(self, self.vit);
		sprint(self, " (");
		sprint_ftos(self, self.max_health);
		sprint(self, " max health)\n");
		self.point = (self.point - H_ROTTEN);
	}
	if ((self.impulse == 22))
	{
		self.stre = (self.stre + H_ROTTEN);
		sprint(self, "upgraded: ÛÙÚÂÓÁÙË∫ ");
		sprint_ftos(self, self.stre);
		sprint(self, " (");
		sprint_ftos(self, ((self.stre * CL_DEADTIME) + 100));
		sprint(self, "% damage amplify)\n");
		self.point = (self.point - H_ROTTEN);
	}
	if ((self.point <= WF_NORMAL))
	{
		if ((self.items & IT_KEY1))
		{
			self.items = (self.items - IT_KEY1);
		}
	}
};

void(entity e, float nm) des_scroll =
{
	local float tmp;

	sprint(e, "Û„ÚÔÏÏ†ÔÊ†");
	if ((nm == H_ROTTEN))
	{
		sprint(e, "ËÂ·ÏÈÓÁ ùlvl:");
		sprint_ftos(e, e.sc_heal_lvl);
		sprint(e, "ûmana:");
		sprint_ftos(e, (LOGIC_FINDDEFEND + (e.sc_heal_lvl * H_MEGA)));
		sprint(e, "ûeff:");
		sprint_ftos(e, (15 + (e.sc_heal_lvl * TE_LAVASPLASH)));
		sprint(e, "ü");
		sprint(e, "\n");
	}
	else
	{
		if ((nm == H_MEGA))
		{
			sprint(e, "ÚÂ‰ı„ÙÈÔÓ ùlvl:");
			sprint_ftos(e, e.sc_redu_lvl);
			sprint(e, "ûmana:");
			sprint_ftos(e, (LOGIC_PATROL + (e.sc_redu_lvl * LOGIC_FINDDEFEND)));
			sprint(e, "ûeff:");
			tmp = (25 + (e.sc_redu_lvl * LOGIC_FINDDEFEND));
			if ((tmp > 60))
			{
				tmp = 60;
			}
			sprint_ftos(e, tmp);
			sprint(e, "%ûtime:");
			sprint_ftos(e, (LOGIC_DEFEND + (e.sc_redu_lvl * H_MEGA)));
			sprint(e, "secûtargets:");
			tmp = (H_ROTTEN + rint((e.sc_redu_lvl / H_MEGA)));
			sprint_ftos(e, tmp);
			sprint(e, "ûrange:");
			tmp = ((350 + (e.sc_redu_lvl * 50)) / 100);
			sprint_ftos(e, tmp);
			sprint(e, "mü");
			sprint(e, "\n");
		}
		else
		{
			if ((nm == LOGIC_FINDDEFEND))
			{
				sprint(e, "ÛÏÔ˜ ùlvl:");
				sprint_ftos(e, e.sc_slow_lvl);
				sprint(e, "ûmana:");
				sprint_ftos(e, (KEY_MOVERIGHT + (e.sc_slow_lvl * H_MEGA)));
				sprint(e, "ûtime:");
				tmp = (LOGIC_DEFEND + rint((e.sc_slow_lvl * CL_DEADTIME)));
				sprint_ftos(e, tmp);
				sprint(e, "secûtargets:");
				tmp = (H_ROTTEN + rint((e.sc_slow_lvl / LOGIC_FINDDEFEND)));
				sprint_ftos(e, tmp);
				sprint(e, "ûrange:");
				tmp = ((350 + (e.sc_slow_lvl * 50)) / 100);
				sprint_ftos(e, tmp);
				sprint(e, "mü");
				sprint(e, "\n");
			}
		}
	}
	if ((nm == LOGIC_DEFEND))
	{
		sprint(e, "‚ÚıÙ·ÏÈÙ˘ ùlvl:");
		sprint_ftos(e, e.sc_brut_lvl);
		sprint(e, "ûmana:");
		sprint_ftos(e, (LOGIC_PATROL + (e.sc_brut_lvl * LOGIC_FINDDEFEND)));
		sprint(e, "ûeff:");
		sprint_ftos(e, (50 + (e.sc_brut_lvl * KEY_MOVERIGHT)));
		sprint(e, "%ûtime:");
		sprint_ftos(e, (LOGIC_HUNTENEMY + (e.sc_brut_lvl * H_MEGA)));
		sprint(e, "secü");
		sprint(e, "\n");
	}
};

void() Scroll_list =
{
	sprint(self, "\n===== Û„ÚÔÏÏÛ†=====\n");
	if ((self.sc_n1 > WF_NORMAL))
	{
		des_scroll(self, self.sc_n1);
	}
	if ((self.sc_n2 > WF_NORMAL))
	{
		des_scroll(self, self.sc_n2);
	}
	if ((self.sc_n3 > WF_NORMAL))
	{
		des_scroll(self, self.sc_n3);
	}
	if ((self.sc_n4 > WF_NORMAL))
	{
		des_scroll(self, self.sc_n4);
	}
	if ((self.sc_n5 > WF_NORMAL))
	{
		des_scroll(self, self.sc_n5);
	}
	sprint(self, "===================\n");
};

void() Cast_Slow =
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
		ip("this spell requies ");
		sprint_ftos(self, rm);
		ip(" mana\n");
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
		sound(self, CHAN_VOICE, "moon/magic/m_slow.wav", H_ROTTEN, ATTN_NORM);
		self.scroll_time = (time + MON_BACKTIME);
	}
	else
	{
		sprint(self, "no monsters in range\n");
	}
};

void() Cast_Redu =
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
		ip("this spell requies ");
		sprint_ftos(self, rm);
		ip(" mana\n");
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

void() Cast_Heal =
{
	local float rm;
	local float eff;

	rm = (LOGIC_FINDDEFEND + (self.sc_heal_lvl * H_MEGA));
	eff = (15 + (self.sc_heal_lvl * TE_LAVASPLASH));
	if ((self.mana < rm))
	{
		ip("this spell requies ");
		sprint_ftos(self, rm);
		ip(" mana\n");
		return;
	}
	if ((self.health >= self.max_health))
	{
		ip("your life already at maximum\n");
		return;
	}
	if ((self.scroll_time > time))
	{
		return;
	}
	sound(self, CHAN_VOICE, "moon/magic/m_heal.wav", H_ROTTEN, ATTN_NORM);
	T_Heal(self, eff, WF_NORMAL);
	self.mana = (self.mana - rm);
	if ((self.mana < WF_NORMAL))
	{
		self.mana = WF_NORMAL;
	}
	self.scroll_heal_eff = (time + MON_BACKTIME);
	self.scroll_time = (time + MON_BACKTIME);
};

void() Cast_Brut =
{
	local float rm;
	local float eff;
	local float dur;

	rm = (LOGIC_PATROL + (self.sc_brut_lvl * LOGIC_FINDDEFEND));
	eff = (50 + (self.sc_brut_lvl * KEY_MOVERIGHT));
	dur = (LOGIC_HUNTENEMY + (self.sc_brut_lvl * H_MEGA));
	if ((self.mana < rm))
	{
		ip("this spell requies ");
		sprint_ftos(self, rm);
		ip(" mana\n");
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
	self.scroll_brut_eff = (time + dur);
};

void() Cast_Shie =
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

void() infe_eff =
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

void() Cast_Infe =
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

void() shaf_eff =
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

void() Cast_Shaf =
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
		sound(self, CHAN_WEAPON, "moon/magic/m_thun.wav", H_ROTTEN, ATTN_NORM);
		self.scroll_time = (time + MON_BACKTIME);
		return;
	}
	else
	{
		sprint(self, "no monsters in range\n");
	}
};

void() mete_eff_th =
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

void(entity who) mete_eff =
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

void() Cast_Mete =
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

void(float nm) CastN =
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

void(float nm) Cast =
{
	if ((nm == H_ROTTEN))
	{
		if ((self.sc_n1 <= WF_NORMAL))
		{
			ip("no 1st scroll to cast\n");
			return;
		}
		CastN(self.sc_n1);
	}
	if ((nm == H_MEGA))
	{
		if ((self.sc_n2 <= WF_NORMAL))
		{
			ip("no 2nd scroll to cast\n");
			return;
		}
		CastN(self.sc_n2);
	}
	if ((nm == LOGIC_FINDDEFEND))
	{
		if ((self.sc_n3 <= WF_NORMAL))
		{
			ip("no 3rd scroll to cast\n");
			return;
		}
		CastN(self.sc_n3);
	}
	if ((nm == LOGIC_DEFEND))
	{
		if ((self.sc_n4 <= WF_NORMAL))
		{
			ip("no 4th scroll to cast\n");
			return;
		}
		CastN(self.sc_n4);
	}
	if ((nm == LOGIC_PATROL))
	{
		if ((self.sc_n5 <= WF_NORMAL))
		{
			ip("no 5th scroll to cast\n");
			return;
		}
		CastN(self.sc_n5);
	}
};

void(entity who, float l) GetPrfx =
{
	local string s;

	if ((l < WF_NORMAL))
	{
		bprint("ERROR IN GetPrfx(...): player level is negative value.\n");
	}
	if ((l == WF_NORMAL))
	{
		s = "novice ";
	}
	if ((l == H_ROTTEN))
	{
		s = "ordinary ";
	}
	if ((l == H_MEGA))
	{
		s = "promoted ";
	}
	if ((l == LOGIC_FINDDEFEND))
	{
		s = "advanced ";
	}
	if ((l == LOGIC_DEFEND))
	{
		s = "experienced ";
	}
	if ((l == LOGIC_PATROL))
	{
		s = "grim ";
	}
	if ((l == LOGIC_HUNTENEMY))
	{
		s = "massive ";
	}
	if ((l == TE_WIZSPIKE))
	{
		s = "skillful ";
	}
	if ((l == KEY_MOVERIGHT))
	{
		s = "incredible ";
	}
	if ((l == TE_LIGHTNING3))
	{
		s = "merciless ";
	}
	if ((l == TE_LAVASPLASH))
	{
		s = "drilled ";
	}
	if ((l == TE_TELEPORT))
	{
		s = "war ";
	}
	if ((l == 12))
	{
		s = "enourmous ";
	}
	if ((l == 13))
	{
		s = "powerful ";
	}
	if ((l == 14))
	{
		s = "grand ";
	}
	if ((l == 15))
	{
		s = "chaos ";
	}
	if ((l == KEY_MOVEFORWARD))
	{
		s = "demonical ";
	}
	if ((l == 17))
	{
		s = "superior ";
	}
	if ((l == 18))
	{
		s = "hurricane ";
	}
	if ((l == 19))
	{
		s = "defacing ";
	}
	if ((l == GRD_PATROLTIME))
	{
		s = "phantom ";
	}
	if ((l == 21))
	{
		s = "lord ";
	}
	if ((l == 22))
	{
		s = "baron ";
	}
	if ((l == SVC_TEMPENTITY))
	{
		s = "overlord ";
	}
	if ((l == 24))
	{
		s = "warlord ";
	}
	if ((l == 25))
	{
		s = "king ";
	}
	if ((l == 26))
	{
		s = "plague ";
	}
	if ((l == SVC_KILLEDMONSTER))
	{
		s = "storm ";
	}
	if ((l == SVC_FOUNDSECRET))
	{
		s = "shadow ";
	}
	if ((l == 29))
	{
		s = "holocaust ";
	}
	if ((l == MON_CAMPTIME))
	{
		s = "order ";
	}
	if ((l == SVC_FINALE))
	{
		s = "dire ";
	}
	if ((l == KEY_MOVEBACK))
	{
		s = "gale ";
	}
	if ((l == SVC_SELLSCREEN))
	{
		s = "cruel ";
	}
	if ((l == 34))
	{
		s = "doom ";
	}
	if ((l == 35))
	{
		s = "serious ";
	}
	if ((l == 36))
	{
		s = "celestial ";
	}
	if ((l == 37))
	{
		s = "terrible ";
	}
	if ((l == 38))
	{
		s = "diamond ";
	}
	if ((l == 39))
	{
		s = "rush ";
	}
	if ((l == GRD_DEFENDTIME))
	{
		s = "crashing ";
	}
	if ((l == 41))
	{
		s = "fanged ";
	}
	if ((l == 42))
	{
		s = "thirsty ";
	}
	if ((l == 43))
	{
		s = "splitter ";
	}
	if ((l == 44))
	{
		s = "sunder ";
	}
	if ((l == 45))
	{
		s = "rend ";
	}
	if ((l == 46))
	{
		s = "reaver ";
	}
	if ((l == 47))
	{
		s = "gnash ";
	}
	if ((l == 48))
	{
		s = "blow ";
	}
	if ((l == 49))
	{
		s = "smasher ";
	}
	if ((l >= 50))
	{
		s = "satan's ";
	}
	who.prefix_two = s;
	who.view_ofs = '0 0 25';
};

float(float mn) MonsterCtable =
{
	if ((mn == WF_NORMAL))
	{
		return (rint(((random() * LOGIC_FINDDEFEND) + H_MEGA)));
	}
	if ((mn == H_ROTTEN))
	{
		return (rint(((random() * LOGIC_FINDDEFEND) + H_MEGA)));
	}
	if ((mn == H_MEGA))
	{
		return (rint(((random() * LOGIC_DEFEND) + H_MEGA)));
	}
	if ((mn == LOGIC_FINDDEFEND))
	{
		return (rint(((random() * LOGIC_DEFEND) + H_MEGA)));
	}
	if (((mn >= LOGIC_DEFEND) && (mn <= KEY_MOVERIGHT)))
	{
		return (rint(((random() * LOGIC_DEFEND) + LOGIC_FINDDEFEND)));
	}
	if (((mn >= TE_LIGHTNING3) && (mn <= 17)))
	{
		return (rint(((random() * LOGIC_PATROL) + LOGIC_FINDDEFEND)));
	}
	if (((mn >= 18) && (mn < 48)))
	{
		return (rint(((random() * LOGIC_PATROL) + LOGIC_DEFEND)));
	}
	if ((mn >= 48))
	{
		return (rint(((random() * LOGIC_HUNTENEMY) + LOGIC_PATROL)));
	}
};

void(entity who, float l) MonsterTable =
{
	local float r;
	local float k;
	local float gen;
	local float enforcer_base_level;
	local float spider_base_level;
	local float orge_base_level;
	local float mage_base_level;
	local float shalrath_base_level;
	local float snake_base_level;

	r = random();
	k = rint((random() * LOGIC_FINDDEFEND));
	if ((l == WF_NORMAL))
	{
		gen = H_ROTTEN;
	}
	else
	{
		if ((l == H_ROTTEN))
		{
			gen = rint((H_ROTTEN + (random() * H_ROTTEN)));
		}
		else
		{
			if (((l >= H_MEGA) && (l < LOGIC_DEFEND)))
			{
				gen = rint((H_ROTTEN + (random() * H_MEGA)));
			}
			else
			{
				if (((l >= LOGIC_DEFEND) && (l < LOGIC_HUNTENEMY)))
				{
					gen = rint((H_ROTTEN + (random() * LOGIC_FINDDEFEND)));
				}
				else
				{
					if (((l >= LOGIC_HUNTENEMY) && (l < KEY_MOVERIGHT)))
					{
						gen = rint((H_ROTTEN + (random() * LOGIC_DEFEND)));
					}
					else
					{
						if (((l >= KEY_MOVERIGHT) && (l < 15)))
						{
							gen = rint((H_ROTTEN + (random() * LOGIC_PATROL)));
						}
						else
						{
							if ((l >= 15))
							{
								gen = rint((H_ROTTEN + (random() * LOGIC_HUNTENEMY)));
							}
						}
					}
				}
			}
		}
	}
	enforcer_base_level = H_ROTTEN;
	spider_base_level = H_MEGA;
	orge_base_level = LOGIC_DEFEND;
	snake_base_level = LOGIC_HUNTENEMY;
	mage_base_level = KEY_MOVERIGHT;
	shalrath_base_level = 15;
	if ((gen == H_ROTTEN))
	{
		spawn_soldier(self, (l - k));
	}
	else
	{
		if ((gen == H_MEGA))
		{
			spawn_enforcer(self, ((l - k) - enforcer_base_level));
		}
		else
		{
			if ((gen == LOGIC_FINDDEFEND))
			{
				spawn_spider(self, ((l - k) - spider_base_level));
			}
			else
			{
				if ((gen == LOGIC_DEFEND))
				{
					spawn_ogre(self, ((l - k) - orge_base_level));
				}
				else
				{
					if ((gen == LOGIC_PATROL))
					{
						spawn_snake(self, ((l - k) - snake_base_level));
					}
					else
					{
						if ((gen == LOGIC_HUNTENEMY))
						{
							spawn_mage(self, ((l - k) - mage_base_level));
						}
						else
						{
							if ((gen == TE_WIZSPIKE))
							{
								spawn_shalrath(self, ((l - k) - shalrath_base_level));
							}
							else
							{
								bprint("ERROR IN MonsterTable(...): gen spawns null monster\n");
							}
						}
					}
				}
			}
		}
	}
};
float SVC_SETVIEWPORT    = 5;
float SVC_SETVIEWANGLES    = 10;
float CHSCAM_ON    = 1;
void() Keep_cam_chasing_owner;
void(float opt) Remove_chase_cam;
float chasecam_dist    = 118;
float chasecam_zofs    = 24;

void(entity cam_owner) Start_chase_cam =
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

void() Reable_chase_cam =
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

void(float opt) Remove_chase_cam =
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

void() Keep_cam_chasing_owner =
{
	local vector goal;
	local vector dir;
	local float dist;
	local float cap;
	local float f_f;
	local string s;

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
		if ((dist > MON_CAMPTIME))
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
	}
	else
	{
		self.speed = CHSCAM_ON;
		self.weaponmodel = s_wiz;
		Start_chase_cam(self);
	}
};
entity lastmspawn;

float() MaxLvl =
{
	local entity h;
	local float mxlv;

	mxlv = WF_NORMAL;
	h = find(world, classname, "player");
	while (h)
	{
		if ((h.lvl > mxlv))
		{
			mxlv = h.lvl;
		}
		h = find(h, classname, "player");
	}
	return (mxlv);
};

entity() MonterSpawnPoint =
{
	local entity spot;
	local entity thing;
	local float pcount;

	spot = lastmspawn;
	while (H_ROTTEN)
	{
		spot = find(spot, classname, "info_monster_start");
		if ((spot != world))
		{
			if ((spot == lastmspawn))
			{
				return (world);
			}
			pcount = WF_NORMAL;
			thing = findradius(spot.origin, 80);
			while (thing)
			{
				if ((thing.flags & FL_MONSTER))
				{
					if ((thing.health > WF_NORMAL))
					{
						pcount = (pcount + H_ROTTEN);
					}
				}
				thing = thing.chain;
			}
			if ((pcount == WF_NORMAL))
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
	local float mxx;

	if (gameover)
	{
		return;
	}
	if ((self.count <= WF_NORMAL))
	{
		remove(self);
		return;
	}
	mxx = MaxLvl();
	MonsterTable(self, mxx);
	self.nextthink = (time + 0.3);
	self.think = StartSpawning;
};

void(float z) SpawnMoster =
{
	local entity a;

	a = spawn();
	a.count = z;
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
				makechatnoise();
				if ((head.mode == H_ROTTEN))
				{
					if ((random() < MON_BACKTIME))
					{
						sound(head, CHAN_VOICE, "moon/talk/stay1.wav", H_ROTTEN, ATTN_NORM);
					}
					else
					{
						sound(head, CHAN_VOICE, "moon/talk/stay2.wav", H_ROTTEN, ATTN_NORM);
					}
					head.mode = H_MEGA;
					bprint("Guard: I will stay here\n");
				}
				else
				{
					if ((head.mode == H_MEGA))
					{
						if ((random() < MON_BACKTIME))
						{
							sound(head, CHAN_VOICE, "moon/talk/go1.wav", H_ROTTEN, ATTN_NORM);
						}
						else
						{
							sound(head, CHAN_VOICE, "moon/talk/go2.wav", H_ROTTEN, ATTN_NORM);
						}
						head.mode = H_ROTTEN;
						bprint("Guard: I coming\n");
					}
				}
			}
		}
		head = head.chain;
	}
};

void() brain_think =
{
	local float mxx;
	local float mn;

	if ((gameover == TRUE))
	{
		remove(self);
		return;
	}
	mxx = MaxLvl();
	mn = MonsterCtable(mxx);
	SpawnMoster(mn);
	self.nextthink = ((time + MON_CAMPTIME) + (random() * MON_CAMPTIME));
	self.think = brain_think;
};

void() game_brain =
{
	local entity e;

	e = spawn();
	e.nextthink = ((time + MON_CAMPTIME) + (random() * MON_CAMPTIME));
	e.think = brain_think;
};

void() info_monster_start =
{
};

void() shoot_ent =
{
	self.health = H_ROTTEN;
};

void() charaster =
{
	local entity head;

	head = find(world, classname, "heart");
	sprint(self, "\n===== √Ë·Ú·ÛÙÂÚÛ =====\n");
	sprint(self, "\nHeart Life: ");
	sprint_ftos(self, head.health);
	sprint(self, "\nMonsters Killed: ");
	sprint_ftos(self, self.mosterskilled);
	sprint(self, "\nLevel: ");
	sprint_ftos(self, self.lvl);
	sprint(self, "\nExpirience: ");
	sprint_ftos(self, self.exp);
	sprint(self, "\nNext level: ");
	sprint_ftos(self, self.nextexp);
	sprint(self, " exp\nGold: ");
	sprint_ftos(self, self.gold);
	sprint(self, "\n======================\n");
};

void() Prepare =
{
	if ((mapname != "moon4"))
	{
		sprint(self, "\ngame supports only map moon4.bsp\n");
		localcmd("\ndisconnect\n");
		return;
	}
	self.exp = WF_NORMAL;
	self.lvl = WF_NORMAL;
	self.gold = 300;
	self.nextexp = GRD_DEFENDTIME;
	self.prepared = TRUE;
	self.point = WF_NORMAL;
	self.mana = 35;
	self.max_mana = 35;
	self.mosterskilled = WF_NORMAL;
	sv_alwaysday = WF_NORMAL;
	self.up_bullet = WF_NORMAL;
	up_alert = WF_NORMAL;
	if ((waypoints_ok == FALSE))
	{
		set_map();
	}
	sprint(self, "Project MOON. v0.21 beta. Created by ≥‰€–Ô˜ÂÚ›\nhttp://www.3dpower.org\ntype „ËÂÏ command to view info about console commands\n");
};

void() moonimpulse =
{
	if ((self.impulse == 86))
	{
		if ((self.cl_framtime == WF_NORMAL))
		{
			self.cl_framtime = H_ROTTEN;
			bprint("Client: cl_fps enabled\n");
		}
		else
		{
			if ((self.cl_framtime == H_ROTTEN))
			{
				self.cl_framtime = WF_NORMAL;
				bprint("Client: cl_fps disabled\n");
			}
		}
	}
	else
	{
		if (((self.impulse == 87) && (self.colormap == H_ROTTEN)))
		{
			if ((sv_alwaysday == WF_NORMAL))
			{
				sv_alwaysday = H_ROTTEN;
				bprint("Server: alwaysday enabled\n");
			}
			else
			{
				if ((sv_alwaysday == H_ROTTEN))
				{
					sv_alwaysday = WF_NORMAL;
					bprint("Server: alwaysday disabled\n");
				}
			}
		}
		else
		{
			if ((self.impulse == 88))
			{
				if ((self.cl_nohelp == WF_NORMAL))
				{
					self.cl_nohelp = H_ROTTEN;
					sprint(self, "Client: nohelp enabled\n");
				}
				else
				{
					if ((self.cl_nohelp == H_ROTTEN))
					{
						self.cl_nohelp = WF_NORMAL;
						sprint(self, "Client: nohelp disabled\n");
					}
				}
			}
			else
			{
				if (((self.impulse == 89) && (self.colormap == H_ROTTEN)))
				{
					if ((sv_fastmeat == WF_NORMAL))
					{
						sv_fastmeat = H_ROTTEN;
						bprint("Server: fastmeat enabled\n");
					}
					else
					{
						if ((sv_fastmeat == H_ROTTEN))
						{
							sv_fastmeat = WF_NORMAL;
							bprint("Server: fastmeat disabled\n");
						}
					}
				}
			}
		}
	}
	if ((self.impulse == 94))
	{
		weareditems();
	}
	if ((self.impulse == 95))
	{
		wearitem();
	}
	if ((self.impulse == 96))
	{
		charaster();
	}
	if ((self.impulse == 97))
	{
		bye_item();
	}
	if ((self.impulse == 98))
	{
		indefy_item();
	}
	else
	{
		if (((self.impulse >= GRD_PATROLTIME) && (self.impulse <= SVC_TEMPENTITY)))
		{
			skill_impulse();
		}
		else
		{
			if ((self.impulse == 231))
			{
				sprint(self, "\n=== ËÂÏ†ÔÓ∫†„ÔÓÛÔÏÂ†„ÔÌÌ·Ó‰Û ===\n");
				sprint(self, "use „Ë·Ú·ÛÙÂÚ†or „†command to view charaster screen.\n");
				sprint(self, "use ‚ı˘†command to buy some item in the shop.\n");
				sprint(self, "use ÈÓ‰ÂÊ˘ command to get a description of item in the shop.\n");
				sprint(self, "use ÛÙ·ÙÛ command to view screen with your stats.\n");
				sprint(self, "use ıÛÂ command pick up some magical item.\n");
				sprint(self, "use ÈÓˆÂÓÙÔÚ˘†or È†command to view inventory screen.\n");
				sprint(self, "=================================\n");
			}
		}
	}
	if ((self.prepared == FALSE))
	{
		Prepare();
	}
};

void() MoonPreThink =
{
	if ((self.cold_time > time))
	{
		if ((self.flags & FL_ONGROUND))
		{
			if ((self.velocity_x > 160))
			{
				self.velocity_x = 150;
			}
			if ((self.velocity_y > 160))
			{
				self.velocity_y = 150;
			}
		}
	}
};

void() MonsterDead =
{
	self.solid = SOLID_NOT;
	self.think = SUB_Remove;
	if ((sv_fastmeat == H_ROTTEN))
	{
		self.nextthink = ((time + H_ROTTEN) + (random() * H_ROTTEN));
	}
	else
	{
		self.nextthink = ((time + SVC_SETVIEWANGLES) + (random() * SVC_SETVIEWANGLES));
	}
};

void() makechatnoise =
{
	local entity p;

	p = find(world, classname, "player");
	while ((p != world))
	{
		stuffcmd(p, "play misc/talk.wav\n");
		p = find(p, classname, "player");
	}
	p = find(world, classname, "CameraClient");
	while ((p != world))
	{
		stuffcmd(p, "play misc/talk.wav\n");
		p = find(p, classname, "CameraClient");
	}
};

void() GetRandomVector =
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
};

float(entity targ) BotCanSeePlayer =
{
	local vector spot1;
	local vector spot2;
	local vector vec;
	local float r;

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

void(float n) SendChat =
{
	local float r;

	makechatnoise();
	r = random();
	if ((n == H_ROTTEN))
	{
		if ((r < 0.25))
		{
			bprint("Áı·Ú‰∫†ÈÓ„ÔÌÈÓÁ°\n");
		}
		else
		{
			if ((r < MON_BACKTIME))
			{
				bprint("Áı·Ú‰∫†ÙËÂ˘†·ÚÂ†„ÔÌÈÓÁ\n");
			}
			else
			{
				if ((r < 0.75))
				{
					bprint("Áı·Ú‰∫†È†ÊÔıÓ‰†ÂÓÂÌ˘°\n");
				}
				else
				{
					bprint("Áı·Ú‰∫†˜Â†·ÚÂ†ıÓ‰ÂÚ†·ÙÙ·„Î°\n");
				}
			}
		}
	}
};

void() bot_find_enemy =
{
	local entity head;
	local entity selected;
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
							SendChat(H_ROTTEN);
						}
						self.guard_chat_incoming = (time + MON_CAMPTIME);
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

void() bot_fire =
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
	if ((self.items & IT_LIGHTNING))
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
		if ((head.classname == "guard"))
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
						bprint("Guard, helping teammate\n");
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

void() ai_evade =
{
	local float dist;
	local vector vec;
	local vector org;
	local entity e;
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

void() bot_ai_stand =
{
	local float dst;

	self.currentammo = WF_NORMAL;
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

void() bot_prethink =
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

void(float dist) bot_ai_run =
{
	local float dst;
	local vector vec;
	local float stream;
	local entity head;

	self.currentammo = H_ROTTEN;
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

void() bot_run1 =
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

void(entity who) BotItems =
{
	local float lv;

	lv = MaxLvl();
	who.items = ((who.items + IT_AXE) + IT_SHOTGUN);
	if ((lv <= LOGIC_DEFEND))
	{
		who.items = (who.items + IT_ARMOR1);
		who.armorvalue = (H_ROTTEN + (lv * 25));
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
		if ((lv <= KEY_MOVERIGHT))
		{
			who.items = (who.items + IT_ARMOR2);
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
				who.items = (who.items + IT_ARMOR3);
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
				if ((random() < MON_BACKTIME))
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
	who.health = (100 + (25 * lv));
};

void() BotActivate =
{
	local entity newbot;
	local entity spot;
	local vector org;

	newbot = spawn();
	newbot.solid = SOLID_SLIDEBOX;
	newbot.movetype = MOVETYPE_STEP;
	newbot.angles = self.angles;
	newbot.classname = "guard";
	newbot.master = self;
	newbot.action = LOGIC_FREESTYLE;
	newbot.takedamage = DAMAGE_AIM;
	newbot.goalentity = world;
	newbot.movetarget = world;
	newbot.pausetime = (time + H_MEGA);
	newbot.ideal_yaw = (newbot.angles * '0 1 0');
	newbot.yaw_speed = LOGIC_HUNTENEMY;
	newbot.view_ofs = '0 0 25';
	newbot.speed = 320;
	newbot.wantline = H_ROTTEN;
	BotItems(newbot);
	newbot.max_health = newbot.health;
	bprint("== · ˜·Ó‰ÂÚÈÓÁ Áı·Ú‰È·Ó ÍÔÈÓÛ ˘ÔıÚ ÊÔÚ„ÂÛ ==\n");
	bprint("Health: ");
	bprint_ftos(newbot.health);
	if ((newbot.items & IT_ARMOR1))
	{
		bprint(". Green armor (");
	}
	else
	{
		if ((newbot.items & IT_ARMOR2))
		{
			bprint(". Yellow armor (");
		}
		else
		{
			if ((newbot.items & IT_ARMOR3))
			{
				bprint(". Red armor (");
			}
		}
	}
	bprint_ftos(newbot.armorvalue);
	bprint("). Weapons: shot");
	if ((newbot.items & IT_SUPER_SHOTGUN))
	{
		bprint(", supershot");
	}
	if ((newbot.items & IT_NAILGUN))
	{
		bprint(", nail");
	}
	if ((newbot.items & IT_SUPER_NAILGUN))
	{
		bprint(", supernail");
	}
	if ((newbot.items & IT_GRENADE_LAUNCHER))
	{
		bprint(", gl");
	}
	if ((newbot.items & IT_ROCKET_LAUNCHER))
	{
		bprint(", rl");
	}
	if ((newbot.items & IT_LIGHTNING))
	{
		bprint(", shaft");
	}
	bprint(".\n");
	newbot.th_stand = bot_ai_stand;
	newbot.th_run = bot_run1;
	newbot.th_die = PlayerDie;
	newbot.th_missile = bot_fire;
	newbot.team = self.team;
	newbot.flags = FL_CLIENT;
	newbot.mode = H_ROTTEN;
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

void() mon_evade =
{
	local float dist;
	local vector vec;
	local vector org;
	local entity e;
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
		if ((self.enemy.classname == "heart"))
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
	rint(vlen(self.velocity));
	if ((rint(self.speed) > rint(self.speed)))
	{
		bprint("warning: monster speed overload. maxspeed: ");
		bprint_ftos(self.speed);
		bprint(". Current: ");
		bprint_ftos(vlen(self.velocity));
		bprint(".\n");
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
	local entity mon;

	if ((self.next_gate > time))
	{
		return;
	}
	self.next_gate = (time + 0.12);
	e = find(world, classname, "gate");
	if (e)
	{
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
		return;
	}
	self.next_heart = (time + 0.1324);
	if ((self.enemy.classname == "heart"))
	{
		return;
	}
	e = find(world, classname, "heart");
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
	local entity selected;
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
						self.show_hostile = ((time + self.hst) + (random() / SVC_SETVIEWANGLES));
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
		return;
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
};

void() mon_run_slide =
{
	local float ofs;

	return;
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
};

void(entity who) particle_heal =
{
	local vector smes;

	smes = ((who.origin + ((v_up * 12) * crandom())) + ((v_right * SVC_SETVIEWANGLES) * crandom()));
	particle(smes, VEC_ORIGIN, 165, 25);
	particle(smes, VEC_ORIGIN, 73, 25);
};

void(entity who, float clr) particle_scroll =
{
	local vector smes;

	smes = (((who.origin + (v_up * self.maxs_z)) - ((v_up * 12) * random())) + ((v_right * LOGIC_DEFEND) * crandom()));
	particle(smes, '0 0 -20', clr, 25);
};

void() check_heal =
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

void() CheckCurse =
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
	if ((((self.currentammo == WF_NORMAL) && (gameover == FALSE)) && (self.camp_time < time)))
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

	self.currentammo = WF_NORMAL;
	if (!gameover)
	{
		dst = vlen((self.goalentity.origin - self.origin));
		visible(self.goalentity);
		if ((visible(self.goalentity) && (self.goalentity.classname == "waypoint")))
		{
			self.ideal_yaw = vectoyaw((self.goalentity.origin - self.origin));
			self.currentammo = H_ROTTEN;
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
					self.currentammo = H_ROTTEN;
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

	self.currentammo = H_ROTTEN;
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
	if (((self.enemy.classname == "shoot_ent") || (self.enemy.classname == "heart")))
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
		rint(vlen(self.velocity));
		if ((rint(self.speed) > rint(self.speed)))
		{
			bprint("warning: monster speed overload. maxspeed: ");
			bprint_ftos(self.speed);
			bprint(". Current: ");
			bprint_ftos(vlen(self.velocity));
			bprint(".\n");
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

void() heart_die =
{
	local entity head;
	local entity pos;
	local float pl;

	head = find(world, classname, "player");
	pos = find(world, classname, "info_intermission");
	pl = MaxLvl();
	bprint("êÁ·ÌÂÔˆÂÚ° Your level is ");
	bprint_ftos(pl);
	bprint("ë\n");
	while (head)
	{
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
		head = find(head, classname, "player");
	}
	intermission_running = H_ROTTEN;
	intermission_exittime = (time + SVC_SETVIEWANGLES);
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
	self.health = (self.health + H_ROTTEN);
	if ((self.health > self.max_health))
	{
		self.health = self.max_health;
	}
	self.nextthink = (time + H_ROTTEN);
};

void() heart =
{
	setmodel(self, "progs/heart.mdl");
	self.solid = SOLID_BBOX;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.takedamage = DAMAGE_AIM;
	self.health = 200;
	self.max_health = 200;
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

void(entity e) GenerateMagic =
{
	local float r;
	local float mxx;

	mxx = MaxLvl();
	if ((mxx <= SVC_SETVIEWANGLES))
	{
		r = rint(((random() * KEY_MOVERIGHT) + H_ROTTEN));
	}
	else
	{
		if ((mxx <= GRD_PATROLTIME))
		{
			r = rint(((random() * KEY_MOVEFORWARD) + H_ROTTEN));
		}
		else
		{
			if ((mxx <= GRD_DEFENDTIME))
			{
				r = rint(((random() * 21) + H_ROTTEN));
			}
			else
			{
				r = rint(((random() * SVC_KILLEDMONSTER) + H_ROTTEN));
			}
		}
	}
	if ((r == H_ROTTEN))
	{
		e.magic_typeone = H_ROTTEN;
		e.magic_typeone_value = rint(((random() * SVC_SETVIEWANGLES) + SVC_SETVIEWPORT));
		e.prefix_one = "Â„ËÈ‰Ó· ";
	}
	else
	{
		if ((r == H_MEGA))
		{
			e.magic_typeone = H_MEGA;
			e.magic_typeone_value = rint(((random() * TE_LIGHTNING3) + H_ROTTEN));
			e.prefix_one = "Ë·ÏÔ ";
		}
		else
		{
			if ((r == LOGIC_FINDDEFEND))
			{
				e.magic_typeone = LOGIC_FINDDEFEND;
				e.magic_typeone_value = rint(((random() * GRD_PATROLTIME) + GRD_PATROLTIME));
				e.prefix_one = "ÏıÓ·„˘ ";
			}
			else
			{
				if ((r == LOGIC_DEFEND))
				{
					e.magic_typeone = LOGIC_DEFEND;
					e.magic_typeone_value = rint(((random() * GRD_PATROLTIME) + SVC_SETVIEWPORT));
					e.prefix_one = "‚ÚıÙ·Ï ";
				}
				else
				{
					if ((r == SVC_SETVIEWPORT))
					{
						e.magic_typeone = SVC_SETVIEWPORT;
						e.magic_typeone_value = rint(((random() * KEY_MOVERIGHT) + LOGIC_FINDDEFEND));
						e.prefix_one = "‰ÚÂ·‰ ";
					}
					else
					{
						if ((r == LOGIC_HUNTENEMY))
						{
							e.magic_typeone = LOGIC_HUNTENEMY;
							e.magic_typeone_value = rint(((random() * LOGIC_HUNTENEMY) + LOGIC_FINDDEFEND));
							e.prefix_one = "ÊÏÂÛË ";
						}
						else
						{
							if ((r == TE_WIZSPIKE))
							{
								e.magic_typeone = TE_WIZSPIKE;
								e.magic_typeone_value = rint(((random() * H_MEGA) + H_ROTTEN));
								e.prefix_one = "ˆÂÈÓ ";
							}
							else
							{
								if ((r == KEY_MOVERIGHT))
								{
									e.magic_typeone = KEY_MOVERIGHT;
									e.magic_typeone_value = rint(((random() * SVC_SETVIEWPORT) + H_ROTTEN));
									e.prefix_one = "‚Ú·ÛË ";
								}
								else
								{
									if ((r == TE_LIGHTNING3))
									{
										e.magic_typeone = H_ROTTEN;
										e.magic_typeone_value = rint(((random() * SVC_SETVIEWANGLES) + 15));
										e.prefix_one = "ˆÈÂÚ ";
									}
									else
									{
										if ((r == SVC_SETVIEWANGLES))
										{
											e.magic_typeone = H_MEGA;
											e.magic_typeone_value = rint(((random() * TE_LIGHTNING3) + SVC_SETVIEWANGLES));
											e.prefix_one = "‚ÏÂÛÛÂ‰ ";
										}
										else
										{
											if ((r == TE_TELEPORT))
											{
												e.magic_typeone = LOGIC_FINDDEFEND;
												e.magic_typeone_value = rint(((random() * 41) + GRD_DEFENDTIME));
												e.prefix_one = "Ê·Ó·ÙÈ„ ";
											}
											else
											{
												if ((r == 12))
												{
													e.magic_typeone = LOGIC_DEFEND;
													e.magic_typeone_value = rint(((random() * 15) + GRD_PATROLTIME));
													e.prefix_one = "‚·ÙÙÏÂ ";
												}
												else
												{
													if ((r == 13))
													{
														e.magic_typeone = SVC_SETVIEWPORT;
														e.magic_typeone_value = rint(((random() * TE_WIZSPIKE) + SVC_SETVIEWANGLES));
														e.prefix_one = "ÈÓÛ·ÓÂ ";
													}
													else
													{
														if ((r == 14))
														{
															e.magic_typeone = LOGIC_HUNTENEMY;
															e.magic_typeone_value = rint(((random() * KEY_MOVERIGHT) + KEY_MOVERIGHT));
															e.prefix_one = "‚ÏÔÔ‰ ";
														}
														else
														{
															if ((r == 15))
															{
																e.magic_typeone = TE_WIZSPIKE;
																e.magic_typeone_value = rint(((random() * H_MEGA) + LOGIC_FINDDEFEND));
																e.prefix_one = "ÁÚÂ·Ù†ˆÂÈÓ ";
															}
															else
															{
																if ((r == KEY_MOVEFORWARD))
																{
																	e.magic_typeone = KEY_MOVERIGHT;
																	e.magic_typeone_value = rint(((random() * TE_WIZSPIKE) + LOGIC_HUNTENEMY));
																	e.prefix_one = "Â‰ÂÌ ";
																}
																else
																{
																	if ((r == 17))
																	{
																		e.magic_typeone = H_ROTTEN;
																		e.magic_typeone_value = rint(((random() * SVC_SETVIEWANGLES) + 25));
																		e.prefix_one = "Ú·˙ÔÚ ";
																	}
																	else
																	{
																		if ((r == 18))
																		{
																			e.magic_typeone = H_MEGA;
																			e.magic_typeone_value = rint(((random() * LOGIC_HUNTENEMY) + GRD_PATROLTIME));
																			e.prefix_one = "ÛÙÔÓÂ ";
																		}
																		else
																		{
																			if ((r == 19))
																			{
																				e.magic_typeone = LOGIC_DEFEND;
																				e.magic_typeone_value = rint(((random() * 15) + 35));
																				e.prefix_one = "‰ÂÌÔÓÈ„ ";
																			}
																			else
																			{
																				if ((r == GRD_PATROLTIME))
																				{
																					e.magic_typeone = TE_WIZSPIKE;
																					e.magic_typeone_value = rint(((random() * H_MEGA) + SVC_SETVIEWPORT));
																					e.prefix_one = "ËÂÏÏßÛ†ˆÂÈÓ ";
																				}
																				else
																				{
																					if ((r == 21))
																					{
																						e.magic_typeone = KEY_MOVERIGHT;
																						e.magic_typeone_value = rint(((random() * TE_TELEPORT) + 15));
																						e.prefix_one = "ËÂ·ˆÂÓ ";
																					}
																					else
																					{
																						if ((r == 22))
																						{
																							e.magic_typeone = TE_WIZSPIKE;
																							e.magic_typeone_value = rint(((random() * H_MEGA) + TE_WIZSPIKE));
																							e.prefix_one = "Ì·ÁÂÓÙ· ";
																						}
																						else
																						{
																							if ((r == SVC_TEMPENTITY))
																							{
																								e.magic_typeone = H_ROTTEN;
																								e.magic_typeone_value = rint(((random() * 51) + 50));
																								e.prefix_one = "‰ÔÔÌ ";
																							}
																							else
																							{
																								if ((r == chasecam_zofs))
																								{
																									e.magic_typeone = H_MEGA;
																									e.magic_typeone_value = rint(((random() * LOGIC_HUNTENEMY) + 25));
																									e.prefix_one = "‰Ú·ÁÔÓÛÎÈÓ ";
																								}
																								else
																								{
																									if ((r == 25))
																									{
																										e.magic_typeone = LOGIC_FINDDEFEND;
																										e.magic_typeone_value = rint(((random() * 101) + 100));
																										e.prefix_one = "ÁÔÏ‰ ";
																									}
																									else
																									{
																										if ((r == 26))
																										{
																											e.magic_typeone = SVC_SETVIEWPORT;
																											e.magic_typeone_value = rint(((random() * TE_TELEPORT) + GRD_PATROLTIME));
																											e.prefix_one = "ÌÈÚÚÔÚ ";
																										}
																										else
																										{
																											if ((r == SVC_KILLEDMONSTER))
																											{
																												e.magic_typeone = LOGIC_HUNTENEMY;
																												e.magic_typeone_value = rint(((random() * SVC_SETVIEWANGLES) + KEY_MOVEFORWARD));
																												e.prefix_one = "‰·ÚÎÌ·ÁÂ ";
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
							}
						}
					}
				}
			}
		}
	}
};

void(entity e) GenerateMagic2 =
{
	local float r;
	local float mxx;

	mxx = MaxLvl();
	if ((mxx <= SVC_SETVIEWANGLES))
	{
		r = rint(((random() * TE_WIZSPIKE) + H_ROTTEN));
	}
	else
	{
		if ((mxx <= GRD_PATROLTIME))
		{
			r = rint(((random() * 13) + H_ROTTEN));
		}
		else
		{
			if ((mxx <= GRD_DEFENDTIME))
			{
				r = rint(((random() * KEY_MOVEFORWARD) + H_ROTTEN));
			}
			else
			{
				r = rint(((random() * 17) + H_ROTTEN));
			}
		}
	}
	if ((r == H_ROTTEN))
	{
		e.magic_typetwo = H_ROTTEN;
		e.magic_typetwo_value = rint(((random() * TE_WIZSPIKE) + TE_WIZSPIKE));
		e.prefix_two = "†ÔÊ†ÏÈÊÂ ";
	}
	else
	{
		if ((r == H_MEGA))
		{
			e.magic_typetwo = H_MEGA;
			e.magic_typetwo_value = rint(((random() * TE_LIGHTNING3) + H_ROTTEN));
			e.prefix_two = "†ÔÊ†ÚÂÛÈÛÙ·Ó„Â";
		}
		else
		{
			if ((r == LOGIC_FINDDEFEND))
			{
				e.magic_typetwo = LOGIC_FINDDEFEND;
				e.magic_typetwo_value = rint(((random() * GRD_PATROLTIME) + GRD_DEFENDTIME));
				e.prefix_two = "†ÔÊ†ÁÚÂÂ‰";
			}
			else
			{
				if ((r == LOGIC_DEFEND))
				{
					e.magic_typetwo = LOGIC_DEFEND;
					e.magic_typetwo_value = rint(((random() * 21) + SVC_SETVIEWPORT));
					e.prefix_two = "†ÔÊ†„·ÚÓ·ÁÂ";
				}
				else
				{
					if ((r == SVC_SETVIEWPORT))
					{
						e.magic_typetwo = SVC_SETVIEWPORT;
						e.magic_typetwo_value = rint(((random() * LOGIC_HUNTENEMY) + SVC_SETVIEWPORT));
						e.prefix_two = " ÔÊ†ÙÂÓÔÓÛ";
					}
					else
					{
						if ((r == LOGIC_HUNTENEMY))
						{
							e.magic_typetwo = LOGIC_HUNTENEMY;
							e.magic_typetwo_value = rint(((random() * KEY_MOVERIGHT) + H_MEGA));
							e.prefix_two = " ÔÊ†ÙËÂ†ÏÂÂ„Ë";
						}
						else
						{
							if ((r == TE_WIZSPIKE))
							{
								e.magic_typetwo = TE_WIZSPIKE;
								e.magic_typetwo_value = rint(((random() * H_MEGA) + H_ROTTEN));
								e.prefix_two = " ÔÊ†ÚÂÁÂÓÂÚ·ÙÈÔÓ";
							}
							else
							{
								if ((r == KEY_MOVERIGHT))
								{
									e.magic_typetwo = H_ROTTEN;
									e.magic_typetwo_value = rint(((random() * 13) + 13));
									e.prefix_two = "†ÔÊ†ËÂ·ÏÙË";
								}
								else
								{
									if ((r == TE_LIGHTNING3))
									{
										e.magic_typetwo = H_MEGA;
										e.magic_typetwo_value = rint(((random() * SVC_SETVIEWANGLES) + SVC_SETVIEWANGLES));
										e.prefix_two = "†ÔÊ†ÚÔÙÂ„ÙÈÔÓ";
									}
									else
									{
										if ((r == SVC_SETVIEWANGLES))
										{
											e.magic_typetwo = LOGIC_FINDDEFEND;
											e.magic_typetwo_value = rint(((random() * MON_CAMPTIME) + 50));
											e.prefix_two = "†ÔÊ†ÙÚÂ·ÛıÚÂ";
										}
										else
										{
											if ((r == TE_TELEPORT))
											{
												e.magic_typetwo = LOGIC_DEFEND;
												e.magic_typetwo_value = rint(((random() * 26) + 25));
												e.prefix_two = "†ÔÊ†ˆÈÔÏÂÓ„Â";
											}
											else
											{
												if ((r == 12))
												{
													e.magic_typetwo = SVC_SETVIEWPORT;
													e.magic_typetwo_value = rint(((random() * TE_TELEPORT) + SVC_SETVIEWANGLES));
													e.prefix_two = " ÔÊ†ÚıÊÊÛ";
												}
												else
												{
													if ((r == 13))
													{
														e.magic_typetwo = KEY_MOVERIGHT;
														e.magic_typetwo_value = rint(((random() * LOGIC_DEFEND) + H_MEGA));
														e.prefix_two = " ÔÊ†ÙËÂ†ÁËÔÛÙ";
													}
													else
													{
														if ((r == 14))
														{
															e.magic_typetwo = H_MEGA;
															e.magic_typetwo_value = rint(((random() * SVC_SETVIEWANGLES) + GRD_PATROLTIME));
															e.prefix_two = "†ÔÊ†ÚÂ‰ı„ÙÈÔÓ";
														}
														else
														{
															if ((r == 15))
															{
																e.magic_typetwo = KEY_MOVERIGHT;
																e.magic_typetwo_value = rint(((random() * TE_WIZSPIKE) + LOGIC_HUNTENEMY));
																e.prefix_two = " ÔÊ†ÙËÂ†˜Ú·ÈÙË";
															}
															else
															{
																if ((r == KEY_MOVEFORWARD))
																{
																	e.magic_typetwo = TE_WIZSPIKE;
																	e.magic_typetwo_value = rint(((random() * H_MEGA) + LOGIC_FINDDEFEND));
																	e.prefix_two = " ÔÊ†ÚÂÛË·Â";
																}
																else
																{
																	if ((r == 17))
																	{
																		e.magic_typetwo = LOGIC_DEFEND;
																		e.magic_typetwo_value = rint(((random() * 51) + 50));
																		e.prefix_two = "†ÔÊ†ÙËÂ†‚·ÙÙÏÂÌ·ÛÙÂÚ";
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
							}
						}
					}
				}
			}
		}
	}
};

void() MagicItemTouch =
{
	local float l;

	if ((other.classname != "player"))
	{
		return;
	}
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	if (((other.next_mesg_time < time) || (other.mesg_inflictor != self)))
	{
		sprint(other, "\n=== magic item: ");
		if ((self.prefix_one != s_wiz))
		{
			sprint(other, self.prefix_one);
		}
		sprint(other, self.netname);
		if ((self.prefix_two != s_wiz))
		{
			sprint(other, self.prefix_two);
		}
		sprint(other, " ===\n");
		if ((self.magic_typeone == H_ROTTEN))
		{
			sprint(other, "+");
			if ((self.magic_typetwo == H_ROTTEN))
			{
				sprint_ftos(other, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(other, self.magic_typeone_value);
			}
			sprint(other, " to maximum health\n");
		}
		if ((self.magic_typeone == H_MEGA))
		{
			sprint(other, "reduce damage by ");
			if ((self.magic_typetwo == H_MEGA))
			{
				sprint_ftos(other, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(other, self.magic_typeone_value);
			}
			sprint(other, "%\n");
		}
		if ((self.magic_typeone == LOGIC_FINDDEFEND))
		{
			if ((self.magic_typetwo == LOGIC_FINDDEFEND))
			{
				sprint_ftos(other, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(other, self.magic_typeone_value);
			}
			sprint(other, "% extra gold from monsters\n");
		}
		if ((self.magic_typeone == LOGIC_DEFEND))
		{
			if ((self.magic_typetwo == LOGIC_DEFEND))
			{
				sprint_ftos(other, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(other, self.magic_typeone_value);
			}
			sprint(other, "% damage amplify\n");
		}
		if ((self.magic_typeone == SVC_SETVIEWPORT))
		{
			sprint(other, "attacker takes ");
			if ((self.magic_typetwo == SVC_SETVIEWPORT))
			{
				sprint_ftos(other, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(other, self.magic_typeone_value);
			}
			sprint(other, "% of damage caused\n");
		}
		if ((self.magic_typeone == LOGIC_HUNTENEMY))
		{
			if ((self.magic_typetwo == LOGIC_HUNTENEMY))
			{
				sprint_ftos(other, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(other, self.magic_typeone_value);
			}
			sprint(other, "% your damage converts to life\n");
		}
		if ((self.magic_typeone == TE_WIZSPIKE))
		{
			sprint(other, "replenish ");
			if ((self.magic_typetwo == TE_WIZSPIKE))
			{
				sprint_ftos(other, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(other, self.magic_typeone_value);
			}
			sprint(other, " health every second\n");
		}
		if ((self.magic_typeone == KEY_MOVERIGHT))
		{
			sprint(other, "adds ");
			if ((self.magic_typetwo == KEY_MOVERIGHT))
			{
				sprint_ftos(other, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(other, self.magic_typeone_value);
			}
			sprint(other, " health after each kill\n");
		}
		if (((self.magic_typetwo == H_ROTTEN) && (self.magic_typeone != H_ROTTEN)))
		{
			sprint(other, "+");
			sprint_ftos(other, self.magic_typetwo_value);
			sprint(other, " to maximum health\n");
		}
		if (((self.magic_typetwo == H_MEGA) && (self.magic_typeone != H_MEGA)))
		{
			sprint(other, "reduce damage by ");
			sprint_ftos(other, self.magic_typetwo_value);
			sprint(other, "%\n");
		}
		if (((self.magic_typetwo == LOGIC_FINDDEFEND) && (self.magic_typeone != LOGIC_FINDDEFEND)))
		{
			sprint_ftos(other, self.magic_typetwo_value);
			sprint(other, "% extra gold from monsters\n");
		}
		if (((self.magic_typetwo == LOGIC_DEFEND) && (self.magic_typeone != LOGIC_DEFEND)))
		{
			sprint_ftos(other, self.magic_typetwo_value);
			sprint(other, "% damage amplify\n");
		}
		if (((self.magic_typetwo == SVC_SETVIEWPORT) && (self.magic_typeone != SVC_SETVIEWPORT)))
		{
			sprint(other, "attacker takes ");
			sprint_ftos(other, self.magic_typetwo_value);
			sprint(other, "% of damage caused\n");
		}
		if (((self.magic_typetwo == LOGIC_HUNTENEMY) && (self.magic_typeone != LOGIC_HUNTENEMY)))
		{
			sprint_ftos(other, self.magic_typetwo_value);
			sprint(other, "% your damage converts to life\n");
		}
		if (((self.magic_typetwo == TE_WIZSPIKE) && (self.magic_typeone != TE_WIZSPIKE)))
		{
			sprint(other, "replenish ");
			sprint_ftos(other, self.magic_typetwo_value);
			sprint(other, " health every second\n");
		}
		if (((self.magic_typetwo == KEY_MOVERIGHT) && (self.magic_typeone != KEY_MOVERIGHT)))
		{
			sprint(other, "adds ");
			sprint_ftos(other, self.magic_typetwo_value);
			sprint(other, " health after each kill\n");
		}
		if ((other.cl_nohelp == WF_NORMAL))
		{
			if ((self.classname != "goody_ent"))
			{
				l = MaxLvl();
				if ((l < LOGIC_DEFEND))
				{
					sprint(other, "Use ıÛÂ command to pick it up\n");
				}
			}
		}
		other.next_mesg_time = (time + LOGIC_DEFEND);
		other.mesg_inflictor = self;
		if ((self.classname == "goody_ent"))
		{
			sprint(other, "Cost: ");
			sprint_ftos(other, self.cost);
			sprint(other, "\n");
		}
		sprint(other, "======================\n");
	}
};

void() wearitem =
{
	local entity head;
	local entity selected;
	local float min_dist;

	min_dist = 100;
	head = find(world, classname, "magicitem");
	while (head)
	{
		if ((vlen((head.origin - self.origin)) < min_dist))
		{
			min_dist = vlen((head.origin - self.origin));
			selected = head;
		}
		head = find(head, classname, "magicitem");
	}
	if ((other.classname == "goody_ent"))
	{
		selected = other;
	}
	if ((selected != world))
	{
		if ((selected.netname == "·ÚÌÔÚ"))
		{
			if ((self.wear_armor == H_ROTTEN))
			{
				if ((self.magic_typeone == H_ROTTEN))
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
				if ((self.magic_typetwo == H_ROTTEN))
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
			self.wear_armor = H_ROTTEN;
			if ((selected.magic_typeone > WF_NORMAL))
			{
				self.magic_typeone = selected.magic_typeone;
				self.magic_typeone_value = selected.magic_typeone_value;
				self.magic_prefixone = selected.magic_prefixone;
				if ((selected.magic_typeone == H_ROTTEN))
				{
					self.max_health = (self.max_health + selected.magic_typeone_value);
					T_Heal(self, self.magic_typeone_value, WF_NORMAL);
				}
			}
			if ((selected.magic_typetwo > WF_NORMAL))
			{
				self.magic_typetwo = selected.magic_typetwo;
				self.magic_typetwo_value = selected.magic_typetwo_value;
				self.magic_prefixtwo = selected.magic_prefixtwo;
				if ((selected.magic_typetwo == H_ROTTEN))
				{
					self.max_health = (self.max_health + selected.magic_typetwo_value);
					T_Heal(self, self.magic_typetwo_value, WF_NORMAL);
				}
			}
			if ((selected.classname == "goody_ent"))
			{
				sprint(self, "\nYou buy ");
			}
			else
			{
				sprint(self, "\nYou put on ");
			}
			if ((selected.magic_prefixone != s_wiz))
			{
				sprint(self, selected.magic_prefixone);
			}
			sprint(self, selected.netname);
			if ((selected.magic_prefixtwo != s_wiz))
			{
				sprint(self, selected.magic_prefixtwo);
			}
			sprint(self, "\n");
		}
		else
		{
			if ((selected.netname == "ÚÈÓÁ"))
			{
				if ((self.wear_ring == H_ROTTEN))
				{
					if ((self.ring_typeone == H_ROTTEN))
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
					if ((self.ring_typetwo == H_ROTTEN))
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
				self.wear_ring = H_ROTTEN;
				if ((selected.ring_typeone > WF_NORMAL))
				{
					self.ring_typeone = selected.ring_typeone;
					self.ring_typeone_value = selected.ring_typeone_value;
					self.ring_prefixone = selected.ring_prefixone;
					if ((selected.ring_typeone == H_ROTTEN))
					{
						self.max_health = (self.max_health + selected.ring_typeone_value);
						T_Heal(self, self.ring_typeone_value, WF_NORMAL);
					}
				}
				if ((selected.ring_typetwo > WF_NORMAL))
				{
					self.ring_typetwo = selected.ring_typetwo;
					self.ring_typetwo_value = selected.ring_typetwo_value;
					self.ring_prefixtwo = selected.ring_prefixtwo;
					if ((selected.ring_typetwo == H_ROTTEN))
					{
						self.max_health = (self.max_health + selected.ring_typetwo_value);
						T_Heal(self, self.ring_typetwo_value, WF_NORMAL);
					}
				}
				if ((selected.classname == "goody_ent"))
				{
					sprint(self, "\nYou buy ");
				}
				else
				{
					sprint(self, "\nYou put on ");
				}
				if ((selected.ring_prefixone != s_wiz))
				{
					sprint(self, selected.ring_prefixone);
				}
				sprint(self, selected.netname);
				if ((selected.ring_prefixtwo != s_wiz))
				{
					sprint(self, selected.ring_prefixtwo);
				}
				sprint(self, "\n");
			}
		}
		stuffcmd(self, "bf\n");
		remove(selected);
	}
	else
	{
		sprint(self, "no items around\n");
	}
};

void() weareditems =
{
	if ((((((self.wear_armor == WF_NORMAL) && (self.wear_ring == WF_NORMAL)) && (self.mentat_bonus == WF_NORMAL)) && (self.mentat_bonus2 == WF_NORMAL)) && (self.mentat_bonus3 == WF_NORMAL)))
	{
		sprint(self, "you have no special items\n");
		return;
	}
	sprint(self, "\n== ˘ÔıÚ†„ıÚÚÂÓÙ†ÈÙÂÌÛ ==\n");
	if ((self.mentat_bonus == H_ROTTEN))
	{
		sprint(self, "ÔÊÊÂÓ„ÈˆÂ†‰ÚıÁ (+10% to damage amplify)\n");
	}
	if ((self.mentat_bonus2 == H_ROTTEN))
	{
		sprint(self, "‰ÂÊÂÓÛÈˆÂ†‰ÚıÁ (reduce received damage by 10%)\n");
	}
	if ((self.mentat_bonus3 == H_ROTTEN))
	{
		sprint(self, "·„„ÂÏÂÚ·ÙÈˆÂ†‰ÚıÁ (increase your attack speed)\n");
	}
	if ((self.wear_armor == H_ROTTEN))
	{
		if ((((self.mentat_bonus == H_ROTTEN) || (self.mentat_bonus2 == H_ROTTEN)) || (self.mentat_bonus3 == H_ROTTEN)))
		{
			sprint(self, "--------------------------\n");
		}
		if ((self.magic_prefixone != s_wiz))
		{
			sprint(self, self.magic_prefixone);
		}
		sprint(self, "·ÚÌÔÚ");
		if ((self.magic_prefixtwo != s_wiz))
		{
			sprint(self, self.magic_prefixtwo);
		}
		sprint(self, "\n");
		if ((self.magic_typeone == H_ROTTEN))
		{
			sprint(self, "+");
			if ((self.magic_typetwo == H_ROTTEN))
			{
				sprint_ftos(self, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.magic_typeone_value);
			}
			sprint(self, " to maximum health\n");
		}
		if ((self.magic_typeone == H_MEGA))
		{
			sprint(self, "reduce damage by ");
			if ((self.magic_typetwo == H_MEGA))
			{
				sprint_ftos(self, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.magic_typeone_value);
			}
			sprint(self, "%\n");
		}
		if ((self.magic_typeone == LOGIC_FINDDEFEND))
		{
			if ((self.magic_typetwo == LOGIC_FINDDEFEND))
			{
				sprint_ftos(self, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.magic_typeone_value);
			}
			sprint(self, "% extra gold from monsters\n");
		}
		if ((self.magic_typeone == LOGIC_DEFEND))
		{
			if ((self.magic_typetwo == LOGIC_DEFEND))
			{
				sprint_ftos(self, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.magic_typeone_value);
			}
			sprint(self, "% damage amplify\n");
		}
		if ((self.magic_typeone == SVC_SETVIEWPORT))
		{
			sprint(self, "attacker takes ");
			if ((self.magic_typetwo == SVC_SETVIEWPORT))
			{
				sprint_ftos(self, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.magic_typeone_value);
			}
			sprint(self, "% of damage caused\n");
		}
		if ((self.magic_typeone == LOGIC_HUNTENEMY))
		{
			if ((self.magic_typetwo == LOGIC_HUNTENEMY))
			{
				sprint_ftos(self, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.magic_typeone_value);
			}
			sprint(self, "% your damage converts to life\n");
		}
		if ((self.magic_typeone == TE_WIZSPIKE))
		{
			sprint(self, "replenish ");
			if ((self.magic_typetwo == TE_WIZSPIKE))
			{
				sprint_ftos(self, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.magic_typeone_value);
			}
			sprint(self, " health every second\n");
		}
		if ((self.magic_typeone == KEY_MOVERIGHT))
		{
			sprint(self, "adds ");
			if ((self.magic_typetwo == KEY_MOVERIGHT))
			{
				sprint_ftos(self, (self.magic_typeone_value + self.magic_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.magic_typeone_value);
			}
			sprint(self, " health after each kill\n");
		}
		if (((self.magic_typetwo == H_ROTTEN) && (self.magic_typeone != H_ROTTEN)))
		{
			sprint(self, "+");
			sprint_ftos(self, self.magic_typetwo_value);
			sprint(self, " to maximum health\n");
		}
		if (((self.magic_typetwo == H_MEGA) && (self.magic_typeone != H_MEGA)))
		{
			sprint(self, "reduce damage by ");
			sprint_ftos(self, self.magic_typetwo_value);
			sprint(self, "%\n");
		}
		if (((self.magic_typetwo == LOGIC_FINDDEFEND) && (self.magic_typeone != LOGIC_FINDDEFEND)))
		{
			sprint_ftos(self, self.magic_typetwo_value);
			sprint(self, "% extra gold from monsters\n");
		}
		if (((self.magic_typetwo == LOGIC_DEFEND) && (self.magic_typeone != LOGIC_DEFEND)))
		{
			sprint_ftos(self, self.magic_typetwo_value);
			sprint(self, "% damage amplify\n");
		}
		if (((self.magic_typetwo == SVC_SETVIEWPORT) && (self.magic_typeone != SVC_SETVIEWPORT)))
		{
			sprint(self, "attacker takes ");
			sprint_ftos(self, self.magic_typetwo_value);
			sprint(self, "% of damage caused\n");
		}
		if (((self.magic_typetwo == LOGIC_HUNTENEMY) && (self.magic_typeone != LOGIC_HUNTENEMY)))
		{
			sprint_ftos(self, self.magic_typetwo_value);
			sprint(self, "% your damage converts to life\n");
		}
		if (((self.magic_typetwo == TE_WIZSPIKE) && (self.magic_typeone != TE_WIZSPIKE)))
		{
			sprint(self, "replenish ");
			sprint_ftos(self, self.magic_typetwo_value);
			sprint(self, " health every second\n");
		}
		if (((self.magic_typetwo == KEY_MOVERIGHT) && (self.magic_typeone != KEY_MOVERIGHT)))
		{
			sprint(self, "adds ");
			sprint_ftos(self, self.magic_typetwo_value);
			sprint(self, " health after each kill\n");
		}
	}
	if ((self.wear_ring == H_ROTTEN))
	{
		if ((self.wear_armor == H_ROTTEN))
		{
			sprint(self, "--------------------------\n");
		}
		if ((self.ring_prefixone != s_wiz))
		{
			sprint(self, self.ring_prefixone);
		}
		sprint(self, "ÚÈÓÁ");
		if ((self.ring_prefixtwo != s_wiz))
		{
			sprint(self, self.ring_prefixtwo);
		}
		sprint(self, "\n");
		if ((self.ring_typeone == H_ROTTEN))
		{
			sprint(self, "+");
			if ((self.ring_typetwo == H_ROTTEN))
			{
				sprint_ftos(self, (self.ring_typeone_value + self.ring_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.ring_typeone_value);
			}
			sprint(self, " to maximum health\n");
		}
		if ((self.ring_typeone == H_MEGA))
		{
			sprint(self, "reduce damage by ");
			if ((self.ring_typetwo == H_MEGA))
			{
				sprint_ftos(self, (self.ring_typeone_value + self.ring_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.ring_typeone_value);
			}
			sprint(self, "%\n");
		}
		if ((self.ring_typeone == LOGIC_FINDDEFEND))
		{
			if ((self.ring_typetwo == LOGIC_FINDDEFEND))
			{
				sprint_ftos(self, (self.ring_typeone_value + self.ring_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.ring_typeone_value);
			}
			sprint(self, "% extra gold from monsters\n");
		}
		if ((self.ring_typeone == LOGIC_DEFEND))
		{
			if ((self.ring_typetwo == LOGIC_DEFEND))
			{
				sprint_ftos(self, (self.ring_typeone_value + self.ring_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.ring_typeone_value);
			}
			sprint(self, "% damage amplify\n");
		}
		if ((self.ring_typeone == SVC_SETVIEWPORT))
		{
			sprint(self, "attacker takes ");
			if ((self.ring_typetwo == SVC_SETVIEWPORT))
			{
				sprint_ftos(self, (self.ring_typeone_value + self.ring_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.ring_typeone_value);
			}
			sprint(self, "% of damage caused\n");
		}
		if ((self.ring_typeone == LOGIC_HUNTENEMY))
		{
			if ((self.ring_typetwo == LOGIC_HUNTENEMY))
			{
				sprint_ftos(self, (self.ring_typeone_value + self.ring_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.ring_typeone_value);
			}
			sprint(self, "% your damage converts to life\n");
		}
		if ((self.ring_typeone == TE_WIZSPIKE))
		{
			sprint(self, "replenish ");
			if ((self.ring_typetwo == TE_WIZSPIKE))
			{
				sprint_ftos(self, (self.ring_typeone_value + self.ring_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.ring_typeone_value);
			}
			sprint(self, " health every second\n");
		}
		if ((self.ring_typeone == KEY_MOVERIGHT))
		{
			sprint(self, "adds ");
			if ((self.ring_typetwo == KEY_MOVERIGHT))
			{
				sprint_ftos(self, (self.ring_typeone_value + self.ring_typetwo_value));
			}
			else
			{
				sprint_ftos(self, self.ring_typeone_value);
			}
			sprint(self, " health after each kill\n");
		}
		if (((self.ring_typetwo == H_ROTTEN) && (self.ring_typeone != H_ROTTEN)))
		{
			sprint(self, "+");
			sprint_ftos(self, self.ring_typetwo_value);
			sprint(self, " to maximum health\n");
		}
		if (((self.ring_typetwo == H_MEGA) && (self.ring_typeone != H_MEGA)))
		{
			sprint(self, "reduce damage by ");
			sprint_ftos(self, self.ring_typetwo_value);
			sprint(self, "%\n");
		}
		if (((self.ring_typetwo == LOGIC_FINDDEFEND) && (self.ring_typeone != LOGIC_FINDDEFEND)))
		{
			sprint_ftos(self, self.ring_typetwo_value);
			sprint(self, "% extra gold from monsters\n");
		}
		if (((self.ring_typetwo == LOGIC_DEFEND) && (self.ring_typeone != LOGIC_DEFEND)))
		{
			sprint_ftos(self, self.ring_typetwo_value);
			sprint(self, "% damage amplify\n");
		}
		if (((self.ring_typetwo == SVC_SETVIEWPORT) && (self.ring_typeone != SVC_SETVIEWPORT)))
		{
			sprint(self, "attacker takes ");
			sprint_ftos(self, self.ring_typetwo_value);
			sprint(self, "% of damage caused\n");
		}
		if (((self.ring_typetwo == LOGIC_HUNTENEMY) && (self.ring_typeone != LOGIC_HUNTENEMY)))
		{
			sprint_ftos(self, self.ring_typetwo_value);
			sprint(self, "% your damage converts to life\n");
		}
		if (((self.ring_typetwo == TE_WIZSPIKE) && (self.ring_typeone != TE_WIZSPIKE)))
		{
			sprint(self, "replenish ");
			sprint_ftos(self, self.ring_typetwo_value);
			sprint(self, " health every second\n");
		}
		if (((self.ring_typetwo == KEY_MOVERIGHT) && (self.ring_typeone != KEY_MOVERIGHT)))
		{
			sprint(self, "adds ");
			sprint_ftos(self, self.ring_typetwo_value);
			sprint(self, " health after each kill\n");
		}
	}
	sprint(self, "==========================\n");
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
	item.classname = "magicitem";
	if ((random() < MON_BACKTIME))
	{
		item.netname = "·ÚÌÔÚ";
		setmodel(item, "progs/armor.mdl");
		item.skin = LOGIC_FINDDEFEND;
	}
	else
	{
		item.netname = "ÚÈÓÁ";
		setmodel(item, "progs/ring.mdl");
	}
	setsize(item, '-16 -16 0', '16 16 48');
	item.touch = MagicItemTouch;
	item.nextthink = (time + MENTAT_TIME);
	item.think = SUB_Remove;
	z = random();
	if ((z < 0.3))
	{
		GenerateMagic(item);
	}
	else
	{
		if ((z < 0.6))
		{
			GenerateMagic2(item);
		}
		else
		{
			GenerateMagic(item);
			GenerateMagic2(item);
		}
	}
};

void() UpgradeTouch =
{
	local float pl;
	local entity head;
	local float bonuslife;

	if ((other.classname != "player"))
	{
		return;
	}
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	pl = MaxLvl();
	if ((self.cnt == H_ROTTEN))
	{
		sprint(other, "¬ÔÔÎ†ÔÊ†Á·ÙÂ†·ÏÂÚÙ (gate gives a signal if killed)\n");
		up_alert = H_ROTTEN;
	}
	if ((self.cnt == H_MEGA))
	{
		sprint(other, "¬ÔÔÎ†ÔÊ†‚ıÏÏÂÙ†ÈÌÚÔˆÂÌÂÓÙ (your shell attack now stronger and more concentrated)\n");
		other.up_bullet = H_ROTTEN;
	}
	if ((self.cnt == LOGIC_FINDDEFEND))
	{
		sprint(other, "¬ÔÔÎ†ÔÊ†Ó·ÈÏ†ÈÌÚÔˆÂÌÂÓÙ (your nails attack now faster)\n");
		other.up_nail = H_ROTTEN;
	}
	if ((self.cnt == LOGIC_DEFEND))
	{
		sprint(other, "¬ÔÔÎ†ÔÊ†ÛÙ·ÙÛ†‚ÔÓıÛ (you get 5 stats points)\n");
		other.point = (other.point + SVC_SETVIEWPORT);
		if (!(other.items & IT_KEY1))
		{
			other.items = (other.items + IT_KEY1);
		}
	}
	if ((self.cnt == SVC_SETVIEWPORT))
	{
		sprint(other, "¬ÔÔÎ†ÔÊ†Áı·Ú‰È·Ó (guardian joined your army)\n");
		BotActivate();
	}
	if ((self.cnt == LOGIC_HUNTENEMY))
	{
		sprint(other, "¬ÔÔÎ†ÔÊ†ÙÚÂ·ÛıÚÂ (global gold income increased)\n");
		up_gold_value = (((up_gold_value + LOGIC_FINDDEFEND) + (pl * MON_BACKTIME)) + (random() * TE_WIZSPIKE));
		bprint("«ÏÔ‚·Ï†ÁÔÏ‰†ÈÓ„ÔÌÂ†now +");
		bprint_ftos(up_gold_value);
		bprint("%\n");
	}
	if ((self.cnt == TE_WIZSPIKE))
	{
		sprint(other, "¬ÔÔÎ†ÔÊ†ÈÌÌÔÚÙ·Ï˘†(heart life increased)\n");
		bonuslife = ((SVC_SETVIEWPORT + (pl * 0.25)) + (random() * SVC_SETVIEWPORT));
		head = find(world, classname, "heart");
		if ((head != world))
		{
			head.max_health = (head.max_health + bonuslife);
			head.health = (head.health + bonuslife);
			if ((head.health > head.max_health))
			{
				head.health = head.max_health;
			}
		}
		bonuslife = (head.max_health + bonuslife);
		bprint("»Â·ÚÙ†Ì·¯†ÏÈÊÂ†now ");
		bprint_ftos(bonuslife);
		bprint("\n");
	}
	sound(other, CHAN_ITEM, "moon/items/book.wav", H_ROTTEN, ATTN_NORM);
	stuffcmd(other, "bf\n");
	remove(self);
};

void(entity who) DropUpgrade =
{
	local entity item;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.cnt = (rint((random() * LOGIC_DEFEND)) + H_ROTTEN);
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel(item, "progs/tome.mdl");
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = UpgradeTouch;
	item.nextthink = (time + MENTAT_TIME);
	item.think = SUB_Remove;
};

void(entity who, float val) DropOtherBook =
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
	item.nextthink = (time + MENTAT_TIME);
	item.think = SUB_Remove;
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
	if ((other.classname != "player"))
	{
		return;
	}
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	if ((other.health < other.max_health))
	{
		sprint(other, "You get ");
		sprint(other, self.netname);
		sprint(other, " and receive ");
		sprint_ftos(other, self.healamount);
		sprint(other, " health\n");
	}
	else
	{
		sprint(other, "You get ");
		sprint(other, self.netname);
		sprint(other, "\n");
	}
	T_Heal(other, self.healamount, WF_NORMAL);
	sound(other, CHAN_ITEM, "moon/items/potion.wav", H_ROTTEN, ATTN_NORM);
	stuffcmd(other, "bf\n");
	remove(self);
};

void() ELTouch =
{
	if ((other.classname != "player"))
	{
		return;
	}
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	if ((self.cnt == WF_NORMAL))
	{
		other.stre = (other.stre + H_ROTTEN);
	}
	if ((self.cnt == H_ROTTEN))
	{
		other.vit = (other.vit + H_ROTTEN);
		other.max_health = (other.max_health + H_MEGA);
		T_Heal(other, H_MEGA, WF_NORMAL);
	}
	if ((self.cnt == H_MEGA))
	{
		other.wiz = (other.wiz + H_ROTTEN);
		other.max_mana = (other.max_mana + H_ROTTEN);
		T_Mana(other, H_MEGA);
	}
	sprint(other, "You get ");
	sprint(other, self.netname);
	sprint(other, "\n");
	sound(other, CHAN_ITEM, "moon/items/potion.wav", H_ROTTEN, ATTN_NORM);
	stuffcmd(other, "bf\n");
	remove(self);
};

void(entity who) DrEL =
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
	pl = rint((random() * H_ROTTEN));
	item.cnt = pl;
	if ((pl == WF_NORMAL))
	{
		item.netname = "ÂÏÈ¯ÈÚ†ÔÊ†ÛÙÚÂÓÁÙË (+1 to strength)";
	}
	else
	{
		if ((pl == H_ROTTEN))
		{
			item.netname = "ÂÏÈ¯ÈÚ†ÔÊ†ˆÈÙ·ÏÈÙ˘ (+1 to vitality)";
		}
		else
		{
			item.netname = "ÂÏÈ¯ÈÚ†ÔÊ†Ì·ÁÈ„ (+1 to magic)";
		}
	}
};

void(entity who) DrHP =
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
	pl = MaxLvl();
	if ((pl < LOGIC_DEFEND))
	{
		item.healamount = rint(((random() * 35) + 15));
		item.netname = "small healing potion";
	}
	else
	{
		if (((pl >= LOGIC_DEFEND) && (pl <= KEY_MOVERIGHT)))
		{
			if ((random() < 0.6))
			{
				item.healamount = rint(((random() * 65) + 35));
				item.netname = "healing potion";
			}
			else
			{
				item.healamount = rint(((random() * 35) + 15));
				item.netname = "small healing potion";
			}
		}
		else
		{
			r = random();
			if ((r < 0.33))
			{
				item.healamount = rint(((random() * 65) + 35));
				item.netname = "healing potion";
			}
			else
			{
				if ((r > 0.66))
				{
					item.healamount = rint(((random() * 35) + 15));
					item.netname = "small healing potion";
				}
				else
				{
					item.healamount = rint(((random() * 100) + 65));
					item.netname = "big healing potion";
				}
			}
		}
	}
	setsize(item, '-12 -12 0', '12 12 36');
	item.touch = HPTouch;
	item.nextthink = (time + 60);
	item.think = SUB_Remove;
};

void(entity e, float n1, float n2) SCTCLP =
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

void(entity e, float sc_n, float cnn, float cn) SCTD =
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

void() SCT =
{
	if ((other.classname != "player"))
	{
		return;
	}
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
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
	sound(other, CHAN_ITEM, "moon/items/scroll.wav", CHSCAM_ON, ATTN_NORM);
	stuffcmd(other, "bf\n");
	remove(self);
};

void(entity who) DrSC =
{
	local entity item;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.flags = FL_ITEM;
	item.cnt = rint((CHSCAM_ON + (random() * LOGIC_FINDDEFEND)));
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	item.angles_y = rint((random() * 360));
	setmodel(item, "progs/scroll.mdl");
	setsize(item, '-16 -16 0', '16 16 48');
	item.touch = SCT;
	item.nextthink = (time + 60);
	item.think = SUB_Remove;
};

void() ShardTouch =
{
	if ((other.classname != "player"))
	{
		return;
	}
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	if (((!(other.items & IT_ARMOR1) && !(other.items & IT_ARMOR2)) && !(other.items & IT_ARMOR3)))
	{
		other.items = (other.items + IT_ARMOR1);
		other.armortype = 0.3;
		other.armorvalue = SVC_SETVIEWPORT;
	}
	else
	{
		other.armorvalue = (other.armorvalue + SVC_SETVIEWPORT);
		if ((other.armorvalue > 255))
		{
			other.armorvalue = 255;
		}
	}
	sound(other, CHAN_ITEM, "moon/items/shard.wav", CHSCAM_ON, ATTN_NORM);
	stuffcmd(other, "bf\n");
	remove(self);
};

void(entity who) DrSH =
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
	item.nextthink = (time + 60);
	item.think = SUB_Remove;
};

void() GoldTouch =
{
	if ((other.classname != "player"))
	{
		return;
	}
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	other.gold = (other.gold + self.gold);
	sprint(other, "You get ");
	sprint_ftos(other, self.gold);
	sprint(other, " gold\n");
	sound(other, CHAN_ITEM, "moon/items/gold.wav", CHSCAM_ON, ATTN_NORM);
	stuffcmd(other, "bf\n");
	remove(self);
};

void() mentat_think =
{
	if ((self.attack_finished < (time + LOGIC_FINDDEFEND)))
	{
		if ((self.cnt == WF_NORMAL))
		{
			sprint(self.owner, self.netname);
			sprint(self.owner, " is fading\n");
		}
		self.cnt = CHSCAM_ON;
	}
	if ((((self.attack_finished < time) || (self.owner.health <= WF_NORMAL)) || (((self.owner.mentat_bonus + self.owner.mentat_bonus2) + self.owner.mentat_bonus3) == WF_NORMAL)))
	{
		if ((self.mentat_bonus == CHSCAM_ON))
		{
			self.owner.mentat_bonus = WF_NORMAL;
		}
		else
		{
			if ((self.mentat_bonus2 == CHSCAM_ON))
			{
				self.owner.mentat_bonus2 = WF_NORMAL;
			}
			else
			{
				if ((self.mentat_bonus3 == CHSCAM_ON))
				{
					self.owner.mentat_bonus3 = WF_NORMAL;
				}
			}
		}
		remove(self);
	}
	self.nextthink = (time + CHSCAM_ON);
	self.think = mentat_think;
};

void() MentatTouch =
{
	local entity e;

	if ((other.classname != "player"))
	{
		return;
	}
	if ((other.health <= WF_NORMAL))
	{
		return;
	}
	sound(other, CHAN_ITEM, "moon/items/drug.wav", CHSCAM_ON, ATTN_NORM);
	stuffcmd(other, "bf\n");
	if ((self.prefix == CHSCAM_ON))
	{
		sprint(other, "You get ÔÊÊÂÓ„ÈˆÂ†‰ÚıÁ (increase your damage by 20%)\n");
		self.netname = "ÔÊÊÂÓ„ÈˆÂ†‰ÚıÁ";
		e = find(world, classname, "mentat");
		while (e)
		{
			if ((e.owner == other))
			{
				if ((e.mentat_bonus == CHSCAM_ON))
				{
					e.attack_finished = (time + MENTAT_TIME);
					remove(self);
					return;
				}
			}
			e = find(e, classname, "mentat");
		}
		self.mentat_bonus = CHSCAM_ON;
		other.mentat_bonus = CHSCAM_ON;
	}
	else
	{
		if ((self.prefix == H_MEGA))
		{
			sprint(other, "You get ‰ÂÊÂÓÛÈˆÂ†‰ÚıÁ (reduce received damage by 20%)\n");
			self.netname = "‰ÂÊÂÓÛÈˆÂ†‰ÚıÁ";
			e = find(world, classname, "mentat");
			while (e)
			{
				if ((e.owner == other))
				{
					if ((e.mentat_bonus2 == CHSCAM_ON))
					{
						e.attack_finished = (time + MENTAT_TIME);
						remove(self);
						return;
					}
				}
				e = find(e, classname, "mentat");
			}
			self.mentat_bonus2 = CHSCAM_ON;
			other.mentat_bonus2 = CHSCAM_ON;
		}
		else
		{
			sprint(other, "You get ·„„ÂÏÂÚ·ÙÈˆÂ†‰ÚıÁ (increase your attack speed)\n");
			self.netname = "·„„ÂÏÂÚ·ÙÈˆÂ†‰ÚıÁ";
			e = find(world, classname, "mentat");
			while (e)
			{
				if ((e.owner == other))
				{
					if ((e.mentat_bonus3 == CHSCAM_ON))
					{
						e.attack_finished = (time + MENTAT_TIME);
						remove(self);
						return;
					}
				}
				e = find(e, classname, "mentat");
			}
			self.mentat_bonus3 = CHSCAM_ON;
			other.mentat_bonus3 = CHSCAM_ON;
		}
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

void(entity who) DrDR =
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
	item.classname = "mentat";
	setmodel(item, "progs/drugs.mdl");
	item.prefix = rint(((random() * H_MEGA) + CHSCAM_ON));
	item.skin = (item.prefix - CHSCAM_ON);
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = MentatTouch;
	item.nextthink = (time + 60);
	item.think = SUB_Remove;
};

void(entity who) DrWE =
{
	local float r;
	local entity item;

	r = random();
	item = spawn();
	item.origin = (who.origin - '0 0 24');
	if ((r < 0.15))
	{
		setmodel(item, "progs/g_shot.mdl");
		item.ammo_shells = rint(((random() * SVC_SETVIEWANGLES) + SVC_SETVIEWANGLES));
		item.netname = "Double-barrelled Shotgun";
		item.items = IT_SUPER_SHOTGUN;
	}
	else
	{
		if ((r < 0.3))
		{
			setmodel(item, "progs/g_nail.mdl");
			item.ammo_nails = rint(((random() * 25) + 25));
			item.netname = "Nailgun";
			item.items = IT_NAILGUN;
		}
		else
		{
			if ((r < 0.45))
			{
				setmodel(item, "progs/g_nail2.mdl");
				item.ammo_nails = rint(((random() * 25) + 25));
				item.netname = "Super Nailgun";
				item.items = IT_SUPER_NAILGUN;
			}
			else
			{
				if ((r < 0.6))
				{
					setmodel(item, "progs/g_rock.mdl");
					item.ammo_rockets = rint(((random() * SVC_SETVIEWPORT) + SVC_SETVIEWPORT));
					item.netname = "Grenade Launcher";
					item.items = IT_GRENADE_LAUNCHER;
				}
				else
				{
					if ((r < 0.8))
					{
						setmodel(item, "progs/g_rock2.mdl");
						item.ammo_rockets = rint(((random() * SVC_SETVIEWPORT) + SVC_SETVIEWPORT));
						item.netname = "Rocket Launcher";
						item.items = IT_ROCKET_LAUNCHER;
					}
					else
					{
						setmodel(item, "progs/g_light.mdl");
						item.ammo_cells = rint(((random() * SVC_SETVIEWPORT) + SVC_SETVIEWANGLES));
						item.netname = "Thunderbolt";
						item.items = IT_LIGHTNING;
					}
				}
			}
		}
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
	item.nextthink = (time + 60);
	item.think = SUB_Remove;
};

void(entity who) DropPLGold =
{
	local entity item;
	local entity h;

	if ((self.gold == WF_NORMAL))
	{
		return;
	}
	if ((who.classname != "player"))
	{
		return;
	}
	item = spawn();
	item.gold = who.gold;
	item.origin = (who.origin - '0 0 24');
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.owner = who;
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel(item, "progs/gold.mdl");
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = GoldTouch;
	item.nextthink = (time + 60);
	item.think = SUB_Remove;
};

void(entity who) DropGold =
{
	local entity item;
	local entity h;
	local float bngld;

	h = find(world, classname, "player");
	item = spawn();
	if ((who.classname == "derrick"))
	{
		item.origin = (who.origin + '0 0 8');
		random();
		item.gold = ((H_MEGA + (2.5 * h.lvl)) + (random() * (SVC_SETVIEWANGLES + (h.lvl * H_MEGA))));
	}
	else
	{
		item.gold = ((CHSCAM_ON + (SVC_SETVIEWPORT * h.lvl)) + (random() * 60));
		item.origin = (who.origin - '0 0 24');
	}
	item.gold = ceil(item.gold);
	if ((who.prefix == SVC_SETVIEWPORT))
	{
		item.gold = (item.gold + percent(item.gold, who.prefix_value));
	}
	item.gold = (item.gold + percent(item.gold, up_gold_value));
	bngld = WF_NORMAL;
	if ((who.killer.magic_typeone == LOGIC_FINDDEFEND))
	{
		bngld = (bngld + who.killer.magic_typeone_value);
	}
	if ((who.killer.magic_typetwo == LOGIC_FINDDEFEND))
	{
		bngld = (bngld + who.killer.magic_typetwo_value);
	}
	if ((who.killer.ring_typeone == LOGIC_FINDDEFEND))
	{
		bngld = (bngld + who.killer.ring_typeone_value);
	}
	if ((who.killer.ring_typetwo == LOGIC_FINDDEFEND))
	{
		bngld = (bngld + who.killer.ring_typetwo_value);
	}
	item.gold = (item.gold + percent(item.gold, bngld));
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.owner = who;
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel(item, "progs/gold.mdl");
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = GoldTouch;
	item.nextthink = (time + 60);
	item.think = SUB_Remove;
};

void(entity who) DropAmmo =
{
	local entity item;

	item = spawn();
	item.origin = (who.origin - '0 0 24');
	item.gold = (CHSCAM_ON + (random() * 125));
	item.velocity_z = 300;
	item.velocity_x = (-100 + (random() * 200));
	item.velocity_y = (-100 + (random() * 200));
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	if ((random() < 0.3))
	{
		setmodel(item, "maps/b_shell0.bsp");
		item.ammo_shells = ceil((CHSCAM_ON + (random() * 35)));
	}
	else
	{
		if ((random() < 0.6))
		{
			setmodel(item, "maps/b_nail0.bsp");
			item.ammo_nails = ceil((LOGIC_HUNTENEMY + (random() * 35)));
		}
		else
		{
			if ((random() < 0.8))
			{
				setmodel(item, "maps/b_rock0.bsp");
				item.ammo_rockets = ceil((CHSCAM_ON + (random() * SVC_SETVIEWANGLES)));
			}
			else
			{
				setmodel(item, "maps/b_batt0.bsp");
				item.ammo_cells = ceil((H_MEGA + (random() * KEY_MOVEFORWARD)));
			}
		}
	}
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = ammo_touch;
	item.nextthink = (time + 60);
	item.think = SUB_Remove;
};

void() DropItem =
{
	local entity e;

	self.think = SUB_Null;
	self.nextthink = WF_NORMAL;
	if ((self.scroll_shaf_eff > time))
	{
		shaf_eff();
	}
	if ((self.scroll_infe_eff > time))
	{
		infe_eff();
	}
	if ((self.prefix == LOGIC_HUNTENEMY))
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
	if ((self.prefix == SVC_SETVIEWPORT))
	{
		DropGold(self);
		return;
	}
	if ((random() < 0.0035))
	{
		DropUpgrade(self);
		return;
	}
	else
	{
		if ((random() < 0.0125))
		{
			DropOtherBook(self, LOGIC_HUNTENEMY);
			return;
		}
		if ((random() < 0.0125))
		{
			DropOtherBook(self, TE_WIZSPIKE);
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
		DrEL(self);
		return;
	}
	if ((random() < MON_MAGICCHANCE))
	{
		DrWE(self);
		return;
	}
	if ((random() < MON_MAGICCHANCE))
	{
		DrSH(self);
		return;
	}
	if ((random() < 0.025))
	{
		DrDR(self);
		return;
	}
	if ((random() < MON_UNIQUECHANCE))
	{
		DrHP(self);
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
	local float nx;

	nx = ((was + (l * GRD_DEFENDTIME)) + percent((l * GRD_DEFENDTIME), 35));
	return (nx);
};

void() GiveExp =
{
	local entity e;
	local entity head;

	if (gameover)
	{
		return;
	}
	e = find(world, classname, "player");
	if (((e.exp + self.exp) >= e.nextexp))
	{
		BotActivate();
	}
	while (e)
	{
		e.exp = (e.exp + self.exp);
		if ((e.exp >= e.nextexp))
		{
			e.lvl = (e.lvl + CHSCAM_ON);
			if (!(e.items & IT_KEY1))
			{
				e.items = (e.items + IT_KEY1);
			}
			if ((e.health > WF_NORMAL))
			{
				if ((e.health < e.max_health))
				{
					e.health = e.max_health;
				}
			}
			e.frags = e.lvl;
			e.nextexp = exp_table(e.lvl, e.nextexp);
			if ((e.lvl <= 35))
			{
				e.point = (e.point + SVC_SETVIEWPORT);
			}
			else
			{
				if ((e.lvl <= GRD_DEFENDTIME))
				{
					e.point = (e.point + LOGIC_DEFEND);
				}
				else
				{
					e.point = (e.point + LOGIC_FINDDEFEND);
				}
			}
			sound(e, CHAN_BODY, "moon/misc/levelup.wav", CHSCAM_ON, ATTN_NORM);
			sprint(e, "\n=== ÃÂˆÂÏ†’ ===\n");
			sprint(e, "You are now ");
			sprint_ftos(e, e.lvl);
			sprint(e, " leveled player\n");
			sprint(e, "Next level: ");
			sprint_ftos(e, e.nextexp);
			sprint(e, " expirience.\n");
			if ((e.cl_nohelp == WF_NORMAL))
			{
				if ((e.lvl < LOGIC_DEFEND))
				{
					sprint(e, "use ÛÙ·ÙÛ command to upgrade your stats\n");
				}
			}
			if ((e.lvl == 50))
			{
				sprint(e, "Congratulations. You won the game.\n");
			}
			sprint(e, "================\n");
			head = find(world, classname, "heart");
			if ((head != world))
			{
				if ((head.lvl != e.lvl))
				{
					head.max_health = (head.max_health + SVC_SETVIEWANGLES);
					head.health = (head.health + SVC_SETVIEWANGLES);
					if ((head.health > head.max_health))
					{
						head.health = head.max_health;
					}
					head.lvl = e.lvl;
				}
			}
		}
		e = find(e, classname, "player");
	}
};
