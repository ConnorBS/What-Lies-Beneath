extends Node

var Player_ACTIVE = false
var Spawn_Point = 1

func set_Player_Active(state:bool)->bool:
	Player_ACTIVE = state
	return Player_ACTIVE
	
	
func get_Player_Active()->bool:
	return Player_ACTIVE
