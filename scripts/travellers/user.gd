extends Traveller

var next_pos_ready : bool = false
var next_position_input : Vector2i

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("ui_up")):
		next_position_input = directions[0] + current_position
		next_pos_ready = true
	if(Input.is_action_just_pressed("ui_down")):
		next_position_input = directions[1] + current_position
		next_pos_ready = true
	if(Input.is_action_just_pressed("ui_left")):
		next_position_input = directions[2] + current_position
		next_pos_ready = true
	if(Input.is_action_just_pressed("ui_right")):
		next_position_input = directions[3] + current_position
		next_pos_ready = true

func get_next_position() -> Vector2i:
	if(next_pos_ready):
		next_pos_ready = false
		return next_position_input
	else:
		return current_position
