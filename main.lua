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
	local g = game.states.running:newObject( "Updater" )
	g:lock( )

	game.player = game.newEntityObject( )
	game.player:resize( 50, 100 )
	game.camera = game.newCameraObject( )
	game.camera:linkTo( game.player )
	table.insert( game.map.entities, game.player )
	game.player:move( "set", 0, 3800 )
	
	g.update = function( self, ev )
		if ev[1] == "update" then
			local xl = game.camera:getLeftClipping( )
			local xr = game.camera:getRightClipping( )
			if not game.map.blocks[xl] then
				game.map:newColumn( xl, "left" )
			end
			if not game.map.blocks[xr] then
				game.map:newColumn( xr, "right" )
			end
			if love.keyboard.isDown( "d" ) then
				game.player:applyVelocity( 0.2, 0 )
			end
			if love.keyboard.isDown( "a" ) then
				game.player:applyVelocity( -0.2, 0 )
			end
			game.player:update( "x" )
			local colliding, object = game.player:isCollidingWithMap( game.map )
			if colliding then
				if not game.physics.collisionUp( 2, game.player, object ) then
					game.player:applyVelocity( 0, -game.gravity * 2 )
				end
				game.player:moveBack( )
			end
			game.player:applyVelocity( 0, game.gravity )
			game.player:update( "y" )
			if game.player:isCollidingWithMap( game.map ) then
				game.player.yv = 0
				game.player:moveBack( )
			end
		elseif ev[1] == "Mouse" and ev[2] == "Down" then
			local x, y = game.camera:getClickPosition( ev[3], ev[4] )
			game.map:setBlock( x, y, "Stair" )
			game.renderdata = x..", "..y
		elseif ev[1] == "Keyboard" and ev[2] == "Down" then
			if ev[3] == " " then
				game.player:applyVelocity( 0, -30 )
			elseif ev[3] == "tab" then
				game.func = game.func == "render" and "renderCollisionMap" or "render"
			end
		end
	end
	g.render = function( )
		game.camera[game.func]( game.camera, game.map )
		love.graphics.print( game.camera.x..", "..game.camera.y, 1, 1 )
		love.graphics.print( math.floor( game.camera.x / game.blockSize )..", "..math.floor( game.camera.y / game.blockSize ), 1, 21 )
		love.graphics.print( game.renderdata, 1, 41 )
	end
end

function love.update( dt )
	game.interface.run.update( game.interface )
end

function love.keypressed( key, uni )
	game.interface.run.keypressed( game.interface, key, uni )
end

function love.mousepressed( x, y, button )
	game.interface.run.mousepressed( game.interface, x, y, button )
end

function love.draw( )
	game.interface.run.render( game.interface )
end
