#include <sourcemod>

public Plugin myinfo =
{
	name = "NT Team join locker",
	description = "Use !lock to toggle being able to change teams",
	author = "bauxite",
	version = "1.0",
	url = "https://discord.gg/afhZuFB9A5",
}

bool LockState;

public void OnPluginStart()
{
	AddCommandListener(Command_JoinTeam, "jointeam");	
	RegAdminCmd("sm_lock", Command_ToggleLock, ADMFLAG_KICK);	
}

public void OnMapStart()
{
	LockState = false;
}

public Action Command_ToggleLock(int iClient, int iArgs)
{
	LockState =! LockState;
	PrintToChatAll("ADMIN: %N has %s team join.", iClient, LockState ? "disabled" : "enabled");
	return Plugin_Handled;
}

public Action Command_JoinTeam(int iClient, const char[] sName, int iArgs)
{
	switch (LockState)
	{
		case true:
		{
			PrintToChat(iClient, "Team join is disabled.");
			return Plugin_Stop;
		}
		case false:
		{
			return Plugin_Continue;
		}
	}

	return Plugin_Continue;
}
