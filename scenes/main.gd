extends Node2D

enum TilesetColour {
	RED, ORANGE, YELLOW, LIME, GREEN, CYAN, BLUE, PURPLE, PINK, BLACK,
	DESATURATED_RED, DESATURATED_ORANGE, DESATURATED_YELLOW, DESATURATED_LIME, DESATURATED_GREEN, DESATURATED_CYAN, DESATURATED_BLUE, DESATURATED_PURPLE, DESATURATED_PINK, DARK_GREY,
	LIGHT_GREY,
	OFF_WHITE,
	WHITE,
}

var colours_in_tileset = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0), Vector2i(7, 0), Vector2i(8, 0), Vector2i(9, 0),
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1), Vector2i(9, 1),
	Vector2i(9, 2),
	Vector2i(9, 3),
	Vector2i(9, 4), 
]

var a = [-1, 0, 1]

var starting_cells : Array[Vector2i] = [
	Vector2i(0,0),
]

var queue : Array = []
var cur_cell
var visited_cells : Dictionary

var time_per_tick : float = 0.5

# For traversing the queue without deleting elements -v
var cur_index : int = 0
var THRESHOLD_BEFORE_POINTER : int = 50
var trigger_pointer_mode : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for cell in starting_cells:
		$TileMapLayer.set_cell(cell, 0, colours_in_tileset[TilesetColour.ORANGE])
		queue.push_back(cell)
		visited_cells[cell] = true
	
	#Engine.physics_ticks_per_second = 1

func _physics_process(delta: float) -> void:
	if(queue.is_empty() == false):
		# We can try make this more aggressive to keep it lower than 150 -v
		var reset_threshold : int = 30
		if(cur_index >= reset_threshold):
			var new_queue : Array
			for i in range(queue.size() - reset_threshold):
				new_queue.push_back(queue[i + reset_threshold])
			queue = new_queue
			cur_index = 0
		if(trigger_pointer_mode):
			# To stop it from erroring when the array is of size one
			if(cur_index >= queue.size()):
				queue.clear()
				return
			cur_cell = queue[cur_index]
			cur_index += 1
			"""
			cur_cell = queue.front()
			queue.pop_front()
			"""
		$TileMapLayer.set_cell(cur_cell, 0, colours_in_tileset[TilesetColour.ORANGE])
		add_to_queue(cur_cell)
	else:
		print("all done")

func add_to_queue(cell : Vector2) -> void:
	for i in range(3):
		# Limitting the range of the exapnsion -v
		#if(cur_cell.x + a[i] < 0 or cur_cell.x + a[i] > 5): continue
		for j in range(3):
			if(abs(a[i]) == abs(a[j])): continue
			#if(cur_cell.y + a[j] < 0 or cur_cell.x + a[j] > 5): continue
			# We are adding stuff here multiple times -v
			if(visited_cells.get(Vector2i(cur_cell.x + a[i],cur_cell.y + a[j])) == null):
				# This prevents it from going if the cell already has a colour
				if($TileMapLayer.get_cell_tile_data(Vector2i(cell.x + a[i],cell.y + a[j])) == null):
					queue.push_back(Vector2i(cell.x + a[i],cell.y + a[j]))
					print("added " + str(Vector2i(cell.x + a[i],cell.y + a[j])) + " to queue")
					visited_cells[Vector2i(cell.x + a[i],cell.y + a[j])] = true
			else:
				print("already done")
			#await get_tree().create_timer(time_per_tick).timeout
