extends Monster

onready var blood_spary_scene = preload("res://Scenes/Effect/BloodSpray.tscn")
onready var monsterHitBox = $MonsterCriticalHitBox
onready var playerVisionNode = $PlayerVision
onready var wallVisionNode =  $WallVision
onready var decisionTimerNode = $DecisionTimer
onready var attackZoneNode = $AttackZone
export (float) var chance_to_turn = 0.5
export (float) var chance_to_walk = 0.5
export (float) var time_to_make_decision = 5.0



enum STATE {IDLE,WALK,CHARGE,ATTACK}
var currentState = STATE.IDLE
var justFlipped = false
var decisionMade = false
var playerInAttackZone = false

var lock_in_y

func _ready():
	lock_in_y = position.y
	walk_speed = -walk_speed
	charge_speed = -charge_speed
	var level_node = _find_level_node()
	if level_node.save_enemies:
		load_enemy_state()
		
#	position.y = level_node.get_floor_y(find_floor())


func find_floor():
	var nameOfFloor = get_parent().get_parent().name
	
	if nameOfFloor == "Floor1":
		return 1
	if nameOfFloor == "Floor2":
		return 2
	if nameOfFloor == "Floor3":
		return 3

func _process(delta):
	if _dead == false:
		
		if playerVisionNode.is_colliding():
			if currentState != STATE.CHARGE and currentState != STATE.ATTACK:
				charge()
		
		elif decisionMade == false:
			if wallVisionNode.is_colliding():
					if roll_chance(chance_to_turn):
						flip()
						if roll_chance(chance_to_walk):
							walk_forward()
						else:
							idle()
					else:
						idle()
						
			elif currentState == STATE.IDLE:
				if justFlipped:
					if roll_chance(chance_to_walk):
						walk_forward()
					else:
						idle()
				else:
					if roll_chance(chance_to_turn):
						flip()
					if roll_chance(chance_to_walk):
						walk_forward()
					else:
						idle()
		
		if currentState == STATE.WALK:
			var _movement = move_and_slide(Vector2(walk_speed,0)*delta,Vector2.UP)
#			print (_movement)
		elif currentState == STATE.CHARGE:
			var _movement = move_and_slide(Vector2(charge_speed,0)*delta,Vector2.UP)
#			print (_movement)
		
		position.y = lock_in_y
		
			
	pass

func idle():
	currentState = STATE.IDLE
	change_animation("Idle")
	decision_made()
#	print (name+ " is now Idling")
func charge():
	currentState = STATE.CHARGE
	change_animation("Walk")
	decision_made()
	
#	print (name+ " is now Charging")
	
func attack():
	currentState = STATE.ATTACK
	change_animation("Idle")
	change_animation("Attack")
	decision_made(1.8)
#	print(name+ " is now Attacking")
	pass

func flip():
	currentState = STATE.IDLE
	change_animation("Idle")
	self.scale.x = -self.scale.x
	walk_speed = -walk_speed
	charge_speed = -charge_speed
	decision_made()
	
#	print (name+ " has turned itself")
	
func decision_made(optional_time = time_to_make_decision):
	decisionMade = true
	decisionTimerNode.wait_time = optional_time
	decisionTimerNode.start()
	
func walk_forward():
	currentState = STATE.WALK
	change_animation("Walk")
	decision_made()
#	print (name+ " is now Walking")
	pass
	
func blood_spray(_position_to_use,_slope):
#	print (position)
#	var new_blood = blood_spary_scene.instance()
#	new_blood.position = position_to_use
#	add_child(new_blood)
	pass

func _on_TouchDamage_area_entered(area):
	if !_dead:
		if area.get_parent().is_in_group("Player") and touch_damage_enabled:
			area.get_parent().receive_damage(touch_damage)
			touch_damage_enabled = false
			$TouchDamage/WaitTillDamageCanOccurAgain.start()
			save_enemy_state()
		
func _on_WaitTillDamageCanOccurAgain_timeout():
	touch_damage_enabled = true
	


func _on_TouchDamage_body_entered(body):
	if !_dead:
		if body.is_in_group("Player") and touch_damage_enabled:
			body.receive_damage(touch_damage)
			touch_damage_enabled = false
			$TouchDamage/WaitTillDamageCanOccurAgain.start()
			save_enemy_state()

func roll_chance(chance_of_hit:float = 0.5)-> bool:
	if chance_of_hit <= randf():
		return true
	return false

func reset_state():
	currentState = STATE.IDLE
	decisionMade = false
	justFlipped = false
	
func _on_DecisionTimer_timeout():
#	if currentState == STATE.WALK:
#		change_animation("idle")
	if _dead:
		return
	elif currentState == STATE.ATTACK and playerInAttackZone:
		attack()
	else:
		reset_state()


func _on_AttackZone_body_entered(_body):
	if !_dead:
		playerInAttackZone = true
		attack()
	
	pass # Replace with function body.


func _on_AttackZone_body_exited(_body):
	if !_dead:
		playerInAttackZone  = false
	pass # Replace with function body.
