#pragma semicolon 1

#include <sourcemod>
#include <neotokyo>
#include <clientprefs>

static bool wants_text[32+1];

Handle KillerCookie;

char class_name[][] = {
	"Unknown",
	"Recon",
	"Assault",
	"Support"
};

public Plugin myinfo = 
{
	name		= "NT Killer Info Display, streamlined for NT and with chat relay",
	author		= "Berni, gH0sTy, Smurfy1982, Snake60, bauxite",
	description	= "Displays the name, weapon, health and class of player that killed you and relays info to chat",
	version		= "0.1.9",
	url		= "http://forums.alliedmods.net/showthread.php?p=670361",
};

public void OnPluginStart()
{	
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	
	KillerCookie = RegClientCookie("killer_info_text", "killer info text preference", CookieAccess_Public);
	
	SetCookieMenuItem(KillerTextMenu, KillerCookie, "killer info text");
}

public void KillerTextMenu(int client, CookieMenuAction action, any info, char[] buffer, int maxlen)
{
	if (action == CookieMenuAction_SelectOption) 
	{
		KillerCustomMenu(client);
	}
}

public Action KillerCustomMenu(int client)
{
	Menu menu = new Menu(KillerCustomMenu_Handler, MENU_ACTIONS_DEFAULT);
	menu.AddItem("on", "Enable");
	menu.AddItem("off", "Disable");
	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int KillerCustomMenu_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End) 
	{
		delete menu;
	}
	else if (action == MenuAction_Select) 
	{
		int client = param1;
		int selection = param2;

		char option[10];
		menu.GetItem(selection, option, sizeof(option));

		if (StrEqual(option, "on")) 
		{ 
			SetClientCookie(client, KillerCookie, "1");
			wants_text[client] = true;
		} 
		else 
		{
			SetClientCookie(client, KillerCookie, "0");
			wants_text[client] = false;
		}
	}
	
	return 0;
}

public void OnClientCookiesCached(int client)
{
	int i_wants_text;
	char buf_wants_text[2];
	GetClientCookie(client, KillerCookie, buf_wants_text, 2);
	i_wants_text = StringToInt(buf_wants_text);
	
	if(i_wants_text == 1)
	{
		wants_text[client] = true;
	}
	else
	{
		wants_text[client] = false;
	}
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (client == 0 || attacker == 0 || client == attacker) 
	{
		return Plugin_Continue;
	}

	char weapon[32];
	
	float distance;

	int healthLeft = GetClientHealth(attacker);

	GetEventString(event, "weapon", weapon, sizeof(weapon));		
	
	float clientVec[3];
	float attackerVec[3];
	GetClientAbsOrigin(client, clientVec);
	GetClientAbsOrigin(attacker, attackerVec);
	
	distance = GetVectorDistance(clientVec, attackerVec);
	
	distance = distance * 0.01905;
	
	// Print To Panel
	
	Handle panel= CreatePanel();
	char buffer[64];
	Format(buffer, sizeof(buffer), "%N killed you", attacker);
	SetPanelTitle(panel, buffer);
	DrawPanelItem(panel, "", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
		
	Format(buffer, sizeof(buffer), "Weapon:   %s", weapon);
	DrawPanelItem(panel, buffer, ITEMDRAW_DEFAULT);
	
	Format(buffer, sizeof(buffer), "Health:      %d HP", healthLeft);
	DrawPanelItem(panel, buffer, ITEMDRAW_DEFAULT);
	
	Format(buffer, sizeof(buffer), "Class:        %s", class_name[GetPlayerClass(attacker)]);
	DrawPanelItem(panel, buffer, ITEMDRAW_DEFAULT);
		
	Format(buffer, sizeof(buffer), "Distance:  %.1f Meters", distance);
	DrawPanelItem(panel, buffer, ITEMDRAW_DEFAULT);
		
	DrawPanelItem(panel, "", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);

	SetPanelCurrentKey(panel, 10);
	SendPanelToClient(panel, client, Handler_DoNothing, 20);
	CloseHandle(panel);

	if (wants_text[client] == true)
	{
		ClientCommand(client, "say_team %d %s %s", healthLeft, class_name[GetPlayerClass(attacker)], weapon);
	}
	
	return Plugin_Continue;
}

public Handler_DoNothing(Menu menu, MenuAction action, int param1, int param2) {}
