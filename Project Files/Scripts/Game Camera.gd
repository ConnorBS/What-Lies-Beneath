extends Camera2D

onready var level_node = get_parent().get_parent().get_parent().get_parent()
onready var player_node = get_parent()

var min_pos = Vector2.ZERO
var max_pos = Vector2.ZERO
onready var old_pos = position
onready var camera_length_to_border = get_viewport().size/2*self.zoom

export (Vector2) var camera_swing_max = Vector2(100,100)
var camera_swing = Vector2.ZERO


var buff

func _ready():
	max_pos = Vector2(level_node.level_width,level_node.level_height)
	pass

	
func update_against_boundaries()->void:
	if global_position.x - camera_length_to_border.x < min_pos.x:
		global_position.x = min_pos.x + camera_length_to_border.x
	elif global_position.x + camera_length_to_border.x > max_pos.x:
		global_position.x = max_pos.x - camera_length_to_border.x
	
	if global_position.y - camera_length_to_border.y < min_pos.y:
		global_position.y = min_pos.y + camera_length_to_border.y
	elif global_position.y + camera_length_to_border.y > max_pos.y:
		global_position.y = max_pos.y - camera_length_to_border.y

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

func _process(_delta):
	update_camera(dynamic_Camera(player_node.position))
	update_against_boundaries()
	old_pos = player_node.position
	pass
