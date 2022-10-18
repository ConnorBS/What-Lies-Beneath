extends MarginContainer

var item:Inventory.Items

#func update_item(new_item:Inventory.Items)->void:
#	if item != new_item:
#		if new_item == null:
#			$ItemTexture.texture = null
#			clear_label()
#		else:
#			$ItemTexture.texture = load(new_item.texture)
#			if new_item.stackable:
#				update_label(new_item.quantity)
#			else:
#				clear_label()
#		item = new_item
#	elif new_item != null:
#		if new_item.stackable:
#			update_label(new_item.quantity)
#		else:
#			clear_label()
#	pass
#
func update_item(new_item:Inventory.Items)->void:
	if new_item == null:
		$ItemTexture.texture = null
		clear_label()
		item = null
	else:
		if item != new_item:
			$ItemTexture.texture = load(new_item.texture)
			item = new_item
		if new_item.stackable:
			update_label(new_item.quantity)
		else:
			clear_label()
	
func update_label(new_quantity):
	$Label.text = "- "+str(new_quantity)+" -"

func clear_label():
	$Label.text = ""
