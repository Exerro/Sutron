
require "Resources/Generation"

game.blockSize = 32
game.mapHeight = 256
game.seaLevel = 128

game.blockCountX = math.ceil( love.graphics.getWidth( ) / game.blockSize )
game.blockCountY = math.ceil( love.graphics.getHeight( ) / game.blockSize )

game.map = { }
game.map.newColumn = function( self, x )
	self[x] = game.generation.generateColumn( self, x )
	for y = 1,#self[x] do
		self[x][y].block:setParent( self[x][y] )
		self[x][y].block:move( x, y )
		self[x][y].light = 0
		self[x][y].x = x
		self[x][y].y = y
		self[x][y].move = function( self, x, y )
			if x == self.x and y == self.y then return end
			if game.map[x] and game.map[x][y] and game.map[x][y].onDestroy then
				game.map[x][y]:onDestroy( "Replace" )
			end
			if game.map[x] and game.map[x][y] then
				game.map[x][y] = game.map[self.x][self.y]
				game.map[self.x][self.y] = game.newBlock( "Air" )
				self.x, self.y = x, y
				self.block:move( x, y )
			end
			return false
		end
	end
end

for i = 1,game.blockCountX do
	game.map:newColumn( i )
end

-- lighting will be done in the map, i.e map[y][x].lighting
-- this is so when you move a block you don't necessarily need to do a lighting update
