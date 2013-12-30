
game.engine.particle = { }
game.engine.particle.create = function( )
	local p = { }
	p.size = 1
	p.colour = { 255, 255, 255, 100 }
	p.shape = "circle"
	p.x = 1
	p.y = 1
	p.scaler = 1
	p.xvel = 0
	p.yvel = 0
	p.vscaler = 0
	p.active = true
	
	p.update = function( self )
		self.x = self.x + self.xvel
		self.y = self.y + self.yvel
		self.xvel = self.xvel * self.vscaler
		self.yvel = self.yvel * self.vscaler
		self.size = self.size * self.scaler
	end
	p.applyVelocity = function( self, x, y )
		self.xvel = self.xvel + ( x or 0 )
		self.yvel = self.yvel + ( y or 0 )
	end
	p.render = function( self, x, y )
		if not self.active then return end
		love.graphics.setColor( unpack( self.colour ) )
		if self.shape == "circle" then
			love.graphics.circle( "fill", x, y, self.size )
		elseif self.shape == "rectangle" then
			love.graphics.rectangle( "fill", x - self.size / 2, y - self.size / 2, self.size, self.size )
		end
	end
	p.hide = function( self )
		self.active = false
	end
	p.setColour = function( self, r, g, b )
		self.colour = { r, g, b }
	end
	p.move = function( self, x, y )
		self.x, self.y = x, y
	end
	p.getSpeed = function( self )
		return math.sqrt( self.xvel ^ 2 + self.yvel ^ 2 )
	end
	return p
end
game.engine.particle.createSource = function( )
	local s = { }
	s.particles = { }
	s.x = 1
	s.y = 1
	s.move = function( self, x, y )
		self.x, self.y = x, y
	end
	s.generate = function( self, range, intensity, col )
		for i = 1,intensity do
			local size = math.random( 4, 10 )
			local p = game.engine.particle.create( )
			p:move( self.x, self.y )
			local angle = math.random( 1, 360 ) / 180 * math.pi
			local n = range * 0.3
			local xv, yv = math.sin( angle ) * n, math.cos( angle ) * n
			p:applyVelocity( xv, yv )
			p:setColour( col[1] + math.random( -10, 10 ), col[2] + math.random( -10, 10 ), col[3] + math.random( -10, 10 ) )
			p.vscaler = math.random( 80, 90 ) / 100
			p.scaler = math.random( 95, 100 ) / 100
			table.insert( self.particles, p )
		end
	end
	s.render = function( self )
		for i = 1,#self.particles do
			self.particles[i]:render( self.particles[i].x, self.particles[i].y )
		end
	end
	s.update = function( self )
		for i = #self.particles, 1, -1 do
			self.particles[i]:update( )
			if self.particles[i].size < 1 or self.particles[i]:getSpeed( ) < 0.3 then
				self.particles[i]:hide( )
			end
			if not self.particles[i].active then
				table.remove( self.particles, i )
			end
		end
	end
	return s
end
