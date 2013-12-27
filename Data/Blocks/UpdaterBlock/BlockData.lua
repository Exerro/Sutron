
local col = 255

block.render = function( self, x, y )
	love.graphics.setColor( col, col, col )
	love.graphics.rectangle( "fill", x, y, self.parent.parent.blockSize, self.parent.parent.blockSize )
end

block.updater = function( self )
	col = col + 1
	if col > 255 then
		col = 0
	end
end
