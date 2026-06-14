extends TileMapLayer

@export_category("Travellers")

@export var auto_add_travellers : bool = true

# arr = ["traveller type", vector2i colour, vector2i start pos]

@export var travellers : Array

enum TravInfo {
	TYPE, COLOUR, START_POS
}

# Colour -> astar grid
var all_astar_grids : Dictionary[Vector2i, AStarGrid2D]

var astar_grid : AStarGrid2D = AStarGrid2D.new()

# Position : colour
var filled_cells_in_grid : Dictionary

# making an astar grid for each colour
# which allows teams

"""
[
	[[action type, action value]],[ [action type, action value]],
	[[action type, action value]],[ [action type, action value]], for each move
	] traveller no
[fill, [(pos, filled), (for, every_pos)]]
[move, (pos, moved_to)]

"""

var moves_finished : Array[bool]

func get_astar_grid(current_passed_colour : Vector2i) -> AStarGrid2D:
	return all_astar_grids[current_passed_colour]

func update_solid_points(current_astar_grid : AStarGrid2D, good_active_colour : Vector2i, good_passed_colour : Vector2i) -> void:
	for x in range(GlobalTravInfo.grid_size.x):
		for y in range(GlobalTravInfo.grid_size.y):
			var current_tile_data = get_cell_tile_data(Vector2i(x - 60, y - 35))
			if(current_tile_data == null): continue
			if(current_tile_data.get_custom_data("Colour") != good_active_colour 
			and current_tile_data.get_custom_data("Colour") != good_passed_colour):
				current_astar_grid.set_point_solid(Vector2i(x - 60, y - 35))

func _ready() -> void:
	if name == "OriginalTileMap":
		queue_free()
		return
	
	if auto_add_travellers == true:
		for traveller : Array[Variant] in travellers:
			var traveller_type = traveller[TravInfo.TYPE]
			traveller_type = traveller_type.to_lower()
			var trav_colour : Vector2i = traveller[TravInfo.COLOUR]
			
			var new_traveller_node = Node.new()
			
			match traveller_type:
				"user":
					new_traveller_node.set_script(load("res://main/travellers/user.gd"))
				"random":
					new_traveller_node.set_script(load("res://main/travellers/random.gd"))
				"random location":
					new_traveller_node.set_script(load("res://main/travellers/random_seeker.gd"))
				_:
					printerr("Invalid traveller type entered")
					assert(false)
			
			new_traveller_node.active_colour = Vector2i(trav_colour.x, 0)
			new_traveller_node.passed_colour = Vector2i(trav_colour.x, 1)
			
			new_traveller_node.current_position = traveller[TravInfo.START_POS]
			
			add_child(new_traveller_node)
					
		for child : Traveller in get_children():
			child.disabled = false
	
	GlobalTravInfo.global_move_log.resize(self.get_child_count())
	moves_finished.resize(self.get_child_count())
	moves_finished.fill(true)
	
	GlobalTravInfo.no_of_travellers = self.get_child_count()
	GlobalTravInfo.traveller_colours.resize(GlobalTravInfo.no_of_travellers)
	GlobalTravInfo.is_traveller_disabled.resize(GlobalTravInfo.no_of_travellers)
	
	# index 0 for empty space
	GlobalTravInfo.traveller_cells_claimed.resize(GlobalTravInfo.no_of_travellers + 1)
	GlobalTravInfo.traveller_cells_claimed.fill(0)
	# The number of empty cells in the grid (placehodl valeu)
	GlobalTravInfo.traveller_cells_claimed[0] = 832409
	
	for arr : Array in GlobalTravInfo.global_move_log:
		arr.push_back([])
	
	if self.get_child_count() == 0:
		printerr(name, " has no children")
	
	for i in range(self.get_child_count()):
	#for child : Traveller in self.get_children():
		var child : Traveller = self.get_child(i)
		
		child.move_finished.connect(traveller_move_finished.bind(i))
		
		GlobalTravInfo.traveller_colours[i] = child.active_colour.x
		GlobalTravInfo.is_traveller_disabled[i] = child.disabled
		child.child_no = i
		
		if(child.disabled): continue
		var new_astar_grid : AStarGrid2D = AStarGrid2D.new()
		@warning_ignore("integer_division")
		new_astar_grid.region = Rect2i(Vector2i(-GlobalTravInfo.grid_size.x / 2, -GlobalTravInfo.grid_size.y / 2), GlobalTravInfo.grid_size)
		new_astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		new_astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
		new_astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
		new_astar_grid.update()
		all_astar_grids[child.passed_colour] = new_astar_grid
		# Set up astar grid
		update_solid_points(get_astar_grid(child.passed_colour), child.active_colour, child.passed_colour)
		
		child.set_cell_colour(child.current_position, child.active_colour)
	
func _physics_process(_delta: float) -> void:
	if name == "OriginalTileMap":
		queue_free()
		return
	
	if is_all_travellers_finished() == false:
		return
	GlobalTravInfo.current_turn += 1
	
	for arr : Array in GlobalTravInfo.global_move_log:
		arr.push_back([])
	
	for i in range(get_child_count()):
		var child : Traveller = self.get_child(i)
		if(GlobalTravInfo.current_turn % int(child.get_speed()) == 0):
			child.start_moving()
		child.move_log.push_back(child.current_position)
		var arr_to_be_added = ["move", child.current_position]
		GlobalTravInfo.global_move_log[i][GlobalTravInfo.current_turn].push_back(arr_to_be_added)
		#print("push back ", arr_to_be_added, " to ", i)
	# Re calculate astar grids
	if(GlobalTravInfo.current_turn % 10 == 0):
		for child : Traveller in self.get_children():
			if child.disabled: continue
			update_solid_points(get_astar_grid(child.passed_colour), child.active_colour, child.passed_colour)
		
		
func traveller_move_finished(traveller_no : int) -> void:
	moves_finished[traveller_no] = true
	
func is_all_travellers_finished() -> bool:
	for i in range(moves_finished.size()):
		if moves_finished[i] == false:
			return false
	moves_finished.fill(false)
	return true
