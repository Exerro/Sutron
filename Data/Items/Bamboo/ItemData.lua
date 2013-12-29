
item.useInMap = function( self, map, x, y )
	local x = math.floor( x / map.blockSize )
	local y = math.floor( y / map.blockSize )
	map:breakBlock( x, y )
	map:placeBlock( x, y, "Bamboo" )
end
