
local biomes = { 
	Plains = {
		cover = "Dirt:3,Stone:1";
		mxh = 100; -- max height
		mnh = 95; -- min height
		mxg = 1; -- max gradient
		mng = 0; -- min gradient
		mxd = 30; -- max distance
		mnd = 10; -- min distance
		underground = "Stone:100,Copper_Ore:5"; -- block:probability
	};
	Something = {
		cover = "Bamboo:10,Stone:3";
		mxh = 90; -- max height
		mnh = 80; -- min height
		mxg = 2; -- max gradient
		mng = 0; -- min gradient
		mxd = 30; -- max distance
		mnd = 10; -- min distance
		underground = "Stone:1"; -- block:probability
	};
}

loadBiome = function( t )
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

for k, v in pairs( biomes ) do
	biomes[k] = loadBiome( v )
end

game.generation = { 
	newBiome = function( t )
		table.insert( biomes, loadBiome( t ) )
	end;
	getRandomSeed = function( x )
		return x
	end;
	setRandomSeed = function( x )
		-- math.randomseed( game.generation.getRandomSeed( x ) )
	end;
	selection = {
		changeBiome = function( dir )
			game.generation.setRandomSeed( game.generation[dir].x )
			local biome = biomes[game.generation[dir].biome]
			local n = 6
			if game.generation[dir].distance > biome.mnd then
				local n = math.random( 1, game.map.newBiomeChance )
			end
			if n <= 5 or game.generation[dir].distance >= biome.mxd then
				return true
			end
			return false
		end;
		biome = function( dir )
			game.generation.setRandomSeed( game.generation[dir].x )
			local count = 0
			local bs = { }
			for k, v in pairs( biomes ) do
				count = count + 1
				bs[count] = k
			end
			return bs[math.random( 1, count )]
		end;
		ore = function( dir )
			game.generation.setRandomSeed( game.generation[dir].x )
			local biome = biomes[game.generation[dir].biome]
			local n = math.random( 1, biome.underground.max )
			return biome.underground[n]
		end;
		height = function( dir )
			game.generation.setRandomSeed( game.generation[dir].x )
			local biome = biomes[game.generation[dir].biome]
			local height = math.random( biome.mnh, biome.mxh )
			return height
		end;
		heightChange = function( dir )
			game.generation.setRandomSeed( game.generation[dir].x )
			local biome = biomes[game.generation[dir].biome]
			local n = math.random( biome.mng, biome.mxg )
			if game.generation[dir].height > game.generation[dir].toheight then
				return game.generation[dir].height - n
			else
				return game.generation[dir].height + n
			end
		end;
	};
	fill = function( t, s, l, n )
		for i = s, l do
			t[i] = { block = type( n ) == "string" and game.newBlock( n ) or game.newBlock( n.type ) }
		end
	end;
	surfaceFill = function( dir, t )
		local biome = biomes[game.generation[dir].biome]
		local height = game.generation[dir].height
		for h = height, height + #biome.cover - 1 do
			local b = biome.cover[h - height + 1]
			t[h] = { block = game.newBlock( b ) }
		end
		return height + #biome.cover
	end;
	left = {
		x = 0;
		biome = "Plains";
		tobiome = "Plains";
		changing = false;
		height = 100;
		toheight = 100;
		distance = 0;
		data = { };
	};
	right = {
		x = 1;
		biome = "Plains";
		tobiome = "Plains";
		changing = false;
		height = 100;
		toheight = 100;
		distance = 0;
		data = { };
	};
}

game.generation.generateColumn = function( map, dir )
	local column = { }
	column.maxAir = 0
	column.biome = game.generation[dir].biome
	for y = 1,game.mapHeight do
		column[y] = { }
	end
	local nh = game.generation.surfaceFill( dir, column )
	for y = nh, game.mapHeight do
		column[y].block = game.generation.selection.ore( dir )
	end
	local found = true
	for y = 1,game.mapHeight do
		if not column[y].block then
			column[y].block = game.newBlock( "Air" )
			if found then
				column.maxAir = y
			end
		else
			found = false
		end
	end
	if game.generation[dir].height == game.generation[dir].toheight then
		game.generation[dir].toheight = game.generation.selection.height( dir )
	else
		game.generation[dir].height = game.generation.selection.heightChange( dir )
	end
	game.generation[dir].x = game.generation[dir].x + ( dir == "left" and -1 or 1 )
	if game.generation.selection.changeBiome( dir ) then
		game.generation[dir].changing = true
		if game.generation[dir].height < biomes[game.generation[dir].tobiome].mnh or game.generation[dir].height > biomes[game.generation[dir].tobiome].mxh then
			game.generation[dir].toheight = game.generation[dir].height < biomes[game.generation[dir].tobiome].mnh and biomes[game.generation[dir].tobiome].mnh or biomes[game.generation[dir].tobiome].mxh
		else
			
		end
	end
	if game.generation[dir].changing and not ( game.generation[dir].height < biomes[game.generation[dir].tobiome].mnh or game.generation[dir].height > biomes[game.generation[dir].tobiome].mxh ) then
		game.generation[dir].biome = game.generation[dir].tobiome
		game.generation[dir].tobiome = game.generation.selection.biome( dir )
		game.generation[dir].distance = 0
		game.generation[dir].changing = false
	end
	game.generation[dir].distance = game.generation[dir].distance + 1
	return column
end

--[[

		mountain = {
			cover = { 3, 3, 3 };
			mxh = 80;
			mnh = 20;
			gradient = 6;
			ores = { };
			surface = { { id = 32, mxh = map.height, mnh = 1, dist = 4 } };
			length = 30;
		};
		plains = {
			cover = { 3, 3, 3 };
			mxh = 100;
			mnh = 97;
			gradient = 1;
			ores = { };
			surface = { { id = 31, mxh = map.height, mnh = 95, dist = 1 }, { id = 32, mxh = map.height, mnh = 95, dist = 1 } };
			length = 60;
		};
		desert = {
			cover = { 4, 4, 4, 4 };
			mxh = 101;
			mnh = 100;
			gradient = 1;
			ores = { };
			surface = { { id = 33, mxh = map.height, mnh = 1, dist = 5 } };
			length = 40;
		};
		forest = {
			cover = { 3, 3, 3 };
			mxh = 100;
			mnh = 95;
			gradient = 1;
			ores = { };
			surface = { { id = 30, mxh = map.height, mnh = 80, dist = 4 } };
			length = 40;
		};
		quarry = {
			cover = { 3, 7, 7, 7 };
			mxh = 130;
			mnh = 110;
			gradient = 2;
			ores = { };
			surface = { { id = 31, mxh = map.height, mnh = 95, dist = 1 }, { id = 32, mxh = map.height, mnh = 95, dist = 1 } };
			length = 20;
		};
		tundra = {
			cover = { 3, 3, 3, 3 };
			mxh = 100;
			mnh = 80;
			gradient = 2;
			ores = { { min = map.sealevel, max = map.height, id = 55 } }; -- Tin ore
			surface = { { id = 30, mxh = map.height, mnh = 90, dist = 5 } };
			length = 40;
		};
	};
}
]]

--[[

generation.getUndergroundBlock = function( height, biome )
	local matches = { }
	for i = 1,#ores do
		if ores[i].max >= height and ores[i].min <= height then
			table.insert( matches, ores[i].id )
		end
	end
	for i = 1,#generation.biomes[biome].ores do
		if generation.biomes[biome].ores[i].max >= height and generation.biomes[biome].ores[i].min <= height then
			table.insert( matches, generation.biomes[biome].ores[i].id )
		end
	end
	local ore = random( 1, 40 )
	if ore > 1 or #matches < 1 then
		return map.genBlock( 2 )
	end
	return map.genBlock( matches[random( 1, #matches )] )
end

generation.newColumn = function( dir )
	
	local col = { }
	col.biome = generation[dir].biome
	for i = 1,map.height do
		col[i] = map.genBlock( 1 )	
	end
	local up = false
	if generation[dir].data.h < generation[dir].data.th then
		up = true
	end -- hill generation
	local am = random( 0, generation.biomes[generation[dir].biome].gradient )
	if up and generation[dir].data.th - generation[dir].data.h < am then
		am = generation[dir].data.th - generation[dir].data.h
	elseif not up and generation[dir].data.h - generation[dir].data.th < am then
		am = generation[dir].data.h - generation[dir].data.th
	end
	if not up then am = -am end
	generation[dir].data.h = generation[dir].data.h + am
	for i = 1,#generation.biomes[generation[dir].biome].cover do
		col[i+generation[dir].data.h - 1] = map.genBlock( generation.biomes[generation[dir].biome].cover[i] )
	end
	for i = generation[dir].data.h+#generation.biomes[generation[dir].biome].cover, map.height do
		col[i] = generation.getUndergroundBlock( i, generation[dir].biome ) -- ores and stuff
	end
	col.lastair = 300
	for i = 1,map.height do
		if col[i].id ~= 1 then
			col.lastair = i - 1	
			break
		end
	end
	
	local spawn = random( 1, math.floor( #generation.biomes[generation[dir].biome].surface * 1.2 ) + 1 )
	if generation.biomes[generation[dir].biome].surface[spawn] then
		local item = generation.biomes[generation[dir].biome].surface[spawn]
		if not generation[dir].data.dist[map.blocks[item.id].name] or ( dir == "l" and generation[dir].data.dist[map.blocks[item.id].name] >= item.dist or #map.tiles - generation[dir].data.dist[map.blocks[item.id].name] >= item.dist ) then
			if col.lastair >= item.mnh and col.lastair <= item.mxh then
				col[col.lastair] = map.genBlock( item.id )
				col.lastair = col.lastair - 1
				generation[dir].data.dist[map.blocks[item.id].name] = dir == "l" and 1 or #map.tiles + 1
			end
		end
	end
	
	if dir == "l" then
		table.insert( map.tiles, 1, col )
		player.x = player.x + 1
		for i = 1,#map.updaters do
			map.updaters[i].x = map.updaters[i].x + 1
		end
		for i, v in pairs( generation[dir].data.dist ) do
			generation[dir].data.dist[i] = v + 1
		end
		map.spawn = map.spawn + 1
	else
		table.insert( map.tiles, col )	
	end
	
	for i = 1,#map.tiles[dir=="l" and 1 or #map.tiles] do
		if map.tiles[dir=="l" and 1 or #map.tiles][i].update and not map.tiles[dir=="l" and 1 or #map.tiles][i].uc then
			map.newUpdater( dir=="l" and 1 or #map.tiles, i )
		end
	end
	
	if generation[dir].data.h <= generation.biomes[generation[dir].biome].mxh and generation[dir].data.h >= generation.biomes[generation[dir].biome].mnh then
		generation[dir].data.distance = generation[dir].data.distance + 1
	end
	if generation[dir].data.h == generation[dir].data.th then
		if random( 1, 3 ) == 1 and generation[dir].data.distance > generation.biomes[generation[dir].biome].length then
			generation[dir].changing = true
		end
		generation[dir].data.th = random( generation.biomes[generation[dir].biome].mnh, generation.biomes[generation[dir].biome].mxh )
	end
	if generation[dir].changing then
		if generation[dir].data.h <= generation.biomes[generation[dir].tobiome].mxh and generation[dir].data.h >= generation.biomes[generation[dir].tobiome].mnh then
			generation[dir].biome = generation[dir].tobiome
			generation[dir].tobiome = generation.selBiome( )
			generation[dir].data.distance = 0
			generation[dir].changing = false
			generation[dir].data.th = random( generation.biomes[generation[dir].biome].mnh, generation.biomes[generation[dir].biome].mxh )
		else
			generation[dir].data.th = generation[dir].data.h > generation.biomes[generation[dir].tobiome].mxh and generation.biomes[generation[dir].tobiome].mxh or generation.biomes[generation[dir].tobiome].mnh
		end
	end
end

]]