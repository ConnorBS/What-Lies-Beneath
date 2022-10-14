extends MarginContainer

tool

signal Continue
signal Save
signal Cancel
signal Back
export (bool) var Options = false
export (bool) var Continue = false

var _continueLabelText = "Continue"
var _backLabelText = "Back"

func _ready():
	
	if Options:
		_set_buttons_for_options()
	if Continue == false:
		$HBoxContainer/Continue.text = ""
	pass
	

func _on_Back_pressed():
	
	if Options:
		emit_signal("Cancel")
	else:
		emit_signal("Back")
	pass # Replace with function body.


func _on_Continue_pressed():
	if Options:
		emit_signal("Save")
	else:
		emit_signal("Continue")
	pass # Replace with function body.

func _set_buttons_for_options():
	$HBoxContainer/Back.text = "Cancel"
	$HBoxContainer/Continue.text = "Save"
	pass

func _process(_delta):
	if Engine.editor_hint:
		if Options:
			_set_buttons_for_options()
		else:
			$HBoxContainer/Back.text = _backLabelText
			$HBoxContainer/Continue.text = _continueLabelText

		if Continue == false:
			$HBoxContainer/Continue.text = ""
