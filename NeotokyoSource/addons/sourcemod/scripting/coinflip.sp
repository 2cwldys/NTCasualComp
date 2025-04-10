#include <sourcemod>

bool bFlipCooldown;

public Plugin myinfo = {
	name = "Flip a Coin",
	description = "Use !coin to flip a coin",
	author = "bauxite",
	version = "0.1.5",
	url = "https://github.com/bauxiteDYS/SM-CoinFlip",
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_coin", Cmd_Coin);
}

public void OnMapStart()
{
	bFlipCooldown = false;
}

public Action Cmd_Coin(int client, int args)
{
	if (client == 0)
	{
		return Plugin_Stop;
	}
	
	if (!IsClientInGame(client))
	{
		return Plugin_Stop;
	}
	
	if (bFlipCooldown)
	{
		ReplyToCommand(client, "Flip is on cooldown, wait 15s");
		return Plugin_Stop;
	}
	
	int iCoin;
	int iNumFlips;
	
	iNumFlips = GetRandomInt(1, 10);
	
	for (int iFlip = 1; iFlip <= iNumFlips; iFlip++)
	{
		iCoin = GetRandomInt(1, 2);
	}
	
	if (iCoin == 1)
	{ 
		PrintToChatAll("Coin Flip Result: Heads");
		PrintToConsoleAll("Coin Flip Result: Heads");
	}
	else
	{
		PrintToChatAll("Coin Flip Result: Tails");
		PrintToConsoleAll("Coin Flip Result: Tails");
	}
	
	bFlipCooldown = true;
	CreateTimer(15.0, ResetCoinCooldown, _, TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Handled;
}

public Action ResetCoinCooldown(Handle timer)
{
	bFlipCooldown = false;
	
	return Plugin_Stop;
}
