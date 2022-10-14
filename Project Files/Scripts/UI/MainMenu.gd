extends CanvasLayer

signal Map
signal Memo
signal KeyItems
signal Options




func _on_Map_pressed():
	emit_signal("Map")
	pass # Replace with function body.


func _on_Memo_pressed():
	emit_signal("Memo")
	pass # Replace with function body.


func _on_KeyItems_pressed():
	emit_signal("KeyItems")
	pass # Replace with function body.


func _on_Options_pressed():
	emit_signal("Options")
	pass # Replace with function body.
