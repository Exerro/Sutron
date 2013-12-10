
require "Resources/Generation"

game.map = { }
game.map.newColumn = function( self, x )
	game.generation.generateColumn( self, x )
end

-- lighting will be done in the map, i.e map[y][x].lighting
-- this is so when you move a block you don't necessarily need to do a lighting update
