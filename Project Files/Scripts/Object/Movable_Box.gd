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
# Called when the node enters the scene tree for the first time.
func _ready():
	update_floor(floor_placement)
	pass # Replace with function body.


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


func _process(delta):
	if player_grabbed and PlayerState.get_Player_Active():
		##############################################
		#############Movement Logic###################
		##############################################
		
		var velocity = Vector2.ZERO
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		move_and_slide(velocity * push_box_speed)

func player_latched (state)->Vector2:
	player_grabbed = state
	return snap_position()
	
func snap_position()->Vector2:
	if player_location == LEFT:
		return $LeftSidePlayerSnap.global_position
	elif player_location == RIGHT:
		return $RightSidePlayerSnap.global_position
	printerr("Called without Player Detected")
	return Vector2.ZERO


func _on_LeftInteraction_area_entered(area):
	if area.is_in_group("Player"):
		player_location = LEFT
		print ("LEFT")
	pass # Replace with function body.


func _on_LeftInteraction_area_exited(area):
	if area.is_in_group("Player"):
		player_location = NONE
	pass # Replace with function body.


func _on_RightInteraction_area_entered(area):
	if area.is_in_group("Player"):
		player_location = RIGHT
		print ("Right")
	pass # Replace with function body.


func _on_RightInteraction_area_exited(area):
	if area.is_in_group("Player"):
		player_location = NONE
	pass # Replace with function body.
