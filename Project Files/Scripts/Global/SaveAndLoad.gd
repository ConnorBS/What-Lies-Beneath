extends Node

static func is_there_a_saved_game()->bool:
	var check_for_save = File.new()
	if check_for_save.file_exists("user://savegame.save"):
		return true
	return false
	
func save_game()-> void:
	
	var saveGame = File.new()
	saveGame.open("user://savegame.save", File.WRITE)
	
	var save_playerstate = PlayerState.get_save_state()
	var save_playerInventory = PlayerInventory.get_save_state()
	print (save_playerInventory)
	saveGame.store_line(to_json(PlayerState.get_save_state()))
	saveGame.store_line(to_json(PlayerInventory.get_save_state()))
	saveGame.close()
	pass

func load_game()->void:
	var loadGame = File.new()
	if not loadGame.file_exists("user://savegame.save"):
		return
	loadGame.open("user://savegame.save",File.READ)
	print (loadGame.get_len())
	PlayerState.loading_from_file = true
	
	if get_tree().root.get_node("GameScreen") == null:
		get_tree().change_scene("res://Scenes/GameScreen.tscn")
	else:
		var loading_game_node = load(LevelDirectory.lookup_level(PlayerState._current_level)).instance()
#		print (loading_game_node)
		loading_game_node
		get_tree().root.get_node("GameScreen")._on_change_scene(null, loading_game_node)

#	print_Nodes()
#	var current_game_node = get_node("/root/GameScreen/MainMenu/GameWindowPanel/ViewportContainer/Viewport").get_child(0)
#
#	var loading_game_node = load(LevelDirectory.lookup_level(PlayerState._current_level)).instance()
#	get_tree().root.find_node("GameScreen")._on_change_scene(current_game_node,loading_game_node)
#
	if !loadGame.eof_reached() and loadGame.get_len() > 1:
		PlayerState.write_load_state(parse_json(loadGame.get_line()))
		PlayerInventory.write_load_state(parse_json (loadGame.get_line()))
	
	loadGame.close()
	pass


func print_Nodes(current_node= get_tree().root,string_placeholder = "-"):
	for i in current_node.get_child_count():
		print (string_placeholder+current_node.get_child(i).name+"  "+str(i)+" ("+current_node.get_child(i).get_path()+")")
		print_Nodes(current_node.get_child(i),string_placeholder+"-")
		
