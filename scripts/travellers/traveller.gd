extends Node

class_name Traveller

var tilemap : TileMapLayer

@export_category("Colours")

@export var active_colour : Vector2i = CellColour.colours_in_tileset[CellColour.TilesetColour.RED]
@export var passed_colour : Vector2i = CellColour.colours_in_tileset[CellColour.TilesetColour.DESATURATED_RED]

@export_category("Speed")

@export var traveller_speed : float = 1

@export_category("Position")

@export var current_position : Vector2i = Vector2i(0, 0)

func _ready() -> void:
	if(get_parent() is TileMapLayer):
		tilemap = get_parent()
	else:
		printerr("No tile map layer to reference!")

func move(next_position : Vector2i) -> void:
	if(can_move(next_position)):
		tilemap.set_cell(next_position, 0, active_colour)
		tilemap.get_cell_tile_data(next_position).set_custom_data("Colour", active_colour)
		tilemap.set_cell(current_position, 0, passed_colour)
		tilemap.get_cell_tile_data(current_position).set_custom_data("Colour", passed_colour)
		current_position = next_position

func can_move(next_position : Vector2i) -> bool:
	if(tilemap.get_cell_tile_data(next_position) == null or 
	   tilemap.get_cell_tile_data(next_position).get_custom_data("Colour") == passed_colour):
		return true
	else:
		return false
		

func get_speed() -> float:
	return traveller_speed


"""
Make a manager for things like nearest position in the tile map layer, 
so all the travellers can access it easily.
Also make a function for getting these things.
-j
"""
