using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath}
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Assets }

RankProgressBar := class():

    var ProgressBarColorTop<private> : color_block = color_block{}  
    var Overlay<private> : overlay = overlay{}
        
    PBarTitleTextBlock<private> : text_block = text_block{DefaultTextColor := MakeColorFromHex("FFFFFF")}

    HPTitleText<private><localizes>(HPText : string) : message = "{HPText}"

    Init(Current : int, Goal : int):void=
        PBarTitleTextBlock.SetText(HPTitleText("{Current}/{Goal}"))


    UpdateWidthAndText(iCurrent : int, Goal : int):void=
        var NewCurrent : float = iCurrent * 1.0
        var NewGoal : float = Goal * 1.0

        RankPercentage := NewCurrent / NewGoal

        if (Current := float[NewGoal], Total := float[NewGoal]):
            if(iCurrent >= 170):
                PBarTitleTextBlock.SetText(HPTitleText("{iCurrent}/∞"))
            else:
                PBarTitleTextBlock.SetText(HPTitleText("{iCurrent}/{Goal}"))

    ShowUIForPlayer(Player : player):void=
        if (PlayerUI := GetPlayerUI[Player]):
            if (Fortchar := Player.GetFortCharacter[]):
                if (Instigator : agent = Fortchar.GetAgent[]):
                    PlayerUI.AddWidget(CreateUI(Instigator))

    UpdateHealthBar(NewWidth : float):void=
        Overlay.RemoveWidget(PBarTitleTextBlock)
        Overlay.AddWidget(CreateOverlaySlot(PBarTitleTextBlock,horizontal_alignment.Center))
        
    CreateOverlaySlot<private>(TheWidget : widget, HAlignment : horizontal_alignment):overlay_slot=  
        overlay_slot:
            Widget := TheWidget 
            #HorizontalAlignment := HAlignment

    CreateOverlay<private>(Agent : agent) : overlay=
        TheOverlay := overlay:
            Slots := array:
                overlay_slot:
                    Widget := PBarTitleTextBlock
        set Overlay = TheOverlay


    CreateUI<private>(Agent : agent) : canvas=
        TheCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.175149, Y := 0.833333}, Maximum := vector2{X := 0.175149, Y := 0.833333}}
                    Offsets := margin{Top := 100.0, Left := -100.0, Right := 0.0, Bottom := 0.0} #SACASAS
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := array:
                            stack_box_slot:
                                Widget := CreateOverlay(Agent)
                            
                                                                
        return TheCanvas


RankSystem := class(creative_device):

    var PlayerMap : [agent]PlayerVariable = map{}

    #Change names to your texture ones

    @editable EliminationTracker : tracker_device = tracker_device{}

    #Unreanked : texture = Ranks.Unranked

    Bronze1 : texture = Ranks.Bronze_1

    Bronze2 : texture = Ranks.Bronze_2

    Bronze3 : texture = Ranks.Bronze_3

    Silver1 : texture = Ranks.Silver_1

    Silver2 : texture = Ranks.Silver_2

    Silver3 : texture = Ranks.Silver_3

    Gold1 : texture = Ranks.Gold_1

    Gold2 : texture = Ranks.Gold_2

    Gold3 : texture = Ranks.Gold_3

    Plat1 : texture = Ranks.Platinum_1

    Plat2 : texture = Ranks.Platinum_2

    Plat3 : texture = Ranks.Platinum_3

    Diamond1 : texture = Ranks.Diamond_1

    Diamond2 : texture = Ranks.Diamond_2

    Diamond3 : texture = Ranks.Diamond_3

    Elite : texture = Ranks.Elite

    Champion : texture = Ranks.Champ_1

    Unreal : texture = Ranks.Unreal

    #Barra1 : texture = Ranks.Barra1
    

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

        # TODO: Replace this with your code
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
        Sleep(0.3)
        AlllPlayers := GetPlayspace().GetPlayers()
        for(Player : AlllPlayers):
            OnPlayerAdded(Player)

    OnPlayerAdded(Agent : agent):void=
       if (PlayerObj := player[Agent]):
            if (PlayerExists := PlayerMap[Agent]):

            else:
                PV : PlayerVariable = PlayerVariable{AgentOB := Agent}

                PV.RankBar.Init(PV.GetCurrentValue(), PV.GetCurrentGoal())

                PV.RankBar.ShowUIForPlayer(PlayerObj)

                spawn{MakeCurrentValue(Agent)}


                spawn{RankedLoopHudMessage(Agent, PlayerObj)}

                
            
                option:
                    set PlayerMap[Agent] = PV

    



    MakeCurrentValue(Agent : agent)<suspends>:void=
        loop:
            Sleep(0.01)
            if (PV : PlayerVariable = PlayerMap[Agent]):
                PV.SetCurrentValue(EliminationTracker.GetValue(Agent))
                PV.RankBar.UpdateWidthAndText(PV.GetCurrentValue(), PV.GetCurrentGoal())


    RankedLoopHudMessage(Agent : agent, Player : player)<suspends>:void =

        RankTextureBlock : texture_block = texture_block{DefaultImage := Bronze1, DefaultDesiredSize := vector2{X := 500.0, Y := 150.0}} #CAMBIAR BRONZE1

        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 0):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(10)
                    RankTextureBlock.SetImage(Bronze1) #CAMBIAR
                    NewCanvas : canvas = canvas:
                        Slots := array:
                            canvas_slot:
                                Widget := RankTextureBlock
                                Anchors := anchors{Minimum := vector2{X := 0.15, Y := 0.8}, Maximum := vector2{X := 0.15, Y := 0.8}}
                                Offsets := margin{Top := -80.0,Left := -270.0, Right :=0.0, Bottom :=0.0}  #Top := -80.0,Left := -270.0, Right :=0.0, Bottom :=0.0}  
                                Alignment := vector2{X := 0.0, Y := 0.0}    
                                
                                
                    #Barra transparente
                    <#
                    BarraBlock : texture_block = texture_block{DefaultImage := Barra1, DefaultDesiredSize := vector2{X := 500.0, Y := 125.0}} 
                    BarraBlock.SetImage(Barra1)

                    BarraTransparente : canvas = canvas:
                        Slots := array:
                            canvas_slot:
                                Widget := BarraBlock
                                Anchors := anchors{Minimum := vector2{X := 0.15, Y := 0.8}, Maximum := vector2{X := 0.15, Y := 0.8}}
                                Offsets := margin{Top := -65.0,Left := -280.0, Right :=0.0, Bottom :=0.0} 
                                Alignment := vector2{X := 0.0, Y := 0.0}     #>

                    if (PlayerUI := GetPlayerUI[Player]):
                        PlayerUI.AddWidget(NewCanvas)
                        #PlayerUI.AddWidget(BarraTransparente)
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 10 ):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(20)   
                    RankTextureBlock.SetImage(Bronze2) 
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 20 ):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(30)   
                    RankTextureBlock.SetImage(Bronze3) 
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 30):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(40)   
                    RankTextureBlock.SetImage(Silver1) 
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 40 ):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(50)   
                    RankTextureBlock.SetImage(Silver2) 
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 50):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(60)   
                    RankTextureBlock.SetImage(Silver3)
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 60):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(70)   
                    RankTextureBlock.SetImage(Gold1)
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 70):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(80)   
                    RankTextureBlock.SetImage(Gold2)
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 80):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(90)   
                    RankTextureBlock.SetImage(Gold3)
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 90):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(100)   
                    RankTextureBlock.SetImage(Plat1)
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 100):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(110)   
                    RankTextureBlock.SetImage(Plat2)
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 110):
                if (CP : PlayerVariable = PlayerMap[Agent]):
                    CP.SetCurrentGoal(120)   
                    RankTextureBlock.SetImage(Plat3)
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 120):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(130)   
                    RankTextureBlock.SetImage(Diamond1)
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 130):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(140)   
                    RankTextureBlock.SetImage(Diamond2)
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 140):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(150)   
                    RankTextureBlock.SetImage(Diamond3)
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 150):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(160)   
                    RankTextureBlock.SetImage(Elite)
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 160):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(170)   
                    RankTextureBlock.SetImage(Champion)
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 170):
                if (PV : PlayerVariable = PlayerMap[Agent]):   
                    RankTextureBlock.SetImage(Unreal)
                    break

    

    OnPlayerRemoved(PlayerLeft : agent):void =
        if (Agent := agent[PlayerLeft]):
            if (ActualPlayer := PlayerMap[Agent]):
                var TempAllPlayersMap : [agent]PlayerVariable = map{}
                for (Key -> Value : PlayerMap, Key <> Agent):
                    set TempAllPlayersMap = ConcatenateMaps(TempAllPlayersMap, map{Key => Value})
                
                set PlayerMap = TempAllPlayersMap
    #Don't share this code