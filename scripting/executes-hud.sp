#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <executes>

#pragma semicolon 1
#pragma newdecls required

#define MESSAGE_PREFIX "[\04Executes\x01]"
#define STYLE_HUD "1"
#define STYLE_HINT "2"
#define STYLE_CHAT "3"

Handle cvar_plugin_enabled = null;
Handle cvar_style = null;

Handle cvar_red = null;
Handle cvar_green = null;
Handle cvar_blue = null;
Handle cvar_fadein = null;
Handle cvar_fadeout = null;
Handle cvar_xcord = null;
Handle cvar_ycord = null;
Handle cvar_holdtime = null;

bool pluginEnabled;
char style[8];

int red;
int green;
int blue;
float fadein;
float fadeout;
float holdtime;
float xcord;
float ycord;

Bombsite bombsite;

public Plugin myinfo = {
	name = "[Executes] Bombsite HUD",
	author = "B3none",
	description = "Displays the current execute in a HUD message.",
	version = "2.0.0",
	url = "https://github.com/b3none/executes-hud"
};

public void OnPluginStart() {
	cvar_plugin_enabled = CreateConVar("sm_executes_hud_enabled", "1", "Should we display the HUD?", _, true, 0.0, true, 1.0);
	cvar_style = CreateConVar("sm_executes_hud_style", "1", "1: HUD, 2: Hint Text, 3: Chat | You can also use multiple by doing 123", _, true, 0.0, true, 123.0);
	
	cvar_red = CreateConVar("sm_executes_hud_red", "255", "How much red would you like?", _, true, 0.0, true, 255.0);
	cvar_green = CreateConVar("sm_executes_hud_green", "255", "How much green would you like?", _, true, 0.0, true, 255.0);
	cvar_blue = CreateConVar("sm_executes_hud_blue", "255", "How much blue would you like?", _, true, 0.0, true, 255.0);
	cvar_fadein = CreateConVar("sm_executes_hud_fade_in", "0.5", "How long would you like the fade in animation to last in seconds?", _, true, 0.0);
	cvar_fadeout = CreateConVar("sm_executes_hud_fade_out", "0.5", "How long would you like the fade out animation to last in seconds?", _, true, 0.0);
	cvar_holdtime = CreateConVar("sm_executes_hud_time", "5.0", "Time in seconds to display the HUD.", _, true, 1.0);
	cvar_xcord = CreateConVar("sm_executes_hud_position_x", "0.42", "The position of the HUD on the X axis.", _, true, 0.0);
	cvar_ycord = CreateConVar("sm_executes_hud_position_y", "0.3", "The position of the HUD on the Y axis.", _, true, 0.0);
	
	AutoExecConfig(true, "executes_hud");
	
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_Pre);
}

public void OnConfigsExecuted() {
	pluginEnabled = GetConVarBool(cvar_plugin_enabled);
	GetConVarString(cvar_style, style, sizeof(style));
	red = GetConVarInt(cvar_red);
	green = GetConVarInt(cvar_green);
	blue = GetConVarInt(cvar_blue);
	fadein = GetConVarFloat(cvar_fadein);
	fadeout = GetConVarFloat(cvar_fadeout);
	holdtime = GetConVarFloat(cvar_holdtime);
	xcord = GetConVarFloat(cvar_xcord);
	ycord = GetConVarFloat(cvar_ycord);
}

public void Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast) {
	if (!pluginEnabled || !Executes_Enabled() || IsWarmup()) {
		return;
	}
	
	bombsite = Executes_GetCurrrentBombsite();
	
	CreateTimer(1.0, displayHud);
}

public Action displayHud(Handle timer) {
	char bombsiteStr[1];
	bombsiteStr = bombsite == BombsiteA ? "A" : "B";
	
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsValidClient(i) || GetClientTeam(i) == CS_TEAM_CT) {
			continue;
		}
		
		char message[64] = "Execute site:";
		Format(message, sizeof(message), "%s %s", message, bombsiteStr);
		
		if (StrContains(style, STYLE_HUD) != -1) {
			SetHudTextParams(xcord, ycord, holdtime, red, green, blue, 255, 0, 0.25, fadein, fadeout);
			ShowHudText(i, 5, "%s", message);
		}
		
		if (StrContains(style, STYLE_HINT) != -1) {
			PrintHintText(i, "%s", message);
		}
		
		if (StrContains(style, STYLE_CHAT) != -1) {
			PrintToChat(i, "%s %s", MESSAGE_PREFIX, message);
		}
	}
}

stock bool IsWarmup() {
	return GameRules_GetProp("m_bWarmupPeriod") == 1;
}

stock bool IsValidClient(int client) {
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client);
}
