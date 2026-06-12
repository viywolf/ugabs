extends Panel

var trav_type : String
var trav_colour : Vector2i
var trav_start_pos : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%TypeLabel.text = "Type: " + trav_type
	%StartPosLabel.text = "Starting Position: " + str(trav_start_pos.x) + ", " + str(trav_start_pos.y)
