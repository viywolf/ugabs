extends TileMapLayer

var current_turn : int = 0

func _ready() -> void:
	pass
	Engine.physics_ticks_per_second = 12

func _physics_process(_delta: float) -> void:
	current_turn += 1
	for traveller in get_children():
		if(current_turn % int(traveller.get_speed()) == 0):
			traveller.move(traveller.get_next_position())


"""
This carries all the global variables such as every traveller position.
"""
