extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MetaInfo.screen_size = get_viewport().get_visible_rect().size
	$Label.position.x = MetaInfo.screen_size.x / MetaInfo.fraction_of_screen
	$VBoxContainer.position.x = MetaInfo.screen_size.x / MetaInfo.fraction_of_screen

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://main/main.tscn")
