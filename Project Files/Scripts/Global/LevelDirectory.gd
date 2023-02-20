extends Node

const LEVELS = {
	"Outside Gas Station":"res://Scenes/Levels/Gas Station/Outside Gas Station.tscn",
	"Inside Gas Station":"res://Scenes/Levels/Gas Station/Inside Gas Station.tscn"
	}
	
static func lookup_level (level_name):
	if LEVELS.keys().has(level_name):
		return LEVELS[level_name]
	return null
