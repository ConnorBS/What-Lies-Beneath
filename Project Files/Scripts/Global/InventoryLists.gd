extends Node

const KeyItems = {"Key":{},"Item":{}}
const MapFragments = {}
const Types = {}
var KeyItemsListCSV = "res://Scripts/Global/KeyItemsCSV.csv"
var InventoryTypeListCSV = "res://Scripts/Global/InventoryTypes.csv"
var MapFragmentListCSV = "res://Scripts/Global/MapFragments.csv"

###################################
######## Key Items ################
###################################
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
					new_item.slot = int(csv[0])
					new_item.name = csv[1]
					new_item.type = csv[2]
					new_item.unlocked = (csv[3] == "TRUE")
					new_item.description = csv[4]
					new_item.unkown_texture = csv[5]
					new_item.collected_texture = csv[6]
					if KeyItems[new_item.type].has(new_item.slot):
						push_warning("InventoryLists.load_KeyItems() has overwritten a KeyItems Dictionary Value")
					KeyItems[new_item.type][new_item.slot] = new_item
	file.close()
	print ("KeyItems: ",KeyItems)
	return KeyItems

func get_KeyItem(name_of_KeyItem):
	if name_of_KeyItem != null:
		for id in KeyItems["Key"]:
			if KeyItems["Key"][id].name == name_of_KeyItem:
				return KeyItems["Key"][id]
		for id in KeyItems["Item"]:
			if KeyItems["Item"][id].name == name_of_KeyItem:
				return KeyItems["Item"][id]
	return null

func get_Key_by_slot(slot_of_KeyItem:int):
	if slot_of_KeyItem != null:
		for id in KeyItems["Key"]:
			if KeyItems["Key"][id].slot == slot_of_KeyItem:
				return KeyItems["Key"][id]

func get_KeyItem_by_slot(slot_of_KeyItem:int):
	if slot_of_KeyItem != null:
		for id in KeyItems["Item"]:
			if KeyItems["Item"][id].slot == slot_of_KeyItem:
				return KeyItems["Item"][id]
	return null


###################################
######## Inventory Items ##########
###################################
func load_Inventory_Types ()->Dictionary:
	var file = File.new()
	file.open(InventoryTypeListCSV, file.READ)
	if file.get_error() == 0:
		file.get_csv_line() ###removes the top line
		while !file.eof_reached():
			var csv = file.get_csv_line ()
			if !csv.empty():
				if csv[0] != "":
					var new_item = Inventory.Items.new()
					new_item.name = csv[0]
					new_item.description = csv[1]
					new_item.use = csv[2]
					new_item.value = int(csv[3])
					new_item.max_quantity = int(csv[4])
					new_item.stackable = new_item.max_quantity > 1
					new_item.weapon = (csv[5] == "TRUE")
					new_item.texture = csv[6]
					new_item.reload_to = ("" if (csv[7] == "") else csv[7])
					new_item.combinableWith = ("" if (csv[8] == "") else csv[8])
					new_item.combinableTo = ("" if (csv[9] == "") else csv[9])
					if Types.keys().has(new_item.name):
						push_warning("InventoryLists.load_Inventory_Types has overwritten a Types Dictionary Value")
					Types[new_item.name] = new_item
	file.close()
	print("Types: ", Types)
	return Types

static func _duplicate_item(name_to_pull)->Inventory.Items:
	var item = Inventory.Items.new()
	if !Types.keys().has(name_to_pull):
		return null
	var dict_Item = Types[name_to_pull]
	item.name = dict_Item.name
	item.description = dict_Item.description
	item.use = dict_Item.use 
	item.value = dict_Item.value
	item.max_quantity = dict_Item.max_quantity
	item.stackable = dict_Item.stackable
	item.weapon = dict_Item.weapon
	item.texture = dict_Item.texture 
	item.reload_to = dict_Item.reload_to
	item.combinableWith = dict_Item.combinableWith
	item.combinableTo = dict_Item.combinableTo
	return item
	
static func get_item(name_to_pull,item_quantity = 1)->Inventory.Items:
	var item = _duplicate_item(name_to_pull)
	if item != null:
		item.quantity = item_quantity
	return item

###################################
######## Map Fragments ############
###################################
func load_MapFragments()->Dictionary:
	var file = File.new()
	file.open(MapFragmentListCSV, file.READ)
	if file.get_error() == 0:
		file.get_csv_line() ###removes the top line
		while !file.eof_reached():
			var csv = file.get_csv_line ()
			if !csv.empty():
				if csv[0] != "":
					var new_map = Inventory.MapFragments.new()
					for i in csv.size():
						if i == 0:
							new_map.name = csv[i]
						elif csv[i] != null and csv[i] != "":
							new_map.maps_unlocked.append(csv[i])
					
					
					if MapFragments.keys().has(new_map.name):
						push_warning("InventoryLists.load_MapFragments() has overwritten a MapFragments Dictionary Value")
					MapFragments[new_map.name] = new_map
	file.close()
	print ("MapFragments :",MapFragments)
	return MapFragments

static func get_MapFragmenets(name_of_map)->Inventory.MapFragments:
	var mapFragment:Inventory.MapFragments
	if MapFragments.has(name_of_map):
		mapFragment = MapFragments[name_of_map]
	
	return mapFragment
####################################
######## General ###################
####################################
#
#static func find_item_type(name_of_item)->String:
#	for item_name in Types:
#		if name_of_item == item_name:
#			return "Inventory.Items"
#	for key_name in KeyItems["Key"]:
#		if name_of_item == key_name:
#			return "Inventory.KeyItems"
#	for keyitem_name in KeyItems["Item"]:
#		if name_of_item == keyitem_name:
#			return "Inventory.KeyItems"
#	for map_name in MapFragments:
#		if name_of_item == map_name:
#			return "Inventory.MapFragments"
#	for item_name in Types:
#		if name_of_item == item_name:
#			return "Inventory.Items"
#
#
#	return ""
#
#
		
