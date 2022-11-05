extends Node


enum GUNTYPES {NONE,PISTOL,SHOTGUN,RIFLE}

onready var equipped_gun = GUNTYPES.PISTOL

###### Inventory ######
var _equipped_gun:Inventory.Items
const _inventory:Dictionary = {}
const _key_items:Dictionary = {}
const _map_fragments:Dictionary = {}
const _locations:Dictionary = {}


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
	
	
	pass


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
	elif item.is_type("Inventory.Locations"):
			_add_item_to_inventory(item,_locations)
	
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
	elif item.is_type("Inventory.Locations"):
			_add_item_to_inventory(item,_locations)

func equip(item):
	var current_equipment = get_equiped_item()
	if current_equipment != null:
		add_item(current_equipment)
	_equipped_gun = item
	remove_item(_equipped_gun)

func unequip():
	var item_to_unequip = _equipped_gun
	_equipped_gun = null
	add_item(item_to_unequip)
	
func get_equiped_item()->Inventory.Items:
	return _equipped_gun
	
	
static func remove_item (item,inventoryType:Dictionary = _inventory)->void:
	var key_to_remove = _get_key_of_item(item,inventoryType)
	if key_to_remove == -1:
		push_warning("Trying to delete an item: "+item.name+" that doesn't exist in _inventory")
	else:
		
		var _item_deleted = inventoryType.erase(key_to_remove)

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
	var keyList:Array = []
	for item in _key_items["Item"].keys():
		keyList.append(_key_items["Item"][item])
	return keyList

static func pickup_KeyItem(item:Inventory.KeyItems)->void:
	_key_items[item.type][item.slot].unlocked = true
	

###########################
#### Player KeyItems #####
###########################
func _load_base_MapFragments() -> void:
	var base_map_fragments = InventoryLists.load_MapFragemnts()
	for map_names in base_map_fragments.keys():
		_map_fragments[map_names] = base_map_fragments[map_names]
		
func collect_MapFragment(map_fragment:String):
	if _map_fragments.keys().has(map_fragment):
		_map_fragments[map_fragment].collected = true


func has_map(level) -> bool:
	for map_name in _map_fragments.keys():
		if _map_fragments[map_name].collected:
			for map in _map_fragments[map_name].maps_unlocked:
				if map == level:
					return true
	return false
