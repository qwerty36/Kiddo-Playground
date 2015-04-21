#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define L4D2_MAXPLAYERS 32

//UL4D2 Teams
#define TEAM_UNKNOWN 0
#define TEAM_SPECTATOR 1
#define TEAM_SURVIVOR 2
#define TEAM_INFECTED 3

//UL4D2 ZombieClasses
#define ZC_UNKNOWN 0
#define ZC_SMOKER 1
#define ZC_BOOMER 2
#define ZC_HUNTER 3
#define ZC_SPITTER 4
#define ZC_JOCKEY 5
#define ZC_CHARGER 6
#define ZC_WITCH 7
#define ZC_TANK 8
#define ZC_NOT_INFECTED 9     //survivor

public Plugin:myinfo =
{
	name = "[Milksheikh] KIDDOS - Custom Audio Sounds",
	author = "MonkeyDrone",
	description = "Plays specific sound files on specific events.",
	version = "0.1",
	url = "http://milksheikh.nl"
};

stock bool:IsValidClient(client)
{
    if (client <= 0 || client > MaxClients) return false;
    if (!IsClientInGame(client)) return false;
    return true;
} 
new bool:leftSaferoom = false;
////Sounds that play for players when these events happen.
//#0 - Player Incapped
//#1 - when player types !JetPack
//#2 - Ragequit Sound
//#3 - When survivor kills an SI.
//#4 - Round Start and player left safe area sound.
#define PLAYERGOTINCAPPED 0
#define JETPACKACTION 1
#define PLAYERRAGEQUIT 2
#define SURVIVORKILLEDINFECTED 3
#define ROUNDSTARTSOUND 4

#define noOfSoundFiles 5 
static const String:soundFiles[noOfSoundFiles][256] =
{
	"kiddo/000-incapsound.mp3",
	"kiddo/001-jetpacksound.mp3",
	"kiddo/002-rqsound.mp3",
	"kiddo/003-sikillsound.mp3",
	"kiddo/004-startsound.mp3"
};

public OnMapStart()
{
	for(new i = 0; i < sizeof(soundFiles); i++)
	{
		PrecacheGeneric(soundFiles[i]);
		PrecacheSound(soundFiles[i], true);
		decl String:addTheFileToTable[128];
		Format(addTheFileToTable, sizeof(addTheFileToTable), "sound/%s", soundFiles[i]);	
		AddFileToDownloadsTable(addTheFileToTable);
	}
} 

public OnPluginStart()
{
	//AddCommandListener(Command_Say, "say_team");
	//AddCommandListener(Command_Say, "say");
	//RegConsoleCmd("sm_muzic", play_muzic);
	//HookEvent("player_disconnect", Player_Disconnected);
	HookEvent("player_death",Player_Died);										//#3
	HookEvent("player_left_start_area",Player_Left_Saferoom);	//#4
	HookEvent("player_incapacitated",Player_Got_Incapped);		//#0
	//HookEvent("player_disconnect", Player_Disconnected);			//#2		//fires when players die...fracks things up, do not use.
	HookEvent("round_start",Round_Start_Event);
	HookEvent("round_end", Event_Round_End);
	
	RegConsoleCmd("sm_jetpack", play_jetpack);
}

public Action:play_muzic(client, args)
{
	new String:myNumber[3];
	GetCmdArgString(myNumber, sizeof(myNumber));
	new tempValue = StringToInt(myNumber);
	if (tempValue < noOfSoundFiles)
	{
		PrintToChatAll("Playing Sound Now Numbered %i", tempValue);
		EmitSoundToAll(soundFiles[tempValue], _, _, _, _, 1.0, _, _, _, _, _, _);
	}
	else
	{
		PrintToChatAll("Failed to Play Sound");
	}
}

public Action:play_jetpack(client, args)
{
	EmitSoundToClient(client, soundFiles[JETPACKACTION], _, _, _, _, 1.0, _, _, _, _, _, _);
}

public Player_Got_Incapped(Handle:event, String:name[], bool:dontBroadcast)
{
	for (new client = 1; client <= L4D2_MAXPLAYERS; client++)
	{
		if ((IsValidClient(client)) && (GetClientTeam(client) == TEAM_SURVIVOR) && (IsPlayerAlive(client)))
		{
			EmitSoundToAll(soundFiles[PLAYERGOTINCAPPED], _, _, _, _, 1.0, _, _, _, _, _, _);
		}
	}
}

public OnClientDisconnect_Post(client_unused)
{
	for (new client = 1; client <= L4D2_MAXPLAYERS; client++)
	{
		if ((IsValidClient(client)) && (GetClientTeam(client) == TEAM_SURVIVOR) && (IsPlayerAlive(client)))
		{
			EmitSoundToAll(soundFiles[PLAYERRAGEQUIT], _, _, _, _, 1.0, _, _, _, _, _, _);
		}
	}
}

public OnClientAuthorized(client)
{
	if (leftSaferoom)
	{
		CreateTimer(15.0, playerEpicMusic, client);
	}
	//EmitSoundToClient(client, soundFiles[ROUNDSTARTSOUND], _, _, _, _, 1.0, _, _, _, _, _, _);
}

public Action:playerEpicMusic(Handle:timer, any:client)
{
	EmitSoundToClient(client, soundFiles[ROUNDSTARTSOUND], _, _, _, _, 1.0, _, _, _, _, _, _);
}

public Player_Died(Handle:event, String:name[], bool:dontBroadcast)
{
	new player_died_ClientID = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker_ClientID = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	
	if (GetClientTeam(player_died_ClientID) == TEAM_INFECTED)
	{
		EmitSoundToClient(attacker_ClientID, soundFiles[SURVIVORKILLEDINFECTED], _, _, _, _, 1.0, _, _, _, _, _, _);
	}
}

public Player_Left_Saferoom(Handle:event, String:name[], bool:dontBroadcast)
{
	new player_rambo = GetClientOfUserId(GetEventInt(event, "userid"));
	if (GetClientTeam(player_rambo) == TEAM_SURVIVOR)
	{
		if (!leftSaferoom)
		{
			EmitSoundToAll(soundFiles[ROUNDSTARTSOUND], _, _, _, _, 1.0, _, _, _, _, _, _);
		}
		leftSaferoom = true;
	}
	
}

public Round_Start_Event(Handle:event, String:name[], bool:dontBroadcast)
{
	leftSaferoom = false;		//So people can listen to the round start music.
}

public Event_Round_End(Handle:event, String:name[], bool:dontBroadcast)
{
	leftSaferoom = false;		//So people can listen to the round start music.
}

public Action:Command_Say(client, const String:command[], args)
{
	new String:playerCommanded[128];
	//new String:toCheckJetpack[128] = {"!jetpack"};
	//new startidx = 0;
	GetCmdArgString(playerCommanded, sizeof(playerCommanded));
	//PrintToChatAll("player typed %s", playerCommanded);
	if ( StrContains(playerCommanded, "!jetpack", true) == 0) 
	{
		PrintToChatAll("Emitting Sound.");
		EmitSoundToClient(client, soundFiles[JETPACKACTION], _, _, _, _, 1.0, _, _, _, _, _, _);
	}
	else
	{
		PrintToChatAll("Command Listener Failed.");
	}
	//PrintToChatAll("Command Entered is %s", playerCommanded);
	return Plugin_Continue; 
}