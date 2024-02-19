//  commands.sp - Command hooks

static char g_BlockedCommands[][] = {

    //  Prevent the player from attempting to votekick
    "callvote",

    "sm_chat",
    "sm_say",
    "say",
    "say_team"
};

void CreateBlockedCommands()
{
    for(int i = 0; i < sizeof(g_BlockedCommands); i++)
    {
        AddCommandListener(OnBlockableCommand, g_BlockedCommands[i]);
    }
}


//  Hooks client chat messages
public Action OnClientSayCommand(int client, const char[] command, const char[] args)
{
    if (!IsAuthenticated(client))
    {
        PrintFailAuthToChat(client);
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

//  Generic callback to block a command if the player isn't authenticated
//  Note this only stops sourcemod from handling the command.
//  Other sources will need to be stopped on their own.
public Action OnBlockableCommand(int client, const char[] command, int argc)
{
    if (client != 0 && !IsAuthenticated(client))
    {
        //  PrintToServer("Blocking command %s from %N", command, client);
        return Plugin_Stop;
    }

    return Plugin_Continue;
}