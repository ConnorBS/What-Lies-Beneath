extends Node

var level_width = 2022
var level_height = 360

func _ready():
	$FogShader.rect_size = Vector2(level_width,level_height)
