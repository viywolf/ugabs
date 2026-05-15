extends TileMapLayer

var current_turn : int = 0

func _ready() -> void:
	Engine.physics_ticks_per_second = 6

func _physics_process(delta: float) -> void:
	current_turn += 1
	for traveller in get_children():
		if(current_turn % int(traveller.get_speed()) == 0):
			traveller.get_move()











"""
This carries all the global variables such as every traveller position.
Children can easily access it.
Also consider moving all the 'move' functions here
as I'm not sure if it's the best to keep it in the children.
But we also have to consider things like speed of movement
and size of traveller.

Also add the whole type of traveller (bfs, etc, basically movement algorithm) [travel type!]
vs traveller modifier (bigger, faster, etc, things unrelated to movement algo)

-j
"""

"""
(v)
[j]
{m}
|s|
"""
