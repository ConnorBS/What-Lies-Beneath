extends CanvasLayer

#Text speed determines the speed of the text written. 0 = instant

onready var conversationWindow = $DialogWindowPanel/DialogTexture/Conversation
onready var conversationSpeaker = $DialogWindowPanel/Speaker/SpeakerNameTexture/SpeakerName
onready var Dialog = $DialogWindowPanel
onready var NextButton = $NextButton
onready var _dialog_tween = $InvestigationTween
onready var sceneToLoad = 0
var playerName 

var dialogContent = Array ()
var speakerNameContent = Array()
var playerPosition = 0
var dialogCount = 0
var currentlyAnimating = false;
var waitingForSelection = false;


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

var activeSection = true ## if path in text file doesn't match up, will skip through lines

var changingScene = false;

var dialogFile
var audioFile
var pictureFile

var currently_investigating = false

var choice_unlocked = false
var end_scene = false
signal dialogClosed
# Called when the node enters the scene tree for the first time.
func _ready():
	text_speed = Settings.text_speed;

	playerName = PlayerState.get_player_name();
	if dialogFile != null:
		load_dialogs(dialogFile)
	update_dialog(speakerNameContent[playerPosition],dialogContent[playerPosition]);
	
	text_speed = Settings.text_speed;
	
	if pictureFile != null:
		Dialog.show_investigation()
		
	PlayerState.set_Player_Active(false)
	if $InvestigationItem.texture != null:
		tween_in_investigation()
	
func load_window(level_name:String,trigger_name:String):
	dialogFile =DialogManager.get_dialog(level_name,trigger_name)
	audioFile = next_audio_file(dialogFile)
	pictureFile = next_picture_file(dialogFile)
	dialog_level_name = level_name
	dialog_trigger_name = trigger_name

func load_system_window(array_of_text):
	var text_to_add:String
	var count = 1
	var max_lines = 2
	
	for text in array_of_text:
		if count > 1:
			text_to_add +="\n"+text
		else:
			 text_to_add = text
		count += 1
		if count > max_lines:
			count = 1
			dialogContent.append(text_to_add)
			speakerNameContent.append("")
			text_to_add = ""
	if text_to_add != "":
		dialogContent.append(text_to_add)
		speakerNameContent.append("")
		
			
			
		
	

func next_audio_file(exisiting_file=dialogFile):
	if exisiting_file != null and exisiting_file != "":
		var new_audio = exisiting_file.left(exisiting_file.length()-4)+str(playerPosition+1)+".wav"
		if does_audio_exist(new_audio):
			return new_audio
	return null
	
func tween_in_investigation():
	$InvestigationItem.self_modulate = Color(1,1,1,0)
	_dialog_tween.interpolate_property($InvestigationItem,"self_modulate",Color(1,1,1,0),Color(1,1,1,1),.8)
	_dialog_tween.start()
	$InvestigationItem.show()
	gameState = pause

func tween_out_investigation():
	_dialog_tween.interpolate_property($InvestigationItem,"self_modulate",Color(1,1,1,1),Color(1,1,1,0),.8)
	_dialog_tween.start()
	gameState = pause

func does_audio_exist(new_audio)->bool:
	var file_check = File.new()
	if file_check.file_exists(new_audio):
		return true
	else:
		push_warning("No Audio found for dialog: "+new_audio)
		return false
		
		
func next_picture_file(exisiting_file=dialogFile):
	if exisiting_file != null and exisiting_file != "":
		var new_texture = exisiting_file.left(exisiting_file.length()-4)+str(playerPosition+1)+".png"
		if does_audio_exist(new_texture):
			return new_texture
	return null
	
	
func does_texture_exist(new_texture)->bool:
	var file_check = File.new()
	if file_check.file_exists(new_texture):
		return true
	else:
		push_warning("No Texture found for dialog: "+new_texture)
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
	var _skipDialog = false;
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
#				print (finalString)
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
						if check_choices_array.size()%4 == 0:
							for count in (check_choices_array.size()/4):
#								print (count)
								
								var saved_choices = PlayerState.get_choices(check_choices_array[0+(count*4)],check_choices_array[1+(count*4)])
								if !saved_choices.empty():
									if int(check_choices_array[3+(count*4)]) == saved_choices[int(check_choices_array[2+(count*4)])]:
										choice_matched = true
									else:
										choice_matched = false
										break
								else:
									choice_matched = false
									break

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
#					else:
#						print("Unable to determine value in []")
				
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
			
		#reset quote mark
		if quoteMark and character != "\"":
			if BBCode == false:
				quoteMark = false
	
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
#	print ("Player Position = ",playerPosition)
	if checkPath(playerPosition):
		play_next_dialog()
	elif gameState == passing:
		play_next_dialog();
	elif gameState == loading:
		save_settings()
		newPath(lineDataDict[playerPosition])
	else:
		if dialogContent.size() <= playerPosition or speakerNameContent.size() <= playerPosition:
			newPath("END")
		else:
			update_dialog(speakerNameContent[playerPosition],dialogContent[playerPosition])
		pass
	
	audioFile = next_audio_file()
	pictureFile = next_picture_file()
	
	if audioFile != null:
		$Voice.stream = load(audioFile)
		$Voice.play()
	if pictureFile != null:
		if $InvestigationItem.texture == null:
			$InvestigationItem.texture = load(pictureFile)
			tween_in_investigation()
		else:
			tween_out_investigation()
		Dialog.show_investigation()

#update to animation states at later dates
func update_dialog(speaker,conversation):
	NextButton.hide();
	
	audioFile = next_audio_file()
	pictureFile = next_picture_file()
	
	if audioFile != null:
		$Voice.stream = load(audioFile)
		$Voice.play()
	if pictureFile != null:
		if $InvestigationItem.texture == null:
			$InvestigationItem.texture = load(pictureFile)
			tween_in_investigation()
		else:
			tween_out_investigation()
		Dialog.show_investigation()
	
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
			
	
func newPath (pathWay):
	if pathWay == "END":
		change_to_next_scene()
	else:
		DialogManager.newDialog(pathWay)


func _input(event):
	if end_scene != true:
		if currently_investigating:
			if event is InputEventKey or event is InputEventMouseButton:
				if event.pressed:
					show_Dialog(true)
					Dialog.reset_button()
					currently_investigating = false
		elif gameState == regular:
			if event is InputEventKey:# or event is InputEventMouseButton:
				if event.pressed:
					if currentlyAnimating:
						Dialog.done_Writing()
					elif waitingForSelection:
						pass
					else:
						play_next_dialog();
func show_Dialog(state):
	if state:
		_dialog_tween.interpolate_property(Dialog,"modulate",Dialog.modulate,Color(1,1,1,1),.25)
		_dialog_tween.interpolate_property($NextButton,"modulate",$NextButton.modulate,Color(1,1,1,1),.25)
		
	else:
		_dialog_tween.interpolate_property(Dialog,"modulate",Dialog.modulate,Color(1,1,1,0),.25)
		_dialog_tween.interpolate_property($NextButton,"modulate",$NextButton.modulate,Color(1,1,1,0),.25)
	_dialog_tween.start()
	
func save_settings():
#	ConfigManager.text_speed = text_speed;
	pass

###Post Next Button as we are ready to move on
func next_button_ready():
	NextButton.show()
	pass

func _on_DialogWindow_writingFinished():
	currentlyAnimating = false;
	next_button_ready()
	pass # Replace with function body.


func _on_NextButton_pressed():
	play_next_dialog();
	pass # Replace with function body.




func pause_dialog(state):
	previousState = gameState
	gameState=state;
	Dialog.pause_dialog(gameState);

	
func change_to_next_scene():
#	print ("change scene function here")
	PlayerState.set_Player_Active(true)
	PlayerState.update_dialog(dialog_level_name,dialog_trigger_name,true,playerChoices)
	emit_signal("dialogClosed")
	_dialog_tween.interpolate_property($InvestigationItem,"self_modulate", Color(1,1,1,1), Color(1,1,1,0),0.8)
	_dialog_tween.interpolate_property(Dialog,"modulate", Color(1,1,1,1), Color(1,1,1,0),0.8)
	_dialog_tween.interpolate_property(NextButton,"modulate", Color(1,1,1,1), Color(1,1,1,0),0.8)
	_dialog_tween.start()
	end_scene = true
	pass

func save_state():
#	PlayerGameSave.playerSave = playerPosition;
#	PlayerGameSave.saveGame()
	pass


func _on_DialogWindow_choiceMade(choice):
	previousState = gameState
	gameState = regular
	playerChoices.append(choice)
	PlayerState.update_dialog(dialog_level_name,dialog_trigger_name,true,playerChoices)
	play_next_dialog()
	pass # Replace with function body.



func _on_DialogWindowPanel_investigate():
	show_Dialog(false)
	currently_investigating = true
	pass # Replace with function body.


func _on_InvestigationTween_tween_completed(object, key):
	print(object, key)
	if end_scene:
		if object.self_modulate == Color(1,1,1,0):
			emit_signal("dialogClosed",true)
			self.queue_free()
	else:
		if object == $InvestigationItem and object.self_modulate == Color(1,1,1,0):
			$InvestigationItem.texture = load(pictureFile)
			tween_in_investigation()
		
		elif object == $InvestigationItem and object.self_modulate == Color(1,1,1,1):
			gameState = regular
	pass # Replace with function body.
