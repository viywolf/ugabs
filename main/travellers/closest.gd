extends Traveller

var is_path_complete : bool = true

var target_cell : Vector2i
var path_to_target : PackedVector2Array

var index_in_path : int = -1

func preparatory_actions() -> void:
	pass

func get_next_cell() -> Vector2i:
	return Vector2i(path_to_target[index_in_path])

func get_next_position() -> Vector2i:
	if(is_path_complete == true):
		# BFS
		var visited: Dictionary
		var q: Array[Vector2i]
		q.push_back(current_position)
		visited[current_position] = true
		var cur_index = 0
		
		while(cur_index != q.size()):
			var cur_pos: Vector2i = q[cur_index]
			cur_index += 1
			if(visited.get_or_add(cur_pos, false) == false):
				visited[cur_pos] = true
			else:
				continue
			
			# Found an empty cell
			if(is_cell_null(cur_pos)):
				print("found null cell")
				is_path_complete = false
				
				if(tilemap.get_astar_grid(passed_colour).is_point_solid(current_position)):
					tilemap.get_astar_grid(passed_colour).set_point_solid(current_position, false)
				
				path_to_target = tilemap.get_astar_grid(passed_colour).get_point_path(current_position, cur_pos)
				target_cell = cur_pos
				if(path_to_target.is_empty() == true):
					is_path_complete = true
				
				break
			# Else, continue the search
			else:
				print("adding adjacent cells")
				q.push_back(current_position + Vector2i.UP)
				q.push_back(current_position + Vector2i.DOWN)
				q.push_back(current_position + Vector2i.LEFT)
				q.push_back(current_position + Vector2i.RIGHT)
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
				return get_next_cell()
		else:
			is_path_complete = true
			return current_position
	
