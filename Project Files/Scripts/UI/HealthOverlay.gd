extends ColorRect
onready var green = self.color

func set_health(healthValue,totalHealth)->void:
	var healthPercentage:float =  1.0 - float(healthValue)/float(totalHealth)
	if healthPercentage > 1.0:
		self.material.set("shader_param/static_noise_intensity", 1.0)
		self.color = green
	else:
		self.material.set("shader_param/static_noise_intensity", healthPercentage)
		var topH = green.h
		self.color.h = green.h*healthPercentage

func _ready():
	set_health(95,100)



func _on_HSlider_value_changed(value):
	print (value)
	set_health(value,100)
	pass # Replace with function body.
