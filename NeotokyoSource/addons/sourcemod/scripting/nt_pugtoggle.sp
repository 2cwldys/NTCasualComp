#pragma semicolon 1
#include <sourcemod>

public Plugin myinfo = {
    name = "Warmode Toggle",
    author = "YourName",
    description = "Toggles between sm_warmode_on.cfg and sm_warmode_off.cfg using !pug",
    version = "1.0",
    url = ""
};

ConVar g_hCvarWarmode;

public void OnPluginStart()
{
    g_hCvarWarmode = CreateConVar("sm_warmode", "0", "Toggle warmode between on and off", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    RegAdminCmd("sm_pug", Cmd_ToggleWarmode, ADMFLAG_GENERIC, "Toggles warmode on/off");
}

public Action Cmd_ToggleWarmode(int client, int args)
{
    if (!client || !IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    int warmode = g_hCvarWarmode.IntValue;
    if (warmode == 0)
    {
        g_hCvarWarmode.SetInt(1);
        ServerCommand("exec sm_warmode_on.cfg");
        PrintToChatAll("[PUGMode] Enabled!");
    }
    else
    {
        g_hCvarWarmode.SetInt(0);
        ServerCommand("exec sm_warmode_off.cfg");
        PrintToChatAll("[PUGMode] Disabled!");
    }

    return Plugin_Handled;
}