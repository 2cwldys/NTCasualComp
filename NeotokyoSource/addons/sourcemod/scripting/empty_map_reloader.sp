#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

bool g_firstStart;


public Plugin myinfo = {
	name = "Empty server map reloader",
	author = "bauxite, rain",
	description = "Reloads current map when server is empty to prevent issues",
	version = "0.2.1",
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_firstStart = !late;
	return APLRes_Success;
}

public void OnMapStart()
{
	if(g_firstStart)
	{
		g_firstStart = false;
		CreateTimer(3.0, Timer_ReloadMap, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{	
		CreateTimer(2341.0, Timer_ReloadMapIfEmptyServer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_ReloadMap(Handle timer, any data)
{
	ReloadLevel();
	return Plugin_Stop;
}

public Action Timer_ReloadMapIfEmptyServer(Handle timer, any data)
{
	int playerCount = GetClientCount(true);
	
	if (playerCount <= 1)
	{
		ReloadLevel();
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

void ReloadLevel()
{
	char mapName[64];
	GetCurrentMap(mapName, sizeof(mapName));

	ForceChangeLevel(mapName, "Empty server");
}
