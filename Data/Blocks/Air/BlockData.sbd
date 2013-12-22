
block.solid = false
block.render = function( self, x, y )
	love.graphics.setColor( 255, 255, 255 )
	if self.parent.y > self.map.seaLevel then
		love.graphics.draw( game.data.Blocks.Air.belowGround.image, x, y )
	else
		love.graphics.draw( game.data.Blocks.Air.aboveGround.image, x, y )
	end
end