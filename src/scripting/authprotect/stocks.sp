

//  Determine if the player is authenticated
//  @param int client: The client number
bool IsAuthenticated(int client)
{
    //  Debug handler
    if (DEBUG_ALWAYS_UNAUTHED)
        return false;

    //  This should be the big lad here
    if (!IsClientAuthorized(client))
        return false;

    char steam_id[32];

    //  If fetching auth string fails,
    //  then consider us not authenticated
    if (!GetClientAuthId(client, AuthId_SteamID64, steam_id, sizeof(steam_id)))
        return false;

    return true;
}

//  Print a "You are not authenticated" message to a player
//  @param int client: The client to print to
void PrintFailAuthToChat(int client)
{
    static float g_PlayerLastNotified[MAXPLAYERS + 1];

    if ((GetEngineTime() - g_PlayerLastNotified[client]) >= 3)
    {
        g_PlayerLastNotified[client] = GetEngineTime();

        //  Get the message shown to unauthenticated players
        //  TODO: maybe make this a global?
        char message[512];
        g_UnauthMessage.GetString(message, sizeof(message));

        CPrintToChat(client, " {red} %s ", message);
    }
}

void PrintDependencyStatus(const char[] dependency, bool status)
{
    PrintToServer("[AuthProtect] Dependency %15s %s", dependency, status ? ".. enabled" : "!! not found");

}