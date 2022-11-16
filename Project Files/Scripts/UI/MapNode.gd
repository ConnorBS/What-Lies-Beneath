extends Control
tool

export (String) var map_name
export (Texture) var border_image
export (Texture) var backing_image

var  _animating_node = false
var _highlight_colour = Color.dimgray
var _animation_time = 1.2
var _fully_completed_colour = Color.darkgreen

var _completed_map_node = false

onready var _timer_animation_node = $Tween/Timer
func _ready():
	load_images(border_image,backing_image)
	pass

func load_window():
	reset_map()
	if PlayerState.has_location_been_visited(map_name):
		display_map()
		if PlayerState.check_all_item_pickups_in_level(map_name) == true:
			fully_completed_map()
		if PlayerState.get_current_level() == map_name:
			current_map(true)
	elif PlayerInventory.has_map(map_name):
		unexplored_map()
	else:
		hide_map()

func fully_completed_map():
#	self.modulate = _fully_completed_colour
	_completed_map_node = true
	_highlight_colour = Color.gray
	$MapBacking.self_modulate = _highlight_colour
	$MapBacking.modulate = _fully_completed_colour

func display_map():
	self.show()
	$MapBacking.modulate = Color.white
	$MapBacking.self_modulate = Color.black
	$MapBorder.self_modulate = Color.white

func unexplored_map():
	self.show()
	$MapBacking.modulate = Color.white
	$MapBacking.self_modulate = Color.red
	self.modulate = Color.webgray

func reset_map():
	$Tween/Timer.stop()
	$Tween.stop_all()
	$MapBorder.self_modulate = Color.white
	$MapBacking.self_modulate = Color.white
	$MapBacking.modulate = Color.white
	self.modulate = Color.white
	hide_map()

func hide_map():
	self.hide()

func current_map(state):
	_animating_node = state
	if _animating_node == true:
		_highlight_item()
	pass

func _highlight_item():
	$Tween.interpolate_property($MapBacking,"self_modulate",$MapBacking.self_modulate,_highlight_colour,_animation_time)
	$Tween.start()

func _remove_highlight_item():
	$Tween.interpolate_property($MapBacking,"self_modulate",$MapBacking.self_modulate,Color.black,_animation_time)
	$Tween.start()
	

func load_images(border_image_to_load,backing_image_to_load)->void:
	$MapBorder.texture = border_image_to_load
	$MapBacking.texture = backing_image_to_load

func _process(_delta):
	if Engine.editor_hint:
		load_images(border_image,backing_image)
#		troubleshooting()


#func _on_Tween_tween_completed(_object, _key):
#	if _animating_node:
#		if $MapBacking.self_modulate == _highlight_colour:
#			_timer_animation_node.start()
#		else:
#			_highlight_item()
#	else:
#		_remove_highlight_item()
#	pass # Replace with function body.


func _on_Timer_timeout():
	_remove_highlight_item()
	pass # Replace with function body.


func _on_Tween_tween_all_completed():
	if _animating_node:
		if $MapBacking.self_modulate == _highlight_colour:
			_timer_animation_node.start()
		else:
			_highlight_item()
	else:
		_remove_highlight_item()
	pass # Replace with function body.
	pass # Replace with function body.
