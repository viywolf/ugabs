extends CanvasLayer

func _ready() -> void:
	Engine.physics_ticks_per_second = 12

func _on_speed_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		print("changed")
		if $SpeedSlider.value == 0:
			# Set all to disabled
			pass
		else:
			Engine.physics_ticks_per_second = $SpeedSlider.value
			print("changed")
