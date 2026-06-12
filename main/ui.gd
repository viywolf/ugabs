extends CanvasLayer

func _ready() -> void:
	Engine.physics_ticks_per_second = 12

func _on_speed_slider_value_changed(value: float) -> void:
	var value_to_ticks : int = int(round(value*value))
	if value_to_ticks == 0:
		for node in get_tree().current_scene.get_children():
			if node == TileMapLayer:
				node.set_physics_process(false)
		get_tree().paused = true
		Engine.physics_ticks_per_second = 1
	else:
		for node in get_tree().current_scene.get_children():
			if node == TileMapLayer:
				node.set_physics_process(true)
		get_tree().paused = false
		Engine.physics_ticks_per_second = value_to_ticks

# Process : mode : always/pausable
