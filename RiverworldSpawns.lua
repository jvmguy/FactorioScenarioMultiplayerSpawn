
local M = {};
  
local function PolarToCartesian( p )
    return { x = p.r * math.sin( p.theta ), y = p.r * math.cos( p.theta) }
end


local function SpawnPoint(n)
    -- degenerate spiral that just alternates on either side of the axis
    local n = scenario.config.riverworld.firstSpawnPoint + n
    local spacing = scenario.config.riverworld.spacing
    return PolarToCartesian({ r=spacing * n / 2, theta= (n * math.pi ) })
end

  
local function CenterInChunk(a)
    return { x = a.x-math.fmod(a.x, 32)+16, y=a.y-math.fmod(a.y, 32)+16 }
end

local function MakeRect( x, w, y, h )
	return { left_top = { x=x, y=y }, right_bottom = { x=x+w, y=y+h } }
end

local function ChunkIntersects( a, b )
	if a.left_top.x > b.right_bottom.x or b.left_top.x > a.right_bottom.x or
	   a.left_top.y > b.right_bottom.y or b.left_top.y > a.right_bottom.y then
		return false;
	end
	return true;
end

local function ChunkIntersection( a, b )
        return { left_top = { x=math.max(a.left_top.x, b.left_top.x), y= math.max(a.left_top.y, b.left_top.y)}, 
                 right_bottom = { x=math.min(a.right_bottom.x, b.right_bottom.x), y= math.min(a.right_bottom.y, b.right_bottom.y)} }
end

local function ChunkContains( chunk, pt )
        return pt.x >= chunk.left_top.x and pt.x < chunk.right_bottom.x and
            pt.y >= chunk.left_top.y and pt.y < chunk.right_bottom.y;
end

local function makeIndestructibleEntity(surface, args)
    local entity = surface.create_entity(args);
    if entity ~= nil then
        entity.destructible = false;
        entity.minable = false;
    end
    return entity;
end

local function GenerateRails(surface, chunkArea, railX, rails)
    if ChunkIntersects(chunkArea, rails) then
        local rect = ChunkIntersection( chunkArea, rails );
        local tiles = {};
        for y = rect.left_top.y, rect.right_bottom.y-1 do
            for x = rect.left_top.x, rect.right_bottom.x-1 do
                table.insert(tiles, {name = "grass", position = {x,y}});
            end
        end
        surface.set_tiles(tiles)

        for _, entity in pairs (surface.find_entities_filtered{area = rails}) do
            entity.destroy()  
        end

        for y = rect.left_top.y, rect.right_bottom.y-1 do
            if math.fmod(y,2)==0 then
                local pt = { x=railX+1, y=y };                 
                makeIndestructibleEntity(surface, {name="straight-rail", position=pt, force=MAIN_FORCE})
                local pt = { x=railX+9, y=y };
                makeIndestructibleEntity(surface, {name="straight-rail", position=pt, force=MAIN_FORCE})
                local pt = { x=railX+17, y=y };
                makeIndestructibleEntity(surface, {name="straight-rail", position=pt, force=MAIN_FORCE})
                local pt = { x=railX+25, y=y };
                makeIndestructibleEntity(surface, {name="straight-rail", position=pt, force=MAIN_FORCE})
            end
            if (math.fmod(y,30)==0) then
                local pt = { x=railX, y=y+1 };                 
                surface.create_entity({name="rail-signal", position=pt, force=MAIN_FORCE})
                local pt = { x=railX+8, y=y+1 };                 
                surface.create_entity({name="rail-signal", position=pt, force=MAIN_FORCE})
                local pt = { x=railX+14, y=y+1 };                 
                surface.create_entity({name="big-electric-pole", position=pt, force=MAIN_FORCE})
                local pt = { x=railX+19, y=y };                 
                surface.create_entity({name="rail-signal", position=pt, force=MAIN_FORCE, direction=4})
                local pt = { x=railX+27, y=y };                 
                surface.create_entity({name="rail-signal", position=pt, force=MAIN_FORCE, direction=4})
            end
        end
    end
end

function M.InitSpawnPoint(n)
   local a = SpawnPoint(n)
   local spawn = CenterInChunk(a);
   spawn.generated = false;
   spawn.used = false;
   spawn.seq = n
   table.insert(global.unusedSpawns, spawn );
   table.insert(global.allSpawns, spawn)
end

function M.ChunkGenerated(event)
    local surface = event.surface
    
    if surface.name == GAME_SURFACE_NAME then
        local chunkArea = event.area
        local midPoint = {x = (chunkArea.left_top.x + chunkArea.right_bottom.x)/2,
                            y = (chunkArea.left_top.y + chunkArea.right_bottom.y)/2 }
        -- to do this correctly, we should really get the *two* closest spawns 
        local spawnPos = NearestSpawn( global.allSpawns, midPoint)
        local dy = math.abs(midPoint.y - spawnPos.y)
        local spacing = scenario.config.riverworld.spacing
        local barrier = scenario.config.riverworld.barrier
        local spawnHeight = (spacing - barrier) / 2
        local w = chunkArea.right_bottom.x - chunkArea.left_top.x
        local wallRect = MakeRect( chunkArea.left_top.x, w, spawnPos.y-spawnHeight - barrier, barrier );
        wallRect = ChunkIntersection(chunkArea, wallRect);

                
        local railsRect = MakeRect( scenario.config.riverworld.rail, 28, -20000, 40000);
        railsRect = ChunkIntersection( chunkArea, railsRect);
                
        local railsRect2 = MakeRect( scenario.config.riverworld.rail2, 28, -20000, 40000);
        railsRect2 = ChunkIntersection( chunkArea, railsRect2);
        
        -- quick reject
        if (dy < spacing) then
            local tiles = {};
            for y=wallRect.left_top.y, wallRect.right_bottom.y-1 do
                for x = wallRect.left_top.x, wallRect.right_bottom.x-1 do
--                          table.insert(tiles, {name = "out-of-map",position = {x,y}})
                            table.insert(tiles, {name = "grass",position = {x,y}})
                end
            end
            surface.set_tiles(tiles)

	    for _, entity in pairs (surface.find_entities_filtered{area = wallRect}) do
		entity.destroy()  
	    end
            for y=wallRect.left_top.y, wallRect.right_bottom.y-1 do
                for x = wallRect.left_top.x, wallRect.right_bottom.x-1 do
                    if not ChunkContains(railsRect, {x=x,y=y}) and not ChunkContains(railsRect2, {x=x,y=y} )then
                        makeIndestructibleEntity(surface, {name="stone-wall", position={x, y}, force=MAIN_FORCE});
                    end
                end
            end
        end

        GenerateRails( surface, chunkArea, scenario.config.riverworld.rail, railsRect);        
        GenerateRails( surface, chunkArea, scenario.config.riverworld.rail2, railsRect2);
    end
end

function M.ConfigureGameSurface()
    if scenario.config.riverworld.freezeTime ~= nil then
        local surface = game.surfaces[GAME_SURFACE_NAME];
        surface.daytime = scenario.config.riverworld.freezeTime
        surface.freeze_daytime = true;
    end 
end

return M;