extends CanvasLayer

onready var _animationPlayerNode = $AnimationPlayer
onready var _viewportNode = $GameWindowPanel/ViewportContainer/Viewport
onready var _gamePanelNode = $GameWindowPanel
onready var _gameScreenResizeTween = $GameScreenResize
onready var _healthOverlayNode = $GameWindowPanel/ViewportContainer/HealthOverlay
onready var _fullDimensions = get_viewport().size
export (Vector2) var shrinkTopLeftCorner = Vector2(37,69)
export (Vector2) var shrinkBottomRightCorner = Vector2(334,189)
export (float) var timeToTween = 1.0
##States##
var menu_visible = false
func _ready():
	_fill_screen_with_game()
	pass # Replace with function body.

func _fill_screen_with_game():
	_gamePanelNode.margin_bottom = _fullDimensions.y
	_gamePanelNode.margin_right = _fullDimensions.x
	_gamePanelNode.margin_left = 0
	_gamePanelNode.margin_top = 0

func _tween_shrink(topLeft:Vector2,bottomRight:Vector2)->void:
	_gameScreenResizeTween.interpolate_property(_gamePanelNode,"margin_left",_gamePanelNode.margin_left, topLeft.x,timeToTween)
	_gameScreenResizeTween.interpolate_property(_gamePanelNode,"margin_top",_gamePanelNode.margin_top, topLeft.y,timeToTween)
	_gameScreenResizeTween.interpolate_property(_gamePanelNode,"margin_right",_gamePanelNode.margin_right, bottomRight.x,timeToTween)
	_gameScreenResizeTween.interpolate_property(_gamePanelNode,"margin_bottom",_gamePanelNode.margin_bottom, bottomRight.y,timeToTween)
	_gameScreenResizeTween.interpolate_property(_healthOverlayNode,"self_modulate",_healthOverlayNode.self_modulate,Color(_healthOverlayNode.self_modulate.r,_healthOverlayNode.self_modulate.g,_healthOverlayNode.self_modulate.b,1.0), timeToTween)
	
	_gameScreenResizeTween.start()
	pass
	
func _tween_grow(topLeft:Vector2,bottomRight:Vector2)->void:
	_gameScreenResizeTween.interpolate_property(_gamePanelNode,"margin_left",_gamePanelNode.margin_left, topLeft.x,timeToTween)
	_gameScreenResizeTween.interpolate_property(_gamePanelNode,"margin_top",_gamePanelNode.margin_top, topLeft.y,timeToTween)
	_gameScreenResizeTween.interpolate_property(_gamePanelNode,"margin_right",_gamePanelNode.margin_right, bottomRight.x,timeToTween)
	_gameScreenResizeTween.interpolate_property(_gamePanelNode,"margin_bottom",_gamePanelNode.margin_bottom, bottomRight.y,timeToTween)
	_gameScreenResizeTween.interpolate_property(_healthOverlayNode,"self_modulate",_healthOverlayNode.self_modulate,Color(_healthOverlayNode.self_modulate.r,_healthOverlayNode.self_modulate.g,_healthOverlayNode.self_modulate.b,0.0), timeToTween)

	_gameScreenResizeTween.start()
	pass
	
	
func _get_input():
	if Input.is_action_just_pressed("menu"):
		if menu_visible:
#			_animationPlayerNode.play("MainMenu_Down")
			_tween_grow(Vector2.ZERO,_fullDimensions)
			menu_visible = false
			get_tree().paused = false
			PlayerState.set_Player_Active(true)
		else:
#			_animationPlayerNode.play("MainMenu_Up")
			_tween_shrink(shrinkTopLeftCorner,shrinkBottomRightCorner)
			menu_visible = true
			get_tree().paused = true
			PlayerState.set_Player_Active(false)

func _process(_delta):
	_get_input()
