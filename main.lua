-- Define some global game variables that we will be needing later

-- define all the grapical storage
game.mask = { }
game.mask.image = { }
game.mask.data = { }
game.mask.data.collision = { }

-- require high level classes (Core classes)
require "Resources/Utils"
require "Resources/Mask"

-- require low level classes (Game Classes)
require "Resources/BlockObject"
require "Resources/InventoryObject"
require "Resources/EntityObject"
require "Resources/CameraObject"
require "Resources/Map"

function love.load( )
	-- loadAll() -- load all the images from the folders using the mask class
	-- Changed this to be called at the end of mask.lua -Ben

	game.entity = game.newEntityObject( )
	game.camera = game.newCameraObject( )
	game.camera:linkTo( game.entity )
end

function love.update( dt )
	if love.keyboard.isDown( "d" ) then
		game.entity:move( "add", 1, 0 )
	elseif love.keyboard.isDown( "a" ) then
		game.entity:move( "add", -1, 0 )
	end
end

function love.keypressed( key, uni )
	-- keyboard press
end

function love.mousepressed( x, y, button )
	-- mouse press
end

function love.draw( )
	love.graphics.print( game.camera.x..", "..game.camera.y, 1, 1 )
	game.camera:render( game.map )
end
