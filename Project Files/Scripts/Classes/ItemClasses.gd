class_name Inventory

class Items:
	enum COMMANDS {USE,EQUIP,RELOAD,REMOVE}
	var texture
	var name
	var use
	var value
	var stackable
	var description
	var quantity = 0
	var max_quantity = 99
	var reload_to = null
	var weapon:bool = false
	
	func is_type(type:String):
		return type == "Inventory.Items"
		
		
	func get_item_commands()->Dictionary:
		if use == "Heal":
			return {COMMANDS.USE : true, COMMANDS.EQUIP : false , COMMANDS.RELOAD : false, COMMANDS.REMOVE : true}
		elif use == "Equip" and weapon == true:
			return {COMMANDS.USE : false, COMMANDS.EQUIP : true, COMMANDS.RELOAD : true, COMMANDS.REMOVE : true}
		elif use == "Reload":
			return {COMMANDS.USE : false, COMMANDS.EQUIP : false, COMMANDS.RELOAD : true, COMMANDS.REMOVE : true}
		push_warning("Inventory.Items does not have a matching command expected for get_item_commands()")
		return {COMMANDS.USE : false, COMMANDS.EQUIP : false, COMMANDS.RELOAD : false, COMMANDS.REMOVE : false}
	
	func use_item()->bool:
		var will_be_deleted = false
		if use == "Heal":
			PlayerState.heal(value)
			PlayerInventory.remove_item(self)
			will_be_deleted = true
		return will_be_deleted
		
		
	func equip_item():
		if use == "Equip" and weapon == true:
			PlayerInventory.equip(self)
			
	func reload_item():
		if (use == "Reload" or use == "Equip") and reload_to != null:
			PlayerInventory.reload_item(self)



class KeyItems:
	var slot:int
	var name:String
	var description:String
	var unlocked:bool = false
	var collected_texture:String
	var unkown_texture:String = "res://Assets/KeyItems/Blank-Keys.png"
	var type:String = "Item" # or "Key"
	
	
	func is_type(type_to_check:String):
		return type_to_check == "Inventory.KeyItems"
	

class MapFragments:
	var name:String
	
	func is_type(type:String):
		return type == "Inventory.MapFragments"

	
class Locations:
	
	func is_type(type:String):
		return type == "Inventory.Locations"
	pass

class JournalPage:
	var pageName:String
	var pageNumber:int
	
	func is_type(type:String):
		return type == "Inventory.JournalPage"
