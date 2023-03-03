extends Node

static func is_there_a_saved_game()->bool:
	var check_for_save = File.new()
	if check_for_save.file_exists("user://savegame.save"):
		return true
	return false
	
func save_game()-> void:
	
	var saveGame = File.new()
	saveGame.open("user://savegame.save", File.WRITE)
	
	saveGame.store_line(to_json(PlayerState.get_save_state()))
	saveGame.store_line(to_json(PlayerInventory.get_save_state()))
	saveGame.close()
	pass

func load_game()->void:
	var loadGame = File.new()
	if not loadGame.file_exists("user://savegame.save"):
		return
	loadGame.open("user://savegame.save",File.READ)
	PlayerState.loading_from_file = true
	
	if !get_tree().root.has_node("GameScreen"):
		var _new_scene = get_tree().change_scene("res://Scenes/GameScreen.tscn")
	else:
		var loading_game_node = load(LevelDirectory.lookup_level(PlayerState._save_point_level)).instance()
#		
		get_tree().root.get_node("GameScreen")._on_change_scene(null, loading_game_node)

	if !loadGame.eof_reached() and loadGame.get_len() > 1:
		PlayerState.write_load_state(parse_json(loadGame.get_line()))
		PlayerInventory.write_load_state(parse_json (loadGame.get_line()))
	
	loadGame.close()
	pass

