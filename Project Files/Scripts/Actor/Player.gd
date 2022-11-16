extends KinematicBody2D

onready var level_manager = get_parent().get_parent().get_parent()
onready var state_machine = $AnimationTree.get("parameters/playback")
onready var interact_pop_up_message = $InteractPopUp
onready var bullet_ray = $Bullet
onready var target_mouse_reticle = preload("res://Assets/UI/Mouse Cursors/Target.png")

onready var stamina = $Stamina
var has_stamina = true
export (int) var run_speed = 160
export (int) var walk_speed = 80
export (int) var fall_speed = 160
var push_box_speed = 40

enum BOX_SIDE {NONE,LEFT,RIGHT}
###############################
#########Player States#########
###############################
var sprint_state = false
var gun_out_state = false
var interact_state = false
var aim_state = false
var push_box_state = false
var climb_box_state = false
var side_of_box = BOX_SIDE.NONE
var infront_of_interactable_object = false
var _interact_object
var falling = false
var flipped = false
var dialog_state = false
###############################

var previous_animation:String = ""


export (int) var current_floor = 1
#########################
########Climbing#########
#########################
export (int) var climb_speed = 30
var climbing = false
var climbing_reached_top = false
var climbing_reached_bottom = false

#########################
#########Boxes###########
#########################
var climb_box_positions:Array

#########################
#########Falling#########
#########################
var falling_start_position = Vector2.ZERO
var falling_end_position = Vector2.ZERO
var falling_vector = Vector2.ZERO

var action_set_player_active_as_false = false

var gun_selected = PlayerInventory.equipped_gun
var interactable_object = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationTree.active = true
	level_manager.enable_floor(current_floor)
	pass 

func check_equipped_gun() -> int:
	gun_selected = PlayerInventory.equipped_gun
	return gun_selected
	
func change_animation(animationToChangeTo:String)->void:
	if state_machine.get_current_node() != animationToChangeTo:
		state_machine.travel(animationToChangeTo)
		#print (animationToChangeTo)
		if animationToChangeTo == "Idle":
			
				pass
func change_mouse(mouse_cursor)->void:
	if mouse_cursor == null:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW,Vector2.ZERO)
	elif mouse_cursor == target_mouse_reticle:
		Input.set_custom_mouse_cursor(mouse_cursor,Input.CURSOR_ARROW,Vector2(10,10))
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
func check_if_current_animation_allows_movement() -> bool:
	var animation_playing = state_machine.get_current_node()
	if animation_playing == "Kneeling_Down":
		return false
	elif animation_playing == "Kneeling_Up":
		return false
	elif animation_playing == "Pulling_Out_Pistol":
		return false
	elif animation_playing == "Putting_In_Pistol":
		return false
	elif animation_playing == "Raising_Pistol":
		return false
	elif animation_playing == "Lowering_Pistol":
		return false
	elif animation_playing == "Climbing_Up_Box":
		return false
		
	#######CLimbing#######
	elif check_if_current_animation_transition_climbing():
		return false
		
	#####Boxes#####
	elif check_if_current_animation_transition_pushing():
		return false
	#####Falling#####
	elif check_if_current_animation_is_falling():
		return false
	else:
		return true
func check_if_current_animation_transition_climbing()->bool:
	
	var animation_playing = state_machine.get_current_node()
	if animation_playing == "Standing_To_Climbing_Up":
		return true
	elif animation_playing == "Standing_To_Climbing_Down":
		return true
	elif animation_playing == "Climbing_Up_To_Standing":
		return true
	elif animation_playing == "Climbing_Down_To_Standing":
		return true
	return false

func check_if_current_animation_transition_pushing()->bool:
	
	var animation_playing = state_machine.get_current_node()
	if animation_playing == "Standing_To_Pushing":
		return true
	elif animation_playing == "Pushing_To_Standing":
		return true
	elif animation_playing == "Climbing_Down_Box":
		return true
	elif animation_playing == "Climbing_Up_Box":
		return true
	return false
	
func check_if_current_climbing_animation()->bool:
	var animation_playing = state_machine.get_current_node()
	if animation_playing == "Climbing_Up":
		return true
	elif animation_playing == "Climbing_Down":
		return true
	elif animation_playing == "Climbing_Idle":
		return true
	return false
func check_if_current_animation_is_falling()->bool:
	var animation_playing = state_machine.get_current_node()
	if animation_playing == "Standing_To_Falling":
		return true
	elif animation_playing == "Falling":
		return true
	elif animation_playing == "Landing":
		return true
	return false

func update_previous_animation():
	if state_machine.get_current_node() != previous_animation:
		previous_animation = state_machine.get_current_node()
func check_if_animation_has_changed()->bool:
	if state_machine.get_current_node() != previous_animation:
		return true
	return false
func enable_ground_checker(prev_animation):
	if prev_animation == "Climbing_Up_To_Standing" or prev_animation == "Climbing_Down_To_Standing":
		change_collision_and_mask(self,current_floor-1,true)
	if prev_animation == "Climbing_Up_Box":
		climb_box_state = false
		push_box_state = false
		change_collision_and_mask(self,current_floor-1,true)
	

	
func _process(_delta):
	###############################################
	#########Logic After Animation Change##########
	###############################################
	if check_if_animation_has_changed():
		
		enable_ground_checker(previous_animation)
		$CenterContainer/animationPlaceholder.hide()
		$CenterContainer/animationPlaceholder.text = "Animation\nPlace Holder\n"
	if state_machine.get_current_node() == "Climbing_Up_Box":
		change_animation("Idle")
	###############################################
	################ Falling Logic#################
	###############################################

	if falling:
		PlayerState.set_Player_Active(false)
		action_set_player_active_as_false = true
		if global_position.y > falling_end_position.y:
			landing()
		else:
			var _velocity = move_and_slide(falling_vector)
	###############################################
	#####Input Check if Animation allows it########
	###############################################
	elif check_if_current_animation_allows_movement() == true and !climb_box_state:
		if action_set_player_active_as_false:
			PlayerState.set_Player_Active(true)
			action_set_player_active_as_false = false
		var vector = _get_input()
		if vector != Vector2.ZERO:
			var _velocity = move_and_slide(vector)
	elif !climb_box_positions.empty():
		var _velocity = move_and_slide(climb_box(climb_box_positions))
		if climb_box_positions.empty():
			stand_on_box()
	######################################
	####Moves Sprite while Climbing#######
	######################################
	elif check_if_current_animation_transition_climbing():
		var vector = snap_to_ladder(interactable_object)
		vector.y = move_sprite_while_climbing().y
		var _velocity = move_and_slide(vector)
		
	else:
		PlayerState.set_Player_Active(false)
		action_set_player_active_as_false = true
		
#	if interact_state == true:
#		if Input.any_ke
#			change_animation("Idle")
#			interact_state = false
	######################################
	###########Aiming Gun#################
	######################################
	if aim_state:
		aiming_gun()
	######################################
	update_previous_animation()
func _draw():
	if aim_state:
		###Removed Laser Pointer Visual
		aiming_gun()



### Checking to break Interact State ("Kneeling_Down")
func _input(event):
	if interact_state == true:
		if ((event is InputEventKey) or (event is InputEventJoypadButton)) and event.pressed:
			change_animation("Idle")
			interact_state = false
	

func _get_input()->Vector2:
	var velocity = Vector2.ZERO
	if !PlayerState.get_Player_Active():
		return velocity
	##############################################
	##############GUN Logic#######################
	##############################################
	if Input.is_action_just_pressed("use_weapon"):
		#state_machine.travel(attacks[randi() % 2])
		return velocity
	if gun_out_state:
		if aim_state:
			if Input.is_action_just_released("aim"):
				change_animation("Idle_Pistol")
				aim_state = false
				change_mouse(null)
				clear_aiming()
				return velocity
			else:
				return velocity
		elif Input.is_action_just_pressed("aim"):
			change_animation("Aiming_Pistol")
			change_mouse(target_mouse_reticle)
			aim_state = true
	#############################################
	##############Interactions###################
	#############################################
	if infront_of_interactable_object:
		if Input.is_action_just_pressed("interact"):
			gun_out_state =false
			###############################
			##########Climbing#############
			###############################
			if interactable_object.is_in_group("Ladder"):
				if climbing:
					climbing_state (false)
				else:
					climbing_state (true)
				return velocity
			##############################
			######Interactable Object#####
			##############################
			if interactable_object.is_in_group("Box"):
				if push_box_state:
					return push_box(false,interactable_object)
				else:
					return push_box(true,interactable_object)
			elif interact_state:
				change_animation("Kneeling_Up")
				$AnimationTree.pause_mode = Node.PAUSE_MODE_INHERIT
				interact_state = false
				return velocity
			else:
#				change_animation("Kneeling_Down")
				$AnimationTree.pause_mode = Node.PAUSE_MODE_PROCESS
				if interactable_object.get_parent().is_there_a_scene_change():
					interactable_object.get_parent().change_scene_level()
					change_animation("Idle")
					return velocity
				else:
					change_animation("Kneeling_Down")
				interactable_object.get_parent().trigger_dialog()
				PlayerState.set_Player_Active(false)
				_on_InteractableHitBox_area_exited(interactable_object)
				dialog_state = true
				####Could hold out from saying interact State to be triggered by dialog/cutscene time
				interact_state = true
				return velocity
	
	##############################################
	#############Pull Out Weapon##################
	##############################################
	if Input.is_action_just_pressed("equip_gun"):
		if gun_out_state:
			if check_equipped_gun() == PlayerInventory.GUNTYPES.PISTOL:
				change_animation("Idle")
				gun_out_state = false
				return velocity
		else:
			if check_equipped_gun() == PlayerInventory.GUNTYPES.PISTOL:
				change_animation("Idle_Pistol")
				gun_out_state = true
				return velocity

	##############################################
	###############Sprint Logic###################
	##############################################
	if Input.is_action_just_pressed("toggle_sprint"):
		sprint_state = !sprint_state
	if Input.is_action_pressed("sprint"):
		sprint_state = true
	elif Input.is_action_just_released("sprint"):
		sprint_state = false
	
	##############################################
	#############Movement Logic###################
	##############################################
	if Input.is_action_pressed("move_right") and !climbing:
		velocity.x += 1
		if !push_box_state:
			flip_sprite(false)
	if Input.is_action_pressed("move_left") and !climbing:
		velocity.x -= 1
		if !push_box_state:
			flip_sprite(true)
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		#####Climbs Box####
		if push_box_state:
			trigger_climb_on_box()
			
			return climb_box(interactable_object.get_parent().player_climb())
	if Input.is_action_pressed("move_down") and !push_box_state:
		velocity.y += 1
		
	##############################################
	###################Climbing ##################
	##############################################
	if climbing:
		if check_if_current_climbing_animation() == true:
			if velocity.y < 0 :
				change_animation("Climbing_Up")
			elif velocity.y > 0 :
				change_animation("Climbing_Down")
			else:
				change_animation("Climbing_Idle")
		return velocity * climb_speed
	
	##############################################
	################## Pushing ###################
	##############################################
	elif push_box_state:		
		if velocity.x < 0 :
			if flipped:
				change_animation("Pushing_Box")
			else:
				change_animation("Pulling_Box")
		elif velocity.x > 0 :
			if flipped:
				change_animation("Pulling_Box")
			else:
				change_animation("Pushing_Box")
		else:
			change_animation("Pushing_Idle")
		return (velocity * push_box_speed) + snap_to_box(interactable_object.get_parent().snap_position())
		
	else:
		if (sprint_state == true) and (gun_out_state == false) and has_stamina:
			velocity = velocity.normalized() * run_speed
			if velocity.length() != 0:
				stamina.use()
				change_animation("Running")
		else:
			velocity = velocity.normalized() * walk_speed
			if velocity.length() != 0:
				if gun_out_state:
					if check_equipped_gun() == PlayerInventory.GUNTYPES.PISTOL:
						change_animation("Walk_With_Pistol")
				else:
					change_animation("Walking")
		
		if velocity.length() == 0:
			if gun_out_state:
				if check_equipped_gun() == PlayerInventory.GUNTYPES.PISTOL:
					change_animation("Idle_Pistol")
			elif interact_state == false:
				change_animation("Idle")
	return velocity

func flip_sprite(state:bool)->void:
	if flipped != state:
		flipped = state
		if flipped:
			$Sprite.scale.x = -1
		else:
			$Sprite.scale.x = 1

func laser_pointer_to_mouse(target):
	if state_machine.get_current_node() == "Aiming_Pistol":
		draw_line(bullet_ray.position, target, Color(255, 0, 0), 1)
	


func clear_aiming()->void:
	bullet_ray.enabled = false

func aiming_gun(max_slope = .5/1)->void:
	bullet_ray.enabled = true
	var target= get_local_mouse_position()
	var direction_to_target 
	var distance_to_travel = 2000
	var gun_position = bullet_ray.position
	###################################################
	##########Set origin position of gun###############
	###################################################
	if flipped:
		if bullet_ray.position.x > 0:
			bullet_ray.position.x = -bullet_ray.position.x
			gun_position.x = bullet_ray.position.x
	else:
		if bullet_ray.position.x < 0:
			bullet_ray.position.x = -bullet_ray.position.x
			gun_position.x = bullet_ray.position.x
			
	####################################################
	##############Avoid division by zero################
	####################################################
	if flipped:
		
		if target.x - gun_position.x == 0:
			direction_to_target = Vector2(-1,0)
		else:
			direction_to_target = gun_position.direction_to(target)
	else:
		if gun_position.x - target.x == 0:
			direction_to_target = Vector2(1,0)
		else:
			direction_to_target = gun_position.direction_to(target)
	
	##############################################################
	##########Limit range of gun##################################
	##############################################################
	
	if direction_to_target.y > max_slope:
		direction_to_target.y = max_slope
		direction_to_target.x = sqrt(1-pow(direction_to_target.y,2))
		if flipped:
			direction_to_target.x = -direction_to_target.x

	elif direction_to_target.y < -max_slope:
		direction_to_target.y = -max_slope
		direction_to_target.x = sqrt(1-pow(-direction_to_target.y,2))
		if flipped:
			direction_to_target.x = -direction_to_target.x
	
	if flipped:
		if direction_to_target.x > 0:
			direction_to_target.x = -direction_to_target.x 
			
	else:
		if direction_to_target.x < 0:
			direction_to_target.x = -direction_to_target.x 
			
	##############################################################
	##########Set Mouse in Bounds#################################
	##############################################################

	var max_x = 2000
	if flipped:
		max_x = -max_x
		clamp_mouse_to_aim(gun_position,-max_slope,max_x,gun_position.x)
	else:
		
		clamp_mouse_to_aim(gun_position,max_slope,gun_position.x,max_x)

	##############################################################
	#####Set Offical Target, and update RayCast to hit Target#####
	##############################################################
	target = gun_position+(distance_to_travel*direction_to_target)
	bullet_ray.cast_to = target-gun_position
	
	###############################################################
	#If target collides with something, set target to intersection#
	###############################################################
	if bullet_ray.is_colliding():
		target = self.to_local(bullet_ray.get_collision_point())



func clamp_mouse_to_aim(starting_point:Vector2,slope:float,min_x:float,max_x:float):
	var mouse_pos = get_local_mouse_position()
	var new_mouse_pos = Vector2.ZERO
	new_mouse_pos.x = clamp(mouse_pos.x,min_x,max_x)
	## Using the formula y = mx + b
	var min_y = -slope*(new_mouse_pos.x-starting_point.x)+starting_point.y
	var max_y = slope*(new_mouse_pos.x-starting_point.x)+starting_point.y
	new_mouse_pos.y = clamp(mouse_pos.y,min_y,max_y)
	Input.warp_mouse_position(get_viewport().canvas_transform.xform(to_global(new_mouse_pos)))
	
	
func update_interaction(in_range:bool,area)->void:
	infront_of_interactable_object = in_range
	interactable_object = area
	if in_range:
		interact_pop_up_message.show()
	else:
		interact_pop_up_message.hide()


func _on_InteractableHitBox_area_entered(area):
	if area.is_in_group("Interact"):
		if !climbing and !climb_box_state and !dialog_state:
			update_interaction(true,area)
			if area.is_in_group("Box:Left"):
				side_of_box = BOX_SIDE.LEFT
			elif area.is_in_group("Box:Right"):
				side_of_box = BOX_SIDE.RIGHT
		check_for_dialog(area.get_parent())
	
	if area.is_in_group("Fall"):
		falling_trigger(area,true)


func _on_InteractableHitBox_area_exited(area):
	if area.is_in_group("Interact"):
		if interactable_object == area and !climbing and !climb_box_state:
			update_interaction(false,null)
			
			if area.is_in_group("Box"):
				side_of_box = BOX_SIDE.NONE


func _on_ClimbingHitBoxTop_area_entered(area):
	if area.is_in_group("Ladder"):
		if climbing and check_if_current_climbing_animation() == true and !climb_box_state:
			climbing_reached_top = true
			climbing_trigger(area.get_parent().up_floor)


func _on_ClimbingHitBoxTop_area_exited(area):
	if area.is_in_group("Ladder"):
		climbing_reached_top = false


func _on_ClimbingHitBoxBottom_area_entered(area):
	if area.is_in_group("Ladder"):
		if climbing and check_if_current_climbing_animation() == true and !climb_box_state:
			climbing_reached_bottom = true
			climbing_trigger(area.get_parent().down_floor)

func climbing_state(state):
	climbing = state
	if climbing:
		if interactable_object.is_in_group("Ladder_Bottom"):
			change_animation("Climbing_Up")
		elif interactable_object.is_in_group("Ladder_Top"):
			change_animation("Climbing_Down")
		$ClimbingInterations/ClimbingHitBoxBottom.monitoring = true
		$ClimbingInterations/ClimbingHitBoxTop.monitoring = true
		$InteractableHitBox.monitoring = false
		change_collision_and_mask(self,current_floor-1,false)
		level_manager.move_to_floor(interactable_object.get_parent().floor_placement,self)
	else:
		$ClimbingInterations/ClimbingHitBoxBottom.set_deferred("monitoring", false)
		$ClimbingInterations/ClimbingHitBoxTop.set_deferred("monitoring", false)
		$InteractableHitBox.monitoring = true
		update_interaction(false,null)
		
func _on_ClimbingHitBoxBottom_area_exited(_area):
	if climbing:
		climbing_reached_bottom = false

func climbing_trigger(new_level):
		change_animation("Idle")
		climbing_reached_bottom = false
		climbing_reached_top = false
		move_a_floor(new_level)
		climbing_state(false)
		current_floor = new_level

func snap_to_ladder(ladder_area2d):
	var vector = Vector2.ZERO
	if ladder_area2d != null:
		var global_ladder_position = ladder_area2d.get_parent().global_position
		vector.x = global_ladder_position.x-self.global_position.x
		##################################
		#####Adjust for Sprite Width######
		##################################
		if global_position.x> global_ladder_position.x:
			if flipped:
				vector.x -= 10
			else:
				vector.x -= 15
		else:
			if flipped:
				vector.x += 15
			else:
				vector.x += 10
	return vector

func move_sprite_while_climbing():
	var vector = Vector2.ZERO
	var animation_playing = state_machine.get_current_node()
	if animation_playing == "Standing_To_Climbing_Up":
		vector = Vector2(0,-1) * (climb_speed *1)
	elif animation_playing == "Standing_To_Climbing_Down":
		vector = Vector2(0,1) * climb_speed * 2.5
	elif animation_playing == "Climbing_Up_To_Standing":
		vector = Vector2.UP * climb_speed * 2.75
	elif animation_playing == "Climbing_Down_To_Standing":
		vector = Vector2.DOWN
	return vector

func move_a_floor(new_floor):
	change_collision_and_mask(self,current_floor-1,false)
	change_collision_and_mask($InteractableHitBox,current_floor+9,false)
	change_collision_and_mask($InteractableHitBox,new_floor+9,true)
	
	level_manager.move_to_floor(new_floor,self)
	pass
	
func update_floor_collision(new_floor):
	change_collision_and_mask(self,current_floor-1,false)
	change_collision_and_mask(self,new_floor-1,true)
	change_collision_and_mask($InteractableHitBox,current_floor+9,false)
	change_collision_and_mask($InteractableHitBox,new_floor+9,true)
	current_floor = new_floor
	pass
func change_collision_and_mask(node,floor_update,state):
	node.set_collision_layer_bit(floor_update,state)
	node.set_collision_mask_bit(floor_update,state)
	pass
###########################################
################Stamina####################
###########################################
func _on_Stamina_out_of_stamina():
	has_stamina = false


func _on_Stamina_stamina_filled():
	has_stamina = true

###########################################
###############Push Boxes##################
###########################################
func push_box(state:bool,box_area2D:Area2D)->Vector2:
	if push_box_state != state:
		push_box_state = state
		if push_box_state:
			change_animation("Pushing_Idle")
			var box_node = box_area2D.get_parent()
			push_box_speed = box_node.push_box_speed
			if side_of_box == BOX_SIDE.LEFT:
				flip_sprite(false)
			elif side_of_box == BOX_SIDE.RIGHT:
				flip_sprite(true)
			return snap_to_box(box_node.player_latched(push_box_state))

		else:
			change_animation("Idle")
			var box_node = box_area2D.get_parent()
			return snap_to_box(box_node.player_latched(push_box_state))
	return Vector2.ZERO
	
func snap_to_box(snap_pos:Vector2)->Vector2:
	var vector = Vector2.ZERO
	vector.y = snap_pos.y-self.global_position.y
	vector.x = snap_pos.x-self.global_position.x

	return vector * 20


func climb_box(positions:Array) -> Vector2:
	
	climb_box_state = true
	climb_box_positions = positions
	var vector = Vector2.ZERO
	if !positions.empty():
		if (climb_box_positions[0]-global_position).length() <= 10:
			climb_box_positions.remove(0)
		else:
			vector = positions[0] - self.global_position
		
	return vector

func stand_on_box():
	var new_floor = interactable_object.get_parent().top_floor
	move_a_floor(new_floor)
	change_collision_and_mask(self,new_floor-1,true)
	
	current_floor = new_floor
	interactable_object.get_parent().stand_on_box(true)
	climb_box_state = false
	
	_on_InteractableHitBox_area_exited(interactable_object)
	
func trigger_climb_on_box():
	climb_box_state=true
	var new_floor = interactable_object.get_parent().top_floor
	level_manager.move_to_floor(new_floor,self)
	change_animation("Climbing_Up_Box")
	change_collision_and_mask(self,current_floor-1,false)
	
	
###########################################
############### Falling ###################
###########################################

func falling_trigger(area:Area2D,state:bool):
	if falling != state:
		falling = state
		if falling:
			interactable_object = area
			falling_start_position = global_position
			falling_end_position =falling_start_position + Vector2(0,area.fall_distance)
			falling_vector = Vector2(0,area.fall_distance)
			change_animation("Falling")
			move_a_floor(area.down_floor)
			current_floor = area.down_floor
			
func landing():
	falling = false
	change_animation("Idle")
	change_collision_and_mask(self,current_floor-1,true)
	
	
##################################
##########Dialog##################
##################################
var overhead_text:String
var playing_text:bool = false
onready var _overhead_text_node = $OverheadText
onready var _overhead_text_timer_node = $OverheadText/TextDelay
onready var _overhead_text_fade_out_node = $OverheadText/FadeOut
onready var _voice_node = $Voice

func check_for_dialog(interact_object):
	if interact_object.has_overhead_text():
		play_overhead(interact_object.get_overhead_text())
		var audioFile = interact_object.get_overhead_voice_over()
		if audioFile != null:
			_voice_node.stream = audioFile
			_voice_node.play()
	
	
func dialog_closed():
	if state_machine.get_current_node() == "Kneeling_Down":
		change_animation("Idle")
		dialog_state = false
	interact_state = false
		
func play_overhead(new_string:String = overhead_text):
	if overhead_text != new_string and !playing_text:
		overhead_text = new_string
		playing_text = true
	if overhead_text == new_string and playing_text:
		if overhead_text != "" and overhead_text != null:
			_overhead_text_node.text += overhead_text[0]
			overhead_text.erase(0,1)
		if overhead_text != "":
			_overhead_text_timer_node.start()
		else:
			_overhead_text_fade_out_node.interpolate_property(_overhead_text_node,"self_modulate",Color(1,1,1,1.0),Color(1,1,1,0.0),3)
			_overhead_text_fade_out_node.start()
	 
func _on_TextDelay_timeout():
	play_overhead()
	pass # Replace with function body.


func _on_FadeOut_tween_completed(_object,_key):
	_overhead_text_node.text = ""
	_overhead_text_node.self_modulate.a = 1.0
	playing_text = false
	pass # Replace with function body.
