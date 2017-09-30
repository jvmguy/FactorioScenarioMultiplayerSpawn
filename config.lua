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
--    "Look in the car at your spawn for fast start items.",
--    "The car is also your personal transport to and from the silo.",
    "Discord chat: https://discord.gg/q6gfYa9",
}

WELCOME_MSG_TITLE = "Welcome to Jvmguy's Server"

scenario.config.welcomeMessages = {
    "This scenario is a variant of a scenario created by Oarc",
    "",
    "Rules: Be polite. Ask before changing other players's stuff. Have fun!",
--    "This server is running a custom scenario that changes spawn locations.",
    "",
--    "/w Due to the way this scenario works, it may take some time for the land",
--    "/w around your new spawn area to generate...",
--    "/w Please wait for 10-20 seconds when you select your first spawn.",
--    "",
--    "/w Biter expansion is on, so watch out!",
    "Discord chat https://discord.gg/q6gfYa9",
    "",
    "Good Luck!",
    
    "Oarc contact: SteamID:Oarc | Twitter:@_Oarc_ | oarcinae@gmail.com",
    "jvmguy contact: SteamID:jvmguy | Discord:@jvmguy | jvmguy@gmail.com",
}

scenario.config.bots = {
    worker_robots_storage_bonus = 5;
    worker_robots_speed_modifier = 1.0,
}

scenario.config.silo = {
    addBeacons = true,
    addPower = true,
}

scenario.config.startKit = {
        {name = "power-armor", count = 1,
            equipment = {
                  -- the order of these does matter.
                  {name = "fusion-reactor-equipment"},
--                  {name = "exoskeleton-equipment"},
--                  {name = "battery-mk2-equipment", count=1},
                  {name = "personal-roboport-mk2-equipment", count=1},
--                  {name = "solar-panel-equipment", count = 7 }
            }
        },
        {name = "belt-immunity-equipment", count = 1},
--        {name = "night-vision-equipment", count = 1},
        {name = "construction-robot", count = 10},
        {name = "steel-axe", count = 5},
        {name = "roboport", count = 1},
        {name = "logistic-chest-storage", count = 1},
		{name = "burner-mining-drill", count = 1},
		{name = "stone-furnace", count = 1},
		{name = "submachine-gun", count=1},
--		{name = "car", count=1},
--		{name = "raw-wood", count=100},
		{name = "firearm-magazine", count=100},
--		{name = "landfill", count=200}
}

scenario.config.mapSettings = {
--    RSO_TERRAIN_SEGMENTATION = "very-low", -- Frequency of water
--    RSO_WATER = "high", -- Size of water patches
    
    -- jvmguy uses these settings sometimes
--    RSO_TERRAIN_SEGMENTATION = "low", -- Frequency of water
--    RSO_WATER = "very-high", -- Size of water patches

    -- jvmguy uses these settings for riverworld
    -- RSO_TERRAIN_SEGMENTATION = "low", -- Frequency of water
    -- RSO_WATER = "very-low", -- Size of water patches
    
    -- jvmguy uses these settings for toxic jungle
    RSO_TERRAIN_SEGMENTATION = "low", -- Frequency of water
    RSO_WATER = "low", -- Size of water patches

    RSO_PEACEFUL = false, -- Peaceful mode for biters/aliens
    RSO_STARTING_AREA = "very-low", -- Does not affect Oarc spawn sizes.
}

scenario.config.teleporter = {
    enabled = false,
    -- where in the spawn to place the teleporter
	spawnPosition = { x=30, y=-23 },

    -- where in the silo chunk to place the teleporter
    -- this should not be 0,0 if there is the possibility that the default spawn will be used
    siloPosition = { x=2, y=0 },
    
    -- where in the silo chunk the teleporter takes you
    -- this should be different than the silo position
    siloTeleportPosition = { x=0, y=0 },
    
    startItems = {
        {name= "coal", count=50},
        {name= "stone-furnace", count=2},
        {name= "burner-mining-drill", count=2},
        {name= "landfill", count=50},
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

-- Enable GUI player list
ENABLE_PLAYER_LIST = true

-- Enable Long Reach
ENABLE_LONGREACH = true

-- Enable Autofill
ENABLE_AUTOFILL = true

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

scenario.config.toxicJungle = {
    enabled = true,
    tree_chance = 0.2
}    
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
    --     nearest base is sqrt(25)*spacing = 5000
    --     most distant base is sqrt(25+42)*spacing = 8000
    preferFar = false,
    firstSpawnPoint = 25,
    numSpawnPoints = 24,
    -- extraSpawn = 120,    -- admin spawn really far away
    spacing = 800,
    
-- x = right, left
-- y = up, down

    land = 58,
    trees = 2,  -- included in the land
    moat = 0,   -- additional to land
    size = 58,  -- should be land + moat
	
	water = { shape="rect", x=-5, y=-50, size=5, aspectRatio=3.0 }, 
	
    resources = {
        { shape="rect", name="steel-chest", x=-5,   y=-17, size=2, aspectRatio=1, contents = { {name = "iron-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=-5,   y=-12, size=2, aspectRatio=1, contents = { {name = "copper-plate", count=4800 } },  },
        { shape="rect", name="steel-chest", x=-5,   y=-8,  size=2, aspectRatio=1, contents = { {name = "coal", count=2400 } }  },
        { shape="rect", name="steel-chest", x=-5,   y=-4,  size=1, aspectRatio=1, contents = { {name = "stone", count=2400 } },  },
    
        { shape="rect", type="coal",         x=-43+14, y=-41, size=18, aspectRatio=1.17, amount=4000,  },
        { shape="rect", type="stone",        x=-43+17, y=-21, size=9,  aspectRatio=2.0,  amount=4000,  },
        { shape="rect", type="copper-ore",   x=-43, y=-10, size=21, aspectRatio=1.7,  amount=4000,  },
        { shape="rect", type="iron-ore",     x=-43, y =12, size=21, aspectRatio=1.7,  amount=4000,  },
        { shape="rect", type="uranium-ore",  x=-43, y= -41+19, size=10, aspectRatio=1.0,  amount=1800,  },
        
        { shape="rect", type="crude-oil", x=-47, y=-3, size=1, amount=1000000,  },
        { shape="rect", type="crude-oil", x=-47, y= 0, size=1, amount=1000000,  },
        { shape="rect", type="crude-oil", x=-47, y= 3, size=1, amount=1000000,  },
        
    },
}

scenario.config.riverworld = {
    -- this mostly inherits the separateSpawns config, but has a few minor differences
    enabled = false,
    firstSpawnPoint = 16,
    -- moat=0,         -- horizontal offset relative to center of spawn
    -- moatWidth=8,    
    spacing = 320,  -- because of "no good reasons" this should be a multiple of 32 (chunk width)
    barrier = 10,	-- width of impenetrable barrier
    rail = 3*512+3,	-- generate a north-south railway starting here
    rail2 = -3*512-32+3, -- generate a north-south railway starting here
    
    -- freeze time of day
    -- you might get night vision at the start, but you have to decide whether it's worth using it.
    -- freezeTime = 0.0,   -- see https://wiki.factorio.com/Game-day
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
ENFORCE_LAND_AREA_TILE_DIST = scenario.config.separateSpawns.size 

---------------------------------------
-- Other Forces/Teams Options
---------------------------------------

-- I am not currently implementing other teams. It gets too complicated.
-- Enable if people can join their own teams
-- ENABLE_OTHER_TEAMS = false

-- Main force is what default players join
MAIN_FORCE = "main_force"
GAME_SURFACE_NAME = "game_surface"

-- Enable if people can spawn at the main base
ENABLE_DEFAULT_SPAWN = false

-- Enable if people can allow others to join their base
ENABLE_SHARED_SPAWNS = true
MAX_ONLINE_PLAYERS_AT_SHARED_SPAWN = 3

---------------------------------------
-- Ghost Time to live
-- 
-- Set this to zero for infinite ghosts
---------------------------------------
GHOST_TIME_TO_LIVE = 10 * TICKS_PER_MINUTE

---------------------------------------
-- Special Action Cooldowns
---------------------------------------
RESPAWN_COOLDOWN_IN_MINUTES = 60
RESPAWN_COOLDOWN_TICKS = TICKS_PER_MINUTE * RESPAWN_COOLDOWN_IN_MINUTES

-- Require playes to be online for at least 15 minutes
-- Else their character is removed and their spawn point is freed up for use
MIN_ONLIME_TIME_IN_MINUTES = 15
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
SILO_DISTANCE = 0     -- put the silo 1 chunk east of the origin (prevents problems)
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
RESOURCE_DIST_BONUS = 3

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
