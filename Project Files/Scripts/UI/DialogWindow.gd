extends CanvasLayer

#Text speed determines the speed of the text written. 0 = instant

onready var conversationWindow = $DialogWindow/DialogTexture/Conversation
onready var conversationSpeaker = $DialogWindow/Speaker/SpeakerNameTexture/SpeakerName
onready var Dialog = $DialogWindow
onready var NextButton = $NextButton
onready var ConfirmationWindow = $ConfirmationWindow
onready var AutoTimer = $AutoTimer
onready var sceneToLoad = 0
var playerName 

var dialogContent = Array ()
var speakerNameContent = Array()
var playerPosition = 0
var dialogCount = 0
var currentlyAnimating = false;
var waitingForSelection = false;

var autoJustTurnedOn = false;
enum {regular, pause, choice, passing, loading}
var gameState = regular   ## Helps determine if it's regular mode, the game is paused, or a choice is given
var previousState = regular ##Lets it toggle back to it's previous state

var dialog_level_name
var dialog_trigger_name

var button_positions = [];

var playerChoices = [];

var choiceCount = 0

var lineCount = 0
var lineDataDict = {}
var dataTypesPerLine = {}
 
var text_speed;
var auto_speed;
var auto_state;

var activeSection = true ## if path in text file doesn't match up, will skip through lines

var changingScene = false;

var dialogFile
var audioFile

var choice_unlocked = false

signal dialogClosed
# Called when the node enters the scene tree for the first time.
func _ready():
	text_speed = Settings.text_speed;
	auto_speed = Settings.auto_speed;
	auto_state = Settings.auto_state;

	playerName = PlayerState.get_player_name();

#	Dialog.update_Auto(auto_state);
	button_positions = Dialog.button_hitboxes();
#	var dialogFile = DialogManager.dialog_to_load()
#	##Troubelshooting
	load_dialogs(dialogFile)
	update_dialog(speakerNameContent[playerPosition],dialogContent[playerPosition]);
	
	text_speed = Settings.text_speed;
	auto_speed = Settings.auto_speed;
	auto_state = Settings.auto_state;
	Dialog.update_Auto(auto_state);
	
	PlayerState.set_Player_Active(false)
	
func load_window(level_name:String,trigger_name:String):
	dialogFile =DialogManager.get_dialog(level_name,trigger_name)
	audioFile = next_audio_file(dialogFile)
	dialog_level_name = level_name
	dialog_trigger_name = trigger_name
#	update_dialog(speakerNameContent[playerPosition],dialogContent[playerPosition]);

func next_audio_file(exisiting_file=dialogFile):
	if exisiting_file != null and exisiting_file != "":
		var new_audio = exisiting_file.left(exisiting_file.length()-4)+str(playerPosition+1)+".wav"
		if does_audio_exist(new_audio):
			return new_audio
	return null
	
	
func does_audio_exist(new_audio)->bool:
	var file_check = File.new()
	if file_check.file_exists(new_audio):
		return true
	else:
		push_warning("No Audio found for dialog: "+new_audio)
		return false
		
	
func convertTextVariables (string) -> String:
	if string == "PC":
		return playerName
#	elif string == "Background":
#		return PlayerGameSave.playerBackground
	return ""

func update_if_player(name):
	if name == null:
		return ""
	elif name == "PC":
		return playerName
	else: return name
func parse_square_brackets(dialogText,lineNumber):
	var countSlashes =0
	var areThereCharactersOutsideSquareBracket = false;
	var numbered_choice = false;
	var contentSquareBracketString = "";
	var finalString:String = ""
	var insideBracket = false;
	var skipDialog = false;
	var choices = [] ## determined by [number] and text
	var choiceNumbers = []
	var choiceString = ""
	var newScript = false ## determined by [/****/]
	var variableText = ""
	var variableState = false;
	var quoteMark = false
	var BBCode = false
	var check_choices = false
	var check_choices_array = []
	var choice_matched = false
	for i in dialogText:
		var character = dialogText.left(1);
		if character =="\"":
			if BBCode:
				BBCode = false
				quoteMark = false
				#### call to ignore character
				character = ""
			quoteMark = true
		if character == "{":
			variableState = true
		elif character == "}":
			variableState = false
			if numbered_choice:
				choiceString += convertTextVariables(variableText)
			elif insideBracket:
				contentSquareBracketString += convertTextVariables(variableText)
			else:
				finalString += convertTextVariables(variableText)
				areThereCharactersOutsideSquareBracket = true
			variableText = ""
			
		elif variableState:
			variableText += character
		elif character == "[":
			if quoteMark == true:
				BBCode = true
				finalString = finalString.left(finalString.length()-1)
				finalString += character
				print (finalString)
			else:
				insideBracket = true;
				if numbered_choice == true and choiceString != "":
					choices.append(choiceString)
					choiceString = ""
		elif character == "]":
			if BBCode:
				finalString += character
			
			if !newScript:
				if countSlashes == 0: ### choice
					if check_choices:
						check_choices_array.append(contentSquareBracketString)
						contentSquareBracketString = ""
						if check_choices_array.size() == 4:
							var saved_choices = PlayerState.get_choices(check_choices_array[0],check_choices_array[1])
							if !saved_choices.empty():
								if int(check_choices_array[3]) == saved_choices[int(check_choices_array[2])]:
									choice_matched = true

						else: push_warning("check_choices_array expected 4 values")
					elif int(contentSquareBracketString) != 0:
						numbered_choice = true;
						choiceNumbers.append(int(contentSquareBracketString))
						choiceString += contentSquareBracketString + ". "
						contentSquareBracketString = ""
	#				elif numbered_choice and int(contentSquareBracketString) <= 5:
	#					choiceNumbers.append(int(contentSquareBracketString))
	#					choiceString += contentSquareBracketString + ". "
	#					contentSquareBracketString=""
					else:
						print("Unable to determine value in []")
				
			insideBracket = false
		elif insideBracket and character == "/":
			countSlashes += 1;
			contentSquareBracketString += character;
		elif insideBracket and character == "\\":
			newScript = true;
		elif insideBracket and character == ",":
			check_choices = true
			check_choices_array.append(contentSquareBracketString)
			contentSquareBracketString = ""
		elif insideBracket:
			contentSquareBracketString += character;
		elif numbered_choice and character == "&" and areThereCharactersOutsideSquareBracket == false:
			if !dataTypesPerLine.has(lineNumber):
				lineDataDict[lineNumber]=choiceNumbers
				choiceNumbers.empty();
			else:
				lineDataDict[lineNumber].append(choiceNumbers);
				choiceNumbers.empty();
		
		elif BBCode:
			finalString += character
		else:
			if numbered_choice:
				choiceString += character
			elif variableState:
				pass
				
			else:
				
				finalString += character;
				areThereCharactersOutsideSquareBracket = true;
			
		if dialogText.left(2) != null:
			dialogText = dialogText.right(1)
	
	if newScript:
		dataTypesPerLine[lineNumber] = "loadNewScript"
		lineDataDict[lineNumber] = contentSquareBracketString
		return ""
	elif numbered_choice and !choices.empty():
		dataTypesPerLine[lineNumber] = "choiceToMake"
		choices.append(choiceString)
		lineDataDict[lineNumber] = choices
		if areThereCharactersOutsideSquareBracket:
			return finalString
	elif numbered_choice and choices.empty():
		dataTypesPerLine[lineNumber] = "pathCheck"
		lineDataDict[lineNumber]=choiceNumbers
	elif areThereCharactersOutsideSquareBracket:
		return finalString;
	elif contentSquareBracketString == "RESUME":
		dataTypesPerLine[lineNumber] = "pathCheck"
		lineDataDict[lineNumber] = "RESUME"
	
	elif contentSquareBracketString == "ELSE":
		dataTypesPerLine[lineNumber] = "choiceCheck"
		if !choice_unlocked:
			lineDataDict[lineNumber] = "Unlocked"
		else:
			lineDataDict[lineNumber] = "Locked"
		choice_unlocked = false
	elif choice_matched:
		dataTypesPerLine[lineNumber] = "choiceCheck"
		lineDataDict[lineNumber] = "Unlocked"
		choice_unlocked = true
	elif !choice_matched:
		dataTypesPerLine[lineNumber] = "choiceCheck"
		lineDataDict[lineNumber] = "Locked"
		
	return "Error reading Square Brackets"
	
		
#func parse_gender_brackets (dialogText):
#	print (dialogText)
#	var genderString = "";
#	var inGenderString = false;
#	var contentString = ""
#	for i in dialogText.length():
#
#		var character = dialogText.left(1);
#		if character == "[":
#			inGenderString = true;
#
#		elif character == "]":
#			inGenderString = false;
#			contentString += player_gendered_Dictionary(genderString);
#			inGenderString = "";
#		elif inGenderString:
#			genderString += character
#		else:
#			contentString += character;
#		dialogText = dialogText.right(1)
#	return contentString;

##Takes the dialogs, and parsing it out to two parts left of ":" and right of ":"
##Brackets are handled by the functions after, to cycle through the info in brackets
func load_dialogs(file_location):
	var d = File.new();
	d.open(file_location,File.READ)
#	troubleshooting
#	var index = 0
	var nameofSpeaker = "";
	var dialog = "";
	dialogCount = 0;
	while not d.eof_reached():
		var line = d.get_line();
		lineCount += 1;
		var troubleshootingline = line;
		var contentString = "";
		var found_split = false;
		var charcount = line.length()
		
		if line != "":
			for i in charcount:
				var character = line.left(1);
#				print ("character = ",character)
				##Finding split between Speaker and Dialog
				if !found_split:
					if character != null and i+1 != charcount:
#						print ("i(",i,") != charcount(",charcount,") -> ", i+1 != charcount)
						if character != ":":
							contentString += character;
							line = line.right(1);
						elif line.left(2) != null:
							if line.left(2) == "/": ## New path
								newPath(line.right(2))
								return
							else:
								nameofSpeaker = contentString
								line= line.right(2);
								found_split = true;
								contentString = "";
#							else:
#								contentString += line.left(2);
#								line = line.right(2)
#						print (character)
					else:
						dialog=contentString+character;
#						print ("character null = ", dialog)
						break;
				else:
					if line != null:
						dialog = line;
#					print ("found split = ", dialog)
					break;
			dialog = parse_square_brackets(dialog,lineCount-1); ##parsing the speach, if there is no name, then processes square brackte
#			print ("name of speaker = ", nameofSpeaker);
			speakerNameContent.append(update_if_player(nameofSpeaker))
#			if dialog != "" and dialog != null:
#				dialogContent.append(dialog.replace("\\n", "\n\n"))
#				dialogCount += 1;
			dialogContent.append(dialog.replace("\\n", "\n\n"))
			dialogCount += 1;
				
			
#troubleshooting
#		line += " "
#		print(troubleshootingline + " " + str(index))
#		print(speakerNameContent[index],":")
#		print(dialogContent[index])
#		index += 1
	d.close()
	



func checkActiveDialog(position):
	if dataTypesPerLine.has(position):
		if dataTypesPerLine[position] == "choiceToMake":
			previousState = gameState
			gameState = choice
		elif dataTypesPerLine[position] == "loadNewScript":
			previousState = gameState
			gameState = loading
		elif dataTypesPerLine[position] == "choiceCheck":
			previousState = gameState
			gameState = regular
func checkPath (position):
	var matching = false;
	if dataTypesPerLine.has(position):
		if dataTypesPerLine[position] == "pathCheck":
			var arrayCheck = lineDataDict[position]
			
			if arrayCheck is String:
				if arrayCheck == "RESUME":
					matching = true
				
			elif arrayCheck[0] is Array:
				for i in arrayCheck.size():
					var returned = arrayCompare(playerChoices,arrayCheck[i]);
					if matching or returned == true:
						matching = true
			else:
				matching = arrayCompare(playerChoices,arrayCheck)
			if matching:
				previousState = gameState
				gameState = regular
			else:
				previousState = gameState
				gameState = passing
	return matching

func arrayCompare (array1,array2) -> bool :
	if array1.size() != array2.size():
		return false
	var matching = true
	for i in array1.size():
		if array1[i] != array2[i]:
			matching = false;
	return matching;
func play_next_dialog():
	playerPosition += 1;
	save_state();
	checkActiveDialog(playerPosition)
	print ("Player Position = ",playerPosition)
	if checkPath(playerPosition):
		play_next_dialog()
	elif gameState == passing:
		play_next_dialog();
	elif gameState == loading:
		save_settings()
		newPath(lineDataDict[playerPosition])
	else:
		update_dialog(speakerNameContent[playerPosition],dialogContent[playerPosition])
		pass
	
	audioFile = next_audio_file(audioFile)
	
	print(audioFile)
	if audioFile != null:
		$Voice.stream = load(audioFile)
		$Voice.play()

#update to animation states at later dates
func update_dialog(speaker,conversation):
#	print ("update dialoge speaker " + speaker)
	NextButton.hide();
	
	audioFile = next_audio_file()
	
	print(audioFile)
	if audioFile != null:
		$Voice.stream = load(audioFile)
		$Voice.play()
	
	if !lineDataDict.has(playerPosition):
		conversationWindow.show(); #calling show each time just incase states change elsewere.	
		conversationSpeaker.text = speaker;
		conversationWindow.text = conversation;
		currentlyAnimating = true;
		Dialog.new_Dialog(speaker,conversation,text_speed)
	
	elif dataTypesPerLine.has(playerPosition):
		if dataTypesPerLine[playerPosition] == "choiceToMake":
			previousState = gameState
			gameState = choice
			Dialog.new_Choices(speaker,lineDataDict[playerPosition])
			lineDataDict.erase(playerPosition)
		elif dataTypesPerLine[playerPosition] == "choiceCheck":
			if lineDataDict[playerPosition] == "Unlocked":
				previousState = gameState
				gameState = regular
				play_next_dialog()
				lineDataDict.erase(playerPosition)
			elif lineDataDict[playerPosition] == "Locked":
				previousState = gameState
				gameState = passing
				play_next_dialog()
			
	
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func newPath (pathWay):
	if pathWay == "END":
		change_to_next_scene()
	else:
		DialogManager.newDialog(pathWay)

#func check_choice(choice_dict,value_to_check):
#	choice_dict

func _input(event):
	if gameState == regular:
		if event is InputEventKey or event is InputEventMouseButton:
			if event.pressed:
	#			if !is_a_button(get_global_mouse_position()):
				if currentlyAnimating:
					Dialog.done_Writing()
				elif waitingForSelection:
					pass
				else:
					play_next_dialog();
		elif !currentlyAnimating and auto_state and AutoTimer.time_left == 0 and autoJustTurnedOn:
			AutoTimer.start();
			autoJustTurnedOn = false;
		
		
## button_positions is pulled from Dialog Screen, and is global position with:
## x start, y start, x end, y end.
func is_a_button(position):
	for i in button_positions.size():
		if button_positions[i][0] <= position.x and button_positions[i][2] >= position.x:
			if button_positions[i][1] <= position.y and button_positions[i][3] >= position.y:
				return true;
	return false
	
func save_settings():
#	ConfigManager.text_speed = text_speed;
#	ConfigManager.auto_speed = auto_speed;
#	ConfigManager.auto_state = auto_state;
#	ConfigManager.update_files();
	pass
###Post Next Button as we are ready to move on
func next_button_ready():
	NextButton.show()
	pass

func _on_DialogWindow_writingFinished():
	currentlyAnimating = false;
	if auto_state:
		AutoTimer.wait_time = auto_speed*.05
		AutoTimer.start();
	else:
		next_button_ready()
	pass # Replace with function body.


func _on_AutoTimer_timeout():
	play_next_dialog();


func _on_NextButton_pressed():
	play_next_dialog();
	pass # Replace with function body.

func _on_DialogWindow_AutoPlay():
	auto_state = !auto_state;
	autoJustTurnedOn=true
	pass # Replace with function body.


func _on_DialogWindow_Settings():
	pass # Replace with function body.


func _on_DialogWindow_Skip():
	ConfirmationWindow.show();
	pause(pause);
	pass # Replace with function body.

func pause(state):
	previousState = gameState
	gameState=state;
	Dialog.pause(gameState);

func _process(delta):
	pass
	
func change_to_next_scene():
	print ("change scene function here")
	PlayerState.set_Player_Active(true)
	PlayerState.update_dialog(dialog_level_name,dialog_trigger_name,true,playerChoices)
	emit_signal("dialogClosed")
	self.queue_free()
	pass

func save_state():
#	PlayerGameSave.playerSave = playerPosition;
#	PlayerGameSave.saveGame()
	pass

func _on_ConfirmationWindow_confirmation(confirmation):
	if confirmation:
		change_to_next_scene();
	else:
		ConfirmationWindow.hide();
		pause(previousState)

	pass # Replace with function body.



func _on_DialogWindow_choiceMade(choice):
	previousState = gameState
	gameState = regular
	playerChoices.append(choice)
	PlayerState.update_dialog(dialog_level_name,dialog_trigger_name,true,playerChoices)
	play_next_dialog()
	pass # Replace with function body.


func _on_VisualNovelWindow_playerAnimation():
	pass # Replace with function body.
