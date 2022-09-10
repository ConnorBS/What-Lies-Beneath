extends InteractableObjects
export (Texture) var spriteToLoad:Texture

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.texture = spriteToLoad
	change_collision_and_mask($Area2D,floor_placement+9,true)
	set_hitboxes_state(hitboxes_enabled)
	pass # Replace with function body.
