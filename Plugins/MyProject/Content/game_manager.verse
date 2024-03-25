
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

using{/Fortnite.com/Teams}
using{/Fortnite.com/Game}
using{/Fortnite.com/Characters}

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
game_manager := class(creative_device):

    var PlayerMap: [player]int = map {}


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()
        for(Player : AllPlayers, FortCharacter := Player.GetFortCharacter[]):
            if (set PlayerMap[Player] = 0):
                Print("Guardando jugador")
