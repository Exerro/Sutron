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
