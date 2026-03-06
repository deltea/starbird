@tool
class_name EnvironmentParticles extends CPUParticles2D

@export var density = 1.0:
	set(value):
		density = value
		change_amount(value)

func _ready() -> void:
	change_amount(density)

func change_amount(value: int) -> void:
	amount = emission_rect_extents.x * emission_rect_extents.y * density * 0.001
