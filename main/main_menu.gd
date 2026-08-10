extends CanvasLayer

var main_sim_node: PackedScene
var is_loading: bool = false
var load_status: Array 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MetaInfo.screen_size = get_viewport().get_visible_rect().size
	$Label.position.x = MetaInfo.screen_size.x / MetaInfo.fraction_of_screen
	$VBoxContainer.position.x = MetaInfo.screen_size.x / MetaInfo.fraction_of_screen
	
	ResourceLoader.load_threaded_request("res://main/main.tscn")

func _process(_delta: float) -> void:
	if(is_loading):
		$VBoxContainer/LoadingLabel.show()
		ResourceLoader.load_threaded_get_status("res://main/main.tscn", load_status)
		if(load_status[0] == 1.0):
			main_sim_node = ResourceLoader.load_threaded_get("res://main/main.tscn")
			get_tree().change_scene_to_node(main_sim_node.instantiate())

func _on_start_pressed() -> void:
	is_loading = true
