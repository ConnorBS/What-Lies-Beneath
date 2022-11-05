extends MenuClass

onready var _map_manager = $MarginContainer/VBoxContainer/ViewportContainer/Viewport/MapManager
###############################################
###########  Button Presses  ##################
###############################################

func _on_BottomButtonMargin_Back():
#	print ("Map")
	emit_signal("Back")


func _on_BottomButtonMargin_Cancel():
	pass # Replace with function body.

func _process(_delta):
	$ButtonCanvas.offset.x = self.offset.x
	
func load_window():
	load_all_maps()

func load_all_maps():
	for map_node in _map_manager.get_children():
		map_node.load_window()



########################################################
##############    Camera Controls   ####################
########################################################
onready var _camera_node = $MarginContainer/VBoxContainer/ViewportContainer/Viewport/Camera2D

var mouse_start_pos
var screen_start_position

var dragging = false
var velocity = Vector2.ZERO
var max_zoom = Vector2(.4,.4)
var min_zoom = Vector2(1.5,1.5)
var zoom_modifier = Vector2(0.1,0.1)

func _input(event):
	if event.is_action("drag"):
		if event.is_pressed():
			mouse_start_pos = event.position
			screen_start_position = _camera_node.position
			dragging = true
		else:
			dragging = false
			
	elif event is InputEventMouseMotion and dragging:
		_camera_node.position = _camera_node.zoom * (mouse_start_pos - event.position) + screen_start_position

	if event.is_action("zoom_in"):
		_camera_node.zoom -= zoom_modifier
		if _camera_node.zoom <= max_zoom:
			_camera_node.zoom = max_zoom
	elif event.is_action("zoom_out"):
		_camera_node.zoom += zoom_modifier
		if _camera_node.zoom >= min_zoom:
			_camera_node.zoom = min_zoom

