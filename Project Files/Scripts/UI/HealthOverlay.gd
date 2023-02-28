extends ColorRect
var _recorded_health
var _recorded_max_health
onready var green = $ColorRect.color
#var _troubleshootingSlider:HSlider

func set_health(healthValue,totalHealth)->void:
#	var healthPercentage:float =  1.0 - float(healthValue)/float(totalHealth)
#	if healthPercentage > 1.0:
#		self.material.set("shader_param/static_noise_intensity", 1.0)
#	else:
#		self.material.set("shader_param/static_noise_intensity", healthPercentage)
	var colourhealthPercentage:float =  float(healthValue)/float(totalHealth)
	if colourhealthPercentage > 1.0:
		$ColorRect.color = green
	else:
#		var topH = green.h
		$ColorRect.color.h = green.h*colourhealthPercentage

#func _ready():
#	set_health(95,100)
#	_troubleshootingSlider = get_parent().get_parent().get_parent().get_parent().find_node("HSlider")


#
#func _on_HSlider_value_changed(value):
#	print (value)
#	PlayerState.set_Player_Health(value)
##	set_health(value,100)
#	pass # Replace with function body.

func _process(_delta):
	var new_health = PlayerState.get_Player_Health()
	var new_max_health = PlayerState.get_Player_Max_Health()
	if new_health != _recorded_health or new_max_health != _recorded_max_health:
		_recorded_health = new_health
		_recorded_max_health = new_max_health
		set_health(_recorded_health,_recorded_max_health)
#		_troubleshootingSlider.value = _recorded_health
