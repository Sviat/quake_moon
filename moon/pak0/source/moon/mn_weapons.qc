/// ReProjectMoon-specific source file
/// Here go all common functions related to weapon pick, switch, damage, ammo count etc


void(entity target) moon_reset_target_anim = // to reliably reset state after weapon change
{
	entity temp;
	temp = self;
	self = target;
	player_run(); // get out of any weapon firing states
	self = temp;
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

void(entity target, entity object) moon_target_consume_ammo_from =
{
	target.ammo_shells = (target.ammo_shells + object.ammo_shells);
	target.ammo_nails = (target.ammo_nails + object.ammo_nails);
	target.ammo_rockets = (target.ammo_rockets + object.ammo_rockets);
	target.ammo_cells = (target.ammo_cells + object.ammo_cells);
	moon_limit_target_ammo(target);
};

void(entity target) moon_set_target_currentammo = // variant of W_SetCurrentAmmo
{
	moon_reset_target_anim(target);
	target.items = (target.items - (target.items & (((IT_SHELLS | IT_NAILS) | IT_ROCKETS) | IT_CELLS)));

	switch(target.weapon)
	{
	case IT_AXE:
		target.currentammo = 0;
		target.weaponmodel = MOON_WEAPON_AXE_MODEL_FPV;
		target.weaponframe = WF_NORMAL;
		break;
	case IT_SHOTGUN:
		target.currentammo = target.ammo_shells;
		target.weaponmodel = MOON_WEAPON_SHOTGUN_MODEL_FPV;
		target.weaponframe = WF_NORMAL;
		target.items = (target.items | IT_SHELLS);
		break;
	case IT_SUPER_SHOTGUN:
		target.currentammo = target.ammo_shells;
		target.weaponmodel = MOON_WEAPON_SUPERSHOTGUN_MODEL_FPV;
		target.weaponframe = WF_NORMAL;
		target.items = (target.items | IT_SHELLS);
		break;
	case IT_NAILGUN:
		target.currentammo = target.ammo_nails;
		target.weaponmodel = MOON_WEAPON_NAILGUN_MODEL_FPV;
		target.weaponframe = WF_NORMAL;
		target.items = (target.items | IT_NAILS);
		break;
	case IT_SUPER_NAILGUN:
		target.currentammo = target.ammo_nails;
		target.weaponmodel = MOON_WEAPON_SUPERNAILGUN_MODEL_FPV;
		target.weaponframe = WF_NORMAL;
		target.items = (target.items | IT_NAILS);
		break;
	case IT_GRENADE_LAUNCHER:
		target.currentammo = target.ammo_rockets;
		target.weaponmodel = MOON_WEAPON_GRENADELAUNCHER_MODEL_FPV;
		target.weaponframe = WF_NORMAL;
		target.items = (target.items | IT_ROCKETS);
		break;
	case IT_ROCKET_LAUNCHER:
		target.currentammo = target.ammo_rockets;
		target.weaponmodel = MOON_WEAPON_ROCKETLAUNCHER_MODEL_FPV;
		target.weaponframe = WF_NORMAL;
		target.items = (target.items | IT_ROCKETS);
		break;
	case IT_LIGHTNING:
		target.currentammo = target.ammo_cells;
		target.weaponmodel = MOON_WEAPON_LIGHTNING_MODEL_FPV;
		target.weaponframe = WF_NORMAL;
		target.items = (target.items | IT_CELLS);
		break;
	default:
		target.currentammo = 0;
		target.weaponmodel = string_null;
		target.weaponframe = WF_NORMAL;
	}

	if ( target.speed & CHSCAM_ON )
	{
		target.weaponmodel = string_null;
	}
};

float(float weapon, float ammo) moon_is_enough_ammo = // variant of W_EnoughAmmoToShoot
{
	switch(weapon)
	{
	case IT_AXE:
		return (TRUE);
	case IT_SHOTGUN:
		return ((ammo >= MOON_WEAPON_SHOTGUN_SALVO_SIZE) ? TRUE : FALSE);
	case IT_SUPER_SHOTGUN:
		return ((ammo >= MOON_WEAPON_SUPERSHOTGUN_SALVO_SIZE) ? TRUE : FALSE);
	case IT_NAILGUN:
		return ((ammo >= MOON_WEAPON_NAILGUN_SALVO_SIZE) ? TRUE : FALSE);
	case IT_SUPER_NAILGUN:
		return ((ammo >= MOON_WEAPON_SUPERNAILGUN_SALVO_SIZE) ? TRUE : FALSE);
	case IT_GRENADE_LAUNCHER:
		return ((ammo >= MOON_WEAPON_GRENADELAUNCHER_SALVO_SIZE) ? TRUE : FALSE);
	case IT_ROCKET_LAUNCHER:
		return ((ammo >= MOON_WEAPON_ROCKETLAUNCHER_SALVO_SIZE) ? TRUE : FALSE);
	case IT_LIGHTNING:
		return ((ammo >= MOON_WEAPON_LIGHTNING_SALVO_SIZE) ? TRUE : FALSE);
	default:
		return (FALSE);
	}
};

float(entity target, float weapon) moon_target_has_enough_ammo =
{
	switch(weapon)
	{
	case IT_AXE:
		return (TRUE);
	case IT_SHOTGUN:
		return ((target.ammo_shells >= MOON_WEAPON_SHOTGUN_SALVO_SIZE) ? TRUE : FALSE);
	case IT_SUPER_SHOTGUN:
		return ((target.ammo_shells >= MOON_WEAPON_SUPERSHOTGUN_SALVO_SIZE) ? TRUE : FALSE);
	case IT_NAILGUN:
		return ((target.ammo_nails >= MOON_WEAPON_NAILGUN_SALVO_SIZE) ? TRUE : FALSE);
	case IT_SUPER_NAILGUN:
		return ((target.ammo_nails >= MOON_WEAPON_SUPERNAILGUN_SALVO_SIZE) ? TRUE : FALSE);
	case IT_GRENADE_LAUNCHER:
		return ((target.ammo_rockets >= MOON_WEAPON_GRENADELAUNCHER_SALVO_SIZE) ? TRUE : FALSE);
	case IT_ROCKET_LAUNCHER:
		return ((target.ammo_rockets >= MOON_WEAPON_ROCKETLAUNCHER_SALVO_SIZE) ? TRUE : FALSE);
	case IT_LIGHTNING:
		return ((target.ammo_cells >= MOON_WEAPON_LIGHTNING_SALVO_SIZE) ? TRUE : FALSE);
	default:
		return (FALSE);
	}
};

float(entity target, float include_dangerous = false) moon_get_target_best_weapon = // variant of W_BestWeapon
{
	local float it;

	it = target.items;
	if ( (target.waterlevel <= 1) && (it & IT_LIGHTNING) && moon_target_has_enough_ammo(target, IT_LIGHTNING) )
	{
		return (IT_LIGHTNING);
	}
	if ( (it & IT_SUPER_NAILGUN) && moon_target_has_enough_ammo(target, IT_SUPER_NAILGUN) )
	{
		return (IT_SUPER_NAILGUN);
	}
	if ( (it & IT_SUPER_SHOTGUN) && moon_target_has_enough_ammo(target, IT_SUPER_SHOTGUN) )
	{
		return (IT_SUPER_SHOTGUN);
	}

	if ( include_dangerous && (it & IT_ROCKET_LAUNCHER) && moon_target_has_enough_ammo(target, IT_ROCKET_LAUNCHER) )
	{
		return (IT_ROCKET_LAUNCHER);
	}

	if ( (it & IT_NAILGUN) && moon_target_has_enough_ammo(target, IT_NAILGUN))
	{
		return (IT_NAILGUN);
	}
	if ( (it & IT_SHOTGUN) && moon_target_has_enough_ammo(target, IT_SHOTGUN) )
	{
		return (IT_SHOTGUN);
	}

	if ( include_dangerous && (it & IT_GRENADE_LAUNCHER) && moon_target_has_enough_ammo(target, IT_GRENADE_LAUNCHER) )
	{
		return (IT_GRENADE_LAUNCHER);
	}

	return (IT_AXE);
};

float(entity target, float wpn) moon_select_target_weapon =
{
	target.weapon = wpn;
	moon_set_target_currentammo(target);
	return target.weapon;
};

float(entity target, float include_dangerous = false) moon_swap_target_to_best_weapon =
{
	target.weapon = moon_get_target_best_weapon(target, include_dangerous);
	moon_set_target_currentammo(target);
	return target.weapon;
};

float(float weapon) moon_get_weapon_rank =
{
	switch(weapon)
	{
	case IT_LIGHTNING:
		return 1;
	case IT_ROCKET_LAUNCHER:
		return 2;
	case IT_SUPER_NAILGUN:
		return 3;
	case IT_GRENADE_LAUNCHER:
		return 4;
	case IT_SUPER_SHOTGUN:
		return 5;
	case IT_NAILGUN:
		return 6;
	case IT_AXE:
	case IT_SHOTGUN:
	default:
		return 7;
	}
};

void(entity target, float candidate) moon_set_target_deathmatch_weapon =
{
	local float rank_current;
	local float rank_candidate;

	rank_current = moon_get_weapon_rank(target.weapon);
	rank_candidate = moon_get_weapon_rank(candidate);
	if ( rank_candidate < rank_current )
	{
		target.weapon = candidate;
	}
};