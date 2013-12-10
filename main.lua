
game.blockSize = 32
game.images = { }
game.mapHeight = 256 -- mapWidth is infinite
game.seaLevel = 128
game.blockCountX = math.ceil( love.graphics.getWidth( ) / game.blockSize )
game.blockCountY = math.ceil( love.graphics.getHeight( ) / game.blockSize )

require "Resources/BlockObject"
require "Resources/InventoryObject"
require "Resources/EntityObject"
require "Resources/Map"

function love.load( )
	
end

function love.update( dt )
	
end

function love.keypressed( key, uni )
	
end

function love.mousepressed( x, y, button )
	
end

function love.draw( )
	love.graphics.print( game.title, 1, 1 )
end