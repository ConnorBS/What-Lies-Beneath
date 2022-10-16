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
	if value < 0:
		if item_hover_over < 0:
			item_hover_over = item_list.size()-1
		update_inventory_scroll()
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
		_disable_buttons(true)
		return
	elif item_list.size() == 1:
		_disable_buttons(true)
#		_itemRowNode.get_child(2).update_item(item_list[0])
	else:
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
				items_to_display.push_front(leftSide)
			leftSide -= 1
	else: return [null,null,null,null,null]
	return items_to_display
func _clear_inventory()->void:
	for i in _itemRowNode.get_child_count()-1:
		_itemRowNode.get_child(i).update_item(null)
