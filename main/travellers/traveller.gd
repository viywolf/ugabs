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
	

func move(to_next_position : Vector2i) -> void:
	if(disabled):
		return
	next_position = to_next_position
	
	if(next_position == current_position):
		return
	
	if(can_move(next_position)):
		previous_position = current_position
		if(is_new_position.get_or_add(current_position, true) == true):
			if(tilemap.get_cell_tile_data(next_position) != null 
			   and (tilemap.get_cell_tile_data(next_position).get_custom_data("Colour") == passed_colour
			or tilemap.get_cell_tile_data(next_position).get_custom_data("Colour") == active_colour)):
				if(filling_disabled == false):
					check_if_enclosed(next_position)
			is_new_position[current_position] = false
		tilemap.set_cell(next_position, 0, active_colour)
		tilemap.get_cell_tile_data(next_position).set_custom_data("Colour", active_colour)
		tilemap.set_cell(current_position, 0, passed_colour)
		tilemap.get_cell_tile_data(current_position).set_custom_data("Colour", passed_colour)
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
		print(next_position)
		#print(name + " cannot move to this location")

func can_move(to_next_position : Vector2i) -> bool:
	if(tilemap.get_cell_tile_data(to_next_position) == null or 
	   tilemap.get_cell_tile_data(to_next_position).get_custom_data("Colour") == passed_colour
		or tilemap.get_cell_tile_data(to_next_position).get_custom_data("Colour") == active_colour):
		return true
	else:
		return false

func check_if_enclosed(current_next_position : Vector2i) -> void:
	
	disabled = true
	
	var cells_to_fill_1 : Dictionary[Vector2i, bool]
	var is_fill_valid : bool = true
	# This goes through column by column
	
	#for i in range(min(boundaries[0].x, boundaries[1].x) - 2, max(boundaries[2].x, boundaries[3].x) + 2):
	for i in range(max_pos[MaxPosDirections.LEFT], max_pos[MaxPosDirections.RIGHT] + 1):
		# Checking each x position
		var cells_found : int = 0
		
		var found_cell_front : bool = false
		var found_cell_back : bool = false
		var empty_cells : Array[Vector2i]
		#for j in range(min(boundaries[0].y, boundaries[3].y) - 2, max(boundaries[2].y, boundaries[1].y) + 2):
		for j in range(max_pos[MaxPosDirections.UP], max_pos[MaxPosDirections.DOWN] + 1):
			# Checking each y position
			#if(visited.get_or_add(Vector2i(i, j), false) == true): 
			if(tilemap.get_cell_tile_data(Vector2i(i, j)) != null
				and (tilemap.get_cell_tile_data(Vector2i(i, j)).get_custom_data("Colour") == passed_colour
				or tilemap.get_cell_tile_data(Vector2i(i, j)).get_custom_data("Colour") == active_colour)):
				# if the cell has been visited in the bfs (it is a passed cell)
				cells_found += 1
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
			
			if(tilemap.get_cell_tile_data(Vector2i(i, j)) == null):
				if(found_cell_front == true):
					empty_cells.push_back(Vector2i(i, j))
			elif(tilemap.get_cell_tile_data(Vector2i(i, j)).get_custom_data("Colour").y == 1
				and tilemap.get_cell_tile_data(Vector2i(i, j)).get_custom_data("Colour") != active_colour
				and tilemap.get_cell_tile_data(Vector2i(i, j)).get_custom_data("Colour") != passed_colour):
				pass
				#print("Invalid fill attempted")
				#is_fill_valid = false
				#break
		#print("found " + str(cells_found) + " cells in column " + str(i))
		
	# Row by row
	
	var cells_to_fill_2 : Dictionary[Vector2i, bool]
	
	#for i in range(min(boundaries[0].y, boundaries[3].y) - 2, max(boundaries[2].y, boundaries[1].y) + 2):
	for i in range(max_pos[MaxPosDirections.UP], max_pos[MaxPosDirections.DOWN] + 1):
		var cells_found : int = 0
		# Checking each y position
		var found_cell_front : bool = false
		var found_cell_back : bool = false
		var empty_cells : Array[Vector2i]
		var added_cell_to_fill : bool =false
		#for j in range(min(boundaries[0].x, boundaries[1].x) - 2, max(boundaries[2].x, boundaries[3].x) + 2):
		for j in range(max_pos[MaxPosDirections.LEFT], max_pos[MaxPosDirections.RIGHT] + 1):
			# Checking each x position
			
			#if(visited.get_or_add(Vector2i(i, j), false) == true): 
			if(tilemap.get_cell_tile_data(Vector2i(j, i)) != null
				and (tilemap.get_cell_tile_data(Vector2i(j, i)).get_custom_data("Colour") == passed_colour
				or tilemap.get_cell_tile_data(Vector2i(j, i)).get_custom_data("Colour") == active_colour)):
				# if the cell has been visited in the bfs (it is a passed cell)
				cells_found += 1
				if(found_cell_front == true):
					found_cell_back = true
				found_cell_front = true
				if found_cell_front == true and found_cell_back == true:
					for cell in empty_cells:
						added_cell_to_fill = true
						cells_to_fill_2[cell] = true
					empty_cells.clear()
					found_cell_back = false
				continue
			
			if(tilemap.get_cell_tile_data(Vector2i(j, i)) == null):
				if(found_cell_front == true):
					empty_cells.push_back(Vector2i(j, i))
			elif(tilemap.get_cell_tile_data(Vector2i(j, i)).get_custom_data("Colour").y == 1
				and tilemap.get_cell_tile_data(Vector2i(j, i)).get_custom_data("Colour") != active_colour
				and tilemap.get_cell_tile_data(Vector2i(j, i)).get_custom_data("Colour") != passed_colour):
				pass
				#print("Invalid fill attempted")
				#is_fill_valid = false
				#break
			
		#print("found " + str(cells_found) + " cells in row " + str(i))
		#if(added_cell_to_fill):
	#		print("added cell to fill")
			
	if(is_fill_valid):
		#print(cells_to_fill_1)
		#print(cells_to_fill_2)
		for cell in cells_to_fill_1.keys():
			if(cells_to_fill_2.get_or_add(cell, false) == true):
				var open_to_not_added_cells : bool = false
				for direction : Vector2i in directions:
					if((tilemap.get_cell_tile_data(cell + direction) == null and cells_to_fill_1.get_or_add(cell + direction, false) == false)
						or(tilemap.get_cell_tile_data(cell + direction) == null and cells_to_fill_2.get_or_add(cell + direction, false) == false)):
							open_to_not_added_cells = true
				if(open_to_not_added_cells == false):
					print("filling in " + str(cell))
					if(is_new_position.get_or_add(current_position, true) == true):
						is_new_position[cell] = false
					tilemap.set_cell(cell, 0, passed_colour)
					tilemap.get_cell_tile_data(cell).set_custom_data("Colour", passed_colour)
		tilemap.get_cell_tile_data(current_position).set_custom_data("Colour", active_colour)
	
	#for i in range(boundaries.size()):
	#	boundaries[i] = current_position
	disabled = false
	
	
@abstract func get_next_position() -> Vector2i

func get_speed() -> float:
	return traveller_speed
