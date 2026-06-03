extends Traveller

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var target_cell : Vector2i = Vector2i(10, 10)
var path_to_target : PackedVector2Array

var index_in_path : int = -1

func get_new_target_cell() -> void:
	target_cell = Vector2i(rng.randi_range(-60, 60), rng.randi_range(-35, 35))

func reset_path() -> void:
	index_in_path = -1
	path_to_target = tilemap.astar_grid.get_point_path(current_position, target_cell)
	if(path_to_target.is_empty() == true):
		get_new_target_cell()
	
func get_next_cell() -> Vector2i:
	return Vector2i(path_to_target[index_in_path])

func get_next_position() -> Vector2i:
	if(current_position == target_cell):
		get_new_target_cell()
		reset_path()
	if(path_to_target.size() == 0):
		reset_path()
	index_in_path += 1
	if(index_in_path < path_to_target.size()):
		if(can_move(get_next_cell()) == false):
			reset_path()
			return current_position
		else:
			return get_next_cell()
	else:
		return current_position
