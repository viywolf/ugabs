extends TileMapLayer

@export_category("Travellers")

@export var travellers : Array[String]

var current_turn : int = 0

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

func _physics_process(_delta: float) -> void:
	current_turn += 1
	for traveller in get_children():
		if(current_turn % int(traveller.get_speed()) == 0):
			traveller.move(traveller.get_next_position())
		traveller.move_log.push_back(traveller.current_position)


"""
This carries all the global variables such as every traveller position.
"""
