
game.engine.inventory = { }
game.engine.inventory.parent = game.states.running

game.engine.inventory.active = false
game.engine.inventory.activeHotbar = false

local sfont = love.graphics.newFont( 8 )

local templates = { }
game.engine.inventory.newTemplate = function( name, t )
	templates[name] = t
end

game.engine.inventory.create = function( )
	local i = { }
	
	i.w = 600
	i.h = 400
	i.name = "Inventory"

	-- Frame ( for the GUI )
	i.frame = game.engine.inventory.parent:newFrame( )
	i.frame:resize( "set", i.w, i.h )
	i.frame:move( "set", ( love.graphics.getWidth( ) - i.w ) / 2, ( love.graphics.getHeight( ) - i.h ) / 2 )

	local background = i.frame:newObject( "Button" )
	background.data.colour = { 100, 50, 25 }
	if game.data.GUI.InventoryBackground then
		background.data.image = game.data.GUI.InventoryBackground.image
	end
	background:fillSize( )
	background:lock( )
	
	local nameDisplay = i.frame:newObject( "Text" )
	nameDisplay:move( "set", 30, 20 )
	nameDisplay:setFont( 25 )
	nameDisplay:resize( "set", nameDisplay.data.font:getWidth( i.name ) + 5, 30 )
	nameDisplay:setText( i.name )
	nameDisplay:setBackgroundColour( 255, 255, 255, 10 )
	nameDisplay:setTextColour( 0, 0, 0 )
	i.nameDisplay = nameDisplay

	local ct = i.frame:newObject( "Mouse_Tracker" )
	i.ct = ct
	ct:deactivate( )
	ct:resize( "set", 32, 32 )
	ct:deactivate( )
	ct.data.item = { name = "empty", count = 0 }
	ct.data.handlesMouse = false
	ct.data.following = true
	ct.data.solid = false
	ct.render = function( self )
		local item = game.engine.item.get( self.data.item.name )
		if self.data.item.count > 0 and self.data.item.name ~= "empty" then
			if item then
				item:render( "Inventory", self:getX( true ), self:getY( true ), "left" )
			else
				love.graphics.print( self.data.item.name, self:getX( true ), self:getY( true ) + 4 )
			end
			local f = love.graphics.getFont( )
			love.graphics.setFont( sfont )
			love.graphics.setColor( 255, 255, 255 )
			love.graphics.print( tostring( self.data.item.count ), self:getX( true ), self:getY( true ) + self:getHeight( ) - 10 )
			love.graphics.setFont( f )
		end
	end

	i.slots = { }

	i.newSlot = function( self, x, y )
		local slot = self.frame:newObject( "Button" )
		slot:lock( )
		slot:move( "set", x, y )
		slot:resize( "set", 40, 40 )
		slot.data.item = { name = "empty", count = 0 } --newItemTracker( )
		slot.onClick = function( self, button )
			if ct.data.item.count == 0 or ct.data.item.name == "empty" then
				-- replace the hand with the slot
				ct.data.item.name = self.data.item.name
				if button == "l" then
					ct.data.item.count = self.data.item.count
					self.data.item = { name = "empty", count = 0 } --self.data.item:clear( )
				else
					ct.data.item.count = math.ceil( self.data.item.count / 2 )
					self.data.item.count = math.floor( self.data.item.count / 2 )
				end
			elseif self.data.item.count == 0 or self.data.item.name == "empty" or self.data.item.name == ct.data.item.name then
				-- replace the slot with the hand
				self.data.item.name = ct.data.item.name
				if button == "l" then
					self.data.item.count = self.data.item.count + ct.data.item.count
					ct.data.item = { name = "empty", count = 0 } --ct.data.item:clear( )
				else
					self.data.item.count = self.data.item.count + 1
					ct.data.item.count = ct.data.item.count - 1
				end
			else
				-- swap
				local n, c = self.data.item.name, self.data.item.count
				self.data.item.name = ct.data.item.name
				self.data.item.count = ct.data.item.count
				ct.data.item.name = n
				ct.data.item.count = c
			end
			self.data.Parent:focus( ct )
		end
		slot.render = function( self )
			if self:checkMousePosition( love.mouse.getPosition( ) ) then
				love.graphics.draw( game.data.GUI.InventorySlot.Selected.image, self:getX( true ), self:getY( true ) )
			else
				love.graphics.draw( game.data.GUI.InventorySlot.Deselected.image, self:getX( true ), self:getY( true ) )
			end
			if self.data.item.name ~= "empty" and self.data.item.count > 0 then
				local item = game.engine.item.get( self.data.item.name )
				if item then
					item:render( "Inventory", self:getX( true ) + 4, self:getY( true ) + 4, "left" )
				else
					love.graphics.print( tostring( self.data.item.name ), self:getX( true ), self:getY( true ) + 4 )
				end
				local f = love.graphics.getFont( )
				love.graphics.setFont( sfont )
				love.graphics.setColor( 255, 255, 255 )
				love.graphics.print( tostring( self.data.item.count ), self:getX( true ), self:getY( true ) + self:getHeight( ) - 10 )
				love.graphics.setFont( f )
			end
		end
		table.insert( self.slots, slot )
		return slot, #self.slots
	end
	
	i.setSlotTemplate = function( self, temp )
		if templates[temp] then
			self.name = temp
			self.nameDisplay:setText( self.name )
			self.nameDisplay:resize( "set", self.nameDisplay.data.font:getWidth( self.name ) + 5, 30 )
			self.slots = { }
			local places = templates[temp]( self )
			for i = 1,#places do
				local s = self:newSlot( places[i][1], places[i][2] )
				s.data.item.count = places[i][3] or 0
				s.data.item.name = places[i][4] or "empty"
				places[i] = s
			end
		end
	end
	
	-- Inventory manipulation
	
	i.addItem = function( self, name, count )	
		local count = count or 1
		for i = 1,#self.slots do
			if self.slots[i].data.item.name == name then
				self.slots[i].data.item.count = self.slots[i].data.item.count + count
				return true
			end
		end
		for i = 1,#self.slots do
			if self.slots[i].data.item.name == "empty" or self.slots[i].data.item.count == 0 then
				self.slots[i].data.item.name = name
				self.slots[i].data.item.count = count
				return true
			end
		end
		return false
	end
	
	i.removeItem = function( self, name, count )
		for i = 1,#self.slots do
			if self.slots[i].data.item.name == name and self.slots[i].data.item.count > 0 then
				self.slots[i].data.item.count = self.slots[i].data.item.count - count
				if self.slots[i].data.item.count < 0 then
					local n = math.abs( self.slots[i].data.item.count )
					self.slots[i].data.item.count = 0
					return true, n
				end
				return true, count
			end
		end
		return false
	end
	
	i.getAllItems = function( self )
		local items = { }
		for i = 1,#self.slots do
			if self.slots[i].data.item.name ~= "empty" and self.slots[i].data.item.count > 0 then
				items[self.slots[i].data.item.name] = items[self.slots[i].data.item.name] or 0
				items[self.slots[i].data.item.name] = items[self.slots[i].data.item.name] + self.slots[i].data.item.count
			end
		end
		return items
	end
	
	i.addInventory = function( self, other )
		local ok = true
		for i = 1,#other.slots do
			if other.slots[i].data.item.name ~= "empty" and other.slots[i].data.item.count > 0 then
				if not self:addItem( other.slots[i].data.item.name, other.slots[i].data.item.count ) then
					ok = false
				end
			end
		end
		return ok
	end
	
	-- Making it appear and disappear

	i.frame:deactivate( )
	i.activate = function( self )
		if game.engine.inventory.active then
			game.engine.inventory.active:deactivate( )
		end
		self.frame:activate( )
		game.engine.inventory.active = self
		self.frame.data.Parent:focus( self.frame )
	end
	i.deactivate = function( self )
		game.engine.inventory.active = false
		self.frame:deactivate( )
	end
	i.toggleActive = function( self )
		self.frame:toggleActive( )
	end
	
	return i
end

game.engine.inventory.createHotbar = function( )
	local h = { }
	h.frame = game.engine.inventory.parent:newFrame( )
	h.frame:deactivate( )
	h.frame:resize( "set", 400, 40 )
	h.frame:move( "set", ( love.graphics.getWidth( ) - 400 ) / 2, love.graphics.getHeight( ) - 50 )
	h.frame.parent = h
	h.slots = { }
	h.selection = 1
	for i = 1,10 do
		h.slots[i] = h.frame:newObject( "Button" )
		h.slots[i]:setX( i * 40 - 39 )
		h.slots[i]:resize( "set", 40, 40 )
		h.slots[i].data.index = i
		h.slots[i].data.item = { name = "empty", count = 0 }
		h.slots[i].render = function( self )
			local x, y = self:getPosition( true )
			if self.data.Parent.parent.selection == self.data.index then
				love.graphics.draw( game.data.GUI.InventorySlot.Selected.image, x, y )
			else
				love.graphics.draw( game.data.GUI.InventorySlot.Deselected.image, x, y )
			end
			local item = game.engine.item.get( self.data.item.name )
			if item and self.data.item.name ~= "empty" and self.data.item.count > 0 then
				item:render( "Inventory", x + 4, y + 4, "left" )
			elseif self.data.item.name ~= "empty" and self.data.item.count > 0 then
				love.graphics.print( self.data.item.name, x, y + 4 )
			end
			local f = love.graphics.getFont( )
			love.graphics.setFont( sfont )
			love.graphics.setColor( 255, 255, 255 )
			love.graphics.print( tostring( self.data.item.count ), x, y + self:getHeight( ) - 10 )
			love.graphics.setFont( f or love.graphics.newFont( 12 ) )
		end
		h.slots[i].onClick = function( self, button )
			self.data.Parent.parent.selection = self.data.index
			if game.engine.inventory.active then
				if game.engine.inventory.active.ct.data.item.count == 0 or game.engine.inventory.active.ct.data.item.name == "empty" then
					-- replace the hand with the slot
					game.engine.inventory.active.ct.data.item.name = self.data.item.name
					if button == "l" then
						game.engine.inventory.active.ct.data.item.count = self.data.item.count
						self.data.item = { count = 0, name = "empty" }
					else
						game.engine.inventory.active.ct.data.item.count = math.ceil( self.data.item.count / 2 )
						self.data.item.count = math.floor( self.data.item.count / 2 )
					end
				elseif self.data.item.count == 0 or self.data.item.name == "empty" or self.data.item.name == game.engine.inventory.active.ct.data.item.name then
					-- replace the slot with the hand
					self.data.item.name = game.engine.inventory.active.ct.data.item.name
					if button == "l" then
						self.data.item.count = self.data.item.count + game.engine.inventory.active.ct.data.item.count
						game.engine.inventory.active.ct.data.item.count = 0
						game.engine.inventory.active.ct.data.item.name = "empty"
					else
						self.data.item.count = self.data.item.count + 1
						game.engine.inventory.active.ct.data.item.count = game.engine.inventory.active.ct.data.item.count - 1
					end
				else
					-- swap
					local n, c = self.data.item.name, self.data.item.count
					self.data.item.name = game.engine.inventory.active.ct.data.item.name
					self.data.item.count = game.engine.inventory.active.ct.data.item.count
					game.engine.inventory.active.ct.data.item.name = n
					game.engine.inventory.active.ct.data.item.count = c
				end
				game.engine.inventory.active.frame:focus( game.engine.inventory.active.ct )
			end
		end
	end
	h.addItem = function( self, name, count )
		local count = count or 1
		for i = 1,#self.slots do
			if self.slots[i].data.item.name == name then
				self.slots[i].data.item.count = self.slots[i].data.item.count + count
				return true
			end
		end
		for i = 1,#self.slots do
			if self.slots[i].data.item.name == "empty" or self.slots[i].data.item.count == 0 then
				self.slots[i].data.item.name = name
				self.slots[i].data.item.count = count
				return true
			end
		end
		return false
	end
	
	h.removeItem = function( self, name, count )
		for i = 1,#self.slots do
			if self.slots[i].data.item.name == name and self.slots[i].data.item.count > 0 then
				self.slots[i].data.item.count = self.slots[i].data.item.count - count
				if self.slots[i].data.item.count < 0 then
					local n = math.abs( self.slots[i].data.item.count )
					self.slots[i].data.item.count = 0
					return true, n
				end
				return true, count
			end
		end
		return false
	end
	
	h.addInventory = function( self, other )
		local ok = true
		for i = 1,#other.slots do
			if other.slots[i].data.item.name ~= "empty" and other.slots[i].data.item.count > 0 then
				if not self:addItem( other.slots[i].data.item.name, other.slots[i].data.item.count ) then
					ok = false
				end
			end
		end
		return ok
	end
	h.useItem = function( self, map, x, y, xd, yd )
		local item = game.engine.item.get( self.slots[self.selection].data.item.name )
		if item then
			item:useInMap( map, x, y, xd, yd, self )
		elseif self.slots[self.selection].data.item.name == "empty" or self.slots[self.selection].data.item.count == 0 then
			map:hitBlock( math.floor( x / map.blockSize ), math.floor( y / map.blockSize ), 1, "Hand" )
		end
	end
	
	h.renderItem = function( self, x, y )
		local item = game.engine.item.get( self.slots[self.selection].data.item.name )
		if item then
			local x, y = x or love.mouse.getX( ), y or love.mouse.getY( )
			item:render( "Hand", x, y )
		end
	end
	
	h.activate = function( self )
		self.frame:activate( )
	end
	h.deactivate = function( self )
		
	end
	h.focusOn = function( self )
		self.data.parent:focus( self )
	end
	return h
end
