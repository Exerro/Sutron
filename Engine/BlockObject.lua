
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
			if self.parent.y > self.map.seaLevel then
				love.graphics.draw( game.data.Blocks.Air.belowGround.image, x, y )
			else
				love.graphics.draw( game.data.Blocks.Air.aboveGround.image, x, y )
			end
		end;
		itemName = false;
	};
	["Stair"] = {
		render = function( self, x, y )
			local x, y = x or self.position.x, y or self.position.y
			game.blocks.Air.render( self, x, y )
			x = x + ( self.xdirection == "right" and self.map.blockSize or 0 )
			y = y + ( self.ydirection == "up" and self.map.blockSize or 0 )
			love.graphics.draw( game.data.Blocks.Stair.Texture.image, x, y, 0, self.xdirection == "right" and -1 or 1, self.ydirection == "up" and -1 or 1 )
		end;
	};
	["Dirt"] = {
		render = function( self, x, y, map )
			love.graphics.draw( game.data.Blocks.Dirt.Texture.image, x, y )
			local grass = game.data.Blocks.Dirt.GrassTop.image
			if self.parent.y < map.seaLevel / 2 or map.blocks[self.parent.x].biome == "Tundra" then
				grass = game.data.Blocks.Dirt.SnowTop.image
			end
			if map.blocks[self.parent.x][self.parent.y-1] and ( map.blocks[self.parent.x][self.parent.y-1].block.transparent or not map.blocks[self.parent.x][self.parent.y-1].block.solid ) then
				love.graphics.draw( grass, x, y )
			end
			if map.blocks[self.parent.x+1] and ( map.blocks[self.parent.x+1][self.parent.y].block.transparent or not map.blocks[self.parent.x+1][self.parent.y].block.solid ) then
				love.graphics.draw( grass, x + self.map.blockSize, y, math.pi * 0.5 )
			end
			if map.blocks[self.parent.x-1] and ( map.blocks[self.parent.x-1][self.parent.y].block.transparent or not map.blocks[self.parent.x-1][self.parent.y].block.solid ) then
				love.graphics.draw( grass, x, y + self.map.blockSize, math.pi * 1.5 )
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
		maxdamage = 2;
	};
	["Bamboo"] = {
		frame = 1;
		frames = { };
		load = function( self )
			self.inventory = game.newInventoryObject( )
			self.inventory:setSlotTemplate( "Block Demo" )
		end;
		blockUpdate = function( self, side, data )
			if side == "down" and data == "Break" then
				self.parent:destroy( )
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
	t.lightSource = false

	t.onDestroy = function( self, reason )
		game.renderdata = "Broken: "..self.parent.x * self.map.blockSize..", "..self.parent.y * self.map.blockSize
		if reason == "Break" and self.type ~= "Air" then
			self.map:dropItem( self.parent.x * self.map.blockSize, self.parent.y * self.map.blockSize, self.itemName )
		end
		if self.inventory then
			local items = self.inventory:getAllItems( )
			for k, v in pairs( items ) do
				for i = 1,v do
					self.map:dropItem( self.parent.x * self.map.blockSize, self.parent.y * self.map.blockSize, k )
				end
			end
		end
	end;

	t.render = function( self, x, y )
		if game.data.Blocks[self.type] and not self.transparent then
			local x, y = x or self.parent.x, y or self.parent.y
			x = x + ( self.xdirection == "right" and self.map.blockSize or 0 )
			y = y + ( self.ydirection == "up" and self.map.blockSize or 0 )
			if not game.data.Blocks[self.type].Texture then
				error( "Could not find texture for "..self.type )
			end
			love.graphics.draw( game.data.Blocks[self.type].Texture.image, x, y, 0, self.xdirection == "right" and -1 or 1, self.ydirection == "up" and -1 or 1 )
		end
	end
	t.renderCollisionMap = function( self, x, y )
		if not self.solid then return end
		if not self.ci then
			local idata = love.image.newImageData( self.map.blockSize, self.map.blockSize )
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
		local x, y = x or self.parent.x, y or self.parent.y
		x = x + ( self.xdirection == "right" and self.map.blockSize or 0 )
		y = y + ( self.ydirection == "up" and self.map.blockSize or 0 )
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
		self.itemName = type
		if game.blocks[type] then
			for k, v in pairs( game.blocks[type] ) do
				self[k] = v
			end
		end
		if self.load then
			self:load( )
		end
		self:setData( game.data.Blocks[type] )
	end
	t.setData = function( self, t )
		if not t["BlockData"] then return end
		local data = t.BlockData.data
		local env = { }
		env.block = self
		env.game = game
		setmetatable( env, { __index = getfenv( ) } )
		setfenv( data, env )
		data( )
	end
	t.setParent = function( self, parent )
		self.parent = parent or self.parent
	end
	t.setTransparency = function( self, bool )
		self.transparent = not not bool
	end
	t.setSolid = function( self, bool )
		self.solid = not not bool
	end
	t.addDamage = function( self, am )
		self.damage = self.damage + am
		if self.damage >= self.maxDamage then
			self.parent:destroy( )
		end
	end
	t.getRealXY = function( self )
		return self.parent.x * self.map.blockSize, self.parent.y * self.map.blockSize
	end
	return t
end

game.newBlock = function( type )
	local block = game.newBlockObject( )
	block:setType( type )
	return block
end
