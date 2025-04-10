#include <sourcemod>
#include <sdktools>

public Plugin myinfo = {	
	name = "Force to Spectator",
	description = "Use !forcespec to move all players to Spectator team",
	author = "bauxite",
	version = "0.1.0",
	url = "https://discord.gg/afhZuFB9A5",
};

public OnPluginStart()
{
	RegAdminCmd("sm_forcespec", Command_Force, ADMFLAG_GENERIC);	
}

public Action Command_Force(int client, int args)
{
	for(int i = 1; i <= MaxClients; i++)
	{	
		ForceSpec(i);
	}

	return Plugin_Handled;
}

void ForceSpec(int i)
{
	if(IsClientInGame(i) && !IsClientSourceTV(i))
	{	
		FakeClientCommand(i, "kill"); 
		FakeClientCommand(i, "jointeam 1");
	}
}
