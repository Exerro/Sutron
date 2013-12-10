require "Resources/Generation"

game.map = { }
game.map.newColumn = function( self, x )
	self[x] = game.generation.generateColumn( self, x )
	for y = 1,#self[x] do
		self[x][y].parent = self[x][y]
		self[x][y].light = 0
		self[x][y].x = x
		self[x][y] = y
		self[x][y].move = function( self, x, y )
			if game.map[x] and game.map[x][y] and game.map[x][y].onDestroy then
				game.map[x][y]:onDestroy( "Replace" )
			end
			if game.map[x] and game.map[x][y] then
				game.map[x][y] = game.map[self.x][self.y]
				game.map[self.x][self.y] = game.newBlock( "Air" )
			end
			return false
		end
	end
end

-- lighting will be done in the map, i.e map[y][x].lighting
-- this is so when you move a block you don't necessarily need to do a lighting update
