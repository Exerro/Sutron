
local sfont = love.graphics.newFont( 8 )

local types = {
	["Player Inventory"] = function( self )
		local t = { }
		local i = 1
		for y = 1,5 do
			for x = 1,10 do
				local s = self:newSlot( x * 50 + 5, y * 50 + 30 )
				i = i + 1
			end
		end
		return { }
	end;
	["Block Demo"] = function( self )
		return { { 50, 50, 5, "Iron Pickaxe" } }
	end;
}

for k, v in pairs( types ) do
	game.newInventoryTemplate( k, v )
end

game.hotbar = game.states.running:newFrame( )
game.hotbar.data.selection = 1
game.hotbar:resize( "set", 400, 40 )
game.hotbar:move( "set", ( love.graphics.getWidth( ) - 400 ) / 2, love.graphics.getHeight( ) - 50 )
game.hotbar.slots = { }
for i = 1,10 do
	local b = game.hotbar:newObject( "Button" )
	game.hotbar.slots[i] = b
	b:setX( i * 40 - 39 )
	b:resize( "set", 40, 40 )
	b.data.index = i
	b.data.item = { name = "empty", count = 0 }
	b.render = function( self )
		local x, y = self:getPosition( true )
		if self.data.Parent.data.selection == self.data.index then
			love.graphics.draw( game.data.GUI.InventorySlot.Selected.image, x, y )
		else
			love.graphics.draw( game.data.GUI.InventorySlot.Deselected.image, x, y )
		end
		local item = game.items[self.data.item.name]
		if item and self.data.item.name ~= "empty" and self.data.item.count > 0 then
			item:render( "Inventory", self:getX( true ) + 4, self:getY( true ) + 4, "left" )
		elseif self.data.item.name ~= "empty" and self.data.item.count > 0 then
			love.graphics.print( self.data.item.name, self:getX( true ), self:getY( true ) + 4 )
		end
		local f = love.graphics.getFont( )
		love.graphics.setFont( sfont )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.print( tostring( self.data.item.count ), self:getX( true ), self:getY( true ) + self:getHeight( ) - 10 )
		love.graphics.setFont( f )
	end
	b.onClick = function( self, button )
		if not game.activeInventory then
			self.data.Parent.data.selection = self.data.index
		else
			if game.activeInventory.ct.data.item.count == 0 or game.activeInventory.ct.data.item.name == "empty" then
				-- replace the hand with the slot
				game.activeInventory.ct.data.item.name = self.data.item.name
				if button == "l" then
					game.activeInventory.ct.data.item.count = self.data.item.count
					self.data.item = { count = 0, name = "empty" }
				else
					game.activeInventory.ct.data.item.count = math.ceil( self.data.item.count / 2 )
					self.data.item.count = math.floor( self.data.item.count / 2 )
				end
			elseif self.data.item.count == 0 or self.data.item.name == "empty" or self.data.item.name == game.activeInventory.ct.data.item.name then
				-- replace the slot with the hand
				self.data.item.name = game.activeInventory.ct.data.item.name
				if button == "l" then
					self.data.item.count = self.data.item.count + game.activeInventory.ct.data.item.count
					game.activeInventory.ct.data.item.count = 0
					game.activeInventory.ct.data.item.name = "empty"
				else
					self.data.item.count = self.data.item.count + 1
					game.activeInventory.ct.data.item.count = game.activeInventory.ct.data.item.count - 1
				end
			else
				-- swap
				local n, c = self.data.item.name, self.data.item.count
				self.data.item.name = game.activeInventory.ct.data.item.name
				self.data.item.count = game.activeInventory.ct.data.item.count
				game.activeInventory.ct.data.item.name = n
				game.activeInventory.ct.data.item.count = c
			end
			game.activeInventory.frame:focus( game.activeInventory.ct )
			game.renderdata = game.activeInventory.ct.data.item:getCount( )
		end
	end
end
game.hotbar.addItem = function( self, name, count )
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
game.hotbar.useItem = function( self, map, x, y, xd, yd )
	local item = game.items[self.slots[self.data.selection].data.item.name]
	if item then
		item:useInMap( map, x, y, xd, yd )
	elseif self.slots[self.data.selection].data.item.name == "empty" or self.slots[self.data.selection].data.item.count == 0 then
		map:breakBlock( x, y )
	end
end