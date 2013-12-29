
-- Generation

local standardUndergroundSpawn = "Stone:100,Copper_Ore:5"

local overworld_biomes = { 
	Plains = {
		cover = "Dirt:3,Stone:1";
		mxh = 100; -- max height
		mnh = 95; -- min height
		mxg = 1; -- max gradient
		mng = 0; -- min gradient
		mxd = 30; -- max distance
		mnd = 20; -- min distance
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
		mnd = 20;
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
		mnd = 20;
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
		mnd = 20;
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
		mnd = 20;
		underground = standardUndergroundSpawn;
		structures = { };
	};
	Quarry = {
		cover = "Dirt:1,Chalk:6,Stone:1";
		mxh = 140;
		mnh = 110;
		mxg = 1;
		mng = 0;
		mxd = 30;
		mnd = 20;
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
		mnd = 20;
		underground = standardUndergroundSpawn;
		structures = { 
			[1] = {
				name = "Lake";
				minspacing = 1;
				maxspacing = false;
				data = {
					
				};
			};
		};
	};
}

local underworld_biomes = {
	Nether = {
		cover = "Netherrack:1";
		mxh = 100;
		mnh = 80;
		mxg = 1;
		mng = 0;
		mxd = 10000;
		mnd = 1;
		underground = "Netherrack:1";
		structures = { };
	};
}

game.resource.map = { }
game.resource.map.newOverworldMap = function( map )
	local map = map or game.engine.map.create( )
	local structures = { }
	for k, v in pairs( overworld_biomes ) do
		map.generation:addBiomeType( k, game.clone( v ) )
		for i = 1,#v.structures do
			structures[v.structures[i].name] = true
		end
	end
	for k, v in pairs( structures ) do
		map.generation:addStructureType( k, game.resource.structure.get( k ) )
	end
	return map
end

game.resource.map.newUnderworldMap = function( map )
	local map = map or game.engine.map.create( )
	for k, v in pairs( underworld_biomes ) do
		map.generation:addBiomeType( k, game.clone( v ) )
	end
	return map
end
