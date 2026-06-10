extends TileMapLayer

@onready var move_log = GlobalTravInfo.global_move_log

var cur_turn : int = 0

var prev_positions : Array[Vector2i]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# random out of bounds value
	prev_positions.fill(Vector2i(237, 237))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	for i in range(move_log.size()):
		var move = move_log[cur_turn][i]
		for action : Array in move:
			var action_type : String = action[0]
			var action_value : Variant = action[1]
			if(action_type == "move"):
				# fill prev pos with passd colour
				prev_positions[i]
				# fill cur pos with active colour 
				# actin value shold be a vector2i
				action_value
			elif(action_type == "fill"):
				# action value should be array of vector2i
				for coordinate : Vector2i in action_value:
					# fill coordinate in passed colour
					coordinate
			else:
				printerr("Invalid action type in move_log[", i, "]")
			
	cur_turn += 1
