
local structures = {
	Block = {
		name = "Block";
		minspacing = 1;
		width = 5;
		height = 5;
		canoverlap = false;
		spawnchance = "1:5";
		getTileMap = function( )
			local tm = game.engine.tilemap.create( )
			local str = [[Block:1:Stone
Row1#1#1#1#1
Row1#1#1#1#1
Row1#1#1#1#1
Row1#1#1#1#1
Row1#1#1#1#1]]
			tm:loadFromString( str )
			return tm
		end;
	};
	Lake = {
		name = "Lake";
		canoverlap = false;
		spawnchance = "1:10";
		height = 5;
		width = 7;
		minspacing = 3;
		getTileMap = function( )
			local tm = game.engine.tilemap.create( )
			local str = [[Block:1:Empty
Block:2:Bamboo
Block:3:Air
Row1#3#3#3#3#3#1
Row3#3#3#3#3#3#3
Row1#2#2#2#2#2#1
Row1#1#2#2#2#1#1
Row1#1#1#1#1#1#1]]
			tm:loadFromString( str )
			return tm
		end;
		getSpawnHeight = function( self, gendata, data, dir )
			return math.random( gendata.height - 2, 128 )
		end;
		checkHeightChange = function( self, height, gendata, data )
			return height
		end;
	}
}

game.resource.structure = { }
game.resource.structure.get = function( struct )
	if type( struct ) == "string" then
		struct = structures[struct]
	end
	if type( struct ) ~= "table" then
		return
	end
	local s = game.engine.structure.create( )
	s:setData( struct )
	return s
end
