
game.resource.world = { }
game.resource.world.create = function( )
	local w = { }
	w.maps = { }
	w.currentMap = 1

	w.newMap = function( self, map )
		table.insert( self.maps, map )
		map.world = self
	end
	w.getMapByID = function( self, id )
		return self.maps[id or self.currentMap] or false
	end
	w.setMapByID = function( self, n )
		self.currentMap = ( self.maps[n] and n ) or ( self.maps[self.currentMap] and self.currentMap ) or n
		return self.currentMap == n
	end
	
	w.getMapByMap = function( self, map )
		for i = 1,#self.maps do
			if self.maps[i] == map then
				return i
			end
		end
		return false
	end
	w.setMapByMap = function( self, map )
		self.currentMap = self:getMapByMap( map ) or self.currentMap
	end
	
	w.changeMap = function( self, mode )
		local n = self.currentMap
		if mode == "random" then
			n = math.random( 1, #self.maps )
		elseif mode == "add" then
			n = n + 1
			if n > #self.maps then
				n = 1
			end
		end
		self.currentMap = ( self.maps[n] and n ) or ( self.maps[self.currentMap] and self.currentMap ) or n
		return self.currentMap
	end

	w.changeEntityMap = function( self, map, entity, map2 )
		if type( map ) == "number" then
			if self.maps[map] then
				map = self.maps[map]
			else
				return false
			end
		end
		for i = 1,#map.entities do
			if map.entities[i] == entity then
				table.remove( map.entities, i )
			end
		end
		map2:newEntity( entity )
	end
	
	return w
end
