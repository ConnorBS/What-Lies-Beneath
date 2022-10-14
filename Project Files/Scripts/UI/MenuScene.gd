extends CanvasLayer
enum MENU_WINDOWS{Main,Map,Memo,KeyItems,Options}

var _window_state = MENU_WINDOWS.Main


onready var _menuTransitionsNode = $MenuTransition
func _update_window(new_window:int)->void:
	if new_window == MENU_WINDOWS.Map:
		_menuTransitionsNode.play("Open_Map")




	_window_state = new_window
	
	pass

func _ready():
	pass # Replace with function body.



func _process(delta):
#	if Input.is_mouse_button_pressed(BUTTON_LEFT):
#		print ("Clicked", self.get_global_mouse_position())
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	pass


func _on_MainMenu_Map():
	_update_window(MENU_WINDOWS.Map)
	pass # Replace with function body.
