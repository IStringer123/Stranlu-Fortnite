using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Teams }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/FortPlayerUtilities }

Game_Manager_Device := class(creative_device):

    #Todos los Players
    var PlayerMap : [player]int = map{}

    #Spawners
    @editable
    var Spawners1 : []player_spawner_device = array{}
    
                #Instant Respawn
    var SpawnsPad : []player_spawner_device = array{}
    @editable ElimManager : elimination_manager_device = elimination_manager_device{}

    #Weapon Granters
    @editable
    var WeaponGranters : []item_granter_device = array{}


    #Bot
    @editable
    var Sentries : []sentry_device = array{}

    #Variables
    var ElimsToEndGame : int = 0
    var MaximoRondas : int = 2
    

    #-------------------CODIGO-----------------------------

    OnBegin<override>()<suspends>:void=
        GetPlayspace().PlayerAddedEvent().Subscribe(RegistrarNuevo)
        set ElimsToEndGame = WeaponGranters.Length;
        InitPlayers()
        InitSpawners()
        ElimManager.EliminatedEvent.Subscribe(SelfEliminated)

        InitTestMode()
    
        

    #Inicializa el Spawner del Mapa Seleccionado
    InitSpawners() : void=
        
        DisableSpawners()

        for(Spawner : Spawners1):
            Spawner.Enable()

    #Desabilita todos los spawners de todos los mapas.
    DisableSpawners() : void=

        for(Spawner1 : Spawners1):
            Spawner1.Disable()

    RegistrarNuevo(Player : player): void=

        if (set PlayerMap[Player] = 0, WeaponTier:= PlayerMap[Player],FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)
            GrantWeapon(Player, WeaponTier)
            
            
    InitPlayers() : void=
        AllPlayers := GetPlayspace ().GetPlayers()
       for (Player : AllPlayers, FortCharacter := Player.GetFortCharacter[]):
            if (set PlayerMap[Player] = 0, WeaponTier:= PlayerMap[Player]):
                FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)
                GrantWeapon(Player, WeaponTier)
    
    GrantWeapon(Player : player, WeaponTier: int) : void=
        if (ItemGranter := WeaponGranters[WeaponTier]):
                ItemGranter.GrantItem(Player)

    OnPlayerEliminated(Result : elimination_result) : void=

            Eliminator := Result.EliminatingCharacter
            
            if (FortCharacter := Eliminator?, EliminatingAgent := FortCharacter.GetAgent[]):

                PromotePlayer(EliminatingAgent)
                

    PromotePlayer(Agent: agent) : void=

        var WeaponTier : int = 0
        if (Player := player[Agent], PlayerWeaponTier := PlayerMap[Player]):
            set WeaponTier = PlayerWeaponTier + 1


            if(WeaponTier >= ElimsToEndGame):

                set WeaponTier = 0
        
        if (Player := player[Agent], set PlayerMap[Player] = WeaponTier):

            GrantWeapon(Player, WeaponTier)
        
    InitTestMode() : void=
        for (Sentry : Sentries):
            Sentry.EliminatedEvent.Subscribe(TestPlayerElimination)
    
    TestPlayerElimination(Agent : ?agent) : void=
        if (Player := Agent?):
            PromotePlayer(Player)


    #Instant Respawn:

    SelfEliminated(Agent:agent):void=
        
        set SpawnsPad = Spawners1

        PadRandom := GetRandomInt(1,SpawnsPad.Length)
        if ( RandomInt := SpawnsPad[PadRandom-1] ): 
            Transform := RandomInt.GetTransform()
            if (Player := player[Agent], PlayerWeaponTier := PlayerMap[Player]):
                Agent.Respawn(Transform.Translation, Transform.Rotation)
                GrantWeapon(Player, PlayerWeaponTier)
