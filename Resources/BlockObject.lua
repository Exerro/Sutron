
game.blocks = {
	["Air"] = {
		solid = false;
		transparent = true;
		render = function( self, x, y )
			if self.position.y > game.seaLevel then
				love.graphics.draw( game.imageData.Blocks.Air.belowGround.image, x, y )
			else
				love.graphics.draw( game.imageData.Blocks.Air.aboveGround.image, x, y )
			end
		end;
		getCollisionMap = function( self )
			if self.position.y > game.seaLevel then
				return game.imageData.Blocks.Air.belowGround.collisionMap
			else
				return game.imageData.Blocks.Air.aboveGround.collisionMap
			end
		end;
	};
}

game.blockUpdateMethods = {
	["Flowing"] = function( self, map )
		
	end;
	["Gravity"] = function( self, map )
		
	end;
}

game.newBlockObject = function( parent )
	local t = { }
	t.position = { x = 1, y = 1, w = 1, h = 1 }
	t.parent = parent
	t.type = "Air"
	t.blockType = ""
	t.image = false
	t.damage = 0
	t.maxDamage = 1
	t.transparent = false
	t.solid = true -- collision

	t.render = function( self, x, y )
		if game.imageData.Blocks[self.type] and not self.transparent then
			local x, y = x or self.position.x, y or self.position.y
			love.graphics.draw( game.imageData.Blocks[self.type].Texture.image, x, y )
		end
	end
	t.getCollisionMap = function( self )
		return game.imageData.Blocks[self.type].Texture.image
	end
	t.update = function( self )
		
	end
	t.setType = function( self, type )
		self.type = type
		if game.blocks[type] then
			for k, v in pairs( game.blocks[type] ) do
				self[k] = v
			end
		end
	end
	t.setParent = function( self, parent )
		self.parent = parent or self.parent
	end
	t.move = function( self, x, y )
		if self.position.x == x and self.position.y == y then return end
		self.position.x = x or self.position.x
		self.position.y = y or self.position.y
		if self.parent and self.parent.move then
			self.parent:move( x, y )
		end
	end
	t.setTransparency = function( self, bool )
		self.transparent = not not bool
	end
	t.setSolid = function( self, bool )
		self.solid = not not bool
	end
	t.addDamage = function( self, am )
		self.damage = self.damage + am
		if self.damage >= self.maxDamage and self.onDestroy then
			self:onDestroy( )
		end
	end
	t.isColliding = function( self, other )
		if not self.solid then return false end
		local x, y, w, h = other.x, other.y, other.w, other.h
		local x2, y2, w2, h2 = self.position.x * game.blockSize, self.position.y * game.blockSize, game.blockSize, game.blockSize
		local t, b
		if y2 > y then
			t, b = y2, y + h - 1
		else
			t, b = y, y2 + h2 - 1
		end
		if t > b then return false end
		local l, r
		if x2 > x then
			r, l = x2, x + w - 1
		else
			r, l = x, x2 + w2 - 1
		end
		if l < r then return false end
		return true
	end
	return t
end

game.newBlock = function( type )
	local block = game.newBlockObject( )
	block:setType( type )
	return block
end
