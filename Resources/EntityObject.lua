
game.newEntityObject = function( )
    local t = { }
    t.x, t.y = 1, 1
    t.w, t.h = 1, 1
    t.frames = { }
    t.frame = 1
    
    t.render = function( self )
      if self.frames[self.frame] then
        love.graphics.draw( self.frames[self.frame], self.x, self.y )
      end
      self.frame = self.frame + 1
      if self.frame > #self.frames then
          self.frame = 1
      end
    end
    
    t.move = function( self, mode, x, y )
      if mode == "add" then
        self.x = self.x + x
        self.y = self.y + y
      elseif mode == "set" then
        self.x = x
        self.y = y
      else
        error( "Unsupported movement mode: "..tostring( mode )..", use \"set\" or \"add\"" )
    end
    return t
end
