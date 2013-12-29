
local col = 0
local cdir = 1

block.render = function( self, x, y )
	love.graphics.setColor( col, col, col )
	love.graphics.rectangle( "fill", x, y, self.parent.parent.blockSize, self.parent.parent.blockSize )
	col = col + cdir
	if col > 254 then
		cdir = - 1
	elseif col < 1 then
		cdir = 1
	end
end

local lastMove = 0

block.updater = function( self )
	lastMove = game.resource.block.updaters.Gravity.update( self, lastMove )
end

block.event = function( self, dir, event, ... )
	local data = { ... }
	game.resource.block.updaters.Gravity.event( self, dir, event, data )
end
