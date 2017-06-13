
function HoursAndMinutes(ticks)
    local seconds = ticks/TICKS_PER_SECOND
    local minutes = math.floor((seconds)/60)
    local hours = math.floor(minutes/60)
    return string.format("%d:%02d", hours, minutes)
end

commands.add_command("status", "shows your location, time in game", function()
   local player = game.player;
   local status = string.format("You have played %s of %s. Location %d,%d",
          HoursAndMinutes(player.online_time),
          HoursAndMinutes(game.tick),
          math.floor(player.position.x),
          math.floor(player.position.y))
	game.player.print(status)
end)
