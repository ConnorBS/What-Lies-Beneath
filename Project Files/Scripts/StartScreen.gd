extends Control

onready var newGame_scene = "res://Scenes/GameScreen.tscn"

onready var continue_button = $VBoxContainer/Continue
onready var startNewGame_button = $VBoxContainer/StartNewGame
onready var quit_button = $VBoxContainer/Quit

enum BUTTON {START,CONTINUE}
var button_pressed:int 
func _ready():
	
	if !SaveAndLoad.is_there_a_saved_game():
		continue_button.queue_free()

func _on_Continue_pressed():
	button_pressed = BUTTON.CONTINUE
	load_animation()
	pass # Replace with function body.


func _on_StartNewGame_pressed():
	button_pressed = BUTTON.START
	load_animation()
	pass # Replace with function body.


func _on_Quit_pressed():
	get_tree().quit()
	pass # Replace with function body.

func load_animation():
	$VBoxContainer.hide()
	$StartGameButton.play()
	$Loading.interpolate_property($BackgroundImage,"modulate",Color(1,1,1,1),Color(1,1,1,0),2.5)
	$Loading.interpolate_property($VBoxContainer,"modulate",Color(1,1,1,1),Color(1,1,1,0),2.5)
	$Loading.interpolate_property($BackgroundMusic,"volume_db",0,-80,2.5,Tween.EASE_IN)

	$Loading.start()

func _on_Loading_tween_completed(_object, _key):
	if button_pressed == BUTTON.START:
		var _new_scene = get_tree().change_scene(newGame_scene)
	elif button_pressed == BUTTON.CONTINUE:
		SaveAndLoad.load_game()
	pass # Replace with function body.
