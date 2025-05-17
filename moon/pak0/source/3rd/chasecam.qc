//=====================================
// Mod:			DuelMod
// Name:		chasecam.qc
// Function:		Behind view camera
// Programmer:		3d[Power]
// Comment:		Special optimization for duelmod
// Last update: 	28.06.00
//=====================================

// message protocol defines
float SVC_SETVIEWPORT   = 5;
float SVC_SETVIEWANGLES = 10;
float CHSCAM_ON       = 1;

void() Keep_cam_chasing_owner;
void( float opt ) Remove_chase_cam;
float chasecam_dist = 118;
float chasecam_zofs = 24;

// called either by player or chase cam entities (to restart)
void( entity cam_owner ) Start_chase_cam =
{
	local entity	chase_cam;

	chase_cam = spawn();

	chase_cam.owner=cam_owner;

	// turn on bit-flag
	chase_cam.owner.speed = chase_cam.owner.speed | CHSCAM_ON;

	chase_cam.solid = SOLID_NOT;
	chase_cam.movetype = MOVETYPE_FLY;


	chase_cam.angles = chase_cam.owner.angles;

	setmodel (chase_cam,  "progs/eyes.mdl");
	setsize (chase_cam, '0 0 0', '0 0 0');
	setorigin( chase_cam, chase_cam.owner.origin );
	chase_cam.classname = "chase_cam";

	chase_cam.nextthink = time + 0.1;
	chase_cam.think = Keep_cam_chasing_owner;

	msg_entity = chase_cam.owner;                         // target of message
	WriteByte (MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity (MSG_ONE, chase_cam);           // view port
	// distance clipping
	chase_cam.ammo_shells = chasecam_dist / 3; // chasecam_dist;

};

// secondary think for cam entities
void() Reable_chase_cam =
{
	self.nextthink = time + 0.1;

	if (self.owner.health <= 0)
	{
		remove(self);
		return;
	}

	if (self.owner.waterlevel)
		return;

	Start_chase_cam( self.owner );
	remove( self );

};

// called only by chase cam entities
// opt values
// TRUE = remove completely
// FALSE = remove view but keep alive with Reable_chase_cam();
void( float opt ) Remove_chase_cam =
{
	// turn off bit-flag
	if ( (self.owner.speed & CHSCAM_ON) )
		self.owner.speed = self.owner.speed - CHSCAM_ON;

	// makes entity appear gone even if going into keep alive state
	setmodel( self, "" );
	self.velocity = '0 0 0';

	// set view-point back to normal
	msg_entity = self.owner;      // target of message
	WriteByte (MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity (MSG_ONE, self.owner);           // view port

	if ( !opt )
	{
		self.nextthink = time + 0.1;
		self.think = Reable_chase_cam;
	}
	else
		remove( self );

};

// main think function for cam entities
//  self.ammo_shells = distance clipping
//  self.ammo_nails = hang-up flag

void() Keep_cam_chasing_owner =
{
	local vector goal, dir;
	local float  dist, cap,
					 f_f;
	//debug var
	// local string s;

	self.nextthink = time + 0.1;

	// check if player toggled
	// or in water
	if (! (self.owner.speed & CHSCAM_ON))
	{
		Remove_chase_cam( TRUE );
		return;
	}
	// get player velocity relative to player's
	// current yaw
	// f_f (based on running calcs (maxspeed = 400)
	//  (back ~= 640, forward ~= 0)
	dir_y = self.owner.v_angle_y;
	makevectors( dir );
	f_f = vlen( (v_forward * 320) - self.owner.velocity );

	// held for use after second makevectors call for
	// v_forward based only on yaw
	dir = v_forward;

	makevectors( self.owner.v_angle );

	// set spot before clipping
	goal = self.owner.origin - (v_forward * self.ammo_shells);
	if (self.owner.v_angle_x > 16)
	{
		// dir is first v_forward based on yaw only
		goal = goal + (dir * (self.owner.v_angle_x - 16) );
		cap = chasecam_zofs - ((self.owner.v_angle_x - 16) );// * 0.8);
		//if (cap < 0) cap = 0;
		goal_z = goal_z + cap;
		if (goal_z < self.owner.origin_z + 20)
			goal_z = self.owner.origin_z + 20;

	}
	else
		goal_z = goal_z + chasecam_zofs;


	traceline (self.owner.origin, goal, FALSE, self.owner);

	// for fading from walls and up-aim auto rising
	if (trace_fraction < 1 || self.owner.v_angle_x < -16)
		self.ammo_shells = 8 + vlen(trace_endpos - self.owner.origin);

	// avoids most hang-ups along walls
	goal = trace_endpos + ( v_forward * 2 );



	// clip from ceiling if too close
	traceline (goal, goal + '0 0 32', FALSE, self.owner );
	if (trace_fraction < 1 )
	{
		dir = trace_endpos - '0 0 32';

		traceline (goal, goal - '0 0 32', FALSE, self.owner );
		if (trace_fraction == 1)
			goal = dir;
	}


	dir = normalize(goal - self.origin);
	dist = vlen(goal - self.origin);


	// traceline( self.origin, goal, FALSE, self.owner );
	// if ( trace_fraction == 1 )
	if ( visible(self.owner) )
	{
		self.angles = self.owner.angles;

		cap = dist * 0.2;

		if (cap > 5.2)
			self.velocity = dir * dist * 5.2;
		else if (cap > 1)
			self.velocity = dir * dist * cap;
		else
			self.velocity = dir * dist;

		// tighten up if owner running backwards
		if ( f_f > 560)
		{
			self.velocity = self.velocity * 2;
		}

	}
	else
		setorigin( self, goal );

	// fade back from walls
	self.ammo_shells = self.ammo_shells + 4.5;
	if (self.ammo_shells > chasecam_dist)
		self.ammo_shells = chasecam_dist;

	// respawn if missile ent. get's hung up
	if( self.oldorigin == self.origin )
	{
		if( dist > 30 )
			self.ammo_nails = self.ammo_nails + 1;
		if( self.ammo_nails > 2 )
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
	if(self.speed & CHSCAM_ON)
		self.speed = self.speed - CHSCAM_ON;
	else { self.speed = CHSCAM_ON; self.weaponmodel = "";
		Start_chase_cam( self ); }
};