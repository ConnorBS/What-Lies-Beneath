extends Sprite
class_name InteractableObjects
export (String) var object_name
export (int) var down_floor = 1
export (int) var up_floor = 2
export (int) var floor_placement = 2
export (bool) var hitboxes_enabled = true
export (String) var key_needed
export (String) var scene_to_change_location
export (int) var spawn_point = 1

export (Texture) var spriteToLoad:Texture


var _collected = false

static func change_collision_and_mask(node,floor_update:int,state:bool):
	node.set_collision_layer_bit(floor_update,state)
	node.set_collision_mask_bit(floor_update,state)

func set_hitboxes_state(state:bool):
	var children_nodes = get_children()
	if children_nodes != null:
		for node in children_nodes:
			if node is Area2D:
				node.set_deferred("monitorable", state)
				node.monitoring = state

func is_there_a_scene_change():
	return scene_to_change_location != ""

func is_there_a_key_needed():
	return key_needed != ""
	
func change_scene_level():
	var locked = false
	if is_there_a_key_needed():
		if !PlayerInventory.has_KeyItem(key_needed):
			locked = true
			
	if locked:
		print ("_on_open_dialogWindow_system_message (",object_name," is locked)")
		_find_level_node()._on_open_dialogWindow_system_message([object_name+" is locked"])
		pass
	
	elif is_there_a_scene_change():
		
		_collected = true
		save_pickup_state()
		PlayerState.Spawn_Point = spawn_point
		_find_level_node().change_level(scene_to_change_location,spawn_point)

func _find_level_node() -> Node:
	var parent = get_parent()
	while parent != null:
		if parent.is_in_group("Level"):
			return parent
		elif parent == get_tree():
			push_warning("Tried to find Level Node from Interactable Object, no parents reporting as \"Level\" group")
			parent = null
		else:
			parent = parent.get_parent()
	return parent
func has_overhead_text():
	return false


func load_pickup_state():
	pass

func save_pickup_state():
	pass

