
local blocks = { }
game.engine.block = { }

game.engine.block.get = function( type )
	return blocks[type] or false
end

game.engine.block.create = function( )
	local t = { }
	t.type = "Block"
	t.name = "Air"
	t.itemName = "Air"

	t.damage = 0
	t.maxDamage = 1
	t.density = 1

	t.xdirection = "left"
	t.ydirection = "down"

	t.ci = false
	t.solid = true

	t.lightSource = false
	
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
				self.parent.parent:dropItem( self.parent.x, self.parent.y, t )
			end
		end
	end

	t.render = function( self, x, y )
		if game.data.Blocks[self.name] and not self.transparent then
			local x, y = x or self.parent.x, y or self.parent.y
			x = x + ( self.xdirection == "right" and self.parent.parent.blockSize or 0 )
			y = y + ( self.ydirection == "up" and self.parent.parent.blockSize or 0 )
			if not game.data.Blocks[self.name].Texture then
				error( "Could not find texture for "..self.name )
			end
			love.graphics.draw( game.data.Blocks[self.name].Texture.image, x, y, 0, self.xdirection == "right" and -1 or 1, self.ydirection == "up" and -1 or 1 )
		end
	end
	t.renderCollisionMap = function( self, x, y )
		if not self.solid then return end
		if not self.ci then
			local idata = love.image.newImageData( self.parent.parent.blockSize, self.parent.parent.blockSize )
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
		x = x + ( self.xdirection == "right" and self.parent.parent.blockSize or 0 )
		y = y + ( self.ydirection == "up" and self.parent.parent.blockSize or 0 )
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
		if not blocks[type] then
			blocks[type] = game.engine.block.create( )
			blocks[type].name = type
			blocks[type].itemName = type
			blocks[type]:setData( game.data.Blocks[type] )
			if blocks[type].load then
				blocks[type]:load( )
			end
		end
	end
	t.setData = function( self, t )
		if t["BlockData"] then
			local data = t.BlockData
			local env = { }
			env.block = self
			env.game = game
			setmetatable( env, { __index = getfenv( ) } )
			setfenv( data, env )
			data( )
		elseif type( t ) == "table" then
			for k, v in pairs( t ) do
				self[k] = v
			end
		end
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
		return self.parent.x * self.parent.parent.blockSize, self.parent.y * self.parent.parent.blockSize
	end
	return t
end
