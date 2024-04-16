#include <sourcemod>
#include <sdkhooks>

#define TEAM_SURVIVOR   2
#define TEAM_INFECTED   3

enum ZombieClass
{
    Zombie_Common = 0,
    Zombie_Smoker,
    Zombie_Boomer,
    Zombie_Hunter,
    Zombie_Spitter,
    Zombie_Jockey,
    Zombie_Charger,
    Zombie_Witch,
    Zombie_Tank,
    Zombie_Survivor,
};

ConVar l4d1_minigun_tank_damage = null;
ConVar mounted_gun_pz_damage = null;

public void OnPluginStart()
{
    l4d1_minigun_tank_damage = CreateConVar( "l4d1_minigun_tank_damage", "200" );
    mounted_gun_pz_damage = CreateConVar( "mounted_gun_pz_damage", "50" );
}

public void OnClientPutInServer( int iClient )
{
    SDKHook( iClient, SDKHook_OnTakeDamage, CTerrorPlayer_OnTakeDamage );
}

public void OnClientDisconnect( int iClient )
{
    SDKUnhook( iClient, SDKHook_OnTakeDamage, CTerrorPlayer_OnTakeDamage );
}

public Action CTerrorPlayer_OnTakeDamage( int iVictim, int &iAttacker, int &iInflictor, float &flDamage, int &fDamageType, int &iWeapon, float flVecDamageForce[3], float flVecDamagePosition[3] )
{
    bool bIsAttackerClient = ( iAttacker > 0 && iAttacker <= MaxClients );
    if ( GetClientTeam( iVictim ) == TEAM_INFECTED && bIsAttackerClient )
    {
        char szInflictor[64];
        GetEntityClassname( iInflictor, szInflictor, sizeof( szInflictor ) );

        if ( view_as< ZombieClass >( GetEntProp( iVictim, Prop_Send, "m_zombieClass" ) ) == Zombie_Tank && StrEqual( szInflictor, "prop_minigun_l4d1" ) )
        {
            flDamage = float( l4d1_minigun_tank_damage.IntValue );
            return Plugin_Changed;
        }

        if ( StrEqual( szInflictor, "prop_minigun" ) )
        {
            flDamage = float( mounted_gun_pz_damage.IntValue );
            return Plugin_Changed;
        }
    }

    return Plugin_Continue;
}

public Plugin myinfo =
{
    name = "[L4D2] Minigun & Heavy Machine Gun Damage Modifier",
    author = "Justin \"Sir Jay\" Chellah",
    description = "Allows server operators to change the Minigun damage against tanks and Heavy Machine Gun damage against players in general",
    version = "1.0.0",
    url = "https://www.justin-chellah.com/"
};