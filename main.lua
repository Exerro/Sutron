-- Define some global game variables that we will be needing later

game.blockSize = 32
game.images = { }
game.mapHeight = 256 -- mapWidth is infinite
game.seaLevel = 128
game.blockCountX = math.ceil( love.graphics.getWidth( ) / game.blockSize )
game.blockCountY = math.ceil( love.graphics.getHeight( ) / game.blockSize )

-- require high level classes (Core classes)
require "Resources/Utils"
require "Resources/Mask"

-- require low level classes (Game Classes)
require "Resources/BlockObject"
require "Resources/InventoryObject"
require "Resources/EntityObject"
require "Resources/Map"

function love.load( )
	-- what will happen when the game loads
	-- nothing....
	
	-- yet
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
	-- draw these high end grapics that really impact your GTX Titan
	love.graphics.print( game.title, 1, 1 )
end
