
local function StatusCommand_ShowStatus(player, xplayer)
    if xplayer ~= nil then
       local status = string.format("%s played %s. Location %d,%d",
              xplayer.name,
              HoursAndMinutes(xplayer.online_time),
              math.floor(xplayer.position.x),
              math.floor(xplayer.position.y));
       game.player.print(status)
    end
end

local function sbool(b)
    if b then return "true"; else return "false"; end
end
local function sname(n)
    if n then return n; else return "none"; end
end
local function doprint(msg)
    if game.player then
        game.player.print(msg);
    else
        game.write_file("log.txt", msg .. "\n" , true, 0);
    end
end

commands.remove_command("spawns");
commands.add_command("spawns", "info about the spawns", function(command)
    for _,spawn in pairs(global.allSpawns) do
        if spawn then
            doprint( string.format("%d: %d,%d used=%s, %s", spawn.seq, spawn.x, spawn.y, sbool(spawn.used), sname(spawn.createdFor) ) );
        end        
    end
end)
