extends Node

var level_width = 2022
var level_height = 360

func _ready():
	$FogShader.rect_size = Vector2(level_width,level_height)
<<<<<<< HEAD
	pass
=======
#	$Level1/Background/OutOfBounds.set_collision_layer_bit(4,false)
#	$Level1/Background/OutOfBounds.set_collision_layer_bit(1,true)
	current_floor = find_node("Player",true).current_floor
	pass

func move_to_floor(new_floor,node_to_move):
	print("moving_floor(",new_floor,", ",node_to_move.name,")")
	disable_floor(current_floor)
	node_to_move.get_parent().remove_child(node_to_move)
	find_node(make_floor_name(new_floor)).find_node("ActorsAndObjects").add_child(node_to_move)
	enable_floor(new_floor)
	current_floor = new_floor
	print (current_floor)

func disable_floor(floor_to_disable):
	var level_node = find_node(make_floor_name(floor_to_disable))
#	var background_node = level_node.find_node("Background")
#	for collision_shapes in background_node.find_node("OutOfBounds").get_children():
#		collision_shapes.call_deferred("disabled", true)
	level_node.hide()
	

func enable_floor(floor_to_enable):
	var level_node = find_node(make_floor_name(floor_to_enable))
#	var background_node = level_node.find_node("Background")
#	for collision_shapes in background_node.find_node("OutOfBounds").get_children():
#		collision_shapes.call_deferred("disabled", false)
	level_node.show()
	
func get_current_level():
	current_floor = find_node("Player",true).current_floor
	return current_floor

func make_floor_name(floor_number:int)->String:
	return "Level"+str(floor_number)
>>>>>>> 09c508b (Ladders working to move between levels)
