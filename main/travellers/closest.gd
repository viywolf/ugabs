extends Traveller

var is_path_complete : bool = true

func preparatory_actions() -> void:
	pass

func get_next_position() -> Vector2i:
	if(is_path_complete == true):
		# BFS
		var visited: Dictionary
		var q: Array[Vector2i]
		q.push_back(current_position)
		visited[current_position] = true
		var cur_index = 0
		
		while(q.is_empty() == false):
			var cur_pos: Vector2i = q[cur_index]
			cur_index += 1
			if(visited.get_or_add(cur_pos, false) == false):
				visited[cur_pos] = true
			else:
				continue
			
			# Found an empty cell
			if(is_cell_null(cur_pos)):
				break
				# Get shortest path to it
			# Continue the search
			else:
				q.push_back(current_position + Vector2i.UP)
				q.push_back(current_position + Vector2i.DOWN)
				q.push_back(current_position + Vector2i.LEFT)
				q.push_back(current_position + Vector2i.RIGHT)
		return current_position
	else:
		return current_position
	
