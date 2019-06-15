-- spawns arranged in a spiral

local M = {};

function M.GetConfig()
    return scenario.config.fermatSpiralSpawns;
end

local function PolarToCartesian( p )
    return { x = p.r * math.sin( p.theta ), y = p.r * math.cos( p.theta) }
end

local function SpawnPoint(n)
    -- Vogel's model. see https://en.wikipedia.org/wiki/Fermat%27s_spiral
    local config = M.GetConfig()
    local n = config.firstSpawnPoint + n
    return PolarToCartesian({ r= config.spacing * math.sqrt(n), theta= (n * 137.508 * math.pi/180) })
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

function M.InitSpawnPoint(n)
   local a = FermatSpiralPoint(n)
   local spawn = CenterInChunk(a);
   spawn.createdFor = nil;
   spawn.used = false;
   spawn.seq = n
   table.insert(global.allSpawns, spawn)
end


local function toZCoord( area, position )
    local x = position.x
    local y = position.y
    return (x-area.left_top.x) + (y-area.left_top.y) * 65536;
end

local function fromZCoord( area, z )
    local x = z % 65536;
    local y = (z - x) / 65536;
    return { x=area.left_top.x+x, y=area.left_top.y+y }
end

function M.InitSpawnPoint(n)
   local a = SpawnPoint(n)
   local spawn = CenterInChunk(a);
   spawn.surfaceName = GAME_SURFACE_NAME;
   spawn.createdFor = nil;
   spawn.used = false;
   spawn.seq = n
   global.allSpawns[n] = spawn;
end

function M.ChunkGenerated(event)
    local surface = event.surface
    
    if surface.name == GAME_SURFACE_NAME then
        local chunkArea = event.area
        local midPoint = {x = (chunkArea.left_top.x + chunkArea.right_bottom.x)/2,
                            y = (chunkArea.left_top.y + chunkArea.right_bottom.y)/2 }
                            
        -- to do this correctly, we should really get the *two* closest spawns 
        local spawnPos = NearestSpawn( global.allSpawns, midPoint)
        
    end
end

function M.ConfigureGameSurface()
    local config = M.GetConfig()
    if config.freezeTime ~= nil then
        local surface = game.surfaces[GAME_SURFACE_NAME]
        surface.daytime = config.freezeTime
        surface.freeze_daytime = true
    end 
    if config.startingEvolution ~= nil then
        game.forces['enemy'].evolution_factor = config.startingEvolution;
    end 
end

return M;
