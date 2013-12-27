
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
	game.engine.inventory.newTemplate( k, v )
end
