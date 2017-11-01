-- This is my re-implementation of regrowth (originally by Oarc)
-- My code style is different, but functionally it is similar to his implementation
-- a few trivial differences.


local M = {};

local config = {
    chunkTimeoutTicks = 1 * TICKS_PER_MINUTE,
    cleanupIntervalTicks = 1 * TICKS_PER_MINUTE,
    maxGarbage = 400
}

local MAXX=4096     -- max chunk coord x/y. tile coord is 32x
local MAXY=4096
local MAXY2 = 2*MAXY


global.regrow = {
    -- map of all chunks
    map = {},
    
    -- list of chunks in LRU order 
    lru = { first=0, last=0, count=0 },
    
    playerRefreshIndex = 1,
    forceRemovalTime = -1,
}

-- chunk status
local CS_NORMAL=0   
local CS_PERM=1     -- permanent chunk. will not be collected
local CS_FORCE=2    -- forced removal. will definitely be collected

local function checkLRU()
    local count = 0
    local map = global.regrow.map
    local lru = global.regrow.lru;
    local p = map[lru.first]
    while p ~= nil do
        count = count + 1
        if p.next ~= 0 then
            if map[p.next].prev ~= p then
                game.print("FOOBAR");
            end
            if p.lruTime > p.next.lruTime then
                game.print("FOOBAR4");
            end
        else
            if lru.last ~= p then
                game.print("FOOBAR2");
            end
        end
        p = map[p.next]
    end
    if count ~= lru.count then
        game.print("FOOBAR3");
    end
end

local function addToLRUFront(mapEntry)
    local map = global.regrow.map
    local lru = global.regrow.lru;

    mapEntry.prev = 0
    mapEntry.next = global.regrow.lru.first
    
    if mapEntry.next ~= 0 then
        map[mapEntry.next].prev = mapEntry.id
    end
    lru.first = mapEntry.id
    if lru.last == 0 then
        lru.last = mapEntry.id;
    end
        
    mapEntry.inLRU = true
    mapEntry.lruTime = 0
    lru.count = lru.count+1
--    checkLRU()    
end

local function addToLRUEnd(mapEntry)
    local map = global.regrow.map
    local lru = global.regrow.lru;
    if lru.first == 0 then
        lru.first = mapEntry.id
    else
        map[lru.last].next = mapEntry.id
    end    
    mapEntry.prev = lru.last
    mapEntry.next = 0
    lru.last = mapEntry.id
    mapEntry.inLRU = true
    mapEntry.lruTime = game.tick + config.chunkTimeoutTicks
    lru.count = lru.count+1
--    checkLRU()    
end


local function addToLRU(mapEntry)
    if mapEntry.status == CS_FORCE then
        addToLRUFront(mapEntry)
    else
        addToLRUEnd(mapEntry)
    end
end

local function removeFromLRU(mapEntry)
    local map = global.regrow.map
    local lru = global.regrow.lru;
    local prev = mapEntry.prev
    local next = mapEntry.next
    if prev == 0 then
        lru.first = next
    else
        map[prev].next = next
    end
    if next == 0 then
        lru.last = prev
    else
        map[next].prev = prev
    end
    mapEntry.prev = 0
    mapEntry.next = 0
    mapEntry.inLRU = false
    lru.count = lru.count-1
--    checkLRU()    
end

local function zIndexFromChunkPos(chunkPos)
    return (chunkPos.x + MAXX) + (chunkPos.y + MAXY) * MAXY2
end

local function getMapEntry(chunkPos)
    local zindex = zIndexFromChunkPos(chunkPos);
    return global.regrow.map[zindex]
end

local function newMapEntry(chunkPos)
    local zindex = zIndexFromChunkPos(chunkPos);
    local result = {
        id = zindex,
        x=chunkPos.x,
        y=chunkPos.y,
        -- status is CS_PERM for chunks that are persistent and not in the LRU
        status=CS_NORMAL,
        inLRU = false,
        lruTime=0,
        prev=0,
        next=0,
    }
    global.regrow.map[zindex] = result
    return result
end
 
local function tileToChunk(pos)
    return { x=math.floor(pos.x/32), y=math.floor(pos.y/32) }
end

local function chunkToTile(pos)
    return { x=32*pos.x, y= 32*pos.y }
end

local function markChunk( chunkPosition )
    local mapEntry = getMapEntry(chunkPosition)
    if mapEntry ~= nil then
        if mapEntry.inLRU then
            removeFromLRU(mapEntry)
        end
        if mapEntry.status ~= CS_PERM then 
            addToLRU(mapEntry)
        end
    end
end

local function markRange( center, chunkRadius )
    for x=-chunkRadius, chunkRadius do
        for y=-chunkRadius, chunkRadius do
            local chunkPosition = { x=center.x+x, y=center.y+y }
            markChunk(chunkPosition);
        end
    end
end

local function markPermanent( center, chunkRadius )
    for x=-chunkRadius,chunkRadius do
        for y=-chunkRadius, chunkRadius do
            local chunkPosition = { x=center.x+x, y=center.y+y }
            local mapEntry = getMapEntry(chunkPosition);
            if mapEntry == nil then
                mapEntry = newMapEntry(chunkPosition);
            end
            mapEntry.status = CS_PERM;
            if mapEntry.inLRU then
                removeFromLRU(mapEntry);
            end
        end
    end
end

local function markForForcedCollection( center, chunkRadius )
    for x=-chunkRadius,chunkRadius do
        for y=-chunkRadius, chunkRadius do
            local chunkPosition = { x=center.x+x, y=center.y+y }
            -- game.print("mark for forced collection: " .. chunkPosition.x .. "," .. chunkPosition.y)
            local mapEntry = getMapEntry(chunkPosition);
            if mapEntry == nil then
                mapEntry = newMapEntry(chunkPosition);
            end
            if mapEntry.inLRU then
                removeFromLRU(mapEntry);
            end
            mapEntry.status = CS_FORCE;
            addToLRU(mapEntry);
        end
    end
end


-- Entities in a chunk, excluding mobile entities
local function countChunkEntities(chunkPos)
    local search_top_left = {x=chunkPos.x*32, y=chunkPos.y*32}
    local search_area = {search_top_left, {x=search_top_left.x+32,y=search_top_left.y+32}}
    local total = 0
    for f,_ in pairs(game.forces) do
        if f ~= "neutral" and f ~= "enemy" then
            local entities = game.surfaces[GAME_SURFACE_NAME].find_entities_filtered{area = search_area, force=f}
            total = total + #entities
--            if (#entities > 0) then
--                
--                for _,e in pairs(entities) do
--                    if ((e.type == "player") or
--                         (e.type == "car") or
--                         (e.type == "logistic-robot") or
--                         (e.type == "construction-robot")) then
--                        total = total - 1
--                    end
--                end
--            end
        end
    end
    return total
end

local function chunkHasResources(mapEntry)
    local topLeft = chunkToTile(mapEntry)
    local bottomRight = { x=topLeft.x+32, y=topLeft.y+32 }
    local resourceCount = game.surfaces[GAME_SURFACE_NAME].count_entities_filtered{area = {topLeft, bottomRight}, type= "resource"}
    return resourceCount>0
end

local function refreshPlayerArea()
    global.regrow.playerRefreshIndex = global.regrow.playerRefreshIndex + 1
    if (global.regrow.playerRefreshIndex > #game.connected_players) then
        global.regrow.playerRefreshIndex = 1
    end
    local player = game.connected_players[global.regrow.playerRefreshIndex] 
    if (player) then
        local chunkPos = tileToChunk(player.position)
        markRange(chunkPos, 4)
    end

end

-- Remove all garbage chunks at same time to reduce impact to FPS/UPS
local function removeGarbageChunks()
    local time = game.tick
    local count  = 0
    local removed = 0
    local map = global.regrow.map
    local lru = global.regrow.lru
    while true do
        if lru.first == 0 then
            break
        end
        local mapEntry = map[lru.first]
        if mapEntry == nil or mapEntry.lruTime > time or count > config.maxGarbage then
            break
        end
        if mapEntry.inLRU then
            removeFromLRU(mapEntry)
            local inUseCount = countChunkEntities(mapEntry)
            local pollution = game.surfaces[GAME_SURFACE_NAME].get_pollution(chunkToTile(mapEntry))
            local doRemove = (inUse == 0) and (pollution == 0);
            if doRemove  or ( mapEntry.status == CS_FORCE ) then
                -- game.print("removed chunk: " .. mapEntry.x .. "," .. mapEntry.y .. " status; " .. mapEntry.status )
                game.surfaces[GAME_SURFACE_NAME].delete_chunk(mapEntry)
                removed = removed + 1
            else
                -- game.print("still in use: " .. mapEntry.x .. "," .. mapEntry.y .. " count " .. inUseCount )
                addToLRU(mapEntry)
            end
        else
            -- game.print("removeGarbage: not in LRU! " .. mapEntry.x .. "," .. mapEntry.y )
            break
        end
        count = count + 1
    end
    if lru.first ~= 0 then
        local mapEntry = map[lru.first]
        local timeToLive = (mapEntry.lruTime - time) / TICKS_PER_SECOND
        game.print("removeGarbageChunks: collected " .. removed .. " of " .. count .. " next map entry:" .. mapEntry.x .. "," .. mapEntry.y .. " expires in " .. timeToLive)
    end
end



function M.init() 
    markPermanent( {x=0,y=0}, 10 );
end

function M.onTick()
    if ((game.tick % (30)) == 2) then
        refreshPlayerArea()
    end
    
    -- check a few chunks to see if they can be collected
    --checkLRUList()

    if false then
        return
    end
--    -- Send a broadcast warning before it happens.
--    if ((game.tick % config.cleanupIntervalTicks) == config.cleanupIntervalTicks-601) then
--        SendBroadcastMsg("Map cleanup in 10 seconds...")
--    end

    -- Delete all listed chunks
    if ((game.tick % config.cleanupIntervalTicks) == config.cleanupIntervalTicks-1) then
        removeGarbageChunks()
--        SendBroadcastMsg("Map cleanup done...")
    end

--    -- Catch force remove flag
    if (game.tick == global.regrow.forceRemovalTime+60) then
        SendBroadcastMsg("Map cleanup in 10 seconds...")
    end
    if (game.tick == global.regrow.forceRemovalTime+660) then
        removeGarbageChunks()
        SendBroadcastMsg("Map cleanup done...")
    end
         
end

function M.collect()
    removeGarbageChunks()
end

function M.onSectorScan(event)
    markArea(event.radar.position, 14, game.tick);
    markChunk(event.chunk_position, game.tick); 
end

-- This is used to decide whether to generate RSO resources when a chunk is generated
-- we construct a map entry the first time a chunk is generated.
-- If the chunk has resources, it will not be deleted.
-- So if a map entry exists, we know that that chunk was deleted and had no resources. 
 
function M.shouldGenerateResources(event)
    if event.surface.name ~= GAME_SURFACE_NAME then
        return true
    end 
    local pos = event.area.left_top
    local chunkPos = tileToChunk(pos);
    local mapEntry = getMapEntry(chunkPos);
    return mapEntry == nil or mapEntry.status == CS_FORCE;
end

function M.afterResourceGeneration(event)
    if event.surface.name ~= GAME_SURFACE_NAME then
        return
    end
    local pos = event.area.left_top
    local chunkPos = tileToChunk(pos);
    local mapEntry = getMapEntry(chunkPos);
    if chunkHasResources(mapEntry) then
        -- game.print("chunk " .. mapEntry.x .. "," .. mapEntry.y .. " has resources")
        markPermanent( chunkPos, 0);
    end
end

function M.onChunkGenerated(event)
    if event.surface.name ~= GAME_SURFACE_NAME then
        return
    end 
    local pos = event.area.left_top
    local chunkPos = tileToChunk(pos);
    -- game.print("onChunkGenerated: " .. chunkPos.x .. "," .. chunkPos.y)
    local mapEntry = getMapEntry(chunkPos);
    if mapEntry == nil then
        mapEntry = newMapEntry(chunkPos);
--    else
--        game.print("map entry exists: " .. chunkPos.x .. "," .. chunkPos.y)
    end
    if mapEntry.inLRU then
        removeFromLRU(mapEntry)
    end
    if mapEntry.status ~= CS_PERM then
        addToLRU(mapEntry);
--    else
--        game.print("map entry is permanent: " .. chunkPos.x .. "," .. chunkPos.y)
    end
end

function M.onBuiltEntity(event)
    if event.created_entity.surface.name ~= GAME_SURFACE_NAME then
        return
    end 
    local pos = event.created_entity.position; 
    local chunkPos = tileToChunk(pos);
    markChunk(chunkPos); 
end

function M.onRobotBuiltEntity(event)
    if event.created_entity.surface.name ~= GAME_SURFACE_NAME then
        return
    end 
    local pos = event.created_entity.position 
    local chunkPos = tileToChunk(pos);
    markChunk(chunkPos); 
end

function M.onRobotMinedEntity(event)
    -- chunk might not be in use anymore 
end

function M.onPlayerMinedEntity(event) 
    -- chunk might not be in use anymore 
end

function M.markForRemoval(pos)
    markForForcedCollection( tileToChunk(pos), 10)
    global.regrow.forceRemovalTime = game.tick
end

function M.forceCollectSpawn(spawnNumber)
    markForForcedCollection( global.allSpawns[spawnNumber], 10)
    global.regrow.forceRemovalTime = game.tick
end

function M.regrowStatus(x,y)
    local chunkPos = tileToChunk({ x=x, y=y })
    local mapEntry = getMapEntry(chunkPos);
    if mapEntry then
        local inLRU = "n"
        if mapEntry.inLRU then inLRU = "y" end
        local timeToLive = mapEntry.lruTime - game.tick
        game.print("chunk " .. mapEntry.x .. "," .. mapEntry.y
         .. " status: " .. mapEntry.status
         .. " inLRU: " .. inLRU
         .. " ttl: " .. timeToLive
         );
     else
        game.print("not in map")     
     end 
end

return M;
