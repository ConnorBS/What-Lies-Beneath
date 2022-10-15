extends MenuClass

onready var _keyGridNode = get_node("%KeyGrid")
onready var _itemGridNode = get_node("%ItemGrid")
onready var _keyItemScene = preload("res://Scenes/UI/Components/KeyItem.tscn")

func load_window()->void:
	PlayerInventory.pickup_KeyItem(InventoryLists.KeyItems["Item"][2])
	var keyList = PlayerInventory.get_key_list()
	var itemList = PlayerInventory.get_item_list()
	_update_keys(keyList)
	_update_items(itemList)
	_update_description("","")

func _update_keys(keyList:Array)->void:
	var currentChildCount = _keyGridNode.get_child_count()
	for i in keyList.size():
		if i >= currentChildCount:
			var newKeyItem = _keyItemScene.instance()
			_keyGridNode.add_child(newKeyItem)
			newKeyItem.connect("description_update",self,"_update_description")
		_keyGridNode.get_child(i).update_item(keyList[i])


func _update_items(itemList:Array)->void:
	var currentChildCount = _itemGridNode.get_child_count()
	for i in itemList.size():
		if i >= currentChildCount:
			var newKeyItem = _keyItemScene.instance()
			_itemGridNode.add_child(newKeyItem)
			newKeyItem.connect("description_update",self,"_update_description")
		_itemGridNode.get_child(i).update_item(itemList[i])

func _update_description(item_name,item_description)->void:
	$MarginContainer/VBoxContainer/ItemDescription/DescriptionPanel/VBoxContainer/ItemName.text = item_name
	$MarginContainer/VBoxContainer/ItemDescription/DescriptionPanel/VBoxContainer/CenterContainer/RichTextLabel.bbcode_text= item_description









func _on_BottomButtonMargin_Back()->void:
	emit_signal("Back")

