extends Node2D

var playback_scene: PackedScene = preload("res://main/board_playback.tscn")
var setup_res: PackedScene = load("res://main/traveller_setup_menu.tscn")

var main_tilemap_scene: TileMapLayer

var has_sim_ended: bool = false

func _ready() -> void:
	$TravellerSetupMenu.setup_done.connect(tilemap_created)


func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("Toggle Sound")):
		Global.sound_muted = not Global.sound_muted
	if(Input.is_action_just_pressed("ui_down")):
		%Camera2D.zoom -= (%Camera2D.zoom * 0.1)
	if(Input.is_action_just_pressed("ui_up")):
		%Camera2D.zoom += (%Camera2D.zoom * 0.1)

func tilemap_created() -> void:
	for child: Node in get_children():
		if child is TileMapLayer:
			main_tilemap_scene = child
			child.update_cells_claimed.connect(update_cells_percentage_claimed_data)
			child.beep.connect(make_a_beep)
	%UI.update_no_of_labels()
	%UI.show()
	%UI.stop_updating_turns = false
	$UI/ReplayButton.hide()
	$UI/EndOfSimLabel.hide()
	has_sim_ended = false
	for child: Label in %UI/Labels.get_children():
		child.hide()


func end_of_sim_actions() -> void:
	if(has_sim_ended == true): return
	has_sim_ended = true
	
	for child: Traveller in main_tilemap_scene.get_children():
		child.disabled = true
	%UI.stop_updating_turns = true
	$UI/ReplayButton.show()
	$UI/EndOfSimLabel.show()
	
	# Colour wins label
	# TODO make it centered? and needs testing
	
	var current_highest_colour_claimed: String
	var current_highest_amount_claimed: float = 0
	
	for key in GlobalTravInfo.team_cells_claimed.keys():
		if(GlobalTravInfo.team_cells_claimed[key] > current_highest_amount_claimed):
			current_highest_amount_claimed = GlobalTravInfo.team_cells_claimed[key]
			current_highest_colour_claimed = CellColour.vector2i_to_colour_name(key)
	
	create_win_text(str(current_highest_colour_claimed) + " won!")
	

func create_win_text(message: String) -> void:
	var message_label: Label = Label.new()
	message_label.text = message
	message_label.theme = load("res://main/ui/main_theme.tres")
	message_label.add_theme_font_size_override("font_size", 24)
	
	@warning_ignore("integer_division")
	message_label.global_position.x = -MetaInfo.screen_size.x / 10
	message_label.global_position.y = -MetaInfo.screen_size.y / 2 + (MetaInfo.fraction_of_screen)
	
	message_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	%UI/Labels.add_child(message_label)
	
	var tween  = create_tween()
	await tween.tween_property(message_label, "modulate:a", 1, 0.5).finished
	
	await get_tree().create_timer(0.7).timeout
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(message_label, "modulate:a", 0, 1.5)
	await tween.parallel().tween_property(message_label, "position:y", -400, 1.7).finished
	
	message_label.queue_free()


func update_cells_percentage_claimed_data(cur_cells_claimed: Array[int]):
	var total_percentage: float = 0
	for i in cur_cells_claimed.size():
		var cur_percentage: float = (float(cur_cells_claimed[i]) / GlobalTravInfo.total_cells_in_grid)
		%UI.cells_claimed_percentages[i] = cur_percentage
		total_percentage += cur_percentage
	
	for key in GlobalTravInfo.team_cells_claimed.keys():
		var cur_percentage: float = (float(GlobalTravInfo.team_cells_claimed[key]) / GlobalTravInfo.total_cells_in_grid)
		GlobalTravInfo.team_cells_claimed[key] = cur_percentage
	
	%UI.update_cell_claimed_labels()
	%UI.update_cur_turn_label()
	
	if(is_equal_approx(total_percentage, 1.0)):
		end_of_sim_actions()


func remove_all_tilemaps() -> void:
	for child: Node in self.get_children():
		if(child is TileMapLayer):
			child.queue_free()


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


func make_a_beep() -> void:
	if(%Beep.playing == false and Global.sound_muted == false):
		%Beep.play()


func _on_replay_button_pressed() -> void:
	remove_all_tilemaps()
	var instantiated_scene: TileMapLayer = playback_scene.instantiate()
	instantiated_scene.name = "PlaybackScene"
	instantiated_scene.scale = Vector2(10, 10)
	add_child(instantiated_scene)
