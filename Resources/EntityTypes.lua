
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
				self:moveBack( )
			end
		end
	end
	ent.entityType = "Item"
	return ent
end

game.resource.entity.newProjectile = function( xspeed, yspeed, w, h )
	local ent = game.engine.entity.create( )
	ent:resize( w, h )
	ent:applyVelocity( xspeed, yspeed )
	ent.weight = 1
	ent.entityType = "Projectile"
	ent.yfriction = 0.99
	ent.xfriction = 0.99
	ent.onCollision = function( self, other, data )
		if self:getSpeed( ) < 0.5 then
			self.removeFromMap = true
			return
		end
		if other.type == "Block" then
			self:moveBack( )
			local map = other.parent.parent
			if self:getSpeed( ) > 3 then
				map:hitBlock( other.parent.x, other.parent.y, self:getSpeed( ) * 3, "Projectile", self )
				self.xv = self.xv * 0.7
				self.yv = self.yv * 0.7
			else
				self.xv = 0
				self.yv = 0
				local o = { }
				o.x, o.y = other:getRealXY( )
				o.w, o.h = other.parent.parent.blockSize, other.parent.parent.blockSize
				self:pushFrom( o, 0.2 )
			end
		end
	end
	return ent
end
