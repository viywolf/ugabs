extends Traveller

var directions : Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func get_move() -> void:
	move(current_position + directions[rng.randi_range(0, 3)])
