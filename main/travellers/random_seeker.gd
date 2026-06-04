extends Traveller

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var target_cell : Vector2i
var path_to_target : PackedVector2Array

var index_in_path : int = -1

"""

Speed up the finding new cell part by only considering null cells in range

"""

func preparatory_actions() -> void:
	get_new_target_cell()

func get_new_target_cell() -> void:
	# temp small area
	target_cell = Vector2i(rng.randi_range(-20, 20), rng.randi_range(-10, 10))
	
	#target_cell = Vector2i(rng.randi_range(-60, 60), rng.randi_range(-35, 35))

func reset_path() -> void:
	index_in_path = -1
	
	# For som reason the current point becomes solid randomly, this prevents that
	
	if(tilemap.get_astar_grid(passed_colour).is_point_solid(current_position)):
		#print("Current point is solid")
		tilemap.get_astar_grid(passed_colour).set_point_solid(current_position, false)
	
	path_to_target = tilemap.get_astar_grid(passed_colour).get_point_path(current_position, target_cell)
	if(path_to_target.is_empty() == true):
		get_new_target_cell()
		path_to_target = tilemap.get_astar_grid(passed_colour).get_point_path(current_position, target_cell)
	
func get_next_cell() -> Vector2i:
	return Vector2i(path_to_target[index_in_path])

func get_next_position() -> Vector2i:
	if(current_position == target_cell):
		print(name + " reached target")
		get_new_target_cell()
		reset_path()
		
	# Impossible to go there
	if(path_to_target.size() == 0):
		print(name + " cannot go there")
		get_new_target_cell()
		reset_path()
		return current_position
		
	index_in_path += 1
	
	if(index_in_path < path_to_target.size()):
		if(can_move(get_next_cell()) == false):
			print(name + " cannot move to next cell")
			reset_path()
			return current_position
		else:
			return get_next_cell()
	else:
		print(name + " has finished the current path")
		return current_position
