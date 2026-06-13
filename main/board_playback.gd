extends TileMapLayer

@onready var move_log = GlobalTravInfo.global_move_log

var cur_turn : int = 0

var prev_positions : Array[Vector2i]

func set_cell_colour(cell_coords : Vector2i, colour : Vector2i):
	self.set_cell(cell_coords, 0, colour)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prev_positions.resize(GlobalTravInfo.no_of_travellers)
	# random out of bounds value
	prev_positions.fill(Vector2i(237, 237))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	for i in range(move_log.size()):
		
		if GlobalTravInfo.is_traveller_disabled[i] == true:
			continue
		
		# Assuming that there will always be at least one traveller
		if cur_turn >= move_log[0].size():
			#print("All moves done")
			break
		
		var move = move_log[i][cur_turn]
		for action : Array in move:
			var action_type : String = action[0]
			var action_value : Variant = action[1]
			var position_of_trav : Vector2i = Vector2i(237, 237)
			if(action_type == "fill"):
				# action value should be array of vector2i
				for coordinate : Vector2i in action_value:
					# fill coordinate in passed colour
					# temp colour
					set_cell_colour(coordinate, Vector2i(GlobalTravInfo.traveller_colours[i], 1))
			elif(action_type == "move"):
				# fill prev pos with passd colour
				set_cell_colour(prev_positions[i], Vector2i(GlobalTravInfo.traveller_colours[i], 1))
				prev_positions[i] = action_value
				# fill cur pos with active colour 
				# actin value shold be a vector2i
				set_cell_colour(action_value, Vector2i(GlobalTravInfo.traveller_colours[i], 0))
				position_of_trav = action_value
			else:
				printerr("Invalid action type in move_log[", i, "]")
			if position_of_trav != Vector2i(237,237):
				set_cell_colour(position_of_trav, Vector2i(GlobalTravInfo.traveller_colours[i], 0))
			
	cur_turn += 1
