extends CanvasLayer

signal setup_done

var current_traveller_info : Array[Variant] = [
	"", # Type (string),
	Vector2i.ZERO, # Colour (vector2i), 
	Vector2i.ZERO, # Position (vector2i),
]

@onready var type_select : OptionButton = $MainContainer/TypeContainer/OptionButton
@onready var colour_select : OptionButton = $MainContainer/ColourContainer/OptionButton
@onready var position_select_x : SpinBox = $MainContainer/StartingPosContainer/GridPosInputX
@onready var position_select_y : SpinBox = $MainContainer/StartingPosContainer/GridPosInputY

var info_box_resource : PackedScene = preload("res://main/contender_info_box.tscn")

var main_sim_res : PackedScene = preload("res://main/main_simulation.tscn")

var main_sim_instance : TileMapLayer

var positions_taken : Dictionary

var current_trav_id : int = 0

var temp_added_travs_storage : Dictionary[int, Array]

@onready var cur_radius : int = $BorderInfo/SpinBox.value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_sim_instance = main_sim_res.instantiate()
	
	# Positioning nodes
	$MainContainer.position.x = MetaInfo.screen_size.x / MetaInfo.fraction_of_screen
	$BorderInfo.position.x = MetaInfo.screen_size.x / MetaInfo.fraction_of_screen
	
	$StartButton.position.x = MetaInfo.screen_size.x / MetaInfo.fraction_of_screen
	$StartButton.position.y = MetaInfo.screen_size.y - $StartButton.size.y - (MetaInfo.screen_size.y / MetaInfo.fraction_of_screen)
	
	%WarningLabel.size.x = $MainContainer.size.x
	%WarningLabel.position.x = $MainContainer.position.x
	%WarningLabel.position.y = $StartButton.position.y - (MetaInfo.fraction_of_screen * 5)
	%WarningLabel.hide()
	
	$ExplanationBox.position.x = $MainContainer.position.x + $MainContainer.size.x + MetaInfo.screen_size.x / MetaInfo.fraction_of_screen
	$ExplanationBox.position.y = $MainContainer.position.y
	
	$ScrollContainer.position.x = MetaInfo.screen_size.x - $ScrollContainer.size.x - (MetaInfo.screen_size.x / MetaInfo.fraction_of_screen)
	
	$ExplanationBox/Label.custom_minimum_size.x = MetaInfo.screen_size.x - $ScrollContainer.custom_minimum_size.x - $MainContainer.size.x - (MetaInfo.screen_size.x / MetaInfo.fraction_of_screen * 4)
	$ExplanationBox.custom_minimum_size.x = $ExplanationBox/Label.custom_minimum_size.x
	$ExplanationBox.custom_minimum_size.y = $MainContainer.size.y + $BorderInfo.size.y
	
	# Set up
	for type : String in GlobalTravInfo.all_traveller_types.keys():
		$MainContainer/TypeContainer/OptionButton.add_item(type.capitalize())
		
	# Only add the main colours?
	for colour : String in CellColour.colour_names:
		if colour == "BLACK": break
		$MainContainer/ColourContainer/OptionButton.add_item(colour.capitalize())
	
	$ExplanationBox/Label.text = GlobalTravInfo.trav_types_desc[0]
	
	update_coords_limits()
	
	$BorderInfo/SpinBox.min_value = 1
	$BorderInfo/SpinBox.max_value = int(GlobalTravInfo.grid_size.y / 2.0)
	
	# Get saved settings if any
	if(SetupSettings.has_saved_settings == true):
		current_trav_id = SetupSettings.saved_current_trav_id
		positions_taken = SetupSettings.saved_positions_taken.duplicate()
		temp_added_travs_storage = SetupSettings.saved_temp_added_travs_storage.duplicate()
		
		match SetupSettings.saved_border_type.capitalize():
			"Square": $BorderInfo/OptionButton.selected = 0
			"Circle": $BorderInfo/OptionButton.selected = 1
			"Logo": $BorderInfo/OptionButton.selected = 2
			_: printerr("Shape not found: " + str(SetupSettings.saved_border_type)) 
			
		$BorderInfo/SpinBox.value = SetupSettings.saved_border_radius
		
		for i in current_trav_id:
			if(temp_added_travs_storage[i] != []):
				add_trav_box_info(temp_added_travs_storage[i][0], temp_added_travs_storage[i][1], temp_added_travs_storage[i][2], i)

func _on_add_new_traveller_button_pressed() -> void:
	current_traveller_info[0] = type_select.get_item_text(type_select.get_selected_id())
	current_traveller_info[1] = CellColour.colours_in_tileset[colour_select.get_selected_id()]
	var position_as_vector : Vector2i
		
	position_as_vector.x = int(position_select_x.value)
	position_as_vector.y = int(position_select_y.value)
	current_traveller_info[2] = position_as_vector
	@warning_ignore("integer_division")
	
	if (positions_taken.get_or_add(position_as_vector, false) == true):
		positions_taken[position_as_vector] = true
		show_warning("Position value entered cannot be the same as a previously added position")
		return
	positions_taken[position_as_vector] = true
	
	add_trav_box_info(current_traveller_info[0], current_traveller_info[1], current_traveller_info[2], current_trav_id)
	current_trav_id += 1

func add_trav_box_info(type : String, colour : Vector2i, pos : Vector2i, cur_id) -> void:
	var new_info_box : Node = info_box_resource.instantiate()
	var this_box_info : Array = [type, colour, pos]
	
	new_info_box.trav_type = type
	new_info_box.trav_colour = colour
	new_info_box.trav_start_pos = pos
	
	new_info_box.node_id = cur_id
	new_info_box.remove_this.connect(remove_traveller.bind(cur_id))
	
	temp_added_travs_storage[cur_id] = this_box_info.duplicate()
	
	%CurrentlySelectedOptions.add_child(new_info_box)

func _on_start_button_pressed() -> void:
	for key in temp_added_travs_storage.keys():
		if(temp_added_travs_storage[key] != []):
			main_sim_instance.travellers.push_back(temp_added_travs_storage[key].duplicate())
	
	main_sim_instance.chosen_border_shape = $BorderInfo/OptionButton.text
	main_sim_instance.border_radius = $BorderInfo/SpinBox.value
	
	add_sibling(main_sim_instance)
	setup_done.emit()
	
	# Save cur settings
	SetupSettings.saved_border_type = $BorderInfo/OptionButton.text
	SetupSettings.saved_border_radius = $BorderInfo/SpinBox.value
	
	SetupSettings.saved_current_trav_id = current_trav_id
	SetupSettings.saved_positions_taken = positions_taken.duplicate()
	SetupSettings.saved_temp_added_travs_storage = temp_added_travs_storage.duplicate()
	SetupSettings.has_saved_settings = true
	
	# Reset cur turn
	GlobalTravInfo.current_turn = 0
	
	Global.setup_open = false
	
	queue_free()
	
func remove_traveller(id : int) -> void:
	for child : Node in %CurrentlySelectedOptions.get_children():
		if child.node_id == id:
			child.queue_free()
			positions_taken.erase(temp_added_travs_storage[id][2])
			temp_added_travs_storage[id] = []
			##await get_tree().process_frame
			##show_or_hide_warning_label()
			return
	printerr("Id " + str(id) + " was not found")

func show_warning(message : String) -> void:
	var warning_panel : Panel = Panel.new()
	
	var warning_label : Label = Label.new()
	warning_label.text = message
	warning_label.add_theme_color_override("font_color", Color(1.0, 0.151, 0.108, 1.0))
	
	warning_panel.size = warning_label.get_combined_minimum_size()
	
	var new_stylebox : StyleBoxFlat = StyleBoxFlat.new()
	new_stylebox.bg_color = Color(0.107, 0.107, 0.107, 0.9)
	new_stylebox.set_expand_margin_all(10)
	new_stylebox.set_corner_radius_all(10)
	new_stylebox.corner_detail = 5
	
	warning_panel.add_theme_stylebox_override("panel", new_stylebox)
	
	# Half of scrren width, temp val for nw
	@warning_ignore("integer_division")
	warning_panel.position.x = (1152 /2) - (1152 / 4)
	warning_panel.position.y = 50
	
	warning_panel.add_child(warning_label)
	add_child(warning_panel)
	
	await get_tree().create_timer(0.7).timeout
	
	var tween  = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(warning_panel, "modulate:a", 0, 0.5)
	await tween.parallel().tween_property(warning_panel, "position:y", -100, 1).finished
	
	warning_panel.queue_free()

func _on_option_button_item_selected(index: int) -> void:
	$ExplanationBox/Label.text = GlobalTravInfo.trav_types_desc[index]

func update_coords_limits() -> void:
	# Position limits
	$MainContainer/StartingPosContainer/GridPosInputX.min_value = int(-cur_radius + 1)
	$MainContainer/StartingPosContainer/GridPosInputX.max_value = int(cur_radius - 1)
	$MainContainer/StartingPosContainer/GridPosInputY.min_value = int(-cur_radius + 1)
	$MainContainer/StartingPosContainer/GridPosInputY.max_value = int(cur_radius - 1)
	
	show_or_hide_warning_label()

func show_or_hide_warning_label() -> void:
	var has_coords_more_than_rad : bool = false
	for child in %CurrentlySelectedOptions.get_children():
		# TODO
		# If its a circle, do a special boundary check
		if($BorderInfo/OptionButton.selected == 1):
			if(abs(child.trav_start_pos.x) + abs(child.trav_start_pos.y) >= cur_radius):
				has_coords_more_than_rad = true
				break
		if(abs(child.trav_start_pos.x) >= cur_radius
			or abs(child.trav_start_pos.y) >= cur_radius):
			has_coords_more_than_rad = true
			
	if has_coords_more_than_rad: 
		%WarningLabel.show()
	else:
		%WarningLabel.hide()

func _on_spin_box_value_changed(value: float) -> void:
	cur_radius = int(value)
	update_coords_limits()
