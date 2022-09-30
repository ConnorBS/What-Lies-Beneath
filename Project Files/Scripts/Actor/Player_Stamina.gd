extends ProgressBar

export (int) var stamina_max = 100
export (int) var refresh_rate = 1
export (float) var use_rate = .5

 
signal out_of_stamina
signal stamina_filled

var running = false

func _ready():
	max_value = stamina_max
	value = stamina_max
	
func _process(_delta):
	if running:
		running = false
	else:
		var stamina_previous = value
		value += refresh_rate
		if stamina_previous < stamina_max and value >= stamina_max:
			emit_signal("stamina_filled")


func use():
	value -= use_rate
	running = true
	if value <= 0:
		emit_signal("out_of_stamina")
