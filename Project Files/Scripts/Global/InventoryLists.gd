extends Node

const KeyItems = {"Key":{},"Item":{}}
var KeyItemsListCSV = "res://Scripts/Global/KeyItemsCSV.csv"


#func _ready():
#	load_KeyItems()
	
func load_KeyItems()->Dictionary:
	var file = File.new()
	file.open(KeyItemsListCSV, file.READ)
	if file.get_error() == 0:
		file.get_csv_line() ###removes the top line
		while !file.eof_reached():
			var csv = file.get_csv_line ()
			if !csv.empty():
				if csv[0] != "":
					var new_item = Inventory.KeyItems.new()
					print(csv)
					new_item.slot = int(csv[0])
					new_item.name = csv[1]
					new_item.type = csv[2]
					new_item.unlocked = (csv[3] == "TRUE")
					new_item.description = csv[4]
					new_item.unkown_texture = csv[5]
					new_item.collected_texture = csv[6]
					if KeyItems[new_item.type].has(new_item.slot):
						push_warning("InventoryLists._load_KeyItems() has overwritten a KeyItems Dictionary Value")
					KeyItems[new_item.type][new_item.slot] = new_item
	file.close()
	return KeyItems
