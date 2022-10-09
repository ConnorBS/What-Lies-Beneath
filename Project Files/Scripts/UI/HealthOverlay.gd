extends ColorRect
onready var green = self.color

func set_health(healthValue,totalHealth)->void:
	var healthPercentage:float =  float(healthValue)/float(totalHealth)
	if healthPercentage > 1.0:
		self.color = green
	else:
		var topH = green.h
		self.color.h = green.h*healthPercentage

func _ready():
	set_health(75,100)


func _on_HSlider_drag_ended(value_changed):
	pass # Replace with function body.


func _on_HSlider_value_changed(value):
	print (value)
	set_health(value,100)
	pass # Replace with function body.
