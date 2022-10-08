extends ColorRect
onready var green = self.color

func set_health(healthValue,totalHealth)->void:
	var healthPercentage:float =  float(healthValue)/float(totalHealth)
	if healthPercentage > 1.0:
		self.color = green
	else:
		var topH = green.h
		self.color.h = green.h*healthPercentage
