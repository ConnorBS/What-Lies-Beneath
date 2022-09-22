extends Node

var level_width = 2022
var level_height = 360
var current_floor 
export (Dictionary) var entrance_locations = {0:Vector2(200,200)}


func _ready():
	$FogShader.rect_size = Vector2(level_width,level_height)
	current_floor = find_node("Player",true).current_floor
	pass

func move_to_floor(new_floor,node_to_move):
	print("moving_floor(",new_floor,", ",node_to_move.name,")")
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
	return "Level"+str(floor_number)
