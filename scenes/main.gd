extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TileMapLayer.set_cell(Vector2i(1,1), 0, Vector2i(0, 55))
