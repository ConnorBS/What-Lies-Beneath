extends CanvasLayer

onready var _tween_node = $Tween
onready var _screen_node = $ColorRect

var dead = false

func tween_in():
	_screen_node.show()
	_tween_node.interpolate_property(_screen_node,"modulate",Color(1,1,1,0),Color(1,1,1,1),2.0)
	_tween_node.start()

func show():
	tween_in()

func _on_Tween_tween_completed(object, key):
	dead = true
	$AnimationPlayer.play("pulse text")
	
func _process(_delta):
	if dead:
		if did_a_key_get_pressed():
			get_tree().reload_current_scene()

func did_a_key_get_pressed():
	for i in InputMap.get_actions():
		if Input.is_action_just_pressed(i):
			return true
	return false
