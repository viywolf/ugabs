extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Mathy set up stuff
	pass # Replace with function body.



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://main/main_2.tscn")
