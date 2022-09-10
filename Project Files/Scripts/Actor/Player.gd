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
var side_of_box = BOX_SIDE.NONE
var infront_of_interactable_object = false
var flipped = false

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
onready var climb_tween = $ClimbingInterations/ClimbTween

#########################
#########Boxes###########
#########################
signal move_box


var gun_selected = PlayerInventory.equipped_gun
var interactable_object = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationTree.active = true
	level_manager.enable_floor(current_floor)
	pass # Replace with function body.

func check_equipped_gun() -> int:
	gun_selected = PlayerInventory.equipped_gun
	return gun_selected
	
func change_animation(animationToChangeTo:String)->void:
	if state_machine.get_current_node() != animationToChangeTo:
		
		##TO BE REMOVED WHEN ALL ANIMATIONS ACCOUNTED FOR
		$animationPlaceholder.hide()
		#####################
		state_machine.travel(animationToChangeTo)
		print (animationToChangeTo)
		if animationToChangeTo == "Idle":
			
				pass
func change_mouse(mouse_cursor)->void:
	if mouse_cursor == null:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW,Vector2.ZERO)
	elif mouse_cursor == target_mouse_reticle:
		Input.set_custom_mouse_cursor(mouse_cursor,Input.CURSOR_ARROW,Vector2(10,10))
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
#		Input.set_custom_mouse_cursor(mouse_cursor,0,Vector2(10	,10))
	
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
		
	#######CLimbing#######
	elif check_if_current_animation_transition_climbing():
		return false
		
	#####Boxes#####
	elif check_if_current_animation_transition_pushing():
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

func update_previous_animation():
	if state_machine.get_current_node() != previous_animation:
		previous_animation = state_machine.get_current_node()
func check_if_animation_has_changed()->bool:
	if state_machine.get_current_node() != previous_animation:
		return true
	return false
func enable_ground_checker(prev_animation):
	if prev_animation == "Climbing_Up_To_Standing" or prev_animation == "Climbing_Down_To_Standing":
		$GroundPosition.set_deferred("disabled", false)
	

	
func _process(delta):
	###############################################
	#########Logic After Animation Change##########
	###############################################
	if check_if_animation_has_changed():
		enable_ground_checker(previous_animation)

	###############################################
	#####Input Check if Animation allows it########
	###############################################
	if check_if_current_animation_allows_movement() == true:
		PlayerState.set_Player_Active(true)
		var vector = get_input()
#		print ("Moving Character by ",vector)
		move_and_slide(vector)
		if push_box_state:
			print (vector)
	else:
		PlayerState.set_Player_Active(false)
	######################################
	####Moves Sprite while Climbing#######
	######################################
	if check_if_current_animation_transition_climbing():
		var vector = snap_to_ladder(interactable_object)
		vector.y = move_sprite_while_climbing().y
#		print ("ladder Vector: ",vector)
		move_and_slide(vector)
		
	######################################
	####Moves Sprite while Pushing #######
	######################################
#	elif check_if_current_animation_transition_pushing():
#		var vector = snap_to_box(interactable_object)
#		print ("Box Vector: ",vector)
#		move_and_slide(vector)
#		interactable_object.get_parent().move_and_slide(-vector)
	
	######################################
	##Calls draw to update laser pointer##
	######################################
	if aim_state:
		############With Laser Pointer#############
#		update()
		##########Without Laser Pointer#########
		aiming_gun()
	######################################
	update_previous_animation()
func _draw():
	if aim_state:
		###Removed Laser Pointer Visual
#		laser_pointer_to_mouse(aiming_gun())
		aiming_gun()



### Checking to break Interact State ("Kneeling_Down")
func _input(event):
	if interact_state == true:
		if ((event is InputEventKey) or (event is InputEventJoypadButton)) and event.pressed:
			change_animation("Idle")
			interact_state = false
#	if aim_state == true:
#		###Removed Laser Pointer Visual
##		laser_pointer_to_mouse(aiming_gun())
#		aiming_gun()
	

func get_input()->Vector2:
	var current = state_machine.get_current_node()
	var velocity = Vector2.ZERO
	
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
				##Erases laser pointer:
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
				return velocity
			elif interact_state:
				change_animation("Kneeling_Up")
				interact_state = false
				return velocity
			else:
				change_animation("Kneeling_Down")
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
	if Input.is_action_pressed("move_up") and !push_box_state:
		velocity.y -= 1
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
		###Determine movement speed
	
	##############################################
	################## Pushing ###################
	##############################################
	elif push_box_state:
#		if check_if_current_climbing_animation() == true:
		
		if velocity.x < 0 :
			if flipped:
				change_animation("Pushing_Box")
			else:
				change_animation("Pulling_Box")
		elif velocity.x > 0 :
			if flipped:
				change_animation("Pushing_Box")
			else:
				change_animation("Pulling_Box")
		else:
			change_animation("Pushing_Idle")
		return velocity * push_box_speed
		
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
	update()
	bullet_ray.enabled = false

func aiming_gun()->Vector2:
	bullet_ray.enabled = true
	var target= get_local_mouse_position()
	var direction_to_target 
	var distance_to_travel = 2000
	var gun_position = bullet_ray.position
	var max_slope = .5/1
	var facing = Vector2(1,0)
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
	var min_mouse_cord = Vector2(gun_position.x,0) ## Mouse Clamping
	var max_mouse_cord = Vector2.ZERO ## Mouse Clamping
	
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

	return target
func clamp_mouse_to_aim(starting_point:Vector2,slope:float,min_x:float,max_x:float)->Vector2:
	var mouse_pos = get_local_mouse_position()
	var new_mouse_pos = Vector2.ZERO
	new_mouse_pos.x = clamp(mouse_pos.x,min_x,max_x)
	##y=mx+b
	var min_y = -slope*(new_mouse_pos.x-starting_point.x)+starting_point.y
	var max_y = slope*(new_mouse_pos.x-starting_point.x)+starting_point.y
	new_mouse_pos.y = clamp(mouse_pos.y,min_y,max_y)
	Input.warp_mouse_position(get_viewport().canvas_transform.xform(to_global(new_mouse_pos)))
	return new_mouse_pos
	
	
func update_interaction(in_range:bool,area)->void:
	infront_of_interactable_object = in_range
	interactable_object = area
	if in_range:
		interact_pop_up_message.show()
	else:
		interact_pop_up_message.hide()
	
#func set_climbing(state:bool):
#	if climbing

func _on_InteractableHitBox_area_entered(area):
	if area.is_in_group("Interact"):
		update_interaction(true,area)
		if area.is_in_group("Box:Left"):
			side_of_box = BOX_SIDE.LEFT
		elif area.is_in_group("Box:Right"):
			side_of_box = BOX_SIDE.RIGHT


func _on_InteractableHitBox_area_exited(area):
	if area.is_in_group("Interact"):
		if !climbing:
			update_interaction(false,null)
			
		if area.is_in_group("Box"):
			side_of_box = BOX_SIDE.NONE


func _on_ClimbingHitBoxTop_area_entered(area):
	if climbing and check_if_current_climbing_animation() == true:
		if area.is_in_group("Ladder"):
			climbing_reached_top = true
			climbing_trigger(area.get_parent().up_floor)


func _on_ClimbingHitBoxTop_area_exited(area):	
	if climbing:
		climbing_reached_top = false


func _on_ClimbingHitBoxBottom_area_entered(area):
	if climbing and check_if_current_climbing_animation() == true:
		if area.is_in_group("Ladder"):
			climbing_reached_bottom = true
			climbing_trigger(area.get_parent().down_floor)

func climbing_state(state):
	climbing = state
	if climbing:
		var new_level = current_floor
		if interactable_object.is_in_group("Ladder_Bottom"):
			change_animation("Climbing_Up")
#			new_level += interactable_object.get_parent().travels_up_and_down_floor_count
		elif interactable_object.is_in_group("Ladder_Top"):
			change_animation("Climbing_Down")
#			new_level -= interactable_object.get_parent().travels_up_and_down_floor_count
		$ClimbingInterations/ClimbingHitBoxBottom.monitoring = true
		$ClimbingInterations/ClimbingHitBoxTop.monitoring = true
		$InteractableHitBox.monitoring = false
		$GroundPosition.disabled =true
		level_manager.move_to_floor(interactable_object.get_parent().ladder_floor,self)
	else:
		$ClimbingInterations/ClimbingHitBoxBottom.monitoring = false
		$ClimbingInterations/ClimbingHitBoxTop.monitoring = false
		$InteractableHitBox.monitoring = true
		##Ground position handled in process for after animation now
#		$GroundPosition.set_deferred("disabled", false)
		update_interaction(false,null)
		
func _on_ClimbingHitBoxBottom_area_exited(area):
	if climbing:
		climbing_reached_bottom = false

func climbing_trigger(new_level):
		change_animation("Idle")
		climbing_reached_bottom = false
		climbing_reached_top = false
		move_a_floor(new_level)
		climbing_state(false)
		current_floor = new_level
#		level_manager.move_to_floor(current_floor,self)

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
		vector = Vector2.UP * climb_speed * 2.5
	elif animation_playing == "Climbing_Down_To_Standing":
		vector = Vector2.DOWN #* climb_speed *.5
	return vector

func move_a_floor(new_floor):
	self.set_collision_layer_bit(current_floor-1,false)
	self.set_collision_mask_bit(current_floor-1,false)
	self.set_collision_layer_bit(new_floor-1,true)
	self.set_collision_mask_bit(new_floor-1,true)
	level_manager.move_to_floor(new_floor,self)
	return

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
#			box_node.position = to_local(box_node.position)
##			connect("move_box",box_node,)
#			get_parent().remove_child(box_node)
#			add_child(box_node)
		else:
			change_animation("Idle")
			var box_node = box_area2D.get_parent()
			
#			box_node.position = to_global(box_node.position)
#			self.remove_child(box_node)
#			get_parent().add_child(box_node)
			return snap_to_box(box_node.player_latched(push_box_state))
	return Vector2.ZERO
	
func snap_to_box(snap_pos:Vector2):
	var vector = Vector2.ZERO
	
	if snap_pos.y <self.global_position.y:
		vector.y = snap_pos.y-self.global_position.y
	else:
		vector.y = self.global_position.y-snap_pos.y
	
	if snap_pos.x <self.global_position.x:
		vector.x = snap_pos.x-self.global_position.x
	else:
		vector.x = self.global_position.x-snap_pos.x
	##################################
	#####Adjust for Sprite Width######
	##################################
	if global_position.x> snap_pos.x:
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
