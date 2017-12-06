-- control.lua
-- Nov 2016

-- Oarc's Separated Spawn Scenario
-- modified by jvmguy. where "I" is used below, that's Oarc, not jvmguy.
-- 
-- I wanted to create a scenario that allows you to spawn in separate locations
-- From there, I ended up adding a bunch of other minor/major features
-- 
-- Credit:
--  RSO mod to RSO author - Orzelek - I contacted him via the forum
--  Tags - Taken from WOGs scenario 
--  Event - Taken from WOGs scenario (looks like original source was 3Ra)
--  Rocket Silo - Taken from Frontier as an idea
--
-- Feel free to re-use anything you want. It would be nice to give me credit
-- if you can.
-- 
-- Follow server info on @_Oarc_


-- To keep the scenario more manageable I have done the following:
--      1. Keep all event calls in control.lua (here)
--      2. Put all config options in config.lua
--      3. Put mods into their own files where possible (RSO has multiple)


-- My Scenario Includes
require("oarc_utils")
require("jvmguy_utils")
require("config")

-- Include Mods
require("rso_control")
require("separate_spawns")
require("separate_spawns_guis")
require("frontier_silo")
require("tag")
require("playerlist_gui")
require("bps")
require("statuscommand")
require("kitcommand")
require("rgcommand")
require("spawnscommand")
toxicJungle = require("ToxicJungle")

-- spawnGenerator = require("FermatSpiralSpawns");
spawnGenerator = require("RiverworldSpawns");

regrow = require("jvm-regrowth");
wipespawn = require("jvm-wipespawn");

function playerNameFromEvent(event)
    return (event.player_index and game.players[event.player_index].name) or "<unknown>"
end

function logInfo(playerName, msg)
    game.write_file("infolog.txt", game.tick .. ": " .. playerName .. ": " .. msg .. "\n", true, 0);
end


--------------------------------------------------------------------------------
-- Rocket Launch Event Code
-- Controls the "win condition"
--------------------------------------------------------------------------------
function RocketLaunchEvent(event)
    local force = event.rocket.force
    
    if event.rocket.get_item_count("satellite") == 0 then
        for index, player in pairs(force.players) do
            player.print("You launched the rocket, but you didn't put a satellite inside.")
        end
        return
    end

    if not global.satellite_sent then
        global.satellite_sent = {}
    end

    if global.satellite_sent[force.name] then
        global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1   
    else
        game.set_game_state{game_finished=true, player_won=true, can_continue=true}
        global.satellite_sent[force.name] = 1
    end
    
    for index, player in pairs(force.players) do
        if player.gui.left.rocket_score then
            player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
        else
            local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption="Score"}
            frame.add{name="rocket_count_label", type = "label", caption={"", "Satellites launched", ":"}}
            frame.add{name="rocket_count", type = "label", caption=tostring(global.satellite_sent[force.name])}
        end
    end
end


--------------------------------------------------------------------------------
-- ALL EVENT HANLDERS ARE HERE IN ONE PLACE!
--------------------------------------------------------------------------------


----------------------------------------
-- On Init - only runs once the first 
--   time the game starts
----------------------------------------
script.on_init(function(event)

    -- Configures the map settings for enemies
    -- This controls evolution growth factors and enemy expansion settings.
    if ENABLE_RSO then
        CreateGameSurface(RSO_MODE)
    else
        CreateGameSurface(VANILLA_MODE)
    end
    
    if spawnGenerator.ConfigureGameSurface then
        spawnGenerator.ConfigureGameSurface()
    end
    
    ConfigureAlienStartingParams()

    if ENABLE_SEPARATE_SPAWNS then
        InitSpawnGlobalsAndForces()
    end

    if ENABLE_RANDOM_SILO_POSITION then
        SetRandomSiloPosition()
    else
        SetFixedSiloPosition()
    end

    if FRONTIER_ROCKET_SILO_MODE then
        ChartRocketSiloArea(game.forces[MAIN_FORCE])
    end

    if scenario.config.research.coalLiquefactionResearched then
        game.forces[MAIN_FORCE].technologies['coal-liquefaction'].researched=true;
    end
    
    if ENABLE_ALL_RESEARCH_DONE then
        game.forces[MAIN_FORCE].research_all_technologies()
    end

    if scenario.config.wipespawn.enabled then
        wipespawn.init()
    elseif scenario.config.regrow.enabled then
        regrow.init()
    end
    
end)

----------------------------------------
-- Freeplay rocket launch info
-- Slightly modified for my purposes
----------------------------------------
script.on_event(defines.events.on_rocket_launched, function(event)
    if FRONTIER_ROCKET_SILO_MODE then
        RocketLaunchEvent(event)
    end
end)


----------------------------------------
-- Chunk Generation
----------------------------------------
script.on_event(defines.events.on_chunk_generated, function(event)
    local shouldGenerateResources = true
    if scenario.config.wipespawn.enabled then
        wipespawn.onChunkGenerated(event)
    elseif scenario.config.regrow.enabled then
        shouldGenerateResources = regrow.shouldGenerateResources(event);
        regrow.onChunkGenerated(event)
    end
    if ENABLE_UNDECORATOR then
        UndecorateOnChunkGenerate(event)
    end
    
    if scenario.config.riverworld.enabled then
        spawnGenerator.ChunkGenerated(event);
    end

    if scenario.config.toxicJungle.enabled then
        toxicJungle.ChunkGenerated(event);
    end    

    if scenario.config.riverworld.enabled then
        spawnGenerator.ChunkGenerated(event);
    end

    if ENABLE_RSO then
        if shouldGenerateResources then
            RSO_ChunkGenerated(event)
        end
    end

    if FRONTIER_ROCKET_SILO_MODE then
        GenerateRocketSiloChunk(event)
    end

    -- This MUST come after RSO generation!
    if ENABLE_SEPARATE_SPAWNS then
        SeparateSpawnsGenerateChunk(event)
    end
    
    if scenario.config.regrow.enabled then
        regrow.afterResourceGeneration(event)
    end
end)

----------------------------------------
-- Gui Click
----------------------------------------
script.on_event(defines.events.on_gui_click, function(event)
    if ENABLE_TAGS then
        TagGuiClick(event)
    end

    if ENABLE_PLAYER_LIST then
        PlayerListGuiClick(event)
    end

    if ENABLE_SEPARATE_SPAWNS then
        WelcomeTextGuiClick(event)
        SpawnOptsGuiClick(event)
        SpawnCtrlGuiClick(event)
        SharedSpwnOptsGuiClick(event)
    end

end)


----------------------------------------
-- Player Events
----------------------------------------
script.on_event(defines.events.on_player_joined_game, function(event)
    logInfo( playerNameFromEvent(event), "+++ player joined game" );
    
    PlayerJoinedMessages(event)

    if ENABLE_TAGS then
        CreateTagGui(event)
    end

    if ENABLE_PLAYER_LIST then
        CreatePlayerListGui(event)
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    logInfo( playerNameFromEvent(event), "+++ player created" );
    if ENABLE_SPAWN_SURFACE then
        AssignPlayerToStartSurface(game.players[event.player_index])
    end
--    if ENABLE_RSO then
--      RSO_PlayerCreated(event)
--  end

    if ENABLE_LONGREACH then
        GivePlayerLongReach(game.players[event.player_index])
    end

    GivePlayerBonuses(game.players[event.player_index])

    if not ENABLE_SEPARATE_SPAWNS then
        PlayerSpawnItems(event)
    else
        SeparateSpawnsPlayerCreated(event)
    end

    -- Not sure if this should be here or in player joined....
    if ENABLE_BLUEPRINT_STRING then
        bps_player_joined(event)
    end
end)

script.on_event(defines.events.on_player_died, function(event)
    logInfo( playerNameFromEvent(event), "+++ player died" );
    if ENABLE_GRAVESTONE_CHESTS then
        CreateGravestoneChestsOnDeath(event)
    end
end)

script.on_event(defines.events.on_player_respawned, function(event)
    logInfo( playerNameFromEvent(event), "+++ player respawned" );
    if not ENABLE_SEPARATE_SPAWNS then
        PlayerRespawnItems(event)
    else 
        SeparateSpawnsPlayerRespawned(event)
    end

    if ENABLE_LONGREACH then
        GivePlayerLongReach(game.players[event.player_index])
    end
    GivePlayerBonuses(game.players[event.player_index])
end)

script.on_event(defines.events.on_player_left_game, function(event)
    logInfo( playerNameFromEvent(event), "+++ player left game" );
    if ENABLE_SEPARATE_SPAWNS then
        FindUnusedSpawns(event)
    end
end)

script.on_event(defines.events.on_built_entity, function(event)
    if ENABLE_AUTOFILL then
        Autofill(event)
    end

    if scenario.config.regrow.enabled then
        regrow.onBuiltEntity(event);
    end

    local type = event.created_entity.type    
    if type == "entity-ghost" or type == "tile-ghost" or type == "item-request-proxy" then
        if GHOST_TIME_TO_LIVE ~= 0 then
            event.created_entity.time_to_live = GHOST_TIME_TO_LIVE
        end
    end
end)

script.on_event(defines.events.on_tick, function(event)
    if scenario.config.wipespawn.enabled then
        wipespawn.onTick(event)
    elseif scenario.config.regrow.enabled then
        regrow.onTick(event)
    end
end)

if scenario.config.teleporter.enabled then
    script.on_event(defines.events.on_player_driving_changed_state, function(event)
        local player = game.players[event.player_index];
        TeleportPlayer(player)
    end)
end

----------------------------------------
-- On Research Finished
----------------------------------------
script.on_event(defines.events.on_research_finished, function(event)
    if FRONTIER_ROCKET_SILO_MODE then
        RemoveRocketSiloRecipe(event)
    end

    if ENABLE_BLUEPRINT_STRING then
        bps_on_research_finished(event)
    end

    -- Example of how to remove a particular recipe:
    -- RemoveRecipe(event, "beacon")
end)

if scenario.config.regrow.enabled then
    script.on_event(defines.events.on_sector_scanned, function (event)
        regrow.onSectorScan(event)
    end)

    script.on_event(defines.events.on_robot_built_entity, function (event)
        regrow.onRobotBuiltEntity(event)
    end)

    script.on_event(defines.events.on_player_mined_entity, function(event)
        regrow.onPlayerMinedEntity(event)
    end)
    
    script.on_event(defines.events.on_robot_mined_entity, function(event)
        regrow.onRobotMinedEntity(event)
    end)

end

script.on_event(defines.events.on_console_chat, function (event)
    logInfo( playerNameFromEvent(event), event.message );
end)
----------------------------------------
-- BPS Specific Event
----------------------------------------
--script.on_event(defines.events.on_robot_built_entity, function(event)
--end)

-- debug code from Mylon to detect possible causes for desync
--Time for the debug code.  If any (not global.) globals are written to at this point, an error will be thrown.
--eg, x = 2 will throw an error because it's not global.x or local x
if false then
    setmetatable(_G, {
         __newindex = function(_, n, v)
             log("Attempt to write to undeclared var " .. n)
             game.print("Attempt to write to undeclared var " .. n)
             global[n] = v;
         end,
         __index = function(_, n)
             log("Attempt to read undeclared var " .. n)
             game.print("Attempt to read undeclared var " .. n)
            return global[n];
         end
     })
end     

