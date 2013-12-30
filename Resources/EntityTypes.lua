
game.resource.entity = game.resource.entity or { }
game.resource.entity.newPlayer = function( )
	local ent = game.engine.entity.create( )
	ent.inventory = game.engine.inventory.create( )
	ent.inventory:setSlotTemplate( "Player Inventory" )
	ent.hotbar = game.engine.inventory.createHotbar( )
	ent.camera = game.engine.camera.create( )
	ent.camera:linkTo( ent )
	ent.onCollision = function( self, other, data )
		if other.type == "Block" then
			if data == "X" then
				if not game.physics.collisionY( 4, self, other ) then
					self:applyVelocity( 0, -self.map.gravity * 2 )
				end
			elseif data == "Y" then
				self.yv = 0
			end
			self:pushFrom( { x = other.parent.x * other.parent.parent.blockSize, y = other.parent.y * other.parent.parent.blockSize, w = other.parent.parent.blockSize, h = other.parent.parent.blockSize }, 0.3 )
			self:moveBack( )
		end
	end
	ent.entityType = "Player"
	return ent
end

game.resource.entity.newItem = function( t )
	local ent = game.engine.entity.create( )
	ent.inventory = game.engine.inventory.create( )
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
				self:pushFrom( other, self:getSpeed( ) )
				other:pushFrom( self, other:getSpeed( ) )
			end
		end
	end
	ent.entityType = "Item"
	return ent
end

game.resource.entity.newProjectile = function( angle, speed, w, h )
	local ent = game.engine.entity.create( )
	ent:resize( w, h )
	ent:applyRadialVelocity( angle, speed )
	ent.entityType = "Projectile"
	ent.yfriction = 0.99
	ent.xfriction = 0.99
	ent.onCollision = function( self, other, data )
		self.removeFromMap = true
		if other.type == "Block" and self:getSpeed( ) > 1 then
			local map = other.parent.parent
			map:hitBlock( other.parent.x, other.parent.y, self:getSpeed( ) * 3, "Projectile", self )
		elseif other.type == "Entity" then
			if other.entityType == "Item" then
				other:applyVelocity( self.xv * 0.1, self.yv * 0.1 )
			end
		end
	end
	return ent
end
