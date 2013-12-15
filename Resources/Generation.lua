game.generation = { 
	left = {
		biome = "Plains";
	};
	right = {
		biome = "Plains";
	};
}

game.generation.generateColumn = function( map, x )
	local column = { }
	for y = 1,game.mapHeight / 2 do
		column[y] = { }
		if y < game.seaLevel then
			column[y].block = game.newBlock( "Air" )
		else
			column[y].block = game.newBlock( "Stone" )
		end
	end
	return column
end

--[[

local random = function( m, ma, seed )
	--math.randomseed( seed or map.seed )
	return math.random( m, ma )
end

map.seed = map.seed or os.time( )
generation = {
	l = {
		biome = "plains";
		tobiome = "plains";
		changing = false;
		data = { h = 100, th = random( 95, 100 ), distance = 0, lasttree = 1, dist = { }; };
	};
	r = {
		biome = "plains";
		tobiome = "plains";
		changing = false;
		data = { h = 100, th = random( 95, 100 ), distance = 0, lasttree = 1, dist = { }; };
	};
	biomes = {
		hills = {
			cover = { 3, 3, 3 };
			mxh = 80;
			mnh = 60;
			gradient = 3;
			ores = { };
			surface = { { id = 31, mxh = map.height, mnh = 1, dist = 3 } };
			length = 40;
		};
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

generation.selBiome = function( )
	local count = 0
	for k, v in pairs( generation.biomes ) do
		count = count + 1
	end
	local n = random( 1, count )
	local count = 0
	for k, v in pairs( generation.biomes ) do
		count = count + 1
		if count == n then
			return k
		end
	end
end

local ores = {
    [1] = { id = 50, min = 60, max = map.height }; -- Coal ore
	[2] = { id = 51, min = map.sealevel, max = map.height }; -- Iron ore
	[3] = { id = 52, min = map.sealevel * 2.75, max = map.height }; -- Uranium ore
	[4] = { id = 53, min = map.sealevel, max = map.height }; -- Copper ore
	[5] = { id = 54, min = map.sealevel * 2.75, max = map.height }; -- Diamond ore
	[6] = { id = 55, min = map.sealevel * 2, max = map.height }; -- Tin ore
	[7] = { id = 7, min = 1, max = map.sealevel }; -- Marble
}
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