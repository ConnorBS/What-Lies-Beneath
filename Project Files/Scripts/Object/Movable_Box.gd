extends KinematicBody2D

export (int) var floor_placement = 1
export (int) var top_floor = 2
export (int) var push_box_speed = 40

enum {NONE,LEFT,RIGHT}
onready var player_location = NONE

onready var ground_shape = $GroundShape
onready var right_interaction = $RightInteraction
onready var left_interaction = $LeftInteraction

var player_grabbed = false
var moving = false


func _ready():
	update_floor(floor_placement)
	load_pickup_state()

func update_collision_layer_and_mask(node,floor_to_adjust,state):
	node.set_collision_layer_bit(floor_to_adjust,state)
	node.set_collision_mask_bit(floor_to_adjust,state)
	
func update_floor(floor_number):
	self.set_collision_layer_bit(0,false)
	self.set_collision_mask_bit(0,false)
	self.set_collision_layer_bit(floor_number-1,true)
	self.set_collision_mask_bit(floor_number-1,true)
	
	### Interactions
	right_interaction.set_collision_layer_bit(9,false)
	right_interaction.set_collision_mask_bit(9,false)
	right_interaction.set_collision_layer_bit(9+floor_number,true)
	right_interaction.set_collision_mask_bit(9+floor_number,true)
	
	
	left_interaction.set_collision_layer_bit(9,false)
	left_interaction.set_collision_mask_bit(9,false)
	left_interaction.set_collision_layer_bit(9+floor_number,true)
	left_interaction.set_collision_mask_bit(9+floor_number,true)


func _process(_delta):
	if player_grabbed and PlayerState.get_Player_Active():
		##############################################
		#############Movement Logic###################
		##############################################
		
		var velocity = Vector2.ZERO
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		var _velocity = move_and_slide(velocity * push_box_speed)
		

func player_latched (state)->Vector2:
	player_grabbed = state
	save_pickup_state()
	return snap_position()
	
func snap_position()->Vector2:
	if player_location == LEFT:
		return $LeftSidePlayerSnap.global_position
	elif player_location == RIGHT:
		return $RightSidePlayerSnap.global_position
	printerr("snap_position: Called without Player Detected")
	return Vector2.ZERO


func _on_LeftInteraction_area_entered(area):
	if area.is_in_group("Player"):
		player_location = LEFT
#		print ("LEFT")


func _on_LeftInteraction_area_exited(area):
	if area.is_in_group("Player"):
		player_location = NONE


func _on_RightInteraction_area_entered(area):
	if area.is_in_group("Player"):
		player_location = RIGHT
#		print ("Right")


func _on_RightInteraction_area_exited(area):
	if area.is_in_group("Player"):
		player_location = NONE

func player_climb():
	if player_location == LEFT:
		player_grabbed = false
		return [$LeftSidePlayerSnap/LeftClimbPos1.global_position,$LeftSidePlayerSnap/LeftClimbPos2.global_position]
	if player_location == RIGHT:
		player_grabbed = false
		return [$RightSidePlayerSnap/RightClimbPos1.global_position,$RightSidePlayerSnap/RightClimbPos2.global_position]
	return []
	
func stand_on_box(is_on_box:bool):
	if is_on_box:
		update_collision_layer_and_mask($UpperBoxFloor,top_floor-1,true)
		update_collision_layer_and_mask($LeftFallDown,top_floor+9,true)
		update_collision_layer_and_mask($RightFallDown,top_floor+9,true)
		
	pass
	
func has_overhead_text():
	return false
	
func load_pickup_state():
	if self.name != "":
		var load_data = _find_level_node().load_pickup_state_of_object_in_level(get_parent().get_parent().name+"_"+self.name)
		if !load_data.empty():
			self.position.y = load_data["position.y"]
			self.position.x = load_data["position.x"]
			
		else: ### If it's not in the save file, it should be, so adds current state into memory
			save_pickup_state()

func save_pickup_state():
	if self.name != "":
		var save_data = {
			"position.y":self.position.y,
			"position.x":self.position.x,
			}
		_find_level_node().save_pickup_state_of_object_in_level(get_parent().get_parent().name+"_"+self.name,save_data)


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
