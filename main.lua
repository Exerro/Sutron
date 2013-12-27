
game.func = "render"
game.renderdata = ""

game.engine = { }
game.resource = { }

-- require high level classes (Core classes)
require "Engine/Utils"
require "Engine/Physics"
require "Engine/InterfaceObject"

game.interface = game.engine.interface.create( 1, 1, love.graphics.getWidth( ), love.graphics.getHeight( ) )
game.states = { }
game.states.running = game.interface:newFrame( )
game.states.running:lock( )
game.states.running:resize( "set", love.graphics.getWidth( ), love.graphics.getHeight( ) )

-- require low level classes (Game Classes)
require "Engine/ItemObject"
require "Engine/InventoryObject"
require "Engine/BlockObject"
require "Engine/EntityObject"
require "Engine/CameraObject"
require "Engine/MapObject"

require "Resources/InventoryTypes"
require "Resources/EntityTypes"
require "Resources/Biomes"
require "Resources/World"
require "Resources/BlockUpdateMethods"

if love.filesystem.exists( "Resources/Start.lua" ) then
	require "Resources/Start"
end

game.world = game.resource.world.create( )

game.map = game.engine.map.create( )
game.resource.map.newOverworldMap( game.map )
game.map:load( "Tundra" )

local om = game.engine.map.create( )
game.resource.map.newUnderworldMap( om )
om:load( )

game.world:newMap( game.map )
game.world:newMap( om )

local files = love.filesystem.enumerate( "Resources" )
for i = 1,#files do
	require( "Resources/"..files[i]:sub( 1, #files[i] - 4 ) )
end

function love.load( )

	local g = game.states.running:newObject( "Updater" )
	g:fillSize( )
	g.data.handlesMouse = true
	g:lock( )

	game.player = game.resource.entity.newPlayer( true )
	game.player:move( "set", 0, game.map.blocks[0].lastAir * game.map.blockSize )
	game.player:newAnimation( "Still" )
	game.player:newFrame( game.data.Sprites.Player[1] )
	game.player:newAnimation( "Walking" )
	game.player:newFrame( game.data.Sprites.Player[2] )
	game.player:newFrame( game.data.Sprites.Player[3] )
	game.player:newFrame( game.data.Sprites.Player[4] )
	game.player:newFrame( game.data.Sprites.Player[5] )
	game.player:resize( 30, 30 )
	game.map:newEntity( game.player )
	game.player.hotbar:activate( )
	
	if game.playerStartInventory then
		game.player.inventory:addInventory( game.playerStartInventory )
	end
	if game.playerStartHotbar then
		game.player.hotbar:addInventory( game.playerStartHotbar )
	end
	
	local lastClickTime = 0
	local dist = false
	
	g.update = function( self, ev, lastevent )
		if ev[1] == "update" then
			game.world:getMapByID( ):update( )
			for m = 1,#game.world.maps do
				for e = #game.world.maps[m].entities, 1, -1 do
					if game.world.maps[m].entities[e].removeFromMap then
						table.remove( game.world.maps[m].entities, e )
					end
				end
			end
			local xl = game.player.camera:getLeftClipping( )
			local xr = game.player.camera:getRightClipping( )
			if not game.world:getMapByID( ).blocks[xl] then
				game.world:getMapByID( ).generation:newColumn( "left" )
			end
			if not game.world:getMapByID( ).blocks[xr] then
				game.world:getMapByID( ).generation:newColumn( "right" )
			end
			if love.mouse.isDown( "l" ) and love.timer.getTime( ) - lastClickTime > 0.2 then
				if self:isMouseIn( love.mouse.getPosition( ) ) then
					local x, y, xd, yd = game.player.camera:getClickPosition( love.mouse.getPosition( ) )
					game.player.hotbar:useItem( game.world:getMapByID( ), x, y, xd, yd )
					lastClickTime = love.timer.getTime( )
				end
			end
			local key = false
			if love.keyboard.isDown( "d" ) then
				game.player:applyVelocity( 0.2, 0 )
				game.player.xdirection = "right"
				game.player:setAnimation( "Walking" )
				key = true
			end
			if love.keyboard.isDown( "a" ) then
				game.player:applyVelocity( -0.2, 0 )
				game.player.xdirection = "left"
				game.player:setAnimation( "Walking" )
				key = true
			end
			if not key then
				game.player:setAnimation( "Still" )
			end
			for i = 1,#game.world:getMapByID( ).entities do
				game.world:getMapByID( ):moveEntity( game.world:getMapByID( ).entities[i], xc, yc, true, 2 or ev[2] * 60 )
			end
		elseif ev[1] == "Mouse" and ev[2] == "Down" and ev[6] == self then
			local x, y, xd, yd = game.player.camera:getClickPosition( ev[3], ev[4] )
			if ev[5] == "r" and game.world:getMapByID( ).blocks[x] and game.world:getMapByID( ).blocks[x][y].block.inventory then
				game.world:getMapByID( ).blocks[x][y].block.inventory:activate( )
			end
		elseif ev[1] == "Keyboard" and ev[2] == "Down" then
			if ev[3] == " " then -- jumping
				local colliding = false
				local y = math.floor( ( game.player.y + game.player.h ) / game.world:getMapByID( ).blockSize ) -- gets the block that is containing the bottom of the player
				for x = math.floor( game.player.x / game.world:getMapByID( ).blockSize ), math.floor( game.player.x / game.world:getMapByID( ).blockSize ) + math.ceil( game.player.w / game.world:getMapByID( ).blockSize ) do
					if game.world:getMapByID( ).blocks[x][y] and game.physics.collisionY( -5, game.player, game.world:getMapByID( ).blocks[x][y].block ) then -- checks if a block is below the player
						colliding = true
						break
					end
				end
				if not colliding then
					for i = 1,#game.world:getMapByID( ).entities do
						if game.world:getMapByID( ).entities[i] ~= game.player then
							if game.physics.collisionY( -3, game.player, game.world:getMapByID( ).entities[i] ) then
								colliding = true
								break
							end
						end
					end
				end
				if colliding then
					game.player:applyVelocity( 0, -8 ) -- if there is a block below, jump
				end
			elseif ev[3] == "tab" then
				if game.func == "render" then
					game.func = "renderCollisionMap"
				else
					if game.player.camera.smoothLighting then
						game.func = "render"
					else
						game.func = "render"
					end
					game.player.camera.smoothLighting = not game.player.camera.smoothLighting
				end
			elseif ev[3] == "e" then
				if game.engine.inventory.active then
					game.engine.inventory.active:deactivate( )
				else
					game.player.inventory:activate( )
				end
			elseif ev[3] == "x" then
				dist = not dist
			elseif tonumber( ev[3] ) then
				local n = tonumber( ev[3] )
				if n == 0 then n = 10 end
				game.player.hotbar.selection = n
			end
		end
	end
	
	g.render = function( )
		game.player.camera[game.func]( game.player.camera, game.world:getMapByID( ), dist )
		game.player.hotbar:renderItem( )
		love.graphics.print( game.player.camera.x..", "..game.player.camera.y, 1, 1 )
		love.graphics.print( ( math.floor( ( game.player.camera.x + 1 ) / 32 ) )..", "..( math.floor( ( game.player.camera.y + 1 ) / 32 ) + 1 ), 1, 21 )
		love.graphics.print( game.renderdata, 1, 61 )
		love.graphics.print( love.timer.getFPS( ), 1, 41 )
		local bx, by = game.player.camera:getClickPosition( love.mouse.getPosition( ) )
		local x, y = bx * game.world:getMapByID( ).blockSize - game.player.camera.x, by * game.world:getMapByID( ).blockSize - game.player.camera.y
		local x = x + ( love.graphics.getWidth( ) / 2 - game.player.w / 2 )
		local y = y + ( love.graphics.getHeight( ) / 2 - game.player.h / 2 )
		love.graphics.setColor( 255, 255, 0, 30 )
		love.graphics.rectangle( "fill", x, y, game.world:getMapByID( ).blockSize, game.world:getMapByID( ).blockSize )
		love.graphics.setColor( 255, 255, 255 )
	end
end

function love.update( dt )
	game.interface.run.update( game.interface, dt )
end

function love.keypressed( key, uni )
	game.interface.run.keypressed( game.interface, key, uni )
end

function love.mousepressed( x, y, button )
	game.interface.run.mousepressed( game.interface, x, y, button )
end

function love.mousereleased( x, y, button )
	game.interface.run.mousereleased( game.interface, x, y, button )
end

function love.draw( )
	game.interface.run.render( game.interface )
end
