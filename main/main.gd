extends Node2D


var playback_scene : PackedScene = preload("res://main/board_playback.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
		if Input.is_action_just_pressed("ui_accept"):
			for child : Node in get_children():
				if child is TileMapLayer:
					child.queue_free()
			var instantiated_scene : TileMapLayer = playback_scene.instantiate()
			instantiated_scene.name = "PlaybackScene"
			add_child(instantiated_scene)
			return
