
block.render = function( self, x, y, map )
	love.graphics.draw( game.data.Blocks["Stone"].Texture.image, x, y )
	love.graphics.draw( game.data.Blocks["Copper_Ore"].Texture.image, x, y )
end
block.getCollisionMap = function( self )
	return game.data.Blocks.Stone.Texture.collisionMap.left.down
end
block.maxdamage = 2;