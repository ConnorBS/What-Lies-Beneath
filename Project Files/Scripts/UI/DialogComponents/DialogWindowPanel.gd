extends Control

onready var Conversation = $DialogTexture/Conversation
onready var SpeakerName = $Speaker/SpeakerNameTexture/SpeakerName
onready var TextDelayTimer = $TextDelayTimer
onready var _investigationNode = $InvestigationMarginContainer
#onready var AutoPlay = $ButtonBar/Buttons/AutoPlay
#onready var Buttons = $ButtonBar/Buttons
onready var choiceOptionBox = $ChoiceBoxes

onready var textChoiceBoxes = preload("res://Scenes/UI/DialogComponents/TextChoices.tscn").instance()

var conversationCharacterCount = 0
var speedCoefficient = .01

signal writingFinished;
signal investigate
enum {regular, pause, choice}
var gameState = regular
var previousState = regular


func pause_dialog(state):
	previousState = gameState
	gameState = state;
	if gameState == pause:
		TextDelayTimer.stop();
#		print ("Text Delay Stop")
	else:
		TextDelayTimer.start();

func skip_animation():
	done_Writing();


func new_Dialog (speaker,conversation,speed):
	Conversation.visible_characters = 0;
	if speaker != "":
		$Speaker.show()
		SpeakerName.text = speaker;
	else:
		$Speaker.hide()
	Conversation.bbcode_text = conversation;
	conversationCharacterCount = conversation.length();
	if speed <= 0:
		Conversation.visible_characters = -1;
		done_Writing(false);
	else:
		TextDelayTimer.wait_time = speed*speedCoefficient
		TextDelayTimer.start()


func next_letter ():
	Conversation.visible_characters += 1
	var visibleCharacters = Conversation.visible_characters;
	if conversationCharacterCount <= visibleCharacters:
		done_Writing();
		
func done_Writing(timerStarted = true):
	if timerStarted:
		TextDelayTimer.stop();
	if Conversation.visible_characters != -1 and Conversation.visible_characters != conversationCharacterCount :
		Conversation.visible_characters = -1;
	emit_signal("writingFinished");
	

func _on_TextDelayTimer_timeout():
	next_letter()


############################################
########Choices#############################
############################################


## For Choices
var currentChoices = []
var currentSelection = 0
signal choiceMade


func new_Choices (speaker,choiceArray):
	previousState = gameState
	gameState = choice
	Conversation.hide()
	Conversation.text = ""
	
	if speaker != "":
		$Speaker.show()
		SpeakerName.text = speaker;
	else:
		$Speaker.hide()
	if choiceArray != null:
		for i in choiceArray.size():
			var newOption = textChoiceBoxes.duplicate()
			choiceOptionBox.add_child(newOption)
			newOption.text = choiceArray[i]
			newOption.choice = i+1
			newOption.connect("choiceHighlighted",self,"_on_Choice_choiceHighlighted")
			currentChoices.append(newOption)
#			print(newOption.text)
				
func selected_Choice ():
	emit_signal("choiceMade",currentSelection)
#	print ("sent signal #",currentSelection)
	currentSelection = 0
	deleteArrayOfChoices(currentChoices)
	currentChoices.clear()
	gameState = regular
	Conversation.show()
	
func deleteArrayOfChoices(arrayOfNodes):
	for i in arrayOfNodes.size():
		arrayOfNodes[i].queue_free()

func _input(event):
	if gameState == choice:
		if Input.is_action_just_pressed("ui_accept") or event is InputEventMouseButton:
			if currentSelection != 0:
				selected_Choice()
	pass

func _on_Choice_choiceHighlighted(highlightedSelection):
	currentSelection = highlightedSelection
#	print (currentSelection)
	pass # Replace with function body.

func show_investigation():
	_investigationNode.show()
	

func _on_Investigate_pressed(button_pressed):
	if button_pressed:
		emit_signal("investigate")
	pass # Replace with function body.

func reset_button():
	find_node("Investigate").pressed = false
