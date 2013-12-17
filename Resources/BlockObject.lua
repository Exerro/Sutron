
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
			local x, y = x or self.position.x, y or self.position.y
			game.blocks.Air.render( self, x, y )
			x = x + ( self.xdirection == "right" and game.blockSize or 0 )
			y = y + ( self.ydirection == "up" and game.blockSize or 0 )
			love.graphics.draw( game.data.Blocks.Stair.Texture.image, x, y, 0, self.xdirection == "right" and -1 or 1, self.ydirection == "up" and -1 or 1 )
		end;
	};
	["Dirt"] = {
		render = function( self, x, y, map )
			love.graphics.draw( game.data.Blocks.Dirt.Texture.image, x, y )
			if map.blocks[self.position.x][self.position.y-1] and map.blocks[self.position.x][self.position.y-1].block.transparent then
				love.graphics.draw( game.data.Blocks.Dirt.GrassTop.image, x, y )
			end
			if map.blocks[self.position.x+1] and map.blocks[self.position.x+1][self.position.y].block.transparent then
				love.graphics.draw( game.data.Blocks.Dirt.GrassTop.image, x + game.blockSize, y, math.pi * 0.5 )
			end
			if map.blocks[self.position.x-1] and map.blocks[self.position.x-1][self.position.y].block.transparent then
				love.graphics.draw( game.data.Blocks.Dirt.GrassTop.image, x, y + game.blockSize, math.pi * 1.5 )
			end
		end;
		onDestroy = function( self, reason )
			game.renderdata = "Broken: "..self.position.x * game.blockSize..", "..self.position.y * game.blockSize
			if reason == "Break" then
				local block = game.newEntityObject( )
				block:resize( game.blockSize, game.blockSize )
				block:move( "set", self.position.x * game.blockSize, self.position.y * game.blockSize )
				block:newFrame( game.data.Blocks.Dirt.Texture )
				block.onCollision = function( self, other )
					if other == game.player then
						self.removeFromMap = true
					end
				end
				table.insert( game.map.entities, block )
			end
		end;
	};
	["Copper_Ore"] = {
		render = function( self, x, y, map )
			love.graphics.draw( game.data.Blocks["Stone"].Texture.image, x, y )
			love.graphics.draw( game.data.Blocks["Copper_Ore"].Texture.image, x, y )
		end;
		getCollisionMap = function( self )
			return game.data.Blocks.Stone.Texture.collisionMap.left.down
		end;
	};
	["Bamboo"] = {
		frame = 1;
		frames = { };
		load = function( self )
			for i = 1,5 do
				table.insert( self.frames, game.data.Blocks.Bamboo[tostring( i )] )
			end
		end;
		lastRenderTime = 0;
		render = function( self, x, y )
			game.blocks.Air.render( self, x, y )
			love.graphics.draw( self.frames[self.frame].image, x, y )
			if love.timer.getTime( ) - self.lastRenderTime > 0.5 then
				self.lastRenderTime = love.timer.getTime( )
				self.frame = self.frame + 1
				if self.frame > #self.frames then
					self.frame = 1
				end
			end
		end;
		solid = false;
	}
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
	t.solid = true
	t.xdirection = "left"
	t.ydirection = "down"
	t.ci = false

	t.render = function( self, x, y )
		if game.data.Blocks[self.type] and not self.transparent then
			local x, y = x or self.position.x, y or self.position.y
			x = x + ( self.xdirection == "right" and game.blockSize or 0 )
			y = y + ( self.ydirection == "up" and game.blockSize or 0 )
			love.graphics.draw( game.data.Blocks[self.type].Texture.image, x, y, 0, self.xdirection == "right" and -1 or 1, self.ydirection == "up" and -1 or 1 )
		end
	end
	t.renderCollisionMap = function( self, x, y )
		if not self.solid then return end
		if not self.ci then
			local idata = love.image.newImageData( game.blockSize, game.blockSize )
			local map = self:getCollisionMap( "left", "down" )
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
		local x, y = x or self.position.x, y or self.position.y
		x = x + ( self.xdirection == "right" and game.blockSize or 0 )
		y = y + ( self.ydirection == "up" and game.blockSize or 0 )
		love.graphics.draw( self.ci, x, y, 0, self.xdirection == "right" and -1 or 1, self.ydirection == "up" and -1 or 1 )
	end
	t.getCollisionMap = function( self, x, y )
		if not game.data.Blocks[self.type].Texture then
			error( "Could not find texture for "..self.type )
		end
		return game.data.Blocks[self.type].Texture.collisionMap[x or self.xdirection][y or self.ydirection]
	end
	t.setType = function( self, type )
		self.type = type
		if game.blocks[type] then
			for k, v in pairs( game.blocks[type] ) do
				self[k] = v
			end
		end
		if self.load then
			self:load( )
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
