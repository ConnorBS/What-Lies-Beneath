extends Node

const _dictionary_of_dialogs:Dictionary = {}
var _table_of_dialog_location = "res://Dialog/TableOfDialog.csv"
func dialog_to_load():
	return ("res://Dialog/GasStation/GasStationEntrance.txt")

func get_dialog(level_name:String,trigger_name:String)->String:
	return _dictionary_of_dialogs[level_name][trigger_name]

func _ready():
	load_dialog_directory()
	print ("Dialog loaded: ",_dictionary_of_dialogs)
#

func load_dialog_directory():
	var file = File.new()
	file.open(_table_of_dialog_location, file.READ)
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
						print("Unable to find Dialog Directory in TableOfDialog.csv "+csv[0]+" "+csv[1])
					var file_check = File.new()
					if !file_check.file_exists(path):
						print ("Unable to find Dialog File in TableOfDialog.csv - "+path)
					
					
					if !_dictionary_of_dialogs.keys().has(csv[0]):
						_dictionary_of_dialogs[csv[0]] = {csv[1]:path}
					else:
						_dictionary_of_dialogs[csv[0]][csv[1]] =path
					
	else:
		print(file.get_error())
		print("Could not find the TableOfDialog.csv file")
	file.close()
#	return _dictionary_of_dialogs

