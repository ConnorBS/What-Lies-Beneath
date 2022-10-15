class_name Inventory

class Items:
	var texture
	var name
	var stackable
	var description
	var quantity = 0
	var max_quantity = 99
	var weapon:bool = false



class KeyItems:
	var slot:int
	var name:String
	var description:String
	var unlocked:bool = false
	var collected_texture:String
	var unkown_texture:String = "res://Assets/KeyItems/Blank-Keys.png"
	var type:String = "Item" # or "Key"

class MapFragments:
	pass
	
class Locations:
	pass

class JournalPage:
	var pageName:String
	var pageNumber:int
	
