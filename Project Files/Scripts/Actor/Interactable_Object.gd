extends InteractableObjects
tool

export (String) var dialog_trigger:String
export (bool) var dialog_one_time_trigger = false
var dialog_trigger_count:int = 0

export (bool) var overhead_one_time_trigger = false
export (String) var overhead_text= ""
export (AudioStream) var overhead_voice_over = null
var overhead_trigger_count:int = 0

signal dialogWindow

export (Vector2) var scale_of_interactable_box = Vector2(1,1)

export (Array) var inventory_items_to_add
export (String) var key_item_to_add
export (String) var map_pieces_to_unlock
 
var _inventory_item_pickups:Array
var _key_item_pickup:Inventory.KeyItems
var _map_item_pickup


func _ready():
	self.texture = spriteToLoad
	change_collision_and_mask($Area2D,floor_placement+9,true)
	set_hitboxes_state(hitboxes_enabled)
	$Area2D/CollisionShape2D.scale = scale_of_interactable_box
	_inventory_item_pickups = make_inventory_items(inventory_items_to_add)
	_key_item_pickup = make_key_item(key_item_to_add)
	_map_item_pickup = make_map_item(map_pieces_to_unlock)
	
	load_pickup_state()
	#####

func make_inventory_items(inventory_list) -> Array:
	var new_inventory_list = []
	if inventory_list != null or !inventory_list.empty():
		for item in inventory_list:
			new_inventory_list.append(InventoryLists.get_item(item[0],item[1]))
	return new_inventory_list 

func make_key_item(new_key_item_name):
	return InventoryLists.get_KeyItem(new_key_item_name)

func make_map_item(new_map_fragment_name):
	return new_map_fragment_name

func load_pickup_state():
	if object_name != "" and scene_to_change_location == "":
		var load_data = _find_level_node().load_pickup_state_of_object_in_level(object_name)
		if !load_data.empty():
			_collected = load_data["collected"]
			overhead_trigger_count = load_data["overhead_trigger_count"]
			dialog_trigger_count = load_data["dialog_trigger_count"]
			
			if dialog_one_time_trigger and dialog_trigger_count > 0 :
				remove_interaction()
		else: ### If it's not in the save file, it should be, so adds current state into memory
			save_pickup_state()

func save_pickup_state():
	if object_name != "" and scene_to_change_location == "":
		var save_data = {
			"collected":_collected,
			"overhead_trigger_count":overhead_trigger_count,
			"dialog_trigger_count":dialog_trigger_count
			}
		
		_find_level_node().save_pickup_state_of_object_in_level(object_name,save_data)
		

func pickup_items():
	var text_array = ["You Found:"]
	
	if !_inventory_item_pickups.empty():
		for item in _inventory_item_pickups:
			PlayerInventory.add_item(item)
			text_array.append(str(item.quantity) +"x "+item.name)
	if _key_item_pickup != null:
		PlayerInventory.pickup_KeyItem(_key_item_pickup)
		text_array.append("The "+_key_item_pickup.name)
	if _map_item_pickup != null and _map_item_pickup != "":
		PlayerInventory.collect_MapFragment(_map_item_pickup)
		text_array.append("The "+_map_item_pickup+ " map fragment")
		
	_collected = true
	save_pickup_state()
	
	if text_array.size() > 1:
		_find_level_node()._on_open_dialogWindow_system_message(text_array)
func _process(_delta):
	if Engine.editor_hint:
		$Area2D/CollisionShape2D.scale = scale_of_interactable_box

func trigger_dialog():
	if dialog_trigger == "" or dialog_trigger == null:
		pass
	else:
		if dialog_one_time_trigger == false or dialog_trigger_count == 0:
			dialog_trigger_count += 1
			_find_level_node()._on_open_dialogWindow(dialog_trigger)
			if dialog_one_time_trigger:
				remove_interaction()
		else: 
			pass
	if _collected == false:
		pickup_items()

func remove_interaction():
	$Area2D.monitoring = false
	$Area2D.monitorable = false
	$Particles2D.emitting = false
	$Area2D.queue_free()
	$Particles2D.queue_free()
	
func has_overhead_text()->bool:
	return overhead_text != ""
	
func get_overhead_text():
	if overhead_one_time_trigger:
		if overhead_trigger_count <= 0:
			if overhead_text != "":
				_increase_overhead_trigger_count(1)
				return overhead_text
			return ""
		return ""
	else:
		if overhead_text != "":
			return overhead_text
		return ""

func _increase_overhead_trigger_count(num = 1):
	overhead_trigger_count += num
	save_pickup_state()
	
func overhead_voice_over() -> AudioStream:
	return overhead_voice_over
