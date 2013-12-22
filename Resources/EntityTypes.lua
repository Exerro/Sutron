
game.newPlayerEntity = function( )
	local ent = game.newEntityObject( true )
	ent.hotbar = game.newHotbarObject( )
	ent.onCollision = function( self, other, data )
		if other.type == "Block" then
			self:moveBack( )
			if data == "X" then
				if not game.physics.collisionY( 4, self, other ) then
					self:applyVelocity( 0, -self.map.gravity * 2 )
				end
				self.xv = 0
			elseif data == "Y" then
				self.yv = 0
			end
		end
	end
	ent.entityType = "Player"
	return ent
end

game.newItemEntity = function( t )
	local ent = game.newEntityObject( true )
	if t then
		for i = 1,#t do
			ent.inventory:newSlot( 1, 1 )
			ent.inventory:addItem( t[i].name, t[i].count )
		end
	end
	ent.onCollision = function( self, other, data )
		if other.type == "Entity" and other.entityType == "Player" then
			if other.hotbar:addInventory( self.inventory ) or other.inventory:addInventory( self.inventory ) then
				self.removeFromMap = true
			end
		elseif other.type == "Block" then
			self:moveBack( )
		elseif other.type == "Entity" and other.entityType == "Item" then
			if not other.removeFromMap and other.inventory:addInventory( self.inventory ) then
				self.removeFromMap = true
			else
				self:moveBack( )
			end
		end
	end
	ent.entityType = "Item"
	return ent
end
