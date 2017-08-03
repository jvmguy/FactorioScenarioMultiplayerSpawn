
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

function DeprecatedGivePlayerBestStarterItems(player)
    -- deprecated, but keeping the list
    player.insert{name = "power-armor-mk2", count = 1}
    player.insert{name = "fusion-reactor-equipment", count=1}
    player.insert({name = "exoskeleton-equipment", count=3})
    player.insert({name = "personal-roboport-equipment", count=4})
    player.insert{name="construction-robot", count = 50}
    player.insert{name="blueprint", count = 3}
    player.insert{name="deconstruction-planner", count = 1}
    player.insert{name="night-vision-equipment", count = 1}
    player.insert{name="steel-axe", count = 5}
end

function DeprecatedGivePlayerBetterStarterItems(player)
    -- deprecated, but keeping the list
    player.insert{name = "power-armor", count = 1}
    player.insert{name = "fusion-reactor-equipment", count=1}
    player.insert({name = "exoskeleton-equipment", count=1})
    player.insert({name = "personal-roboport-equipment", count=2})
    player.insert{name="construction-robot", count = 50}
    player.insert{name="night-vision-equipment", count = 1}
    player.insert{name="steel-axe", count = 5}
    player.insert{name="roboport", count = 3}
    player.insert{name="logistic-chest-storage", count = 1}
    player.insert{name = "battery-equipment", count=3}
end

function DeprecatedGivePlayerGoodStarterItems(player)
    -- deprecated, but keeping the list
    player.insert{name="steel-axe", count = 5}
    player.insert{name = "raw-fish", count = 20}
    player.insert{name = "modular-armor", count = 1}
    player.insert{name = "battery-equipment", count=1}
    player.insert({name = "solar-panel-equipment", count=5})
    player.insert({name = "personal-roboport-equipment", count=1})
    player.insert{name="construction-robot", count = 5}
    player.insert{name="blueprint", count = 2}
    player.insert{name="deconstruction-planner", count = 1}
    player.insert{name="roboport", count = 1}
    player.insert{name="logistic-chest-storage", count = 1}

    player.insert{name = "iron-plate", count = 100}
    player.insert{name = "copper-plate", count = 100}

    -- fast power setup
    player.insert{name = "offshore-pump", count = 1}
    player.insert{name = "boiler", count = 4}
    player.insert{name = "steam-engine", count = 3}
    player.insert({name = "pipe", count=10})
    player.insert({name = "pipe-to-ground", count=10})

    -- resource extraction    
    player.insert{name = "electric-mining-drill", count = 5}
    player.insert{name = "stone-furnace", count = 9} -- there's one already there

    -- connectivity
    player.insert{name = "transport-belt", count=50}
    player.insert({name = "inserter", count=20})
end

function DeprecatedGiveBestStartItems(player)
    -- deprecated, but keeping the list
  -- raw materials
    player.insert{name = "coal", count = 100}
    player.insert{name = "iron-plate", count = 100}
    player.insert{name = "copper-plate", count = 100}
    player.insert{name = "steel-plate", count = 100}
    player.insert{name = "electronic-circuit", count = 200}
    player.insert{name = "iron-gear-wheel", count = 200}
    -- fast power setup
    player.insert{name = "offshore-pump", count = 1}
    player.insert{name = "boiler", count = 14}
    player.insert{name = "steam-engine", count = 10}
    player.insert({name = "pipe", count=50})
    player.insert({name = "pipe-to-ground", count=10})
    -- resource extraction    
    player.insert{name = "stone-furnace", count = 49} -- there's one already there
    player.insert{name = "electric-mining-drill", count = 50}
    -- production
    player.insert({name = "assembling-machine-2", count=20})
    -- connectivity
    player.insert{name = "medium-electric-pole", count = 50}
    player.insert{name = "transport-belt", count=200}
    player.insert({name = "underground-belt", count=50})
    player.insert({name = "splitter", count=50})
    player.insert({name = "inserter", count=100})
    player.insert({name = "fast-inserter", count=50})
end

function DeprecatedGivePlayerLogisticStarterItems(player)
    -- connectivity
    player.insert{name="roboport", count = 5}
    player.insert{name="logistic-robot", count = 50}
    player.insert{name="logistic-chest-storage", count = 50}
    player.insert{name="logistic-chest-requester", count = 50}
    player.insert{name="logistic-chest-passive-provider", count = 50}
    player.insert{name="logistic-chest-active-provider", count = 50}
    player.insert({name = "inserter", count=100})
    player.insert({name = "fast-inserter", count=50})
    player.insert({name = "long-handed-inserter", count=50})
    player.insert{name = "medium-electric-pole", count = 50}
    player.insert{name = "big-electric-pole", count = 20}
    player.insert{name = "substation", count = 20}
    -- fast power setup
    player.insert{name="solar-panel", count = 200}
    player.insert{name="accumulator", count = 200}
    -- resource extraction
    player.insert{name = "electric-mining-drill", count = 50}
    player.insert{name="electric-furnace", count = 50}
    -- production
    player.insert({name = "assembling-machine-2", count=20})
end

function CreateTeleporter(surface, spawnPos, dest)
    local car = surface.create_entity{name="car", position={spawnPos.x+2,spawnPos.y}, force=MAIN_FORCE }
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
    local surface = game.surfaces["nauvis"];
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


