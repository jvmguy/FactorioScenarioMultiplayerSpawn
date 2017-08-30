
if global.portal == nil then
    global.portal={}
end

-- Enforce a square of land, with a tree border
-- this is equivalent to the CreateCropCircle code
function CreateCropOctagon(surface, centerPos, chunkArea, tileRadius)

    local dirtTiles = {}
    for i=chunkArea.left_top.x,chunkArea.right_bottom.x,1 do
        for j=chunkArea.left_top.y,chunkArea.right_bottom.y,1 do

            local distVar1 = math.floor(math.max(math.abs(centerPos.x - i), math.abs(centerPos.y - j)))
            local distVar2 = math.floor(math.abs(centerPos.x - i) + math.abs(centerPos.y - j))
            local distVar = math.max(distVar1, distVar2 * 0.707);

            -- Fill in all unexpected water in a circle
            if (distVar < tileRadius) then
                if (surface.get_tile(i,j).collides_with("water-tile") or ENABLE_SPAWN_FORCE_GRASS) then
                    table.insert(dirtTiles, {name = "grass", position ={i,j}})
                end
            end

            -- Create a ring
            if ((distVar < tileRadius) and 
                (distVar > tileRadius-1.9)) then
                if math.random() < SPAWN_TREE_DENSITY then
                  surface.create_entity({name="tree-01", amount=1, position={i, j}})
                end
            end
        end
    end
    surface.set_tiles(dirtTiles)
end

function CreateWaterOctagon(surface, centerPos, chunkArea, tileRadius)

    local dirtTiles = {}
    for i=chunkArea.left_top.x,chunkArea.right_bottom.x,1 do
        for j=chunkArea.left_top.y,chunkArea.right_bottom.y,1 do

            local distVar1 = math.floor(math.max(math.abs(centerPos.x - i), math.abs(centerPos.y - j)))
            local distVar2 = math.floor(math.abs(centerPos.x - i) + math.abs(centerPos.y - j))
            local distVar = math.max(distVar1, distVar2 * 0.707);

            -- Create a water ring
            if ((distVar < tileRadius) and 
                (distVar > tileRadius-2.9)) then
                table.insert(dirtTiles, {name = "water", position ={i,j}})
            end
        end
    end
    surface.set_tiles(dirtTiles)
end

function CreateWaterStrip(surface, spawnPos, width, height)
    local waterTiles = {}
    for j=1,height do
        for i=1,width do
            table.insert(waterTiles, {name = "water", position ={spawnPos.x+i-1,spawnPos.y+j-1}});
        end
    end
    -- DebugPrint("Setting water tiles in this chunk! " .. chunkArea.left_top.x .. "," .. chunkArea.left_top.y)
    surface.set_tiles(waterTiles)
end

function CreateTeleporter(surface, teleporterPosition, dest)
    local car = surface.create_entity{name="car", position=teleporterPosition, force=MAIN_FORCE }
    car.destructible=false;
    car.minable=false;
    for _,item in pairs(scenario.config.teleporter.startItems) do
        car.insert(item);
    end
    -- resource extraction    
    table.insert(global.portal, { position=spawnPos, car = car, dest=dest });
end

function TeleportPlayer( player )
    local car = player.vehicle;
    if car ~= nil then
        local dest = nil
        for _,portal in pairs(global.portal) do
            if car == portal.car then
                if portal.dest == nil then
                    -- teleport from silo back to player spawn.
                    player.print("teleport back to player spawn");
                    dest = global.playerSpawns[player.name];
                    break
                -- we could allow only the player to use the teleporter.
                -- elseif SameCoord(portal.dest, global.playerSpawns[player.name]) then
                else    
                    -- teleport player to silo
                    player.print("teleport to silo");
                    dest = portal.dest;
                    break
                end
            end
        end
        -- TODO. transport anyone in the vicinity as well 
        if dest ~= nil then
            player.driving=false;
            player.teleport(dest);
        end
    end
end

function SameCoord(a, b)
    return a.x == b.x and a.y == b.y;
end

function EnableAutomatedConstruction(force)
--    force.technologies['automated-construction'].researched=true;
end

function AssignPlayerToStartSurface(player)
    local startSurface = game.surfaces["lobby"]
    if startSurface == nil then
        local settings = {
            terrain_segmentation = "very-low",
            water= "very-high",
            width =64,
            height = 64,
            starting_area = "low",
            peaceful_mode = true,
            seed = 1
        };
        game.create_surface("lobby", settings)
        startSurface = game.surfaces["lobby"]
    end
    player.teleport( {x=0,y=0}, startSurface)
end

function ShowSpawns(player, t)
  if t ~= nil then
    for key,spawn in pairs(t) do
      player.print("spawn " .. key .. ": " .. spawn.radius .. " sector " .. spawn.sector .. " seq ".. spawn.seq .. " " .. spawn.x .. "," .. spawn.y );
    end
  end
end

function ShowPlayerSpawns(player)
  ShowSpawns( player, global.playerSpawns );
end

function EraseArea(position, chunkDist)
    local surface = game.surfaces[GAME_SURFACE_NAME];
    local eraseArea = {left_top=
                            {x=position.x-chunkDist*CHUNK_SIZE,
                             y=position.y-chunkDist*CHUNK_SIZE},
                        right_bottom=
                            {x=position.x+chunkDist*CHUNK_SIZE,
                             y=position.y+chunkDist*CHUNK_SIZE}}
    for chunk in surface.get_chunks() do
        local chunkAreaCenter = {x=chunk.x*CHUNK_SIZE+(CHUNK_SIZE/2), y=chunk.y*CHUNK_SIZE+(CHUNK_SIZE/2)}
        if CheckIfInArea(chunkAreaCenter,eraseArea) then
            surface.delete_chunk(chunk);
        end
    end
end

function SurfaceSettings(surface)
    local settings = surface.map_gen_settings;
    game.player.print("surface terrain_segmentation=" .. settings.terrain_segmentation);
    game.player.print("surface water=" .. settings.water);
    game.player.print("surface seed=" .. settings.seed);
end


