-- Define some global game variables that we will be needing later

-- define all the grapical storage
game.mask = { }
game.mask.image = { }
game.mask.data = { }
game.mask.data.collision = { }
game.func = "render"
game.renderdata = ""

-- require high level classes (Core classes)
require "Resources/Utils"
require "Resources/Physics"

-- require low level classes (Game Classes)
require "Resources/InterfaceObject"
require "Resources/BlockObject"
require "Resources/InventoryObject"
require "Resources/EntityObject"
require "Resources/CameraObject"
require "Resources/Map"

function love.load( )
	game.interface = game.newInterface( 1, 1, love.graphics.getWidth( ), love.graphics.getHeight( ) )
	game.states = { }
	game.states.running = game.interface:newFrame( )
	game.states.running:resize( "set", love.graphics.getWidth( ), love.graphics.getHeight( ) )

	game.player = game.newEntityObject( )
	game.player:move( "set", 0, game.map.blocks[0].maxAir * game.blockSize )
	game.player:newAnimation( "Still" )
	game.player:newFrame( game.data.Sprites.Player1 )
	game.player:newAnimation( "Walking" )
	game.player:newFrame( game.data.Sprites.Player2 )
	game.player:newFrame( game.data.Sprites.Player3 )
	game.player:resize( 30, 30 )
	table.insert( game.map.entities, game.player )
	game.camera = game.newCameraObject( )
	game.camera:linkTo( game.player )

	local g = game.states.running:newObject( "Updater" )
	g:fillSize( )
	g:lock( )
	
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
				game.map:newColumn( "left" )
			end
			if not game.map.blocks[xr] then
				game.map:newColumn( "right" )
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
			for i = 1,#game.map.entities do
				game.map.entities[i]:update( "x" )
				local colliding, object = game.map.entities[i]:isCollidingWithMap( game.map )
				if colliding then
					if not game.physics.collisionY( 4, game.map.entities[i], object ) then
						game.map.entities[i]:applyVelocity( 0, -game.gravity * 2 )
					end
					game.map.entities[i]:moveBack( )
				end
			end
			for i = 1,#game.map.entities do
				game.map.entities[i]:applyVelocity( 0, game.gravity )
				game.map.entities[i]:update( "y" )
				if game.map.entities[i]:isCollidingWithMap( game.map ) then
					game.map.entities[i].yv = 0
					game.map.entities[i]:moveBack( )
				end
			end
		end
	end
	g.render = function( )
		game.camera[game.func]( game.camera, game.map )
		love.graphics.print( game.camera.x..", "..game.camera.y, 1, 1 )
		love.graphics.print( math.floor( game.camera.x / game.blockSize )..", "..math.floor( game.camera.y / game.blockSize ), 1, 21 )
		love.graphics.print( game.renderdata, 1, 61 )
		love.graphics.print( love.timer.getFPS( ), 1, 41 )
	end
	
	local c = game.states.running:newObject( "Button" )
	c:fillSize( )
	c:lock( )

	c.update = function( self, ev, lastevent )
		if ev[1] == "Mouse" and ev[2] == "Down" and ev[6] == self then
			local x, y, xd, yd = game.camera:getClickPosition( ev[3], ev[4] )
			if ev[5] == "l" then
				local ok = true
				for i = 1,#game.map.entities do
					local col = game.physics.collisionBERR( game.map.entities[i], x, y )
					if col then ok = false end
				end
				if ok then
					local b = game.map:setBlock( x, y, "Stair" )
					if b then
						b.block.xdirection = xd
						b.block.ydirection = yd
					end
					game.renderdata = xd..", "..yd
				end
			else
				game.renderdata = x..", "..y
				game.map:breakBlock( x, y )
			end
		elseif ev[1] == "Keyboard" and ev[2] == "Down" then
			if ev[3] == " " then -- jumping
				local colliding = false
				local y = math.floor( ( game.player.y + game.player.h ) / game.blockSize ) -- gets the block that is containing the bottom of the player
				for x = math.floor( game.player.x / game.blockSize ), math.floor( game.player.x / game.blockSize ) + math.ceil( game.player.w / game.blockSize ) do
					if game.map.blocks[x][y] and game.physics.collisionY( -3, game.player, game.map.blocks[x][y].block ) then -- checks if a block is below the player
						colliding = true
						break
					end
				end
				if colliding then
					game.player:applyVelocity( 0, -8 ) -- if there is a block below, jump
				end
			elseif ev[3] == "tab" then
				game.func = game.func == "render" and "renderCollisionMap" or "render"
			elseif ev[3] == "e" then
				random:toggleActive( )
			end
		end
	end
	c.render = function( ) end
	
	local random = game.states.running:newObject( "Dragable" )
	random:move( "set", 200, 200 )
	random:resize( "set", 100, 50 )
	local state = 1
	random.onClick = function( self )
		self.data.colour = state == 1 and { 0, 0, 255 } or { 0, 255, 0 }
		state = state == 1 and 2 or 1
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
