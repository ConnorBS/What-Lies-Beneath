extends InteractableObjects


onready var top_y = to_global($Top/CollisionShape2D.position- $Top.shape_owner_get_shape(0,0).extents).y
onready var bottom_y = to_global($Bottom/CollisionShape2D.position).y

func _ready():
	set_hitboxes_state(hitboxes_enabled)
	change_collision_and_mask($Top,up_floor+9,true)
	change_collision_and_mask($Top,floor_placement+9,true)
	change_collision_and_mask($Bottom,down_floor+9,true)
	change_collision_and_mask($Bottom,floor_placement+9,true)
	
