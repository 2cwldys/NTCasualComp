#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#include <neotokyo>

#define PLUGIN_VERSION "0.1.0"

public Plugin myinfo = {
	name = "NEOTOKYO OnRoundConcluded Event",
	description = "Provides the OnRoundConcluded global forward for plugin developers.",
	author = "Rain",
	version = PLUGIN_VERSION,
	url = "https://github.com/Rainyan/sourcemod-nt-onroundconcluded-event"
};

Handle _fwd;

int _prev_state;
int _prev_jin_score, _prev_nsf_score;

public void OnPluginStart()
{
	CreateConVar("sm_onroundconcluded_version", PLUGIN_VERSION,
		"NEOTOKYO OnRoundConcluded Event version", FCVAR_DONTRECORD);

	_fwd = CreateGlobalForward("OnRoundConcluded", ET_Ignore, Param_Cell);

	HookEvent("game_round_start", OnRoundStart);
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	_prev_jin_score = GetTeamScore(TEAM_JINRAI);
	_prev_nsf_score = GetTeamScore(TEAM_NSF);
}

public void OnGameFrame()
{
	int state = GameRules_GetProp("m_iGameState");

	if (state == GAMESTATE_ROUND_OVER && _prev_state == GAMESTATE_ROUND_ACTIVE)
	{
		Call_StartForward(_fwd);

		int jin_score = GetTeamScore(TEAM_JINRAI);
		int nsf_score = GetTeamScore(TEAM_NSF);

		int winner = -1;
		if (jin_score > _prev_jin_score && nsf_score == _prev_nsf_score)
		{
			winner = TEAM_JINRAI;
		}
		else if (nsf_score > _prev_nsf_score && jin_score == _prev_jin_score)
		{
			winner = TEAM_NSF;
		}
		else if (jin_score == _prev_jin_score && nsf_score == _prev_nsf_score)
		{
			winner = TEAM_NONE;
		}

		if (winner == -1)
		{
			LogError("Indeterminate winner");
			Call_Cancel();
		}
		else
		{
			Call_PushCell(winner);
			Call_Finish();
		}
	}

	_prev_state = state;
}
