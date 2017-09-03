

--------------------------------------------------------------------------------
-- Player List GUI - My own version
--------------------------------------------------------------------------------
function CreatePlayerListGui(event)
  local player = game.players[event.player_index]
  if player.gui.top.playerList == nil then
      player.gui.top.add{name="playerList", type="button", caption="Player List"}
  end   
end

local function ExpandPlayerListGui(player)
    local frame = player.gui.left["playerList-panel"]
    if (frame) then
        frame.destroy()
    else
        local frame = player.gui.left.add{type="frame",
                                            name="playerList-panel",
                                            caption="Online:"}
        local scrollFrame = frame.add{type="scroll-pane",
                                        name="playerList-panel",
                                        direction = "vertical"}
        ApplyStyle(scrollFrame, my_player_list_fixed_width_style)
        scrollFrame.horizontal_scroll_policy = "never"
        for _,player in pairs(game.connected_players) do
            local text=scrollFrame.add{type="label", caption=player.name, name=player.name.."_plist"}
            if (player.admin) then
                ApplyStyle(text, my_player_list_admin_style)
            else
                ApplyStyle(text, my_player_list_style)
            end
        end
        local spacer = scrollFrame.add{type="label", caption="     ", name="plist_spacer_plist"}
        ApplyStyle(spacer, my_player_list_style_spacer)
    end
end

function PlayerListGuiClick(event) 
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.element.player_index]
    local name = event.element.name

    if (name == "playerList") then
        ExpandPlayerListGui(player)        
    end
end
