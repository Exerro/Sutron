
block.render = function( self, x, y )
	local air = game.engine.block.get( "Air" )
	if air then air:render( x, y ) end
	x = x + ( self.xdirection == "right" and self.parent.parent.blockSize or 0 )
	y = y + ( self.ydirection == "up" and self.parent.parent.blockSize or 0 )
	love.graphics.draw( game.data.Blocks.Stair.Texture.image, x, y, 0, self.xdirection == "right" and -1 or 1, self.ydirection == "up" and -1 or 1 )
end;