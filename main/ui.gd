extends CanvasLayer

var cells_claimed_data : Array[int]

var label_base_text : Array[String]
var label_base_text_coloured : Dictionary[Vector2i, String]

var cells_claimed_percentages : Array[float]
var cells_claimed_percentages_by_colour : Dictionary[Vector2i, float]

func _ready() -> void:
	Engine.physics_ticks_per_second = 12
	self.hide()
	
	# Positioning
	
	var this_screen_size : Vector2i = get_viewport().get_visible_rect().size
	
	%BackButton.position.y = this_screen_size.y / 2.2 - %BackButton.size.y
	$ToggleUILabel.position.y = %BackButton.position.y - $ToggleUILabel.size.y - 5
	
	$CurrentTurnLabel.position.x = this_screen_size.x / 2.2 - $CurrentTurnLabel.size.x - 50
	$SpeedSlider.position.x = this_screen_size.x / 2.2
	$SpeedSliderLabelFast.position.x = $SpeedSlider.position.x + 20
	$SpeedSliderLabelSlow.position.x = $SpeedSlider.position.x + 20
	
	$SpeedSlider.min_value = 0
	var screen_refresh_rate : float = DisplayServer.screen_get_refresh_rate()
	if(screen_refresh_rate > 0):
		$SpeedSlider.max_value = sqrt(screen_refresh_rate)
	else:
		$SpeedSlider.max_value = sqrt(60)
	
	$SpeedSlider.step = 0.1
	$SpeedSlider.value = sqrt(12)
	
func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("ToggleUI")):
		self.visible = !self.visible

func _on_speed_slider_value_changed(value: float) -> void:
	var value_to_ticks : int = int(round(value*value))
	if is_equal_approx(value, 0):
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
		if(value_to_ticks != 0):
			Engine.physics_ticks_per_second = value_to_ticks
		else:
			Engine.physics_ticks_per_second = 1

# Process : mode : always/pausable

func update_no_of_labels() -> void:
	label_base_text.resize(GlobalTravInfo.no_of_travellers)
	
	for key in GlobalTravInfo.team_cells_claimed.keys():
		label_base_text_coloured[key] = ""
	
	cells_claimed_percentages.resize(GlobalTravInfo.no_of_travellers)
	
	# Remove labels currently in it
	
	for child in $PercentagedClaimedBox.get_children():
		child.free()
	for child in $PercentagedClaimedBoxColours.get_children():
		child.free()
	
	for i in GlobalTravInfo.no_of_travellers:
		var new_label = Label.new()
		label_base_text[i] = GlobalTravInfo.traveller_names[i] + ": "
		new_label.add_theme_font_size_override("font_size", 20)
		$PercentagedClaimedBox.add_child(new_label)
		
	for i in GlobalTravInfo.traveller_teams.keys().size():
		var new_label = Label.new()
		label_base_text_coloured[GlobalTravInfo.traveller_teams.keys()[i]] = CellColour.colour_names[CellColour.colours_in_tileset.find(GlobalTravInfo.traveller_teams.keys()[i])].capitalize() + ": "
		new_label.add_theme_font_size_override("font_size", 20)
		$PercentagedClaimedBoxColours.add_child(new_label)
		
	$CurrentTurnLabel.add_theme_font_size_override("font_size", 20)

func update_cell_claimed_labels() -> void:
	for i in $PercentagedClaimedBox.get_child_count():
		var child : Label = $PercentagedClaimedBox.get_child(i)
		# Convert number to percentage
		cells_claimed_percentages[i] *= 100
		# Round the percentage to 2 d.p
		cells_claimed_percentages[i] *= 100
		cells_claimed_percentages[i] = roundf(cells_claimed_percentages[i])
		cells_claimed_percentages[i] /= 100
		child.text = label_base_text[i] + str(cells_claimed_percentages[i]) + "%"
		
	var current_index : int = 0
	for key in GlobalTravInfo.team_cells_claimed.keys():
		var child : Label = $PercentagedClaimedBoxColours.get_child(current_index)
		current_index += 1
		# Convert number to percentage
		GlobalTravInfo.team_cells_claimed[key] *= 100
		# Round the percentage to 2 d.p
		GlobalTravInfo.team_cells_claimed[key] *= 100
		GlobalTravInfo.team_cells_claimed[key] = roundf(GlobalTravInfo.team_cells_claimed[key])
		GlobalTravInfo.team_cells_claimed[key] /= 100
		child.text = label_base_text_coloured[key] + str(GlobalTravInfo.team_cells_claimed[key]) + "%"

func update_cur_turn_label() -> void:
	$CurrentTurnLabel.text = "Turns Passed: " + str(GlobalTravInfo.current_turn)

func _on_toggle_percentages_pressed() -> void:
	$PercentagedClaimedBox.visible = !$PercentagedClaimedBox.visible
	$PercentagedClaimedBoxColours.visible = !$PercentagedClaimedBoxColours.visible
	if $HBoxContainer/TogglePercentages.text == "Show Types":
		$HBoxContainer/TogglePercentages.text = "Show Colours"
	else:
		$HBoxContainer/TogglePercentages.text = "Show Types"
