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
    
    t.render = function( self )
      if self.frames[self.frame] then
        love.graphics.draw( self.frames[self.frame], self.x, self.y, 0, self.direction == "right" and -1 or 1 )
      end
      self.frame = self.frame + 1
      if self.frame > #self.frames then
          self.frame = 1
      end
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
        y = self.x + x
        x = self.y + y
      elseif mode ~= "set" then
        error( "Unsupported movement mode: "..tostring( mode )..", use \"set\" or \"add\"" )
      end
      self.x, self.y = x, y
      if self.link and self.link.move then
      	self.link:move( x, y )
      end
    end
    
    t.moveBack = function( self )
        self:move( self.ox, self.oy )
    end
    
    t.applyVelocity = function( self, x, y )
        self.xv = self.xv + ( x or 0 )
        self.yv = self.yv + ( y or 0 )
        if math.abs( self.xv ) < 0.1 then self.xv = 0 end
        if math.abs( self.yv ) < 0.1 then self.yv = 0 end
    end
    
    t.update = function( self )
        self:move( self.xv, self.yv )
        self:updateVelocity( )
    end
    return t
end
