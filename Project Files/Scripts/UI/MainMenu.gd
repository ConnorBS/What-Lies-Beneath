extends CanvasLayer

signal Map
signal Memo
signal KeyItems
signal Options

onready var _itemRowNode = $MarginContainer/VBoxContainer/ItemRow

onready var _itemScrollButtons = $ItemScrollButtonMarginContainer

onready var _itemNameLabel = $MarginContainer/VBoxContainer/ItemDescription/DescriptionPanel/VBoxContainer/ItemName
onready var _itemDescriptionLabel = $MarginContainer/VBoxContainer/ItemDescription/DescriptionPanel/VBoxContainer/CenterContainer/ItemDescriptionRichText
var item_hover_over = 0
var item_list:Array = []
var _noInventoryNode:Label = null
func _on_Map_pressed():
	emit_signal("Map")
	pass # Replace with function body.


func _on_Memo_pressed():
	emit_signal("Memo")
	pass # Replace with function body.


func _on_KeyItems_pressed():
	emit_signal("KeyItems")
	pass # Replace with function body.


func _on_Options_pressed():
	emit_signal("Options")
	pass # Replace with function body.

func update_Item_Scroll_position(value)->void:
	item_hover_over += value
	if value > 0:
		if item_hover_over >= item_list.size():
			item_hover_over = 0
		update_inventory_scroll()
#		_itemRowNode.move_child(_itemRowNode.get_child(0),_itemRowNode.get_child_count()-1)
	elif value < 0:
		if item_hover_over < 0:
			item_hover_over = item_list.size()-1
		update_inventory_scroll()
	if item_list.size() == 0:
		item_hover_over = 0
#		_itemRowNode.move_child(_itemRowNode.get_child(_itemRowNode.get_child_count()-1),0)

	pass
	
func _disable_buttons(state=true)->void:
	if state:
		_itemScrollButtons.hide()
	else:
		_itemScrollButtons.show()

func _on_Item_Scroll_Previous_pressed():
	get_parent().click_success()
	update_Item_Scroll_position(-1)
	
func _on_Item_Scroll_Next_pressed():
	get_parent().click_success()
	update_Item_Scroll_position(1)
	pass # Replace with function body.

func update_inventory_scroll()->void:
	item_list = PlayerInventory.get_list_of_inventory()
	var count = 0
	_clear_inventory()
	if item_list.size() == 0:
		_no_inventory(true)
		_disable_buttons(true)
		update_text(null)
		return
	elif item_list.size() == 1:
		
		_no_inventory(false)
		_disable_buttons(true)
#		_itemRowNode.get_child(2).update_item(item_list[0])
	else:
		_no_inventory(false)
		_disable_buttons(false)
	var item_to_display = _find_Items_to_display(item_hover_over)
	for i in _itemRowNode.get_child_count():
		if item_to_display[i] == null:
			_itemRowNode.get_child(i).update_item(null)
		else:
			_itemRowNode.get_child(i).update_item(item_list[item_to_display[i]])
	
	update_text(_itemRowNode.get_child(2).item)
	

func update_text (item_to_use:Inventory.Items)->void:
	if item_to_use == null:
		_itemNameLabel.text = ""
		_itemDescriptionLabel.bbcode_text = ""
	else:
		_itemNameLabel.text = item_to_use.name
		_itemDescriptionLabel.bbcode_text = item_to_use.description
	
func _find_Items_to_display(center_Loc)->Array:
	var items_to_display = []
	var item_list_size = item_list.size() 
	if item_list_size > center_Loc:
		items_to_display.append(center_Loc)
		var rightSide = center_Loc + 1
		var did_it_cycle = false
		for i in range (0,2,1):
			if rightSide >= item_list_size:
				rightSide = 0
				did_it_cycle = true
			if !items_to_display.has(rightSide):
				if (item_list_size == 3 and i == 1):
					items_to_display.append(null)
				else: 
					items_to_display.append(rightSide)
			else:
				items_to_display.append(null)
				
			rightSide += 1
		var leftSide = center_Loc-1
		for i in range (0,2,1):
			if leftSide < 0:
				leftSide = item_list_size-1
			if i >= 1:
				if !items_to_display.has(leftSide) or item_list_size > 3:
					items_to_display.push_front(leftSide)
				else:
					items_to_display.push_front(null)
			else:
				if leftSide == center_Loc:
					items_to_display.push_front(null)
				else:
					items_to_display.push_front(leftSide)
			leftSide -= 1
	else: return [null,null,null,null,null]
	return items_to_display
func _clear_inventory()->void:
	for i in _itemRowNode.get_child_count()-1:
		_itemRowNode.get_child(i).update_item(null)


func _on_Remove_pressed():
	if !item_list.empty():
		PlayerInventory.remove_item(item_list[item_hover_over])
		item_list = PlayerInventory.get_list_of_inventory()
		update_Item_Scroll_position(-1)
	
func _no_inventory(state)->void:
	if state and _noInventoryNode == null:
		for node in _itemRowNode.get_children():
			node.hide()
		_noInventoryNode = Label.new()
		_noInventoryNode.text = "No Inventory"
		_noInventoryNode.align = _noInventoryNode.ALIGN_CENTER
		_noInventoryNode.valign = _noInventoryNode.VALIGN_CENTER
		_noInventoryNode.size_flags_horizontal = _noInventoryNode.SIZE_EXPAND_FILL
		_itemRowNode.add_child(_noInventoryNode)
	elif state == false and _noInventoryNode != null:
		_itemRowNode.remove_child(_noInventoryNode)
		_noInventoryNode.queue_free()
		for node in _itemRowNode.get_children():
			node.show()
		_noInventoryNode = null
		


###############################################
###############TroubleShooting################

var pressed = false
func _process(delta):
	if Input.is_key_pressed(KEY_1):
		if pressed == false:
			var item = InventoryLists.get_item("Small Plant",1)
			PlayerInventory.add_item(item)
			update_inventory_scroll()
			pressed = true
	elif Input.is_key_pressed(KEY_2): 
		if pressed == false:
			var item = InventoryLists.get_item("Medium Sized Plant",1)
			PlayerInventory.add_item(item)
			update_inventory_scroll()
			pressed = true
	elif Input.is_key_pressed(KEY_3):
		if pressed == false:
			var item = InventoryLists.get_item("Large Sized Plant",1)
			PlayerInventory.add_item(item)
			update_inventory_scroll()
			pressed = true
	elif Input.is_key_pressed(KEY_4):
		if pressed == false:
			var item = InventoryLists.get_item("Pistol",1)
			PlayerInventory.add_item(item)
			update_inventory_scroll()
			pressed = true
	elif Input.is_key_pressed(KEY_5):
		if pressed == false:
			var item = InventoryLists.get_item("Shotgun",1)
			PlayerInventory.add_item(item)
			update_inventory_scroll()
			pressed = true
	else:
		pressed = false
	#################
