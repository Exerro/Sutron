
game = { }
game.w = 720
game.h = 540
game.title = "Sutron Alpha Release"
game.version = "0.1.8"
game.window = { }

function love.conf( t )
	t.screen.width = game.w
	t.screen.height = game.h
	t.title = game.title.." "..game.version
	t.vsync = true
end