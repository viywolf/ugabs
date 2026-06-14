extends Node2D

var playback_scene : PackedScene = preload("res://main/board_playback.tscn")

var main_tilemap_scene : TileMapLayer

func _ready() -> void:
	$TravellerSetupMenu.setup_done.connect(tilemap_created)

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

func tilemap_created() -> void:
	for child : Node in get_children():
		if child is TileMapLayer:
			main_tilemap_scene = child
			child.update_cells_claimed.connect(update_cells_claimed_data)
	%UI.update_no_of_labels()

func update_cells_claimed_data(cur_cells_claimed : Array[int]):
	for i in cur_cells_claimed.size():
		%UI.cells_claimed_percentages[i] = (float(cur_cells_claimed[i]) / GlobalTravInfo.total_cells_in_grid)
	%UI.update_cell_claimed_labels()
