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
#		var LoadingLevel = SceneToLoad.instance()
		get_tree().change_scene(SceneToLoad)
	pass # Replace with function body.
