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

func _ready() -> void:
	if(get_parent() is TileMapLayer):
		tilemap = get_parent()
	else:
		printerr("No tile map layer to reference!")

func move(to_next_position : Vector2i) -> void:
	if(disabled):
		return
	next_position = to_next_position
	if(can_move(next_position)):
		previous_position = current_position
		if(tilemap.get_cell_tile_data(next_position) != null 
		   and tilemap.get_cell_tile_data(next_position).get_custom_data("Colour") == passed_colour):
			check_if_enclosed(next_position)
		tilemap.set_cell(next_position, 0, active_colour)
		tilemap.get_cell_tile_data(next_position).set_custom_data("Colour", active_colour)
		tilemap.set_cell(current_position, 0, passed_colour)
		tilemap.get_cell_tile_data(current_position).set_custom_data("Colour", passed_colour)
		current_position = next_position

func can_move(to_next_position : Vector2i) -> bool:
	if(tilemap.get_cell_tile_data(to_next_position) == null or 
	   tilemap.get_cell_tile_data(to_next_position).get_custom_data("Colour") == passed_colour):
		return true
	else:
		return false

func check_if_enclosed(current_next_position : Vector2i) -> void:
	# current next position = passed colour
	
	# Using a raycast, rotate it 360 degrees to check for gaps
	# This does not work if the shape is weird and blocks parts of it
	
	#Graph cycle detection
	# Have to stop it from going int a random direction - maybe stop it if it touches the passed colour twice?
	
	# Need a way to get all enclosed cells
	
	# What if there are two empty spaces in an enclosed space?
	#	This will never happen since they get filled in immedietly
	# What if it is mostly empty except for a traveller in the middle?
	
	var visited : Dictionary[Vector2i, bool] = {}
	
	var q : Array[Vector2i] = []
	q.push_back(current_next_position)
	
	var cur_index = 0
	
	# Need a way to find unfilled cells in the right place
	
	#Idea: if it is next to 4 visited cells, fill it in.
	
	print("starting")
	while(q.is_empty() == false):
		var cur_cell = q.pop_front()
		#var cur_cell = q[cur_index]
		#cur_index += 1
		var surrounded_by_filled_cell : int = 0
		var temp_queue : Array[Vector2i]
		for direction : Vector2i in directions:
			if(visited.get_or_add(cur_cell + direction, false) == true):
				pass
			else:
				visited[cur_cell + direction] = true
				if(tilemap.get_cell_tile_data(cur_cell + direction) == null):
					pass
				elif(tilemap.get_cell_tile_data(cur_cell + direction).get_custom_data("Colour") == passed_colour
					 or tilemap.get_cell_tile_data(cur_cell + direction).get_custom_data("Colour") == active_colour):
					temp_queue.push_back(cur_cell + direction)
					surrounded_by_filled_cell += 1
		
		# if surrounded on all sides, impossible for this to be a boundary
		if(surrounded_by_filled_cell != 4):
			for cell in temp_queue:
				q.push_back(cell)
				visited[cell] = true
				
		# using regular process to do it as fast as possible
		await get_tree().process_frame
		
	print(current_next_position)
	var recursive_check_starting_point : Vector2i
	
	var cells_to_fill : Array = []
	
	for key : Vector2i in visited.keys():
		var surrounded : int = 0
		for direction : Vector2i in directions:
			if(visited.get_or_add(key + direction, false) == true):
				surrounded += 1
		if(surrounded == 4):
			var rng : RandomNumberGenerator = RandomNumberGenerator.new()
			if(rng.randi_range(0, 3) == 1):
				pass
				recursive_check_starting_point = key
			cells_to_fill.push_back(key)
			#tilemap.set_cell(key, 0, passed_colour)
			#tilemap.get_cell_tile_data(key).set_custom_data("Colour", passed_colour)
	if(recursive_check_starting_point == Vector2i(0,0)):
		recursive_check_starting_point = visited.keys()[0]
	for cell in cells_to_fill:
		tilemap.set_cell(cell, 0, passed_colour)
		tilemap.get_cell_tile_data(cell).set_custom_data("Colour", passed_colour)
	#check_if_enclosed(recursive_check_starting_point)
	
@abstract func get_next_position() -> Vector2i

func get_speed() -> float:
	return traveller_speed
