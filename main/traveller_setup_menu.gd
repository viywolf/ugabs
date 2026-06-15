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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_sim_instance = main_sim_res.instantiate()
	
	# Set up
	for type : String in GlobalTravInfo.all_traveller_types.keys():
		$MainContainer/TypeContainer/OptionButton.add_item(type.capitalize())
		
	# Only add the main colours?
	for colour : String in CellColour.colour_names:
		if colour == "BLACK": break
		$MainContainer/ColourContainer/OptionButton.add_item(colour.capitalize())
	
	# Position limits
	# Make it so this updates as you change the radius size/square to circle
	$MainContainer/StartingPosContainer/GridPosInputX.min_value = int(-GlobalTravInfo.grid_size.x / 2.0)
	$MainContainer/StartingPosContainer/GridPosInputX.max_value = int(GlobalTravInfo.grid_size.x / 2.0)
	$MainContainer/StartingPosContainer/GridPosInputY.min_value = int(-GlobalTravInfo.grid_size.y / 2.0)
	$MainContainer/StartingPosContainer/GridPosInputY.max_value = int(GlobalTravInfo.grid_size.y / 2.0)
	
	$BorderInfo/SpinBox.min_value = 1
	$BorderInfo/SpinBox.max_value = int(GlobalTravInfo.grid_size.y / 2.0)
	
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
		
	var new_info_box : Node = info_box_resource.instantiate()
	new_info_box.trav_type = current_traveller_info[0]
	new_info_box.trav_colour = current_traveller_info[1]
	new_info_box.trav_start_pos = current_traveller_info[2]
	
	new_info_box.node_id = current_trav_id
	new_info_box.remove_this.connect(remove_traveller.bind(current_trav_id))
	
	temp_added_travs_storage[current_trav_id] = current_traveller_info.duplicate()
	
	current_trav_id += 1
	%CurrentlySelectedOptions.add_child(new_info_box)

func get_traveller_info() -> Array:
	return current_traveller_info

func _on_start_button_pressed() -> void:
	for key in temp_added_travs_storage.keys():
		if(temp_added_travs_storage[key] != []):
			main_sim_instance.travellers.push_back(temp_added_travs_storage[key].duplicate())
	
	main_sim_instance.chosen_border_shape = $BorderInfo/OptionButton.text
	main_sim_instance.border_radius = $BorderInfo/SpinBox.value
	
	add_sibling(main_sim_instance)
	setup_done.emit()
	queue_free()
	
func remove_traveller(id : int) -> void:
	for child : Node in %CurrentlySelectedOptions.get_children():
		if child.node_id == id:
			child.queue_free()
			temp_added_travs_storage[id] = []
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
	
	#warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Half of scrren width, temp val for nw
	# Please center it somehow???
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
