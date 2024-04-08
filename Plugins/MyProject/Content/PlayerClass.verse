using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }

PlayerVariable := class():
    AgentOB : agent

    RankBar : RankProgressBar = RankProgressBar{}

    var CurrentGoal : int = 10

    var CurrentValue : int = 0

    GetCurrentGoal() : int =
        return CurrentGoal

    SetCurrentGoal(Change : int) : int =
        set CurrentGoal = Change

    GetCurrentValue() : int =
        return CurrentValue

    SetCurrentValue(Change : int) : int =
        set CurrentValue = Change