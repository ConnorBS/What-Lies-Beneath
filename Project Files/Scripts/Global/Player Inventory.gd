extends Node


enum GUNTYPES {NONE,PISTOL,SHOTGUN,RIFLE}

onready var equipped_gun = GUNTYPES.PISTOL

###### Inventory ######
var _equipped_gun
const _inventory:Dictionary = {}
const _key_items:Dictionary = {}
const _map_fragments:Dictionary = {}
const _locations:Dictionary = {}

##Troubleshooting
func _ready():
	var journalPage = Inventory.JournalPage.new()
	journalPage.pageNumber = 1
	add_journal_Page(journalPage)
	
	journalPage = Inventory.JournalPage.new()
	journalPage.pageNumber = 2
	add_journal_Page(journalPage)

	pass


###########################
#### Player Inventory #####
###########################

##### Add Items ######

func add_item(item:Inventory):
	if item == Inventory.Items:
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
				_add_item_to_inventory(item,_inventory)
			_add_item_to_inventory(item,_inventory)
		else:
			_add_item_to_inventory(item,_inventory)
	elif item == Inventory.KeyItems:
			_add_item_to_inventory(item,_key_items)
	elif item == Inventory.MapFragments:
			_add_item_to_inventory(item,_map_fragments)
	elif item == Inventory.Locations:
			_add_item_to_inventory(item,_locations)
	
func _add_item_to_inventory(item:Inventory,inventoryType:Dictionary = _inventory):
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
func use_item(item:Inventory): ###Use 1x Item
	if item == Inventory.Items:
		if item.weapon == true:
			_equipped_gun = item
			return
		elif item.stackable:
			item.quantity -= 1
			if item.quantity <= 0:
				_remove_item(item,_inventory)
		else:
			_remove_item(item,_inventory)
	elif item == Inventory.KeyItems:
			_add_item_to_inventory(item,_key_items)
	elif item == Inventory.MapFragments:
			_add_item_to_inventory(item,_map_fragments)
	elif item == Inventory.Locations:
			_add_item_to_inventory(item,_locations)

func _remove_item (item:Inventory,inventoryType:Dictionary = _inventory)->void:
	var key_to_remove = _get_key_of_item(item,inventoryType)
	if key_to_remove == -1:
		push_warning("Trying to delete an item: "+item.name+" that doesn't exist in _inventory")
	else:
		inventoryType.erase(key_to_remove)

#### Dictionary Searches ####
func _get_player_inventory_list_of_matching_items_by_name(name_to_check:String)->Array:
	var list_of_items = []
	if !_inventory.empty():
		for i in _inventory.keys():
			if _inventory[i].name == name_to_check:
				list_of_items.appoend(_inventory[i])
	return list_of_items

func _get_key_of_item(item:Inventory,inventoryType:Dictionary = _inventory)->int:
	if !inventoryType.empty():
		for keyCheck in inventoryType.keys():
			if item == inventoryType[keyCheck]:
				return keyCheck
	return -1 ## Indicates nothing was found

### Location Updates ###


#### Memo Inventory ####
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
