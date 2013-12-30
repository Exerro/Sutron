
-- Todo

local events = { }
local rblocks = { }
for i = 1,1000 do
	rblocks[i] = { }
end
local id = 1

game.engine.event = { }
game.engine.event.create = function( )
	local e = { }
	e.startTime = 0
	e.running = false
	e.endTime = 0
	e.time = 0
	e.onEvent = false
	e.setTime = function( self, time )
		self.time = time
	end
	e.reset = function( self )
		self.startTime = love.timer.getTime( )
		self.endTime = self.startTime + self.time
	end
	e.start = function( self )
		self:reset( )
		self.running = true
	end
	e.cancel = function( self )
		self.running = false
	end
	e.setFunction = function( self, func )
		self.onEvent = func
	end
	table.insert( events, e )
	return e
end

game.engine.event.removeByID = function( id )
	for i = 1,#rblocks do
		for k = #rblocks[i], 1, -1 do
			if rblocks[i][k].parentid == id then
				table.remove( rblocks[i], k )
			end
		end
	end
end

game.engine.event.random = function( n, func, parentid )
	if n <= 1000 and n > 0 then
		table.insert( rblocks[n], { func = func, parentid = id } )
		id = id + 1
	end
end

game.engine.event.multipleRandom = function( min, max, func )
	min = math.min( math.max( min, 1 ), 1000 )
	max = math.max( math.max( max, 1 ), 1000 )
	for i = math.min( min, max ), math.max( min, max ) do
		table.insert( rblocks[i], { func = func, parentid = id } )
	end
	id = id + 1
end

game.engine.event.update = function( )
	local time = love.timer.getTime( )
	for i = 1,#events do
		if events[i].running and events[i].endTime <= time then
			if events[i].onEvent then
				events[i]:onEvent( time )
			end
		end
	end
	local n = math.random( 1, 1000 )
	for i = 1,#rblocks[n] do
		rblocks[n][i]:func( n )
	end
end
