
game.engine.tilemap = { }
game.engine.tilemap.create = function( )
	local m = { }
	m.type = "TileMap"
	m.map = { }
	m.setMap = function( self, map, h )
		if type( map ) == "table" then
			self.map = map
		elseif type( map ) == "number" and type( h ) == "number" then
			self.map = { }
			for x = 1,map do
				self.map[x] = { }
				for y = 1,h do
					self.map[x][y] = game.engine.block.create( )
					self.map[x][y]:setType( "Air" )
				end
			end
		end
	end
	m.loadFromString = function( self, str )
		local split = game.split
		local lines = split( str, "\n" )
		local blocks = { }
		for i = #lines, 1, -1 do
			local parts = split( lines[i], ":" )
			if parts[1] == "Block" then
				local id, data = parts[2], table.concat( { unpack( parts, 3 ) }, ":" )
				blocks[id] = data
				table.remove( lines, i )
			end
		end
		for k, v in pairs( blocks ) do
			v = split( v, "." )
			local name, data = v[1], "{}"
			if v[2] then
				data = table.concat( { unpack( v, 2 ) }, "." )
			end
			local f = loadstring( "return "..data )
			if f then
				data = f( )
			else
				data = { }
			end
			blocks[k] = { name = name, data = data }
		end
		local map = { }
		for i = 1,#lines do
			if lines[i]:sub( 1, 3 ) == "Row" then
				local line = split( lines[i]:sub( 4 ), "#" )
				for b = 1,#line do
					local y, x = i, b
					if not map[x] then map[x] = { } end
					map[x][y] = line[b]
				end
			end
		end
		for x = 1,#map do
			for y = 1,#map[x] do
				for i = 1,#map[x][y] do
					if map[x][y]:sub( i, i ) == "{" then
						map[x][y] = { id = map[x][y]:sub( 1, i-1 ), data = map[x][y]:sub( i ) }
						break
					end
				end
				if type( map[x][y] ) == "string" then
					map[x][y] = { id = map[x][y], data = "{}" }
				end
				local data = { }
				if blocks[map[x][y].id] then
					for k, v in pairs( blocks[map[x][y].id].data ) do
						data[k] = v
					end
					map[x][y].name = blocks[map[x][y].id].name
				end
				local s = loadstring( "return "..map[x][y].data )
				if s then
					local t = s( )
					for k, v in pairs( t ) do
						data[k] = v
					end
				else
					error( map[x][y].data )
				end
				map[x][y].data = data
				if map[x][y].name ~= "Empty" then
					local block = game.engine.block.create( )
					block:setType( map[x][y].name )
					block:setData( map[x][y].data )
					map[x][y] = block
				else
					map[x][y] = false
				end
			end
		end
		self.map = map
		return map
	end
	m.loadFromFile = function( self, path )
		if love.filesystem.exists( path ) then
			return self:loadFromString( love.filesystem.read( path ) )
		end
		return false
	end
	m.saveToString = function( self )
		
	end
	m.saveToFile = function( self, path )
		-- just use self:saveToString( )
	end
	m.generate = function( self, col, y, x, m )
		if m then
			x = x - m
		end
		if not self.map[x] then 
			return false
		end
		for yy = y, y + #self.map[x] - 1 do
			if self.map[x][yy-y+1] then
				col[yy] = self.map[x][yy-y+1]
			end
		end
		return true
	end
	return m
end
