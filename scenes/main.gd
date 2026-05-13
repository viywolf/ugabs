extends Node2D

var a = [-1, 0, 1]

var starting_cell : Vector2 = Vector2(0,0)

var queue : Array = []
var cur_cell
var visited_cells : Dictionary

var time_per_tick : float = 0.5

# For traversing the queue without deleting elements
var cur_index : int = 0
var THRESHOLD_BEFORE_POINTER : int = 50
var trigger_pointer_mode : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TileMapLayer.set_cell(starting_cell, 0, Vector2i(0, 55))
	queue.push_back(starting_cell)
	visited_cells[starting_cell] = true
	
	Engine.physics_ticks_per_second = 10

func _physics_process(delta: float) -> void:
	# Make it so it only triggers the following code if the time is modulo 0 -v
	#(Time.get_ticks_msec() * 100 - (floor(Time.get_ticks_msec() * 100 / (time_per_tick)) * time_per_tick)
	#if(int(Time.get_ticks_usec()) % 11 != 0): return
	
	if(queue.is_empty() == false):
		if(queue.size() >= THRESHOLD_BEFORE_POINTER):
			trigger_pointer_mode = true
		if(trigger_pointer_mode):
			cur_cell = queue[cur_index]
			cur_index += 1
		else:
			cur_cell = queue.front()
			queue.pop_front()
		$TileMapLayer.set_cell(cur_cell, 0, Vector2i(0, 55))
		add_to_queue(cur_cell)

func add_to_queue(cur_cell : Vector2) -> void:
	for i in range(3):
		# Limitting the range of the exapnsion -v
		#if(cur_cell.x + a[i] < 0 or cur_cell.x + a[i] > 5): continue
		for j in range(3):
			if(a[i] == a[j]): continue
			#if(cur_cell.y + a[j] < 0 or cur_cell.x + a[j] > 5): continue
			if(visited_cells.get(Vector2i(cur_cell.x + a[i],cur_cell.y + a[j])) == null):
				queue.push_back(Vector2i(cur_cell.x + a[i],cur_cell.y + a[j]))
				visited_cells[Vector2i(cur_cell.x + a[i],cur_cell.y + a[j])] = true
			#await get_tree().create_timer(time_per_tick).timeout
