extends Traveller

var current_direction : Vector2i = Vector2i.RIGHT

func get_next_position() -> Vector2i:
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
