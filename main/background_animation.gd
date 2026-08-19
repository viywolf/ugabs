extends TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(2).timeout
	for i in range(10):
		for j in range(5):
			if(i == 3 and j == 0):
				set_cell(Vector2i(i, j), 0, Vector2i(4, j))
			elif(i == 5 and j == 0):
				set_cell(Vector2i(i, j), 0, Vector2i(4, j))
			elif(i == 7 and j == 0):
				set_cell(Vector2i(i, j), 0, Vector2i(4, j))
			elif(i > 5 and i < 8 and j == 1):
				set_cell(Vector2i(i, j), 0, Vector2i(4, j))
			elif(i == 7 and j == 2):
				set_cell(Vector2i(i, j), 0, Vector2i(4, j))
			elif(i == 6 and j == 3):
				set_cell(Vector2i(i, j), 0, Vector2i(3, j))
			elif(i == 3 and j == 4):
				set_cell(Vector2i(i, j), 0, Vector2i(4, j))
			elif(i == 6 and j == 4):
				set_cell(Vector2i(i, j), 0, Vector2i(4, j))
			elif(i == 7 and j == 4):
				set_cell(Vector2i(i, j), 0, Vector2i(4, j))
			else:
				set_cell(Vector2i(i, j), 0, Vector2i(1, j))
		await get_tree().create_timer(2).timeout
