extends Sprite
class_name InteractableObjects

export (int) var down_floor = 1
export (int) var up_floor = 2
export (int) var floor_placement = 2
export (bool) var hitboxes_enabled = true
export (String) var scene_to_change_location
export (int) var spawn_point = 1

export (Texture) var spriteToLoad:Texture
export (String) var dialog_trigger:String
export (bool) var dialog_one_time_trigger = false
var dialog_trigger_count:int = 0

export (bool) var overhead_one_time_trigger = false
export (String) var overhead_text= ""
export (AudioStream) var overhead_voice_over = null
var overhead_trigger_count:int = 0

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
	if dialog_trigger == "" or dialog_trigger == null:
		return
	else:
		if dialog_one_time_trigger == false or dialog_trigger_count == 0:
			dialog_trigger_count += 1
			emit_signal("dialogWindow",dialog_trigger)
			if dialog_one_time_trigger:
				$Area2D.monitoring = false
				$Area2D.monitorable = false
				$Particles2D.emitting = false
				$Area2D.queue_free()
				$Particles2D.queue_free()
		else: 
			return
	
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
	
func has_overhead_text()->bool:
	return overhead_text != ""
	
func get_overhead_text():
	if overhead_one_time_trigger:
		if overhead_trigger_count <= 0:
			if overhead_text != "":
				overhead_trigger_count += 1
				return overhead_text
			return ""
		return ""
	else:
		if overhead_text != "":
			return overhead_text
		return ""

func overhead_voice_over() -> AudioStream:
	return overhead_voice_over
