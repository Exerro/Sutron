
game.func = "render"
game.renderdata = ""

-- require high level classes (Core classes)
require "Engine/Utils"
require "Engine/Physics"

-- require low level classes (Game Classes)
require "Engine/InterfaceObject"
require "Engine/ItemObject"
require "Engine/InventoryObject"
require "Engine/BlockObject"
require "Engine/EntityObject"
require "Engine/CameraObject"
require "Engine/MapObject"

game.interface = game.newInterface( 1, 1, love.graphics.getWidth( ), love.graphics.getHeight( ) )
game.states = { }
game.states.running = game.interface:newFrame( )
game.states.running:lock( )
game.states.running:resize( "set", love.graphics.getWidth( ), love.graphics.getHeight( ) )
local g = game.states.running:newObject( "Updater" )
g:lock( )

game.map = game.newMapObject( )
game.map:load( )

local files = love.filesystem.enumerate( "Resources" )
for i = 1,#files do
	require( "Resources/"..files[i]:sub( 1, #files[i] - 4 ) )
end

function love.load( )

	game.hotbar:addItem( "Iron Pickaxe" )

	game.player = game.newEntityObject( )
	game.player.inventory:setSlotTemplate( "Player Inventory" )
	game.player:move( "set", 0, game.map.blocks[0].maxAir * game.map.blockSize )
	game.player:newAnimation( "Still" )
	game.player:newFrame( game.data.Sprites.Player[1] )
	game.player:newAnimation( "Walking" )
	game.player:newFrame( game.data.Sprites.Player[2] )
	game.player:newFrame( game.data.Sprites.Player[3] )
	game.player:newFrame( game.data.Sprites.Player[4] )
	game.player:newFrame( game.data.Sprites.Player[5] )
	game.player:resize( 30, 30 )
	game.map:newEntity( game.player )
	game.camera = game.newCameraObject( )
	game.camera:linkTo( game.player )
	
	local lastClickTime = 0

	g:fillSize( )
	g.data.handlesMouse = true
	
	g.update = function( self, ev, lastevent )
		if ev[1] == "update" then
			for i = #game.map.entities, 1, -1 do
				if game.map.entities[i].removeFromMap then
					table.remove( game.map.entities, i )
				end
			end
			local xl = game.camera:getLeftClipping( )
			local xr = game.camera:getRightClipping( )
			if not game.map.blocks[xl] then
				game.map.generation:generateColumn( "left" )
			end
			if not game.map.blocks[xr] then
				game.map.generation:generateColumn( "right" )
			end
			if love.mouse.isDown( "l" ) and love.timer.getTime( ) - lastClickTime > 0.2 then
				if self:isMouseIn( love.mouse.getPosition( ) ) then
					local x, y, xd, yd = game.camera:getClickPosition( love.mouse.getPosition( ) )
					game.hotbar:useItem( game.map, x, y, xd, yd )
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
			local xc = function( self, other )
				if self == game.player then
					if not game.physics.collisionY( 4, self, other ) then
						self:applyVelocity( 0, -self.map.gravity * 2 )
					end
				end
				return false
			end
			local yc = function( self, other )
				if self == game.player then
					return 0
				end
				return false
			end
			for i = 1,#game.map.entities do
				game.map:moveEntity( game.map.entities[i], xc, yc, true, 2 or ev[2] * 60 )
			end
		elseif ev[1] == "Mouse" and ev[2] == "Down" and ev[6] == self then
			local x, y, xd, yd = game.camera:getClickPosition( ev[3], ev[4] )
			if ev[5] == "r" and game.map.blocks[x] and game.map.blocks[x][y].block.inventory then
				game.map.blocks[x][y].block.inventory:activate( )
			end
		elseif ev[1] == "Keyboard" and ev[2] == "Down" then
			if ev[3] == " " then -- jumping
				local colliding = false
				local y = math.floor( ( game.player.y + game.player.h ) / game.map.blockSize ) -- gets the block that is containing the bottom of the player
				for x = math.floor( game.player.x / game.map.blockSize ), math.floor( game.player.x / game.map.blockSize ) + math.ceil( game.player.w / game.map.blockSize ) do
					if game.map.blocks[x][y] and game.physics.collisionY( -5, game.player, game.map.blocks[x][y].block ) then -- checks if a block is below the player
						colliding = true
						break
					end
				end
				if not colliding then
					for i = 1,#game.map.entities do
						if game.map.entities[i] ~= game.player then
							if game.physics.collisionY( -5, game.player, game.map.entities[i] ) then
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
				game.func = game.func == "render" and "renderCollisionMap" or "render"
			elseif ev[3] == "e" then
				if game.activeInventory then
					game.activeInventory:deactivate( )
				else
					game.player.inventory:activate( )
				end
			elseif tonumber( ev[3] ) then
				local n = tonumber( ev[3] )
				if n == 0 then n = 10 end
				game.hotbar.data.selection = n
			end
		end
	end
	g.render = function( )
		game.camera[game.func]( game.camera, game.map )
		love.graphics.print( game.camera.x..", "..game.camera.y, 1, 1 )
		love.graphics.print( math.floor( game.camera.x / 32 )..", "..math.floor( game.camera.y / 32 ), 1, 21 )
		love.graphics.print( game.renderdata, 1, 61 )
		love.graphics.print( love.timer.getFPS( ), 1, 41 )
		local bx, by = game.camera:getClickPosition( love.mouse.getPosition( ) )
		local x, y = bx * game.map.blockSize - game.camera.x, by * game.map.blockSize - game.camera.y
		local x = x + ( love.graphics.getWidth( ) / 2 - game.player.w / 2 )
		local y = y + ( love.graphics.getHeight( ) / 2 - game.player.h / 2 )
		love.graphics.setColor( 255, 255, 0, 30 )
		love.graphics.rectangle( "fill", x, y, game.map.blockSize, game.map.blockSize )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.print( game.map.blocks[math.floor( game.camera.x / 32 )].biome, 1, 81 )
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
