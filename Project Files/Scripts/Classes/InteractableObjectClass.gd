extends Sprite
class_name InteractableObjects

export (int) var down_floor = 1
export (int) var up_floor = 2
export (int) var floor_placement = 2
export (bool) var hitboxes_enabled = true
export (String) var scene_to_change_location
export (int) var spawn_point = 1

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

func is_there_a_scene_change():
	return scene_to_change_location != ""
	
func trigger_dialog():
	if dialogTrigger == "" or dialogTrigger == null:
		return
	else:
		emit_signal("dialogWindow",dialogTrigger)

func change_scene_level():
	if is_there_a_scene_change():
		PlayerState.Spawn_Point = spawn_point
		var parent = get_parent()
		while parent != null:
			if parent.is_in_group("Level"):
				parent.change_level(scene_to_change_location,spawn_point)
				return
			elif parent == get_tree():
				push_warning("Tried to find scene to change, no parents reporting as \"Level\" group")
				parent = null
			else:
				parent = parent.get_parent()
	
