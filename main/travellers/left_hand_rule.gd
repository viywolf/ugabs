extends Traveller

# Always move left unless it cannot, then turns left

var facing_direction : int = 0

var direction_rotations : Array[Vector2i] = [
	Vector2i.LEFT,
	Vector2i.DOWN,
	Vector2i.RIGHT,
	Vector2i.UP,
]

func preparatory_actions() -> void:
	name = "Left Hand Rule "
	
func get_next_position() -> Vector2i:
	if(can_move(current_position + direction_rotations[facing_direction]) == false):
		facing_direction = (facing_direction + 1) % 4
	return current_position + direction_rotations[facing_direction]
