extends Traveller

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func preparatory_actions() -> void:
	pass

func get_next_position() -> Vector2i:
	return current_position + directions[rng.randi_range(0, 3)]
