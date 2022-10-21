extends Area2D

export (String) var SceneToLoad
export (int) var PointToLoad

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Exit1_body_entered(body):
	if body.is_in_group("Player"):
		PlayerState.Spawn_Point = PointToLoad
		var parent = get_parent()
		while parent != null:
			if parent.is_in_group("Level"):
				
				var LoadingLevel = load(SceneToLoad).instance()
				var removingLevel = parent
				var viewPort = parent.get_parent()
				viewPort.remove_child(removingLevel)
				removingLevel.call_deferred("free")
				viewPort.add_child(LoadingLevel)
				parent = null
			elif parent == get_tree():
				push_warning("Tried to find scene to change, no parents reporting as \"Level\" group")
				parent = null
			else:
				parent = parent.get_parent()
	pass # Replace with function body.
