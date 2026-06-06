@abstract extends Node

class_name Traveller

var tilemap : TileMapLayer

var directions : Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

@export_category("Colours")

@export var active_colour : Vector2i = CellColour.colours_in_tileset[CellColour.TilesetColour.RED]
@export var passed_colour : Vector2i = CellColour.colours_in_tileset[CellColour.TilesetColour.DESATURATED_RED]

@export_category("Speed")

@export var traveller_speed : float = 1

@export_category("Position")

@export var current_position : Vector2i = Vector2i(0, 0)
var previous_position : Vector2i = Vector2i(0, 0)
var next_position : Vector2i = Vector2i(0, 0)

@export_category("Modifiers")

@export var traveller_modifier : String
@export var disabled : bool = false
@export var filling_disabled : bool = false

@export_category("Path boundries")


@onready var boundaries : Array[Vector2i] = [
	current_position, # top left
	current_position, # top right
	current_position, # botton right
	current_position, # botton left
]

var max_pos : Array[int] = [
	0, # left
	0, # right
	0, # up
	0, # down
]

enum MaxPosDirections {
	LEFT, RIGHT, UP, DOWN
}

var is_new_position : Dictionary[Vector2i, bool]

var move_log : Array[Vector2i]

func get_speed() -> float:
	return traveller_speed

func _ready() -> void:
	if(get_parent() is TileMapLayer):
		tilemap = get_parent()
	else:
		printerr("No tile map layer to reference!")
		assert(false)
		
		
	max_pos[0] = current_position.x
	max_pos[1] = current_position.x
	max_pos[2] = current_position.y
	max_pos[3] = current_position.y
	
	preparatory_actions()
	
	
	
func set_cell_colour(cell_coords: Vector2i, colour : Vector2i) -> void:
	tilemap.set_cell(cell_coords, 0, colour)
	tilemap.get_cell_tile_data(cell_coords).set_custom_data("Colour", colour)
	
	
func is_cell_null(cell_coords : Vector2i) -> bool:
	if(tilemap.get_cell_tile_data(cell_coords) == null):
		return true
	else:
		return false
	
	
func is_cell_traveller_colour(cell_coords: Vector2i) -> bool:
	if(is_cell_null(cell_coords)):
		return false
	
	if(tilemap.get_cell_tile_data(cell_coords).get_custom_data("Colour") == passed_colour
			or tilemap.get_cell_tile_data(cell_coords).get_custom_data("Colour") == active_colour):
		return true
	else:
		return false

func can_travel_to_cell(cell_coords: Vector2i) -> bool:
	return(is_cell_null(cell_coords) or is_cell_traveller_colour(cell_coords))

func start_moving() -> void:
	if disabled:
		return
	else:
		move(get_next_position())

func move(to_next_position : Vector2i) -> void:
	if(disabled):
		return
		
	next_position = to_next_position
	
	if(next_position == current_position):
		return
	
	if(can_move(next_position)):
		previous_position = current_position
		
		# Checking if it needs to be filled
		if(is_new_position.get_or_add(current_position, true) == true):
			if(is_cell_null(next_position) == false
			   and is_cell_traveller_colour(next_position)):
				if(filling_disabled == false):
					check_if_enclosed(next_position)
			is_new_position[current_position] = false
			
		set_cell_colour(next_position, active_colour)
		set_cell_colour(current_position, passed_colour)
		
		current_position = next_position
		
		# Checking boundaries
		
		#left
		max_pos[0] = min(max_pos[0], current_position.x)
		#right
		max_pos[1] = max(max_pos[1], current_position.x)
		#up
		max_pos[2] = min(max_pos[2], current_position.y)
		#down
		max_pos[3] = max(max_pos[3], current_position.y)
	else:
		print(name + " cannot move to this location")

func can_move(to_next_position : Vector2i) -> bool:
	if(can_travel_to_cell(to_next_position)):
		return true
	else:
		return false

func check_if_enclosed(_current_next_position : Vector2i) -> void:
	
	disabled = true
	
	var cells_to_fill_1 : Dictionary[Vector2i, bool]
	var is_fill_valid : bool = true
	# This goes through column by column

	for i in range(max_pos[MaxPosDirections.LEFT], max_pos[MaxPosDirections.RIGHT] + 1):
		# Checking each x position
		
		var found_cell_front : bool = false
		var found_cell_back : bool = false
		var empty_cells : Array[Vector2i]
		for j in range(max_pos[MaxPosDirections.UP], max_pos[MaxPosDirections.DOWN] + 1):
			# Checking each y position
			if(is_cell_traveller_colour(Vector2i(i, j))):
				
				if(found_cell_front == true):
					found_cell_back = true
				found_cell_front = true
				if found_cell_front == true and found_cell_back == true:
					for cell in empty_cells:
						#print("added cell to fill: " + str(cell))
						cells_to_fill_1[cell] = true
					empty_cells.clear()
					found_cell_back = false
				continue
			
			if(is_cell_null(Vector2i(i, j))):
				if(found_cell_front == true):
					empty_cells.push_back(Vector2i(i, j))
				# Invalid fill
			elif(is_cell_traveller_colour(Vector2i(i, j)) == false):
				if(found_cell_front == true):
					found_cell_front = false
		
	# Row by row
	
	var cells_to_fill_2 : Dictionary[Vector2i, bool]
	
	for i in range(max_pos[MaxPosDirections.UP], max_pos[MaxPosDirections.DOWN] + 1):
		# Checking each y position
		var found_cell_front : bool = false
		var found_cell_back : bool = false
		var empty_cells : Array[Vector2i]
		for j in range(max_pos[MaxPosDirections.LEFT], max_pos[MaxPosDirections.RIGHT] + 1):
			# Checking each x position
			
			if(is_cell_traveller_colour(Vector2i(j, i))):
				# if the cell has been visited in the bfs (it is a passed cell)
				if(found_cell_front == true):
					found_cell_back = true
				found_cell_front = true
				if found_cell_front == true and found_cell_back == true:
					for cell in empty_cells:
						cells_to_fill_2[cell] = true
					empty_cells.clear()
					found_cell_back = false
				continue
			
			if(is_cell_null(Vector2i(j, i))):
				if(found_cell_front == true):
					empty_cells.push_back(Vector2i(j, i))
			elif(is_cell_traveller_colour(Vector2i(i, j)) == false):
				# Invalid fill
				if(found_cell_front == true):
					found_cell_front = false
			
	if(is_fill_valid):
		for cell in cells_to_fill_1.keys():
			if(cells_to_fill_2.get_or_add(cell, false) == true):
				var open_to_not_added_cells : bool = false
				for direction : Vector2i in directions:
					if(
						(is_cell_null(cell + direction) and cells_to_fill_1.get_or_add(cell + direction, false) == false)
						or (is_cell_null(cell + direction) and cells_to_fill_2.get_or_add(cell + direction, false) == false)
					):
						open_to_not_added_cells = true
				if(open_to_not_added_cells == false):
					print("filling in " + str(cell))
					if(is_new_position.get_or_add(current_position, true) == true):
						is_new_position[cell] = false
					set_cell_colour(cell, passed_colour)
		set_cell_colour(current_position, active_colour)
	
	disabled = false
	
	
@abstract func get_next_position() -> Vector2i

@abstract func preparatory_actions() -> void
