class_name Room extends Node2D

@export var palette: Texture2D
@export var limit_x = 1000.0
@export var limit_y = 1000.0

var camera: Camera

func _enter_tree() -> void:
	RoomManager.current_room = self

func _ready() -> void:
	PaletteFilter.set_color_palette(palette)
	PaletteFilter.set_brightness(1.0)
