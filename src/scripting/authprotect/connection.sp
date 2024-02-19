//  connection.sp - OnConnect handlers

//  Invoked upon first connection
//  Register a callback to boot 'em if they take too long to verify
public void OnClientPutInServer(int client)
{
    if (!IsFakeClient(client) && !IsAuthenticated(client))
    {
        //  Kick the client if they don't authenticate soon.
        CreateTimer(g_AuthenticationTimeout.FloatValue, OnClientConnectLate, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
    }
}

public void OnClientAuthorized(int client, const char[] auth)
{
    //  Tell the mute system to unmute them early.
    //  Unsure if OnClientSpeaking() would be messed with by individual mods.
    UnmutePlayer(client);
}

//  This callback is invoked after g_AuthenticationTimeout seconds.
//  If the user isn't authed by now, boot 'em.
static Action OnClientConnectLate(Handle timer, any context)
{
    int userid = view_as<int>(context);
    int client = GetClientOfUserId(userid);

    if (IsClientConnected(client) && !IsAuthenticated(client))
    {
        KickClientEx(client,
            "AUTH_FAIL\n" 
        ... "Steam did not authorize your session in time\n"
        ... "This is usually caused by steam being down\n"
        ... "\n"
        ... "You are not banned, and you are free to re-join.\n"
        ... "\n"
        ... "[This server is protected by AuthProtect]");
    }

    return Plugin_Stop;
}

//  Block the player from moving or taking any action if they are not authenticated
//  This is a bit of an extreme case but would prevent griefing.
//  Todo: make this a convar
public Action OnPlayerRunCmd(
    int client, int& buttons, int& impulse, float vel[3], float angles[3], 
    int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    if (!g_BlockRunCommands.BoolValue)
        return Plugin_Continue;

    if (!IsAuthenticated(client))
    {
        //  Block the player from moving if not authenticated
        buttons = 0;
        impulse = 0;
        vel[0] = 0.0;
        vel[1] = 0.0;
        vel[2] = 0.0;

        //  TODO: Does this do anything that the chat handler doesn't?
        //  SetEntPropFloat(client, Prop_Data, "m_fLastPlayerTalkTime", GetGameTime() + 2);

        PrintFailAuthToChat(client);

        return Plugin_Changed;
    }

    return Plugin_Continue;
}