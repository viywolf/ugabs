extends TileMapLayer

@export_category("Travellers")

@export var travellers : Array[String]

var current_turn : int = 0

# Colour -> astar grid
var all_astar_grids : Dictionary[Vector2i, AStarGrid2D]

var astar_grid : AStarGrid2D = AStarGrid2D.new()

var grid_size : Vector2i = Vector2i(120 + 1, 70 + 1)

# making an astar grid for each colour
# which allows teams

func get_astar_grid(current_passed_colour : Vector2i) -> AStarGrid2D:
	return all_astar_grids[current_passed_colour]

func update_solid_points(current_astar_grid : AStarGrid2D, good_active_colour : Vector2i, good_passed_colour : Vector2i) -> void:
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var current_tile_data = get_cell_tile_data(Vector2i(x - 60, y - 35))
			if(current_tile_data == null): continue
			if(current_tile_data.get_custom_data("Colour") != good_active_colour 
			and current_tile_data.get_custom_data("Colour") != good_passed_colour):
				current_astar_grid.set_point_solid(Vector2i(x - 60, y - 35))

func _ready() -> void:
	"""
	for traveller_type in travellers:
		traveller_type = traveller_type.to_lower()
		
		var new_traveller_node = Node.new()
		
		match traveller_type:
			"user":
				new_traveller_node.set_script(load("res://scripts/travellers/user.gd"))
			"random":
				new_traveller_node.set_script(load("res://scripts/travellers/random.gd"))
			_:
				printerr("Invalid traveller type entered")
				assert(false)
		
		add_child(new_traveller_node)
				
	for child : Traveller in get_children():
		child.disabled = false
		
	"""
				
	Engine.physics_ticks_per_second = 12
	
	for child : Traveller in self.get_children():
		if(child.disabled): continue
		var new_astar_grid : AStarGrid2D = AStarGrid2D.new()
		new_astar_grid.region = Rect2i(Vector2i(-60, -35), grid_size)
		new_astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		new_astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
		new_astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
		new_astar_grid.update()
		all_astar_grids[child.passed_colour] = new_astar_grid
		# Set up astar grid
		update_solid_points(get_astar_grid(child.passed_colour), child.active_colour, child.passed_colour)
		
		child.set_cell_colour(child.current_position, child.active_colour)
	
func _physics_process(_delta: float) -> void:
	current_turn += 1
	for traveller in get_children():
		if(current_turn % int(traveller.get_speed()) == 0):
			traveller.start_moving()
		traveller.move_log.push_back(traveller.current_position)
		
	# Re calculate astar grids
	if(current_turn % 10 == 0):
		for child : Traveller in self.get_children():
			if child.disabled: continue
			update_solid_points(get_astar_grid(child.passed_colour), child.active_colour, child.passed_colour)
		
