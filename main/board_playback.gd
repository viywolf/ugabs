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
	draw_shape_border(GlobalTravInfo.grid_shape.to_lower(), GlobalTravInfo.grid_radius)
	# Fill in the starting cell for each trav
	for key in GlobalTravInfo.starting_colours_positions:
		# The key is saved as the base colour, but we want to use the desat colour
		set_cell_colour(GlobalTravInfo.starting_colours_positions[key], Vector2i(key.x, 1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	for i in range(move_log.size()):
		if GlobalTravInfo.is_traveller_disabled[i] == true:
			continue
		
		# Assuming that there will always be at least one traveller
		if cur_turn >= move_log[0].size():
			break
		
		var move = move_log[i][cur_turn]
		for action : Array in move:
			var action_type : String = action[0]
			# Action value can be an array of vector2i OR vector2i
			var action_value : Variant = action[1]
			var position_of_trav : Vector2i = Vector2i(237, 237)
			if(action_type == "fill"):
				# action value should be array of vector2i
				for coordinate : Vector2i in action_value:
					set_cell_colour(coordinate, Vector2i(GlobalTravInfo.traveller_colours[i], 1))
			elif(action_type == "move"):
				# actin value shold be a vector2i
				set_cell_colour(prev_positions[i], Vector2i(GlobalTravInfo.traveller_colours[i], 1))
				prev_positions[i] = action_value
				set_cell_colour(action_value, Vector2i(GlobalTravInfo.traveller_colours[i], 0))
				position_of_trav = action_value
			else:
				printerr("Invalid action type in move_log[", i, "]")
			if position_of_trav != Vector2i(237,237):
				set_cell_colour(position_of_trav, Vector2i(GlobalTravInfo.traveller_colours[i], 0))
			
	cur_turn += 1


func draw_shape_border(shape: String, radius: int) -> void:
	if(radius <= 0):
		printerr("Radius must be greater than 0")
		return
	
	var middle: Vector2i = Vector2i(0, 0)
	var min_y: int = middle.y - radius
	var max_y: int = middle.y + radius
	var min_x: int = middle.x - radius
	var max_x: int = middle.x + radius
	
	shape = shape.to_lower()
	
	var colour_black: Vector2i = CellColour.colours_in_tileset[CellColour.TilesetColour.BLACK]
	if(shape != "logo"):
		clear()
	if(shape == "square"):
		# Draw top and bottom lines
		for i in abs(min_x) + max_x + 1:
			set_cell(Vector2i(i - radius, min_y), 0, colour_black)
			set_cell(Vector2i(i - radius, max_y), 0, colour_black)
			
		# Draw left and rigth lines
		for i in abs(min_y) + max_y + 1:
			set_cell(Vector2i(min_x, i - radius), 0, colour_black)
			set_cell(Vector2i(max_x, i - radius), 0, colour_black)
	elif(shape == "circle"):
		var d: int = floori(3 - (2 * radius))
		var x: int = 0
		var y: int = radius
		
		var continue_loop: bool = true
		
		while(continue_loop == true):
			# Midpoint circle algorithm
			
			set_cell(Vector2i(middle.x + x, middle.y + y), 0, colour_black)
			set_cell(Vector2i(middle.x + x, middle.y - y), 0, colour_black)
			set_cell(Vector2i(middle.x - x, middle.y + y), 0, colour_black)
			set_cell(Vector2i(middle.x - x, middle.y - y), 0, colour_black)
			set_cell(Vector2i(middle.x + y, middle.y + x), 0, colour_black)
			set_cell(Vector2i(middle.x + y, middle.y - x), 0, colour_black)
			set_cell(Vector2i(middle.x - y, middle.y + x), 0, colour_black)
			set_cell(Vector2i(middle.x - y, middle.y - x), 0, colour_black)
			
			if(d < 0):
				d = floori(d + (4 * x) + 6)
			else:
				d = floori(d + 4 * (x - y) + 10)
				y -= 1
			x += 1
			
			continue_loop = (x <= y)
	elif(shape == "logo"):
		print("logo")
	else:
		printerr("Unknown shape: " + shape)
