extends Resource

class_name SaveAndLoad



static func save_game()-> void:
	
	var saveGame = File.new()
	saveGame.open("user://savegame.save", File.WRITE)
	
	var save_playerstate = PlayerState.get_save_state()
	var save_playerInventory = PlayerInventory.get_save_state()
	print (save_playerInventory)
	saveGame.store_line(to_json(PlayerState.get_save_state()))
	saveGame.store_line(to_json(PlayerInventory.get_save_state()))
	
	saveGame.close()
	pass

static func load_game()->void:
	
	var loadGame = File.new()
	if not loadGame.file_exists("user://savegame.save"):
		return
	loadGame.open("user://savegame.save",File.READ)
	print (loadGame.get_len())
	if !loadGame.eof_reached() and loadGame.get_len() > 1:
		PlayerState.write_load_state(parse_json(loadGame.get_line()))
		PlayerInventory.write_load_state(parse_json (loadGame.get_line()))
	
	pass