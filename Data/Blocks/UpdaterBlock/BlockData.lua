
local col = 0

block.render = function( self, x, y )
	love.graphics.setColor( col, col, col )
	love.graphics.rectangle( "fill", x, y, self.parent.parent.blockSize, self.parent.parent.blockSize )
end

local under = false
local lastMove = 0

block.updater = function( self )
	col = col + 1
	if col > 255 then
		col = 0
	end
	under, lastMove = game.resource.block.updaters.Gravity.update( self, under, lastMove )
end

block.event = function( self, dir, event, ... )
	local data = { ... }
	
	local x, y = self.parent.x, self.parent.y
	under = game.resource.block.updaters.Gravity.event( self, dir, event, data, under )
end
