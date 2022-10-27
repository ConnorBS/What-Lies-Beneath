extends MenuClass

var _old_sound_volume:float
var _old_voice_volume:float
var _old_music_volume:float
var _old_master_volume:float

onready var _sfxAudioPlayerNode = $OptionSFXAudioPlayer
onready var sfxAudioTest = "res://Assets/Audio/UI/SFXAudioTestVolumeLevel.wav"

func _ready():
	load_window()
	pass # Replace with function body.


func load_window():
	_pull_current_values()
	_set_audio_sliders()
	
func _pull_current_values():
	_old_sound_volume = Settings.get_sound()
	_old_voice_volume = Settings.get_voice()
	_old_music_volume = Settings.get_music()
	_old_master_volume = Settings.get_master()

func _cancel_window()->void:
	Settings.update_sound(_old_sound_volume)
	Settings.update_voice(_old_voice_volume)
	Settings.update_music(_old_music_volume)
	Settings.update_master(_old_master_volume)

func _set_audio_sliders():
	get_node("%SFXHSlider").value = _old_sound_volume
	get_node("%VoiceHSlider").value = _old_voice_volume
	get_node("%MusicHSlider").value = _old_music_volume
	get_node("%MasterHSlider").value = _old_master_volume
	
	


###############################################
###########  Button Presses  ##################
###############################################

func _on_Save_pressed():
	emit_signal("Back")
	pass # Replace with function body.



func _on_Cancel_pressed():
	_cancel_window()
	_set_audio_sliders()
	emit_signal("Back")
	
	pass # Replace with function body.



func _on_SFXHSlider_value_changed(value):
	Settings.update_sound(value)
	pass # Replace with function body.


func _on_MusicHSlider_value_changed(value):
	Settings.update_music(value)
	pass # Replace with function body.


func _on_MasterHSlider_value_changed(value):
	Settings.update_master(value)
	pass # Replace with function body.


func _on_SFXHSlider_drag_started():
	_sfxAudioPlayerNode.stream = load(sfxAudioTest)
	_sfxAudioPlayerNode.play()
	pass # Replace with function body.


func _on_SFXHSlider_drag_ended(_value_changed):
	_sfxAudioPlayerNode.stop()
	pass # Replace with function body.


func _on_VoiceHSlider_value_changed(value):
	Settings.update_voice(value)
	pass # Replace with function body.

