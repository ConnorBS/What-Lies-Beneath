extends Control

#######################################
### Mini/Restoring Game Play Window ###
#######################################

######## Nodes #########

#onready var _animationPlayerNode = $AnimationPlayer
onready var _viewportNode = $MainMenu/GameWindowPanel/ViewportContainer/Viewport
onready var _gamePanelNode = $MainMenu/GameWindowPanel
onready var _gameScreenResizeTween = $GameScreenResize
onready var _healthOverlayNode = $MainMenu/GameWindowPanel/ViewportContainer/HealthOverlay
onready var _fullDimensions = get_viewport().size
onready var _menuMusicNode = $MenuMusic
onready var _menuSFXNode = $MenuSFX

######## Editor Values ########
export (Vector2) var shrinkTopLeftCorner = Vector2(37,69)
export (Vector2) var shrinkBottomRightCorner = Vector2(334,189)
export (float) var timeToTween = 1.0

#######################################
######### Menu Controls ###############
#######################################

enum MENU_WINDOWS{Main,Map,Memo,KeyItems,Options}

onready var _menuTransitionsNode = $MenuTransition
onready var _mapNode = $Map
onready var _memoNode = $Map
onready var _keyItemsNode = $Map
onready var _optionsNode = $Map

########States#####
var menu_visible = false
var _window_state = MENU_WINDOWS.Main





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
			
			if _window_state == MENU_WINDOWS.Main:
				_menuMusicNode.stop()
				_viewportNode.gui_disable_input = false
				_tween_grow(Vector2.ZERO,_fullDimensions)
				menu_visible = false
				get_tree().paused = false
				PlayerState.set_Player_Active(true)
			else:
				_on_Back()
		else:
			get_node("%MainMenu").load_window()
			_viewportNode.gui_disable_input = true
			_menuMusicNode.play()
			_tween_shrink(shrinkTopLeftCorner,shrinkBottomRightCorner)
			menu_visible = true
			get_tree().paused = true
			PlayerState.set_Player_Active(false)

func _process(_delta):
	_get_input()



func _update_window(new_window:int)->void:
	if new_window == MENU_WINDOWS.Map:
		_menuTransitionsNode.play("Open_Map")
	if new_window == MENU_WINDOWS.Options:
		_menuTransitionsNode.play("Open_Options")
	if new_window == MENU_WINDOWS.Memo:
		_menuTransitionsNode.play("Open_Memo")
	if new_window == MENU_WINDOWS.KeyItems:
		_menuTransitionsNode.play("Open_KeyItems")
	
	elif new_window == MENU_WINDOWS.Main:
		get_node("%MainMenu").load_window()
		if _window_state == MENU_WINDOWS.Options:
			_menuTransitionsNode.play("Close_Options")
		elif _window_state == MENU_WINDOWS.Map:
			_menuTransitionsNode.play("Close_Map")
		
		elif _window_state == MENU_WINDOWS.Memo:
			_menuTransitionsNode.play("Close_Memo")
		
		elif _window_state == MENU_WINDOWS.KeyItems:
			_menuTransitionsNode.play("Close_KeyItems")
		

	_window_state = new_window
	
	pass


func click_success():
	_menuSFXNode.play()
func _on_MainMenu_Map():
	click_success()
#	get_node("%Map").load_window()
	_update_window(MENU_WINDOWS.Map)
	pass # Replace with function body.


func _on_Back():
	click_success()
	_update_window(MENU_WINDOWS.Main)
	pass # Replace with function body.


func _on_MainMenu_Options():
	click_success()
	get_node("%Options").load_window()
	_update_window(MENU_WINDOWS.Options)
	pass # Replace with function body.


func _on_MainMenu_Memo():
	click_success()
	get_node("%Memo").load_window()
	_update_window(MENU_WINDOWS.Memo)
	pass # Replace with function body.


func _on_MainMenu_KeyItems():
	click_success()
	get_node("%KeyItems").load_window()
	_update_window(MENU_WINDOWS.KeyItems)
	pass # Replace with function body.
