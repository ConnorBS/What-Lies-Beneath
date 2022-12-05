extends Monster

func _process(delta):
#	self.cont
	pass
	
onready var blood_spary_scene = preload("res://Scenes/Effect/BloodSpray.tscn")
onready var monsterHitBox = $MonsterCriticalHitBox

func blood_spray(position_to_use,slope):
	print (position)
#	var new_blood = blood_spary_scene.instance()
#	new_blood.position = position_to_use
#	add_child(new_blood)


func _on_TouchDamage_area_entered(area):
	if area.get_parent().is_in_group("Player") and touch_damage_enabled:
		area.get_parent().receive_damage(touch_damage)
		touch_damage_enabled = false
		
func _on_WaitTillDamageCanOccurAgain_timeout():
	touch_damage_enabled = true
	



func _on_TouchDamage_body_entered(body):
	if body.is_in_group("Player") and touch_damage_enabled:
		body.receive_damage(touch_damage)
		touch_damage_enabled = false
		$TouchDamage/WaitTillDamageCanOccurAgain.start()
