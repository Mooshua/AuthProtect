
#include <sourcemod>
#include <halflife>
#include <console>
#include <clients>

#include <sdkhooks>
#include <sdktools_hooks>
#include <sdktools_voice>
#include <sdktools_tempents>

#include <multicolors>

#undef REQUIRE_PLUGIN
#include <basecomm>
#define REQUIRE_PLUGIN

#define DEBUG_ALWAYS_UNAUTHED false

bool g_HasBaseComm;

#include "authprotect/cvar.sp"
#include "authprotect/stocks.sp"
#include "authprotect/mute.sp"
#include "authprotect/connection.sp"
#include "authprotect/commands.sp"


public Plugin myinfo =
{
    name = "AuthProtect",
    author = "Mooshua <mooshua.net>",
    description = "Blocks players from taking many actions while not authenticated with steam",
    version = "1.1.0",
    url = "https://github.com/Mooshua/AuthProtect"
};


public void OnPluginStart()
{
    PrintToServer("[AuthProtect] Loading");
    AutoExecConfig(true, "authprotect");

    //  Set spray hook
    AddTempEntHook("Player Decal", OnClientSpray);
    
    CreateConVars();
    CreateBlockedCommands()

    g_HasBaseComm = LibraryExists("basecomm");
    PrintDependencyStatus("basecomm.smx", g_HasBaseComm);

    PrintToServer("[AuthProtect] Initialized");
}

//  Thanks to SprayTracer from Nican for figuring this out!
//  Hooks the player decal spawning and prevents it from spawning if the player isn't authenticated yet.
public Action OnClientSpray(const char[] name, const int[] players, int num_players, float delay)
{
    int client = TE_ReadNum("m_nPlayer");

    if (!IsAuthenticated(client))
    {
        PrintFailAuthToChat(client);
        PrintToChat(client, "[SM] Spraying is not allowed until steam has authorized your account.");

        return Plugin_Stop;
    }

    return Plugin_Continue;
}