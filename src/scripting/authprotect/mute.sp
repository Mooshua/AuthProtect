//  mute.sp - OnClientSpeaking hooks

//  True if the player was muted because they were unauthenticated
static bool g_IsUnauthMuted[MAXPLAYERS + 1];

void RemoveClientMuteState(int client)
{
    g_IsUnauthMuted[client] = false;
}

//  If a player is speaking while unauthenticated, mute them.
//  If they are authenticated but were previously muted by authprotect,
//  handle unmuting them through basecomm or natively.
public void OnClientSpeaking(int client)
{
    //  Muting disabled?
    if (!g_BlockVoiceChat.BoolValue)
        return;

    if (!IsAuthenticated(client))
    {
        SetClientListeningFlags(client, VOICE_MUTED);
        PrintFailAuthToChat(client);

        g_IsUnauthMuted[client] = true;

        return;
    }

    if (g_IsUnauthMuted[client])
    {
        UnmutePlayer(client);
    }
}

//  Unmutes a player previously muted by the authproc mute system
//  @param int client: the client to unmute
void UnmutePlayer(int client)
{
    //  Muting disabled?
    if (!g_BlockVoiceChat.BoolValue)
        return;

    if (!g_IsUnauthMuted[client])
        return;

    g_IsUnauthMuted[client] = false;

    if (g_HasBaseComm)
    {
        //  Do not override basecomm mutes
        if (IsPlayerBasecommMuted(client))
            return;
    }


    //  Default unmute
    SetClientListeningFlags(client, VOICE_NORMAL);
}

static bool IsPlayerBasecommMuted(int client)
{
    if (BaseComm_IsClientMuted(client))
    {
        return true;
    }

    //  TODO: Any other checks here?
    return false;
}