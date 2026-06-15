extends Panel

signal remove_this

var trav_type : String
var trav_colour : Vector2i
var trav_start_pos : Vector2i

var node_id : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%TypeLabel.text = "Type: " + trav_type
	%StartPosCoordsLabel.text = "(" + str(trav_start_pos.x) + ", " + str(trav_start_pos.y) + ")"
	
	# Set up box colour
	var coloured_stylebox : StyleBoxFlat = StyleBoxFlat.new()
	coloured_stylebox.bg_color = CellColour.colours_rgba[CellColour.colours_in_tileset.find(trav_colour)]
	
	$HBoxContainer/ColourPanel.add_theme_stylebox_override("panel", coloured_stylebox)

func _on_remove_button_pressed() -> void:
	remove_this.emit()
