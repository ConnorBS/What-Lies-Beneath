extends KinematicBody2D


onready var state_machine = $AnimationTree.get("parameters/playback")
onready var bullet_ray = $Bullet
onready var target_mouse_reticle = preload("res://Assets/UI/Mouse Cursors/Target.png")
export (int) var run_speed = 160
export (int) var walk_speed = 80

var sprint_state = false
var gun_out_state = false
var interact_state = false
var aim_state = false

var gun_selected = PlayerInventory.equipped_gun


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationTree.active = true
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
	else:
		return true
		
		
func _process(delta):
	if check_if_current_animation_allows_movement() == true:
		
		move_and_slide(get_input())
		
	######################################
	##Calls draw to update laser pointer##
	######################################
	if aim_state:
		update()
	######################################
	
func _draw():
	if aim_state:
		laser_pointer_to_mouse(aiming_gun())

### Checking to break Interact State ("Kneeling_Down")
func _input(event):
	if interact_state == true:
		if ((event is InputEventKey) || (event is InputEventJoypadButton)) && event.pressed:
			change_animation("Idle")
			interact_state = false
	
	
#func check_to_break_interact_state()->void:
#	if Input.is_action_pressed()
#	pass
func get_input()->Vector2:
	var current = state_machine.get_current_node()
	var velocity = Vector2.ZERO
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
		
	if Input.is_action_just_pressed("interact"):
		if interact_state:
			change_animation("Kneeling_Up")
			interact_state = false
			return velocity
		else:
			change_animation("Kneeling_Down")
			####Could hold out from saying interact State to be triggered by dialog/cutscene time
			interact_state = true
			return velocity
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

	if Input.is_action_just_pressed("toggle_sprint"):
		sprint_state = !sprint_state
	if Input.is_action_pressed("sprint"):
		sprint_state = true
	elif Input.is_action_just_released("sprint"):
		sprint_state = false
		
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		$Sprite.scale.x = 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		$Sprite.scale.x = -1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		
	###Determine movement speed
	if (sprint_state == true) && (gun_out_state == false):
		velocity = velocity.normalized() * run_speed
		if velocity.length() != 0:
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
	var flipped = $Sprite.scale.x < 0
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
