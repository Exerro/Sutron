
-- Biomes & generation

local loadBiome = function( t )
	if not t.cover then
		t.cover = { "Dirt" }
	else
		local cover = game.split( t.cover, "," )
		for i = 1,#cover do
			cover[i] = game.split( cover[i], ":" )
			cover[i][2] = tonumber( cover[i][2] )
		end
		t.cover = { }
		for i = 1,#cover do
			for k = 1,cover[i][2] do
				table.insert( t.cover, cover[i][1] )
			end
		end
	end
	if not t.underground then
		t.underground = { max = 1, [1] = "Stone" }
	else
		local under = game.split( t.underground, "," )
		for i = 1,#under do
			under[i] = game.split( under[i], ":" )
			under[i][2] = tonumber( under[i][2] )
		end
		t.underground = { max = 0 }
		for i = 1,#under do
			for k = 1,under[i][2] do
				t.underground.max = t.underground.max + 1
				t.underground[t.underground.max] = under[i][1]
			end
		end
	end
	return t
end

-- Map object

game.engine.map = { }
game.engine.map.create = function( )
	local map = { }
	
	map.seaLevel = 128
	map.height = map.seaLevel * 2
	
	map.blockSize = 32
	map.blockCountX = math.ceil( love.graphics.getWidth( ) / map.blockSize )
	map.blockCountY = math.ceil( love.graphics.getHeight( ) / map.blockSize )
	
	map.updaters = { }
	map.update = function( self )
		for i = 1,#self.updaters do
			self.updaters[i]:func( )
		end
	end
	map.newUpdater = function( self, func, parent )
		table.insert( self.updaters, { func = func, parent = parent, index = #self.updaters } )
		return self.updaters, #self.updaters
	end
	map.removeUpdater = function( self, n )
		if type( n ) == "table" then
			for i = n.index, 1, -1 do
				if self.updaters[i] == n then
					n = i
					break
				end
			end
		elseif type( n ) == "function" then
			for i = #self.updaters, 1, -1 do
				if self.updaters[i].func == n then
					n = i
					break
				end
			end
		end
		if type( n ) ~= "number" then return false end
		table.remove( self.updaters, n )
		return true
	end
	
	map.blocks = { }
	
	map.lighting = { }
	map.lighting.parent = map
	map.lighting.min = 0
	map.lighting.max = 15
	map.lighting.getLevel = function( cx, cy, x, y, r, l )
		local dist = math.sqrt( ( cx - x ) ^ 2 + ( cy - y ) ^ 2 )
		local prop = dist / r
		local level = prop * ( l or 1 )
		if level < self.min then level = self.min end
		if level > self.max then level = self.max end
		return level
	end
	map.lighting.mergeColour = function( c1, c2, a1 )
		local a2 = 1 - a1
		local c = { }
		for i = 1,#c1 do
			c[i] = ( c1[i] * a2 + c2[i] * a1 ) / 2
		end
		return c
	end
	map.lighting.update = function( self, x, y )
		if not self.parent.blocks[x] or not self.parent.blocks[x][y] then return false end
		local light = { level = 0, red = 1, blue = 1, green = 1 }
		local block = self.parent.blocks[x][y]
		for i = 1,#block.lighting do
			if block.lighting[i].level > light.level then
				light = block.lighting[i]
			end
		end
		block.light = light
	end
	map.lighting.applyLighting = function( self, x, y, light )
		if not self.parent.blocks[x] or not self.parent.blocks[x][y] then return false end
		local r = light.radius
		local l = light.level
		local inserted = false
		for xx = x - r, x + r do
			if self.parent.blocks[xx] then
				for yy = y - r, y + r do
					if self.parent.blocks[xx][yy] then
						local distance = math.sqrt( ( x - xx ) ^ 2 + ( y - yy ) ^ 2 )
						if distance < r then
							local p = l / r
							local level = l - distance * p
							if level < self.min then level = self.min end
							if level > self.max then level = self.max end
							local l = { level = level, red = light.red or 1, blue = light.blue or 1, green = light.green or 1, light = light }
							table.insert( self.parent.blocks[xx][yy].lighting, l )
							if level > self.parent.blocks[xx][yy].light.level then
								self.parent.blocks[xx][yy].light = l
							end
						end
					end
				end
			elseif not inserted then
				table.insert( self.parent.generation.data.lights, { x = x, y = y, light = light } )
				inserted = true
			end
		end
	end
	map.lighting.removeLighting = function( self, x, y, light )
		if not self.parent.blocks[x] or not self.parent.blocks[x][y] then return false end
		local light = light or self.parent.blocks[x][y].block.lightSource
		for xx = x - light.radius, x + light.radius do
			for yy = y - light.radius, y + light.radius do
				if self.parent.blocks[xx] and self.parent.blocks[xx][yy] then
					for i = #self.parent.blocks[xx][yy].lighting, 1, -1 do
						if self.parent.blocks[xx][yy].lighting[i].light == light then
							table.remove( self.parent.blocks[xx][yy].lighting, i )
						end
					end
					self:update( xx, yy )
				end
			end
		end
	end
	
	map.newBlock = function( self, x, y, name )
		local block = { }
		block.type = "BlockTracker"
		block.block = game.engine.block.create( )
		block.block:setType( name )
		block.block:setParent( block )
		block.parent = self
		block.x = x
		block.y = y
		block.lighting = { }
		block.light = { level = 0, red = 1, green = 1, blue = 1 }
		block.getLightLevel = function( self )
			if self.parent.blocks[self.x].lastAir >= self.y then
				return 15
			end
			return math.max( self.light.level, ( self.parent.blocks[self.x].lastAir + 15 ) - self.y )
		end
		return block
	end
	
	map.dropItem = function( self, x, y, data, count )
		if type( data ) ~= "table" then
			data = { { name = data, count = count or 1 } }
		end
		local ent = game.resource.entity.newItem( data )
		ent:resize( self.blockSize / 2, self.blockSize / 2 )
		ent:move( "set", x + self.blockSize / 4, y + self.blockSize / 4 )
		if #data == 1 and game.data.Items[data[1].name] and game.data.Items[data[1].name].Drop then
			ent:newFrame( game.data.Items[data[1].name].Drop )
		else
			ent:newFrame( game.data.Blocks.Crate.Texture )
		end
		self:newEntity( ent )
	end
	
	map.dropInventory = function( self, x, y, inventory )
		local i = inventory:getAllItems( )
		local items = { }
		for k, v in pairs( i ) do
			table.insert( items, { name = k, count = v } )
		end
		self:dropItem( x, y, items )
	end
	
	map.rawSet = function( self, x, y, block )
		if type( block ) == "string" then
			b = game.engine.block.create( )
			b:setType( block )
			block = b
		end
		if not self.blocks[x] or not self.blocks[x][y] then return end
		self.blocks[x][y].block = block
		self.blocks[x][y].block:setParent( self.blocks[x][y] )
		if y <= self.blocks[x].lastAir and block.name ~= "Air" then
			self.blocks[x].lastAir = y - 1
		end
		if block.lightSource then
			self.lighting:applyLighting( x, y, block.lightSource )
		end
		if block.updater then
			self:newUpdater( block.updater, block )
		end
	end
	
	map.rawBreak = function( self, x, y )
		if self.blocks[x][y].block.lightSource then
			self.lighting:removeLighting( x, y, self.blocks[x][y].block.lightSource )
		end
		if self.blocks[x][y].block.updater then
			self:removeUpdater( self.blocks[x][y].block.updater )
		end
		self:rawSet( x, y, "Air" )
		if y - 1 == self.blocks[x].lastAir then
			for yy = y, map.height do
				if self.blocks[x][yy].block.name ~= "Air" then
					break
				else
					self.blocks[x].lastAir = yy
				end
			end
		end
	end

	map.blockUpdate = function( self, x, y, sdata, bdata, ... )
		if not self.blocks[x] or not self.blocks[x][y] then return false end
		local args = { ... }
		local directions = { { x = -1, y = 0, name = "right" }, { x = 1, y = 0, name = "left" }, { x = 0, y = -1, name = "down" }, { x = 0, y = 1, name = "up" } }
		for i = 1,#directions do
			local nx, ny = x + directions[i].x, y + directions[i].y
			if self.blocks[nx] and self.blocks[nx][ny] then
				if self.blocks[nx][ny].block.event then
					self.blocks[nx][ny].block:event( directions[i].name, sdata, unpack( args ) )
				end
			end
		end
		self.blocks[x][y].block:event( "self", bdata, unpack( args ) )
		return true
	end
	
	map.rawMove = function( self, x, y, x2, y2 )
		self:rawSet( x2, y2, self.blocks[x][y].block )
		self:rawBreak( x, y )
	end
	
	map.moveBlock = function( self, x, y, x2, y2 )
		local directions = { { x = -1, y = 0, name = "left" }, { x = 1, y = 0, name = "right" }, { x = 0, y = -1, name = "up" }, { x = 0, y = 1, name = "down" } }
		local md
		for i = 1,#directions do
			if directions[i].x + x == x2 and directions[i].y + y == y2 then
				md = directions[i]
				break
			end
		end
		if not md then return false end
		self:blockUpdate( x, y, "MoveFromBefore", md.name )
		self:blockUpdate( x2, y2, "MoveToBefore", md.name )
		self:rawMove( x, y, x2, y2 )
		self:blockUpdate( x, y, "MoveFromAfter", md.name )
		self:blockUpdate( x2, y2, "MoveToAfter", md.name )
		return true
	end
	
	map.breakBlock = function( self, x, y )
		if not self.blocks[x] or not self.blocks[x][y] then return end
		self:blockUpdate( x, y, "BreakBefore", "Break" )
		if self.blocks[x][y].block.inventory then
			local xx, yy = self.blocks[x][y].block:getRealXY( )
			self:dropInventory( xx, yy, self.blocks[x][y].block.inventory )
		end
		self:rawBreak( x, y )
		self:blockUpdate( x, y, "BreakAfter" )
	end
	
	map.placeBlock = function( self, x, y, block )
		if not self.blocks[x] or not self.blocks[x][y] then return false end
		if type( block ) == "string" then
			block = self:newBlock( x, y, block )
		end
		if self.blocks[x][y].block.solid then return end
		-- check for solidity of the block at [x][y]
		self:blockUpdate( x, y, "PlaceBefore", "Replace", block.block )
		self:rawSet( x, y, block.block )
		self:blockUpdate( x, y, "PlaceAfter", "Placed", block.block )
		return block
	end

	map.hitBlock = function( self, x, y, damage )
		if not self.blocks[x] or not self.blocks[x][y] then return false end
		local block = self.blocks[x][y].block
		if block:addDamage( damage ) then
			self:breakBlock( x, y )
		end
	end

	map.generation = { }
	map.generation.data = { }
	
	map.setRandomSeed = function( self, x )
		
	end
	
	map.generation.data.left = {
		x = 0;
		biome = "Plains";
		tobiome = "Something";
		changing = false;
		height = 100;
		toheight = 100;
		distance = 0;
		data = { };
	}
	map.generation.data.right = {
		x = 1;
		biome = "Plains";
		tobiome = "Tundra";
		changing = false;
		height = 100;
		toheight = 100;
		distance = 0;
		data = { };
	}
	map.generation.data.lights = { }
	
	map.generation.parent = map
	map.generation.newBiomeChance = 40 -- 1 in 40 ( I think )
	map.generation.biomes = { }
	
	map.generation.addBiomeType = function( self, name, t )
		self.biomes[name] = loadBiome( t )
	end
	
	map.generation.getNewOre = function( self, dir )
		self.parent:setRandomSeed( self.data[dir].x )
		local biome = self.biomes[self.data[dir].biome]
		local n = math.random( 1, biome.underground.max )
		return biome.underground[n]
	end
	map.generation.getSurfaceFill = function( self, dir, t )
		local t = t or { }
		local biome = self.biomes[self.data[dir].biome]
		local height = self.data[dir].height
		for h = height, height + #biome.cover - 1 do
			t[h] = biome.cover[h - height + 1]
		end
		return t, height + #biome.cover
	end
	
	map.generation.generateColumn = function( self, dir )
		local column = { }
		column.parent = self.parent
		column.lastAir = 0
		-- Surface
		local _, h = self:getSurfaceFill( dir, column )
		-- Ores
		for y = h, self.parent.height do
			column[y] = self:getNewOre( dir )
		end
		-- Air
		local found = false
		for y = 1,self.parent.height do
			if not column[y] then
				column[y] = "Air"
				if not found then
					column.lastAir = y
				end
			else
				found = true
			end
		end
		--Structures?
		return column
	end
	
	map.generation.getHeightTarget = function( self, dir )
		self.parent:setRandomSeed( self.data[dir].x )
		local biome = self.biomes[self.data[dir].biome]
		local height = math.random( biome.mnh, biome.mxh )
		return height
	end
	map.generation.getHeightChange = function( self, dir )
		self.parent:setRandomSeed( self.data[dir].x )
		local biome = self.biomes[self.data[dir].biome]
		local n = math.random( biome.mng, biome.mxg )
		if self.data[dir].height > self.data[dir].toheight then
			return self.data[dir].height - n
		else
			return self.data[dir].height + n
		end
	end
	
	map.generation.canChangeBiome = function( self, dir )
		self.parent:setRandomSeed( self.data[dir].x )
		local biome = self.biomes[self.data[dir].biome]
		local n = 6
		if self.data[dir].distance > biome.mnd then
			local n = math.random( 1, self.newBiomeChance )
		end
		if n <= 5 or self.data[dir].distance >= biome.mxd then
			return true
		end
		return false
	end
	map.generation.selectNewBiome = function( self, dir )
		self.parent:setRandomSeed( self.data[dir].x )
		local count = 0
		local bs = { }
		for k, v in pairs( self.biomes ) do
			count = count + 1
			bs[count] = k
		end
		return bs[math.random( 1, count )]
	end
	
	map.generation.newColumn = function( self, dir )
		-- Height control
		if self.data[dir].height == self.data[dir].toheight then
			self.data[dir].toheight = self:getHeightTarget( dir )
		else
			self.data[dir].height = self:getHeightChange( dir )
		end
		
		-- Distance update
		self.data[dir].distance = self.data[dir].distance + 1
		
		-- Biome control
		if self:canChangeBiome( dir ) then
			self.data[dir].changing = true
			self.data[dir].toheight = self.data[dir].height
			-- Range checking
			if self.data[dir].height < self.biomes[self.data[dir].tobiome].mnh then
				self.data[dir].toheight = self.biomes[self.data[dir].tobiome].mnh
			end
			if self.data[dir].height > self.biomes[self.data[dir].tobiome].mxh then
				self.data[dir].toheight = self.biomes[self.data[dir].tobiome].mxh
			end
		end
		if self.data[dir].changing then
			if self.data[dir].height == self.data[dir].toheight then
				self.data[dir].biome = self.data[dir].tobiome
				self.data[dir].tobiome = self:selectNewBiome( dir )
				self.data[dir].distance = 0
				self.data[dir].changing = false
			end
		end
		
		-- Block creation ( from String to BlockTracker )
		local col = self:generateColumn( dir )
		self.parent.blocks[self.data[dir].x] = { }
		self.parent.blocks[self.data[dir].x].lastAir = col.lastAir
		self.parent.blocks[self.data[dir].x].biome = self.data[dir].biome
		for y = 1,#col do
			self.parent.blocks[self.data[dir].x][y] = self.parent:newBlock( self.data[dir].x, y, col[y] )
		end
		
		-- X update
		self.data[dir].x = self.data[dir].x + ( dir == "left" and -1 or 1 )
	end
	
	map.load = function( self, biome, lb, rb )
		self.load = nil
		local biome = biome or self.generation:selectNewBiome( "left" )
		local lb = lb or self.generation:selectNewBiome( "left" )
		local rb = rb or self.generation:selectNewBiome( "right" )
		self.generation.data.left.biome = biome
		self.generation.data.right.biome = biome
		self.generation.data.left.tobiome = lb
		self.generation.data.right.tobiome = rb
		for x = 1,math.ceil( self.blockCountX / 2 ) do
			self.generation:newColumn( "left" )
			self.generation:newColumn( "right" )
		end
	end
	
	map.entities = { }
	map.gravity = 0.15
	
	map.newEntity = function( self, ent )
		ent.map = self
		table.insert( self.entities, ent )
	end
	
	map.applyGravity = function( self )
		for i = 1,#self.entities do
			self.entities[i]:applyVelocity( 0, self.gravity )
			self.entities[i]:update( "y" )
			self.entities[i]:isCollidingWithMap( self, "Y", true )
		end
	end
	
	map.moveEntity = function( self, ent, xc, yc, grav, dt )
		ent:update( "x", dt )
		ent:isCollidingWithMap( self, "X" )
		if grav then
			ent:applyVelocity( 0, self.gravity )
		end
		ent:update( "y", dt )
		ent:isCollidingWithMap( self, "Y", grav )
	end
	
	map.type = "Map"
	return map
end
