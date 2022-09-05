extends KinematicBody2D


onready var state_machine = $AnimationTree.get("parameters/playback")
export (int) var run_speed = 160
export (int) var walk_speed = 80

var sprint_state = false
var gun_out_state = false
var interact_state = false

var gun_selected = PlayerInventory.equipped_gun


# Called when the node enters the scene tree for the first time.
func _ready():
	
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
	else:
		return true
		
		
func _process(delta):
	if check_if_current_animation_allows_movement() == true:
		
		move_and_slide(get_input())

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

