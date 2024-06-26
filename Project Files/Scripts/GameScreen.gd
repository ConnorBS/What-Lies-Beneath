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
onready var _levelTranslationNode= $LevelTransition
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
	_load_current_level()
	pass # Replace with function body.

func _load_current_level():
	var level_to_load = LevelDirectory.lookup_level(PlayerState._current_level)
	var new_level_node = load(level_to_load).instance()
	_viewportNode.add_child(new_level_node)
	new_level_node.connect("change_scene",self,"_on_change_scene")
#############################################
######## Game Window Transtiontions #########
#############################################
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
	_gameScreenResizeTween.interpolate_property(_healthOverlayNode,"modulate",_healthOverlayNode.modulate,Color(_healthOverlayNode.modulate.r,_healthOverlayNode.modulate.g,_healthOverlayNode.modulate.b,1.0), timeToTween)
	
	_gameScreenResizeTween.start()
	pass
	
func _tween_grow(topLeft:Vector2,bottomRight:Vector2)->void:
	_gameScreenResizeTween.interpolate_property(_gamePanelNode,"margin_left",_gamePanelNode.margin_left, topLeft.x,timeToTween)
	_gameScreenResizeTween.interpolate_property(_gamePanelNode,"margin_top",_gamePanelNode.margin_top, topLeft.y,timeToTween)
	_gameScreenResizeTween.interpolate_property(_gamePanelNode,"margin_right",_gamePanelNode.margin_right, bottomRight.x,timeToTween)
	_gameScreenResizeTween.interpolate_property(_gamePanelNode,"margin_bottom",_gamePanelNode.margin_bottom, bottomRight.y,timeToTween)
	_gameScreenResizeTween.interpolate_property(_healthOverlayNode,"modulate",_healthOverlayNode.modulate,Color(_healthOverlayNode.modulate.r,_healthOverlayNode.modulate.g,_healthOverlayNode.modulate.b,0.0), timeToTween)

	_gameScreenResizeTween.start()
	pass

##########################
##### Player Inputs ######
##########################

func _get_input():
	if Input.is_action_just_pressed("menu"):
		if menu_visible:
			
			if _window_state == MENU_WINDOWS.Main:
				_menuMusicNode.stop()
				_viewportNode.gui_disable_input = true
				_tween_grow(Vector2.ZERO,_fullDimensions)
				menu_visible = false
				get_tree().paused = false
				PlayerState.set_Player_Active(true)
				play_background_music()
			else:
				_on_Back()
		elif  PlayerState.get_Player_Active():
			if _viewportNode.get_child(0) != null:
				_viewportNode.get_child(0) .clear_dialog()
			get_node("%MainMenu").load_window()
			_viewportNode.gui_disable_input = true
			_menuMusicNode.play()
			_tween_shrink(shrinkTopLeftCorner,shrinkBottomRightCorner)
			menu_visible = true
			get_tree().paused = true
			PlayerState.set_Player_Active(false)
			play_menu_music()

func _process(_delta):
	_get_input()

###########################################
########### Menu Transitions ##############
###########################################
func unpause():
	_menuMusicNode.stop()
	_viewportNode.gui_disable_input = true
	_tween_grow(Vector2.ZERO,_fullDimensions)
	menu_visible = false
	get_tree().paused = false
	PlayerState.set_Player_Active(true)
	play_background_music()

###Buttons call these functions to triger transitions
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


#############################
######## Audio Cues #########
#############################
func click_success():
	_menuSFXNode.play()

func play_voice(voice_file):
	$Voice.stream = load(voice_file)
	$Voice.play()

func update_backgroundMusic(musicFile):
	$BackgroundMusic.stream = musicFile
	$BackgroundMusic.play()
	play_background_music()
	
func play_menu_music():
	$MenuMusic.stream_paused = false
	$BackgroundMusic.stream_paused = true
func play_background_music():
	$MenuMusic.stream_paused = true
	$BackgroundMusic.stream_paused = false
#############################
###### Button Presses #######
#############################
func _on_MainMenu_Map():
	click_success()
	get_node("%Map").load_window()
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

##########################################
##############Change Scene################
##########################################
onready var node_current:Node = null
var node_to_change:Node = null

func _on_change_scene(node,new_node:Node):
	_levelTranslationNode.play("SmokeTransitionUP")
	node_current = node
	node_to_change = new_node
	PlayerState.set_Player_Active(false)

func _on_LevelTransition_animation_finished(anim_name):
	if anim_name == "SmokeTransitionUP":
		if node_current != null:
			node_current.queue_free()
		elif _viewportNode.get_child(0) != null:
			_viewportNode.get_child(0).queue_free()
		var _ignore_value = node_to_change.connect("change_scene",self,"_on_change_scene")
		_viewportNode.add_child(node_to_change)
		_viewportNode.move_child(node_to_change,0)
		
		_levelTranslationNode.play("SmokeTransitionDown")
	if anim_name == "SmokeTransitionDown":
		PlayerState.set_Player_Active(true)
	pass # Replace with function body.



func _on_MainMenu_Remove_Item(item):
	_viewportNode.get_child(0).drop_item(item)
	pass # Replace with function body.
