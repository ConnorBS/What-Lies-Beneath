extends KinematicBody2D
class_name Monster

onready var level_manager = get_parent().get_parent().get_parent()
onready var state_machine = $AnimationTree.get("parameters/playback")


export (int) var health = 25
export (int) var run_speed = 160
export (int) var walk_speed = 80
export (int) var fall_speed = 160

export (int) var current_floor = 1

var _dead = false

func receive_damage(incoming_damage):
	health -= incoming_damage
	print (health)
	if health <= 0:
		health = 0
		if _dead != true:
			_play_death_animation()
			die()

func die():
	$MonsterCriticalHitBox.queue_free()
	$GroundPosition.queue_free()
	$MonsterHitBox.queue_free()
	$InteractableHitBox.queue_free()
	_dead = true
	
		
		
func _play_death_animation():
	change_animation("Death")
	pass






func change_animation(animationToChangeTo:String)->void:
	if state_machine.get_current_node() != animationToChangeTo:
		state_machine.travel(animationToChangeTo)
