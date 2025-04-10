#include <sourcemod>

public Plugin myinfo =
{
	name        = "NT Empty Map Changer",
	author      = "Rain, bauxite",
	description = "Changes to nextmap when server is empty to prevent issues",
	version     = "0.1.1",
};

public void OnPluginStart()
{
	CreateTimer(2341.0, Timer_RotateMapIfEmptyServer, _, TIMER_REPEAT);
}

public Action Timer_RotateMapIfEmptyServer(Handle timer, any data)
{
	int Count = GetClientCount(true);
	
	if (Count <= 1)
	{
		char nextmap[PLATFORM_MAX_PATH];
		if (!GetNextMap(nextmap, sizeof(nextmap)))
		{
		ThrowError("Failed to get next map");
		}
		ForceChangeLevel(nextmap, "Rotate map due to empty server.");
	}
	return Plugin_Continue;
}
