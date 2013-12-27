
game.engine.camera = { }
game.engine.camera.create = function( )
	local t = { }
	t.x, t.y = 1, 1
	t.w, t.y = 2, 2
	t.link = false
	t.majorType = "Camera"
	t.smoothLighting = false
	t.useCanvas = false
	t.useLighting = true

	t.move = function( self, x, y )
		self.x, self.y = x, y
		if self.link then
			self.x, self.y = self.link.x, self.link.y
			self.w, self.h = self.link.w, self.link.h
		end
	end

	t.linkTo = function( self, link )
		if self.link then
			self.link.link = false
		end
		self.link = link
		if self.link then
			self.link.link = self
		end
	end

	t.render = function( self, map, dist )
		local canvas
		if self.useCanvas then
			canvas = love.graphics.newCanvas( )
			love.graphics.setCanvas( canvas )
		end
		if self.link then
			self.x, self.y = self.link.x, self.link.y
			self.w, self.h = self.link.w, self.link.h
			self.map = self.link.map
			map = self.map
		end
		local w, h = self.map.blockCountX, self.map.blockCountY
		local cx, cy = love.graphics.getWidth( ) / 2, love.graphics.getHeight( ) / 2
		local xo, yo = self.x - cx + self.w / 2, self.y - cy + self.h / 2
		love.graphics.translate( -xo, -yo )
		for x = math.floor( self.x / map.blockSize - w/2 ), math.ceil( self.x / map.blockSize + w/2 ) + 2 do
			for y = math.floor( self.y / map.blockSize - h/2 ), math.ceil( self.y / map.blockSize + h/2 ) + 2 do
				if map.blocks[x] and map.blocks[x][y] then
					local rx, ry = map.blocks[x][y].block:getRealXY( )
					local maxdistance = math.sqrt( ( w / 2 * map.blockSize ) ^ 2 + ( h / 2 * map.blockSize ) ^ 2 )
					local distance = math.sqrt( ( rx - self.x ) ^ 2 + ( ry - self.y ) ^ 2 )
					local rd = distance - maxdistance / 2
					local scaler = math.min( math.max( 0, 1 - ( rd / ( maxdistance / 2 ) ) / 2 ), 1 )
					if not distance then scaler = 1 end
					local light = map.blocks[x][y].light
					local level = math.max( map.blocks[x][y]:getLightLevel( ), 1 )
					if not self.smoothLighting and self.useLighting then
						love.graphics.setColor( level * scaler * 17 * light.red, level * scaler * 17 * light.green, level * scaler * 17 * light.blue )
					end
					map.blocks[x][y].block:render( rx, ry, map )
					if self.smoothLighting then
						local l = 255 - level * scaler * 17
						if l < 0 then l = 0 end
						if l > 255 then l = 255 end
						love.graphics.setColor( 0, 0, 0, 100 )
						love.graphics.rectangle( "fill", rx, ry, map.blockSize, map.blockSize )
					end
					local damage = math.floor( ( map.blocks[x][y].block.damage / map.blocks[x][y].block.maxDamage ) * #game.data["Breaking Animation"] )
					if damage > 0 then
						local damage = damage > 10 and 10 or damage
						love.graphics.draw( game.data["Breaking Animation"][damage].image, rx, ry )
					end
				end
			end
		end
		love.graphics.setColor( 255, 255, 255 )
		for i = 1,#map.entities do
			local rx, ry = map.entities[i].x, map.entities[i].y
			local maxdistance = math.sqrt( ( w / 2 * map.blockSize ) ^ 2 + ( h / 2 * map.blockSize ) ^ 2 )
			local distance = math.sqrt( ( rx - self.x ) ^ 2 + ( ry - self.y ) ^ 2 )
			local rd = distance - maxdistance / 2
			local scaler = math.min( math.max( 0, 1 - ( rd / ( maxdistance / 2 ) ) / 2 ), 1 )
			if not dist then scaler = 1 end
			local x, y = math.floor( ( self.x + 1 ) / map.blockSize ), math.floor( ( self.y + 1 ) / map.blockSize )
			local light, level = { red = 1, green = 1, blue = 1 }, 1
			if map.blocks[x] and map.blocks[x][y] then
				light = map.blocks[x][y].light
				level = math.max( map.blocks[x][y]:getLightLevel( ), 1 )
			end
			love.graphics.setColor( level * scaler * 17 * light.red, level * scaler * 17 * light.green, level * scaler * 17 * light.blue )
			map.entities[i]:render( )
		end
		love.graphics.translate( xo, yo )
		if self.useCanvas then
			love.graphics.setCanvas( )
			love.graphics.draw( canvas )
		end
	end
	
	t.renderCollisionMap = function( self, map )
		if self.link then
			self.x, self.y = self.link.x, self.link.y
			self.w, self.h = self.link.w, self.link.h
			self.map = self.link.map
			map = self.map
		end
		local w, h = map.blockCountX, map.blockCountY
		local cx, cy = love.graphics.getWidth( ) / 2, love.graphics.getHeight( ) / 2
		local xo, yo = self.x - cx + self.w / 2, self.y - cy + self.h / 2
		love.graphics.translate( -xo, -yo )
		for x = math.floor( self.x / map.blockSize - w/2 ), math.ceil( self.x / map.blockSize + w/2 ) + 2 do
			for y = math.floor( self.y / map.blockSize - h/2 ), math.ceil( self.y / map.blockSize + h/2 ) + 2 do
				if map.blocks[x] and map.blocks[x][y] then
					map.blocks[x][y].block:renderCollisionMap( map.blocks[x][y].block:getRealXY( ) )
				end
			end
		end
		for i = 1,#map.entities do
			map.entities[i]:renderCollisionMap( )
		end
		love.graphics.translate( xo, yo )
	end
	
	t.getLeftClipping = function( self )
		if self.link then
			self.x, self.y = self.link.x, self.link.y
			self.w, self.h = self.link.w, self.link.h
			self.map = self.link.map
			map = self.map
		end
		return math.floor( ( self.x - love.graphics.getWidth( ) / 2 ) / self.map.blockSize )
	end
	
	t.getRightClipping = function( self )
		if self.link then
			self.x, self.y = self.link.x, self.link.y
			self.w, self.h = self.link.w, self.link.h
			self.map = self.link.map
			map = self.map
		end
		return math.ceil( ( self.x + love.graphics.getWidth( ) / 2 ) / self.map.blockSize ) + 1
	end
	
	t.getClickPosition = function( self, ox, oy )
		if self.link then
			self.x, self.y = self.link.x, self.link.y
			self.w, self.h = self.link.w, self.link.h
			self.map = self.link.map
			map = self.map
		end
		local cx, cy = love.graphics.getWidth( ) / 2, love.graphics.getHeight( ) / 2
		local x, y = self.x + ( ox - cx ) + self.w / 2, self.y + ( oy - cy ) + self.h / 2
		return math.floor( x / self.map.blockSize ), math.floor( y / self.map.blockSize ), ox + self.w / 2 < cx and "right" or "left", oy + self.h / 2 < cy and "up" or "down"
	end
	
	return t
end
