
game.newCameraObject = function( )
	local t = { }
	t.x, t.y = 1, 1
	t.w, t.y = 2, 2
	t.link = false

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

	t.render = function( self, map, entities )
		if self.link then
			self.x, self.y = self.link.x, self.link.y
			self.w, self.h = self.link.w, self.link.h
		end
		local w, h = game.blockCountX, game.blockCountY
		local cx, cy = love.graphics.getWidth( ) / 2, love.graphics.getHeight( ) / 2
		local xo, yo = self.x - cx + self.w / 2, self.y - cy + self.h / 2
		love.graphics.translate( -xo, -yo )
		for x = math.floor( self.x / game.blockSize - w/2 ), math.ceil( self.x / game.blockSize + w/2 ) do
			for y = math.floor( self.y / game.blockSize - h/2 ), math.ceil( self.y / game.blockSize + h/2 ) + math.floor( self.h / game.blockSize / 2 ) do
				if map.blocks[x] and map.blocks[x][y] then
					map.blocks[x][y].block:render( x * game.blockSize, y * game.blockSize )
				end
			end
		end
		for i = 1,#map.entities do
			map.entities[i]:render( )
		end
		love.graphics.translate( xo, yo )
	end
	
	t.getLeftClipping = function( self )
		if self.link then
			self.x, self.y = self.link.x, self.link.y
			self.w, self.h = self.link.w, self.link.h
		end
		return math.floor( ( self.x - love.graphics.getWidth( ) / 2 ) / game.blockSize )
	end
	
	t.getRightClipping = function( self )
		if self.link then
			self.x, self.y = self.link.x, self.link.y
			self.w, self.h = self.link.w, self.link.h
		end
		return math.ceil( ( self.x + love.graphics.getWidth( ) / 2 ) / game.blockSize )
	end
	return t
end
