
require "Resources/Generation"

game.blockSize = 32
game.mapHeight = 256
game.seaLevel = 128
game.gravity = 0.3

game.blockCountX = math.ceil( love.graphics.getWidth( ) / game.blockSize )
game.blockCountY = math.ceil( love.graphics.getHeight( ) / game.blockSize )

game.map = { blocks = { }, entities = { } }

game.map.setBlock = function( self, x, y, block )
	if type( block ) == "string" then
		block = game.newBlock( block )
	end
	if self.blocks[x] and self.blocks[x][y] then
		self.blocks[x][y] = { block = block }
		self.blocks[x][y].block:setParent( self.blocks[x][y] )
		self.blocks[x][y].block:move( x, y )
		self.blocks[x][y].x = x
		self.blocks[x][y].y = y
		self.blocks[x][y].move = function( self, x, y )
			if x == self.x and y == self.y then return end
			if game.map.blocks[x] and game.map.blocks[x][y] and game.map.blocks[x][y].onDestroy then
				game.map.blocks[x][y]:onDestroy( "Replace" )
			end
			if game.map[x] and game.map[x][y] then
				game.map.blocks[x][y] = game.map.blocks[self.x][self.y]
				game.map.blocks[self.x][self.y] = game.newBlock( "Air" )
				self.x, self.y = x, y
				self.block:move( x, y )
			end
			return false
		end
	end
end

game.map.newColumn = function( self, x )
	self.blocks[x] = game.generation.generateColumn( self, x )
	for y = 1,#self.blocks[x] do
		game.map:setBlock( x, y, self.blocks[x][y].block )
		self.blocks[x][y].light = 0
	end
end

for i = 1,math.ceil( game.blockCountX / 2 ) do
	game.map:newColumn( 0, "right" )
	game.map:newColumn( i, "right" )
	game.map:newColumn( -i, "left" )
end

-- lighting will be done in the map, i.e map[y][x].lighting
-- this is so when you move a block you don't necessarily need to do a lighting update
