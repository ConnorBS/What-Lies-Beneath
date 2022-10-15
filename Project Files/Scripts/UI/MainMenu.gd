extends CanvasLayer

signal Map
signal Memo
signal KeyItems
signal Options

onready var _itemRowNode = $MarginContainer/VBoxContainer/ItemRow

var item_hover_over = 3


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
		_itemRowNode.move_child(_itemRowNode.get_child(0),_itemRowNode.get_child_count()-1)
	if value < 0:
		_itemRowNode.move_child(_itemRowNode.get_child(_itemRowNode.get_child_count()-1),0)
	pass

func _on_Item_Scroll_Previous_pressed():
	get_parent().click_success()
	update_Item_Scroll_position(-1)
	
func _on_Item_Scroll_Next_pressed():
	get_parent().click_success()
	update_Item_Scroll_position(1)
	pass # Replace with function body.
