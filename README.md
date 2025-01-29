# Mod Description

Project MOON was an unique modification for Quake1. ReProject aims to bring this awesome mod to the modern engine and closer to the wider audience.
Mod is best described as Hero Tower Defense FPS. The point of the game is to survive...

Read ``moon/Description.txt`` for more details.

### Naming

Original was a very early beta and had many issues with consistency.
Project MOON, Moon Rizing, Project Moon Rizing ... just MOON.
Mod's name in different places (even inside on file) may be referred differently, but common part was always MOON, which is how I'm going to call it.

ReProject was done for ReRelease hence its name, if anybody asks.

## Build

Author uses `fteqccgui64.exe` of version 6167 (2022-01-17T09:13:05.661658Z), which magically works. Using newer version on Windows proved to be problematic. Place `fteqccgui64.exe` in ``moon/pak0/source`` and open it. Now build without any whistles or bells.

## Installation and Launch

ReProject MOON targets Steam version of Quake 1, also known as Q1 ReRelease (based on Kex engine).

Preferred way to play is to obtain mod from the **Quake Enhanced Add-on Server** repository:
1. Set add-on repository in `Quake 1` launch options in Steam: `+ui_addonsBaseURL "https://kexquake.s3.amazonaws.com/"`
2. Go to `Add-Ons` menu, select `ReProject MOON`
3. Button `Download` may be unclickable due to overlapping with other mod names
	1. so you have to select closest mod (currently it is `Tained` or `Terra`, both work),
	2. press `Right-arrow button`, this will highlight `Download`
	3. press `Enter`
	4. wait till it is ready and different buttons will appear when you select MOON again
4. After selecting `ReProject MOON` buttons `Delete` and `Activate` are available, but may look unclickable due to overlapping with other mod names
	1. however if you hover over `Activate` you will see where it changes its background
	2. right-now it is letter `e` you can click on with mouse
5. After activation, you can start playing MOON from `Menu` -> `Single Player` -> `New Game` -> `ReProject MOON`.
	1. alternatively this can be done via console (\`): `map moon4` or bind to button

Nota bene! You cannot get configs through add-on manager within KEX, but you can still download them from GitHub repo: https://github.com/Sviat/quake_moon/tree/master/config

Alternatively, if you use custom client, like FTE, or got mod as archive:
1. Obtain copy of mod package
2. Extract to the `%USERPROFILE%\Saved Games\Nightdive Studios\Quake\`
3. Launch engine of choice (it is guaranteed to work only on Kex engine so far)
4. Type in console `exec moon.cfg` (or `exec moon_fte.cfg` for FTE)

### Controls

Nota bene:
Project MOON's special commands can't be changed from Quake settings menu.
You have to use configs and/or console.

ReProject MOON's console commands all prefixed with `pm`. Base command to start with is `pm_help`.
Some commands are reserved for server Host, they are marked with `pms_`.
Commands that change things for players own view are marked with `pmc_`.
All commands are just aliases for impulse codes. Using `pm_help` command, one can see exact impulse code listed in left most column.

List of most important aliases:

(Console User Interface)
* `pm_character` - show summary, which includes Hearts HP, Player's Experience progress and carried Gold.
* `pm_stats` - show Player's character skils (Strength, Vitality etc) and number of unspent skill points.
* `pm_inventory` - show Player's equipment (magic armor and ring), plus status effects (like active drugs)

(Interaction with the World)
* `pm_identify` - trigger surroundings check for items that have special properties in MOON.
* `pm_buy` - trigger surroundings check for anything to sale, and buy it if Gold allows.
* `pm_use` - trigger surroundings check for Magical items to wear (magic armors and rings)
* `pm_skill1` (`pm_skill2`) - raise character's Vitality (skill1) or Strength (skill2) by 1 point

To (re-)assign key for a command, type the following text at the quake console:
```
	...
	(syntax: unbind <key>) to remove previous assignments, and not stack on top
	(syntax: bind <key> <command>) to add new alias to key
	unbindkey c
	bind c pm_character
	unbindkey i
	bind i pm_inventory
	...
```

Easiest way:
I've included already configured config file with distribution called `moon.cfg`, feel free to modify relevant part of it or create a new one.

## License agreement

Limited Warranty:
Sanctus-Susanin expressly disclaims any warranty for any part of this Package.
The Package is provided "as is" without warranty of any kind, either express or implied, including, without limitation, the implied warranties of merchantability, fitness for a particular purpose, or noninfringement.

Responsibilities:
You are entitled to use this Package for personal use, but you are not be entitled to sell or gain profit of it.

(Re-)Distribution:
You may freely transfer this software Package citing original and remake authors and keeping this license.