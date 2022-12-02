extends Monster

func _process(delta):
	pass
	
onready var blood_spary_scene = preload("res://Scenes/Effect/BloodSpray.tscn")
onready var monsterHitBox = $MonsterCriticalHitBox

func blood_spray(position_to_use,slope):
	print (position)
	var new_blood = blood_spary_scene.instance()
	new_blood.position = position_to_use
	add_child(new_blood)
