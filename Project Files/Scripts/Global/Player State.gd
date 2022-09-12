extends Node

var Player_ACTIVE = false

func set_Player_Active(state:bool)->bool:
	Player_ACTIVE = state
	return Player_ACTIVE
	
	
func get_Player_Active()->bool:
	return Player_ACTIVE
