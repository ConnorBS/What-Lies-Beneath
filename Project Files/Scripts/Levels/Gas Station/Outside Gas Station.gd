extends Node

export (int) var level_width = 2022
export (int) var level_height = 360
var current_floor 
export (Dictionary) var entrance_locations = {0:Vector2(200,200)}
export (String) var level_name = "Outside Gas Station"
onready var playerNode = find_node("Player")

onready var _dialog_window_scene = preload("res://Scenes/UI/DialogWindow.tscn")
var _current_dialog_window

signal change_scene

func _ready():
	
	set_player_pos(PlayerState.Spawn_Point)
	$FogShader.rect_size = Vector2(level_width,level_height)
	current_floor = playerNode.current_floor
	pass

func move_to_floor(new_floor,node_to_move):
	disable_floor(current_floor)
	yield(get_tree(), "idle_frame")
	node_to_move.get_parent().remove_child(node_to_move)
	find_node(make_floor_name(new_floor)).find_node("ActorsAndObjects").add_child(node_to_move)
	enable_floor(new_floor)
	current_floor = new_floor
	print (current_floor)


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
	playerNode.get_parent().remove_child(playerNode)
	spawnNode.get_parent().add_child(playerNode)
	playerNode.update_floor_collision(int(spawnNode.get_parent().get_parent().name[5]))
	


func _on_open_dialogWindow(trigger_name:String):
	var dialog_window = _dialog_window_scene.instance()
	dialog_window.load_window(level_name,trigger_name)
	dialog_window.connect("dialogClosed",self,"_on_close_dialogWindow")
	get_parent().get_parent().add_child(dialog_window)
	get_tree().paused = true
	pass # Replace with function body.

func _on_close_dialogWindow():
	get_tree().paused = false
	playerNode.dialog_closed()

func change_level(SceneToLoad,PointToLoad):
	var LoadingLevel = load(SceneToLoad).instance()
	
	PlayerState.Spawn_Point = PointToLoad
	emit_signal("change_scene",self,LoadingLevel)
