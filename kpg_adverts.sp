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
	name = "[MILKSHEIKH] KIDDO'S Cluster-Rape Advertisements",
	author = "Monkey Drone",
	description = "Display Ingame advertisement as chat messages",
	version = "1.0",
	url = "http://milksheikh.nl"
};

public OnPluginStart()
{
	DisplayAdsSurvivor();
	DisplayAdsInfected();
}

//Survivors
static NoOfAdsSurvivors = 7;
static const String:AdvertTextSurvivor[][]={
	"\x03 Press and Hold CTRL to use 1337-5P337"
	,"\x03 Try our Jetpacks, say: /jetpack, they are safe, sort of..."
	,"\x03 You can help yourself by holding CTRL"
	,"\x03 Here melee weapons perform better, TRY IT!"
	,"\x03 Try our !buy Command"
	,"\x03 Find a fire extinguisher, it will work as a flamethrower!"
	,"\x03 Say: !3rd to enable third person view mode!!!"
}
static ads_i_survivor = 0;

//Infected Advertisements Below
static NoOfAdsInfected = 6;
static const String:AdvertTextInfected[][]={
	"\x03 Press and Hold CTRL to use 1337-5P337"
	,"\x03 Click right mouse button to change zombie-class"
	,"\x03 Jockeys Jump WAY higher here, give it a try!"
	,"\x03 Chargers can move around while charging!, also JUMP!"
	,"\x03 You can !buy a tank and a witch, or anything else!"
	,"\x03 You can take control over the the Witch!!! press E while standing next to her"
	,"\x03 Hold R while spawning, you will like a little birdy!"
}
static ads_i_infected = 0;

//Survivor Ads
public DisplayAdsSurvivor(){
	CreateTimer(20.0, StartAdsSurvivor, _, TIMER_REPEAT);
}

public Action:StartAdsSurvivor(Handle:timer){
	if (ads_i_survivor == NoOfAdsSurvivors)
	{
		ads_i_survivor = 0;
	}
	for (new i_client=1; i_client <= GetMaxClients(); i_client++)
	{
		if ( (IsValidClient(i_client)) && (GetClientTeam(i_client) == TEAM_SURVIVOR) )
		{
			PrintHintText(i_client, "%s" , AdvertTextSurvivor[ads_i_survivor]);
		}
	}
	ads_i_survivor++
}

//Infected Ads
public DisplayAdsInfected(){
	CreateTimer(20.0, StartAdsInfected, _, TIMER_REPEAT);
}

public Action:StartAdsInfected(Handle:timer){
	if (ads_i_infected == NoOfAdsInfected)
	{
		ads_i_infected = 0;
	}
	
	for (new i_client=1; i_client <= GetMaxClients(); i_client++)
	{
		if ( (IsValidClient(i_client)) && (GetClientTeam(i_client) == TEAM_INFECTED) )
		{
			PrintHintText(i_client, "%s" , AdvertTextInfected[ads_i_infected]);
		}
	
	}
	ads_i_infected++
}


stock bool:IsValidClient(client)
{
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	return true;
} 