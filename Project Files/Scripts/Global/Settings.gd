extends Node

var _soundVolume = .55
var _musicVolume = .75
var _masterVolume = 1.0

func _ready():
	update_audio_bus_configurations()

func get_sound()->float:
	return _soundVolume

func get_music() ->float:
	return _musicVolume
	
func get_master() ->float:
	return _masterVolume


func update_sound (soundVolumeNow = _soundVolume):
	_soundVolume = soundVolumeNow;
	update_audio_bus_configurations()
	pass
	
func update_music(musicVolumeNow = _musicVolume):
	_musicVolume = musicVolumeNow
	update_audio_bus_configurations()
	pass
	
func update_master(masterVolumeNow = _masterVolume):
	_masterVolume = masterVolumeNow
	update_audio_bus_configurations()
	pass

func update_all_music_and_sound():
	update_sound();
	update_music();
	update_master()


func _on__musicVolume_value_changed(value):
	pass # Replace with function body.


func _on__soundVolume_value_changed(value):
	pass # Replace with function body.

func update_audio_bus_configurations():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SoundEffect"),linear2db(_soundVolume));
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear2db(_musicVolume));
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear2db(_masterVolume));
	print("Sound: ", _soundVolume, " || Music: ", _musicVolume, " || Master: ",_masterVolume)