extends CanvasLayer

onready var _animationPlayerNode = $AnimationPlayer
onready var _viewportNode = $ViewportContainer/Viewport
##States##
var menu_visible = false
func _ready():
	print ($ViewportContainer.anchor_right)
	pass # Replace with function body.


func _get_input():
	if Input.is_action_just_pressed("menu"):
		if menu_visible:
			_animationPlayerNode.play("MainMenu_Down")
			menu_visible = false
			get_tree().paused = false
			PlayerState.set_Player_Active(true)
		else:
			_animationPlayerNode.play("MainMenu_Up")
			menu_visible = true
			get_tree().paused = true
			PlayerState.set_Player_Active(false)

func _process(_delta):
	_get_input()
