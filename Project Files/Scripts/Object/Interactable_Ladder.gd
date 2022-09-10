extends InteractableObjects


onready var top_y = to_global($Top/CollisionShape2D.position- $Top.shape_owner_get_shape(0,0).extents).y
onready var bottom_y = to_global($Bottom/CollisionShape2D.position).y
#export (int) var down_floor = 1
#export (int) var up_floor = 2
#export (int) var ladder_floor = 2
#export (bool) var disabled = false
func _ready():
	set_hitboxes_state(hitboxes_enabled)
	change_collision_and_mask($Top,up_floor+9,true)
	change_collision_and_mask($Top,floor_placement+9,true)
	change_collision_and_mask($Bottom,down_floor+9,true)
	change_collision_and_mask($Bottom,floor_placement+9,true)
	
	
#
#func disable_hitboxes():
#	$Top.monitorable = false
#	$Top.monitoring = false
#	$Bottom.monitorable = false
#	$Bottom.monitoring = false
#	$Top/CollisionShape2D.disabled = true
#	$Bottom/CollisionShape2D.disabled = true

