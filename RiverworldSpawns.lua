
local M = {};
  
local function PolarToCartesian( p )
    return { x = p.r * math.sin( p.theta ), y = p.r * math.cos( p.theta) }
end


local function SpiralPoint(n)
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
        return pt.x >= chunk.left_top.x and pt.x > chunk.right_bottom.x and
            pt.y >= chunk.left_top.y and pt.y > chunk.right_bottom.y;
end

function M.InitSpawnPoint(n)
   local a = SpiralPoint(n)
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
        local spawnPos = NearestSpawn( global.allSpawns, midPoint)
        local dy = math.abs(midPoint.y - spawnPos.y)
        local spacing = scenario.config.riverworld.spacing
        local spawnHeight = spacing / 2
        local barrier = scenario.config.riverworld.barrier / 2
        -- quick reject
        if (dy < spacing) then
            local tiles = {};
            for y=chunkArea.left_top.y, chunkArea.right_bottom.y do
                local ddy = math.abs(y - spawnPos.y);
                if ddy > spawnHeight - barrier then
                    for x = chunkArea.left_top.x, chunkArea.right_bottom.x do
--                    	if math.abs(x) < scenario.config.riverworld.barrier_width then
--                        if math.fmod(math.abs(x+64/2), 64)>1 then
                            table.insert(tiles, {name = "out-of-map",position = {x,y}})
--                        end
                    end
                end
            end
            surface.set_tiles(tiles)
        end
        local rails = MakeRect( scenario.config.riverworld.rail, 11, -40000, 80000);
        if ChunkIntersects(chunkArea, rails) then
            local rect = ChunkIntersection( chunkArea, rails );
            local tiles = {};
            for y = rect.left_top.y, rect.right_bottom.y do
                for x = rect.left_top.x, rect.right_bottom.x do
                    table.insert(tiles, {name = "grass", position = {x,y}});
                end
            end
            surface.set_tiles(tiles)
            for y = rect.left_top.y, rect.right_bottom.y do
                if math.fmod(y,2)==0 then
                    local pt = { x=scenario.config.riverworld.rail+1, y=y };                 
                    surface.create_entity({name="straight-rail", position=pt, force=MAIN_FORCE})
                    local pt = { x=scenario.config.riverworld.rail+9, y=y };
                    surface.create_entity({name="straight-rail", position=pt, force=MAIN_FORCE})
                    if (math.fmod(y,30)==0) then
                        local pt = { x=scenario.config.riverworld.rail, y=y };                 
                        surface.create_entity({name="rail-signal", position=pt, force=MAIN_FORCE})
                        local pt = { x=scenario.config.riverworld.rail+11, y=y };                 
                        surface.create_entity({name="rail-signal", position=pt, force=MAIN_FORCE, direction=4})
                        local pt = { x=scenario.config.riverworld.rail+6, y=y };                 
                        surface.create_entity({name="big-electric-pole", position=pt, force=MAIN_FORCE})
                    end
                end
            end
        end
    end
end


return M;