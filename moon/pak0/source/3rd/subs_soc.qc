// https://github.com/hemebond/quake-arcane-dimensions-qc/blob/master/subs_soc.qc#L362C1-L364C41

//======================================================================
// Updates totals on the HUD (checks for client to exist)
// - Specify which total to update using constant
// - Uses MSG_ONE because it is more reliable across many clients
// - Other client updates (SVC_KILLEDMONSTER, SVC_FOUNDSECRET)
//
//----------------------------------------------------------------------
float HUD_SECRETS = 1;
float HUD_MONSTERS = 2;
void(float hud_item) update_hud_totals =
{
	// Has the client player been setup yet?
	if (client_ent && client_ent.flags & FL_CLIENT) {

		// Update total secrets
		if (hud_item & HUD_SECRETS) {
			msg_entity = client_ent;
			WriteByte (MSG_ONE, SVC_UPDATESTAT);
			WriteByte (MSG_ONE, STAT_TOTALSECRETS);
			WriteLong (MSG_ONE, total_secrets);
		}
		// Update total monsters
		if (hud_item & HUD_MONSTERS) {
			msg_entity = client_ent;
			WriteByte (MSG_ONE, SVC_UPDATESTAT);
			WriteByte (MSG_ONE, STAT_TOTALMONSTERS);
			WriteLong (MSG_ONE, total_monsters);
		}
	}
};