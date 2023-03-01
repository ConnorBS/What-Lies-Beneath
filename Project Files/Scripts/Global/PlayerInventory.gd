extends Node


enum GUNTYPES {NONE,PISTOL,SHOTGUN,RIFLE}
const SYRINGE_LIST = ["Small Plant","Medium Sized Plant","Large Sized Plant"] #Weakest -> Strongest

onready var equipped_gun_type = GUNTYPES.NONE

###### Inventory ######
var _equipped_gun:Inventory.Items
const _inventory:Dictionary = {}
const _key_items:Dictionary = {}
const _map_fragments:Dictionary = {}
#const _locations:Dictionary = {}


var _weapon_table = {"Pistol":GUNTYPES.PISTOL,"Shotgun":GUNTYPES.SHOTGUN}
var _equipped_melee_weapon

func get_save_state()-> Dictionary:
	
	return {
		"_inventory":summarize(_inventory),
		"_key_items":summarize(_key_items),
		"_map_fragments": summarize(_map_fragments),
#		"_locations":summarize(_locations),
		"_journal_Pages":summarize(_journal_Pages),
		"_equipped_gun":("" if _equipped_gun == null else _equipped_gun.name),
		"equipped_gun_type":equipped_gun_type,
#		"_equipped_melee_weapon":(null if _equipped_melee_weapon == null else{_equipped_melee_weapon.name:_equipped_melee_weapon.unlocked}),
		"current_Page" :current_Page
		
	}
func update_melee_weapon():
	for items in get_key_list():
		if items.name == "Crowbar":
			if items.unlocked:
				_equipped_melee_weapon = items
	
func write_load_state(load_data:Dictionary)->void:
	var tables_to_load = [_inventory, _key_items, _map_fragments]#, _locations]
	unequip() ##Clear weapons
	for table in tables_to_load:
		clear_dictionary(table)
	
	if !load_data.empty():
		write_new_const_dict(_inventory, load_data["_inventory"])
		write_new_const_dict(_key_items, load_data["_key_items"])
		write_new_const_dict(_map_fragments, load_data["_map_fragments"])
#		write_new_const_dict(_locations, load_data["_locations"])

		#_equipped_gun =#
		equip(find_weapon_in_inventory(load_data["_equipped_gun"]))
		equipped_gun_type = load_data["equipped_gun_type"]
#		_equipped_melee_weapon = null if load_data["_equipped_melee_weapon"].has(load_data["_equipped_melee_weapon"].keys()[0]) else _key_items["Item"][load_data["_equipped_melee_weapon"].keys()[0]]
		current_Page = load_data["current_Page"]
		update_melee_weapon()
	pass

func summarize(dictionary_to_summarize)->Dictionary:
	var summary = {}
	if typeof(dictionary_to_summarize) == TYPE_DICTIONARY:
		var is_inventory = dictionary_to_summarize == _inventory
		var is_key_item = dictionary_to_summarize == _key_items
		var is_map = dictionary_to_summarize == _map_fragments
	#	var is_journal = dictionary_to_summarize == _journal_Pages
		if is_key_item:
			summary["Key"] = {}
			summary["Item"] = {}
			for keys in dictionary_to_summarize["Key"]:
				summary["Key"][int(dictionary_to_summarize["Key"][keys].slot)] = dictionary_to_summarize["Key"][keys].unlocked
			for keys in dictionary_to_summarize["Item"]:
				summary["Item"][int(dictionary_to_summarize["Item"][keys].slot)] = dictionary_to_summarize["Item"][keys].unlocked
		elif is_map:
			for keys in dictionary_to_summarize:
				summary[dictionary_to_summarize[keys].name] = dictionary_to_summarize[keys].unlocked
		

		elif is_inventory:
			for keys in dictionary_to_summarize:
				if is_inventory:
					summary[dictionary_to_summarize[keys].name]=dictionary_to_summarize[keys].quantity
				else:
					summary[dictionary_to_summarize[keys].name]=1
			##Add Gun
			if _equipped_gun != null:
				summary[_equipped_gun.name] =_equipped_gun.quantity
	else:
		for i in dictionary_to_summarize.size():
			summary[i] = {"pageName":dictionary_to_summarize[i].pageName,"pageNumber":dictionary_to_summarize[i].pageNumber,"audioFile":dictionary_to_summarize[i].audioFile}
	
	return summary
	


static func clear_dictionary (dict_to_clear:Dictionary):
#	var keys = dict_to_clear.keys()
#	for key in keys:
	dict_to_clear.clear()

func write_new_const_dict(old_dict, new_dict):
	var keys = new_dict.keys()
	if old_dict == _inventory:
		for i in keys.size():
			var item = InventoryLists._duplicate_item(keys[i])
			item.quantity = new_dict[keys[i]]
			old_dict[i] = item
			
	elif old_dict == _key_items:
#		print("old keyitem dictionary: ",old_dict)
		_key_items["Key"] = {}
		_key_items["Item"]= {}
		for key in keys:
			for itemKey in new_dict[key]:
				var keyItem_Object = InventoryLists.get_KeyItem_by_slot(int(itemKey)) if key=="Item" else InventoryLists.get_Key_by_slot(int(itemKey))
				keyItem_Object.unlocked = new_dict[key][itemKey]
				_key_items[key][int(itemKey)] = keyItem_Object
#		print("key_items: ",_key_items)
		
	elif old_dict == _map_fragments:
		for key in keys:
			var map = InventoryLists.get_MapFragmenets(key)
			map.unlocked = new_dict[key]
			_map_fragments[key]=map

		
	else:##Journal pages
		for key in keys:
			var journalPage = Inventory.JournalPage.new()
			journalPage.audioFile = new_dict[key]["audioFile"]
			journalPage.pageName = new_dict[key]["pageName"]
			journalPage.pageNumber = new_dict[key]["pageNumber"]
			_journal_Pages.append(journalPage)
func _ready():
	#############
#	Load Items
	#############
	_load_base_KeyItems()
	InventoryLists.load_Inventory_Types()
	_load_base_MapFragments()
	
	###################
	##Troubleshooting##
	###################
	var journalPage = Inventory.JournalPage.new()
	journalPage.pageNumber = 1
	journalPage.audioFile = "res://Dialog/Journal Pages/Journal Page1.wav"
	add_journal_Page(journalPage)
	
	journalPage = Inventory.JournalPage.new()
	journalPage.pageNumber = 2
	add_journal_Page(journalPage)
	pickup_KeyItem(InventoryLists.KeyItems["Item"][3])
	
	pass

func use_gun():
	if _equipped_gun != null:
		return _equipped_gun.use_item()
	return false

func get_gun():
	if _equipped_gun !=null:
		return _equipped_gun
	return false
	
func get_gun_damage() -> int:
	if _equipped_gun != null:
		return _equipped_gun.value
	return 0

func gun_has_ammo_loaded() -> bool:
	if _equipped_gun != null:
		return _equipped_gun.quantity > 0
	return false

func get_melee_damage() -> int:
	if _equipped_melee_weapon != null:
		return 4
	return 0

func get_melee_weapon():
	return _equipped_melee_weapon
	
###########################
#### Player Inventory #####
###########################

##### Add Items ######

func add_item(item):
	if item.is_type("Inventory.Items"):
		if item.stackable:
			### Checks to see if it can add to the existing inventory
			
			### If it can add to an existing, and doesn't need another slot
			### adds to inventory, and removes item
			
			### Otherwise, will take the new remaining total, and adds to the 
			### _inventorys list
			var list_of_matching_items = _get_player_inventory_list_of_matching_items_by_name(item.name)
			if !list_of_matching_items.empty():
				var count_to_add = item.quantity
				for existing_item in list_of_matching_items:
					var room_to_add = existing_item.max_quantity - existing_item.quantity
					if count_to_add <= room_to_add:
						existing_item.quantity += count_to_add
						count_to_add = 0
						item.is_queued_for_deletion()
						return ### Will Occur and Quit Function when nothing more To Add
					else:
						count_to_add -= room_to_add
						existing_item.quantity = existing_item.max_quantity
				###Program to continue if there is still more of that item, after topping up all other items
				item.quantity = count_to_add
				if item.weapon:
					var ammo_box = InventoryLists.get_item(item.reload_to)
					ammo_box.quantity = item.quantity
					add_item(ammo_box)
				else:
					_add_item_to_inventory(item,_inventory)
			else:
				_add_item_to_inventory(item,_inventory)
		else:
			_add_item_to_inventory(item,_inventory)
	elif item.is_type("Inventory.KeyItems"):
			_add_item_to_inventory(item,_key_items)
#	elif item.is_type("Inventory.Locations"):
#			_add_item_to_inventory(item,_locations)
	
static func _add_item_to_inventory(item,inventoryType:Dictionary = _inventory):
	if inventoryType.empty():
		inventoryType[0] = item
	else:
		var find_next_unique_key = 0
		for i in inventoryType.keys():
			if i > find_next_unique_key:
				find_next_unique_key = i
		find_next_unique_key += 1
		inventoryType[find_next_unique_key] = item

#### Use Items ####

###Not Used
func use_item(item): ###Use 1x Item
	if item.is_type("Inventory.Items"):
		if item.stackable:
			item.quantity -= 1
			if item.quantity <= 0:
				remove_item(item,_inventory)
		else:
			remove_item(item,_inventory)
	elif item.is_type("Inventory.KeyItems"):
			_add_item_to_inventory(item,_key_items)
#	elif item.is_type("Inventory.Locations"):
#			_add_item_to_inventory(item,_locations)

func equip(item):
	if item != null:
		var current_equipment = get_equiped_item()
		if current_equipment != null:
	#		add_item(current_equipment)
			unequip()
		_equipped_gun = item
		equipped_gun_type =_weapon_table[_equipped_gun.name]
		remove_item(_equipped_gun)

func unequip():
	var item_to_unequip = _equipped_gun
	_equipped_gun = null
	equipped_gun_type = GUNTYPES.NONE
	if item_to_unequip != null:
		add_item(item_to_unequip)
		
	
func get_equiped_item()->Inventory.Items:
	return _equipped_gun
	
func get_weapon_type(gunTypeInt:int)-> String:
	var gunTypeString =""
	for key in _weapon_table.keys():
		if _weapon_table[key] == gunTypeInt:
			return key
	return gunTypeString 
	
static func remove_item (item,inventoryType:Dictionary = _inventory)->void:
	var key_to_remove = _get_key_of_item(item,inventoryType)
	if key_to_remove == -1:
		push_warning("Trying to delete an item: "+item.name+" that doesn't exist in _inventory")
	else:
		
		var _item_deleted = inventoryType.erase(key_to_remove)

func remove_one_item(item:Inventory.Items,qnty=1,inventoryType:Dictionary = _inventory):
	item.quantity -=1
	if item.quantity <= 0:
		remove_item(item,inventoryType)
	
func reload_item(item):
	var reload_to_item_in_inventory = _get_player_inventory_list_of_matching_items_by_name(item.reload_to,_inventory)
	var item_in_equipment = get_equiped_item()
	if  !reload_to_item_in_inventory.empty() or (item_in_equipment != null and get_equiped_item().name == item.reload_to):
		var gun_to_reload:Array
		var ammo_to_use:Array
		if item.use == "Reload":
			gun_to_reload = (reload_to_item_in_inventory if !reload_to_item_in_inventory.empty() else [get_equiped_item()])
			ammo_to_use = _get_player_inventory_list_of_matching_items_by_name(item.name,_inventory)
		else:
			gun_to_reload =  _get_player_inventory_list_of_matching_items_by_name(item.name,_inventory)
			ammo_to_use = (reload_to_item_in_inventory if !reload_to_item_in_inventory.empty() else get_equiped_item())
		for gun_reloading in gun_to_reload:
			if gun_reloading.max_quantity - gun_reloading.quantity > 0:
				while gun_reloading.quantity < gun_reloading.max_quantity and !ammo_to_use.empty():
					gun_reloading.quantity += 1
					ammo_to_use[0].quantity -= 1
					if ammo_to_use[0].quantity <= 0:
						remove_item(ammo_to_use.pop_front(),_inventory)
		return true
	return false
						
						
	
#### Dictionary Searches ####
func _get_player_inventory_list_of_matching_items_by_name(name_to_check:String,inventoryType:Dictionary = _inventory)->Array:
	var list_of_items = []
	if !inventoryType.empty():
		for i in _inventory.keys():
			if inventoryType[i].name == name_to_check:
				list_of_items.append(inventoryType[i])
	if _equipped_gun != null:
		if _equipped_gun.name == name_to_check:
			list_of_items.append(_equipped_gun)
	return list_of_items

static func _get_key_of_item(item,inventoryType:Dictionary = _inventory)->int:
	if !inventoryType.empty():
		for keyCheck in inventoryType.keys():
			if item == inventoryType[keyCheck]:
				return keyCheck
	return -1 ## Indicates nothing was found

static func get_list_of_inventory()->Array:
	var listOfItems = []
	var listOfKeys = _inventory.keys()
	listOfKeys.sort()
	for i in listOfKeys:
		listOfItems.append(_inventory[i])
	return listOfItems

static func find_weapon_in_inventory(name):
	if name != null or name != "":
		for key in _inventory:
			if _inventory[key].name == name:
				return _inventory[key]
	return null
###########################
##### Memo Inventory #####
###########################

const _journal_Pages:Array = [];
var current_Page = 0

func add_journal_Page(new_journal_page:Inventory.JournalPage):
	if !_journal_Pages.has(new_journal_page):
		_journal_Pages.append(new_journal_page)
		set_current_to_recent_page()


func set_current_to_recent_page():
	current_Page = _journal_Pages.size()-1
	return _journal_Pages[current_Page]


func get_current_journal_Page():
	if _journal_Pages.size() - 1 >= current_Page:
		return _journal_Pages[current_Page]
	return null

func get_next_journal_Pages ():
	if current_Page + 1 <= _journal_Pages.size():
		current_Page += 1
		return _journal_Pages[current_Page]
	return null

func get_previous_journal_Pages ():
	if current_Page - 1 >= 0:
		current_Page -= 1
		return _journal_Pages[current_Page]
	return null

func is_there_another_page()->bool:
	if current_Page == _journal_Pages.size() - 1:
		return false
	return true
	
func is_this_the_first_page()->bool:
	if current_Page == 0:
		return true
	return false


###########################
#### Player KeyItems #####
###########################

func _load_base_KeyItems()->void:
	var baseKeys = InventoryLists.load_KeyItems()
	_key_items["Key"] = baseKeys["Key"]
	_key_items["Item"] = baseKeys["Item"]

static func get_key_list()->Array:
	var keyList:Array = []
	for key in _key_items["Key"].keys():
		keyList.append(_key_items["Key"][key])
	return keyList

static func get_item_list()->Array:
	var keyItemList:Array = []
	for item in _key_items["Item"].keys():
		keyItemList.append(_key_items["Item"][item])
	return keyItemList

func pickup_KeyItem(item:Inventory.KeyItems)->void:
#	print(_key_items)
#	print (_key_items[item.type])
#	print(item.slot," is part of the dictionary? ",_key_items[item.type].has(item.slot))
#	print(1," just the number is part of the dictionary? ",_key_items[item.type].has(1))
#	print("1"," just the string is part of the dictionary? ",_key_items[item.type].has("1"))
	_key_items[item.type][item.slot].unlocked = true
	if item == InventoryLists.KeyItems["Item"][3]:
		_equipped_melee_weapon = item

static func has_KeyItem(item_name)->bool:
	for key in get_key_list():
		if key.name == item_name:
			return key.unlocked
	for item in get_item_list():
		if item.name == item_name:
			return item.unlocked
	return false

###########################
####   Player Maps    #####
###########################
func _load_base_MapFragments() -> void:
	var base_map_fragments = InventoryLists.load_MapFragments()
	for map_names in base_map_fragments.keys():
		_map_fragments[map_names] = base_map_fragments[map_names]
		
func collect_MapFragment(map_fragment:String):
	if _map_fragments.keys().has(map_fragment):
		_map_fragments[map_fragment].unlocked = true


func has_map(level) -> bool:
	for map_name in _map_fragments.keys():
		if _map_fragments[map_name].unlocked:
			for map in _map_fragments[map_name].maps_unlocked:
				if map == level:
					return true
	return false


###########################
####   Syringe Logic  #####
###########################

func use_syringe()->void:
	var syringe = find_best_syringe()
	if syringe != null:
#		print ("Using Item: ",syringe.name)
		syringe.use_item()
		
func find_best_syringe()->Inventory:
	var syringe_array:Array = get_list_of_syringes()
	if !syringe_array.empty():
		var total_missing_health = PlayerState.get_Player_Max_Health()-PlayerState.get_Player_Health()
		var syringe_to_use = null
		for syringe_to_check in range(syringe_array.size()-1,-1,-1):
			if syringe_array[syringe_to_check].value <= total_missing_health:
				return syringe_array[syringe_to_check]
			elif syringe_to_use == null or syringe_to_use.name != syringe_array[syringe_to_check].name:
				syringe_to_use = syringe_array[syringe_to_check]
		return syringe_to_use
	return null

func get_list_of_syringes()->Array:
	var list_of_arrays = []
	for itemName in SYRINGE_LIST:
		list_of_arrays+= _get_player_inventory_list_of_matching_items_by_name(itemName)
	return list_of_arrays
	
