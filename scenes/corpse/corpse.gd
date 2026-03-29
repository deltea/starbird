class_name Corpse extends AnimatedSprite2D

@export var initial_x_velocity = 100
@export var initial_y_velocity = -200
@export var gravity = 500.0

var velocity = Vector2.ZERO

func _ready() -> void:
	velocity = Vector2(initial_x_velocity if randf() > 0.5 else -initial_x_velocity, initial_y_velocity)

	await Clock.wait(5.0)
	queue_free()

func _process(dt: float) -> void:
	rotation_degrees += 720 * dt

func _physics_process(dt: float) -> void:
	velocity.y += gravity * dt
	position += velocity * dt
