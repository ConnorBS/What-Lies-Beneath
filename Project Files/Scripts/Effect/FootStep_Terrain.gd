extends Area2D

export (String, "Gravel","Wood") var terrain_type
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group(terrain_type)
	pass # Replace with function body.
