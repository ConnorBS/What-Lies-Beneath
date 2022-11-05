extends Control
#tool

export (String) var map_name
export (Texture) var border_image
export (Texture) var backing_image

var  _animating_node = false
var _highlight_colour = Color.dimgray
var _animation_time = 1.2



func _ready():
	load_images(border_image,backing_image)
	pass

func load_window():
	if PlayerState.has_location_been_visited(map_name):
		display_map()
		if PlayerState.get_current_level() == map_name:
			current_map(true)
		else:
			current_map(false)
	elif PlayerInventory.has_map(map_name):
		unexplored_map()
	else:
		hide_map()
	
func display_map():
	self.show()
	$MapBacking.self_modulate = Color.black
	$MapBorder.self_modulate = Color.white
	
func unexplored_map():
	self.show()
	$MapBacking.self_modulate = Color.darkred
	$MapBorder.self_modulate = Color.webgray

func hide_map():
	self.hide()

func current_map(state):
	_animating_node = state
	if _animating_node == true:
		_highlight_item()
	else:
		$Tween.stop_all()
		$MapBacking.self_modulate = Color.black
		$MapBorder.self_modulate = Color.white
		
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

func _process(delta):
	if Engine.editor_hint:
		load_images(border_image,backing_image)
		display_map()


func _on_Tween_tween_completed(object, key):
	if _animating_node:
		if $MapBacking.self_modulate == _highlight_colour:
			_remove_highlight_item()
		else:
			_highlight_item()
	else:
		_remove_highlight_item()
	pass # Replace with function body.
