/*
 * SourceMod Hosties Project
 * by: SourceMod Hosties Dev Team
 *
 * This file is part of the SM Hosties project.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <adminmenu>
#include <sdkhooks>
#include <emitsoundany>
#include <hosties>
#include <multicolors>

#undef REQUIRE_PLUGIN
#undef REQUIRE_EXTENSIONS
#tryinclude <SteamWorks>
#tryinclude <sourcebanspp>
#define REQUIRE_EXTENSIONS
#define REQUIRE_PLUGIN

// Compiler directives
#pragma 	semicolon 					1

// Constants
#define 	PLUGIN_VERSION				"3.1.17b"
#define 	MAX_DISPLAYNAME_SIZE		64
#define 	MAX_DATAENTRY_SIZE			5
#define 	SERVERTAG					"ENT_Hosties,LR,LastRequest,ENT,Hosties"

// Note: you cannot safely turn these modules on and off yet. Use cvars to disable functionality.

// Add ability to disable collisions for players
#define	MODULE_NOBLOCK						1
// Add the last request system
#define	MODULE_LASTREQUEST					1
// Add a game description override
#define	MODULE_GAMEDESCRIPTION				1
// Add start weapons for both teams
#define	MODULE_STARTWEAPONS					1
// Add round-end team overlays
#define	MODULE_TEAMOVERLAYS					1
// Add !rules command
#define	MODULE_RULES						1
// Add !checkplayers command
#define	MODULE_CHECKPLAYERS					1
// Add muting system
#define	MODULE_MUTE							1
// Add freekill detection and prevention
#define	MODULE_FREEKILL						1
// Add gun safety
#define	MODULE_GUNSAFETY					1
// Add intelli-respawn
#define	MODULE_RESPAWN						1

/******************************************************************************
                   !EDIT BELOW THIS COMMENT AT YOUR OWN PERIL!
******************************************************************************/

// Global vars
char ChatBanner[256];
bool g_bSBAvailable = false; // SourceBans
GameType g_Game = Game_Unknown;

Handle gH_TopMenu = INVALID_HANDLE;
TopMenuObject gM_Hosties = INVALID_TOPMENUOBJECT;

char gShadow_Hosties_LogFile[PLATFORM_MAX_PATH];
Handle gH_Cvar_LR_Debug_Enabled = INVALID_HANDLE;
bool gShadow_LR_Debug_Enabled = false;

#if (MODULE_FREEKILL == 1)
Handle gH_Cvar_Freekill_Sound = INVALID_HANDLE;
Handle gH_Cvar_Freekill_Threshold = INVALID_HANDLE;
Handle gH_Cvar_Freekill_Notify = INVALID_HANDLE;
Handle gH_Cvar_Freekill_BanLength = INVALID_HANDLE;
Handle gH_Cvar_Freekill_Punishment = INVALID_HANDLE;
Handle gH_Cvar_Freekill_Reset = INVALID_HANDLE;
char gShadow_Freekill_Sound[PLATFORM_MAX_PATH];
int gShadow_Freekill_Threshold;
int gShadow_Freekill_BanLength;
int gShadow_Freekill_Reset;
FreekillPunishment gShadow_Freekill_Punishment;
bool gShadow_Freekill_Notify;
int gA_FreekillsOfCT[MAXPLAYERS+1];
#endif

#if (MODULE_NOBLOCK == 1)
#include "hosties/noblock.sp"
#endif
#if (MODULE_LASTREQUEST == 1)
#include "hosties/lastrequest.sp"
#endif
#if (MODULE_GAMEDESCRIPTION == 1)
#include "hosties/gamedescription.sp"
#endif
#if (MODULE_STARTWEAPONS == 1)
#include "hosties/startweapons.sp"
#endif
#if (MODULE_TEAMOVERLAYS == 1)
#include "hosties/teamoverlays.sp"
#endif
#if (MODULE_RULES == 1)
#include "hosties/rules.sp"
#endif
#if (MODULE_CHECKPLAYERS == 1)
#include "hosties/checkplayers.sp"
#endif
#if (MODULE_MUTE == 1)
#include "hosties/muteprisoners.sp"
#endif
#if (MODULE_FREEKILL == 1)
#include "hosties/freekillers.sp"
#endif
#if (MODULE_GUNSAFETY == 1)
#include "hosties/gunsafety.sp"
#endif
#if (MODULE_RESPAWN == 1)
#include "hosties/respawn.sp"
#endif

// ConVars
Handle gH_Cvar_Add_ServerTag = INVALID_HANDLE;
Handle gH_Cvar_Display_Advert = INVALID_HANDLE;
Handle gH_Cvar_ChatTag = INVALID_HANDLE;

public Plugin myinfo =
{
	name        = "ENT_Hosties(V3)",
	author      = "databomb & Entity",
	description = "SM_Hosties Remake",
	version     = "Entity",
};

public void OnPluginStart()
{
	// Load translations
	LoadTranslations("common.phrases");
	LoadTranslations("hosties.phrases");

	// Events hooks
	HookEvent("round_start", Event_RoundStart);

	// Create ConVars
	gH_Cvar_Add_ServerTag = CreateConVar("sm_hosties_add_servertag", "1", "Enable or disable automatic adding of SM_Hosties in sv_tags (visible from the server browser in CS:S): 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_Display_Advert = CreateConVar("sm_hosties_display_advert", "1", "Enable or disable the display of the Powered by SM Hosties message at the start of each round.", 0, true, 0.0, true, 1.0);
	gH_Cvar_ChatTag = CreateConVar("sm_hosties_chat_banner", "{darkblue}[{lightblue}Hosties{darkblue}]", "Edit ChatTag for ENT_Hosties (Colors can be used).");
	
	HookConVarChange(gH_Cvar_ChatTag, OnCvarChange_ChatTag);
	
	char Temp[256];
	GetConVarString(gH_Cvar_ChatTag, Temp, sizeof(Temp));
	Format(ChatBanner, sizeof(ChatBanner), "%s {lime}", Temp);
	
	CreateConVar("sm_hosties_version", PLUGIN_VERSION, "SM_Hosties plugin version (unchangeable)", 0|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	RegAdminCmd("sm_hostiesadmin", Command_HostiesAdmin, ADMFLAG_SLAY);
	
	#if (MODULE_STARTWEAPONS == 1)
	StartWeapons_OnPluginStart();
	#endif
	#if (MODULE_NOBLOCK == 1)
	NoBlock_OnPluginStart();
	#endif
	#if (MODULE_CHECKPLAYERS == 1)
	CheckPlayers_OnPluginStart();
	#endif
	#if (MODULE_RULES == 1)
	Rules_OnPluginStart();
	#endif
	#if (MODULE_GAMEDESCRIPTION == 1)
	GameDescription_OnPluginStart();
	#endif
	#if (MODULE_TEAMOVERLAYS == 1)
	TeamOverlays_OnPluginStart();
	#endif
	#if (MODULE_LASTREQUEST == 1)
	LastRequest_OnPluginStart();
	#endif
	#if (MODULE_MUTE == 1)
	MutePrisoners_OnPluginStart();
	#endif
	#if (MODULE_FREEKILL == 1)
	Freekillers_OnPluginStart();
	#endif
	#if (MODULE_GUNSAFETY == 1)
	GunSafety_OnPluginStart();
	#endif
	#if (MODULE_RESPAWN == 1)
	Respawn_OnPluginStart();
	#endif
	
	char Folder[256];
	BuildPath(Path_SM, Folder, sizeof(Folder), "logs/Entity");
	DirExistsEx(Folder);
	
	SetLogFile(gShadow_Hosties_LogFile, "Hosties-Logs", "Entity");
	if (gShadow_LR_Debug_Enabled == true) LogToFileEx(gShadow_Hosties_LogFile, "Hosties Successfully started.");
	AutoExecConfig(true, "sm_hosties3");
}

public void OnMapStart()
{
	#if (MODULE_TEAMOVERLAYS == 1)
	TeamOverlays_OnMapStart();
	#endif
	#if (MODULE_LASTREQUEST == 1)
	LastRequest_OnMapStart();
	#endif
}

public void OnMapEnd()
{
	#if (MODULE_FREEKILL == 1)	
	Freekillers_OnMapEnd();
	#endif
}

public void OnAllPluginsLoaded()
{
	if (LibraryExists("sourcebans"))
	{
		g_bSBAvailable = true;
	}
	
	Handle h_TopMenu = GetAdminTopMenu();
	if (LibraryExists("adminmenu") && (h_TopMenu != INVALID_HANDLE))
	{
		OnAdminMenuReady(h_TopMenu);
	}
	
	#if (MODULE_MUTE == 1)
	MutePrisoners_AllPluginsLoaded();
	#endif
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() == Engine_CSS)
	{
		g_Game = Game_CSS;
	}
	else if (GetEngineVersion() == Engine_CSGO)
	{
		g_Game = Game_CSGO;
	}
	else
	{
		SetFailState("Game is not supported.");
	}

	MarkNativeAsOptional("SteamWorks_SetGameDescription");

	LastRequest_APL();
	
	RegPluginLibrary("hosties");
	
	return APLRes_Success;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "sourcebans"))
	{
		g_bSBAvailable = true;
	}
	else if (StrEqual(name, "adminmenu") && (GetAdminTopMenu() != INVALID_HANDLE))
	{
		OnAdminMenuReady(GetAdminTopMenu());
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "sourcebans"))
	{
		g_bSBAvailable = false;
	}
	else if (StrEqual(name, "adminmenu"))
	{
		gH_TopMenu = GetAdminTopMenu();
	}
}

public void OnConfigsExecuted()
{
	if (GetConVarInt(gH_Cvar_Add_ServerTag) == 1)
	{
		Handle hTags = FindConVar("sv_tags");
		char sTags[512], sTagsFormat[128];
		GetConVarString(hTags, sTags, sizeof(sTags));
		
		char gShadow_TagList[16][32];
		int TagCount = ExplodeString(SERVERTAG, ",", gShadow_TagList, sizeof(gShadow_TagList), sizeof(gShadow_TagList[]));
		for (int Tidx = 0; Tidx < TagCount; Tidx++)
		{
			if (StrContains(sTags, gShadow_TagList[Tidx], false) == -1)
			{
				Format(sTagsFormat, sizeof(sTagsFormat), ",%s", gShadow_TagList[Tidx]);
			}
		}
		StrCat(sTags, sizeof(sTags), sTagsFormat);
		SetConVarString(hTags, sTags);
		CloseHandle(hTags);
	}
	
	#if (MODULE_FREEKILL == 1)
	Freekillers_OnConfigsExecuted();
	#endif
	#if (MODULE_MUTE == 1)
	MutePrisoners_OnConfigsExecuted();
	#endif
	#if (MODULE_CHECKPLAYERS == 1)
	CheckPlayers_OnConfigsExecuted();
	#endif
	#if (MODULE_GAMEDESCRIPTION == 1)
	GameDesc_OnConfigsExecuted();
	#endif
	#if (MODULE_TEAMOVERLAYS == 1)
	TeamOverlays_OnConfigsExecuted();
	#endif
	#if (MODULE_RULES == 1)
	Rules_OnConfigsExecuted();
	#endif
	#if (MODULE_LASTREQUEST == 1)
	LastRequest_OnConfigsExecuted();
	#endif
	#if (MODULE_NOBLOCK == 1)
	NoBlock_OnConfigsExecuted();
	#endif
	#if (MODULE_STARTWEAPONS == 1)
	StartWeapons_OnConfigsExecuted();
	#endif
}

public void OnClientPutInServer(int client)
{
	#if (MODULE_LASTREQUEST == 1)
	LastRequest_ClientPutInServer(client);
	#endif
	#if (MODULE_FREEKILL == 1)
	Freekillers_ClientPutInServer(client);
	#endif
}

public Action Event_RoundStart(Event event, const char[] name , bool dontBroadcast)
{
	if (GetConVarInt(gH_Cvar_Display_Advert))
	{
		// Print out a messages about SM_Hosties 
		CPrintToChatAll("%s %t", ChatBanner, "Powered By Hosties");
	}
}

public void OnAdminMenuReady(Handle h_TopMenu)
{
	// block double calls
	if (h_TopMenu == gH_TopMenu)
	{
		return;
	}
	
	gH_TopMenu = h_TopMenu;
	
	// Build Hosties menu
	gM_Hosties = AddToTopMenu(gH_TopMenu, "Hosties", TopMenuObject_Category, HostiesCategoryHandler, INVALID_TOPMENUOBJECT);
	
	if (gM_Hosties == INVALID_TOPMENUOBJECT)
	{
		return;
	}
	
	// Let other modules add menu objects
	#if (MODULE_LASTREQUEST == 1)
	LastRequest_Menus(gH_TopMenu, gM_Hosties);
	#endif
	#if (MODULE_GUNSAFETY == 1)
	GunSafety_Menus(gH_TopMenu, gM_Hosties);
	#endif
	#if (MODULE_RESPAWN == 1)
	Respawn_Menus(gH_TopMenu, gM_Hosties);
	#endif
}

public void OnCvarChange_ChatTag(ConVar cvar, char[] oldvalue, char[] newvalue)
{
	Format(ChatBanner, sizeof(ChatBanner), "%s {lime}", newvalue);
}

public Action Command_HostiesAdmin(int client, int args)
{
	DisplayTopMenu(gH_TopMenu, client, TopMenuPosition_LastRoot);
	return Plugin_Handled;
}

public void HostiesCategoryHandler(Handle topmenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case (TopMenuAction_DisplayTitle):
		{
			if (item == gM_Hosties)
			{
				Format(buffer, maxlength, "Hosties:");
			}
		}
		case (TopMenuAction_DisplayOption):
		{
			if (item == gM_Hosties)
			{
				Format(buffer, maxlength, "Hosties");
			}
		}
	}
}

stock void SetLogFile(char path[PLATFORM_MAX_PATH], char[] file, char[] folder)
{
	char LogDate[12];
	FormatTime(LogDate, sizeof(LogDate), "%y-%m-%d");
	Format(path, sizeof(path), "logs/%s/%s-%s.log", folder, file, LogDate);

	BuildPath(Path_SM, path, sizeof(path), path);
}

stock bool DirExistsEx(const char[] path)
{
	if (!DirExists(path))
	{
		CreateDirectory(path, 511);

		if (!DirExists(path))
		{
			LogError("Couldn't create folder! (%s)", path);
			return false;
		}
	}

	return true;
}