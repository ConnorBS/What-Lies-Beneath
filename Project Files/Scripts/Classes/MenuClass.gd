extends CanvasLayer

class_name MenuClass

signal Back

func window_load()->void:
	pass
	
func _on_Back_pressed():
	emit_signal("Back")
