@abstract extends Node

class_name Traveller

var tilemap : TileMapLayer

var directions : Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

@export_category("Colours")

@export var active_colour : Vector2i = CellColour.colours_in_tileset[CellColour.TilesetColour.RED]
@export var passed_colour : Vector2i = CellColour.colours_in_tileset[CellColour.TilesetColour.DESATURATED_RED]

@export_category("Speed")

@export var traveller_speed : float = 1

@export_category("Position")

@export var current_position : Vector2i = Vector2i(0, 0)
var previous_position : Vector2i = Vector2i(0, 0)
var next_position : Vector2i = Vector2i(0, 0)

@export_category("Modifiers")

@export var traveller_modifier : String
@export var disabled : bool = false

@export_category("Path boundries")


@onready var boundaries : Array[Vector2i] = [
	current_position, # top left
	current_position, # top right
	current_position, # botton right
	current_position, # botton left
]

var is_new_position : Dictionary[Vector2i, bool]

func _ready() -> void:
	if(get_parent() is TileMapLayer):
		tilemap = get_parent()
	else:
		printerr("No tile map layer to reference!")

func move(to_next_position : Vector2i) -> void:
	if(disabled):
		return
	next_position = to_next_position
	if(can_move(next_position)):
		previous_position = current_position
		if(is_new_position.get_or_add(current_position, true) == true):
			if(tilemap.get_cell_tile_data(next_position) != null 
			   and (tilemap.get_cell_tile_data(next_position).get_custom_data("Colour") == passed_colour
			or tilemap.get_cell_tile_data(next_position).get_custom_data("Colour") == active_colour)):
				check_if_enclosed(next_position)
				# Moving in the y axis
				if(abs(next_position - current_position).x == 0):
					check_if_enclosed(current_position - directions[2])
					check_if_enclosed(current_position - directions[3])
				# Moving in the x axis
				elif(abs(next_position - current_position).y == 0):
					check_if_enclosed(current_position - directions[0])
					check_if_enclosed(current_position - directions[1])
			is_new_position[next_position] = false
		tilemap.set_cell(next_position, 0, active_colour)
		tilemap.get_cell_tile_data(next_position).set_custom_data("Colour", active_colour)
		tilemap.set_cell(current_position, 0, passed_colour)
		tilemap.get_cell_tile_data(current_position).set_custom_data("Colour", passed_colour)
		current_position = next_position
		
		# Checking boundaries
		
		# top left
		if(current_position.x >= boundaries[0].x and current_position.y <= boundaries[0].y):
			boundaries[0] = current_position
		# top right
		if(current_position.x <= boundaries[1].x and current_position.y <= boundaries[1].y):
			boundaries[1] = current_position
		# bottom right
		if(current_position.x >= boundaries[2].x and current_position.y >= boundaries[2].y):
			boundaries[2] = current_position
		# buttom left
		if(current_position.x <= boundaries[3].x and current_position.y >= boundaries[3].y):
			boundaries[3] = current_position

func can_move(to_next_position : Vector2i) -> bool:
	if(tilemap.get_cell_tile_data(to_next_position) == null or 
	   tilemap.get_cell_tile_data(to_next_position).get_custom_data("Colour") == passed_colour):
		return true
	else:
		return false

func check_if_enclosed(current_next_position : Vector2i) -> void:
	
	disabled = true
	
	print("checking")
	
	var visited : Dictionary[Vector2i, bool] = {}
	
	var q : Array[Vector2i] = []
	q.push_back(current_next_position)
	var cur_index : int = 0
	while(cur_index < q.size()):
		var cur_cell : Vector2i = q[cur_index]
		cur_index += 1
		
		if(visited.get_or_add(cur_cell, false) == false):
			visited[cur_cell] = true
		else:
			continue
		
		#tilemap.set_cell(cur_cell, 0, Vector2i(9, 2))
		
		for direction : Vector2i in directions:
			var next_direction = cur_cell + direction
			
			if(visited.get_or_add(next_direction, false) == true): continue
			
			if(next_direction.x < min(boundaries[0].x, boundaries[3].x) - 1): continue
			if(next_direction.x > max(boundaries[1].x, boundaries[2].x) + 1): continue
			if(next_direction.y < min(boundaries[0].y, boundaries[1].y) - 1): continue
			if(next_direction.y > max(boundaries[2].y, boundaries[3].y) + 1): continue
			
			if(next_direction == current_position): continue
			
			if(tilemap.get_cell_tile_data(next_direction) == null):
				#or tilemap.get_cell_tile_data(next_direction).get_custom_data("Colour") != passed_colour)
				q.push_back(next_direction)
				
		await get_tree().process_frame
		
	print(q)
		
	#print("waiting 3 secs...")
	#await get_tree().create_timer(3).timeout
		
	var cells_to_fill : Array[Vector2i]
	var is_fill_valid : bool = true
	for i in range(min(boundaries[0].x, boundaries[1].x), max(boundaries[2].x, boundaries[3].x)):
		for j in range(min(boundaries[0].y, boundaries[3].y), max(boundaries[2].y, boundaries[1].y)):
			
			if(visited.get_or_add(Vector2i(i, j), false) == true): continue
			
			if(tilemap.get_cell_tile_data(Vector2i(i, j)) == null):
			#or tilemap.get_cell_tile_data(Vector2i(i, j)).get_custom_data("Colour") == passed_colour
			#or tilemap.get_cell_tile_data(Vector2i(i, j)).get_custom_data("Colour") == active_colour):
				cells_to_fill.push_back(Vector2i(i, j))
			elif(tilemap.get_cell_tile_data(Vector2i(i, j)).get_custom_data("Colour").y == 1
				and tilemap.get_cell_tile_data(Vector2i(i, j)).get_custom_data("Colour") != active_colour
				and tilemap.get_cell_tile_data(Vector2i(i, j)).get_custom_data("Colour") != passed_colour):
				print("Invalid fill attempted")
				is_fill_valid = false
				break
			
			
	if(is_fill_valid):
		for cell in cells_to_fill:
			print("filling in " + str(cell))
			tilemap.set_cell(cell, 0, passed_colour)
			tilemap.get_cell_tile_data(cell).set_custom_data("Colour", passed_colour)
		tilemap.get_cell_tile_data(current_position).set_custom_data("Colour", active_colour)
	
	
	disabled = false
	
@abstract func get_next_position() -> Vector2i

func get_speed() -> float:
	return traveller_speed
