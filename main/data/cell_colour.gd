extends Node

enum TilesetColour {
	RED, ORANGE, YELLOW, LIME, GREEN, CYAN, BLUE, PURPLE, PINK, BLACK,
	DESATURATED_RED, DESATURATED_ORANGE, DESATURATED_YELLOW, DESATURATED_LIME, DESATURATED_GREEN, DESATURATED_CYAN, DESATURATED_BLUE, DESATURATED_PURPLE, DESATURATED_PINK, DARK_GREY,
	LIGHT_GREY,
	OFF_WHITE,
	WHITE,
}

var colour_names : Array[String] = [
	"RED", "ORANGE", "YELLOW", "LIME", "GREEN", "CYAN", "BLUE", "PURPLE", "PINK", "BLACK",
	"DESATURATED_RED", "DESATURATED_ORANGE", "DESATURATED_YELLOW", "DESATURATED_LIME", "DESATURATED_GREEN", "DESATURATED_CYAN", "DESATURATED_BLUE", "DESATURATED_PURPLE", "DESATURATED_PINK", "DARK_GREY",
	"LIGHT_GREY",
	"OFF_WHITE",
	"WHITE",
]

var colours_in_tileset : Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0), Vector2i(7, 0), Vector2i(8, 0), Vector2i(9, 0),
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1), Vector2i(9, 1),
	Vector2i(9, 2),
	Vector2i(9, 3),
	Vector2i(9, 4), 
]

var colours_rgba : Array[Color] = [
	Color(255/255.0, 0, 0), 
	Color(173/255.0, 108/255.0, 0), 
	Color(202/255.0, 183/255.0, 27/255.0), 
	Color(73/255.0, 189/255.0, 0), 
	Color(9/255.0, 156/255.0, 44/255.0), 
	Color(0, 189/255.0, 218/255.0), 
	Color(24/255.0, 66/255.0, 202/255.0), 
	Color(131/255.0, 34/255.0, 206/255.0), 
	Color(189/255.0, 11/255.0, 171/255.0),
]

## Converts a vector2i to its equivilent colour name
func vector2i_to_colour_name(vector: Vector2i) -> String:
	for i in range(colours_in_tileset.size()):
		if(colours_in_tileset[i] == vector):
			return colour_names[i]
	printerr("Colour not found")
	return ""
	
## Converts a colour to its equivelent vector2i value
func colour_name_to_vector2i(colour_name: String) -> Vector2i:
	for i in range(colour_names.size()):
		if(colour_names[i] == colour_name):
			return colours_in_tileset[i]
	printerr("Vector2i equivilent not found")
	return Vector2i(-1, -1)
