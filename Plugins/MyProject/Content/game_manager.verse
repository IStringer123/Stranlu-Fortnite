using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Teams }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/FortPlayerUtilities }



# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
Game_Manager_Device := class(creative_device):

    #Todos los Players
    var PlayerMap : [player]int = map{}

    #Spawners
    @editable
    var Spawners1 : []player_spawner_device = array{}
    
                #Instant Respawn
    var SpawnsPad : []player_spawner_device = array{}
    @editable ElimManager : elimination_manager_device = elimination_manager_device{}

    #Teleporter
    @editable
    var Teleporter1 : teleporter_device  = teleporter_device{}

    #Weapon Granters
    @editable
    var WeaponGranters : []item_granter_device = array{}


    #Bot
    @editable
    var Sentries : []sentry_device = array{}


    #Timer
    @editable
    TimerDevice : timer_device = timer_device{}



    #Variables
    var ElimsToEndGame : int = 0
    var ActualRound : int = 1
    var MaximoRondas : int = 2
    

    #-------------------CODIGO-----------------------------

    OnBegin<override>()<suspends>:void=
        set ElimsToEndGame = WeaponGranters.Length;
        InitPlayers()
        InitSpawners()
        ElimManager.EliminatedEvent.Subscribe(SelfEliminated)
      #  TimerDevice.SuccessEvent.Subscribe(RoundChange) 
        InitTestMode()
    
        

    #Inicializa el Spawner del Mapa Seleccionado
    InitSpawners() : void=
        
        DisableSpawners()

        Print("SPAWNERS MAPA 1")
        for(Spawner : Spawners1):
            Spawner.Enable()

    #Desabilita todos los spawners de todos los mapas.
    DisableSpawners() : void=

        for(Spawner1 : Spawners1):
            Spawner1.Disable()


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
            Print("OnPlayerEliminated():  start.")
            Eliminator := Result.EliminatingCharacter
            
            if (FortCharacter := Eliminator?, EliminatingAgent := FortCharacter.GetAgent[]):
                Print("OnPLayerEliminated():  successfully retrieved FortCharacter and EliminatingAgent.")
                PromotePlayer(EliminatingAgent)
                

    PromotePlayer(Agent: agent) : void=
        Print("PromotePlayer():  start")
        var WeaponTier : int = 0
        if (Player := player[Agent], PlayerWeaponTier := PlayerMap[Player]):
            set WeaponTier = PlayerWeaponTier + 1
            Print("PromotePlayer():  successfully retrieved Player and PlayerWeaponTier.")

            if(WeaponTier >= ElimsToEndGame):
                Print("PromotePlayer(): WeaponTier is greater than or equal to ElimsToEndGame.")
                set WeaponTier = 0
        
        if (Player := player[Agent], set PlayerMap[Player] = WeaponTier):
            Print("PromotePlayer():  successfully retrieved Player and set PlayerMap to equal WeaponTier.")
            GrantWeapon(Player, WeaponTier)
        
    InitTestMode() : void=
        for (Sentry : Sentries):
            Sentry.EliminatedEvent.Subscribe(TestPlayerElimination)
    
    TestPlayerElimination(Agent : ?agent) : void=
        if (Player := Agent?):
            PromotePlayer(Player)
            Print("Promoviendo")


    #Instant Respawn:

    SelfEliminated(Agent:agent):void=
        

        Print("SELF ELIMINATED")
        set SpawnsPad = Spawners1

        PadRandom := GetRandomInt(1,SpawnsPad.Length)
        if ( RandomInt := SpawnsPad[PadRandom-1] ): 
            Transform := RandomInt.GetTransform()
            if (Player := player[Agent], PlayerWeaponTier := PlayerMap[Player]):
                Print("Respawneando...")
                Agent.Respawn(Transform.Translation, Transform.Rotation)
                GrantWeapon(Player, PlayerWeaponTier)

    TelentrasportarMapa(): void=
        AllPlayers := GetPlayspace ().GetPlayers()
        Print("Tpeando Mapa1")
        for (Player : AllPlayers):
            Teleporter1.Teleport(Player)


    RespawnearTodos(): void=

        set SpawnsPad = Spawners1

        PadRandom := GetRandomInt(1,SpawnsPad.Length)
        if ( RandomInt := SpawnsPad[PadRandom-1] ): 
            Transform := RandomInt.GetTransform()
            AllPlayers := GetPlayspace ().GetPlayers()
            Print("Respawneando Todos...")
            for (Player : AllPlayers,PlayerWeaponTier := PlayerMap[Player]):
                Player.Respawn(Transform.Translation, Transform.Rotation)
                GrantWeapon(Player, PlayerWeaponTier)

    RoundChange(Agent : ?agent): void=
        #Ver si la mayoria votÃ³ cambio

        Print("Round Changing...")
        #Actualiza numero de rondas y Incializa Spawners del Nuevo Mapa.
        if(ActualRound=MaximoRondas):
            set ActualRound=0
            
            
        set ActualRound = ActualRound + 1
        # InitSpawners()
            
        Print("----ACTUAL ROUND----: " + ToString(ActualRound))
            
        #Tpear todos los jugadores segun ronda.

        #Respawnear a todos antes del tp
        RespawnearTodos()
        TelentrasportarMapa()
