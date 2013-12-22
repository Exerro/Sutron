
block.render = function( self, x, y )
	local x, y = x or self.position.x, y or self.position.y
	game.blocks.Air.render( self, x, y )
	x = x + ( self.xdirection == "right" and self.map.blockSize or 0 )
	y = y + ( self.ydirection == "up" and self.map.blockSize or 0 )
	love.graphics.draw( game.data.Blocks.Stair.Texture.image, x, y, 0, self.xdirection == "right" and -1 or 1, self.ydirection == "up" and -1 or 1 )
end;