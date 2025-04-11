#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <timers>

public Plugin myinfo = {
    name = "Pugmode Toggle",
    author = "2cwldys",
    description = "Toggles between modified sm_warmode_on.cfg and sm_warmode_off.cfg for competitive play.",
    version = "1.3",
    url = ""
};

ConVar g_hCvarWarmode;
ConVar g_hCvarPrivatePug;
//new g_iCountdown = 5;
//new Handle:g_hTimer = INVALID_HANDLE;
static char g_soundCD[] = "buttons/button17.wav";
static char g_soundPUB[] = "ntcomp/server_public.mp3";
static char g_soundPRI[] = "ntcomp/server_private.mp3";
static char g_soundCOMPE[] = "ntcomp/comp_play_enabled.mp3";
static char g_soundCOMPD[] = "ntcomp/comp_play_disabled.mp3";

public void OnPluginStart()
{
    g_hCvarWarmode = CreateConVar("sm_nt_pugmode", "0", "Toggle warmode between on and off", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_hCvarPrivatePug = CreateConVar("sm_nt_privatepug", "0", "Locks the pug with a password", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    RegAdminCmd("sm_pug", Cmd_ToggleWarmode, ADMFLAG_GENERIC, "Toggles warmode on/off");
    RegAdminCmd("sm_privatepug", Cmd_TogglePrivatePug, ADMFLAG_GENERIC, "Toggles private pug mode.");

    AddFileToDownloadsTable("sound/ntcomp/server_private.mp3");
    AddFileToDownloadsTable("sound/ntcomp/server_public.mp3");
    AddFileToDownloadsTable("sound/ntcomp/comp_play_enabled.mp3");
    AddFileToDownloadsTable("sound/ntcomp/comp_play_disabled.mp3");

    PrecacheSound("ntcomp/server_private.mp3");
    PrecacheSound("ntcomp/server_public.mp3");
    PrecacheSound("ntcomp/comp_play_enabled.mp3");
    PrecacheSound("ntcomp/comp_play_disabled.mp3");
}

void CountDownBeep()
{
    float volume = 0.5;	// Volume between 0.0 - 1.0 (original volume is 1.0)
    int pitch = 175;	// Pitch between 0 - 255 (original pitch is 100)
    EmitSoundToAll(g_soundCD, _, _, _, _, volume, pitch);
}

void ServerPublicSnd()
{
    float volume = 0.5;	// Volume between 0.0 - 1.0 (original volume is 1.0)
    int pitch = 100;	// Pitch between 0 - 255 (original pitch is 100)
    EmitSoundToAll(g_soundPUB, _, _, _, _, volume, pitch);
}

void ServerPrivateSnd()
{
    float volume = 0.5;	// Volume between 0.0 - 1.0 (original volume is 1.0)
    int pitch = 100;	// Pitch between 0 - 255 (original pitch is 100)
    EmitSoundToAll(g_soundPRI, _, _, _, _, volume, pitch);
}

void ServerCompetitiveEnableSnd()
{
    float volume = 0.5;	// Volume between 0.0 - 1.0 (original volume is 1.0)
    int pitch = 100;	// Pitch between 0 - 255 (original pitch is 100)
    EmitSoundToAll(g_soundCOMPE, _, _, _, _, volume, pitch);
}

void ServerCompetitiveDisableSnd()
{
    float volume = 0.5;	// Volume between 0.0 - 1.0 (original volume is 1.0)
    int pitch = 100;	// Pitch between 0 - 255 (original pitch is 100)
    EmitSoundToAll(g_soundCOMPD, _, _, _, _, volume, pitch);
}

public Action Cmd_ToggleWarmode(int client, int args)
{
    if (!client || !IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    int warmode = g_hCvarWarmode.IntValue;
    int privatePug = g_hCvarPrivatePug.IntValue;

    if (warmode == 0)
    {
        g_hCvarWarmode.SetInt(1);
        ServerCommand("exec sm_warmode_on.cfg");
        PrintToChatAll("[PUGMode] Enabled!");
        CountDownBeep();
        if (privatePug == 0)
        {
            ServerCompetitiveEnableSnd();
        }
        if (privatePug == 1)
        {
            ServerCommand("sv_password casualpug");
            ServerPrivateSnd();
            PrintToChatAll("[PUGMode] !! Session locked with password (casualpug) !!");
        }
    }
    else
    {
        g_hCvarWarmode.SetInt(0);
        ServerCommand("exec sm_warmode_off.cfg");
        PrintToChatAll("[PUGMode] Disabled!");
        CountDownBeep();
        //StartCountdown();

        if (privatePug == 0)
        {
            ServerCompetitiveDisableSnd()
        }
        if (privatePug == 1)
        {
            ServerPublicSnd();
        }

        char currentMap[64];
        GetCurrentMap(currentMap, sizeof(currentMap));
        ServerCommand("changelevel %s", currentMap);  // Restart the map
    }

    return Plugin_Handled;
}

public Action Cmd_TogglePrivatePug(int client, int args)
{
    if (!client || !IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    int privatePug = g_hCvarPrivatePug.IntValue;

    if (privatePug == 0)
    {
        g_hCvarPrivatePug.SetInt(1);
        PrintToChatAll("[PUGMode] Private Pugs are now enforced...");
        CountDownBeep();
    }
    else
    {
        g_hCvarPrivatePug.SetInt(0);
        PrintToChatAll("[PUGMode] Private Pugs are no longer enforced...");
        CountDownBeep();
    }

    return Plugin_Handled;
}

/* public Action Timer_Countdown(Handle timer)
{
    if (timer != g_hTimer)  // **Ensure this is the correct timer instance**
    {
        return Plugin_Stop;
    }

    if (g_iCountdown > 0)
    {
        PrintToChatAll("[PUGMode] Restarting map for public play in %d...", g_iCountdown);
        CountDownBeep();
    }
    else
    {
        RestartMap();
        
        // **Fix: Now g_hTimer is being checked and invalidated**
        if (g_hTimer != INVALID_HANDLE)
        {
            KillTimer(g_hTimer);
            g_hTimer = INVALID_HANDLE;
        }

        return Plugin_Stop;
    }

    g_iCountdown--;
    return Plugin_Continue;
} */

/* public void StartCountdown()
{
    if (g_hTimer != INVALID_HANDLE)
    {
        KillTimer(g_hTimer);
        g_hTimer = INVALID_HANDLE;  // Reset handle
    }

    g_iCountdown = 5; // Reset countdown
    g_hTimer = CreateTimer(1.0, Timer_Countdown, _, TIMER_REPEAT);  // Assign timer handle

    if (g_hTimer == INVALID_HANDLE)
    {
        PrintToChatAll("Failed to create timer!");
    }
} */

/* public void RestartMap()
{
    PrintToChatAll("[PUGMode] Restarting map...");
    CountDownBeep();
    char currentMap[64];
    GetCurrentMap(currentMap, sizeof(currentMap));
    ServerCommand("changelevel %s", currentMap);  // Restart the map
} */