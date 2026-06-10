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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up
	for type : String in GlobalTravInfo.all_traveller_types.keys():
		$MainContainer/TypeContainer/OptionButton.add_item(type.capitalize())
		
	for colour : String in CellColour.colour_names:
		$MainContainer/ColourContainer/OptionButton.add_item(colour.capitalize())
		

func _on_add_new_traveller_button_pressed() -> void:
	current_traveller_info[0] = type_select.get_item_text(type_select.get_selected_id())
	current_traveller_info[1] = CellColour.colours_in_tileset[colour_select.get_selected_id()]
	# Add some input validation for int only
	var position_as_vector : Vector2i
	position_as_vector.x = int(position_select_x.text)
	position_as_vector.y = int(position_select_y.text)
	current_traveller_info[2] = position_as_vector

func get_traveller_info() -> Array:
	return current_traveller_info
