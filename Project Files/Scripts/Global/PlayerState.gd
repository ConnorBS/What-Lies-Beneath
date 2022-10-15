extends Node

###########################
######## Variables ########
###########################
var _Player_ACTIVE = false
var Spawn_Point = 1

###### Health ######
var _Max_Health = 100
var _Current_Health:int



###########################
###### Player Active ######
###########################

func set_Player_Active(state:bool)->void:
	_Player_ACTIVE = state
	
func get_Player_Active()->bool:
	return _Player_ACTIVE

###########################
###### Player Health ######
###########################
func set_Player_Health(new_health)->void:
	_Current_Health = new_health
	if _check_for_death():
		####INSERT SOME KIND OF DEATH FUNCTION
		pass

func get_Player_Health()->int:
	return _Current_Health

func _check_for_death()->bool:
	if _Current_Health <= 0:
		return true
	return false


