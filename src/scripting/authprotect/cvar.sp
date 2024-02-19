//  cvar.sp - Handle ConVars

//  The authentication timeout, in seconds.
//  Users will have x seconds to authenticate before being kicked.
ConVar g_AuthenticationTimeout;

//  Whether or not to block runcommands
//  This prevents the user from taking most movement and gameplay actions.
ConVar g_BlockRunCommands;

//  Block voice chat for unauthenticated players
ConVar g_BlockVoiceChat;

//  Message shown to unauthenticated players
ConVar g_UnauthMessage;

void CreateConVars()
{
    g_AuthenticationTimeout = 
        CreateConVar(
            "sm_authentication_timeout", 
            "9.0", 
            "The amount of time a user has to authenticate with steam before being kicked");

    g_BlockRunCommands = 
        CreateConVar(
            "sm_unauth_block_runcmd", 
            "1", 
            "Block UserCommands when a user is not authenticated");

    g_BlockVoiceChat =
         CreateConVar(
            "sm_unauth_block_voice", 
            "1", 
            "Mute unauthenticated users, and unmute them once they authenticate.");   

    //  Should this be a translation?
    g_UnauthMessage =
        CreateConVar(
            "sm_unauth_message",
            "[SM] You are not authenticated with steam!",
            "The message to display to unauthenticated players"
        );

}