
local items = {
	
}

game.items = { }
game.newItemObject = function( )
	local i = { }
	i.name = "Stone"
	i.type = "Block"
	i.emitLightSource = false; -- think about it ok?
	i.blockBreakingTimes = { };
	i.typeBreakingTimes = { };
	
	i.useInMap = function( self, map, x, y, xd, yd )
		if self.type == "Block" then
			local ok = true
			for i = 1,#map.entities do
				local col = game.physics.collisionBERR( map.entities[i], x, y )
				if col then ok = false end
			end
			if ok then
				local b = map:placeBlock( x, y, self.name )
				if b then
					b.block.xdirection = xd
					b.block.ydirection = yd
				end
			end
		elseif self.type == "Tool" then
			local block = map.blocks[x] and map.blocks[x][y] and map.blocks[x][y].block or false
			if block then
				if block.name ~= "Air" and block.blockType == self.toolType then
					map:breakBlock( x, y, self.toolSpeed )
				elseif block.name ~= "Air" then
					map:breakBlock( x, y )
				end
			end
		end
	end

	i.render = function( self, image, x, y, dir )
		if not game.data.Items[self.name][image] then return end
		local image = game.data.Items[self.name][image].image
		if dir == "right" then
			x = x + 20
		end
		love.graphics.draw( image, x, y, 0, dir == "right" and -1 or 1 )
	end;
	i.setType = function( self, type )
		game.items[type] = self
		self.name = type
		self.itemName = type
		if items[type] then
			for k, v in pairs( items[type] ) do
				self[k] = v
			end
		end
		if self.load then
			self:load( )
		end
		self:setData( game.data.Items[type] )
	end
	i.setData = function( self, t )
		if not t["ItemData"] then return end
		local data = t.ItemData.data
		local env = { }
		env.item = self
		env.game = game
		setmetatable( env, { __index = getfenv( ) } )
		setfenv( data, env )
		data( )
	end
	return i
end

for k, v in pairs( game.data.Items ) do
	local i = game.newItemObject( )
	i:setType( k )
end
