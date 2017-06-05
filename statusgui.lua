function CreateStatusGui(event)
  local player = game.players[event.player_index]
  if player.gui.top.status == nil then
      player.gui.top.add{name="status", type="button", caption="Status"}
  end   
end

function HoursAndMinutes(ticks)
    local seconds = ticks/TICKS_PER_SECOND
    local minutes = math.floor((seconds)/60)
    local hours = math.floor(minutes/60)
    return string.format("%d:%02d", hours, minutes)
end

function UpdateStatusGui(player)
  local status = player.gui.top.status
  if status ~= nil then
      status.caption = string.format("%s %s %d,%d",
          HoursAndMinutes(game.tick),
          HoursAndMinutes(player.online_time),
          math.floor(player.position.x),
          math.floor(player.position.y))
  end
end

function StatusGuiClick(event) 
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.element.player_index]
    local name = event.element.name

    if (name == "status") then
        local status = player.gui.top.status
        if status ~= nil then
            if status.caption == "Status" then
                UpdateStatusGui(player)
            else
                status.caption = "Status";
            end
        end
    end
end
