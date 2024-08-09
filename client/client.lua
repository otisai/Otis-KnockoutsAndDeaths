------
-- Otis' Death and Knockout Script
-- client.lua - Client-side functionality.
------

------
-- Variables
-- Global variables have "ODKO" (Otis' Death and Knockouts) prepended to them to
-- avoid conflicts with other scripts that may have conflicting variable names.
------
ODKO_isDead = false
ODKO_isDown = false
ODKO_isKnockedOut = false

------
-- Handler - Remove automatic respawning so that we can add in our own logic.
-- @todo - Maybe disable AutoSpawn only on player death? Will help avoid
-- conflict with any other scripts that spawn players.
------
AddEventHandler("onClientMapStart", function()
    if Config.Deaths then
        Citizen.Trace("otis-deathko: Map started, spawning player and disabling AutoSpawn...\n")
        exports.spawnmanager:spawnPlayer()
        Citizen.Wait(2500)
        exports.spawnmanager:setAutoSpawn(false)
        Citizen.Trace("otis-deathko: Player spawned, AutoSpawn disabled... good to go!\n")
    end
end)

------
-- Listener for player death.
-- This method listens for the game event "CEventNetworkEntityDamage" and
-- checks to see if the victim is the player. If so, it will run through
-- more logic and perform death handling and other methods.
------
AddEventHandler("gameEventTriggered", function(eventName, eventArgs)
    if eventName == "CEventNetworkEntityDamage" then
        local player = PlayerPedId()
        local victim = eventArgs[1]
        local weaponHash = eventArgs[7]
        local isVictimDead = IsEntityDead(victim) -- Could use eventArgs instead

        -- Clear timecycles upon death JIC the player is knocked out
        if not Config.Deaths and player == victim and isVictimDead and ODKO_isKnockedOut then
            ClearTimecycleModifier()
            ClearExtraTimecycleModifier()
        -- If deaths are enabled, player is the victim, player is dead, and their death has not already been handled
        elseif Config.Deaths and player == victim and isVictimDead and not ODKO_isDead then
            Citizen.Trace("otis-deathko: Fatal damage detected. Handling death...\n")
            HandlePlayerDeath(player)
        -- Yeah... 
        elseif Config.Knockouts and player == victim and IsWeaponABluntWeapon(weaponHash) and GetEntityHealth(victim) < Config.KnockedOutHealth and not isVictimDead and not ODKO_isKnockedOut then -- Holy shit don't say anything about this PLEASE
            Citizen.Trace("otis-deathko: Knockout!\n")
            HandlePlayerKnockout(player)
        -- If the player is the victim and they aren't dead but they are down and not knocked out
        elseif player == victim and not isVictimDead and ODKO_isDown and not ODKO_isKnockedOut and not ODKO_isDead then -- This just keeps them in a downed state even if they are ragdolled or shot
            DownPlayer()
        end
    end
end)

------
-- Commands & Events
------
Citizen.CreateThread(function()
    TriggerEvent("chat:addSuggestion", "/revive", "Revive yourself if dead. You will revive in place and go into a downed state. Get up by pressing X.")
    TriggerEvent("chat:addSuggestion", "/r", "Revive yourself if dead. You will revive in place and go into a downed state. Get up by pressing X.")
    TriggerEvent("chat:addSuggestion", "/down", "Go into a downed state. Get up by pressing X.")
    TriggerEvent("chat:addSuggestion", "/getup", "Get up from being down.")
    TriggerEvent("chat:addSuggestion", "/respawn", "Respawn at the nearest hospital if dead or down.")

    RegisterKeyMapping("getup", "Get Up from being down. Shortcut: X", "keyboard", "X")
end)

RegisterCommand("revive", function(source, args, raw)
    if ODKO_isDead then
        RevivePlayer()
        DownPlayer()
    end
end)

RegisterCommand("r", function(source, args, raw)
    if ODKO_isDead then
        RevivePlayer()
        DownPlayer()
    end
end)

RegisterCommand("down", function(source, args, raw)
    if not OKDO_isDead and not ODKO_isDown then
        DownPlayer()
    end
end)

RegisterCommand("getup", function(source, args, raw)
    if ODKO_isDown then
        GetPlayerUp()
    end
end)

RegisterCommand("respawn", function(source, args, raw)
    if ODKO_isDown or ODKO_isDead then
        RespawnPlayer()
    end
end)