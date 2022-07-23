#pragma semicolon 1

#define PLUGIN_AUTHOR "Cloud Strife"
#define PLUGIN_VERSION "1.00"
#define MAP_NAME "ze_kitchen_v2s"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <vscripts/Fly>

#pragma newdecls required

bool bValidMap = false;
Fly g_Fly = null;
Fly_End g_FlyEnd = null;
//Fly_End_Hovno g_FlyEndHovno[5] =  { null, ... };
ArrayList g_aFlySmall = null;
Microwave g_Microwave = null;
StringMap g_iButton_players = null;

public Plugin myinfo = 
{
	name = "ze_kitchen VScript",
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/cloudstrifeua/"
};

public void OnPluginStart()
{
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", OnRoundEnd, EventHookMode_PostNoCopy);
}

public void OnPluginEnd()
{
	UnhookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	UnhookEvent("round_end", OnRoundEnd, EventHookMode_PostNoCopy);
}

public void OnMapStart()
{
	char sCurMap[256];
	GetCurrentMap(sCurMap, sizeof(sCurMap));
	bValidMap = (strcmp(sCurMap, MAP_NAME, false) == 0);
	if(bValidMap)
	{
		g_aFlySmall = new ArrayList();
		g_iButton_players = new StringMap();
	}
	else
	{
		char sFilename[256];
		GetPluginFilename(INVALID_HANDLE, sFilename, sizeof(sFilename));

		ServerCommand("sm plugins unload %s", sFilename);
	}
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!bValidMap)
		return;

	int tmp = GetEntityIndexByHammerID(1208341, "trigger_multiple");

	HookSingleEntityOutput(tmp, "OnUser1", OnFlyStart, true);
	HookSingleEntityOutput(tmp, "OnUser2", OnAddFlyHP);
	HookSingleEntityOutput(tmp, "OnStartTouch", OnFlyInit, true);
	tmp = GetEntityIndexByHammerID(1564273, "prop_dynamic");

	HookSingleEntityOutput(tmp, "OnUser1", OnFlyEndInit, true);
	tmp = GetEntityIndexByHammerID(1416995, "prop_dynamic");

	HookSingleEntityOutput(tmp, "OnUser1", OnFlyDeadTrigger, true);
	tmp = GetEntityIndexByHammerID(1189814, "logic_relay");

	HookSingleEntityOutput(tmp, "OnTrigger", OnMicrowaveInit, true);
}

public void OnPlayerPickUp(const char[] output, int caller, int activator, float delay)
{
	char sButtonIndex[64];
	Format(sButtonIndex, sizeof(sButtonIndex), "%d", caller);
	g_iButton_players.SetValue(sButtonIndex, activator, true);
}

public void OnButtonPressed(const char[] output, int caller, int activator, float delay)
{
	char sButtonKey[64];
	Format(sButtonKey, sizeof(sButtonKey), "%d", caller);
	int val = -1;
	g_iButton_players.GetValue(sButtonKey, val);
	if (val == activator)
	{
		EntFireByIndex(caller, "FireUser1", "", "0.00", -1);
	}
}

public void OnMicrowaveInit(const char[] output, int caller, int activator, float delay)
{
	int entity = GetEntityIndexByHammerID(1684029, "prop_dynamic");
	
	g_Microwave = new Microwave(entity);
	
	HookSingleEntityOutput(entity, "OnUser1", OnMicrowaveAddHP);
	HookSingleEntityOutput(entity, "OnTakeDamage", OnMicrowaveTakeDamage);
	HookSingleEntityOutput(entity, "OnUser2", OnMicrowaveStart, true);
	HookSingleEntityOutput(entity, "OnUser3", OnMicrowaveLaserHit1);
	HookSingleEntityOutput(entity, "OnUser4", OnMicrowaveLaserHit2);
}

public void OnMicrowaveLaserHit2(const char[] output, int caller, int activator, float delay)
{
	if(g_Microwave)
		g_Microwave.Hit(80);
}

public void OnMicrowaveLaserHit1(const char[] output, int caller, int activator, float delay)
{
	if(g_Microwave)
	{	
		g_Microwave.Hit(70);
	}
}

public void OnMicrowaveStart(const char[] output, int caller, int activator, float delay)
{
	CreateTimer(1.0, Microwave_StartDelay,_, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Microwave_StartDelay(Handle timer)
{
	KillTimer(timer);
	g_Microwave.Start();
	return Plugin_Stop;
}

public void OnMicrowaveTakeDamage(const char[] output, int caller, int activator, float delay)
{
	if(g_Microwave)
	{	
		g_Microwave.Hit(1);
	}
}

public void OnMicrowaveAddHP(const char[] output, int caller, int activator, float delay)
{
	g_Microwave.AddHealth(200);
}

public void OnFlyDeadTrigger(const char[] output, int caller, int activator, float delay)
{
	float orig[3], angles[3];
	GetOrigin(g_Fly.entity, orig);
	GetAngles(g_Fly.entity, angles);
	SetOrigin(caller, orig);
	SetAngles(caller, angles);
	g_Fly.KillFly();
	delete g_Fly;
	g_Fly = null;
	EntFireByIndex(caller, "SetAnimation", "dead", "0.0", -1);
	EntFireByIndex(caller, "SetAnimation", "dead_loop", "2.0", -1);
}

//public void OnFlyEndHovnoInit1(const char[] output, int caller, int activator, float delay)
//{
	//g_FlyEndHovno[0] = new Fly_End_Hovno(caller);
	//g_FlyEndHovno[0].Start(1, false);
	//
//}

//public void OnFlyEndHovnoInit2(const char[] output, int caller, int activator, float delay)
//{
	//g_FlyEndHovno[1] = new Fly_End_Hovno(caller);
	//g_FlyEndHovno[1].Start(1, false);
	//
//}

//public void OnFlyEndHovnoInit3(const char[] output, int caller, int activator, float delay)
//{
	//g_FlyEndHovno[2] = new Fly_End_Hovno(caller);
	//g_FlyEndHovno[2].Start(1, false);
	//
//}

//public void OnFlyEndHovnoInit4(const char[] output, int caller, int activator, float delay)
//{
	//g_FlyEndHovno[3] = new Fly_End_Hovno(caller);
	//g_FlyEndHovno[3].Start(1, false);
	//
//}

//public void OnFlyEndHovnoInit5(const char[] output, int caller, int activator, float delay)
//{
	//g_FlyEndHovno[4] = new Fly_End_Hovno(caller);
	//g_FlyEndHovno[4].Start(1, false);
	//
//}

public void OnFlyEndInit(const char[] output, int caller, int activator, float delay)
{
	g_FlyEnd = new Fly_End(caller);
	g_FlyEnd.Start();
}

public void OnFlyInit(const char[] output, int caller, int activator, float delay)
{
	int fly = GetEntityIndexByHammerID(1199348, "prop_dynamic");
	
	g_Fly = new Fly(fly);
	
	HookSingleEntityOutput(fly, "OnUser1", OnChangeEggsCount);
	HookSingleEntityOutput(fly, "OnTakeDamage", OnFlyTakeDamage);
}

public void OnFlyTakeDamage(const char[] output, int caller, int activator, float delay)
{
	if(g_Fly)
	{	
		g_Fly.Hit();
	}
}

public void OnFlyStart(const char[] output, int caller, int activator, float delay)
{
	g_Fly.Start();
}

public void OnAddFlyHP(const char[] output, int caller, int activator, float delay)
{
	g_Fly.AddHealth(415);
}

public void OnChangeEggsCount(const char[] output, int caller, int activator, float delay)
{
	if(g_Fly)
	{	
		g_Fly.IncrementEggCount(-1);	
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!bValidMap)
		return;

	if (!CanTestFeatures() || GetFeatureStatus(FeatureType_Native, "SDKHook_OnEntitySpawned") != FeatureStatus_Available)
		SDKHook(entity, SDKHook_SpawnPost, OnEntitySpawnedPost);
}

public void OnEntitySpawnedPost(int entity)
{
	if (!IsValidEntity(entity))
		return;

	// 1 frame later required to get some properties
	RequestFrame(ProcessEntitySpawned, entity);
}

public void OnEntitySpawned(int entity, const char[] classname)
{
	ProcessEntitySpawned(entity);
}

stock void ProcessEntitySpawned(int entity)
{
	if (!bValidMap || !IsValidEntity(entity))
		return;

	char classname[64];
	GetEntityClassname(entity, classname, sizeof(classname));

	if(strcmp(classname, "prop_dynamic") == 0)
	{
		char sName[128];
		GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));
		if(!sName[0])
			return;
		if(StrContains(sName, "fly_small_model") != -1)
		{
			Fly_Small fly_small = new Fly_Small(entity);
			g_aFlySmall.Push(fly_small);
			if(StrContains(sName, "fly_small_model_map") != -1)
			{
				CreateTimer(5.0, StartDelay, fly_small);
			}
			else
			{
				fly_small.Start();
			}
			HookSingleEntityOutput(entity, "OnUser1", OnFlySmallDie, true);
		}
		//else if(strcmp(sName, "1_fly_hovno") == 0)
		//{
			//
			//HookSingleEntityOutput(entity, "OnUser1", OnFlyEndHovnoInit1, true);
		//}
		//else if(strcmp(sName, "2_fly_hovno") == 0)
		//{
			//
			//HookSingleEntityOutput(entity, "OnUser1", OnFlyEndHovnoInit2, true);
		//}
		//else if(strcmp(sName, "3_fly_hovno") == 0)
		//{
			//
			//HookSingleEntityOutput(entity, "OnUser1", OnFlyEndHovnoInit3, true);
		//}
		//else if(strcmp(sName, "4_fly_hovno") == 0)
		//{
			//
			//HookSingleEntityOutput(entity, "OnUser1", OnFlyEndHovnoInit4, true);
		//}
		//else if(strcmp(sName, "5_fly_hovno") == 0)
		//{
			//
			//HookSingleEntityOutput(entity, "OnUser1", OnFlyEndHovnoInit5, true);
		//}
	}
	else if(strcmp(classname, "func_button") == 0)
	{
		char sName[128];
		GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));
		if(!sName[0])
			return;
		if(StrContains(sName, "george_cades_syr_button") != -1)
		{
			HookSingleEntityOutput(entity, "OnUser2", OnPlayerPickUp);
			HookSingleEntityOutput(entity, "OnPressed", OnButtonPressed);
		}
		else if(StrContains(sName, "george_cades_toast_button") != -1)
		{
			HookSingleEntityOutput(entity, "OnUser2", OnPlayerPickUp);
			HookSingleEntityOutput(entity, "OnPressed", OnButtonPressed);
		}
		else if(StrContains(sName, "george_cades_sunka_button") != -1)
		{
			HookSingleEntityOutput(entity, "OnUser2", OnPlayerPickUp);
			HookSingleEntityOutput(entity, "OnPressed", OnButtonPressed);
		}
		else if(StrContains(sName, "george_cades_korenka_button") != -1)
		{
			HookSingleEntityOutput(entity, "OnUser2", OnPlayerPickUp);
			HookSingleEntityOutput(entity, "OnPressed", OnButtonPressed);
		}
		else if(StrContains(sName, "george_cades_houba_button") != -1)
		{
			HookSingleEntityOutput(entity, "OnUser2", OnPlayerPickUp);
			HookSingleEntityOutput(entity, "OnPressed", OnButtonPressed);
		}
	}
}

public Action StartDelay(Handle timer, Fly_Small fly)
{
	KillTimer(timer);
	if(fly)
	{
		fly.Start();
	}
	return Plugin_Stop;
}

public void OnFlySmallDie(const char[] output, int caller, int activator, float delay)
{
	for (int i = 0; i < g_aFlySmall.Length; i++)
	{
		Fly_Small fly = view_as<Fly_Small>(g_aFlySmall.Get(i));
		if(fly.entity == caller)
		{
			fly.Die();
			delete fly;
			g_aFlySmall.Erase(i);
		}
	}
}

public void OnEntityDestroyed(int entity)
{
	if(!bValidMap)
		return;

	if (!CanTestFeatures() || GetFeatureStatus(FeatureType_Native, "SDKHook_OnEntitySpawned") != FeatureStatus_Available)
		SDKUnhook(entity, SDKHook_SpawnPost, OnEntitySpawnedPost);

	if(!IsValidEntity(entity))
		return;

	char sClassname[64];
	GetEntityClassname(entity, sClassname, sizeof(sClassname));
	if(strcmp(sClassname, "prop_dynamic") == 0)
	{
		char sName[128];
	 	GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));
	 	if(!sName[0])
	 		return;
	 	if(StrContains(sName, "fly_small_model") != -1)
	 	{
	 		for (int i = 0; i < g_aFlySmall.Length; i++)
			{
				Fly_Small fly = view_as<Fly_Small>(g_aFlySmall.Get(i));
				if(fly.entity == entity)
				{
					
					fly.doNextTick = false;
					delete fly;
					g_aFlySmall.Erase(i);
				}
			}
	 	}
	 	else if(strcmp(sName, "mikrovlnka_model") == 0)
	 	{
	 		if(g_Microwave)
	 		{
	 			delete g_Microwave;
	 		}
	 	}
	}
}

public void Cleanup()
{
	if(!bValidMap)
		return;
	
	if(g_Microwave)
		delete g_Microwave;
		
	if(g_Fly)
	{
		g_Fly.doNextTick = false;
		delete g_Fly;
		g_Fly = null;
	}
	if(g_FlyEnd)
	{
		g_FlyEnd.doNextTick = false;
		delete g_FlyEnd;
		g_FlyEnd = null;
	}
	//for (int i = 0; i < 5; i++)
	//{
		//if(g_FlyEndHovno[i])
		//{
			//g_FlyEndHovno[i].doNextTick = false;
			//g_FlyEndHovno[i] = null;
		//}
	//}
	if (g_aFlySmall)
	{
		for (int i = 0; i < g_aFlySmall.Length; i++)
		{
			Fly_Small fly = view_as<Fly_Small>(g_aFlySmall.Get(i));
			fly.doNextTick = false;
			delete fly;
			g_aFlySmall.Erase(i);
		}
	}
	if (g_iButton_players)
		g_iButton_players.Clear();
}

public void OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	Cleanup();
}

public void OnMapEnd()
{
	Cleanup();
	if(bValidMap)
	{
		delete g_aFlySmall;
		delete g_iButton_players;
	}
	bValidMap = false;
}
