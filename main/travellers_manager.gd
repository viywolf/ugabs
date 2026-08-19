extends TileMapLayer

# Emits every turn, with a Array[int] of cells claimed
signal update_cells_claimed

signal beep

@export_category("Travellers")

@export var auto_add_travellers: bool = true

# arr = ["traveller type", vector2i colour, vector2i start pos]

@export var travellers: Array

enum TravInfo {
	NAME, TYPE, COLOUR, START_POS
}

# Border making stuff

var chosen_border_shape: String
var border_radius: int

# Colour -> astar grid
var all_astar_grids: Dictionary[Vector2i, AStarGrid2D]

var astar_grid: AStarGrid2D = AStarGrid2D.new()

# Position: colour
var filled_cells_in_grid: Dictionary

var empty_cells_in_grid: Dictionary[Vector2i, bool]

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

var moves_finished: Array[bool]

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
		
func get_astar_grid(current_passed_colour: Vector2i) -> AStarGrid2D:
	return all_astar_grids[current_passed_colour]

func update_solid_points(current_astar_grid: AStarGrid2D, good_active_colour: Vector2i, good_passed_colour: Vector2i) -> void:
	for x in range(GlobalTravInfo.grid_size.x):
		for y in range(GlobalTravInfo.grid_size.y):
			@warning_ignore("integer_division")
			var current_tile_data = get_cell_tile_data(Vector2i(x - GlobalTravInfo.grid_size.x / 2, y - GlobalTravInfo.grid_size.y / 2))
			if(current_tile_data == null): continue
			if(current_tile_data.get_custom_data("Colour") != good_active_colour 
			and current_tile_data.get_custom_data("Colour") != good_passed_colour):
				@warning_ignore("integer_division")
				current_astar_grid.set_point_solid(Vector2i(x - GlobalTravInfo.grid_size.x / 2, y - GlobalTravInfo.grid_size.y / 2))

func _ready() -> void:
	draw_shape_border(chosen_border_shape, border_radius)
	
	GlobalTravInfo.grid_radius = border_radius
		
	# quick dfs here to get grid size:>
	
	if(chosen_border_shape != "logo"):
		var cells_in_grid: int = 0
		
		var stack: Array[Vector2i]
		stack.push_back(Vector2i(0,0))
		var visited: Dictionary[Vector2i, bool]
		
		while(stack.is_empty() == false):
			var cur_node = stack.pop_back()
			if(visited.get_or_add(cur_node, false) == true):
				continue
			else:
				visited[cur_node] = true
				cells_in_grid += 1
				empty_cells_in_grid[cur_node] = true
				
			for direction in GlobalTravInfo.directions:
				if(get_cell_tile_data(cur_node + direction) == null):
					stack.push_back(cur_node + direction)
					
		GlobalTravInfo.total_cells_in_grid = cells_in_grid
		
	# Check and change all cell data to filled
	
	for x in range(GlobalTravInfo.grid_size.x):
		for y in range(GlobalTravInfo.grid_size.y):
			if(get_cell_tile_data(Vector2i(x, y)) != null):
				get_cell_tile_data(Vector2i(x, y)).set_custom_data("Colour", Vector2i(9, 0))
	
	if auto_add_travellers == true:
		for traveller: Array[Variant] in travellers:
			var traveller_type: String = traveller[TravInfo.TYPE]
			traveller_type = traveller_type.to_lower()
			var trav_colour: Vector2i = traveller[TravInfo.COLOUR]
			
			var new_traveller_node = Node.new()
			
			if(GlobalTravInfo.all_traveller_types.get(traveller_type) != null):
				new_traveller_node.set_script(GlobalTravInfo.all_traveller_types[traveller_type])
			else:
				printerr("Invalid traveller type entered")
				continue
			
			new_traveller_node.trav_name = traveller[TravInfo.NAME]
			
			new_traveller_node.active_colour = Vector2i(trav_colour.x, 0)
			new_traveller_node.passed_colour = Vector2i(trav_colour.x, 1)
			
			new_traveller_node.current_position = traveller[TravInfo.START_POS]
			
			empty_cells_in_grid.erase(new_traveller_node.current_position)
			
			add_child(new_traveller_node)
					
		for child: Traveller in get_children():
			child.disabled = false
	
	GlobalTravInfo.global_move_log.resize(self.get_child_count())
	moves_finished.resize(self.get_child_count())
	moves_finished.fill(true)
	
	GlobalTravInfo.no_of_travellers = self.get_child_count()
	GlobalTravInfo.traveller_colours.resize(GlobalTravInfo.no_of_travellers)
	GlobalTravInfo.is_traveller_disabled.resize(GlobalTravInfo.no_of_travellers)
	GlobalTravInfo.traveller_names.resize(GlobalTravInfo.no_of_travellers)
	
	for arr: Array in GlobalTravInfo.global_move_log:
		arr.push_back([])
	
	if self.get_child_count() == 0:
		printerr(name, " has no children")
	
	for i in range(self.get_child_count()):
	#for child: Traveller in self.get_children():
		var child: Traveller = self.get_child(i)
		
		child.move_finished.connect(traveller_move_finished.bind(i))
		child.can_beep.connect(emit_signal_beep)
		
		#GlobalTravInfo.traveller_teams[child.active_colour] = true
		GlobalTravInfo.team_cells_claimed[child.active_colour] = 0
		
		GlobalTravInfo.traveller_colours[i] = child.active_colour.x
		GlobalTravInfo.is_traveller_disabled[i] = child.disabled
		GlobalTravInfo.traveller_names[i] = child.name
		child.child_no = i
		
		if(child.disabled): continue
		var new_astar_grid: AStarGrid2D = AStarGrid2D.new()
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
	
	for arr: Array in GlobalTravInfo.global_move_log:
		arr.push_back([])
	
	for i in range(get_child_count()):
		var child: Traveller = self.get_child(i)
		if(GlobalTravInfo.current_turn % int(child.get_speed()) == 0):
			child.start_moving()
		child.move_log.push_back(child.current_position)
		var arr_to_be_added = ["move", child.current_position]
		GlobalTravInfo.global_move_log[i][GlobalTravInfo.current_turn].push_back(arr_to_be_added)
	# Re calculate astar grids
	if(GlobalTravInfo.current_turn % 10 == 0):
		for child: Traveller in self.get_children():
			if child.disabled: continue
			update_solid_points(get_astar_grid(child.passed_colour), child.active_colour, child.passed_colour)
	
	var cur_cells_claimed: Array[int]
	
	for key in GlobalTravInfo.team_cells_claimed.keys():
		GlobalTravInfo.team_cells_claimed[key] = 0
	
	for child: Traveller in get_children():
		cur_cells_claimed.push_back(child.cells_claimed)
		GlobalTravInfo.team_cells_claimed[child.active_colour] += child.cells_claimed
	
	update_cells_claimed.emit(cur_cells_claimed)
	
func traveller_move_finished(traveller_no: int) -> void:
	moves_finished[traveller_no] = true
	
func is_all_travellers_finished() -> bool:
	for i in range(moves_finished.size()):
		if moves_finished[i] == false:
			return false
	moves_finished.fill(false)
	return true

func emit_signal_beep() -> void:
	beep.emit()
