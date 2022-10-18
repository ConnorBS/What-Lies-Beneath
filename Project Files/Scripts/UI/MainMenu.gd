extends CanvasLayer

signal Map
signal Memo
signal KeyItems
signal Options

onready var _itemRowNode = $MarginContainer/VBoxContainer/ItemRow

onready var _itemScrollButtons = $ItemScrollButtonMarginContainer/HBoxContainer
onready var _itemScrollSelectionWindowNode = $ItemScrollButtonMarginContainer/HBoxContainer/Selector

onready var _itemNameLabel = $MarginContainer/VBoxContainer/ItemDescription/DescriptionPanel/VBoxContainer/ItemName
onready var _itemDescriptionLabel = $MarginContainer/VBoxContainer/ItemDescription/DescriptionPanel/VBoxContainer/CenterContainer/ItemDescriptionRichText
onready var _commandButtonContainerNode = $MarginContainer/VBoxContainer/TopRow/Command/Panel/VBoxContainer

onready var _equipmentNode = $MarginContainer/VBoxContainer/TopRow/Equipment/Panel/InventoryScrollContainer
#onready var 

var item_hover_over = 0
var item_selected:Inventory.Items
var item_list:Array = []
var _noInventoryNode:Label = null
var _noEquipmentNode:Label = null

var equipment_node_selected = false

export (Color) var selected_color = Color(.77,0,0,1)
export (Color) var non_selected_color = Color(1,1,1,1)

func _ready():
#	_equipmentNode.get_parent().grab_focus()
#	
##	select_equipment_node(false)
	select_selector_node(true)
func load_window():
	update_inventory_scroll()
#	_equipmentNode.get_parent().grab_focus()
#	_itemScrollSelectionWindowNode.grab_focus()
	
func select_equipment_node(state=true):
	equipment_node_selected = state
	if state:
		_equipmentNode.get_parent().self_modulate = selected_color
		item_selected = _equipmentNode.item
		update_text(item_selected)
		update_commands(item_selected)
		
	else:
		_equipmentNode.get_parent().self_modulate = non_selected_color
		


func select_selector_node(state=true):
	if state:
		_itemScrollSelectionWindowNode.self_modulate = selected_color
		item_selected = _itemRowNode.get_child(2).item
		update_text(item_selected)
		update_commands(item_selected)
	else:
		_itemScrollSelectionWindowNode.self_modulate = non_selected_color

	

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

func _on_Use_pressed():
	var is_item_being_removed = item_selected.use_item()
	if is_item_being_removed:
		item_list = PlayerInventory.get_list_of_inventory()
		update_Item_Scroll_position()
	
	update_inventory_scroll()
	pass # Replace with function body.


func _on_Equip_pressed():
	if equipment_node_selected:
		PlayerInventory.unequip()
		item_list = PlayerInventory.get_list_of_inventory()
		update_Item_Scroll_position()
		update_inventory_scroll()
		_itemScrollSelectionWindowNode.grab_focus()
	else:
		item_selected.equip_item()
		item_list = PlayerInventory.get_list_of_inventory()
		update_Item_Scroll_position()
		update_inventory_scroll()
		_equipmentNode.get_parent().grab_focus()
	pass # Replace with function body.


func _on_Reload_pressed():
	item_selected.reload_item()
	item_list = PlayerInventory.get_list_of_inventory()
	update_Item_Scroll_position()
	update_inventory_scroll()
	pass # Replace with function body.
	
	
func _on_Remove_pressed():
	if equipment_node_selected:
		PlayerInventory.unequip()
		PlayerInventory.remove_item(item_selected)
		item_list = PlayerInventory.get_list_of_inventory()
		update_Item_Scroll_position()
		update_inventory_scroll()
		_itemScrollSelectionWindowNode.grab_focus()
		
#		update_Item_Scroll_position(-1)
		
	elif !item_list.empty():
		PlayerInventory.remove_item(item_list[item_hover_over])
		item_list = PlayerInventory.get_list_of_inventory()
		update_Item_Scroll_position(-1)

	
	
func update_Item_Scroll_position(value = 0)->void:
	item_hover_over += value
	if value > 0:
		if item_hover_over >= item_list.size():
			item_hover_over = 0
		update_inventory_scroll()
	elif value < 0:
		if item_hover_over < 0:
			item_hover_over = item_list.size()-1
		update_inventory_scroll()
	if item_list.size() == 0:
		item_hover_over = 0
	elif item_hover_over >= item_list.size():
		item_hover_over = item_list.size()-1
			

	pass
	
func _disable_buttons(state=true)->void:
	if state:
		_itemScrollButtons.get_child(0).hide()
		_itemScrollButtons.get_child(2).hide()
	else:
		_itemScrollButtons.get_child(0).show()
		_itemScrollButtons.get_child(2).show()

func _on_Item_Scroll_Previous_pressed():
	get_parent().click_success()
	update_Item_Scroll_position(-1)
	
func _on_Item_Scroll_Next_pressed():
	get_parent().click_success()
	update_Item_Scroll_position(1)
	pass # Replace with function body.

func update_inventory_scroll()->void:
	update_equiped_item()
	item_list = PlayerInventory.get_list_of_inventory()
	var count = 0
	_clear_inventory()
	if item_list.size() == 0:
		_no_inventory(true)
		_disable_buttons(true)
		update_text(null)
		update_commands(null)
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
	if equipment_node_selected == false:
		item_selected = _itemRowNode.get_child(2).item
	update_text(item_selected)
	update_commands(item_selected)

func update_text (item_to_use:Inventory.Items)->void:
	if item_to_use == null:
		_itemNameLabel.text = ""
		_itemDescriptionLabel.bbcode_text = ""
	else:
		_itemNameLabel.text = item_to_use.name
		_itemDescriptionLabel.bbcode_text = item_to_use.description

func update_commands(item_to_use:Inventory.Items)->void:
	if item_to_use == null:
		for button in _commandButtonContainerNode.get_children():
			button.hide()
	else:
		var commands_to_display:Dictionary = item_to_use.get_item_commands()
		for i in _commandButtonContainerNode.get_child_count():
			if commands_to_display[i]:
				_commandButtonContainerNode.get_child(i).show()
				if i == 1:
					if equipment_node_selected:
						_commandButtonContainerNode.get_child(i).text = "Unequip"
					else:
						_commandButtonContainerNode.get_child(i).text = "Equip"
			else:
				_commandButtonContainerNode.get_child(i).hide()
			
	pass
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

func update_equiped_item()->void:
	_equipmentNode.update_item(PlayerInventory.get_equiped_item())
	if _equipmentNode.item == null:
		_no_equipment(true)
	else:
		_no_equipment(false)
	pass
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
	

func _no_equipment(state)->void:
	if state and _noEquipmentNode == null:
		_equipmentNode.hide()
		_noEquipmentNode = Label.new()
		_noEquipmentNode.text = "Nothing Equipped"
		_noEquipmentNode.align = _noEquipmentNode.ALIGN_CENTER
		_noEquipmentNode.valign = _noEquipmentNode.VALIGN_CENTER
		_noEquipmentNode.anchor_right = 1.0
		_noEquipmentNode.anchor_bottom = 1.0
		_noEquipmentNode.size_flags_horizontal = _noEquipmentNode.SIZE_EXPAND_FILL
		_equipmentNode.get_parent().add_child(_noEquipmentNode)
	elif state == false and _noEquipmentNode != null:
		_equipmentNode.get_parent().remove_child(_noEquipmentNode)
		_noEquipmentNode.queue_free()
		_equipmentNode.show()
		_noEquipmentNode = null

###############################################
###############TroubleShooting################

var pressed = false
func _process(delta):
#	print("command focus ",_commandButtonContainerNode.get_focus_owner())
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
	elif Input.is_key_pressed(KEY_6):
		if pressed == false:
			var item = InventoryLists.get_item("Small Bullets",12)
			PlayerInventory.add_item(item)
			update_inventory_scroll()
			pressed = true
	elif Input.is_key_pressed(KEY_7):
		if pressed == false:
			var item = InventoryLists.get_item("Shotgun Shells",4)
			PlayerInventory.add_item(item)
			update_inventory_scroll()
			pressed = true
			
			
		


	else:
		pressed = false
	#################



func _on_Equipment_Panel_focus_entered():
	print(_itemScrollButtons.get_focus_owner())
	if _itemScrollButtons.get_focus_owner() != null:
		select_equipment_node(true)
		select_selector_node(false)
		print ("focus selected ", _equipmentNode.get_focus_owner()  )
	pass # Replace with function body.


#func _on_Equipment_Panel_focus_exited():
#	print("equipment exit: ",_commandButtonContainerNode.get_focus_owner())
#	if _commandButtonContainerNode5.get_focus_owner() == null:
##	if _commandButtonContainerNode.get_focus_owner().get_parent() != $MarginContainer/VBoxContainer/TopRow/Command/Panel/VBoxContainer:
#		select_equipment_node(false)
#		select_selector_node(true)
	pass # Replace with function body.


func _on_Selector_focus_entered():
	print("equipment exit: ",_commandButtonContainerNode.get_focus_owner())
	if _itemScrollButtons.get_focus_owner() != null:
#	if _commandButtonContainerNode.get_focus_owner().get_parent() != $MarginContainer/VBoxContainer/TopRow/Command/Panel/VBoxContainer:
		select_equipment_node(false)
		select_selector_node(true)

#	pass # Replace with function body.
#
#
#func _on_Selector_focus_exited():
#	select_selector_node(false)
#	pass # Replace with function body.

