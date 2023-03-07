extends Node2D

export (int) var level_width = 2022
export (int) var level_height = 360
export (int) var floor1_y =0
export (int) var floor2_y =0
export (int) var floor3_y =0
var current_floor 
export (Dictionary) var entrance_locations = {0:Vector2(200,200)}
export (String) var level_name = "Outside Gas Station"
export (AudioStream) var background_music
export (bool) var save_enemies = true

export (bool) var requires_lighting = false

onready var playerNode = find_node("Player")
onready var _camera_node = playerNode.find_node("GameCamera")

onready var _dialog_window_scene = preload("res://Scenes/UI/DialogWindow.tscn")
var _current_dialog_window

var _dialog_queue = []
signal change_scene

var loaded_from_file

func _ready():
	
#	SaveAndLoad.load_game()
	if PlayerState.loading_from_file:
		playerNode.position = PlayerState.player_position
		PlayerState.loading_from_file = false
	else:
		set_player_pos(PlayerState.Spawn_Point)
		
	$FogShader.rect_size = Vector2(level_width,level_height)
	current_floor = playerNode.current_floor
	if get_tree().get_root().find_node("GameScreen") != null:
		get_tree().get_root().get_node("GameScreen").update_backgroundMusic(background_music)
	PlayerState.set_current_level(level_name)
	_camera_node.enter_scene(level_name)
	
	set_lighting(requires_lighting)
	pass

func get_floor_y (floorNum):
	if floorNum == 1:
		return floor1_y
	elif floorNum == 2:
		return floor2_y
	else:
		return floor3_y
		
func move_to_floor(new_floor,node_to_move):
	disable_floor(current_floor)
	yield(get_tree(), "idle_frame")
	node_to_move.get_parent().remove_child(node_to_move)
	find_node(make_floor_name(new_floor)).find_node("ActorsAndObjects").add_child(node_to_move)
	enable_floor(new_floor)
	current_floor = new_floor
#	print (current_floor)

#####Disable Backgrounds to avoid unintential overwriting
func disable_floor(floor_to_disable):
	var level_node = find_node(make_floor_name(floor_to_disable)).find_node("Background")
	level_node.hide()
	

func enable_floor(floor_to_enable):
	var level_node = find_node(make_floor_name(floor_to_enable)).find_node("Background")
	level_node.show()
	
func get_current_level():
	current_floor = find_node("Player",true).current_floor
	return current_floor

func make_floor_name(floor_number:int)->String:
	return "Floor"+str(floor_number)

func set_player_pos(spawPointNumber:int)->void:
	var newPos = "SpawnPoint"+str(spawPointNumber)
	var spawnNode = find_node(newPos)
	if spawnNode == null:
		newPos = "SpawnPoint1"
		spawnNode = find_node(newPos)
		if spawnNode == null:
			return
	playerNode.position = spawnNode.position
	playerNode.flip_sprite(spawnNode.flipped)
	
	playerNode.get_parent().remove_child(playerNode)
	spawnNode.get_parent().add_child(playerNode)
	playerNode.update_floor_collision(int(spawnNode.get_parent().get_parent().name[5]))
	


func _on_open_dialogWindow(trigger_name:String):
	
	
#	playerNode.change_animation("Walking")
	var dialog_window = _dialog_window_scene.instance()
	if trigger_name == "Save_Load":
		dialog_window.load_window("GeneralUI",trigger_name)
	else:
		dialog_window.load_window(level_name,trigger_name)
	dialog_window.connect("dialogClosed",self,"_on_close_dialogWindow")
	get_parent().get_parent().add_child(dialog_window)
	get_tree().paused = true
	_current_dialog_window = dialog_window
	pass # Replace with function body.

func _on_open_dialogWindow_system_message(array_of_text:Array):
	var dialog_window = _dialog_window_scene.instance()
	dialog_window.load_system_window(array_of_text)
	dialog_window.connect("dialogClosed",self,"_on_close_dialogWindow")
	if _current_dialog_window == null:
		get_parent().get_parent().add_child(dialog_window)
		_current_dialog_window = dialog_window
		get_tree().paused = true
	else:
		_dialog_queue.append(dialog_window)
	
func _on_close_dialogWindow(clear_node = false):
	if clear_node:
		_current_dialog_window =null
	
	elif _dialog_queue.empty():
		get_tree().paused = false
		playerNode.dialog_closed()
#		_current_dialog_window =null
	else:
		
		_current_dialog_window.queue_free()
		_current_dialog_window = null
		_current_dialog_window = _dialog_queue.pop_front()
		get_parent().get_parent().add_child(_current_dialog_window)

func clear_dialog():
	if _current_dialog_window != null:
		_current_dialog_window.queue_free()
		_current_dialog_window = null
		
	

func change_level(SceneToLoad,PointToLoad):
	var LoadingLevel = load(SceneToLoad).instance()
	
#	SaveAndLoad.save_game()
#	playerNode.change_animation("Walking")
	PlayerState.Spawn_Point = PointToLoad
	emit_signal("change_scene",self,LoadingLevel)
	
################################################
######### Object Pickup  #######################
################################################

func save_pickup_state_of_object_in_level(name_of_object,save_data) ->void:
	PlayerState.save_item_pickup(level_name,name_of_object,save_data)

func load_pickup_state_of_object_in_level (name_of_object) -> Dictionary:
	return PlayerState.load_item_pickup(level_name,name_of_object)

################################################
######### Monster     #######################
################################################


func save_enemy_state_in_level(name_of_enemy,save_data) ->void:
	if save_enemies:
		PlayerState.save_enemy_state(level_name,name_of_enemy,save_data)

func load_enemy_state_in_level (name_of_enemy) -> Dictionary:
	if save_enemies:
		return PlayerState.load_enemy_state(level_name,name_of_enemy)
	return {}

func monster_death(_monster_node):
	_camera_node.monster_death()

################################################
######### Lighting Config #######################
################################################

func set_lighting(needs_lighting):
	if needs_lighting:
		self.modulate = Color(.40,.40,.40)
	playerNode.set_the_lights(needs_lighting)
