-- Define some global game variables that we will be needing later

game.blockSize = 32
game.mapHeight = 256 -- mapWidth is infinite
game.seaLevel = 128
game.blockCountX = math.ceil( love.graphics.getWidth( ) / game.blockSize )
game.blockCountY = math.ceil( love.graphics.getHeight( ) / game.blockSize )

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
require "Resources/Map"
require "Resources/CameraObject"

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

function love.update( dt )
	-- tick
end

function love.keypressed( key, uni )
	-- keyboard press
end

function love.mousepressed( x, y, button )
	-- mouse press
end

function love.draw( )
	love.graphics.print( game.camera.x..", "..game.camera.y, 1, 20 )
	-- draw these high end grapics that really impact your GTX Titan
	love.graphics.print( game.title, 1, 1 )
end
