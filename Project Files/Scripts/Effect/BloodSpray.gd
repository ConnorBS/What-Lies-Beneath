extends Node2D

func _process(delta):
	if $Particles2D.emitting == false:
		self.queue_free()
