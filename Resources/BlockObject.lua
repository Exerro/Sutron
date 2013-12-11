
local blocks = {
	["Air"] = {
		solid = false;
		transparent = true;
		render = function( self, x, y )
			if y > game.seaLevel then
				love.graphics.draw( game.imageData.Blocks.Air.belowGround.image )
			else
				love.graphics.draw( game.imageData.Blocks.Air.aboveGround.image )
			end
		end;
		getCollisionMap = function( self )
			local y = self.position.y
			if y > game.seaLevel then
				love.graphics.draw( game.imageData.Blocks.Air.belowGround.image )
			else
				love.graphics.draw( game.imageData.Blocks.Air.aboveGround.image )
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

game.createBlockObject = function( parent )
	local t = { }
	t.position = { x = 1, y = 1, w = game.blockSize, h = game.blockSize }
	t.parent = parent -- or nil
	t.type = "Air"
	t.blockType = ""
	t.image = false
	t.damage = 0
	t.maxDamage = 1
	t.transparent = false
	t.solid = false -- collision

	t.render = function( self, x, y )
		if self.image and not self.transparent then
			local x, y = x or self.position.x, y or self.position.y
			love.graphics.draw( self.image, x, y )
		end
	end
	t.getCollisionMap = function( self )
		return game.imageData.Blocks[self.type].Texture.image
	end
	t.update = function( self )
		
	end
	t.setType = function( self, type )
		self.type = type
		self.image = game.images["Blocks."..type] or love.graphics.newImage( "Resources/Blocks/"..type.."/Image.png" )
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
		self.position.x = x or self.position.x
		self.position.y = y or self.position.y
		if self.parent then
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
		local x, y, w, h = other.x, other.y, other.w, other.h
		local t, b
		if self.position.y > y then
			t, b = self.position.y, y + h - 1
		else
			t, b = y, self.position.y + self.position.h - 1
		end
		if t > b then return false end
		local l, r
		if self.position.y > y then
			r, l = self.position.x, x + w - 1
		else
			r, l = x, self.position.x + self.position.w - 1
		end
		if l < r then return false end
		
	end
	return t
end

game.newBlock = function( type )
	local block = game.newBlockObject( )
	block:setType( type )
	return block
end
