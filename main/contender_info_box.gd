extends Panel

signal remove_this

var trav_name: String
var trav_type: String
var trav_colour: Vector2i
var trav_start_pos: Vector2i

var node_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(trav_name == ""):
		trav_name = "(None)"
	%NameLabel.text = "Name: " + trav_name
	%TypeLabel.text = "Type: " + trav_type
	%StartPosLabel.text += " (" + str(trav_start_pos.x) + ", " + str(trav_start_pos.y) + ")"
	
	# Set up box colour
	var coloured_stylebox : StyleBoxFlat = StyleBoxFlat.new()
	coloured_stylebox.bg_color = Color(0.75, 0.75, 0.75, 1.0)
	coloured_stylebox.set_border_width_all(5)
	coloured_stylebox.border_color = CellColour.colours_rgba[CellColour.colours_in_tileset.find(trav_colour)]
	coloured_stylebox.set_corner_radius_all(3)
	
	self.add_theme_stylebox_override("panel", coloured_stylebox)

func _on_remove_button_pressed() -> void:
	remove_this.emit()
