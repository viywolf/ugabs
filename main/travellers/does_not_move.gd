extends Traveller

func preparatory_actions() -> void:
	name = "Stationary"

func get_next_position() -> Vector2i:
	return current_position
