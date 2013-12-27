
block.blockType = "Soft"
block.maxDamage = 4
block.render = function( self, x, y, map )
	love.graphics.draw( game.data.Blocks.Dirt.Texture.image, x, y )
	local grass = game.data.Blocks.Dirt.GrassTop.image
	if self.parent.y < map.seaLevel / 2 or map.blocks[self.parent.x].biome == "Tundra" then
		grass = game.data.Blocks.Dirt.SnowTop.image
	end
	if map.blocks[self.parent.x][self.parent.y-1] and ( map.blocks[self.parent.x][self.parent.y-1].block.transparent or not map.blocks[self.parent.x][self.parent.y-1].block.solid ) then
		love.graphics.draw( grass, x, y )
	end
	if map.blocks[self.parent.x+1] and ( map.blocks[self.parent.x+1][self.parent.y].block.transparent or not map.blocks[self.parent.x+1][self.parent.y].block.solid ) then
		love.graphics.draw( grass, x + self.map.blockSize, y, math.pi * 0.5 )
	end
	if map.blocks[self.parent.x-1] and ( map.blocks[self.parent.x-1][self.parent.y].block.transparent or not map.blocks[self.parent.x-1][self.parent.y].block.solid ) then
		love.graphics.draw( grass, x, y + self.map.blockSize, math.pi * 1.5 )
	end
end;