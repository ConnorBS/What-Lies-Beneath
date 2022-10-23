extends Sprite
class_name InteractableObjects

export (int) var down_floor = 1
export (int) var up_floor = 2
export (int) var floor_placement = 2
export (bool) var hitboxes_enabled = true


export (Texture) var spriteToLoad:Texture
export (String) var dialogTrigger:String

signal dialogWindow

static func change_collision_and_mask(node,floor_update:int,state:bool):
	node.set_collision_layer_bit(floor_update,state)
	node.set_collision_mask_bit(floor_update,state)

func set_hitboxes_state(state:bool):
	var children_nodes = get_children()
	if children_nodes != null:
		for node in children_nodes:
			if node is Area2D:
				node.monitorable = state
				node.monitoring = state

func trigger_dialog():
	if dialogTrigger == "" or dialogTrigger == null:
		return
	else:
		emit_signal("dialogWindow",dialogTrigger)
