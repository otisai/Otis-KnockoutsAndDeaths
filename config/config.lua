------
-- Otis' Death and Knockout Script
-- config.lua - All important configurations.
------

--- Main configuration table
-- @table config
Config = {}

------
-- Base configuration values. You MAY change these if you desire.
-- All defaults are recommended.
------

--- Boolean indicating whether or not to handle player deaths.
-- Default: True
Config.Deaths = true

--- Boolean indicating whether or not players can be knocked out.
-- Default: true
Config.Knockouts = true

--- String indicating the animation set to use after a player wakes up from being KOd.
-- Default: "MOVE_M@DRUNK@SLIGHTLYDRUNK"
Config.KnockoutAnimationSet = "MOVE_M@DRUNK@SLIGHTLYDRUNK"

--- Integer indicating how low the player's health must be to be considered "knocked out."
-- Default: 145; Max Health: 200
Config.KnockedOutHealth = 145

--- Integer indicating how long the player will remain on the ground when knocked out.
-- Default: 30000
Config.KnockedOutDuration = 30000

--- Integer indicating how long it will take for the player's walk to return to normal.
-- Default: 60000
Config.KnockedOutResetDuration = 60000

------
-- Advanced configuration values. It is highly recommended to avoid changing these unless you
-- know what you are doing. You HAVE been warned.
------

--- Table including a list of death animations. Organized by {dictionary, animation}
Config.DeathAnimations = {
    {dict = "dead", animation = "dead_a"},
    {dict = "dead", animation = "dead_b"},
    {dict = "dead", animation = "dead_c"},
    {dict = "dead", animation = "dead_d"},
    {dict = "dead", animation = "dead_e"},
    -- {dict = "dead", animation = "dead_f"}, -- Handcuffed death pose. Feel free to uncomment.
    {dict = "dead", animation = "dead_g"},
    {dict = "missarmenian2", animation = "drunk_loop"},
    {dict = "missarmenian2", animation = "corpse_search_exit_ped"},
    {dict = "anim@gangops@morgue@table@", animation = "body_search"},
    {dict = "mini@cpr@char_b@cpr_def", animation = "cpr_pumpchest_idle"},
    {dict = "random@mugging4", animation = "flee_backward_loop_shopkeeper"},
}

-- Blunt Weapons - A table used to determine whether a player has been hit by a blunt weapon.
-- The table contains lists of all blunt weapons and their hash keys.
Config.BluntWeapons = {
    GetHashKey("WEAPON_BAT"), --  Baton
    GetHashKey("WEAPON_CROWBAR"), -- Crowbar
    GetHashKey("WEAPON_UNARMED"), -- Unarmed
    GetHashKey("WEAPON_FLASHLIGHT"), -- Flashlight
    GetHashKey("WEAPON_GOLFCLUB"), -- Golf Club
    GetHashKey("WEAPON_HAMMER"), -- Hammer
    GetHashKey("WEAPON_KNUCKLE"), -- Brass Knuckles
    GetHashKey("WEAPON_NIGHTSTICK"), -- Nightstick
    GetHashKey("WEAPON_WRENCH"), -- Wrench
    GetHashKey("WEAPON_POOLCUE"), -- Pool Cue
    GetHashKey("WEAPON_RUN_OVER_BY_CAR"), -- Hit by Car
    GetHashKey("WEAPON_FALL"), -- Fall Damage
    GetHashKey("WEAPON_HIT_BY_WATER_CANNON"), -- Fire Truck and other Water Cannons (yes you can be knocked out by this :D)
    GetHashKey("WEAPON_RAMMED_BY_CAR"), -- Rammed by Car
}

-- Hospital Locations - A tables used to show the coordinates of all hospitals in San Andreas.
-- The table contains a list of the coordinates of all hospitals, and the headings of the spawnpoints.
Config.HospitalLocations = {
    {x = 338.85, y = -1394.56, z = 32.51, heading = 48.5},   -- Central Los Santos Medical Center
    {x = 1839.6, y = 3672.93, z = 34.28, heading = 206.5},   -- Sandy Shores Medical Center
    {x = -247.76, y = 6331.23, z = 32.43, heading = 340.0},  -- Paleto Bay Medical Center
    {x = -449.67, y = -340.83, z = 34.5, heading = 80.0},    -- Mount Zonah Medical Center
    {x = 298.89, y = -584.72, z = 43.26, heading = 70.0},    -- Pillbox Hill Medical Center
    {x = -874.64, y = -307.71, z = 39.58, heading = 357.0},  -- Eclipse Medical Tower
    {x = 1151.21, y = -1529.62, z = 34.84, heading = 35.0},  -- St. Fiacre Hospital
    {x = -676.98, y = 310.68, z = 83.08, heading = 167.0},   -- Rockford Hills Medical Center
}

