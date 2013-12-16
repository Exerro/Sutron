
game.newEntityObject = function( )
    local t = { }
    t.x, t.y = 1, 1
    t.ox, t.oy = 1, 1
    t.xv, t.yv = 0, 0
    t.direction = "left"
    t.w, t.h = 1, 1
    t.frames = { }
    t.frame = 1
    t.health = 100
    t.maxhealth = 100
    t.inventory = game.newInventoryObject( )
    t.alive = true
    t.link = false
	t.friction = 0.95
	t.tvel = 20
	t.majorType = "Entity"
	t.ci = false
    
    t.render = function( self )
		if self.frames[self.frame] then
			love.graphics.draw( self.frames[self.frame].image, self.x, self.y, 0, self.direction == "right" and -1 or 1 )
		elseif #self.frames == 0 then
			love.graphics.rectangle( "line", self.x, self.y, self.w, self.h )
		end
		self.frame = self.frame + 1
		if self.frame > #self.frames then
			self.frame = 1
		end
    end
	
	t.renderCollisionMap = function( self )
		if not self.ci then
			local idata = love.image.newImageData( self.w, self.h )
			local map = self:getCollisionMap( )
			for y = 1,#map do
				for x = 1,#map[y] do
					if map[y][x] then
						idata:setPixel( x - 1, y - 1, 255, 255, 0, 255 )
					else
						idata:setPixel( x - 1, y - 1, 0, 0, 0, 0 )
					end
				end
			end
			self.ci = love.graphics.newImage( idata )
		end
		love.graphics.draw( self.ci, self.x, self.y )
	end
	
	t.getCollisionMap = function( self )
		if self.frames[self.frame] then
			return self.frames[self.frame].collisionMap
		end
		if not self.collisionMap then
			self.collisionMap = { }
			for y = 1,self.h do
				self.collisionMap[y] = { }
				for x = 1,self.w do
					self.collisionMap[y][x] = true
				end
			end
		end
		return self.collisionMap
	end
    
    t.newFrame = function( self, frame )
        local image = type( frame ) == "string" and love.graphics.newImage( frame ) or frame
        table.insert( self.frames, image )
    end

    t.setHealth = function( self, health )
    	self.health = health
    	if self.health <= 0 and self.onDeath then
    		self:onDeath( )
    	else
    		self.alive = false
    	end
    end
    
    t.setDirection = function( self, dir )
    	self.direction = dir
	end
	
	t.changeDirection = function( self )
		self.direction = self.direction == "right" and "left" or "right"
	end
    
    t.move = function( self, mode, x, y )
		if mode == "add" then
			x = self.x + x
			y = self.y + y
		elseif mode ~= "set" then
			error( "Unsupported movement mode: "..tostring( mode )..", use \"set\" or \"add\"" )
		end
		self.ox, self.oy = self.x, self.y
		self.x, self.y = math.round( x ), math.round( y )
		if self.link and self.link.move then
			self.link:move( self.x, self.y )
		end
    end
    
    t.moveBack = function( self )
        self:move( "set", self.ox, self.oy )
    end
    
    t.applyVelocity = function( self, x, y )
        self.xv = self.xv + ( x or 0 )
        self.yv = self.yv + ( y or 0 )
        if math.abs( self.xv ) < 0.1 then self.xv = 0 end
        if math.abs( self.yv ) < 0.1 then self.yv = 0 end
		if math.abs( self.xv ) > self.tvel then
			self.xv = self.xv < 0 and -self.tvel or self.tvel
		end
		if math.abs( self.yv ) > self.tvel then
			self.yv = self.yv < 0 and -self.tvel or self.tvel
		end
    end
	
	t.updateVelocity = function( self )
		self.xv = self.xv * self.friction
		self.yv = self.yv * self.friction
	end
    
    t.update = function( self, mode )
		if not mode then
			self:move( "add", self.xv, self.yv )
		elseif mode == "x" then
			self:move( "add", self.xv, 0 )
		elseif mode == "y" then
			self:move( "add", 0, self.yv )
		end
        self:updateVelocity( )
    end
	
	t.resize = function( self, w, h )
		self.w = w
		self.h = h
	end
	
	t.isColliding = function( self, other )
		local ent = other
		if other.majorType == "Block" then
			if not other.solid then return false, "None" end
			ent = { w = game.blockSize, h = game.blockSize }
			ent.x, ent.y = other:getRealXY( )
		end
		local col, l, r, t, b = game.physics.collisionRR( self, ent )
		if not col then return false, "None" end
		local xo, yo = ent.x - self.x, ent.y - self.y
		local col, x, y = game.physics.collisionMM( self:getCollisionMap( ), other:getCollisionMap( ), xo, yo )
		if not col then return false, "Rectangle" end
		return true, x, y
	end
	
	t.isCollidingWithMap = function( self, map )
		local selfx, selfy = math.floor( self.x / game.blockSize ), math.floor( self.y / game.blockSize )
		for x = selfx, selfx + math.ceil( self.w / game.blockSize ) do
			if map.blocks[x] then
				for y = selfy, selfy + math.ceil( self.h / game.blockSize ) do
					if map.blocks[x][y] then
						if self:isColliding( map.blocks[x][y].block ) then
							return true, map.blocks[x][y].block
						end
					end
				end
			end
		end
		for i = 1,#map.entities do
			if self ~= map.entities[i] and self:isColliding( map.entities[i] ) then
				return true, map.entities[i]
			end
		end
		return false
	end
    return t
end
