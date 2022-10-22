extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var choice = 0
signal choiceHighlighted
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Choice_mouse_entered():
	self.modulate = Color(.5,.5,.5,1)
	emit_signal("choiceHighlighted",choice)
	pass # Replace with function body.


func _on_Choice_mouse_exited():
	self.modulate = Color(1,1,1,1)
	emit_signal("choiceHighlighted",0)
	
	pass # Replace with function body.
