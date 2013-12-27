
block.render = function( self, x, y, map )
	love.graphics.draw( game.data.Blocks["Stone"].Texture.image, x, y )
	love.graphics.draw( game.data.Blocks["Copper_Ore"].Texture.image, x, y )
end;
block.getCollisionMap = function( self )
	return game.data.Blocks.Stone.Texture.collisionMap.left.down
end;
block.event = function( self, dir, event, ... )
	local data = { ... }
	if event == "Break" and dir == "self" then
		local map = self.parent.parent.world:changeMap( "add" )
		self.parent.parent.world:changeEntityMap( self.parent.parent, game.player, self.parent.parent.world:getMapByID( map ) )
	end
end
block.maxdamage = 2;