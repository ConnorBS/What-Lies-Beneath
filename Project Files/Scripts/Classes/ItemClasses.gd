extends Resource
class_name Inventory


class Items:
	enum COMMANDS {USE,EQUIP,RELOAD,REMOVE}
	export var texture:String
	export var name:String
	export var use:String
	export var value:int
	export var stackable:bool
	export var description:String
	export var quantity:int = 0
	export var max_quantity:int = 99
	export var reload_to:String = ""
	export var weapon:bool = false
	
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
		if use == "Heal":
			PlayerState.heal(value)
			PlayerInventory.remove_item(self)
			return true
		if weapon == true:
			if quantity > 0:
				quantity -= 1
				return true
			
		return false
			
		
		
	func equip_item():
		if use == "Equip" and weapon == true:
			PlayerInventory.equip(self)
			
	func reload_item():
		if (use == "Reload" or use == "Equip") and reload_to != "":
			PlayerInventory.reload_item(self)



class KeyItems:
	export var slot:int
	export var name:String
	export var description:String
	export var unlocked:bool = false
	export var collected_texture:String
	export var unkown_texture:String = "res://Assets/KeyItems/Blank-Keys.png"
	export var type:String = "Item" # or "Key"
	
	
	func is_type(type_to_check:String):
		return type_to_check == "Inventory.KeyItems"
	

class MapFragments:
	export var name:String
	export var maps_unlocked:Array = []
	export var collected:bool = false
	export var type:String = "MapFragment"
	func is_type(type_to_check:String):
		return type_to_check == "Inventory.MapFragments"

	
class Locations:
	
	func is_type(type:String):
		return type == "Inventory.Locations"
	pass

class JournalPage:
	export var pageName:String
	export var pageNumber:int
	export var audioFile:String
	
	func is_audio_present()->bool:
		if audioFile == "":return false
		elif File.new().file_exists(audioFile):return true
		return false
		
	func is_type(type:String):
		return type == "Inventory.JournalPage"
