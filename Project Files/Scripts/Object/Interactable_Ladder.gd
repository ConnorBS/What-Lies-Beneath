extends Sprite


onready var top_y = to_global($Top/CollisionShape2D.position- $Top.shape_owner_get_shape(0,0).extents).y
onready var bottom_y = to_global($Bottom/CollisionShape2D.position).y
export (int) var down_floor = 1
export (int) var up_floor = 2
export (int) var ladder_floor = 2
func _ready():
	print ("ladder from: ",position," global: ",to_global(position))
