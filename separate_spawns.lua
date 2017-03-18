-- Nov 2016
--
-- Code that handles everything regarding giving each player a separate spawn
-- Includes the GUI stuff


--------------------------------------------------------------------------------
-- EVENT RELATED FUNCTIONS
--------------------------------------------------------------------------------

-- When a new player is created, present the spawn options
-- Assign them to the main force so they can communicate with the team
-- without shouting.
function SeparateSpawnsPlayerCreated(event)
    local player = game.players[event.player_index]
    player.force = MAIN_FORCE
    DisplayWelcomeTextGui(player)
    global.playerCooldowns[player.name] = {setRespawn=event.tick}
end


-- Check if the player has a different spawn point than the default one
-- Make sure to give the default starting items
function SeparateSpawnsPlayerRespawned(event)
    local player = game.players[event.player_index]
    SendPlayerToSpawn(player)
end



function GenerateSpawnChunk( event, spawnPos)
    local surface = event.surface
    local chunkArea = event.area
		
        local landArea = {left_top=
                            {x=spawnPos.x-ENFORCE_LAND_AREA_TILE_DIST,
                             y=spawnPos.y-ENFORCE_LAND_AREA_TILE_DIST},
                          right_bottom=
                            {x=spawnPos.x+ENFORCE_LAND_AREA_TILE_DIST,
                             y=spawnPos.y+ENFORCE_LAND_AREA_TILE_DIST}}

        local safeArea = {left_top=
                            {x=spawnPos.x-SAFE_AREA_TILE_DIST,
                             y=spawnPos.y-SAFE_AREA_TILE_DIST},
                          right_bottom=
                            {x=spawnPos.x+SAFE_AREA_TILE_DIST,
                             y=spawnPos.y+SAFE_AREA_TILE_DIST}}

        local warningArea = {left_top=
                                {x=spawnPos.x-WARNING_AREA_TILE_DIST,
                                 y=spawnPos.y-WARNING_AREA_TILE_DIST},
                            right_bottom=
                                {x=spawnPos.x+WARNING_AREA_TILE_DIST,
                                 y=spawnPos.y+WARNING_AREA_TILE_DIST}}

        local chunkAreaCenter = {x=chunkArea.left_top.x+(CHUNK_SIZE/2),
                                 y=chunkArea.left_top.y+(CHUNK_SIZE/2)}

                                 

        -- Make chunks near a spawn safe by removing enemies
        if CheckIfInArea(chunkAreaCenter,safeArea) then
            for _, entity in pairs(surface.find_entities_filtered{area = chunkArea, force = "enemy"}) do
                entity.destroy()
            end
        
        -- Create a warning area with reduced enemies
        elseif CheckIfInArea(chunkAreaCenter,warningArea) then
            local counter = 0
            for _, entity in pairs(surface.find_entities_filtered{area = chunkArea, force = "enemy"}) do
                if ((counter % WARN_AREA_REDUCTION_RATIO) ~= 0) then
                    entity.destroy()
                end
                counter = counter + 1
            end

            -- Remove all big and huge worms
            for _, entity in pairs(surface.find_entities_filtered{area = chunkArea, name = "medium-worm-turret"}) do
                    entity.destroy()
            end
            for _, entity in pairs(surface.find_entities_filtered{area = chunkArea, name = "big-worm-turret"}) do
                    entity.destroy()
            end

        end

        -- Fill in any water to make sure we have guaranteed land mass at the spawn point.
        if CheckIfInArea(chunkAreaCenter,landArea) then

            -- remove trees in the immediate areas?
            for key, entity in pairs(surface.find_entities_filtered({area=chunkArea, type= "tree"})) do
                if ((spawnPos.x - entity.position.x)^2 + (spawnPos.y - entity.position.y)^2 < ENFORCE_LAND_AREA_TILE_DIST^2) then
                    entity.destroy()
                end
            end
			if (ENABLE_CROP_OCTAGON) then
	            CreateCropOctagon(surface, spawnPos, chunkArea, ENFORCE_LAND_AREA_TILE_DIST)
			else
	            CreateCropCircle(surface, spawnPos, chunkArea, ENFORCE_LAND_AREA_TILE_DIST)
			end
            CreateWaterStrip( surface, spawnPos, ENFORCE_LAND_AREA_TILE_DIST*3/4 )
            if not spawnPos.generated then
              spawnPos.generated = true;
              GenerateStartingResources( surface, spawnPos);
            end
        end
end


-- This is the main function that creates the spawn area
-- Provides resources, land and a safe zone
function SeparateSpawnsGenerateChunk(event)
    local surface = event.surface
    if surface.name ~= "nauvis" then return end
    local chunkArea = event.area
    -- This handles chunk generation near player spawns
    -- If it is near a player spawn, it does a few things like make the area
    -- safe and provide a guaranteed area of land and water tiles.
    for name,spawnPos in pairs(global.uniqueSpawns) do
		  GenerateSpawnChunk(event, spawnPos)
    end
    for name,spawnPos in pairs(global.unusedSpawns) do
  		GenerateSpawnChunk(event, spawnPos)
    end
end


-- Call this if a player leaves the game
-- Seems to be susceptiable to causing desyncs...
function FindUnusedSpawns(event)
    local player = game.players[event.player_index]
    if (event.player_index>1 and player.online_time < MIN_ONLINE_TIME) then

        -- TODO dump items into a chest.

        -- Clear out global variables for that player???
        if (global.playerSpawns[player.name] ~= nil) then
            global.playerSpawns[player.name] = nil
        end

        -- If a uniqueSpawn was created for the player, mark it as unused.
        if (global.uniqueSpawns[player.name] ~= nil) then
            table.insert(global.unusedSpawns, global.uniqueSpawns[player.name])
            global.uniqueSpawns[player.name] = nil
            SendBroadcastMsg(player.name .. " base was freed up because they left within 5 minutes of joining.")
        end
        
        -- Remove from shared spawns
        if (global.sharedSpawns[player.name] ~= nil) then
            global.sharedSpawns[player.name] = nil
        end

        -- remove that player's cooldown setting
        if (global.playerCooldowns[player.name] ~= nil) then
            global.playerCooldowns[player.name] = nil
        end

        -- Remove from shared spawn player slots (need to search all)
        for _,sharedSpawn in pairs(global.sharedSpawns) do
            for key,playerName in pairs(sharedSpawn.players) do
                if (player.name == playerName) then
                    sharedSpawn.players[key] = nil;
                end
            end
        end


        -- Remove the character completely
        game.remove_offline_players({player})
    end
end


function CreateNewSharedSpawn(player)
    global.sharedSpawns[player.name] = {openAccess=true,
                                    position=global.playerSpawns[player.name],
                                    players={}}
end

function GetOnlinePlayersAtSharedSpawn(ownerName)
    if (global.sharedSpawns[ownerName] ~= nil) then

        -- Does not count base owner
        local count = 0

        -- For each player in the shared spawn, check if online and add to count.
        for _,player in pairs(game.connected_players) do
            if (ownerName == player.name) then
                count = count + 1
            end

            for _,playerName in pairs(global.sharedSpawns[ownerName].players) do
            
                if (playerName == player.name) then
                    count = count + 1
                end
            end
        end

        return count
    else
        return 0
    end
end


-- Get the number of currently available shared spawns
-- This means the base owner has enabled access AND the number of online players
-- is below the threshold.
function GetNumberOfAvailableSharedSpawns()
    local count = 0

    for ownerName,sharedSpawn in pairs(global.sharedSpawns) do
        if (sharedSpawn.openAccess) then
            if (GetOnlinePlayersAtSharedSpawn(ownerName) < MAX_ONLINE_PLAYERS_AT_SHARED_SPAWN) then
                count = count+1
            end
        end
    end

    return count
end


--------------------------------------------------------------------------------
-- NON-EVENT RELATED FUNCTIONS
-- These should be local functions where possible!
--------------------------------------------------------------------------------
function HexPoint(kangle, rad)
      local degreesToRadians = math.pi / 180;
	  -- the slight 10 degree tilt is to make the grid slightly less obvious
      local angle = kangle * 2*math.pi / 6 + 10 * degreesToRadians; 
      return { x= rad * math.sin(angle), y = rad * math.cos(angle) }
end

function lerp( r, a, b)
  return{ x = a.x + r * (b.x-a.x), y= a.y + r * (b.y-a.y) }
end
  
function HexRowPoint(kangle, rad, item, itemlen)
  local first = HexPoint(kangle, rad)
  local last = HexPoint(kangle+1, rad)
  if itemlen==0 then
    return first
  end
  return lerp( (1.0*item)/itemlen, first, last)
end
  
function CenterInChunk(a)
	return { x = a.x-math.fmod(a.x, 32)+16, y=a.y-math.fmod(a.y, 32)+16 }
end

function InitSpawnPoint(k, kangle, j)
   a = HexRowPoint(kangle, k*HEXSPACING, j, k)
   local spawn = CenterInChunk(a);
   spawn.generated = false;
   spawn.used = false;
   spawn.radius = k
   spawn.sector = kangle
   spawn.seq = j
   table.insert(global.unusedSpawns, spawn );
   table.insert(global.allSpawns, spawn)
end

function InitSpawnGlobalsAndForces()
    -- Contains an array of all player spawns
    -- A secondary array tracks whether the character will respawn there.
    if (global.allSpawns == nil) then
        global.allSpawns = {}
    end
    if (global.playerSpawns == nil) then
        global.playerSpawns = {}
    end
    if (global.uniqueSpawns == nil) then
        global.uniqueSpawns = {}
    end
    if (global.sharedSpawns == nil) then
        global.sharedSpawns = {}
    end
    if (global.unusedSpawns == nil) then
        global.unusedSpawns = {}
        -- InitSpawnPoint( 0, 0, 0);
        for rad = HEXFIRSTRING,HEXRINGS do
          for kangle=0,5 do
            for j=0,rad-1 do
              InitSpawnPoint( rad, kangle, j)
            end        			
          end
        end
--        for rad = 1,HEXRINGS do
--          for kangle=0,0 do
--            for j=0,0 do
--              InitSpawnPoint( rad, kangle, j)
--            end             
--          end
--        end
    end
    if (global.playerCooldowns == nil) then
        global.playerCooldowns = {}
    end

    game.create_force(MAIN_FORCE)
    game.forces[MAIN_FORCE].set_spawn_position(game.forces["player"].get_spawn_position("nauvis"), "nauvis")
    SetCeaseFireBetweenAllForces()
end

function GenerateStartingResources(surface, spawnPos)
    --local surface = player.surface

    -- Generate stone
    local stonePos = {x=spawnPos.x+START_RESOURCE_STONE_POS_X,
                  y=spawnPos.y+START_RESOURCE_STONE_POS_Y}

    -- Generate coal
    local coalPos = {x=spawnPos.x+START_RESOURCE_COAL_POS_X,
                  y=spawnPos.y+START_RESOURCE_COAL_POS_Y}

    -- Generate copper ore
    local copperOrePos = {x=spawnPos.x+START_RESOURCE_COPPER_POS_X,
                  y=spawnPos.y+START_RESOURCE_COPPER_POS_Y}
                  
    -- Generate iron ore
    local ironOrePos = {x=spawnPos.x+START_RESOURCE_IRON_POS_X,
                  y=spawnPos.y+START_RESOURCE_IRON_POS_Y}

    -- Tree generation is taken care of in chunk generation

    -- Generate oil patches
    surface.create_entity({name="crude-oil", amount=START_OIL_AMOUNT,
                    position={spawnPos.x+START_RESOURCE_OIL_POS_X, spawnPos.y+START_RESOURCE_OIL_POS_Y}})
    surface.create_entity({name="crude-oil", amount=START_OIL_AMOUNT,
                    position={spawnPos.x+START_RESOURCE_OIL_POS2_X, spawnPos.y+START_RESOURCE_OIL_POS2_Y}})


    CreateResources( surface, stonePos, START_RESOURCE_STONE_SIZE, START_STONE_AMOUNT, "stone" );
    CreateResources( surface, coalPos, START_RESOURCE_COAL_SIZE, START_COAL_AMOUNT, "coal" );
    CreateResources( surface, copperOrePos, START_RESOURCE_COPPER_SIZE, START_COPPER_AMOUNT, "copper-ore" );
    CreateResources( surface, ironOrePos, START_RESOURCE_IRON_SIZE, START_IRON_AMOUNT, "iron-ore" );
end

function CreateResources( surface, pos, size, startAmount, resourceName )
    local xsize = size * ELLIPSE_X_STRETCH
    local ysize = size
    local xRadiusSq = (xsize/2)^2;
    local yRadiusSq = (ysize/2)^2;
    local midPointY = math.floor(size/2)
    local midPointX = math.floor(xsize/2)
    for y=0, size do
        for x=0, xsize do
            if (((x-midPointX)^2/xRadiusSq + (y-midPointY)^2/yRadiusSq < 1) or not ENABLE_RESOURCE_SHAPE_CIRCLE) then
                surface.create_entity({name=resourceName, amount=startAmount,
                    position={pos.x+x, pos.y+y}})
            end
        end
    end
end

function DoesPlayerHaveCustomSpawn(player)
    for name,spawnPos in pairs(global.playerSpawns) do
        if (player.name == name) then
            return true
        end
    end
    return false
end

function ChangePlayerSpawn(player, pos)
    global.playerSpawns[player.name] = pos
end

function SendPlayerToNewSpawnAndCreateIt(player, spawn)
    -- Send the player to that position
    if spawn == nil then
      DebugPrint("SendPlayerToNewSpawnAndCreateIt: error. spawn is nil")
      spawn = { x = 0, y = 0 }
    end
    player.teleport(spawn)
    ChartArea(player.force, player.position, 4)

    -- If we get a valid spawn point, setup the area
    if ((spawn.x ~= 0) and (spawn.y ~= 0)) then
        global.uniqueSpawns[player.name] = spawn
        ClearNearbyEnemies(player, SAFE_AREA_TILE_DIST)
    else      
        DebugPrint("THIS SHOULD NOT EVER HAPPEN! Spawn failed!")
        SendBroadcastMsg("Failed to create spawn point for: " .. player.name)
    end
end

function SendPlayerToSpawn(player)
    if (DoesPlayerHaveCustomSpawn(player)) then
        player.teleport(global.playerSpawns[player.name])
    else
        player.teleport(game.forces[MAIN_FORCE].get_spawn_position("nauvis"))
    end
end

function SendPlayerToRandomSpawn(player)
    local numSpawns = TableLength(global.uniqueSpawns)
    local rndSpawn = math.random(0,numSpawns)
    local counter = 0

    if (rndSpawn == 0) then
        player.teleport(game.forces[MAIN_FORCE].get_spawn_position("nauvis"))
    else
        counter = counter + 1
        for name,spawnPos in pairs(global.uniqueSpawns) do
            if (counter == rndSpawn) then
                player.teleport(spawnPos)
                break
            end
            counter = counter + 1
        end 
    end
end




--------------------------------------------------------------------------------
-- UNUSED CODE
-- Either didn't work, or not used or not tested....
--------------------------------------------------------------------------------



-- local tick_counter = 0
-- function ShareVision(event)
--     if (tick_counter > (TICKS_PER_SECOND*30)) then
--         ShareVisionForAllForces()
--         tick_counter = 0
--     end
--     tick_counter = tick_counter + 1
-- end

-- function CreatePlayerCustomForce(player)
--     local newForce = nil
    
--     -- Check if force already exists
--     if (game.forces[player.name] ~= nil) then
--         return game.forces[player.name]

--     -- Create a new force using the player's name
--     elseif (TableLength(game.forces) < MAX_FORCES) then
--         newForce = game.create_force(player.name)
--         player.force = newForce
--         SetCeaseFireBetweenAllForces()        
--     else
--         player.force = MAIN_FORCE
--         player.print("Sorry, no new teams can be created. You were assigned to the default team instead.")
--     end

--     return newForce
-- end