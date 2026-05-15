extends Node

enum TilesetColour {
	RED, ORANGE, YELLOW, LIME, GREEN, CYAN, BLUE, PURPLE, PINK, BLACK,
	DESATURATED_RED, DESATURATED_ORANGE, DESATURATED_YELLOW, DESATURATED_LIME, DESATURATED_GREEN, DESATURATED_CYAN, DESATURATED_BLUE, DESATURATED_PURPLE, DESATURATED_PINK, DARK_GREY,
	LIGHT_GREY,
	OFF_WHITE,
	WHITE,
}

var colours_in_tileset = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0), Vector2i(7, 0), Vector2i(8, 0), Vector2i(9, 0),
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1), Vector2i(9, 1),
	Vector2i(9, 2),
	Vector2i(9, 3),
	Vector2i(9, 4), 
]
