
game.blocks = {
	["Air"] = {
		solid = false;
		transparent = true;
		render = function( self, x, y )
			if y > game.seaLevel then
				
			else
				love.graphics.draw(  )
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
	t.isColliding = function( self, x, y, w, h )
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
		return l >= r
	end
	return t
end

game.newBlock = function( type )
	local block = game.newBlockObject( )
	block:setType( type )
	return block
end

local blocks = love.filesystem.enumerate( "Resources/Blocks" )
for k, v in pairs( blocks ) do
	local images = love.filesystem.enumerate( "Resources/Blocks/"..v.."/Images" )
	for i = 1,#images do
		local name = images[i]:sub( 1, #images[i] - 4 )
		game.images["Blocks."..v.."."..name] = love.graphics.newImage( "Resources/Blocks/"..v.."/Images/"..images[i] )
	end
end
