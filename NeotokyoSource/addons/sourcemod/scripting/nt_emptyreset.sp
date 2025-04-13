#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define EMPTY_MAP "nt_transit_ctg"

public Plugin myinfo = {
    name = "Empty Server Map Changer",
    author = "2cwldys",
    description = "Changes map to EMPTY_MAP when server is empty",
    version = "1.0"
};

public void OnPluginStart()
{
	//placeholding
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
        PrintToServer("[EmptyMapChanger] No players detected. Changing map to %s...", EMPTY_MAP);
        ForceChangeLevel(EMPTY_MAP, "Server empty - returning to default map.");
        return Plugin_Stop;
    }

    return Plugin_Continue;
}