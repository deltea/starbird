class_name MainMenu extends Room

@onready var star: Star2D = $Star2D
@onready var title_star: Star2D = $Title/Star

func _process(dt: float) -> void:
	star.rotation_degrees += 20.0 * dt
	title_star.rotation_degrees += 160.0 * dt
