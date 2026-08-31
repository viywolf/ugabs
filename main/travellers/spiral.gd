extends Traveller

# Always move left unless it cannot, then turns left

var facing_direction : int = 0

var direction_rotations : Array[Vector2i] = [
	Vector2i.LEFT,
	Vector2i.DOWN,
	Vector2i.RIGHT,
	Vector2i.UP,
]

var is_path_complete: bool = true

var target_cell: Vector2i
var path_to_target: PackedVector2Array

var index_in_path: int = 0

var is_all_surrounding_cells_filled: bool = false

func preparatory_actions() -> void:
	name = "Spiral "
	
func get_next_position() -> Vector2i:
	if(can_move(current_position + direction_rotations[facing_direction]) == false):
		facing_direction = (facing_direction + 1) % 4
		
	is_all_surrounding_cells_filled = true
	for i in range(4):
		if(is_cell_null(current_position + direction_rotations[(i + facing_direction) % 4]) == true):
			is_all_surrounding_cells_filled = false
			is_path_complete = true
			facing_direction = (i + facing_direction) % 4
	
	if(is_all_surrounding_cells_filled == false):
		return current_position + direction_rotations[facing_direction]
	elif(is_path_complete == true):
		var bfs_status: Error = bfs()
		if(bfs_status == Error.FAILED):
			return current_position
		
		if(path_to_target.size() > 1 and
				Vector2i(path_to_target[0]) == current_position):
			index_in_path = 1
		
		if(index_in_path < path_to_target.size()):
			if(can_move(get_next_cell()) == false):
				is_path_complete = true
				return current_position
			else:
				if(index_in_path == path_to_target.size() - 1):
					is_path_complete = true
				return get_next_cell()
		else:
			is_path_complete = true
			return current_position
	else:
		if(current_position == target_cell):
			is_path_complete = true
			
		# Impossible to go there
		if(path_to_target.size() == 0):
			is_path_complete = true
			return current_position
			
		index_in_path += 1
		
		if(index_in_path < path_to_target.size()):
			if(can_move(get_next_cell()) == false):
				is_path_complete = true
				return current_position
			else:
				if(index_in_path == path_to_target.size() - 1):
					is_path_complete = true
				return get_next_cell()
		else:
			is_path_complete = true
			return current_position

func get_next_cell() -> Vector2i:
	return Vector2i(path_to_target[index_in_path])

func bfs() -> Error:
	var visited: Dictionary
	var q: Array[Vector2i]
	q.push_back(current_position)
	var cur_index = 0
	while(cur_index != q.size()):
		var cur_pos: Vector2i = q[cur_index]
		cur_index += 1
		# If the bfs goes too deep, stop it
		if(cur_index > GlobalTravInfo.grid_radius * 100): break
		if(visited.get_or_add(cur_pos, false) == false):
			visited[cur_pos] = true
		else: continue
		# Found an empty cell
		if(is_cell_null(cur_pos)):
			is_path_complete = false
			if(tilemap.get_astar_grid(passed_colour).is_point_solid(current_position)):
				tilemap.get_astar_grid(passed_colour).set_point_solid(current_position, false)
			path_to_target = tilemap.get_astar_grid(passed_colour).get_point_path(current_position, cur_pos)
			index_in_path = 0
			target_cell = cur_pos
			break
		else:
			for direction in directions:
				if((is_cell_traveller_colour(cur_pos + direction) 
						or is_cell_null(cur_pos + direction))):
					q.push_back(cur_pos + direction)
	#Unable to find a null cell
	if(cur_index == q.size()):
		return Error.FAILED
	else:
		return Error.OK
