
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
	s.spawnchance = "1/1"
	s.spawned = { }
	
	s.checkHeightChange = function( self, height, gendata, dir )
		local lowest = height
		for i = 1,#self.spawned do
			if self.spawned[i].dir == dir and not self.spawned[i].canoverlap and lowest < self.spawned[i].y + self.spawned[i].h then
				lowest = self.spawned[i].y + self.spawned[i].h
			end
		end
		return lowest
	end
	s.getSize = function( self )
		return self.width, self.height
	end
	s.canSpawn = function( self, gendata, height, x, w )
		if not self.canspawn then return false end
		local w, h = self:getSize( )
		for i = 1,#gendata.structures do
			if gendata.structures[i].y + gendata.structures[i].h >= height or gendata.structures[i].y <= height + h then
				if not gendata.structures[i].canoverlap or not self.canoverlap then
					return false
				end
			end
		end
		if gendata.nextSpawnPossible then
			if gendata.dir == "right" then
				if gendata.nextSpawnPossible[self.name] < x then
					return false
				end
			else
				if gendata.nextSpawnPossible[self.name] > x + w then
					return false
				end
			end
		end
		return true
	end
	s.getTileMap = function( self, map, gendata, data )
		local tm = game.engine.tilemap.create( )
		tm:setMap( self:getSize( ) )
		return tm
	end
	s.getSpawnChance = function( self )
		local parts = game.split( self.spawnchance, ":" )
		parts[2] = table.concat( { unpack( parts, 2 ) }, ":" )
		local s = loadstring( "return "..parts[1] )
		local s2 = loadstring( "return "..parts[2] )
		local n, n2 = 1, 1
		if s and s2 then
			n, n2 = s( ), s2( )
		end
		return n, n2
	end
	s.getSpawnHeight = function( self, gendata, data, dir )
		local w, h = self:getSize( )
		return gendata.height - h
	end
	s.spawn = function( self, gendata, data, dir )
		local height = self:getSpawnHeight( gendata, data, dir )
		local t = { }
		t.w, t.h = self:getSize( )
		t.y = height
		t.x = gendata.x
		t.dir = dir
		t.canoverlap = self.canoverlap
		t.parent = self
		if dir == "left" then
			t.x = t.x - t.w
		end
		if not self:canSpawn( gendata, height, t.x, t.w ) then return false end
		local mc, mx = self:getSpawnChance( )
		local n = math.random( 1, mx )
		if n > mc then
			return false
		end
		t.tileMap = self:getTileMap( )
		table.insert( gendata.structures, t )
		table.insert( self.spawned, t )
		gendata.sdata.lastSpawn = gendata.sdata.lastSpawn or { }
		gendata.sdata.lastSpawn[self.name] = t.x
		gendata.sdata.nextSpawnPossible = gendata.sdata.nextSpawnPossible or { }
		if dir == "right" then
			gendata.sdata.nextSpawnPossible[self.name] = t.x + t.w - 1 + ( self.minspacing or 0 )
		else
			gendata.sdata.nextSpawnPossible[self.name] = t.x - ( self.minspacing or 0 )
		end
		return true
	end
	s.setData = function( self, t )
		for k, v in pairs( t ) do
			self[k] = v
		end
	end
	return s
end