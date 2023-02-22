extends Node

const _dictionary_of_dialogs:Dictionary = {}
var _table_of_dialog_location = "res://Dialog/Table-Of-Dialog.csv"
func dialog_to_load():
	return ("res://Dialog/GasStation/GasStationEntrance.txt")

func get_dialog(level_name:String,trigger_name:String)->String:
	return _dictionary_of_dialogs[level_name][trigger_name]

func _ready():
	load_dialog_directory()
#

func load_dialog_directory()->Dictionary:
	var file = File.new()
	file.open(_table_of_dialog_location, file.READ_WRITE)
	if file.get_error() == 0:
		var _headers = file.get_csv_line () ###removes the top line
		while !file.eof_reached():
			var csv = file.get_csv_line ()
			if !csv.empty():
				if csv[0] != "":
					var path = csv[2]
					if path == "":
						path = "res://Dialog/"+csv[0]+"/"+csv[0]+" "+csv[1]+".txt"
					var directory = Directory.new()
					if !directory.file_exists(path):
						push_error("Unable to find Dialog Directory in Table-Of-Dialog.csv "+csv[0]+" "+csv[1])
					var file_check = File.new()
					if !file_check.file_exists(path):
						push_error("Unable to find Dialog File in Table-Of-Dialog.csv - "+path)
					
					
					if !_dictionary_of_dialogs.keys().has(csv[0]):
						_dictionary_of_dialogs[csv[0]] = {csv[1]:path}
					else:
						_dictionary_of_dialogs[csv[0]][csv[1]] =path
					
	else:
		push_error("Could not find the Table-Of-Dialog.csv file")
	file.close()
	return _dictionary_of_dialogs

