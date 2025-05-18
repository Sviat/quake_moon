/// ReProjectMoon-specific source file
/// "moon4" map-specific source file
/// Here are all constants and functions used for map loading and initialization
/// This should be included right before "mn_init", to reduce needs in forward declarations

void() moon_set_map_moon4 =
{
	if ( mapname != "moon4" )
	{
		return;
	}

	moon_set_waypoints_moon4();

	gold_derrick('1340.9 1117.7 -360');

	game_brain();
	jesus_brain();
	sale_brain();
};