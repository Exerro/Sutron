
game.blockUpdateMethods = {
	["Flowing"] = function( self, map )
		
	end;
	["Gravity"] = function( self, map )
		
	end;
}

game.blocks = {
	["Air"] = {
		solid = false;
		transparent = true;
		render = function( self, x, y )
			if self.position.y > game.seaLevel then
				love.graphics.draw( game.data.Blocks.Air.belowGround.image, x, y )
			else
				love.graphics.draw( game.data.Blocks.Air.aboveGround.image, x, y )
			end
		end;
	};
	["Stair"] = {
		render = function( self, x, y )
			game.blocks.Air.render( self, x, y )
			love.graphics.draw( game.data.Blocks.Stair.Texture.image, x, y )
		end;
	};
	--[[
	["Name"] = {
		maxDamage = number that when is reached by the block damage value, makes the block break
		transparent = set to true to make the block not render
		solid = set to false to make the collision always return false ( so you can walk through it )
		render = function called when it wants to render, called with self, x, y where self is the block object and x, y are screen coords
		getCollisionMap = function that should return a 2d array of boolean values
		update = function that will be called every game update
	}
	]]
}

game.newBlockObject = function( parent )
	local t = { }
	t.position = { x = 1, y = 1, w = 1, h = 1 }
	t.parent = parent
	t.type = "Air"
	t.majorType = "Block"
	t.damage = 0
	t.maxDamage = 1
	t.transparent = false
	t.solid = true -- collision
	t.ci = false

	t.render = function( self, x, y )
		if game.data.Blocks[self.type] and not self.transparent then
			local x, y = x or self.position.x, y or self.position.y
			love.graphics.draw( game.data.Blocks[self.type].Texture.image, x, y )
		end
	end
	t.renderCollisionMap = function( self, x, y )
		if not self.solid then return end
		if not self.ci then
			local idata = love.image.newImageData( game.blockSize, game.blockSize )
			local map = self:getCollisionMap( )
			for y = 1,#map do
				for x = 1,#map[y] do
					if map[y][x] then
						idata:setPixel( x - 1, y - 1, 255, 0, 0, 255 )
					else
						idata:setPixel( x - 1, y - 1, 0, 0, 0, 0 )
					end
				end
			end
			self.ci = love.graphics.newImage( idata )
		end
		love.graphics.draw( self.ci, x, y )
	end
	t.getCollisionMap = function( self )
		return game.data.Blocks[self.type].Texture.collisionMap
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
	t.getRealXY = function( self )
		return self.position.x * game.blockSize, self.position.y * game.blockSize
	end
	return t
end

game.newBlock = function( type )
	local block = game.newBlockObject( )
	block:setType( type )
	return block
end
