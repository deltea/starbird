@tool
class_name SecretArea extends Area2D

@export var hidden_color: Color = Color.BLACK
@export var visible_color: Color = Color("#222222")

@onready var tilemap: TileMapLayer = $TileMapLayer

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		tilemap.self_modulate = visible_color
		z_index = -10

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		tilemap.self_modulate = hidden_color
		z_index = 10
