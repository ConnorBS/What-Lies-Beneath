extends Node

###########################
######## Variables ########
###########################
export var _Player_ACTIVE:bool = true
export var Spawn_Point:int = 3
var loading_from_file = false
var player_position:Vector2
export var _current_level:String = "Outside Gas Station" #Default/NewGame
export var _player_name:String = "Ethan" #Default/Newgame
export var doors_unlocked = {}
export var item_pickups = {}
export var enemy_state = {}
export var list_of_places_visited = []
###### Health ######
export var _Max_Health = 100
export var _Current_Health:int = 100

signal player_died

#################################################
######   Save / Load Functions ##################
#################################################

func get_save_state()-> Dictionary:
	
	return {
		"doors_unlocked":doors_unlocked,
		"item_pickups":item_pickups,
		"enemy_state": enemy_state,
		"list_of_places_visited":list_of_places_visited,
		
		"_Max_Health":_Max_Health,
		"_Current_Health":_Current_Health,
		
		"_Player_ACTIVE": _Player_ACTIVE,
		"Spawn_Point":Spawn_Point,
		"_current_level":_current_level,
		"_player_name":_player_name,
		"player_position.x":player_position.x,
		"player_position.y":player_position.y
		
	}
func write_load_state(load_data:Dictionary)->void:
	var tables_to_load = [doors_unlocked, item_pickups, enemy_state, list_of_places_visited]
	for table in tables_to_load:
		table.clear()
		
	if !load_data.empty():
		write_new_const_dict(doors_unlocked, load_data["doors_unlocked"])
		write_new_const_dict(item_pickups, load_data["item_pickups"])
		write_new_const_dict(enemy_state, load_data["enemy_state"])
		for item in load_data["list_of_places_visited"]:
			list_of_places_visited.append(item)
			
		_Max_Health = load_data["_Max_Health"]
		_Current_Health = load_data["_Current_Health"]
		
		_Player_ACTIVE = load_data["_Player_ACTIVE"]
		Spawn_Point = load_data["Spawn_Point"]
		_current_level = load_data["_current_level"]
		_player_name = load_data["_player_name"]
		player_position.x = load_data["player_position.x"]
		player_position.y = load_data["player_position.y"]
	pass


func write_new_const_dict(old_dict, new_dict):
	var keys = new_dict.keys()
	for key in keys:
		old_dict[key] = new_dict[key]
	
	
################################################
	
	
func get_player_name()->String:
	return _player_name
func update_player_position(new_position):
	player_position = new_position
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
		emit_signal("player_died")
		pass
	elif _Current_Health >_Max_Health:
		_Current_Health = _Max_Health

func get_Player_Health()->int:
	return _Current_Health
func get_Player_Max_Health()->int:
	return _Max_Health

func receive_damage(value):
	set_Player_Health(_Current_Health - value)
	
func heal(value:int)->void:
	print ("Healing for ", value, " | Current Health = ",_Current_Health, " to:")
	set_Player_Health(_Current_Health + value)
	print (_Current_Health,"/",_Max_Health)
	
func _check_for_death()->bool:
	if _Current_Health <= 0:
		print ("DEAD")
		return true
	return false

#######################
###### Location #######
#######################
func set_current_level (new_level):
	_current_level = new_level
	update_locations_visited(new_level)
	
func get_current_level ():
	return _current_level
	
func update_locations_visited(loc_name):
	if !list_of_places_visited.has(loc_name):
		list_of_places_visited.append(loc_name)
	
func update_door_unlocked(location,door_num):
	if doors_unlocked.has(location):
		doors_unlocked[location][door_num] = true
	else:
		doors_unlocked[location] = {door_num:true}
	
func has_location_been_visited(location)->bool:
	return list_of_places_visited.has(location)
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
		_dialog_tree[dialogLevel][dialogTrigger] ={ DIALOG.EXPERIENCED :experienced,DIALOG.CHOICES: choices}
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


#################################################################
##########           Item Pickups              ##################
#################################################################

#item_pickups
func save_item_pickup (level_name:String,object_name:String,save_data:Dictionary) -> void:
	if !item_pickups.empty():
		if item_pickups.has(level_name):
			item_pickups[level_name][object_name] = save_data
		else:
			item_pickups[level_name] ={object_name:save_data}
	else:
		item_pickups[level_name] ={object_name:save_data}
func load_item_pickup (level_name:String,object_name:String) -> Dictionary:
	var save_data:Dictionary = {}
	if !item_pickups.empty():
		if item_pickups.has(level_name):
			if item_pickups[level_name].has(object_name):
				for type in item_pickups[level_name][object_name].keys():
					save_data[type] = item_pickups[level_name][object_name][type]
	return save_data
	
func check_all_item_pickups_in_level(level_name) -> bool:
	if item_pickups.has(level_name):
		for object_name in item_pickups[level_name].keys():
			if item_pickups[level_name][object_name]["collected"] == false:
				return false
	
	return true

####################################################################
################  Enemy Saving State                ################
####################################################################


#item_pickups
func save_enemy_state (level_name:String,object_name:String,save_data:Dictionary) -> void:
	if !enemy_state.empty():
		if enemy_state.has(level_name):
			enemy_state[level_name][object_name] = save_data
		else:
			enemy_state[level_name] ={object_name:save_data}
	else:
		enemy_state[level_name] ={object_name:save_data}
func load_enemy_state (level_name:String,object_name:String) -> Dictionary:
	var save_data:Dictionary = {}
	if !enemy_state.empty():
		if enemy_state.has(level_name):
			if enemy_state[level_name].has(object_name):
				for type in enemy_state[level_name][object_name].keys():
					save_data[type] = enemy_state[level_name][object_name][type]
	return save_data
