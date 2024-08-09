------
-- Otis' Death and Knockouts Script
-- client/functions.lua - All important client-side helper functions.
------

------
-- Handle's a player's death by showing a black screen and playing an audio through NUI.
--
-- This method takes in an entity as an argument and handles their death, assuming
-- the logic to determine if they are already dead has been performed. If so, their 
-- screen turns black for a moment and a sound plays. 
--
-- @param entity - The entity to handle
-- @return none
------
function HandlePlayerDeath(entity)
    ODKO_isKnockedOut = false -- Set global
    ODKO_isDead = true -- Set global

    DoScreenFadeOut(50) -- Turn screen black quickly

    SendNUIMessage({ -- Play the death sound
        type = "playSound",
        file = "flatline",
        audioVolume = 2.0
    }) 

    Wait(3000) -- Wait 2.5 seconds while sound plays

    ClearTimecycleModifier() -- Just in case they are knocked out prior to dying
    ClearExtraTimecycleModifier() -- Just in case they are knocked out prior to dying

    DoScreenFadeIn(2000) -- Fade the screen in
end

------
-- Handle's a player's knockout by applying a filter and playing an audio through NUI.
--
-- This method takes in an entity as an argument and handles their knockout, assuming
-- the logic to determine if they are already knocked out has been performed. If so, there 
-- is a filter for a moment and a sound plays. 
--
-- @todo - Add audio filter? We will see.
--
-- @param entity - The entity to handle
-- @return none
------
function HandlePlayerKnockout(entity)
    ODKO_isKnockedOut = true -- Set global

    RequestAnimSet(Config.KnockoutAnimationSet) -- Queue requesting the knockout walk

    DoScreenFadeOut(10) -- Fade screen out

    SetTimecycleModifier("Bloom") -- TCM
    SetExtraTimecycleModifier("PlayerWakeUp") -- TCM
    SetTimecycleModifierStrength(2.0) -- TCMS

    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 2.5) -- Shake cam

    SendNUIMessage({ -- Play ears ringing sound
        type = "playSound",
        file = "tinnitus",
        audioVolume = 1.0
    })

    while not IsScreenFadedOut() do -- Make sure screen is faded out before fading in
        Wait(10)
    end

    while IsPedRagdoll(entity) do -- This prevents the player from getting up after being hit from a car and being knocked out
        Wait(10)
    end
    
    SetPedToRagdoll(entity, Config.KnockedOutDuration, Config.KnockedOutDuration, 0, 0, 0, 0) -- Ragdoll for configured time

    DoScreenFadeIn(3000) -- Fade screen in

    Citizen.SetTimeout(Config.KnockedOutDuration, function() -- Timeout to make sure things are set
        ClearTimecycleModifier()
        ClearExtraTimecycleModifier()
        ODKO_isKnockedOut = false
        SetPedMovementClipset(entity, Config.KnockoutAnimationSet, 1)
        RemoveAnimSet(Config.KnockoutAnimationSet)
    end)

    Citizen.SetTimeout(Config.KnockedOutResetDuration, function() -- Timeout to reset effects
        ResetPedMovementClipset(entity, 1)
    end)
end

------
-- Revives a player.
--
-- This method gets the player's ped ID and revives them in place using the 
-- NetworkResurrectLocalPlayer native. This method is commonly called by the main game event
-- handler when the /revive or /r commands are executed.
--
-- @return none
------
function RevivePlayer() -- https://github.com/Andyyy7666/DeathSystem/blob/main/functions.lua
    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player)

    ODKO_isDead = false -- Set global
    ODKO_isKnockedOut = false -- Rare bug
    SetEnableHandcuffs(player, false) -- JIC they are handcuffed. Some conflicting scripts cuff on death.
    SetPlayerInvisibleLocally(player, true) -- Make them invisible
    Wait(300) -- Wait 300ms to make sure they are invisible
    ClearPedTasks(player) -- Clear all animations JIC they are playing one
    SetPlayerInvisibleLocally(player, false) -- Make them visible
    SetEntityCoordsNoOffset(player, playerCoords.x, playerCoords.y, playerCoords.z, false, false, true) -- Set their coords @todo - possibly redundant
    NetworkResurrectLocalPlayer(playerCoords.x, playerCoords.y, playerCoords.z, GetEntityHeading(player), 0, false) -- Revive player at current coordinates and heading
    SetEntityHealth(player, GetEntityMaxHealth(player)) -- Set the player's health to max
end

------
-- Puts a player into a downed state.
--
-- This method gets the player's ped ID and selects a random death animation from the config.lua.
-- It will then request the clip dictionary and play it until the player cancels it by using
-- /getup or its respective bind.
--
-- @return none
------
function DownPlayer()
    local player = PlayerPedId()
    local deathAnim = GetRandomDeathAnimation()

    ODKO_isDown = true -- Set global
    LoadAnimationDictionary(deathAnim.dict) -- Load dict
    TaskPlayAnim(player, deathAnim.dict, deathAnim.animation, 1.0, 1.0, -1, 1, 0, 0, 0, 0) -- Play anim
    RemoveAnimDict(deathAnim.dict) -- Free the memory
end

------
-- Respawns the player at the nearest hospital.
--
-- This method finds the nearest hospital to the player's current position
-- and moves the player to that location.
--
-- @return none
------
function RespawnPlayer()
    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player)
    local nearestHospital = GetNearestHospital(playerCoords)

    if nearestHospital then
        DoScreenFadeOut(1000) -- Fade screen out

        while not IsScreenFadedOut() do -- Wait until screen is faded out to TP
            Wait(10)
        end

        SetEntityCoordsNoOffset(player, nearestHospital.x, nearestHospital.y, nearestHospital.z, false, false, true) -- TP to nearest Hospital
        SetEntityHeading(player, nearestHospital.heading) -- Set heading

        if ODKO_isDead then
            RevivePlayer()
        elseif ODKO_isDown then
            GetPlayerUp()
        end

        DoScreenFadeIn(2500)
    else
        print("No hospitals available for respawn.")
    end
end

------
-- Gets the player up from a downed state.
--
-- This method gets the player's ped ID and cancels any tasks that they are playing.
-- Since being downed typically plays an animation (task), this is used to cancel.
-- This could probably be done in one line, but I never know when I might need to use
-- this method again.
--
-- @return none
------
function GetPlayerUp()
    local player = PlayerPedId()

    ClearPedTasks(player)
    ODKO_isDown = false
end

------
-- Checks if a weapon is a blunt weapon.
--
-- This method take in a weapon hash and compares it to the weapon hashes in
-- the config file. If it matches, true is returned. If not, false is returned.
--
-- @param hash - The weapon hash to compare.
-- @return boolean - A boolean indicating whether or not the hash is a blunt weapon.
------
function IsWeaponABluntWeapon(hash)
    -- Loop through the blunt weapons list
    for _, bluntWeaponHash in ipairs(Config.BluntWeapons) do
        -- Check if the provided hash matches any in the list
        if hash == bluntWeaponHash then
            return true
        end
    end
    -- If no match is found, return false
    return false
end

------
-- Selects a random death animation.
--
-- This method uses the math lib to randomly select a death animation from
-- the list defined in config.lua.
--
-- @return table - A table containing the selected animation's dict and animation name.
------
function GetRandomDeathAnimation()
    math.randomseed(GetGameTimer()) -- Seed math algo

    local deathAnims = Config.DeathAnimations
    local randomIndex = math.random(#deathAnims)
    local selectedAnim = deathAnims[randomIndex]
    return selectedAnim
end

------
-- Finds the nearest hospital to the given coordinates.
--
-- This method calculates the distance between the provided coordinates and
-- each hospital location, returning the closest one.
--
-- @param coords - The coordinates to find the nearest hospital to.
-- @return table - A table containing the nearest hospital's coordinates and heading.
------
function GetNearestHospital(coords)
    local minDistance = math.huge
    local nearestHospital = nil

    for _, hospital in ipairs(Config.HospitalLocations) do
        local hospitalCoords = vector3(hospital.x, hospital.y, hospital.z)
        local distance = #(coords - hospitalCoords)

        if distance < minDistance then
            minDistance = distance
            nearestHospital = hospital
        end
    end

    return nearestHospital
end

------
-- Loads an Animation Set. Different from loading an animation dictionary.
--
-- This method takes an animation set (commonly walk style) and loads it.
--
-- @param set - The animation set to load.
------
function LoadAnimationSet(set)
    while not HasAnimSetLoaded(set) do
        RequestAnimSet(set)
        Wait(10)
    end
end

------
-- Loads a Clip Dictionary for animations.
--
-- This method takes a clip dictionary (commonly for animations E.g. "missarmenian2") and loads it.
--
-- @param dict - The clip dictionary to load.
------
function LoadAnimationDictionary(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end