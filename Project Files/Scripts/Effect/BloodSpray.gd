extends Node2D

func _process(_delta):
	if $Particles2D.emitting == false:
		self.queue_free()
