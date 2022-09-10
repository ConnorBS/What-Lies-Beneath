extends Sprite
export (Texture) var spriteToLoad:Texture

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.texture = spriteToLoad
	pass # Replace with function body.

