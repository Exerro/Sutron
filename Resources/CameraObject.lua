
game.newCameraObject = function( )
	local t = { }
	t.x, t.y = 1, 1
	t.link = false

	t.move = function( self, x, y )
		self.x, self.y = x, y
	end

	t.linkTo = function( self, link )
		self.link = link
		link.link = self
	end

	t.render = function( self, map )
		local w, h = game.blockCountX, game.blockCountY
		local sw, sh = love.graphics.getHeight( ), love.graphics.getWidth( )
		for x = math.floor( self.x - w/2 ), math.ceil( self.x + w/2 ) do
			for y = math.floor( self.y - h/2 ), math.ceil( self.y + h/2 ) do
				if map[x] and map[x][y] then
					map[x][y]:render( ( self.x - x ) * game.blockSize + sw / 2, ( self.y - y ) * game.blockSize + sh / 2 )
				end
			end
		end
	end
	return t
end
