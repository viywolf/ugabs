extends CanvasLayer

var current_traveller_info : Array[Variant] = [
	"", # Type (string),
	Vector2i.ZERO, # Colour (vector2i), 
	Vector2i.ZERO, # Position (vector2i),
]

@onready var type_select : OptionButton = $MainContainer/TypeContainer/OptionButton
@onready var colour_select : OptionButton = $MainContainer/ColourContainer/OptionButton
@onready var position_select_x : LineEdit = $MainContainer/StartingPosContainer/GridPosInputX
@onready var position_select_y : LineEdit = $MainContainer/StartingPosContainer/GridPosInputY

var info_box_resource : PackedScene = preload("res://main/contender_info_box.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up
	for type : String in GlobalTravInfo.all_traveller_types.keys():
		$MainContainer/TypeContainer/OptionButton.add_item(type.capitalize())
		
	# Only add the main colours?
	for colour : String in CellColour.colour_names:
		$MainContainer/ColourContainer/OptionButton.add_item(colour.capitalize())
		

func _on_add_new_traveller_button_pressed() -> void:
	current_traveller_info[0] = type_select.get_item_text(type_select.get_selected_id())
	current_traveller_info[1] = CellColour.colours_in_tileset[colour_select.get_selected_id()]
	var position_as_vector : Vector2i
	
	if(position_select_x.text.is_valid_int() == false or position_select_y.text.is_valid_int() == false):
		# Show error message or something
		return
		
	position_as_vector.x = int(position_select_x.text)
	position_as_vector.y = int(position_select_y.text)
	current_traveller_info[2] = position_as_vector
	@warning_ignore("integer_division")
	
	if(position_as_vector.x < -GlobalTravInfo.grid_size.x / 2 or position_as_vector.x > GlobalTravInfo.grid_size.x / 2
			or position_as_vector.y < -GlobalTravInfo.grid_size.y / 2 or position_as_vector.y > GlobalTravInfo.grid_size.y / 2):
		# Its out of bounds or something warning
		print("out of bundn range")
		return
	
	if (position_as_vector):
		# This vector used before; cannot have two lil guys on the same cell
		pass
		
	var new_info_box : Node = info_box_resource.instantiate()
	new_info_box.trav_type = current_traveller_info[0]
	new_info_box.trav_colour = current_traveller_info[1]
	new_info_box.trav_start_pos = current_traveller_info[2]
	%CurrentlySelectedOptions.add_child(new_info_box)

func get_traveller_info() -> Array:
	return current_traveller_info
