#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <executes>

#pragma semicolon 1
#pragma newdecls required

Handle cvar_red = null;
Handle cvar_green = null;
Handle cvar_blue = null;
Handle cvar_fadein = null;
Handle cvar_fadeout = null;
Handle cvar_xcord = null;
Handle cvar_ycord = null;
Handle cvar_holdtime = null;

int red;
int green;
int blue;
float fadein;
float fadeout;
float holdtime;
float xcord;
float ycord;

public Plugin myinfo =
{
	name = "[Executes] Bombsite HUD",
	author = "B3none",
	description = "Bombsite HUD for executes.",
	version = "1.0.0",
	url = "https://github.com/b3none/executes-hud"
};

public void OnPluginStart()
{
	cvar_red = CreateConVar("sm_redhud", "255");
	cvar_green = CreateConVar("sm_greenhud", "255");
	cvar_blue = CreateConVar("sm_bluehud", "255");
	cvar_fadein = CreateConVar("sm_fadein", "0.5");
	cvar_fadeout = CreateConVar("sm_fadeout", "0.5");
	cvar_holdtime = CreateConVar("sm_holdtime", "5.0");
	cvar_xcord = CreateConVar("sm_xcord", "0.42");
	cvar_ycord = CreateConVar("sm_ycord", "0.3");
	
	AutoExecConfig(true, "executeshud");
	HookEvent("round_start", Event_OnRoundStart);
}

public void OnConfigsExecuted()
{
	red = GetConVarInt(cvar_red);
	green = GetConVarInt(cvar_green);
	blue = GetConVarInt(cvar_blue);
	fadein = GetConVarFloat(cvar_fadein);
	fadeout = GetConVarFloat(cvar_fadeout);
	holdtime = GetConVarFloat(cvar_holdtime);
	xcord = GetConVarFloat(cvar_xcord);
	ycord = GetConVarFloat(cvar_ycord);
}

public void Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsWarmup())
	{
		CreateTimer(1.0, displayHud);
	}
}

public Action displayHud(Handle timer)
{
	Bombsite bombsite = Executes_GetCurrrentBombsite();
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
		{
			continue;
		}
		
		int clientTeam = GetClientTeam(i);
		
		SetHudTextParams(xcord, ycord, holdtime, red, green, blue, 255, 0, 0.25, fadein, fadeout);
		
		ShowHudText(i, 5, "%s Bombsite: %s", clientTeam == CS_TEAM_CT ? "Defend" : "Execute", (bombsite == BombsiteA) ? "A" : "B");
	}
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client);
}

bool IsWarmup()
{
	return GameRules_GetProp("m_bWarmupPeriod") == 1;
}
