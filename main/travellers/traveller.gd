@abstract extends Node

class_name Traveller

signal move_finished

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

@export_category("Position")

@export var current_position : Vector2i = Vector2i(0, 0)
var previous_position : Vector2i = Vector2i(0, 0)
var next_position : Vector2i = Vector2i(0, 0)

@export_category("Modifiers")

@export var traveller_speed : float = 1
@export var traveller_modifier : String
@export var disabled : bool = false
@export var filling_disabled : bool = false

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

var direction_of_movement : Vector2i

var child_no : int = -1

# Functions start here

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
	tilemap.filled_cells_in_grid[cell_coords] = colour
	
	
func is_cell_null(cell_coords : Vector2i) -> bool:
	if(tilemap.get_cell_tile_data(cell_coords) == null):
		return true
	else:
		return false
	
	
func is_cell_traveller_colour(cell_coords: Vector2i) -> bool:
	if(is_cell_null(cell_coords)):
		return false
	
	#if(tilemap.get_cell_tile_data(cell_coords).get_custom_data("Colour") == passed_colour
			#or tilemap.get_cell_tile_data(cell_coords).get_custom_data("Colour") == active_colour):
		#return true
		
	
	# Replaced check with separate dictionay to make it quicker?
	if(tilemap.filled_cells_in_grid.get_or_add(cell_coords, null) == passed_colour
			or tilemap.filled_cells_in_grid.get_or_add(cell_coords, null) == active_colour):
		return true
	else:
		return false

func can_travel_to_cell(cell_coords: Vector2i) -> bool:
	return(is_cell_null(cell_coords) or is_cell_traveller_colour(cell_coords))

func start_moving() -> void:
	if disabled:
		move_finished.emit()
		return
	else:
		await move(get_next_position())
	move_finished.emit()

func move(to_next_position : Vector2i) -> void:
	next_position = to_next_position
	
	if(next_position == current_position):
		return
	
	if(can_move(next_position)):
		previous_position = current_position
		
		# Find the direction it is moving in
		direction_of_movement = next_position - current_position
		
		# CHeck if its not goinf dialogn bc that abd
		var valid_dirt : bool = false
		for direction in directions:
			if direction_of_movement == direction:
				valid_dirt = true
		if valid_dirt == false:
			printerr("Diagonal movement attempted!")
		
		# Checking if it needs to be filled
		if(is_new_position.get_or_add(current_position, true) == true):
			if(is_cell_null(next_position) == false and is_cell_traveller_colour(next_position)):
				if(filling_disabled == false): 
					await check_if_enclosed(next_position)
					"""
					for direction : Vector2i in directions:
						if direction == -direction_of_movement:
							continue
						else:
							check_if_enclosed(current_position + direction)
					"""
		
			is_new_position[current_position] = false
			
		# Visually change the position of the active cell
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
		
	# Cannot move to the next location
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
					if empty_cells.size() > 0:
						cells_to_fill_1[empty_cells[0]] = true
					#for cell in empty_cells:
						#print("added cell to fill: " + str(cell))
					#	cells_to_fill_1[cell] = true
					empty_cells.clear()
					found_cell_back = false
				continue
			
			if(is_cell_null(Vector2i(i, j))):
				if(found_cell_front == true):
					empty_cells.push_back(Vector2i(i, j))
				# Invalid fill (its not null or traveller colour
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
				if(found_cell_front == true):
					found_cell_back = true
				found_cell_front = true
				if found_cell_front == true and found_cell_back == true:
					if empty_cells.size() > 0:
						cells_to_fill_2[empty_cells[0]] = true
					#for cell in empty_cells:
					#	cells_to_fill_2[cell] = true
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
		var all_visited_cells : Array[Array]
		# temp value here
		var a : Array
		a.resize(100)
		a.fill(false)
		for i in range(100):
			all_visited_cells.push_back(a.duplicate())
		
		const adj_mat_offset : int = 50
		
		var cell_is_invalid : Dictionary
		
		#print(all_visited_cells)
		
		for cell in cells_to_fill_1.keys():
			if(all_visited_cells[cell.x + adj_mat_offset][cell.y + adj_mat_offset] == true): 
				#print(all_visited_cells)
				#print("already visited " + str(cell))
				continue
			
			if(cells_to_fill_2.get_or_add(cell, false) == true):
				# dfs here
				var marked_empty_cells : Dictionary
				var stack : Array[Vector2i]
				stack.push_back(cell)
				
				var is_dfs_valid : bool = true
				
				print("New dfs started from " + str(cell))
				
				while(stack.is_empty() == false):
					var cur_cell = stack.pop_back()
					
					#print("Checking " + str(cur_cell))
					
					if(cell_is_invalid.get_or_add(cur_cell, false) == true):
						#printerr(str(cur_cell) + ", a previously visited cell was found to be invalid, discard this dfs")
						is_dfs_valid = false
						break
					if(all_visited_cells[cur_cell.x + adj_mat_offset][cur_cell.y + adj_mat_offset] == true):
						#print("visited cell before: " + str(cur_cell))
						break
					all_visited_cells[cur_cell.x + adj_mat_offset][cur_cell.y + adj_mat_offset] = true
					
					if(marked_empty_cells.get_or_add(cur_cell, false) == true):
						#print("skip " + str(cur_cell))
						continue
					else:
						#print(str(cur_cell) + " is a new cell")
						marked_empty_cells[cur_cell] = true
						
					# If the dfs reaches the border (which it shouldn't for an enclosed space)
					if(cur_cell.x <= max_pos[0] or cur_cell.x >= max_pos[1]
						or cur_cell.y <= max_pos[2] or cur_cell.y >= max_pos[3]):
							#print(str(cur_cell) + " is on the boundary, discard this dfs")
							is_dfs_valid = false
							break
							
					# If the current cell is not null or passed or active (cannot fill it in)
					if(is_cell_null(cur_cell) == false and is_cell_traveller_colour(cur_cell) == false):
						#print(str(cur_cell) + " is not a valid cell to fill in, discard this dfs")
						is_dfs_valid = false
						break
						
					for direction2 in directions:
						if(is_cell_traveller_colour(cur_cell + direction2) == false
							and all_visited_cells[cur_cell.x + direction2.x + adj_mat_offset][cur_cell.y + direction2.y + adj_mat_offset] == false):
							stack.push_back(cur_cell + direction2)
							#print("Added " + str(cur_cell + direction2) + " to stack from " + str(cur_cell))
					
				if(is_dfs_valid == true):
					var arr_for_playback : Array = ["fill"]
					var temp_arr_for_positions : Array[Vector2i]
					for dfs_marked_cell in marked_empty_cells.keys():
						#print("filling in " + str(dfs_marked_cell))
						#???
						if(is_new_position.get_or_add(current_position, true) == true):
							is_new_position[dfs_marked_cell] = false
						set_cell_colour(dfs_marked_cell, passed_colour)
						temp_arr_for_positions.push_back(dfs_marked_cell)
					arr_for_playback.push_back(temp_arr_for_positions)
					GlobalTravInfo.global_move_log[child_no][GlobalTravInfo.current_turn].push_back(arr_for_playback)
				else:
					for dfs_marked_cell in marked_empty_cells.keys():
						cell_is_invalid[dfs_marked_cell] = true
				
		set_cell_colour(current_position, active_colour)
	
	disabled = false
	
	
@abstract func get_next_position() -> Vector2i

@abstract func preparatory_actions() -> void
