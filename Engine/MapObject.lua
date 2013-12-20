
-- Generation

local standardUndergroundSpawn = "Stone:100,Copper_Ore:5"

local biomes = { 
	Plains = {
		cover = "Dirt:3,Stone:1";
		mxh = 100; -- max height
		mnh = 95; -- min height
		mxg = 1; -- max gradient
		mng = 0; -- min gradient
		mxd = 30; -- max distance
		mnd = 10; -- min distance
		underground = standardUndergroundSpawn; -- block:probability
		structures = { };
	};
	Something = {
		cover = "Bamboo:1,Stone:3";
		mxh = 90;
		mnh = 80;
		mxg = 2;
		mng = 0;
		mxd = 30;
		mnd = 10;
		underground = standardUndergroundSpawn;
		structures = { };
	};
	Mountain = {
		cover = "Dirt:3";
		mxh = 80;
		mnh = 30;
		mxg = 4;
		mng = 2;
		mxd = 30;
		mnd = 10;
		underground = standardUndergroundSpawn;
		structures = { };
	};
	Desert = {
		cover = "Sand:4,Stone:1";
		mxh = 100;
		mnh = 95;
		mxg = 1;
		mng = 0;
		mxd = 30;
		mnd = 10;
		underground = standardUndergroundSpawn;
		structures = { };
	};
	Forest = {
		cover = "Dirt:4,Stone:1";
		mxh = 100;
		mnh = 95;
		mxg = 2;
		mng = 0;
		mxd = 30;
		mnd = 10;
		underground = standardUndergroundSpawn;
		structures = { { name = "Tree", spacing = 3, } };
	};
	Quarry = {
		cover = "Chalk:4,Stone:1";
		mxh = 140;
		mnh = 110;
		mxg = 1;
		mng = 0;
		mxd = 30;
		mnd = 10;
		underground = standardUndergroundSpawn;
		structures = { };
	};
	Tundra = {
		cover = "Dirt:4,Stone:1";
		mxh = 100;
		mnh = 80;
		mxg = 2;
		mng = 0;
		mxd = 30;
		mnd = 10;
		underground = standardUndergroundSpawn;
		structures = { };
	};
}

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

game.newMapObject = function( )
	local map = { blocks = { }, entities = { } }
	map.seed = 1
	map.blockSize = 32
	map.blockCountX = math.ceil( love.graphics.getWidth( ) / map.blockSize )
	map.blockCountY = math.ceil( love.graphics.getHeight( ) / map.blockSize )
	map.seaLevel = 128
	map.height = map.seaLevel * 2
	map.setRandomSeed = function( self, x )
		-- math.randomseed( math.abs( x ) + map.seed )
	end
	map.generation = {
		map = map;
		biomes = { };
		newBiomeChance = 40;
		newBiomeType = function( self, name, t )
			self.biomes[name] = loadBiome( t )
		end;
		canChangeBiome = function( self, dir )
			self.map:setRandomSeed( game.map.generationData[dir].x )
			local biome = self.biomes[self.map.generationData[dir].biome]
			local n = 6
			if self.map.generationData[dir].distance > biome.mnd then
				local n = math.random( 1, self.newBiomeChance )
			end
			if n <= 5 or self.map.generationData[dir].distance >= biome.mxd then
				return true
			end
			return false
		end;
		getNewBiome = function( self, dir )
			self.map:setRandomSeed( self.map.generationData[dir].x )
			local count = 0
			local bs = { }
			for k, v in pairs( self.biomes ) do
				count = count + 1
				bs[count] = k
			end
			return bs[math.random( 1, count )]
		end;
		getNewOre = function( self, dir )
			self.map:setRandomSeed( game.map.generationData[dir].x )
			local biome = self.biomes[self.map.generationData[dir].biome]
			local n = math.random( 1, biome.underground.max )
			return biome.underground[n]
		end;
		getHeightTarget = function( self, dir )
			self.map:setRandomSeed( game.map.generationData[dir].x )
			local biome = biomes[self.map.generationData[dir].biome]
			local height = math.random( biome.mnh, biome.mxh )
			return height
		end;
		getHeightChange = function( self, dir )
			self.map:setRandomSeed( game.map.generationData[dir].x )
			local biome = self.biomes[self.map.generationData[dir].biome]
			local n = math.random( biome.mng, biome.mxg )
			if self.map.generationData[dir].height > self.map.generationData[dir].toheight then
				return self.map.generationData[dir].height - n
			else
				return self.map.generationData[dir].height + n
			end
		end;
		surfaceFill = function( self, dir, t )
			local biome = self.biomes[self.map.generationData[dir].biome]
			local height = self.map.generationData[dir].height
			for h = height, height + #biome.cover - 1 do
				local b = biome.cover[h - height + 1]
				t[h] = { block = game.newBlock( b ) }
			end
			return height + #biome.cover
		end;
		generateColumn = function( self, dir )
			local column = { }
			column.map = self.map
			column.maxAir = 0
			column.biome = self.map.generationData[dir].biome
			for y = 1,self.map.height do
				column[y] = { }
			end
			local nh = self:surfaceFill( dir, column )
			for y = nh, self.map.height do
				column[y].block = self:getNewOre( dir )
			end
			local found = true
			for y = 1,self.map.height do
				if not column[y].block then
					column[y].block = game.newBlock( "Air" )
					if found then
						column.maxAir = y
					end
				else
					found = false
				end
			end
			if self.map.generationData[dir].height == self.map.generationData[dir].toheight then
				self.map.generationData[dir].toheight = self:getHeightTarget( dir )
			else
				self.map.generationData[dir].height = self:getHeightChange( dir )
			end
			if self:canChangeBiome( dir ) then
				self.map.generationData[dir].changing = true
				if self.map.generationData[dir].height < self.biomes[self.map.generationData[dir].tobiome].mnh or self.map.generationData[dir].height > self.biomes[self.map.generationData[dir].tobiome].mxh then
					self.map.generationData[dir].toheight = self.map.generationData[dir].height < self.biomes[self.map.generationData[dir].tobiome].mnh and self.biomes[self.map.generationData[dir].tobiome].mnh or self.biomes[self.map.generationData[dir].tobiome].mxh
				else
					
				end
			end
			if self.map.generationData[dir].changing and not ( self.map.generationData[dir].height < self.biomes[self.map.generationData[dir].tobiome].mnh or self.map.generationData[dir].height > self.biomes[self.map.generationData[dir].tobiome].mxh ) then
				self.map.generationData[dir].biome = self.map.generationData[dir].tobiome
				self.map.generationData[dir].tobiome = self:getNewBiome( dir )
				self.map.generationData[dir].distance = 0
				self.map.generationData[dir].changing = false
			end
			self.map.generationData[dir].distance = self.map.generationData[dir].distance + 1

			self.map.blocks[self.map.generationData[dir].x] = column
			for i = 1,#self.map.blocks[self.map.generationData[dir].x] do
				self.map:rawSet( self.map.generationData[dir].x, i, self.map.blocks[self.map.generationData[dir].x][i].block )
			end
			self.map.generationData[dir].x = self.map.generationData[dir].x + ( dir == "left" and -1 or 1 )
		end
	}
	map.generationData = {
		left = {
			x = 0;
			biome = "Plains";
			tobiome = "Something";
			changing = false;
			height = 100;
			toheight = 100;
			distance = 0;
			data = { };
		};
		right = {
			x = 1;
			biome = "Plains";
			tobiome = "Tundra";
			changing = false;
			height = 100;
			toheight = 100;
			distance = 0;
			data = { };
		};
	}
	
	map.load = function( self )
		self.load = nil
		for x = 1,self.blockCountX / 2 do
			self.generation:generateColumn( "left" )
			self.generation:generateColumn( "right" )
		end
	end
	map.gravity = 0.2
	
	map.blockUpdate = function( self, x, y, data )
		local sides = { { -1, 0, "right" }, { 1, 0, "left" }, { 0, -1, "down" }, { 0, 1, "up" } }
		for i = 1,#sides do
			if self.blocks[x+sides[i][1]] and self.blocks[x+sides[i][1]][y+sides[i][2]] then
				if self.blocks[x+sides[i][1]][y+sides[i][2]].block.blockUpdate then
					self.blocks[x+sides[i][1]][y+sides[i][2]].block:blockUpdate( sides[i][3], data )
				end
			end
		end
	end
	map.dropItem = function( self, x, y, itemName )
		if not game.data.Items[itemName] then return end
		local block = game.newEntityObject( )
		block:resize( self.blockSize / 2, self.blockSize / 2 )
		block:move( "set", x + self.blockSize / 4, y + self.blockSize / 4 )
		block:newFrame( game.data.Items[itemName].Drop or game.data.Blocks.Crate.Texture )
		block.itemType = itemName
		block.onCollision = function( self, other )
			if other == game.player then
				if game.hotbar:addItem( self.itemType ) or game.player.inventory:addItem( self.itemType ) then
					self.removeFromMap = true
				end
			end
		end
		self:newEntity( block )
	end
	
	map.rawSet = function( self, x, y, block )
		if not self.blocks[x] or not self.blocks[x][y] then return false end
		if type( block ) == "string" then
			local b = game.newBlockObject( block )
			b:setType( block )
			block = b
		end
		self.blocks[x][y] = { block = block, x = x, y = y }
		self.blocks[x][y].block:setParent( self.blocks[x][y] )
		self.blocks[x][y].block.map = self
		self.blocks[x][y].destroy = function( self )
			local map = self.block.map
			if self.block.map:rawSet( self.x, self.y, "Air" ) then
				if self.block.onDestroy then
					self.block:onDestroy( "Break" )
				end
				self.block.map:blockUpdate( self.x, self.y, "Break" )
			end
		end
		return true
	end
	map.rawBreak = function( self, x, y )
		if self.blocks[x] and self.blocks[x][y] then
			self.blocks[x][y]:destroy( )
		end
	end
	map.placeBlock = function( self, x, y, block )
		if self:rawSet( x, y, block ) then
			self:blockUpdate( x, y, "Place" )
		end
	end
	map.breakBlock = function( self, x, y, damage )
		if self.blocks[x] and self.blocks[x][y] then
			self.blocks[x][y].block:addDamage( damage or 1 )
		end
	end;
	
	map.newEntity = function( self, ent )
		table.insert( self.entities, ent )
		ent.map = self
	end
	
	map.updateCollision = function( self )
		local collisions = { }
		for i = 1,#self.entities do
			local bx, by = math.floor( self.entities[i].x / self.blockSize ), math.floor( self.entities[i].y / self.blockSize )
			local bw, bh = math.ceil( self.entities[i].w / self.blockSize ), math.ceil( self.entities[i].h / self.blockSize )
			for x = bx, bx + bw - 1 do
				for y = by, by + bh - 1 do
					if self.blocks[x] and self.blocks[x][y] then
						if self.entities[i]:isColliding( self.blocks[x][y].block ) then
							table.insert( collisions, { self.entities[i], self.blocks[x][y] } )
						end
					end
				end
			end
			for k = 1,#self.entities do
				if self.entities[i] ~= self.entities[k] then
					if self.entities[i]:isColliding( self.entities[k] ) then
						table.insert( collisions, { self.entities[i], self.entities[k] } )
					end
				end
			end
		end
		return collisions
	end
	
	map.applyGravity = function( self, yc )
		for i = 1,#self.entities do
			self.entities[i]:applyVelocity( 0, self.gravity )
			self.entities[i]:update( "y" )
			local col, other = self.entities[i]:isCollidingWithMap( self )
			if col then
				local ok = - self.entities[i].yv
				if yc then
					yc( self.entities[i], other )
				end
				if ok then
					self.entities[i].yv = ok
				end
				self.entities[i]:moveBack( )
			end
		end
	end
	
	map.moveEntity = function( self, ent, xc, yc, grav, dt )
		ent:update( "x", dt )
		local col, other = ent:isCollidingWithMap( self )
		if col then
			local ok = -ent.xv
			if xc then
				ok = xc( ent, other )
			end
			if ok then
				ent.xv = ok
			end
			ent:moveBack( )
		end
		if grav then
			ent:applyVelocity( 0, self.gravity )
		end
		ent:update( "y", dt )
		local col, other = ent:isCollidingWithMap( self )
		if col then
			local ok = -ent.yv
			if yc then
				ok = yc( ent, other )
			end
			if ok then
				ent.yv = ok
			end
			ent:moveBack( )
		end
	end
	
	for k, v in pairs( biomes ) do
		map.generation:newBiomeType( k, v )
	end

	return map
end
