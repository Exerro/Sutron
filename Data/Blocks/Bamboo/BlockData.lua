
block.load = function( self )
	self.inventory = game.engine.inventory.create( )
	self.inventory:setSlotTemplate( "Block Demo" )
	self.lightSource = { radius = 8, level = 16 }
end;
block.event = function( self, side, data )
	if side == "down" and data == "BreakBefore" then
		self.parent.parent:breakBlock( self.parent.x, self.parent.y )
	end
end;
block.solid = false;
