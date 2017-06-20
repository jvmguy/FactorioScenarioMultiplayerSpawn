
function HoursAndMinutes(ticks)
    local seconds = ticks/TICKS_PER_SECOND
    local minutes = math.floor((seconds)/60)
    local hours = math.floor(minutes/60)
    minutes = minutes - 60 * hours
    return string.format("%d:%02d", hours, minutes)
end

commands.add_command("status", "shows your location, time in game", function()
   local player = game.player;
   if player ~= nil then
       for _,xplayer in pairs(game.players) do
           local status = string.format("%s played %s of %s. Location %d,%d",
                  xplayer.name,
                  HoursAndMinutes(player.online_time),
                  HoursAndMinutes(game.tick),
                  math.floor(player.position.x),
                  math.floor(player.position.y))
    	   game.player.print(status)
        end
    end
end)
