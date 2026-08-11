extends Node2D

var playback_scene : PackedScene = preload("res://main/board_playback.tscn")

var main_tilemap_scene : TileMapLayer

func _ready() -> void:
	$TravellerSetupMenu.setup_done.connect(tilemap_created)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Replay options (kinda incompatible cause you mgiht press enter when typing stuff)
	"""
	if Input.is_action_just_pressed("ui_accept"):
		for child : Node in get_children():
			if child is TileMapLayer:
				child.queue_free()
		var instantiated_scene : TileMapLayer = playback_scene.instantiate()
		instantiated_scene.name = "PlaybackScene"
		add_child(instantiated_scene)
		return
	"""

func tilemap_created() -> void:
	for child : Node in get_children():
		if child is TileMapLayer:
			main_tilemap_scene = child
			child.update_cells_claimed.connect(update_cells_claimed_data)
			child.beep.connect(make_a_beep)
	%UI.update_no_of_labels()
	%UI.show()
	%UI.stop_updating_turns = false

func update_cells_claimed_data(cur_cells_claimed : Array[int]):
	var total_percentage : float = 0
	for i in cur_cells_claimed.size():
		var cur_percentage : float = (float(cur_cells_claimed[i]) / GlobalTravInfo.total_cells_in_grid)
		%UI.cells_claimed_percentages[i] = cur_percentage
		total_percentage += cur_percentage
	
	for key in GlobalTravInfo.team_cells_claimed.keys():
		var cur_percentage : float = (float(GlobalTravInfo.team_cells_claimed[key]) / GlobalTravInfo.total_cells_in_grid)
		GlobalTravInfo.team_cells_claimed[key] = cur_percentage
	
	%UI.update_cell_claimed_labels()
	%UI.update_cur_turn_label()
	
	if(is_equal_approx(total_percentage, 1.0)):
		# maybe do a message saying its stopped?
		for child : Traveller in main_tilemap_scene.get_children():
			child.disabled = true
		%UI.stop_updating_turns = true

var setup_res : PackedScene = load("res://main/traveller_setup_menu.tscn")

func _on_back_button_pressed() -> void:
	if(Global.setup_open == false):
		Global.setup_open = true
	else:
		return
	var setup_scene = setup_res.instantiate()
	setup_scene.setup_done.connect(tilemap_created)
	self.add_child(setup_scene)
	%UI.hide()
	remove_all_tilemaps()
	
func remove_all_tilemaps() -> void:
	for child : Node in self.get_children():
		if(child is TileMapLayer):
			child.queue_free()

func make_a_beep() -> void:
	if(%Beep.playing == false):
		%Beep.play()
