--Values are defined in config.lua
require "../../config.lua"

function GivePlayerLongReach(event)
    local player = game.players[event.player_index]
    if not player and player.valid then
        return
    end
    player.character.character_build_distance_bonus = BUILD_DIST_BONUS
    player.character.character_reach_distance_bonus = REACH_DIST_BONUS
    player.character.character_resource_reach_distance_bonus  = RESOURCE_DIST_BONUS
end

Event.register(defines.events.on_player_respawned, jvm.on_player_respawned)