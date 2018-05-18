[CS:S/CS:GO] SM Hosties v2
by: databomb, dataviruset and DorCoMaNdO
ReWorked by Entity


 Hello everyone!

Quote:
Version modified : 2.2.0
Supported games : csgo (others not tested yet)
Has new convars : No
Description of the changes : Below
I started to fix the latest version from SM_Hosties (damn there is much to do).
First of all I want to appriciate Databomb's hard work with his really cool plugins!
He helped me A LOT. Really thanks!


Credits:
Original plugin, SM_Hosties
Original author, Databomb
Tester, Revan

What I really made with the latest release:

        Added the SteamWorks include
        Added the smlib include
        Added Bayonet to the RightKnifeAntiCheat
        Added GetLastButton for updates in the future
        Added new cvar for debug (sm_hosties_debug_enabled 1 or 0)
        Added support for CSS in Thirdperson KnifeFight
        Added reset to Thirdperson Toggle
        Added debug texts (kills only (yet))
        Added support again for MyJailbreak
        Added support again for 3RD party LR
        Added RightKnife to the AntiCheat
        Added AntiCheat for Shot4Shot
        Added AntiCheat for Dodgeball
        Added AntiCheat for NoScope
        Added AntiCheat for RockPaperScissors
        Added AntiCheat for Race
        Modifed Shot4Shot to the AntiCheat
        Modifed Mag4Mag to the AntiCheat
        Modifed RockPaperScissorts to the AntiCheat
        Modifed Race to the AntiCheat
        Modifed JumpContest to the AntiCheat
        Changed the info (line 123)
        Changed the Announce (line 321)
        Changed sourceban to sourcebanpp include
        Fixed DodgeBall ItemEquip
        Fixed NoScope ItemEquip
        Fixed NoScope StartCheat (More Info Below)
        Fixed TaserCrash
        Fixed the Outsider slay in DodgeBall
        Fixed the AirKnife slay in Race
        Fixed KeepingTaserBug
        Fixed KnifeFight Taser Glitch
        Fixed Thirdperson in Knife Fight
        Fixed Shot4Shot CheatMissDetection
        Fixed Shot4Shot AmmoReplace
        Fixed Shot4Shot Usp Bug (More Info Below)
        Fixed LR Pistol ClipBug (More Info Below)
        Fixed LR Health Issues (More Info Below)
        Modified LR End (More Info Below)
        Modified the AntiCheat (Won't slay just if you hurt your opponent)
        Modified StripAllWeapons (by Databomb's original solution)
        Restricted the AntiCheat to Default LRs
        Colored the DebugTexts
        

Requests:
        Remove Taser at RoundEnd (Completed)
        Fix KnifeFight Taser-Bug (Completed)
        Fix Compile Warnings (Completed)
        Upload Includes for Compile (Completed)
        Shot4Shot P2000 Bug (Completed)
        Create a new AntiCheat to Shot4Shot (Completed)
        RockPaperScissors, NoScope, DodgeBall AntiCheat for Guns (Completed)
        Thirdperson Knife Fight View Bugfix (Completed)
        RightKnife bypasses the AntiCheat (Completed)
        AntiCheat kills for knifing/shooting the ground (AntiCheat full ReWorked)


More Info Place

    NoScope StartCheat (Fixed)

        Timer starts (so you got only knife) if you knife rapidly the first shot will be at your crosshair. That's how you make an easy InstantHeadShot.

        In my version the "CountDown" gives you weapon and then warmup end gives ammo in it. In this way your accuracy will be normal.

    LR Pistol ClipBug (Fixed)

        If you had a fully loaded pistol at the beginning of an lr you reloads it even if it's a new pistol.

        In my version the plugin gives you new weapon and if you have more than 0 ammo it removes it, and than the first shooter gets the ammo.

    LR Health Issues (Fixed)

        Some LR let you play with your current HP and it makes the game unfair.

        In my version you got 100hp at the beginning.

    LR End (Fixed)

        In this version when you win the LR you get 100hp and a knife. (Every other weapon from lr removed).




NOTE: Im so sorry if I left any Hungarian debug text in it. If you find one, please let me know. Im beginner in SourcePawn, but I tried to make everything works whit my C# knowledge...


That's what I got yet. If you have any other issue or question just leave a comment or contact me in steam! 
