extends Control

onready var Conversation = $DialogTexture/Conversation
onready var SpeakerName = $Speaker/SpeakerNameTexture/SpeakerName
onready var TextDelayTimer = $TextDelayTimer
onready var AutoPlay = $ButtonBar/Buttons/AutoPlay
onready var Buttons = $ButtonBar/Buttons
onready var choiceOptionBox = $ChoiceBoxes

onready var textChoiceBoxes = preload("res://Scenes/UI/DialogComponents/TextChoices.tscn").instance()

signal Settings;
signal AutoPlay;
signal Skip;

var conversationCharacterCount = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var speedCoefficient = .01

signal writingFinished;
enum {regular, pause, choice}
var gameState = regular
var previousState = regular

# Called when the node enters the scene tree for the first time.
func _ready():
	##debug
#	var testingArray = ["Cats Option 1","asdfefwefwefwefwefw efwef wef wef we fwe fw owpefe etwpgnewrg vewprjgpwer gpirw bpirw gbprw grwntgwr bh rwptb rwpjt brwjbnrwp pwrej pweti gwpt piwe ewp eqruingvwr  verqpijv ewpriv e[wroubgweprg pewri eqrphb eqrpiv epwhr vepivb vpi veqpibv e vpeirhwv ewrpv eqrpv eqriveprivbc vefveqrubeqrpv eqrpiuvberphv fdfpb e fw efw efw ef wef we fwe fwe fwef wef wef we fwef wfee d","Testing 3","MUAHAAHAHAAHAHAAHAAHAHAHA"]
#	new_Choices(testingArray)
	pass # Replace with function body.

func pause(state):
	previousState = gameState
	gameState = state;
	if gameState == pause:
		TextDelayTimer.stop();
		print ("Text Delay Stop")
	else:
		TextDelayTimer.start();

func button_hitboxes():
	var array_of_hitboxes = []
	for i in Buttons.get_child_count():
		var buttonNode = Buttons.get_child(i);
		var startPos = buttonNode.get_global_position()
		var offset = buttonNode.get_rect();
		
#		var offset = Vector2(rect.-rect[3],rect[4]-rect[2])
#		var pos = Buttons.get_child(i).get_pos()
#		array_of_hitboxes.append([pos.x,pos.y,offset.x,offset.y])
		array_of_hitboxes.append([startPos.x,startPos.y,startPos.x+offset.size.x,startPos.y+offset.size.y])

	return array_of_hitboxes;
		
	

func skip_animation():
	done_Writing();
	
func new_Dialog (speaker,conversation,speed):
	Conversation.visible_characters = 0;
	SpeakerName.text = speaker;
	Conversation.bbcode_text = conversation;
	conversationCharacterCount = conversation.length();
	if speed <= 0:
		Conversation.visible_characters = -1;
		done_Writing(false);
	else:
		TextDelayTimer.wait_time = speed*speedCoefficient
		TextDelayTimer.start()
	pass

			
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
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func update_Auto(state):
	AutoPlay.pressed = state;
		

func _on_TextDelayTimer_timeout():
	next_letter()
	pass # Replace with function body.


func _on_Settings_pressed():
	emit_signal("Settings")
	pass # Replace with function body.


func _on_AutoPlay_pressed():
	emit_signal("AutoPlay")
	print("autoplay Pressed")
	pass # Replace with function body.


func _on_SkipButton_pressed():
	emit_signal("Skip")
	pass # Replace with function body.

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
	SpeakerName.text = speaker;
	if choiceArray != null:
		for i in choiceArray.size():
			var newOption = textChoiceBoxes.duplicate()
			choiceOptionBox.add_child(newOption)
			newOption.text = choiceArray[i]
			newOption.choice = i+1
			newOption.connect("choiceHighlighted",self,"_on_Choice_choiceHighlighted")
			currentChoices.append(newOption)
			print(newOption.text)
				
func selected_Choice ():
	emit_signal("choiceMade",currentSelection)
	print ("sent signal #",currentSelection)
	currentSelection = 0
	deleteArrayOfChoices(currentChoices)
	currentChoices.clear()
	gameState = regular
	Conversation.show()
	
func deleteArrayOfChoices(arrayOfNodes):
	for i in arrayOfNodes.size():
		arrayOfNodes[i].queue_free()

func _process(delta):
	if gameState == choice:
		if Input.is_action_just_pressed("ui_touch"):
			if currentSelection != 0:
				selected_Choice()
	pass

func _on_Choice_choiceHighlighted(highlightedSelection):
	currentSelection = highlightedSelection
	print (currentSelection)
	pass # Replace with function body.
