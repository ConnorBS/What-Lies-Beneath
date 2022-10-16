class_name Inventory

class Items:
	var texture
	var name
	var use
	var value
	var stackable
	var description
	var quantity = 0
	var max_quantity = 99
	var weapon:bool = false
	
	func is_type(type:String):
		return type == "Inventory.Items"



class KeyItems:
	var slot:int
	var name:String
	var description:String
	var unlocked:bool = false
	var collected_texture:String
	var unkown_texture:String = "res://Assets/KeyItems/Blank-Keys.png"
	var type:String = "Item" # or "Key"
	
	func is_type(type:String):
		return type == "Inventory.KeyItems"

class MapFragments:
	
	
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
