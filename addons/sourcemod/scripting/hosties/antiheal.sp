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
#include <cstrike>
#include <sdktools>
#include <hosties>
#include <lastrequest>

int g_Offset_Health = -1;

ConVar gH_Cvar_AntiHeal_Enabled;
ConVar gH_Cvar_AntiHeal_Punishment;
int gShadow_Client_Health[MAXPLAYERS+1];
int gShadow_Clinet_Partner[MAXPLAYERS+1];

void Antiheal_OnPluginStart()
{
	g_Offset_Health = FindSendPropInfo("CBasePlayer", "m_iHealth");
	if (g_Offset_Health == -1)
	{
		SetFailState("Unable to find offset for health.");
	}

	gH_Cvar_AntiHeal_Enabled = CreateConVar("sm_hosties_antiheal_enabled", "1", "Enable or disable heal anticheat in lr:", 0, true, 0.0, true, 1.0);
	gH_Cvar_AntiHeal_Punishment = CreateConVar("sm_hosties_antiheal_mode", "0", "Punishment mode (0 - Block heal, 1 - Slay and abort)", 0, true, 0.0, true, 1.0);
}

public void OnStartLR(int PrisonerIndex, int GuardIndex)
{
	if (gH_Cvar_AntiHeal_Enabled.BoolValue)
	{
		if (IsValidClient(PrisonerIndex))
		{
			gShadow_Client_Health[PrisonerIndex] = 100;
			gShadow_Clinet_Partner[PrisonerIndex] = GuardIndex;
			CreateTimer(0.1, Timer_AntiHeal, PrisonerIndex, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		
		if (IsValidClient(GuardIndex))
		{
			gShadow_Client_Health[GuardIndex] = 100;
			gShadow_Clinet_Partner[GuardIndex] = PrisonerIndex;
			CreateTimer(0.1, Timer_AntiHeal, GuardIndex, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action Timer_AntiHeal(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		if (!IsClientInLastRequest(client) && IsPlayerAlive(client))
			return Plugin_Stop;
		else if (!IsPlayerAlive(client))
			return Plugin_Stop;
		else if (!gH_Cvar_AntiHeal_Enabled.BoolValue)
			return Plugin_Stop;
			
		if (gShadow_Client_Health[client] > GetEntData(client, g_Offset_Health))
		{
			gShadow_Client_Health[client] = GetEntData(client, g_Offset_Health);
		}
		else if (gShadow_Client_Health[client] < GetEntData(client, g_Offset_Health))
		{
			if (gH_Cvar_AntiHeal_Punishment.IntValue == 0)
				SetEntData(client, g_Offset_Health, gShadow_Client_Health[client]);
			else if (gH_Cvar_AntiHeal_Punishment.IntValue == 1)
			{
				KillAndReward(client, gShadow_Clinet_Partner[client]);
				CPrintToChatAll("%s %t", ChatBanner, "LR Cheating Abort", client);
				return Plugin_Stop;
			}
		}
	}
	else
		return Plugin_Stop;
	return Plugin_Continue;
}