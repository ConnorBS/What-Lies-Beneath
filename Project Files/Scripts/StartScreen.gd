extends Control

onready var newGame_scene = "res://Scenes/GameScreen.tscn"

onready var continue_button = $VBoxContainer/Continue
onready var startNewGame_button = $VBoxContainer/StartNewGame
onready var quit_button = $VBoxContainer/Quit

func _ready():
	
	if !SaveAndLoad.is_there_a_saved_game():
		continue_button.queue_free()

func _on_Continue_pressed():
	SaveAndLoad.load_game()
	pass # Replace with function body.


func _on_StartNewGame_pressed():
	var _new_scene = get_tree().change_scene(newGame_scene)
	pass # Replace with function body.


func _on_Quit_pressed():
	get_tree().quit()
	pass # Replace with function body.
