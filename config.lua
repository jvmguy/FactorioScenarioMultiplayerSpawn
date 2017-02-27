-- config.lua
-- Configuration Options

if not scenario then scenario = {} end
if not scenario.config then scenario.config = {} end

scenario.config.mapsettings = scenario.config.mapsettings or {}

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------

WELCOME_MSG = "Welcome to jvmguy's server."
GAME_MODE_MSG = "In the current game mode, a satellite must be launched from the rocket silo in the center to win!"
-- GAME_MODE_MSG = "The current game mode is just basic vanilla!"
MODULES_ENABLED = "Mods Enabled: Separate Spawns, RSO, Gravestone Chests, Long-Reach, Autofill"
-- MODULES_ENABLED = "Mods Enabled: Gravestone-Chests"

-- WELCOME_MSG_TITLE = "[INSERT SERVER OWNER MSG HERE!]"
-- WELCOME_MSG_TITLE = "Welcome to Oarc's Server"
WELCOME_MSG_TITLE = "Welcome to Jvmguy's Server"

WELCOME_MSG0 = "This scenario is a variant of a scenario created by Oarc"
WELCOME_MSG1 = "Rules: Be polite. Ask before changing other players's stuff. Have fun!"
WELCOME_MSG2 = "This server is running a custom scenario that changes spawn locations."
WELCOME_MSG3 = "Due to the way this scenario works, it may take some time for the land"
WELCOME_MSG4 = "around your new spawn area to generate..."
WELCOME_MSG5 = "Please wait for 10-20 seconds when you select your first spawn."
WELCOME_MSG6 = "Oarc contact: SteamID:Oarc | Twitter:@_Oarc_ | oarcinae@gmail.com"
WELCOME_MSG7 = "jvmguy contact: SteamID:jvmguy | Discorc:@jvmguy | jvmgiu@gmail.com"


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

-- Separate spawns
ENABLE_SEPARATE_SPAWNS = true

ENABLE_GOOD_STARTER_ITEMS = false
ENABLE_BETTER_STARTER_ITEMS = false
ENABLE_BEST_STARTER_ITEMS = false

ENABLE_BLUEPRINT_FROM_START = false

-- Enable Scenario version of RSO
ENABLE_RSO = true

-- Enable Gravestone Chests
ENABLE_GRAVESTONE_CHESTS = true

-- Enable Undecorator
ENABLE_UNDECORATOR = true

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

-- Start resource amounts
START_IRON_AMOUNT = 1800
START_COPPER_AMOUNT = 1800
START_STONE_AMOUNT = 1800
START_COAL_AMOUNT = 1800
START_OIL_AMOUNT = 20000

SPAWN_TREE_DENSITY = 0.2

-- Stat resource shape
-- If this is true, it will be a circle or an ellipse
-- If false, it will be a square
ENABLE_RESOURCE_SHAPE_CIRCLE = true
ELLIPSE_X_STRETCH=2.0	-- stretch the size horizontally (make it an ellipse)

-- Start resource position and size
-- Position is relative to player starting location

START_RESOURCE_STONE_POS_X = -25
START_RESOURCE_STONE_POS_Y = -31
START_RESOURCE_STONE_SIZE = 8

START_RESOURCE_COAL_POS_X = -25
START_RESOURCE_COAL_POS_Y = -16
START_RESOURCE_COAL_SIZE = 10

START_RESOURCE_COPPER_POS_X = -25
START_RESOURCE_COPPER_POS_Y = 0
START_RESOURCE_COPPER_SIZE = 12

START_RESOURCE_IRON_POS_X = -25
START_RESOURCE_IRON_POS_Y = 15
START_RESOURCE_IRON_SIZE = 14

START_RESOURCE_OIL_POS_X = 20
START_RESOURCE_OIL_POS_Y = -36

START_RESOURCE_OIL_POS2_X = 24
START_RESOURCE_OIL_POS2_Y = -36

---------------------------------------
-- We override the vertical position to give uniform spacing here. comment out to 
---------------------------------------
RESOURCE_SEPARATION = 3

if RESOURCE_SEPARATION ~= nil then
	START_RESOURCE_COAL_POS_Y = START_RESOURCE_STONE_POS_Y + START_RESOURCE_STONE_SIZE + RESOURCE_SEPARATION
	START_RESOURCE_COPPER_POS_Y = START_RESOURCE_COAL_POS_Y + START_RESOURCE_COAL_SIZE + RESOURCE_SEPARATION
	START_RESOURCE_IRON_POS_Y = START_RESOURCE_COPPER_POS_Y + START_RESOURCE_COPPER_SIZE + RESOURCE_SEPARATION
end
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

HEXSPACING = 1800 -- distance between spawns (tiles)

HEXFIRSTRING = 3  -- number of rings of start spawns
HEXRINGS = 4  -- number of rings of start spawns
HEX_FAR_SPACING = HEXSPACING * HEXFIRSTRING -- the outermost 2 rings



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
MAX_ONLINE_PLAYERS_AT_SHARED_SPAWN = 3


---------------------------------------
-- Special Action Cooldowns
---------------------------------------
RESPAWN_COOLDOWN_IN_MINUTES = 15
RESPAWN_COOLDOWN_TICKS = TICKS_PER_MINUTE * RESPAWN_COOLDOWN_IN_MINUTES

-- Require playes to be online for at least 5 minutes
-- Else their character is removed and their spawn point is freed up for use
MIN_ONLIME_TIME_IN_MINUTES = 5
MIN_ONLINE_TIME = TICKS_PER_MINUTE * MIN_ONLIME_TIME_IN_MINUTES


-- Allow players to choose another spawn in the first 10 minutes
-- This does not allow creating a new spawn point. Only joining other players.
-- SPAWN_CHANGE_GRACE_PERIOD_IN_MINUTES = 10
-- SPAWN_GRACE_TIME = TICKS_PER_MINUTE * SPAWN_CHANGE_GRACE_PERIOD_IN_MINUTES


--------------------------------------------------------------------------------
-- Alien Options
--------------------------------------------------------------------------------

-- Enable/Disable enemy expansion
ENEMY_EXPANSION = false

-- Divide the alien factors by this number to reduce it (or multiply if < 1)
ENEMY_POLLUTION_FACTOR_DIVISOR = 8
ENEMY_DESTROY_FACTOR_DIVISOR = 8


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

BUILD_DIST_BONUS = 14
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
