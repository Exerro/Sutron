game.generation = { }

game.generation.generateColumn = function( map, x )
	local column = { }
	for y = 1,game.mapHeight do
		column[y] = { }
		if y < game.seaLevel then
			column[y].block = game.newBlock( "Air" )
		else
			column[y].block = game.newBlock( "Stone" )
		end
	end
	return column
end
