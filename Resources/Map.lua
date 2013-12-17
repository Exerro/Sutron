
game.map = { blocks = { }, entities = { } }
game.map.seed = 2
game.map.newBiomeChance = 10

require "Resources/Generation"

game.blockSize = 32
game.mapHeight = 256
game.seaLevel = 128
game.gravity = 0.15

game.blockCountX = math.ceil( love.graphics.getWidth( ) / game.blockSize )
game.blockCountY = math.ceil( love.graphics.getHeight( ) / game.blockSize )

game.map.blockUpdate = function( x, y, data )
	local sides = { { -1, 0, "right" }, { 1, 0, "left" }, { 0, -1, "down" }, { 0, 1, "up" } }
	for i = 1,#sides do
		if game.map.blocks[x+sides[i][1]] and game.map.blocks[x+sides[i][1]][y+sides[i][2]] then
			if game.map.blocks[x+sides[i][1]][y+sides[i][2]].block.blockUpdate then
				game.map.blocks[x+sides[i][1]][y+sides[i][2]].block:blockUpdate( sides[i][3], data )
			end
		end
	end
end

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
			if game.map.blocks[x] and game.map.blocks[x][y] and game.map.blocks[x][y].block.onDestroy then
				game.map.blocks[x][y].block:onDestroy( "Replace" )
			end
			if game.map[x] and game.map[x][y] then
				game.map.blocks[x][y] = game.map.blocks[self.x][self.y]
				game.map.blocks[self.x][self.y] = game.newBlock( "Air" )
				self.x, self.y = x, y
				self.block:move( x, y )
			end
			return false
		end
		self.blocks[x][y].destroy = function( self )
			if self.block.onDestroy then
				self.block:onDestroy( "Break" )
			end
			self.block = game.newBlock( "Air" )
			self.block:setParent( self )
			self.block:move( self.x, self.y )
			game.map.blockUpdate( self.x, self.y, "Break" )
		end
	end
	return self.blocks[x][y]
end

game.map.breakBlock = function( self, x, y )
	if self.blocks[x] and self.blocks[x][y] then
		self.blocks[x][y]:destroy( )
	end
end

game.map.newColumn = function( self, dir )
	if not game.generation[dir] then error( dir ) end
	local x = game.generation[dir].x
	self.blocks[x] = game.generation.generateColumn( self, dir )
	for y = 1,#self.blocks[x] do
		game.map:setBlock( x, y, self.blocks[x][y].block )
		self.blocks[x][y].light = 0
	end
end

for i = 1,math.ceil( game.blockCountX / 2 ) do
	game.map:newColumn( "right" )
	game.map:newColumn( "left" )
end

-- lighting will be done in the map, i.e map[y][x].lighting
-- this is so when you move a block you don't necessarily need to do a lighting update
