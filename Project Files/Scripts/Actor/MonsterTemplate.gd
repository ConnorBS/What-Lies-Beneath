extends Monster

func _process(delta):
	pass
	
#func _ready():
#	$AnimationTree.active = true
#	state_machine = $AnimationTree.get("parameters/playback")
		
#func _play_death_animation():
#	change_animation("Death")
#	pass
#
#func change_animation(animationToChangeTo:String)->void:
#	if state_machine.get_current_node() != animationToChangeTo:
#		state_machine.travel(animationToChangeTo)
#		print (animationToChangeTo)
