
block.solid = false
block.render = function( self, x, y )
	love.graphics.setColor( 255, 255, 255 )
	if y > self.parent.parent.seaLevel * self.parent.parent.blockSize then
		love.graphics.draw( game.data.Blocks.Air.belowGround.image, x, y )
	else
		love.graphics.draw( game.data.Blocks.Air.aboveGround.image, x, y )
	end
end