extends KinematicBody2D
class_name Monster

onready var level_manager = get_parent().get_parent().get_parent()
onready var state_machine = $AnimationTree.get("parameters/playback")

signal monster_died

export (int) var health = 1
export (int) var run_speed = 160
export (int) var walk_speed = 80
export (int) var fall_speed = 160

export (int) var current_floor = 1

var _dead = false
export (int) var touch_damage = 30
var touch_damage_enabled = true

func receive_damage(incoming_damage):
	health -= incoming_damage
	print (health)
	if health <= 0:
		health = 0
		if _dead != true:
			_play_death_animation()
			die()

func melee_hit(damage):
	receive_damage(damage)

	
func die():
	$MonsterCriticalHitBox.queue_free()
	$GroundPosition.queue_free()
	$MonsterHitBox.queue_free()
	$InteractableHitBox.queue_free()
	_dead = true
	_find_level_node().monster_death(self)
		
		
func _play_death_animation():
	change_animation("Death")
	pass


func _find_level_node() -> Node:
	var parent = get_parent()
	while parent != null:
		if parent.is_in_group("Level"):
			return parent
		elif parent == get_tree():
			push_warning("Tried to find Level Node from Monster, no parents reporting as \"Level\" group")
			parent = null
		else:
			parent = parent.get_parent()
	return parent


func change_animation(animationToChangeTo:String)->void:
	if state_machine.get_current_node() != animationToChangeTo:
		state_machine.travel(animationToChangeTo)


