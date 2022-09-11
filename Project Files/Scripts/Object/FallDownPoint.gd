extends Area2D


export (int) var down_floor = 1
#export (int) var up_floor = 2
export (int) var floor_placement = 2
export (bool) var hitboxes_enabled = true
export (float) var fall_distance = 100.00

func _ready():
	
	set_hitboxes_state(hitboxes_enabled)
	change_collision_and_mask(self,floor_placement+9,true)
	
	

func change_collision_and_mask(node,floor_update:int,state:bool):
	node.set_collision_layer_bit(floor_update,state)
	node.set_collision_mask_bit(floor_update,state)

func set_hitboxes_state(state:bool):
	self.monitorable = state
	self.monitoring = state

