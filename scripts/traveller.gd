extends Node

class_name Traveller

var tilemap : TileMapLayer

var active_colour : Vector2i = CellColour.colours_in_tileset[CellColour.TilesetColour.RED]
var passed_colour : Vector2i = CellColour.colours_in_tileset[CellColour.TilesetColour.DESATURATED_RED]

var current_position : Vector2i

func _ready() -> void:
	if(get_parent() is TileMapLayer):
		tilemap = get_parent()
	else:
		printerr("No tile map layer to reference!")

func move(next_position : Vector2i):
	tilemap.set_cell(next_position, 0, active_colour)
	tilemap.set_cell(current_position, 0, passed_colour)
	current_position = next_position
