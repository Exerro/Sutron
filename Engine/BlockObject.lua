
game.engine.block = { }
game.engine.block.create = function( )
	local t = { }
	t.type = "Block"
	t.name = "Air"
	t.itemName = "Air"

	t.damage = 0
	t.maxDamage = 1

	t.xdirection = "left"
	t.ydirection = "down"

	t.ci = false
	t.solid = true

	t.lightSource = false

	t.onDestroy = function( self )
		if self.name ~= "Air" then
			self.map:dropItem( self.parent.x * self.map.blockSize, self.parent.y * self.map.blockSize, self.itemName, 1 )
		end
		if self.inventory then
			local items = self.inventory:getAllItems( )
			local t = { }
			for k, v in pairs( items ) do
				table.insert( t, { name = k, count = v } )
			end
			self.map:dropItem( self.parent.x * self.map.blockSize, self.parent.y * self.map.blockSize, t )
		end
	end;
	
	t.event = function( self, dir, event, ... )
		local data = { ... }
		if event == "Break" and dir == "self" and self.name ~= "Air" then
			local x, y = self:getRealXY( )
			self.parent.parent:dropItem( x, y, self.itemName, 1 )
			if self.inventory then
				local items = self.inventory:getAllItems( )
				local t = { }
				for k, v in pairs( items ) do
					table.insert( t, { name = k, count = v } )
				end
				self.map:dropItem( self.parent.x, self.parent.y, t )
			end
		end
	end

	t.render = function( self, x, y )
		if game.data.Blocks[self.name] and not self.transparent then
			local x, y = x or self.parent.x, y or self.parent.y
			x = x + ( self.xdirection == "right" and self.map.blockSize or 0 )
			y = y + ( self.ydirection == "up" and self.map.blockSize or 0 )
			if not game.data.Blocks[self.name].Texture then
				error( "Could not find texture for "..self.name )
			end
			love.graphics.draw( game.data.Blocks[self.name].Texture.image, x, y, 0, self.xdirection == "right" and -1 or 1, self.ydirection == "up" and -1 or 1 )
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
		if not game.data.Blocks[self.name].Texture then
			error( "Could not find texture for "..self.name )
		end
		return game.data.Blocks[self.name].Texture.collisionMap[x or self.xdirection][y or self.ydirection]
	end
	t.setType = function( self, type )
		self.name = type
		self.itemName = type
		self:setData( game.data.Blocks[type] )
		if self.load then
			self:load( )
		end
	end
	t.setData = function( self, t )
		if not t["BlockData"] then return end
		local data = t.BlockData
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
	t.setSolid = function( self, bool )
		self.solid = not not bool
	end
	t.addDamage = function( self, am )
		self.damage = self.damage + ( am or 1 )
		if self.damage >= self.maxDamage then
			return true
		end
		return false
	end
	t.getRealXY = function( self )
		return self.parent.x * self.map.blockSize, self.parent.y * self.map.blockSize
	end
	return t
end
