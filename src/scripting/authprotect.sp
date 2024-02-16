
#include <sourcemod>
#include <halflife>
#include <console>
#include <clients>

#include <sdkhooks>
#include <sdktools_hooks>
#include <sdktools_voice>
#include <sdktools_tempents>

#define FAIL_AUTH_MSG "[SM] You are not authenticated with steam!"
#define DEBUG_ALWAYS_UNAUTHED false

public Plugin myinfo =
{
    name = "AuthProtect",
    author = "Mooshua <mooshua.net>",
    description = "Blocks players from taking many actions while not authenticated with steam",
    version = "1.0.0",
    url = "https://github.com/Mooshua/AuthProtect"
};


float g_PlayerLastNotified[MAXPLAYERS + 1];

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

void TimedReminder(int client)
{
    if ((GetGameTime() - g_PlayerLastNotified[client]) >= 3)
    {
        g_PlayerLastNotified[client] = GetGameTime();
        PrintToChat(client, FAIL_AUTH_MSG);
    }
}

public void OnPluginStart()
{
    PrintToServer("[AuthProtect] Loading");

    //  Set spray hook
    AddTempEntHook("Player Decal", OnClientSpray);
    
    //  If we need to block specific commands, add them here:
    //  AddCommandListener(OnBlockableCommand, "command_here");

	HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);

    PrintToServer("[AuthProtect] We're super-de-duper!");
}

public void OnClientPutInServer(int client)
{

    g_PlayerLastNotified[client] = 0.0;
}

//  [EVENT HANDLER]
//  This modifies the kick reason to explain why the user is kicked,
//  and also let dorks know that they can't do that auth exploit on this server B)
public Action OnPlayerDisconnect(Handle event, char[] name, bool dontBroadcast)
{
    static bool no_recursion = false;

    if (no_recursion)
        return Plugin_Stop;

    //  silly little gooses doing their silly little dances
    no_recursion = true;
    {
        int client = GetClientOfUserId(GetEventInt(event, "userid"));
        char disconnect_reason[48];

        GetEventString(event, "reason", disconnect_reason, sizeof(disconnect_reason));


        if (StrEqual(disconnect_reason, "Client authorization failed"))
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
    }
    no_recursion = false;

    return Plugin_Continue;
}

//  Thanks to SprayTracer from Nican for figuring this out!
//  Hooks the player decal spawning and prevents it from spawning if the player isn't authenticated yet.
public Action OnClientSpray(const char[] name, const int[] players, int num_players, float delay)
{
    int client = TE_ReadNum("m_nPlayer");

    if (!IsAuthenticated(client))
    {
        TimedReminder(client);
        PrintToChat(client, "[SM] Spraying is not allowed until steam has authorized your account.");

        return Plugin_Stop;
    }

    return Plugin_Continue;
}

//  If a player is speaking while unauthenticated, mute them.
//  Note: This is baaaaaaad. We are essentially relying on Basecomm existing
//  to unmute them upon authentication.
public void OnClientSpeaking(int client)
{
    if (!IsAuthenticated(client))
    {
        SetClientListeningFlags(client, VOICE_MUTED);

        TimedReminder(client);
    }
}

//  Hooks client chat messages
public Action OnClientSayCommand(int client, const char[] command, const char[] args)
{
    if (!IsAuthenticated(client))
    {
        TimedReminder(client);
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
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

//  Block the player from moving or taking any action if they are not authenticated
//  This is a bit of an extreme case but would prevent griefing.
//  Todo: make this a convar
public Action OnPlayerRunCmd(
    int client, int& buttons, int& impulse, float vel[3], float angles[3], 
    int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    if (!IsAuthenticated(client))
    {
        //  Block the player from moving if not authenticated
        buttons = 0;
        vel[0] = 0.0;
        vel[1] = 0.0;
        vel[2] = 0.0;

        //  TODO: Does this do anything that the chat handler doesn't?
        //  SetEntPropFloat(client, Prop_Data, "m_fLastPlayerTalkTime", GetGameTime() + 2);

        TimedReminder(client);
    }

    return Plugin_Changed;
}