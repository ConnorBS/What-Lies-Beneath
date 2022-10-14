extends Camera2D

onready var level_node = get_parent().get_parent().get_parent().get_parent()
onready var player_node = get_parent()

var min_pos = Vector2.ZERO
var max_pos = Vector2.ZERO
onready var old_pos = position
onready var camera_length_to_border = get_viewport().size/2*self.zoom

var _viewportMargins
var _viewportNode 

export (Vector2) var camera_swing_max = Vector2(100,100)
var camera_swing = Vector2.ZERO
var base_zoom:Vector2
export (float) var zoom_intensity_on_pause = 0.7
var zoom_flag = false
var buff

func _ready():
#	print (get_viewport())
#	print (get_viewport().size)
#	print (get_viewport().size/2*self.zoom)
	base_zoom = zoom
	max_pos = Vector2(level_node.level_width,level_node.level_height)
	_viewportNode = _find_viewportNode()
	if _viewportNode != null:
		_viewportMargins = Vector2(_viewportNode.get_parent().margin_right,_viewportNode.get_parent().margin_bottom)
#	print (_viewportNode)
#	print (_viewportMargins)
	pass

func _find_border_length()->Vector2:
	return get_viewport().size/2*self.zoom
	
func update_against_boundaries(length_to_border = camera_length_to_border)->void:
	
	if global_position.x - length_to_border.x   < min_pos.x + offset.x:
		global_position.x = min_pos.x + length_to_border.x + offset.x
	elif global_position.x + length_to_border.x > max_pos.x  + offset.x:
		global_position.x = max_pos.x - length_to_border.x + offset.x
	
	if global_position.y - length_to_border.y < min_pos.y - offset.y :
		global_position.y = min_pos.y + length_to_border.y - offset.y
	elif global_position.y + length_to_border.y  > max_pos.y - offset.y:
		global_position.y = max_pos.y - length_to_border.y - offset.y

func dynamic_Camera(new_pos)->Vector2:
	###Right
	var change = Vector2.ZERO
	if old_pos.x - new_pos.x < 0:
		change.x += 1
	###Left
	elif old_pos.x - new_pos.x > 0:
		change.x += -1
	
	###Up
	if old_pos.y - new_pos.y < 0:
		change.y += -1
	###Down
	elif old_pos.y - new_pos.y > 0:
		change.y += 1
	
	return change
	
func update_camera(direction):
	if direction == Vector2.ZERO:
		cameraSnap()
	else:
		if camera_swing.x < camera_swing_max.x and camera_swing.x > -camera_swing_max.x:
			camera_swing.x += direction.x;
		if camera_swing.y<camera_swing_max.y and camera_swing.y > -camera_swing_max.y:
			camera_swing.y += direction.y;
		if camera_swing .x > camera_swing_max.x:
			camera_swing.x = camera_swing_max.x
		elif camera_swing.x < -camera_swing_max.x:
			camera_swing.x = -camera_swing_max.x
		if camera_swing .y > camera_swing_max.y:
			camera_swing.y = camera_swing_max.y
		elif camera_swing.y < -camera_swing_max.y:
			camera_swing.y = -camera_swing_max.y
	position = camera_swing/2
	
func cameraSnap():
	camera_swing = camera_swing/1.01
	if camera_swing < Vector2(5,5) and camera_swing > -Vector2(5,5):
		camera_swing = Vector2.ZERO
		
func update_zoom():
	if _viewportNode != null:
#		print (Vector2(_viewportNode.get_parent().margin_right,_viewportNode.get_parent().margin_bottom)==_viewportMargins)
		if (_viewportNode.anchor_right == 1.0 and _viewportNode.anchor_bottom == 1.0) and Vector2(_viewportNode.get_parent().margin_right,_viewportNode.get_parent().margin_bottom) ==_viewportMargins:
			zoom_flag = false
		else:
			camera_swing = Vector2.ZERO
			center()
			zoom_flag = true
			
			if  (_viewportNode.anchor_right == 1.0 and _viewportNode.anchor_bottom == 1.0):
				zoom.x = base_zoom.y-(1-_viewportNode.get_parent().margin_right/_viewportMargins.x)*base_zoom.x * zoom_intensity_on_pause
				zoom.y = base_zoom.y-(1-_viewportNode.get_parent().margin_bottom/_viewportMargins.y)*base_zoom.y * zoom_intensity_on_pause
			else:
				zoom.x = base_zoom.y-(1-_viewportNode.anchor_right)*base_zoom.x * zoom_intensity_on_pause
				zoom.y = base_zoom.y-(1-_viewportNode.anchor_bottom)*base_zoom.y * zoom_intensity_on_pause
			
func _find_viewportNode()->Viewport:
	var node = get_parent()
#	print ( !(node == ViewportContainer)," and ", node != null)
	while !(node is Viewport) and node != null:
		node = node.get_parent()
#		print ( !(node == ViewportContainer)," and ", node != null)
	if (node.name == "root"):
		return null
	else:
		return node.get_parent()
func center():
	update_camera(self.get_camera_screen_center().direction_to(player_node.position))
	update_against_boundaries(_find_border_length())
	pass
func _process(_delta):
	update_camera(dynamic_Camera(player_node.position))
	update_against_boundaries()
	update_zoom()
	old_pos = player_node.position
	pass
