
game.engine.structure = { }
game.engine.structure.create = function( )
	local s = { }
	s.type = "Structure"
	s.name = "Default"
	s.maxspacing = false
	s.minspacing = false
	s.canoverlap = true
	s.width = 1
	s.height = 1
	s.canspawn = true
	
	s.getWidth = function( self, map, gendata, data )
		return self.width
	end
	s.canSpawn = function( self )
		return self.canspawn
	end
	s.getTileMap = function( self, map, gendata, data )
		local tm = game.engine.tilemap.create( )
		tm:setMap( self.width, self.height )
		return tm
	end
	s.setData = function( self, t )
		for k, v in pairs( t ) do
			self[k] = v
		end
	end
	return s
end