extends Node

var directions: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

var all_traveller_types: Dictionary[String, Resource] = {
	"random": load("res://main/travellers/random.gd"),
	"random router": load("res://main/travellers/random_seeker.gd"),
	"user": load("res://main/travellers/user.gd"),
	"stationary": load("res://main/travellers/does_not_move.gd"),
	"closest": load("res://main/travellers/closest.gd"),
	"left hand": load("res://main/travellers/left_hand_rule.gd"),
}

# Change to dictionary?
var trav_types_desc: Array[String] = [
	"'Random' chooses a random direction to travel in every turn. This includes directions which it cannot move to, causing it to skip a turn.", # random
	"'Random Router' chooses a random uncoloured cell on the grid, which it will then attempt to travel to in the shortest route possible.", # seeker
	"'User' is controlled by you. Use arrow keys to control its movement. If no input is detected, its turn is skipped.", # user
	"'Stationary' will never move. Not to be confused with 'stationery'.",
	"'Closest' tries to find the closest uncoloured cell and moves towards it.",
	"Left hand rule",
	"Placeholder",
	"Placeholder",
	"Placeholder",
]

var global_move_log: Array[Array]

func reset_global_move_log() -> void:
	global_move_log.clear()
	for i in range(no_of_travellers):
		global_move_log.push_back([])

var no_of_travellers: int

## The names of each traveller
var traveller_names: Array[String]

## The number of cells claimed per colour
var team_cells_claimed: Dictionary[Vector2i, float]

# Only used in playback?
var traveller_colours: Array[int]

var is_traveller_disabled: Array[bool]

var current_turn: int = 0

var grid_size: Vector2i = Vector2i(120 + 1, 60 + 1)
var total_cells_in_grid: int

var grid_radius: int
var grid_shape: String
