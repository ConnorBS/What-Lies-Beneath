extends TextureRect

signal description_update

var item:Inventory.KeyItems

func _ready():
	var _new_connectiion = connect("mouse_entered",self, "_on_focus")
#	connect("mouse_exited",self, "_on_focus")


func update_item(new_item:Inventory.KeyItems)->void:
	if new_item != item:
		item = new_item
	if item.unlocked:
		self.texture = load(item.collected_texture)
	else: 
		self.texture = load(item.unkown_texture)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_focus():
	if item.unlocked:
		emit_signal("description_update",item.name,item.description)
	else:
		emit_signal("description_update","???","")
	pass # Replace with function body.
