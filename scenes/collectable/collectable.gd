class_name Collectable extends Area2D

@onready var sprite: Star2D = $Star2D

func _process(dt: float) -> void:
	sprite.rotation += dt * 1.5
	sprite.position.y = sin(Clock.time * 2.0) * 4.0
	# sprite.scale = Vector2.ONE * (1.0 + sin(Clock.time * 2.0) * 0.08)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		queue_free()
