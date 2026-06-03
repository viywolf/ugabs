extends TileMapLayer

@export_category("Travellers")

@export var travellers : Array[String]

var current_turn : int = 0

var astar_grid : AStarGrid2D = AStarGrid2D.new()

var grid_size : Vector2i = Vector2i(120 + 1, 70 + 1)


# needs to be in the individual code so it can cross in the same colour
# or maybe make an astar grid for each colour?
func update_solid_points() -> void:
	pass


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
	
	astar_grid.region = Rect2i(Vector2i(-60, -35), grid_size)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar_grid.update()
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			if(get_cell_tile_data(Vector2i(x - 60, y - 35)) != null):
				astar_grid.set_point_solid(Vector2i(x - 60, y - 35))

func _physics_process(_delta: float) -> void:
	current_turn += 1
	for traveller in get_children():
		if(current_turn % int(traveller.get_speed()) == 0):
			traveller.move(traveller.get_next_position())
		traveller.move_log.push_back(traveller.current_position)
		
