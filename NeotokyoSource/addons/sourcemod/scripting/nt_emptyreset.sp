#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

ConVar g_EmptyMap;

public Plugin myinfo = {
    name = "Empty Server Map Changer",
    author = "2cwldys",
    description = "Changes to desired map when the server is empty",
    version = "1.0"
};

public void OnPluginStart()
{
	g_EmptyMap = CreateConVar("sm_nt_empty_map", "nt_transit_ctg", "Map to change to when the server is empty", FCVAR_NOTIFY);
}

public void OnClientDisconnect(int client)
{
    CreateTimer(1.0, CheckForEmptyServer);
}

public Action CheckForEmptyServer(Handle timer)
{
    int playerCount = 0;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i))
        {
            playerCount++;
        }
    }

    if (playerCount == 0)
    {
        char mapName[64];
        g_EmptyMap.GetString(mapName, sizeof(mapName));

        PrintToServer("[EmptyMapChanger] No players detected. Changing map to %s...", mapName);
        ForceChangeLevel(mapName, "Server empty - returning to default map.");
        return Plugin_Stop;
    }

    return Plugin_Continue;
}