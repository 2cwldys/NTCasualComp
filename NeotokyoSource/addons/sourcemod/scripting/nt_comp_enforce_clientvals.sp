#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.2.0"

char g_sPluginTag[] = "[COMP CVARS]";

public Plugin myinfo = {
    name        = "NT Enforce Comp Values",
    author      = "Rain",
    description = "Enforce some client cvar values for competitive play.",
    version     = PLUGIN_VERSION,
    url         = "https://github.com/Rainyan/sourcemod-nt-comp-enforce-clientvals"
};

// Names of the cvars, followed by the value that is enforced for them.
char g_enforcedVals[][][] = {
    { "r_shadowrendertotexture", "1" },  // Player cvar to monitor, followed by the value it must hold.
};

public void OnPluginStart()
{
    CreateTimer(1.0, Timer_CheckEnforcedVals, _, TIMER_REPEAT);
}

public Action Timer_CheckEnforcedVals(Handle timer)
{
    for (int client = 1; client <= MaxClients; ++client)
    {
        if (!IsClientInGame(client) || IsFakeClient(client))
        {
            continue;
        }

        for (int i = 0; i < sizeof(g_enforcedVals); ++i)
        {
            if (QueryClientConVar(client, g_enforcedVals[i][0], OnCvarQueryFinished, i) == QUERYCOOKIE_FAILED)
            {
                // Only log once, so we don't spam the error log
                static bool have_logged_error = false;
                if (!have_logged_error)
                {
                    LogError("QueryClientConVar %s for client %d (%N) failed", g_enforcedVals[i][0], client, client);
                    have_logged_error = true;
                }
            }
        }
    }

    return Plugin_Continue;
}

public void OnCvarQueryFinished(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, int enforcedCvarIndex)
{
    if (result != ConVarQuery_Okay)
    {
        return;
    }

    if (!StrEqual(cvarValue, g_enforcedVals[enforcedCvarIndex][1], false))
    {
        ClientCommand(client, "%s %s", g_enforcedVals[enforcedCvarIndex][0], g_enforcedVals[enforcedCvarIndex][1]);
        PrintToChat(client, "%s Your cvar %s has been enforced to value: %s", g_sPluginTag, g_enforcedVals[enforcedCvarIndex][0], g_enforcedVals[enforcedCvarIndex][1]);

        PrintToConsoleAll(
            "%s Restored cvar \"%s\" for player \"%N\": from value \"%s\" to \"%s\"",
            g_sPluginTag,
            g_enforcedVals[enforcedCvarIndex][0],
            client,
            cvarValue,
            g_enforcedVals[enforcedCvarIndex][1]
        );

// Probably unwarranted, since we can force the value change to client
#if(0)
        KickClient(
            client,
            "%s Please reset your cvar %s value (\"%s\") to its default value: %s",
            g_sPluginTag,
            cvarName,
            cvarValue,
            g_enforcedVals[enforcedCvarIndex][1]
        );
#endif
    }
}

// Backported from SourceMod/SourcePawn SDK for SM < 1.9 compatibility.
// Used here under GPLv3 license: https://www.sourcemod.net/license.php
// SourceMod (C)2004-2008 AlliedModders LLC.  All rights reserved.
#if SOURCEMOD_V_MAJOR <= 1 && SOURCEMOD_V_MINOR < 9
/**
 * Sends a message to every client's console.
 *
 * @param format        Formatting rules.
 * @param ...           Variable number of format parameters.
 */
stock void PrintToConsoleAll(const char[] format, any ...)
{
    char buffer[254];

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            SetGlobalTransTarget(i);
            VFormat(buffer, sizeof(buffer), format, 2);
            PrintToConsole(i, "%s", buffer);
        }
    }
}
#endif