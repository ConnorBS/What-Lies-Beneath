extends InteractableObjects
tool

export (String) var dialog_trigger:String
export (bool) var dialog_one_time_trigger = false
var dialog_trigger_count:int = 0

export (bool) var overhead_one_time_trigger = false
export (String) var overhead_text= ""
export (AudioStream) var overhead_voice_over = null
var overhead_trigger_count:int = 0

signal dialogWindow

export (Vector2) var scale_of_interactable_box = Vector2(1,1)

 
func _ready():
	self.texture = spriteToLoad
	change_collision_and_mask($Area2D,floor_placement+9,true)
	set_hitboxes_state(hitboxes_enabled)
	$Area2D/CollisionShape2D.scale = scale_of_interactable_box

func _process(_delta):
	if Engine.editor_hint:
		$Area2D/CollisionShape2D.scale = scale_of_interactable_box

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
