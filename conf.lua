
game = { }
game.w = 1080
game.h = 720
game.title = "Sutron Development Release"
game.window = { }

function love.conf( t )
	t.screen.width = game.w
	t.screen.height = game.h
	t.title = game.title
	game.window = t
end