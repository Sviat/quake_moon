/// ReProjectMoon-specific source file
/// "moon4" map-specific source file
/// Here are all constants and functions used for unit Navigation on map

// -===========================================================-
// Project MOON
// Waypoints for map moon4
// Created by 3d[Power]
// -===========================================================-

// WAY OPTIMIZATION FOR MOON4.bsp
void() moon4_touch = // Works - dont touch. 500 lines of pure pleasure
{
	local entity tmp;
	local float nextnum;
	local float nextline;

	if ( other.goalentity != self )
	{
		return;
	}

	if ( (other.flags & FL_MONSTER) && (other.health <= 0) && (other.goalentity == self) )
	{
		bprint("ERROR: Died monster tries to touch waypoint. Please report this bug\n");
		bprint("ERROR INFO:\n netname:");
		bprint(other.netname);
		bprint("\n");
		remove(other);
	}

	if ( other.health <= 0 )
	{
		return;
	}

	if( other.wantline <= 0 || other.wantline > 7 )
	{
		dprint("ERROR: movecode has requested nonexistent way ({0} line was requested). Please report this bug.\n", quick_ftos(other.wantline));
	}

	if ( (other.mon_logic == LOGIC_CAMPER) && (other.flags & FL_MONSTER) )
	{
		if (((other.wantline == self.line) && (other.wantnum == self.num)))
		{
			other.goalentity = world;
			other.mon_logic = LOGIC_STANDART;	// after camp go for HEART :)))))))))) heheheheh
			other.camp_time = ((time + 30) + (random() * 30));
			//other.th_stand();
		}
	}

	if ( (other.classname == MOON_GUARD_CLASSNAME) && (other.wantnum == self.num) && (other.wantline == self.line) && (other.action > 0) )
	{
		if ( other.action == LOGIC_PATROL )
		{
			GeneratePatrolTarget(other);
		}
		if ( other.action == LOGIC_FINDDEFEND )
		{
			// other.goalentity = world;
			other.action = LOGIC_DEFEND;
			other.velocity = VEC_ORIGIN;
			other.think = other.th_stand;
			return;
		}
	}

	if ( other.flags & FL_MONSTER )
	{
		other.velocity = VEC_ORIGIN;
	}

	nextline = self.line; // default

	if ( (self.line == 6) && (self.num == 5) ) // hack: too cloose to not opened door... ignore..
	{
		if ( other.enemy.classname == "shoot_ent" )
		{
			return;
		}
	}


	if(other.wantline == self.line)
	{
		if(other.wantnum > self.num)
			nextnum = self.num + 1;
		if(other.wantnum < self.num)
			nextnum = self.num - 1;
		if(other.wantnum == self.num)
		{
			other.think = other.th_stand;
		}
	}
	else if(self.line == 1)
	{
		if(self.num == 12 && (other.wantline == 5 || other.wantline == 6))
		{
			nextline = 5;
			nextnum = 4;
		}
		else if(other.wantline == 7)	// to gold derrick
		{
			if(self.num < 7)
				nextnum = self.num + 1;
			else if(self.num > 7)
				nextnum = self.num - 1;
			else if(self.num == 7)
			{
				nextline = 7;
				nextnum = 5;
			}
		}
		else if(other.wantline == 3)
		{
			if(self.num < 10) 			// can walk only from 10,1 waypoint
				nextnum = self.num + 1;
			else if(self.num > 10)
				nextnum = self.num - 1;
			else if(self.num == 10)
			{
				nextline = 3;
				nextnum = 1;
			}
		}
		else if(other.wantline == 2)
		{
			if(self.num < 4) 				// can walk only from 4,1 waypoint
				nextnum = self.num + 1;
			else if(self.num > 4)
				nextnum = self.num - 1;
			else if(self.num == 4)
			{
				nextline = 2;
				nextnum = 1;
			}
		}
		else if(other.wantline >= 4 && other.wantline <= 6)	// FIXME: JUMP OVER
		{
			if(self.num == 5 || self.num == 6)
			{
				nextline = 4;
				nextnum = 1;
			}
			else if(self.num < 5)
				nextnum = self.num + 1;
			else if(self.num > 5)
				nextnum = self.num - 1;
		}
	}
	else if(self.line == 2)
	{
		if(self.num == 8 && (other.wantline == 5 || other.wantline == 6))
		{
			nextline = 6;
			nextnum = 4;
		}
		else if(other.wantline == 1 || other.wantline == 3 || other.wantline == 7)
		{
			if(self.num > 1)
				nextnum = self.num - 1;
			else if(self.num == 1)
			{
				nextline = 1;
				nextnum = 4;
			}
		}
		else if(other.wantline >= 4 && other.wantline <= 6) // FIXME: jump over
		{
			if(self.num < 2)
				nextnum = self.num + 1;
			else if(self.num > 2)
				nextnum = self.num - 1;
			else if(self.num == 2)
			{
				nextline = 4;
				nextnum = 5;
			}
		}
	}
	else if(self.line == 3)
	{
		if((other.wantline == 5 || other.wantline == 6) && self.num >= 6)	// jump over ceil
		{
			if(self.num == 6 || self.num == 7)	// FIXME
			{
				nextline = 5;
				nextnum = 4;
			}
			else if(self.num == 8 || self.num == 9)	// FIXME
			{
				nextline = 6;
				nextnum = 4;
			}
		}
		else if(other.wantline == 2 || other.wantline == 1 || (other.wantline >= 4 && other.wantline <= 6) || other.wantline == 7)
		{
			if(self.num > 1)
				nextnum = self.num - 1;
			else if(self.num == 1)
			{
				nextline = 1;
				nextnum = 10;
			}
		}
	}
	else if(self.line == 4)
	{
		if(other.wantline == 1 && other.wantnum <= 2)
		{
			if(self.num == 3)
			{
				if(random() < 0.5)
					nextnum = 4;
				else nextnum = 2;
			}
			else if(self.num < 3)
			{
				if(self.num > 1)
					nextnum = self.num - 1;
				else if(self.num == 1)
				{
					nextline = 1;
					nextnum = 6;
				}
			}
			else if(self.num > 3)
			{
				if(self.num < 5)
					nextnum = self.num + 1;
				else if(self.num == 5)
				{
					nextline = 2;
					nextnum = 2;
				}
			}
		}
		else if(other.wantline == 1 || other.wantline == 3 || other.wantline == 7)	// fix: ���� �� ��������!
		{
			if(self.num > 1)
				nextnum = self.num - 1;
			else if(self.num == 1)
			{
				nextline = 1;
				nextnum = 6;
			}
		}
		else if(other.wantline == 2)
		{
			if(self.num < 5)
				nextnum = self.num + 1;
			else if(self.num == 5)
			{
				nextline = 2;
				nextnum = 2;
			}
		}
		else if(other.wantline == 5 || other.wantline == 6)
		{
			if(self.num < 3)
				nextnum = self.num + 1;
			else if(self.num > 3)
				nextnum = self.num - 1;
			else if(self.num == 3)
			{
				nextline = 6;
				nextnum = 6;
			}
		}
	}
	else if(self.line == 5)
	{
		if(other.wantline < 5 || other.wantline == 7)
		{
			nextnum = self.num + 1;
			if(self.num == 5)
			{
				nextline = 6;
				nextnum = 5;
			}
		}
		else if(other.wantline == 6)
		{
			if(other.wantnum < 3)
				nextnum = self.num + 1;
			else
			{
				nextline = 6;
				nextnum = self.num;
			}
		}
	}
	else if(self.line == 6)
	{
		if(other.wantline < 5 || other.wantline == 7)
		{
			nextnum = self.num + 1;
			if(self.num == 6)
			{
				nextline = 4;
				nextnum = 3;
			}
		}
		else if(other.wantline == 5)
		{
			if(other.wantnum < 3)
				nextnum = self.num + 1;
			else if(self.num == 6)
				nextnum = self.num - 1;
			else
			{
				nextline = 5;
				nextnum = self.num;
			}
		}
	}
	else if(self.line == 7)
	{
		if(self.num == 5)
		{
			nextnum = 7;
			nextline = 1;
		}
		else if(self.wantline < 7)
			nextnum = self.num + 1;
	}

	// execute__find_new_way
	tmp = find(world, classname, "waypoint");
	while (tmp)
	{
		if ( (tmp.num == nextnum) && (tmp.line == nextline) )
		{
			other.goalentity = tmp;
			return;
		}
		tmp = find(tmp, classname, "waypoint");
	}
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
	if ( flg & WF_EXTRASIZE )
	{
		setsize(e, VEC_HULL2_MIN, VEC_HULL2_MAX);
	} else {
		setsize(e, VEC_WAY_MIN, VEC_WAY_MAX);
	}
};

void() moon_set_waypoints_moon4 =
{
	if (waypoints_ok)
	{
		return;
	}

	//	N (origin, num, line, flags, radius);
	//	rstair - heart
	N('368.7 -133.5 -167.3', 12,  1, WF_DEFEND, 100);
	N ('383.0  43.5 -184.0', 11,  1, 0, 150);
	N ('675.6  48.9 -184.0', 10,  1, 0, 150);
	N ('671.6 308.8 -240.0', 9, 1, 0, 150);
	N ('671.6 539.1 -320.0', 8, 1, 0, 150);
	N ('671.6 758.1 -360.0', 7, 1, 0, 150);
	N ('393.1 773.3 -360.0', 6,  1, 0, 150);
	N ('272.2 880.9 -360.0', 5,  1, WF_DEFEND, 150);
	N ('10.2 900.8 -360.0',  4,  1, WF_EXTRASIZE, 150);
	N ('10.2 1128.6 -376.0', 3,  1, 0, 150);
	N ('10.2 1455.1 -456.0', 2,  1, 0, 150);
	N ('4.3 1675.0 -488.0', 1, 1, WF_DEFEND, 150);
	N ('0.0 1867.8 -488.0',  0,  1, 0, 150);	// HEART
	//	lstair
	N ('-361.8 -136.6 -167.3', 8, 2, WF_DEFEND, 100);
	N ('-361.8  51.3 -184.0', 7, 2, 0, 150);
	N ('-684.3  42.9 -184.0', 6, 2, 0, 150);
	N ('-684.3 296.1 -240.0', 5, 2, 0, 150);
	N ('-684.3 505.2 -312.0', 4, 2, 0, 150);
	N ('-683.2 740.9 -360.0', 3, 2, WF_DEFEND, 150);
	N ('-394.5 761.1 -360.0', 2, 2, WF_DEFEND, 150);
	N ('-167.9 869.7 -360.0', 1, 2, WF_DEFEND, 150);
	// 	stairs to ceil - ceil
	N ('926.5  34.8 -184.0', 1, 3, 0, 150);
	N ('1223.4  31.2 -120.0', 2, 3, 0, 150);
	N ('1233.0 343.7 -72.0', 3, 3, 0, 150);
	N ('913.2 362.4 -24.0', 4, 3, 0, 150);
	N ('920.7  34.3 -24.0', 5, 3, 0, 150);
	N ('704.8 -24.6 -24.0', 6, 3, 0, 150);
	N ('247.7 -12.7 -24.0', 7, 3, WF_DEFEND, 120);
	N ('-48.6 -28.4 -24.0', 8, 3, 0, 120);
	N ('-505.1 -30.1 -24.0', 9, 3, 0, 120);
	// 	after gate (first spots in castle)
	N ('370.3 603.6 -360.0', 1, 4, WF_EXTRASIZE, 150);
	N ('377.2 321.6 -360.0', 2, 4, WF_DEFEND + WF_EXTRASIZE, 150);
	N ('-11.5 256.1 -360.0', 3, 4, WF_DEFEND + WF_EXTRASIZE, 200);
	N ('-329.9 291.6 -360.0', 4, 4, WF_DEFEND + WF_EXTRASIZE, 150);
	N ('-359.6 529.3 -360.0', 5, 4, WF_EXTRASIZE, 150);
	//	left hole
	N ('605.8 -1539.1 -360.0', 1, 5, 0, 20);
	N ('369.7 -1438.3 -360.0', 2, 5, 0, 20);
	N ('352.8 -930 -360.0', 3, 5, 0, 150);
	N ('346.2 -558.8 -360.0', 4, 5, WF_EXTRASIZE, 200);
	N ('148.9 -312.0 -360.0', 5, 5, WF_EXTRASIZE, 150);
	// 	right hole
	N ('-44.7 -1530.4 -360.0', 1, 6, 0, 20);
	N ('-217.7 -1434.2 -360.0', 2, 6, 0, 20);
	N ('-230.1 -930 -360.0', 3, 6, 0, 150);
	N ('-256.7 -518.5 -360.0', 4, 6, WF_EXTRASIZE, 200);
	N ('6.1 -211.0 -360.0', 5, 6, WF_EXTRASIZE, 200); // MAIN ENTRANCE <<
	N ('-7.1  14.3 -360.0', 6, 6, WF_EXTRASIZE, 200);
	//	;;; gold_derrick ;;;
	N ('676.8 1113.5 -360.0', 5, 7, 0, 150); // out derrick
	N ('947.6 1108.1 -360.0', 4, 7, 0, 150);
	N ('1181.5 1113.8 -360.0', 3, 7, 0, 150);
	N ('1351.0 1210.9 -360.0', 2, 7, 0, 150);
	N ('1523.2 1144.0 -360.0', 1, 7, 0, 150);

	S ('-1057.5 1625.1 -360.0', 220,0);
	S ('-1232.5 1625.1 -360.0', 270,1);
	S ('-1386.8 1625.1 -360.0', 270,2);
	S ('-1549.5 1606.0 -360.0', 305,3);
	S ('-1533.9 1435.1 -360.0', 0  ,4);

	NS ('-301.0 1225.7 -360.0', 1, 100);
	NS ('-300.2 1435.5 -360.0', 2, 100);
	NS ('-768.8 1435.1 -360.0', 3, 100);
	NS ('-1129.1 1441.0 -360.0', 4,100);

	waypoints_ok = TRUE;
};