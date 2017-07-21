-- config.lua
-- Configuration Options

if not scenario then scenario = {} end
if not scenario.config then scenario.config = {} end

scenario.config.mapsettings = scenario.config.mapsettings or {}

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------
scenario.config.joinedMessages = {
    "Welcome to jvmguy's server.",
    "In the current game mode, a satellite must be launched from the rocket silo in the center to win!",
    "Mods Enabled: Separate Spawns, RSO, Long-Reach, Autofill",
    "",
    "Look in the car at your spawn for fast start items.",
    "The car is also your personal transport to and from the silo.",
}

WELCOME_MSG_TITLE = "Welcome to Jvmguy's Server"

scenario.config.welcomeMessages = {
    "This scenario is a variant of a scenario created by Oarc",
    "",
    "Rules: Be polite. Ask before changing other players's stuff. Have fun!",
    "This server is running a custom scenario that changes spawn locations.",
    "",
    "/w Due to the way this scenario works, it may take some time for the land",
    "/w around your new spawn area to generate...",
    "/w Please wait for 10-20 seconds when you select your first spawn.",
    "",
    "/w Biter expansion is on, so watch out!",
    "",
    "Good Luck!",
    
    "Oarc contact: SteamID:Oarc | Twitter:@_Oarc_ | oarcinae@gmail.com",
    "jvmguy contact: SteamID:jvmguy | Discord:@jvmguy | jvmguy@gmail.com",
}

scenario.config.startKit = {
        {name = "power-armor", count = 1},
        {name = "fusion-reactor-equipment", count=1},
        {name = "exoskeleton-equipment", count=1},
        {name = "personal-roboport-mk2-equipment", count=2},
        {name = "construction-robot", count = 50},
        {name = "night-vision-equipment", count = 1},
        {name = "steel-axe", count = 5},
        {name = "roboport", count = 3},
        {name = "logistic-chest-storage", count = 3},
        {name = "battery-mk2-equipment", count=3},
}

scenario.config.teleporter = {
    enabled = true,
    -- where in the spawn to place the teleporter 
    spawnPosition = { x=2, y=0 },
    -- where in the silo chunk to place the teleporter
    siloPosition = { x=0, y=0 },
    
    startItems = {
        {name= "coal", count=100},
        {name= "stone-furnace", count=12},
        {name= "burner-mining-drill", count=12},
--        {name = "offshore-pump", count = 1},
--        {name = "boiler", count = 10},
--        {name = "steam-engine", count = 20},
--        {name = "pipe", count=5},
--        {name = "pipe-to-ground", count=2},
--        {name = "electric-mining-drill", count = 50},
--        {name = "small-electric-pole", count = 50},
--        {name = "transport-belt", count=400},
--        {name = "inserter", count=100},
    }
}

SPAWN_MSG1 = "Current Spawn Mode: HARDCORE WILDERNESS"
SPAWN_MSG2 = "In this mode, there is no default spawn. Everyone starts in the wild!"
SPAWN_MSG3 = "Resources are spread out far apart but are quite rich."

--------------------------------------------------------------------------------
-- Module Enables
-- These enables are not fully tested! For example, disable separate spawns
-- will probably break the frontier rocket silo mode
--------------------------------------------------------------------------------

-- Frontier style rocket silo mode
FRONTIER_ROCKET_SILO_MODE = true

-- put players on a special surface until they've chosen
ENABLE_SPAWN_SURFACE = true

-- Separate spawns
ENABLE_SEPARATE_SPAWNS = true

ENABLE_GOOD_STARTER_ITEMS = false
ENABLE_BETTER_STARTER_ITEMS = false
ENABLE_BEST_STARTER_ITEMS = false
ENABLE_LOGISTIC_STARTER_ITEMS = false

ENABLE_BLUEPRINT_FROM_START = false
ENABLE_ALL_RESEARCH_DONE = false

-- Enable Scenario version of RSO
ENABLE_RSO = true

-- Enable Gravestone Chests
ENABLE_GRAVESTONE_CHESTS = false

-- Enable Undecorator
ENABLE_UNDECORATOR = true

-- enable player time/position status
ENABLE_STATUS = true

-- Enable Tags
ENABLE_TAGS = true

-- Enable Long Reach
ENABLE_LONGREACH = true

-- Enable Autofill
ENABLE_AUTOFILL = true

-- Enable BPS
ENABLE_BLUEPRINT_STRING = false

--------------------------------------------------------------------------------
-- Spawn Options
--------------------------------------------------------------------------------
ENABLE_CROP_OCTAGON=true
---------------------------------------
-- Distance Options
---------------------------------------
-- Near Distance in chunks
NEAR_MIN_DIST = 25 --50
NEAR_MAX_DIST = 100 --125
                   --
-- Far Distance in chunks
FAR_MIN_DIST = 100 --50
FAR_MAX_DIST = 200 --125
                   --
---------------------------------------
-- Resource Options
---------------------------------------
-- everyone gets a separate start area
scenario.config.separateSpawns = {
--    enabled = true,
--
--    shape = "octagon",
--    treeDensity = 0.2,

    -- if we use fermat spirals 
    --     nearest base is sqrt(36)*spacing = 6000
    --     most distant base is sqrt(36+28)*spacing = 8000
    firstSpawnPoint = 24,
    numSpawnPoints = 42,
    spacing = 900,
    
    resources = {
        { shape="rect", type="stone", x=-25, y=-31, size=8, aspectRatio=2.0, amount=1500,  },
        { shape="rect", type="coal", x=-27, dy=11, size=10, aspectRatio=2.0, amount=2000,  },
        { shape="rect", type="copper-ore", x=-29, dy=13, size=12, aspectRatio=2.0, amount=2000,  },
        { shape="rect", type="iron-ore", x=-31, dy=15, size=16, aspectRatio=2.0, amount=2000,  },
        
        { shape="rect", type="crude-oil", x=-40, y=-5, size=1, amount=1000000,  },
        { shape="rect", type="crude-oil", dy=5, size=1, amount=1000000,  },
        { shape="rect", type="crude-oil", dy=5, size=1, amount=1000000,  },
        
        { shape="rect", type="uranium-ore", x=16, y=-31, size=8, aspectRatio=2.0, amount=1500,  },
    },
}


SPAWN_TREE_DENSITY = 0.2


-- Force the land area circle at the spawn to be fully grass
ENABLE_SPAWN_FORCE_GRASS = true

---------------------------------------
-- Safe Spawn Area Options
---------------------------------------

-- Safe area has no aliens
-- +/- this in x and y direction
SAFE_AREA_TILE_DIST = CHUNK_SIZE*12

-- Warning area has reduced aliens
-- +/- this in x and y direction
WARNING_AREA_TILE_DIST = CHUNK_SIZE*14

-- 1 : X (spawners alive : spawners destroyed) in this area
WARN_AREA_REDUCTION_RATIO = 15

-- Create a circle of land area for the spawn
ENFORCE_LAND_AREA_TILE_DIST = 48

---------------------------------------
-- Other Forces/Teams Options
---------------------------------------

-- I am not currently implementing other teams. It gets too complicated.
-- Enable if people can join their own teams
-- ENABLE_OTHER_TEAMS = false

-- Main force is what default players join
MAIN_FORCE = "main_force"

-- Enable if people can spawn at the main base
ENABLE_DEFAULT_SPAWN = false

-- Enable if people can allow others to join their base
ENABLE_SHARED_SPAWNS = true
MAX_ONLINE_PLAYERS_AT_SHARED_SPAWN = 2


---------------------------------------
-- Special Action Cooldowns
---------------------------------------
RESPAWN_COOLDOWN_IN_MINUTES = 15
RESPAWN_COOLDOWN_TICKS = TICKS_PER_MINUTE * RESPAWN_COOLDOWN_IN_MINUTES

-- Require playes to be online for at least 5 minutes
-- Else their character is removed and their spawn point is freed up for use
MIN_ONLIME_TIME_IN_MINUTES = 11
MIN_ONLINE_TIME = TICKS_PER_MINUTE * MIN_ONLIME_TIME_IN_MINUTES


-- Allow players to choose another spawn in the first 10 minutes
-- This does not allow creating a new spawn point. Only joining other players.
-- SPAWN_CHANGE_GRACE_PERIOD_IN_MINUTES = 10
-- SPAWN_GRACE_TIME = TICKS_PER_MINUTE * SPAWN_CHANGE_GRACE_PERIOD_IN_MINUTES


--------------------------------------------------------------------------------
-- Alien Options
--------------------------------------------------------------------------------

-- Enable/Disable enemy expansion
ENEMY_EXPANSION = true

-- Divide the alien factors by this number to reduce it (or multiply if < 1)
ENEMY_POLLUTION_FACTOR_DIVISOR = 3
ENEMY_DESTROY_FACTOR_DIVISOR = 3

--------------------------------------------------------------------------------
-- Frontier Rocket Silo Options
--------------------------------------------------------------------------------

-- SILO_DISTANCE = 4 * HEXSPACING
SILO_DISTANCE = CHUNK_SIZE      -- put the silo 1 chunk east of the origin (prevents problems)
SILO_CHUNK_DISTANCE_X = math.floor(SILO_DISTANCE/CHUNK_SIZE);
SILO_DISTANCE_X = math.floor(SILO_DISTANCE/CHUNK_SIZE)* CHUNK_SIZE + CHUNK_SIZE/2
SILO_DISTANCE_Y = CHUNK_SIZE/2

-- Should be in the middle of a chunk
SILO_POSITION = {x = SILO_DISTANCE_X, y = SILO_DISTANCE_Y}

-- If this is enabled, the static position is ignored.
ENABLE_RANDOM_SILO_POSITION = false

--------------------------------------------------------------------------------
-- Long Reach Options
--------------------------------------------------------------------------------

BUILD_DIST_BONUS = 15
REACH_DIST_BONUS = BUILD_DIST_BONUS
RESOURCE_DIST_BONUS = 2

--------------------------------------------------------------------------------
-- Autofill Options
--------------------------------------------------------------------------------

AUTOFILL_TURRET_AMMO_QUANTITY = 10

--------------------------------------------------------------------------------
-- Use rso_config and rso_resourece_config for RSO config settings
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DEBUG
--------------------------------------------------------------------------------

-- DEBUG prints for me
global.oarcDebugEnabled = false
global.jvmguyDebugEnabled = false
