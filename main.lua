-- Define some global game variables that we will be needing later

-- define all the grapical storage
game.mask = { }
game.mask.image = { }
game.mask.data = { }
game.mask.data.collision = { }
game.func = "render"
game.renderdata = "Hi"

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
	-- loadAll() -- load all the images from the folders using the mask class
	-- Changed this to be called at the end of mask.lua -Ben

	game.player = game.newEntityObject( )
	game.player:resize( 50, 100 )
	game.camera = game.newCameraObject( )
	game.camera:linkTo( game.player )
	table.insert( game.map.entities, game.player )
	game.player:move( "set", 0, 3800 )
end

function love.update( dt )
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
	game.player:applyVelocity( 0, game.gravity )
	game.player:update( "x" )
	if game.player:isCollidingWithMap( game.map ) then
		game.player:moveBack( )
	end
	game.player:update( "y" )
	if game.player:isCollidingWithMap( game.map ) then
		game.player.yv = 0
		game.player:moveBack( )
	end
end

function love.keypressed( key, uni )
	if key == " " then
		game.player:applyVelocity( 0, -30 )
	elseif key == "tab" then
		game.func = game.func == "render" and "renderCollisionMap" or "render"
	end
end

function love.mousepressed( x, y, button )
	local x, y = game.camera:getClickPosition( x, y )
	game.map:setBlock( x, y, "Stair" )
	game.renderdata = x..", "..y
end

function love.draw( )
	game.camera[game.func]( game.camera, game.map )
	love.graphics.print( game.camera.x..", "..game.camera.y, 1, 1 )
	love.graphics.print( math.floor( game.camera.x / game.blockSize )..", "..math.floor( game.camera.y / game.blockSize ), 1, 21 )
	love.graphics.print( game.renderdata, 1, 41 )
end
