class_name FakeStar extends Node2D

@onready var particles: CPUParticles2D = $Particles

var target_x = 0.0
var speed = 0.0
var rotation_dir = 1.0
var rotation_gain = 0.0
var rotation_speed = 60.0
var speed_gain = 0.0

func _ready() -> void:
	rotation_dir = 1 if randf() > 0.5 else -1
	rotation_gain = randf_range(10, 100)
	particles.emitting = false
	speed = randf_range(30.0, 80.0)
	speed_gain = randf_range(50.0, 100.0)
	target_x = position.x + randf_range(-150.0, 150.0)

	await Clock.wait(1.0)
	particles.emitting = true

func _process(dt: float) -> void:
	rotation_speed += rotation_gain * dt
	rotation_degrees += rotation_dir * rotation_speed * dt
	position.x = lerp(position.x, target_x, 0.5 * dt)
	scale = scale.lerp(Vector2.ONE * randf_range(1, 2), 2.0 * dt)
	speed += speed_gain * dt
	position.y -= speed * dt

func _on_kill_timer_timeout():
	queue_free()
