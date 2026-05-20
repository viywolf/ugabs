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
		if(tilemap.get_cell_tile_data(next_position) != null 
		   and tilemap.get_cell_tile_data(next_position).get_custom_data("Colour") == passed_colour):
			check_if_enclosed(next_position)
		tilemap.set_cell(next_position, 0, active_colour)
		tilemap.get_cell_tile_data(next_position).set_custom_data("Colour", active_colour)
		tilemap.set_cell(current_position, 0, passed_colour)
		tilemap.get_cell_tile_data(current_position).set_custom_data("Colour", passed_colour)
		current_position = next_position

func can_move(to_next_position : Vector2i) -> bool:
	if(tilemap.get_cell_tile_data(to_next_position) == null or 
	   tilemap.get_cell_tile_data(to_next_position).get_custom_data("Colour") == passed_colour):
		return true
	else:
		return false

func check_if_enclosed(current_next_position : Vector2i) -> void:
	var q : Array[Vector2i]
	var visited : Array[Array]
	var visited_list : Array[Vector2i]
	for i in range(500):
		var a:Array
		a.resize(500)
		visited.push_back(a)
		
	# Temporary to stop array from going out of range
	var offset = 250
		
	q.push_back(current_next_position)
	# Make sure we get the empty cell if there is any
	q.push_back(current_next_position + Vector2i.DOWN)
	q.push_back(current_next_position + Vector2i.UP)
	q.push_back(current_next_position + Vector2i.LEFT)
	q.push_back(current_next_position + Vector2i.RIGHT)
	var cur_cell : Vector2i
	print("checking")
	while(q.is_empty() == false):
		cur_cell = q.pop_front()
		var current_cell_data = tilemap.get_cell_tile_data(cur_cell)
		if(visited[cur_cell.x + offset][cur_cell.y + offset] == true):
			continue
		# Doesnt really work, inf loop
		if((current_cell_data != null
		   and (current_cell_data.get_custom_data("Colour") != passed_colour
		   and current_cell_data.get_custom_data("Colour") != active_colour))):
			print("breaking at " + str(cur_cell))
			break
		if(current_cell_data != null and
			current_cell_data.get_custom_data("Colour") == passed_colour):
			continue
		visited[cur_cell.x + offset][cur_cell.y + offset] = true
		visited_list.push_back(cur_cell)
		q.push_back(cur_cell + Vector2i.DOWN)
		q.push_back(cur_cell + Vector2i.UP)
		q.push_back(cur_cell + Vector2i.LEFT)
		q.push_back(cur_cell + Vector2i.RIGHT)
		await get_tree().process_frame
		if(q.size() > 1000):
			print("q too big, breaking")
			break
	print("done")
	print(q.size())
	print(q)
	print("visited")
	print(visited_list)
	if(q.is_empty()):
		printerr("filling it in!!")
		for key in visited_list:
			tilemap.set_cell(key, 0, passed_colour)
	
	#temporary
	if(true):
		for key in visited_list:
			tilemap.set_cell(key, 0, passed_colour)

@abstract func get_next_position() -> Vector2i

func get_speed() -> float:
	return traveller_speed
