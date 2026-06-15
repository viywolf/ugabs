extends Node

var directions : Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

var all_traveller_types : Dictionary[String, Resource] = {
	"user" : load("res://main/travellers/user.gd"),
	"random" : load("res://main/travellers/random.gd"),
	"random location" : load("res://main/travellers/random_seeker.gd"),
}

var global_move_log : Array[Array]

var no_of_travellers : int

var traveller_names : Array[String]

var traveller_colours : Array[int]

var is_traveller_disabled : Array[bool]

var traveller_cells_claimed : Array[int]

var current_turn : int = 0

var grid_size : Vector2i = Vector2i(120 + 1, 60 + 1)
var total_cells_in_grid : int

var grid_radius : int
