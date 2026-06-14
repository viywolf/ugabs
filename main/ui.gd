extends CanvasLayer

var cells_claimed_data : Array[int]

var label_base_text : Array[String]

var cells_claimed_percentages : Array[float]

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

func update_no_of_labels() -> void:
	label_base_text.resize(GlobalTravInfo.no_of_travellers)
	cells_claimed_percentages.resize(GlobalTravInfo.no_of_travellers)
	for i in GlobalTravInfo.no_of_travellers:
		var new_label = Label.new()
		label_base_text[i] = GlobalTravInfo.traveller_names[i] + ": "
		new_label.add_theme_font_size_override("font_size", 10)
		$PercentagedClaimedBox.add_child(new_label)

func update_cell_claimed_labels() -> void:
	for i in $PercentagedClaimedBox.get_child_count():
		var child : Label = $PercentagedClaimedBox.get_child(i)
		#cells claimed percentage needs to reset to tbe the same number of travs
		child.text = label_base_text[i] + str(cells_claimed_percentages[i])
		print(child.text)
