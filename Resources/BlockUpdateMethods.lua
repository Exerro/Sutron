
game.resource.block = game.resource.block or { }
game.resource.block.updaters = {
	Gravity = {
		update = function( self, under, lastMove )
			local x, y = self.parent.parent.x, self.parent.parent.y
			local time = love.timer.getTime( )
			if not under and self.parent.parent.parent.blocks[x][y+1].block.name == "Air" then
				if time >= lastMove + 0.1 and self.parent.parent.parent:moveBlock( x, y, x, y+1 ) then
					lastMove = time
				end
			elseif self.parent.parent.parent.blocks[x][y+1].block.name ~= "Air" then
				under = true
			end
			return under, lastMove
		end;
		event = function( self, dir, event, data, under )
			if ( event == "BreakAfter" or event == "MoveFromAfter" ) and dir == "down" then
				if self.parent.parent.blocks[self.parent.x][self.parent.y+1].block.name == "Air" then
					return false
				else
					return true
				end
			end
			return under
		end;
	}
}
