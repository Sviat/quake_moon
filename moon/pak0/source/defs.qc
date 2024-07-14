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
void(entity client, string s, ...) sprint = #0:ex_sprint;
void(string s, ...) dprint = #0:ex_dprint;
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

void (entity client, string s, ...) centerprint5 = #0:ex_centerprint;	// sprint, but in middle

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
float(entity e, float healamount, float ignore) T_Heal;
float(entity targ, entity inflictor) CanDamage;

void() FuckOff =
{
	bprint(ftos(empty_float)); // supress empty_float unused warning
	bprint("----- hi, litl lamo, try to decompile it, heheh ------");
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
float MON_WAVETIME_FAST   = 1;
float MON_WAVETIME_NORMAL = 10;
float MON_WAVETIME_SLOW   = 21;
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
float sv_fastmeat;
float sv_alwaysday;
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
.float medic;
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
void(entity e, float enc) spawn_knight;
void(entity e, float enc) spawn_snake;
void(entity e, float enc) spawn_soldier;
void(entity e, float enc) spawn_enforcer;
void(entity e, float enc) spawn_ogre;
void(entity e, float enc) spawn_mage;
void(entity e, float enc) spawn_spider;
void(entity e, float enc) spawn_shalrath;
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
string s_wiz;
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

void() monster_precache =
{
	precache_model2("progs/monster1.mdl");
	precache_model2("progs/laser.mdl");
	precache_model2("progs/laser2.mdl");
	precache_sound2("enforcer/death1.wav");
	precache_sound2("enforcer/enfire.wav");
	precache_sound2("enforcer/enfstop.wav");
	precache_sound2("shalrath/attack.wav");
	precache_sound2("shalrath/attack2.wav");
	precache_sound2("shalrath/death.wav");
	precache_sound2("shambler/melee1.wav");
	precache_sound2("shambler/melee2.wav");
	precache_sound2("shambler/smack.wav");
	precache_sound2("shambler/sattck1.wav");
	precache_sound2("shambler/sboom.wav");
	precache_sound2("shambler/sdeath.wav");
	precache_sound2("zombie/z_hit.wav");
	precache_sound2("zombie/z_miss.wav");
	precache_sound2("zombie/z_shot1.wav");
	precache_sound2("zombie/z_gib.wav");
	precache_sound2("zombie/z_pain.wav");
	precache_sound2("zombie/z_pain1.wav");
	precache_model("progs/aura.mdl");
	precache_model("progs/shard.mdl");
	precache_model("progs/monster0.mdl");
	precache_model("progs/monster2.mdl");
	precache_model("progs/monster3.mdl");
	precache_model("progs/monster4.mdl");
	precache_model("progs/monster5.mdl");
	precache_model("progs/monster7.mdl");
	precache_model("progs/monster8.mdl");
	precache_model("progs/monster9.mdl");
	precache_model("progs/spid_gib.mdl");
	precache_model("progs/h_spider.mdl");
	precache_model("progs/w_spike.mdl");
	precache_model("progs/v_spike.mdl");
	precache_model("progs/h_mage.mdl");
	precache_model("progs/w_ball.mdl");
	precache_model("progs/spine.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/skull.mdl");
	precache_model("progs/h_guard.mdl");
	precache_model("progs/h_ogre.mdl");
	precache_model("progs/grenade.mdl");
	precache_model("progs/h_shal.mdl");
	precache_model("progs/uzi.mdl");
	precache_model("progs/knight.mdl");
	precache_model("progs/h_knight.mdl");
	precache_model("progs/s_light.mdl");
	precache_model("progs/shambler.mdl");
	precache_sound("ogre/ogdth.wav");
	precache_sound("ogre/ogsawatk.wav");
	precache_sound("knight/kdeath.wav");
	precache_sound("knight/khurt.wav");
	precache_sound("knight/ksight.wav");
	precache_sound("knight/sword1.wav");
	precache_sound("knight/sword2.wav");
	precache_sound("knight/idle.wav");
	precache_sound("soldier/death1.wav");
	precache_sound("soldier/sattck1.wav");
	//precache_sound("moon/headless/die1.wav"); // missing file
	precache_sound("moon/monsters/d_spider.wav");
	precache_sound("moon/monsters/f_spider.wav");
	precache_sound("moon/monsters/d_snake.wav");
	precache_sound("moon/monsters/d_mage.wav");
	precache_sound("moon/monsters/d_mage2.wav");
	precache_sound("moon/monsters/f_mage.wav");
};

void() item_precache =
{
	precache_model2("progs/h_mega.mdl");
	precache_model("maps/b_bh100.bsp");
	precache_model("maps/b_bh25.bsp");
	precache_model("maps/b_bh10.bsp");
	precache_model("maps/b_shell0.bsp");
	precache_model("maps/b_nail0.bsp");
	precache_model("maps/b_batt0.bsp");
	precache_model("maps/b_rock0.bsp");
	precache_model("progs/g_shot.mdl");
	precache_model("progs/g_nail.mdl");
	precache_model("progs/g_nail2.mdl");
	precache_model("progs/g_rock.mdl");
	precache_model("progs/g_rock2.mdl");
	precache_model("progs/g_light.mdl");
	precache_model("progs/armor.mdl");
	precache_model("progs/ring.mdl");
	precache_model("progs/drugs.mdl");
	precache_model("progs/potion.mdl");
	precache_model("progs/heart.mdl");
	precache_model("progs/s_spikeb.mdl");
	precache_model("progs/player_s.mdl");
	precache_model("progs/player_n.mdl");
	precache_model("progs/gold.mdl");
	precache_model("progs/h_hellkn.mdl");
	precache_model("progs/h_shams.mdl");
	precache_model("progs/tome.mdl");
	precache_model("progs/derrick.mdl");
	precache_sound("items/r_item1.wav");
	precache_sound("items/r_item2.wav");
	precache_sound("items/health1.wav");
	precache_sound("items/armor1.wav");
	precache_sound("misc/null.wav"); // Null to clear channel
	precache_sound("moon/ambient/quake.wav");
	precache_sound("moon/items/ring.wav");
	precache_sound("moon/items/shard.wav");
	precache_sound("moon/items/drug.wav");
	precache_sound("moon/items/potion.wav");
	precache_sound("moon/items/scroll.wav");
	precache_sound("moon/items/gold.wav");
	precache_sound("moon/items/book.wav");
	precache_sound("moon/misc/levelup.wav");
	precache_sound("moon/misc/alert.wav");
	precache_sound("moon/misc/stone1.wav");
	precache_sound("moon/misc/stone2.wav");
	precache_sound("moon/misc/cast.wav");
};

void() extras_precache =
{
	precache_model("progs/scroll.mdl");
	precache_model("progs/meteors.mdl");
	//precache_sound("moon/magic/m_slow.wav"); // missing
	//precache_sound("moon/magic/m_heal.wav"); // missing
	//precache_sound("moon/magic/m_thun.wav"); // missing
	//precache_sound("moon/talk/stay1.wav"); // missing
	//precache_sound("moon/talk/stay2.wav"); // missing
	//precache_sound("moon/talk/go1.wav"); // missing
	//precache_sound("moon/talk/go2.wav"); // missing
};

void() music_precache =
{
	// // BPM
	precache_sound("music/bpm/01_judgement.wav");
	precache_sound("music/bpm/02_the_rhytm_king.wav");
	precache_sound("music/bpm/03_the_crypt.wav");
	precache_sound("music/bpm/04_corruption.wav");
	precache_sound("music/bpm/05_depths_of_helheim.wav");
	precache_sound("music/bpm/06_huginn_shop.wav");
	precache_sound("music/bpm/07_machinations.wav");
	precache_sound("music/bpm/08_into_asgard.wav");
	precache_sound("music/bpm/09_paradox.wav");
	precache_sound("music/bpm/10_fight_of_the_valkyrie.wav");
	precache_sound("music/bpm/11_muninn_arrmoury.wav");
	precache_sound("music/bpm/12_yggdrasil_roots.wav");
};

void() moon_precache =
{
	item_precache();
	monster_precache();
	extras_precache();
	music_precache();
};

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
.float mentat_bonus;
.float mentat_bonus2;
.float mentat_bonus3;
.float mode;
.entity master;
.float blockd;
void() PlayerDie;
.float backdist;
void(float shotcount, vector dir, vector spread) FireBullets;
.float num;
float() FindWaypoint;
void(entity who) DropGold;
float() MaxLvl;
.float cost;
.float free;
.float gold;
.float exp;
.float lvl;
.float nextexp;
.float misspeed;
.float shootframe;
.float ability;
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
float up_alert; // Re-use same param for both Upgrade and Extra health
float up_gold_value;
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
float waypoints_ok;
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
#define const_qex_color_white 0
#define const_qex_color_green 1
#define const_qex_color_teal 2
#define const_qex_color_yellow 3

#define CONST_QC_DISPLAY_MAX 999

#define const_qc_sprint_a "\a"		// Black cell
#define const_qc_sprint_f "\f"		// ?!?
#define CONST_QC_GLYPH_SELECTION "\r"		// Red triangle
#define const_qc_sprint_v "\v"		// White cell

#define const_qc_sprint_b_open "\b"	// Red text
#define const_qc_sprint_b_close "\b"
#define const_qc_sprint_s_open "\s"	// Also red text, but why two different codes?
#define const_qc_sprint_s_close "\s"

#define MOON_GLYPH_WHITECELL "\x0B"		// White cell
#define MOON_GLYPH_SELECTION "\x0D"		// Red triangle
#define MOON_GLYPH_BRACKET_OPEN "\x10"	// Red [, also x90
#define MOON_GLYPH_BRACKET_CLOSE "\x11"	// Red ], also x91
#define MOON_GLYPH_CENTERDOT_WHITE "\x1C" // White center dot
#define MOON_GLYPH_ARROW "\x7F"			// Arrow pointing left
#define MOON_GLYPH_BLACKSQUARE "\x88"	// Black square
#define MOON_GLYPH_REDSQUARE "\x8B"		// Red square
#define MOON_GLYPH_CENTERDOT_YELLOW "\x8E" // Yellow center dot
#define MOON_GLYPH_REDARROW "\xFF"		// Red arrow pointing left

// // Impulse codes. First 19 keep for original Q1; limit is 255; so we should line up somewhere in between
float MOON_IMPULSE_CODE_NOOP = 0;
float MOON_IMPULSE_CODE_FIRST = 32;
// Code range CLI UI 32..95
float MOON_IMPULSE_CODE_FIRST_CLI_UI = 32;
float MOON_IMPULSE_CODE_PRINT_STAT = 40;
float MOON_IMPULSE_CODE_UPSKILL_VITALITY = 41;
float MOON_IMPULSE_CODE_UPSKILL_STRENGTH = 42;
float MOON_IMPULSE_CODE_UPSKILL_SANITY = 43;
float MOON_IMPULSE_CODE_UPSKILL_INTUITION = 44;
float MOON_IMPULSE_CODE_PRINT_CLI_HELP = 50;
float MOON_IMPULSE_CODE_PRINT_INVENTORY = 60;
float MOON_IMPULSE_CODE_PRINT_STATUS = 70;
float MOON_IMPULSE_CODE_LAST_CLI_UI = 95;
// Code range SERVER settings 96..127
float MOON_IMPULSE_CODE_FIRST_SETTING_SERVER = 96;
float MOON_IMPULSE_CODE_ALWAYSDAY = 101;
float MOON_IMPULSE_CODE_FASTMEAT = 102;
float MOON_IMPULSE_CODE_SLOWMEAT = 103;
float MOON_IMPULSE_CODE_CHEAT_QUAD = 127;
float MOON_IMPULSE_CODE_LAST_SETTING_SERVER = 127;
// Code range CLIENT settings 128..159
float MOON_IMPULSE_CODE_FIRST_SETTING_CLIENT = 128;
float MOON_IMPULSE_CODE_NOHELP = 150;
float MOON_IMPULSE_CODE_SHOWFPS = 151;
float MOON_IMPULSE_CODE_LAST_SETTING_CLIENT = 159;
// Code range TRACE CROSSHAIR 160..223
float MOON_IMPULSE_CODE_FIRST_TRACE = 160;
float MOON_IMPULSE_CODE_ITEM_PICKUP = 192;
float MOON_IMPULSE_CODE_ITEM_BUY = 194;
float MOON_IMPULSE_CODE_ITEM_IDENTIFY = 196;
float MOON_IMPULSE_CODE_LAST_TRACE = 223;
//
float MOON_IMPULSE_CODE_LAST = 234;
// //

float MOON_WALKMAN_CHANNEL = 6;
float MOON_WALKMAN_VOLUME_MUSIC = 0.32;
float MOON_WALKMAN_VOLUME_SHOP = 1;
float MOON_WALKMAN_ATTEN_MUSIC = 0.42;
float MOON_WALKMAN_ATTEN_SHOP = 1.0;
float MOON_WALKMAN_DELAY_BETWEENTRACKS = 3; // in seconds

float MOON_PLAYER_MAX_LEVEL = 50;
float MOON_HEART_MAX_LEVEL = 50;
float MOON_EXP_FIRST_LEVEL = 40;
float MOON_NEXTLEVEL_MORE_PLAYERLEVEL_TIMES = 40;
float MOON_NEXTLEVEL_MORE_SCALING_FACTOR = 1.35;

float MOON_ARMOR_MAX_SOFT = 255;
float MOON_ARMOR_SHARD_GAIN = 5;
float MOON_ARMOR_SHARD_TYPE = 0.3;

string MOON_PLAYER_CLASSNAME = "player";
float MOON_PLAYER_LEVEL_GROW_FAST 	= 35;
float MOON_PLAYER_POINT_GROW_FAST 	= 5;
float MOON_PLAYER_LEVEL_GROW_NORMAL = 40;
float MOON_PLAYER_POINT_GROW_NORMAL = 4;
float MOON_PLAYER_LEVEL_GROW_SLOW 	= 50; // unnecessary, just for consistency
float MOON_PLAYER_POINT_GROW_SLOW 	= 3;

string MOON_STAT_STRENGTH_NAME = "strength";	// Firearms power
string MOON_STAT_VITALITY_NAME = "vitality";	// Physical health
string MOON_STAT_SANITY_NAME = "sanity";		// Magic health
string MOON_STAT_INTUITION_NAME = "intuition";	// Magic power

float MOON_STAT_HEALTH_PER_VITALITY = 2;
float MOON_STAT_DAMAGE_PER_STRENGTH = 1.5;
float MOON_STAT_MANA_PER_SANITY 	= 1; 	// Not finished
float MOON_STAT_POWER_PER_INTUITION	= 0.5; 	// Not finished
float MOON_STAT_MAXHEALTH_MIN = 1;
float MOON_STAT_MAXMANA_MIN = 0;

string MOON_GATE_CLASSNAME = "gate";
string MOON_HEART_CLASSNAME = "heart";
float MOON_HEART_HEALTH_INIT = 200;
float MOON_HEART_HEALTH_GROW = 10;
float MOON_HEART_HEALTH_REGEN_VALUE = 1;
float MOON_HEART_HEALTH_REGEN_COOLDOWN = 1;

string MOON_GUARD_CLASSNAME = "guard";
float MOON_GUARD_HEALTH_INIT = 100;
float MOON_GUARD_HEALTH_GROW = 25;
float MOON_GUARD_HEALTH_REGEN_VALUE = 1; // unused
float MOON_GUARD_HEALTH_REGEN_COOLDOWN = 1; // unused

float MOON_CREEP_GOLD_PREFIX_CODE = 5;

float MOON_GOLD_MINE_DETECT_PLAYER_RADIUS = 800; // was 250
float MOON_GOLD_MINE_DETECT_GUARD_RADIUS  = 400; // added in KEK port
float MOON_GOLD_MINE_DELAY_MIN = 12;
float MOON_GOLD_MINE_DELAY_RANDOM = 12;
float MOON_GOLD_MINE_BASE = 2;
float MOON_GOLD_MINE_LVLPERCENT = 2.5;
float MOON_GOLD_MINE_RANDOM = 10;

float MOON_GOLD_LOOT_BASE = 1;
float MOON_GOLD_LOOT_LVLPERCENT = 5;
float MOON_GOLD_LOOT_RANDOM = 60;

float MOON_ITEM_NONE = 0;
float MOON_ITEM_SOME = 1;

string MOON_MARKET_ITEM_CLASSNAME = "goody_ent";

float MOON_ITEM_LVLTHRESHOLD_LOW    = 10;
float MOON_ITEM_LVLTHRESHOLD_NORMAL = 20;
float MOON_ITEM_LVLTHRESHOLD_HIGH   = 40;
float MOON_ITEM_LVLTHRESHOLD_POTION_LOWER = 4;
float MOON_ITEM_LVLTHRESHOLD_POTION_UPPER = 8;

float MOON_ITEM_TRAIT_MAX_EFFECT  = 8;
float MOON_ITEM_TRAIT_MAX_PREFIX  = 27;
float MOON_ITEM_TRAIT_MAX_POSTFIX = 17;

float MOON_ITEM_TRAIT_LOWERBOUND_LOW	= 1;
float MOON_ITEM_TRAIT_LOWERBOUND_HIGH	= 2;
float MOON_ITEM_TRAIT_LOWERBOUND_EPIC	= 4;
float MOON_ITEM_TRAIT_UPPERBOUND_PREFIX_LOW 	= 8;
float MOON_ITEM_TRAIT_UPPERBOUND_PREFIX_NORMAL 	= 16;
float MOON_ITEM_TRAIT_UPPERBOUND_PREFIX_HIGH 	= 21;
float MOON_ITEM_TRAIT_UPPERBOUND_PREFIX_EPIC 	= 27;
float MOON_ITEM_TRAIT_UPPERBOUND_POSTFIX_LOW 	= 7;
float MOON_ITEM_TRAIT_UPPERBOUND_POSTFIX_NORMAL = 13;
float MOON_ITEM_TRAIT_UPPERBOUND_POSTFIX_HIGH 	= 16;
float MOON_ITEM_TRAIT_UPPERBOUND_POSTFIX_EPIC 	= 17;

float MOON_ITEM_MAGIC_CHANCE_PREFIX = 0.3;
float MOON_ITEM_MAGIC_CHANCE_POSTFIX = 0.6; // if above this - both

float MOON_ITEM_ARMOR_VS_RING_CHANCE = 0.5;

// MOON_ITEM_POTION -> MOON_POTION
string MOON_ITEM_POTION_SMALL_NETNAME = "small healing potion";
float MOON_ITEM_POTION_SMALL_BASE		= 15;
float MOON_ITEM_POTION_SMALL_RANDOM 	= 35;
string MOON_ITEM_POTION_NORMAL_NETNAME = "healing potion";
float MOON_ITEM_POTION_NORMAL_BASE 		= 35;
float MOON_ITEM_POTION_NORMAL_RANDOM 	= 65;
string MOON_ITEM_POTION_BIG_NETNAME = "big healing potion";
float MOON_ITEM_POTION_BIG_BASE 		= 65;
float MOON_ITEM_POTION_BIG_RANDOM 		= 100;

// MOON_ITEM_ELIXIR -> MOON_ELIXIR
string MOON_ELIXIR_CLASSNAME = "elixir";	// Unused? goody_ent?
string MOON_ELIXIR_MARKET_NETNAME = "goody_elixir";
float MOON_ELIXIR_STR_CODE = 1;
float MOON_ELIXIR_STR_VALUE 	= 1;
string MOON_ELIXIR_STR_NETNAME 	= "elixir of STRANGE (+1 to Strength)";
string MOON_ELIXIR_STR_NAME 	= "elixir of STRANGE (+1 to Strength)";
float MOON_ELIXIR_VIT_CODE = 2;
float MOON_ELIXIR_VIT_VALUE 	= 1;
string MOON_ELIXIR_VIT_NETNAME 	= "elixir of VITALIKI (+1 to Vitality)";
string MOON_ELIXIR_VIT_NAME 	= "elixir of VITALIKI (+1 to Vitality)";
float MOON_ELIXIR_MAG_CODE = 3;		// Not finished
float MOON_ELIXIR_MAG_VALUE 	= 1;
string MOON_ELIXIR_MAG_NETNAME 	= "elixir of MAGGI (+1 to Sanity)";
string MOON_ELIXIR_MAG_NAME 	= "elixir of MAGGI (+1 to Sanity)";
float MOON_ELIXIR_INT_CODE = 4;		// Not finished
float MOON_ELIXIR_INT_VALUE 	= 1;
string MOON_ELIXIR_INT_NETNAME 	= "elixir of INTEL (+1 to Intuition)";
string MOON_ELIXIR_INT_NAME 	= "elixir of INTEL (+1 to Intuition)";

// MOON_ITEM_MENTAT -> MOON_MENTAT
string MOON_MENTAT_CLASSNAME = "mentat";
float MOON_MENTAT_OFFENSE_CODE = 1;
float MOON_MENTAT_OFFENSE_VALUE = 20;
string MOON_MENTAT_OFFENSE_NETNAME = "offensive drug";
string MOON_MENTAT_OFFENSE_NAME = "offensive drug";

float MOON_MENTAT_DEFENSE_CODE = 2;
float MOON_MENTAT_DEFENSE_VALUE = 20;
string MOON_MENTAT_DEFENSE_NETNAME = "defensive drug";
string MOON_MENTAT_DEFENSE_NAME = "defensive drug";

float MOON_MENTAT_SPEED_CODE = 3;
float MOON_MENTAT_SPEED_VALUE_MIN  = 25;
float MOON_MENTAT_SPEED_VALUE_NORM = 30;
float MOON_MENTAT_SPEED_VALUE_MAX  = 35;
string MOON_MENTAT_SPEED_NETNAME = "accelerative drug";
string MOON_MENTAT_SPEED_NAME = "accelerative drug";

string MOON_ITEM_TRADED_CLASSNAME = "goody_ent";
string MOON_ITEM_MAGIC_CLASSNAME = "magicitem";
string MOON_ITEM_ARMOR_NETNAME = "armor";
string MOON_ITEM_ARMOR_DISPLAY = "armor";

string MOON_ITEM_RING_NETNAME = "ring";
string MOON_ITEM_RING_DISPLAY = "ring";

// MOON_ITEM_AMMO -> MOON_AMMO
float MOON_AMMO_MAX_SHELL 	= 100;	// Initial max, before any upgrades
float MOON_AMMO_MAX_NAIL 	= 200;	// Initial max, before any upgrades
float MOON_AMMO_MAX_ROCKET 	= 100;
float MOON_AMMO_MAX_CELL 	= 100;

// // list of Magical Effects, _CODE's should be in strict increasing order without gaps
float MOON_ITEM_HEALTH_CODE = 1;
string MOON_ITEM_HEALTH_EFFECT  	= "+{} to maximum health";
string MOON_ITEM_HEALTH_PREFIX_LOW   	= "Echidna ";
string MOON_ITEM_HEALTH_PREFIX_NORMAL  	= "Echidna ";
string MOON_ITEM_HEALTH_PREFIX_HIGH  	= "Echidna ";
string MOON_ITEM_HEALTH_PREFIX_EPIC  	= "Echidna ";
string MOON_ITEM_HEALTH_POSTFIX  		= " of Life";
float MOON_ITEM_HEALTH_BONUS     	= 7;//fixme
float MOON_ITEM_HEALTH_BONUS_RANDOM = 10;
float MOON_ITEM_HEALTH_BONUS_LOW 		= 5;
float MOON_ITEM_HEALTH_BONUS_NORMAL		= 5;
float MOON_ITEM_HEALTH_BONUS_HIGH		= 5;
float MOON_ITEM_HEALTH_BONUS_EPIC		= 5;

float MOON_ITEM_RESIST_CODE = 2;
string MOON_ITEM_RESIST_EFFECT  	= "reduce damage received by {}%";
string MOON_ITEM_RESIST_PREFIX_LOW   	= "Halo ";
string MOON_ITEM_RESIST_PREFIX_NORMAL  	= "Halo ";
string MOON_ITEM_RESIST_PREFIX_HIGH   	= "Halo ";
string MOON_ITEM_RESIST_PREFIX_EPIC   	= "Halo ";
string MOON_ITEM_RESIST_POSTFIX  		= " of Resistance";
float MOON_ITEM_RESIST_BONUS     	= 9;
float MOON_ITEM_RESIST_BONUS_RANDOM = 9;
float MOON_ITEM_RESIST_BONUS_LOW 		= 1;
float MOON_ITEM_RESIST_BONUS_NORMAL		= 5;
float MOON_ITEM_RESIST_BONUS_HIGH		= 5;
float MOON_ITEM_RESIST_BONUS_EPIC		= 5;

float MOON_ITEM_GOLD_CODE = 3;
string MOON_ITEM_GOLD_EFFECT	 	= "{}% extra gold from monsters";
string MOON_ITEM_GOLD_PREFIX_LOW   		= "Lunacy ";
string MOON_ITEM_GOLD_PREFIX_NORMAL  	= "Lunacy ";
string MOON_ITEM_GOLD_PREFIX_HIGH   	= "Lunacy ";
string MOON_ITEM_GOLD_PREFIX_EPIC   	= "Lunacy ";
string MOON_ITEM_GOLD_POSTFIX  			= " of Greed";
float MOON_ITEM_GOLD_BONUS_MIN 		= 40;
float MOON_ITEM_GOLD_BONUS_MAX 		= 60;//fixme
float MOON_ITEM_GOLD_BONUS_RANDOM = 20;
float MOON_ITEM_GOLD_BONUS_LOW 			= 20;
float MOON_ITEM_GOLD_BONUS_NORMAL		= 5;
float MOON_ITEM_GOLD_BONUS_HIGH			= 5;
float MOON_ITEM_GOLD_BONUS_EPIC			= 5;

float MOON_ITEM_DAMAGE_CODE = 4;
string MOON_ITEM_DAMAGE_EFFECT 		= "{}% damage amplify";
string MOON_ITEM_DAMAGE_PREFIX_LOW   	= "Brutal ";
string MOON_ITEM_DAMAGE_PREFIX_NORMAL  	= "Brutal ";
string MOON_ITEM_DAMAGE_PREFIX_HIGH   	= "Brutal ";
string MOON_ITEM_DAMAGE_PREFIX_EPIC   	= "Brutal ";
string MOON_ITEM_DAMAGE_POSTFIX  		= "FIXME";
float MOON_ITEM_DAMAGE_BONUS_RANDOM = 20;
float MOON_ITEM_DAMAGE_BONUS_LOW 		= 5;
float MOON_ITEM_DAMAGE_BONUS_NORMAL		= 5;
float MOON_ITEM_DAMAGE_BONUS_HIGH		= 5;
float MOON_ITEM_DAMAGE_BONUS_EPIC		= 5;

float MOON_ITEM_RETALATE_CODE = 5;
string MOON_ITEM_RETALATE_EFFECT 	= "attacker takes {}% of damage caused";

float MOON_ITEM_VAMPIR_CODE = 6;
string MOON_ITEM_VAMPIR_EFFECT 		= "{}% your damage converts to life";

float MOON_ITEM_REGEN_CODE = 7;
string MOON_ITEM_REGEN_EFFECT  		= "replenish {} health every second";

float MOON_ITEM_CONSUME_CODE = 8;
string MOON_ITEM_CONSUME_EFFECT		= "adds {} health after each kill";
// // last Effect's _CODE should not be greater than MOON_ITEM_TRAIT_MAX_EFFECT

// // list of Upgrades
// These things cannot and should be attached to Items, hence new Code sequence
float MOON_ITEM_GATEALERT_CODE = 1;
string MOON_ITEM_GATEALERT_EFFECT  		= "Book of \sRed\s Alert (gate gives a signal when killed)\n";
string MOON_ITEM_GATEALERT_SIDEEFFECT 	= "Book of \sRed\s Gate (+10 max health to Gate)\n";
float MOON_ITEM_GATEALERT_SIDEEFFECT_BONUS = 10;
float MOON_ITEM_SHELLUP_CODE = 2;
string MOON_ITEM_SHELLUP_EFFECT 		= "Book of Shell Shock (your shell attack now stronger and more concentrated)\n";
string MOON_ITEM_SHELLUP_SIDEEFFECT 	= "Book of PowerShell (+10 max shell capacity)\n";
float MOON_ITEM_SHELLUP_SIDEEFFECT_BONUS= 10;
float MOON_ITEM_NAILUP_CODE = 3;
string MOON_ITEM_NAILUP_EFFECT 			= "Book of Nail Polish (your nails attack now faster)\n";
string MOON_ITEM_NAILUP_SIDEEFFECT 		= "9 Inch Book of Nails (+20 max nail capacity)\n";
float MOON_ITEM_NAILUP_SIDEEFFECT_BONUS = 20;
float MOON_ITEM_STATUP_CODE = 4;
float MOON_ITEM_STATUP_BONUS 			= 5;
string MOON_ITEM_STATUP_EFFECT 			= "Book of High Five (you get \5 stats points)\n";
float MOON_ITEM_GUARDIAN_CODE = 5;
string MOON_ITEM_GUARDIAN_EFFECT 		= "Book of Blind Guardian (guardian joins your army)\n";
float MOON_ITEM_GLOBALGOLD_CODE = 6;
float MOON_ITEM_GLOBALGOLD_BONUS_FLAT 	= 5;
float MOON_ITEM_GLOBALGOLD_BONUS_LVLPERCENT = 0.5;
float MOON_ITEM_GLOBALGOLD_BONUS_RANDOM = 7;
string MOON_ITEM_GLOBALGOLD_EFFECT 		= "Book of Treasures (global gold income increase by {}%)\n";
float MOON_ITEM_HEART_CODE = 7;
float MOON_ITEM_HEART_BONUS_FLAT 		= 5;
float MOON_ITEM_HEART_BONUS_LVLPERCENT 	= 0.25;
float MOON_ITEM_HEART_BONUS_RANDOM 		= 5;
string MOON_ITEM_HEART_EFFECT 			= "Book of Immortality (\sHeart\s life increased by {})\n";
// // end of list of Upgrades

// // Monster related consts
float MOON_MONSTER_CODE_SOLDIER 	= 1;
float MOON_MONSTER_CODE_ENFORCER 	= 2;
float MOON_MONSTER_CODE_SPIDER 		= 3;
float MOON_MONSTER_CODE_OGRE 		= 4;
float MOON_MONSTER_CODE_SNAKE 		= 5;
float MOON_MONSTER_CODE_MAGE 		= 6;
float MOON_MONSTER_CODE_SHALRATH 	= 7;
float MOON_MONSTER_BASELEVEL_SOLDIER 	= 0;
float MOON_MONSTER_BASELEVEL_ENFORCER 	= 1;
float MOON_MONSTER_BASELEVEL_SPIDER 	= 2;
float MOON_MONSTER_BASELEVEL_OGRE 		= 4;
float MOON_MONSTER_BASELEVEL_SNAKE 		= 6;
float MOON_MONSTER_BASELEVEL_MAGE 		= 8;
float MOON_MONSTER_BASELEVEL_SHALRATH 	= 15;

// // end of Monster related consts

float(float min, float max) random_int = // result in [min, max] range. N.B! including both sides
{
	return rint( (random() * (max - min)) + min );
};

float(float value, float max) clamp =
{
	if (value <= max) { return value; }
	return max;
};

float(float min, float value, float max) clampd =
{
	if (value < min) { return min; }
	if (value > max) { return max; }
	return value;
};

void() flash_self =
{
	stuffcmd(self, "bf\n");
};

void(entity target) flash_other =
{
	stuffcmd(other, "bf\n");
};

void(entity target) flash_target =
{
	stuffcmd(target, "bf\n");
};

string(float f) floor_ftos =
{
	return ftos(floor(f));
};

string(float f) quick_ftos =
{
	return ftos(f);
};

void(string s) sprint_self =
{
	sprint(self, s);
};

void(string s) sprint_other =
{
	sprint(other, s);
};

void(entity target, string s) sprintln =
{
	sprint(target, s);
	sprint(target, "\n");
};

void(string s) sprintln_self =
{
	sprint(self, s);
	sprint(self, "\n");
};

void(string s) sprintln_other =
{
	sprint(other, s);
	sprint(other, "\n");
};

void(entity who, float f) sprint_ftos = // TODO: slowly get rid of it
{
	local string str;

	str = ftos(floor(f));
	sprint(who, str);
};

void(float f) bprint_ftos =
{
	local string str;
	str = ftos(floor(f));
	bprint(str);
};

void(string f) ip = // TODO: slowly get rid of it
{
	sprint(self, f);
};

float(float n1, float n2) percent =
{
	local float a;

	a = rint(((n1 * n2) / 100));
	return (a);
};

float() MaxLvl =
{
	local entity e;
	local float maxlvl;

	maxlvl = 0;
	e = find(world, classname, MOON_PLAYER_CLASSNAME);
	while (e)
	{
		if ((e.lvl > maxlvl))
		{
			maxlvl = e.lvl;
		}
		e = find(e, classname, MOON_PLAYER_CLASSNAME);
	}
	return maxlvl;
};

float() moon_get_spawn_delay =
{
	if ( sv_fastmeat == 1 )
	{
		dprint("fastmeat, delay: {}-{}\n", quick_ftos(MON_WAVETIME_FAST), quick_ftos(2*MON_WAVETIME_FAST));
		return ( MON_WAVETIME_FAST + (random() * MON_WAVETIME_FAST));
	}

	if ( sv_fastmeat == -1 )
	{
		dprint("slowmeat, delay: {}-{}\n", quick_ftos(MON_WAVETIME_SLOW), quick_ftos(2*MON_WAVETIME_SLOW));
		return ( MON_WAVETIME_SLOW + (random() * MON_WAVETIME_SLOW));
	}

	dprint("justmeat, delay: {}-{}\n", quick_ftos(MON_WAVETIME_NORMAL), quick_ftos(2*MON_WAVETIME_NORMAL));
	return ( MON_WAVETIME_NORMAL + (random() * MON_WAVETIME_NORMAL));
};

void(entity e) AddToQue =
{
	local entity z;

	z = spawn();
	z.origin = e.origin;
	z.angles = e.angles;
	setmodel(z, e.model);
	z.frame = e.frame;
	z.colormap = e.colormap;
	z.flags = e.flags;
	z.movetype = MOVETYPE_TOSS;
	z.solid = SOLID_NOT;
	z.velocity = e.velocity;
	z.think = SUB_Remove;
	z.nextthink = time + moon_get_spawn_delay();
};