extends InteractableObjects
tool

export (Vector2) var scale_of_interactable_box = Vector2(1,1)

 
func _ready():
	self.texture = spriteToLoad
	change_collision_and_mask($Area2D,floor_placement+9,true)
	set_hitboxes_state(hitboxes_enabled)
	$Area2D/CollisionShape2D.scale = scale_of_interactable_box

func _process(delta):
	if Engine.editor_hint:
		$Area2D/CollisionShape2D.scale = scale_of_interactable_box
