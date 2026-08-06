extends Traveller

var current_direction : Vector2i = Vector2i.RIGHT

func preparatory_actions() -> void:
	name = ""

func is_near_cell(cell_coords : Vector2i) -> bool:
	const three_directions : Array = [-1, 0, 1]
	for i in three_directions:
		for j in three_directions:
			if(Vector2i(i,j) == Vector2i(0, 0)): continue
			if(tilemap.get_cell_tile_data(cell_coords + Vector2i(i, j)) == null
			 or tilemap.get_cell_tile_data(cell_coords + Vector2i(i, j)).get_custom_data("Colour") != passed_colour):
				return true
			if(tilemap.get_cell_tile_data(cell_coords + Vector2i(i, j)).get_custom_data("Colour") == active_colour):
				printerr("active cell tested in is near cell function")
	return false

func get_next_position() -> Vector2i:
	
	"""
	Always be near a filled cell (8 directions)
	
	If can go right and has not visited, and it is near a filled cell, go right
	If cant go right go down if not visited and near a filled cell
	If can go left and has no visited and near a filled cell go left
	If the only way to go without visited cell or be near a filled cell is up, go up
	If all cells visited, go the oppposite of the last cell until an univisted cell is availiable
		then do all the tests with only the unvisited cells
	"""
	
	var next_position_value : Vector2i = current_position
	
	if(can_move(current_position + current_direction)):
		return current_position + current_direction
	
	if(can_move(current_position + Vector2i.RIGHT) 
		and tilemap.get_cell_tile_data(current_position + Vector2i.RIGHT) == null):
		next_position_value = current_position + Vector2i.RIGHT
		current_direction = Vector2i.RIGHT
	elif(can_move(current_position + Vector2i.DOWN)
		and tilemap.get_cell_tile_data(current_position + Vector2i.DOWN) == null):
		next_position_value = current_position + Vector2i.DOWN
		current_direction = Vector2i.DOWN
	elif(can_move(current_position + Vector2i.LEFT)
		and tilemap.get_cell_tile_data(current_position + Vector2i.LEFT) == null):
		next_position_value = current_position + Vector2i.LEFT
		current_direction = Vector2i.LEFT
	elif(can_move(current_position + Vector2i.UP)
		and tilemap.get_cell_tile_data(current_position + Vector2i.UP) == null):
		next_position_value = current_position + Vector2i.UP
		current_direction = Vector2i.UP
		
		
	return next_position_value
