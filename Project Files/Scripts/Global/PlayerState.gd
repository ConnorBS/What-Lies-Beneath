extends Node

###########################
######## Variables ########
###########################
var _Player_ACTIVE = true
var Spawn_Point = 3
var _player_name:String = "Ethan"
const doors_unlocked = {}
const list_of_places_visited = []
###### Health ######
var _Max_Health = 100
var _Current_Health:int


func get_player_name()->String:
	return _player_name

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
func get_Player_Max_Health()->int:
	return _Max_Health

func heal(value:int)->void:
	_Current_Health += value
	if _check_for_death():
		_Current_Health = 0
		print ("Dead")
	elif _Current_Health > _Max_Health:
		_Current_Health = _Max_Health
	
func _check_for_death()->bool:
	if _Current_Health <= 0:
		return true
	return false

#######################
###### Location #######
#######################
func update_locations_visited(loc_name):
	if !list_of_places_visited.has(loc_name):
		list_of_places_visited.append(loc_name)
	
func update_door_unlocked(location,door_num):
	if doors_unlocked.has(location):
		doors_unlocked[location][door_num] = true
	else:
		doors_unlocked[location] = {door_num:true}
	

#################################################################
########## Dialog                       Branch ##################
#################################################################

const _dialog_tree = {}
const _dialog_choices = {}
enum DIALOG{LEVEL,TRIGGER,EXPERIENCED,CHOICES}

func update_dialog(dialogLevel,dialogTrigger,experienced:bool,choices:Array = []):
	if !_dialog_tree.keys().has(dialogLevel):
		_dialog_tree[dialogLevel] = {dialogTrigger:{DIALOG.EXPERIENCED :experienced,DIALOG.CHOICES: choices}}
	elif !_dialog_tree[dialogLevel].keys().has(dialogTrigger):
		_dialog_tree[dialogLevel] = {dialogTrigger:{DIALOG.EXPERIENCED :experienced,DIALOG.CHOICES: choices}}
	else:
		_dialog_tree[dialogLevel][dialogTrigger][DIALOG.EXPERIENCED] = experienced
		_dialog_tree[dialogLevel][dialogTrigger][DIALOG.CHOICES] =  choices
		
func get_choices(dialogLevel,dialogTrigger)->Array:
	if does_dialog_exist(dialogLevel,dialogTrigger):
			return _dialog_tree[dialogLevel][dialogTrigger][DIALOG.CHOICES]
	return []


func was_dialog_playerd(dialogLevel,dialogTrigger)->bool:
	if does_dialog_exist(dialogLevel,dialogTrigger):
		return _dialog_tree[dialogLevel][dialogTrigger][DIALOG.EXPERIENCED]
	return false

func does_dialog_exist(dialogLevel,dialogTrigger)->bool:
	if _dialog_tree.keys().has(dialogLevel):
		if _dialog_tree[dialogLevel].keys().has(dialogTrigger):
			return true
	return false


