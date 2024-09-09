//Decompiled code. Please respect the original copyright.
float FALSE;
float TRUE = 1;
float FL_FLY    	= 1;
float FL_SWIM   	= 2;
float FL_CLIENT 	= 8;
float FL_INWATER    	= 16;
float FL_MONSTER    	= 32;
float FL_GODMODE    	= 64;
float FL_NOTARGET    	= 128;
float FL_ITEM    		= 256;
float FL_ONGROUND    	= 512;
float FL_PARTIALGROUND  = 1024;
float FL_WATERJUMP    	= 2048;
float FL_JUMPRELEASED   = 4096;
float MOVETYPE_NONE		= 0;
float MOVETYPE_WALK     = 3;
float MOVETYPE_STEP     = 4;
float MOVETYPE_FLY    	= 5;
float MOVETYPE_TOSS     = 6;
float MOVETYPE_PUSH    	= 7;
float MOVETYPE_NOCLIP   = 8;
float MOVETYPE_FLYMISSILE= 9;
float MOVETYPE_BOUNCE   = 10;
float MOVETYPE_BOUNCEMISSILE = 11;
float SOLID_NOT 		= 0;
float SOLID_TRIGGER    	= 1;
float SOLID_BBOX    	= 2;
float SOLID_SLIDEBOX 	= 3;
float SOLID_BSP    		= 4;
float RANGE_MELEE = 0;
float RANGE_NEAR  = 1;
float RANGE_MID   = 2;
float RANGE_FAR   = 3;
float DEAD_NO 		= 0;
float DEAD_DYING	= 1;
float DEAD_DEAD 	= 2;
float DEAD_RESPAWNABLE = 3;
float DAMAGE_NO 	= 0;
float DAMAGE_YES   	= 1;
float DAMAGE_AIM   	= 2;
float IT_AXE    		= 4096;
float IT_SHOTGUN    		= 1;
float IT_SUPER_SHOTGUN    	= 2;
float IT_NAILGUN			= 4;
float IT_SUPER_NAILGUN    	= 8;
float IT_GRENADE_LAUNCHER  	= 16;
float IT_ROCKET_LAUNCHER	= 32;
float IT_LIGHTNING    		= 64;
float IT_EXTRA_WEAPON 		= 128;
float IT_SHELLS    		= 256;
float IT_NAILS     		= 512;
float IT_ROCKETS   		= 1024;
float IT_CELLS     		= 2048;
float IT_ARMOR1    		= 8192;
float IT_ARMOR2    		= 16384;
float IT_ARMOR3    		= 32768;
float IT_SUPERHEALTH   	= 65536;
float IT_KEY1    		= 131072;
float IT_KEY2    		= 262144;
float IT_INVISIBILITY   	= 524288;
float IT_INVULNERABILITY	= 1048576;
float IT_SUIT    		= 2097152;
float IT_QUAD    		= 4194304;
float CONTENT_EMPTY    = -1;
float CONTENT_SOLID    = -2;
float CONTENT_WATER    = -3;
float CONTENT_SLIME    = -4;
float CONTENT_LAVA     = -5;
float CONTENT_SKY      = -6;
float STATE_TOP    = 0;
float STATE_BOTTOM = 1;
float STATE_UP     = 2;
float STATE_DOWN   = 3;
vector VEC_ORIGIN;
vector VEC_HULL_MIN    	= '-16 -16 -24';
vector VEC_HULL_MAX    	= '16 16 32';
vector VEC_HULL2_MIN    = '-32 -32 -24';
vector VEC_HULL2_MAX    = '32 32 64';
float SVC_TEMPENTITY    = 23;
float SVC_KILLEDMONSTER = 27;
float SVC_FOUNDSECRET	= 28;
float SVC_INTERMISSION	= 30;
float SVC_FINALE    	= 31;
float SVC_CDTRACK    	= 32;
float SVC_SELLSCREEN    = 33;
float TE_SPIKE			= 0;
float TE_SUPERSPIKE    	= 1;
float TE_GUNSHOT    	= 2;
float TE_EXPLOSION    	= 3;
float TE_TAREXPLOSION   = 4;
float TE_LIGHTNING1    	= 5;
float TE_LIGHTNING2    	= 6;
float TE_WIZSPIKE    	= 7;
float TE_KNIGHTSPIKE    = 8;
float TE_LIGHTNING3    	= 9;
float TE_LAVASPLASH    	= 10;
float TE_TELEPORT    	= 11;
float CHAN_AUTO   = 0;
float CHAN_WEAPON = 1;
float CHAN_VOICE  = 2;
float CHAN_ITEM   = 3;
float CHAN_BODY   = 4;
// float CHAN_MUSIC; // See Moon's Walkman channel
float ATTN_NONE	  = 0;
// float ATTN_LOWEST;  // See Moon's Walkman attenuation
float ATTN_NORM   = 1;
float ATTN_IDLE   = 2;
float ATTN_STATIC = 3;
float UPDATE_GENERAL = 0;
float UPDATE_STATIC  = 1;
float UPDATE_BINARY  = 2;
float UPDATE_TEMP    = 3;
float EF_BRIGHTFIELD = 1;
float EF_MUZZLEFLASH = 2;
float EF_BRIGHTLIGHT = 4;
float EF_DIMLIGHT    = 8;
float MSG_BROADCAST = 0;
float MSG_ONE       = 1;
float MSG_ALL       = 2;
float MSG_INIT      = 3;
float movedist;
float gameover;
string string_null;
float empty_float;
entity newmis;
entity activator;
entity damage_attacker;
float framecount;
float skill;
.string wad;
.string map;
.float worldtype;
.string killtarget;
.float light_lev;
.float style;
.void() th_stand;
.void() th_walk;
.void() th_run;
.void() th_missile;
.void() th_melee;
.void(entity attacker, float damage) th_pain;
.void() th_die;
.entity oldenemy;
.float speed;
.float lefty;
.float search_time;
.float attack_state;
float AS_STRAIGHT = 1;
float AS_SLIDING  = 2;
float AS_MELEE    = 3;
float AS_MISSILE  = 4;
.float walkframe;
.float attack_finished;
.float pain_finished;
.float invincible_finished;
.float invisible_finished;
.float super_damage_finished;
.float radsuit_finished;
.float invincible_time;
.float invincible_sound;
.float invisible_time;
.float invisible_sound;
.float super_time;
.float super_sound;
.float rad_time;
.float fly_sound;
.float axhitme;
.float show_hostile;
.float jump_flag;
.float swim_flag;
.float air_finished;
.float bubble_count;
.string deathtype;
.string mdl;
.vector mangle;
.float mangle_x;
.float mangle_y;
.float mangle_z;
.float t_length;
.float t_width;
.vector dest;
.float dest_x;
.float dest_y;
.float dest_z;
.vector dest1;
.float dest1_x;
.float dest1_y;
.float dest1_z;
.vector dest2;
.float dest2_x;
.float dest2_y;
.float dest2_z;
.float wait;
.float delay;
.entity trigger_field;
.string noise4;
.float pausetime;
.entity movetarget;
.float aflag;
.float dmg;
.float cnt;
.void() think1;
.vector finaldest;
.float finaldest_x;
.float finaldest_y;
.float finaldest_z;
.vector finalangle;
.float finalangle_x;
.float finalangle_y;
.float finalangle_z;
.float count;
.float lip;
.float state;
.vector pos1;
.float pos1_x;
.float pos1_y;
.float pos1_z;
.vector pos2;
.float pos2_x;
.float pos2_y;
.float pos2_z;
.float height;
.float waitmin;
.float waitmax;
.float distance;
.float volume;
void (vector ang) makevectors = #1;
void (entity e, vector o) setorigin = #2;
void (entity e, string m) setmodel = #3;
void (entity e, vector min, vector max) setsize = #4;
void () break = #6;
float () random = #7;
void (entity e, float chan, string samp, float vol, float atten) sound = #8;
vector (vector v) normalize = #9;
void (string e) error = #10;
void (string e) objerror = #11;
float (vector v) vlen = #12;
float (vector v) vectoyaw = #13;
entity () spawn = #14;
void (entity e) remove = #15;
void (vector v1, vector v2, float nomonsters, entity forent) traceline = #16;
entity () checkclient = #17;
entity (entity start, .string fld, string match) find = #18;
string (string s) precache_sound = #19;
string (string s) precache_model = #20;
void (entity client, string s) stuffcmd = #21;
entity (vector org, float rad) findradius = #22;
void(string s, ...) bprint = #0:ex_bprint;
void(string s, ...) dprint = #0:ex_bprint; // For some reasons ex_dprint didnt work in KEX
//void(string s, ...) dprint = #0:ex_dprint; // This could be done using IFDEF preprocessor switch
void(entity client, string s, ...) sprint = #0:ex_sprint;
string (float f) ftos = #26;
string (vector v) vtos = #27;
void () coredump = #28;
void () traceon = #29;
void () traceoff = #30;
void (entity e) eprint = #31;
float (float yaw, float dist) walkmove = #32;
float () droptofloor = #34;
void (float style, string value) lightstyle = #35;
float (float v) rint = #36;
float (float v) floor = #37;
float (float v) ceil = #38;
float (entity e) checkbottom = #40;
float (vector v) pointcontents = #41;
float (float f) fabs = #43;
vector (entity e, float speed) aim = #44;
float (string s) cvar = #45;
void (string s) localcmd = #46;
entity (entity e) nextent = #47;
void (vector o, vector d, float color, float count) particle = #48;
void () ChangeYaw = #49;
vector (vector v) vectoangles = #51;
void (float to, float f) WriteByte = #52;
void (float to, float f) WriteChar = #53;
void (float to, float f) WriteShort = #54;
void (float to, float f) WriteLong = #55;
void (float to, float f) WriteCoord = #56;
void (float to, float f) WriteAngle = #57;
void (float to, string s) WriteString = #58;
void (float to, entity s) WriteEntity = #59;
void (float step) movetogoal = #67;
string (string s) precache_file = #68;
void (entity e) makestatic = #69;
void (string s) changelevel = #70;
void (string var, string val) cvar_set = #72;
void (entity client, string s, ...) centerprint = #0:ex_centerprint;	// sprint, but in middle
void (vector pos, string samp, float vol, float atten) ambientsound = #74;
string (string s) precache_model2 = #75;
string (string s) precache_sound2 = #76;
string (string s) precache_file2 = #77;
void (entity e) setspawnparms = #78;

// Plays a sound that only "client" can hear. Useful for announcers...
void localsound( entity client, string sample ) = #0:ex_localsound;

// Debug rendering functions. KEX QuakeC
void draw_point( vector point, float colormap, float lifetime, float depthtest ) = #0:ex_draw_point;
void draw_line( vector start, vector end, float colormap, float lifetime, float depthtest ) = #0:ex_draw_line;
void draw_arrow( vector start, vector end, float colormap, float size, float lifetime, float depthtest ) = #0:ex_draw_arrow;
void draw_ray( vector start, vector direction, float length, float colormap, float size, float lifetime, float depthtest ) = #0:ex_draw_ray;
void draw_circle( vector origin, float radius, float colormap, float lifetime, float depthtest ) = #0:ex_draw_circle;
void draw_bounds( vector min, vector max, float colormap, float lifetime, float depthtest ) = #0:ex_draw_bounds;
void draw_worldtext( string s, vector origin, float size, float lifetime, float depthtest ) = #0:ex_draw_worldtext;
void draw_sphere( vector origin, float radius, float colormap, float lifetime, float depthtest ) = #0:ex_draw_sphere;
void draw_cylinder( vector origin, float halfHeight, float radius, float colormap, float lifetime, float depthtest ) = #0:ex_draw_cylinder;

void(vector tdest, float tspeed, void() func) SUB_CalcMove;
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;
void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void() SUB_CalcMoveDone;
void() SUB_CalcAngleMoveDone;
void() SUB_Null;
void() SUB_UseTargets;
void() SUB_Remove;
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;

float(entity targ, entity inflictor) CanDamage;

void() FuckOff =
{
	bprint(ftos(empty_float)); // supress empty_float unused warning
	bprint("----- hi, litl lamo, try to decompile it, heheh ------"); // kept as a reminder to all envolved
};

vector VEC_WAY_MIN    	= '-24 -24 -24';
vector VEC_WAY_MAX    	= '24 24 32';
vector VEC_HULL3_MIN    = '-24 -24 -24';
vector VEC_HULL3_MAX    = '24 24 64';
float intermission_running;
float intermission_exittime;
.vector movevect;
.float movevect_x;
.float movevect_y;
.float movevect_z;
float KEY_MOVEUP    	= 1;
float KEY_MOVEDOWN    	= 2;
float KEY_MOVELEFT    	= 4;
float KEY_MOVERIGHT    	= 8;
float KEY_MOVEFORWARD   = 16;
float KEY_MOVEBACK    	= 32;
float KEY_LOOKUP    	= 64;
float KEY_LOOKDOWN    	= 128;
float KEY_LOOKLEFT    	= 256;
float KEY_LOOKRIGHT    	= 512;
float GUARD_WALKDIST    = 130;
float AMBIENT_RATE    = 14.03; // unused
float MON_REFRESHTIME = 0.01;
float MON_WALKDIST    = 1;
float MON_REACTIONTIME= 0.2;
float MON_BACKTIME    = 0.5;
float MON_STUCKTIME   = 0.4;
float MON_STUCKDIST   = 5;
float MON_UNIQUECHANCE = 0.04;
float MON_MAGICCHANCE  = 0.03;
float MON_CAMPERCHANCE = 0.1;
float MON_CAMPTIME    = 30;
float CL_DEADTIME    = 1.5;
float MENTAT_TIME    = 90;
float IDLE_TIME = 5;
float IDLE_MAX = 20;
float GRD_DEFENDCHANCE = 0.35;
float GRD_PATROLTIME   = 20;
float GRD_DEFENDTIME   = 40;
float GRD_FIGHTDIST    = 500;
float GRD_SKIN = 1;
.float bot_logic;
.float action;
.float action_time;
void() GenerateAction;
void(entity e) GeneratePatrolTarget;
float LOGIC_FREESTYLE = 0;
float LOGIC_FOLLOW    = 1;
float LOGIC_FINDDEFEND= 3;
float LOGIC_DEFEND    = 4;
float LOGIC_PATROL    = 5;
float LOGIC_HUNTENEMY = 6;
.float guard_chat_incoming;
.float acc;
.float hst;
.float rfr;
.float keys;
.float oldkeys;
.float stre;	// Strength
.float vit;		// Vitality
.float wiz;		// Sanity; recovered in KEK port;
.float intu;	// Intuition; new stat in KEK port; naming kept in line with original
.float melee;
.float mana;
.float max_mana;
.float mosterskilled;
.string mxmnastr; // unused!?
.float next_fndcrt;
.float sc_n1;
.float sc_n2;
.float sc_n3;
.float sc_n4;
.float sc_n5;
.float scroll_heal_eff;
.float sc_heal_lvl;
.float scroll_redu_eff;
.float sc_redu_lvl;
.float scroll_slow_eff;
.float sc_slow_lvl;
.float scroll_brut_eff;
.float sc_brut_lvl;
.float scroll_shie_eff;
.float scroll_infe_eff;
.float scroll_shaf_eff;
.float scroll_mete_eff;
.entity attack_e;
.float scroll_time;
.float mx_speed;
void() execute_changelevel;
void(entity e) moon_generate_magic_prefix;
void(entity e) moon_generate_magic_postfix;
void() MagicItemTouch;
void() M_FireShotgun;
void(vector org) M_FireSuperNail;
void(vector org) M_FireNail;
void() M_FireSuperShotgun;
void() M_FireHomeMissile;
void() M_FireMissile;
void() M_FireShaft;
void() M_FireGrenade;
void(string gibname, float dm) ThrowHead;
.float shaft_time;
.float radius;
.float medic; // WTF IS THAT PROPERTY!?
.float continues;
.entity killer;
.float next_gate;
.float next_heart;
.float cl_nohelp;
.float cl_framtime;
.float frmtm;
.float frmes;
.float damage_bonus;
void() s_explode1;
void(entity who) CheckEdge;
void(entity e) spawn_zombie;
void(entity e) spawn_shambler;
void(entity e) spawn_headless;
void() T_MissileTouch;
float(entity targ, entity inflictor) CanCarefulDamage;
entity() SelectSpawnPoint;
void(vector org) spawn_tfog;
float() crandom;
void() moon_make_chat_noise;
void() bot_run1;
void() BecomeExplosion;
void(string gibname, float dm) ThrowGib;
.entity attacka;
.float green_blood;
.float poison;
.float poisoned;
.float poison_dmg;
.float next_poison;
.float min_attack_dist;
void() game_brain;
.float postenemy_time;
.vector postenemy_org;
.float postenemy_org_x;
.float postenemy_org_y;
.float postenemy_org_z;
.float stuck_time;
.vector stuck_org;
.float stuck_org_x;
.float stuck_org_y;
.float stuck_org_z;
.float rstuck_time;
.vector rstuck_org;
.float rstuck_org_x;
.float rstuck_org_y;
.float rstuck_org_z;
.float black_spike;
.float next_mesg_time;
.entity mesg_inflictor;
.float wear_armor;
.float magic_typeone;
.float magic_typeone_value;
.string magic_prefixone;
.float magic_typetwo;
.float magic_typetwo_value;
.string magic_prefixtwo;
.float wear_ring;
.float ring_typeone;
.float ring_typeone_value;
.string ring_prefixone;
.float ring_typetwo;
.float ring_typetwo_value;
.string ring_prefixtwo;
.float prefix;
.float prefix_value;
.string prefix_one;
.string prefix_two;
.string prefix_three;
.string prefix_four;

.string gatename;
.float framtime;
.float nextyaw;
.float dead_time;
.float mon_logic;
.float camp_time;
.float camp_num;
.float camp_line;
float LOGIC_STANDART = 0;
float LOGIC_CAMPER   = 1;
float LOGIC_HUNTER   = 2;
.float mode;
.entity master;
.float blockd;
void() PlayerDie;
.float backdist;
void(float shotcount, vector dir, vector spread) FireBullets;
.float num;
float() FindWaypoint;
.float cost;
.float free;
.float gold;
.float exp;
.float lvl;
.float nextexp;
.float misspeed;
.float shootframe;
.float ability; // da fack
.float enchanced;
.float prepared;
.float cold_time;
.float console_time;
.float next_strafe_time;
.float next_spam;
.vector spam_vector;
.float spam_vector_x;
.float spam_vector_y;
.float spam_vector_z;
.vector strafe_vector;
.float strafe_vector_x;
.float strafe_vector_y;
.float strafe_vector_z;
.float up_bullet; // Re-use same param for both Upgrade and Extra capacity
.float up_nail; // Re-use same param for both Upgrade and Extra capacity
.float thinkrefresh;
.float nextfind_time;
.float line;
.float wantnum;
.float wantline;
float WF_NORMAL    = 0;
float WF_DEFEND    = 1;
float WF_EXTRASIZE = 2;
.float point;
.float skl_expl;
.float skl_rgn;
.float rgn_time;
.float health_magic_regen_time;
.float rgnm_time;

// // Copied from https://github.com/fte-team/fteqw/blob/1f9f3635f0aef3b2eed6b40e35fcf6223c6ad533/engine/common/protocol.h#L362
//QuakeEx(aka: rerelease) svcs.
//	these are not really documented anywhere. we're trying to stick with protocol 15 (because that's the only documented protocol it supports properly thanks to demos)
//	however we still need some special case svcs
//  (there's also some problematic c2s differences too)
#define svcqex_updateping			46	// [byte] slot, [signed_qe] ping
#define svcqex_updatesocial			47	// [byte] slot, 8 bytes of unknown
#define svcqex_updateplinfo			48	// [byte] slot, [leb128] health, [leb128] armour
#define svcqex_locprint				49	// uses qe's localised string formatting, otherwise treat as svc_print.
#define svcqex_servervars			50	// [leb128] changedvalues, [???] value...
#define svcqex_seq					51	// [leb128] input sequence ack
#define svcqex_achievement			52	// [string] codename
#define svcqex_chat					53	// [byte] svcqex_chat, [byte] playercolour, [byte] textcolour, [string] playername, [string] chattext // new from FTE
#define svcqex_levelcompleted		54
#define svcqex_backtolobby			55
#define svcqex_localsound			56
#define svcqex_prompt				57
#define svcqex_loccenterprint		58	// [string] codename
// //
#define CONST_QEX_COLOR_WHITE 0
#define CONST_QEX_COLOR_GREEN 1
#define CONST_QEX_COLOR_TEAL 2
#define CONST_QEX_COLOR_YELLOW 3

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