
local sfont = love.graphics.newFont( 8 )
game.activeInventory = false

local templates = { }

game.newInventoryTemplate = function( name, t )
	templates[name] = t
end

local newItemTracker = function( )
	local t = { }
	t.name = "empty"
	t.count = 0
	t.getCount = function( self )
		return self.count
	end
	t.addCount = function( self, count )
		self.count = self.count + count
	end
	t.removeCount = function( self, count )
		self.count = self.count - count
		local n = -self.count
		if self.count < 0 then
			self:clear( )
			return false, n
		end
		return true
	end
	t.clear = function( self )
		self.name = "empty"
		self.count = 0
	end
	t.merge = function( self, other )
		if self.name == other.name or self.name == "empty" or self.count == 0 then
			self:addCount( other:getCount( ) )
			other:clear( )
		else
			local sc, sn = self.count, self.name
			self.count = other.count
			self.name = other.name
			other.name = sn
			other.count = sc
		end
	end
	return t
end

game.newInventoryObject = function( )
	local i = { }
	
	i.w = 600
	i.h = 400
	i.name = "Inventory"

	-- Frame ( for the GUI )
	i.frame = game.interface:newFrame( )
	i.frame:resize( "set", i.w, i.h )
	i.frame:move( "set", ( love.graphics.getWidth( ) - i.w ) / 2, ( love.graphics.getHeight( ) - i.h ) / 2 )

	local background = i.frame:newObject( "Button" )
	background.data.colour = { 100, 50, 25 }
	if game.data.GUI.inventoryBackground then
		background.data.image = game.data.GUI.inventoryBackground.image
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

	local ct = i.frame:newObject( "Mouse_Tracker" )
	i.ct = ct
	ct:deactivate( )
	ct:resize( "set", 32, 32 )
	ct:deactivate( )
	ct.data.item = newItemTracker( )
	ct.data.handlesMouse = false
	ct.data.following = true
	ct.data.solid = false
	ct.render = function( self )
		local item = game.items[self.data.item.name]
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
		slot.data.item = newItemTracker( )
		slot.onClick = function( self, button )
			if ct.data.item.count == 0 or ct.data.item.name == "empty" then
				-- replace the hand with the slot
				ct.data.item.name = self.data.item.name
				if button == "l" then
					ct.data.item.count = self.data.item.count
					self.data.item:clear( )
				else
					ct.data.item.count = math.ceil( self.data.item.count / 2 )
					self.data.item.count = math.floor( self.data.item.count / 2 )
				end
			elseif self.data.item.count == 0 or self.data.item.name == "empty" or self.data.item.name == ct.data.item.name then
				-- replace the slot with the hand
				self.data.item.name = ct.data.item.name
				if button == "l" then
					self.data.item.count = self.data.item.count + ct.data.item.count
					ct.data.item:clear( )
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
			game.renderdata = ct.data.item:getCount( )
		end
		slot.render = function( self )
			if self:checkMousePosition( love.mouse.getPosition( ) ) then
				love.graphics.draw( game.data.GUI.InventorySlot.Selected.image, self:getX( true ), self:getY( true ) )
			else
				love.graphics.draw( game.data.GUI.InventorySlot.Deselected.image, self:getX( true ), self:getY( true ) )
			end
			if self.data.item.name ~= "empty" and self.data.item.count > 0 then
				local item = game.items[self.data.item.name]
				if item then
					item:render( "Inventory", self:getX( true ) + 4, self:getY( true ) + 4, "left" )
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
		table.insert( self.slots, slot )
		return slot, #self.slots
	end
	
	i.setSlotTemplate = function( self, temp )
		if templates[temp] then
			self.name = temp
			nameDisplay:setText( i.name )
			nameDisplay:resize( "set", nameDisplay.data.font:getWidth( self.name ) + 5, 30 )
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
	
	-- Making it appear and disappear

	i.frame:deactivate( )
	i.activate = function( self )
		if game.activeInventory then
			game.activeInventory:deactivate( )
		end
		self.frame:activate( )
		game.activeInventory = self
		self.frame.data.Parent:focus( self.frame )
	end
	i.deactivate = function( self )
		game.activeInventory = false
		self.frame:deactivate( )
	end
	i.toggleActive = function( self )
		self.frame:toggleActive( )
	end
	
	return i
end
