class_name Bouncepad extends StaticBody2D

const particles_scene = preload("res://scenes/particles/bounce_particles.tscn")

@onready var sprite: Sprite2D = $Sprite

@onready var scale_dynamics: DynamicsSolverVector = Dynamics.create_dynamics_vector(5.0, 0.2, 2.0)

func _process(dt: float) -> void:
	sprite.scale = scale_dynamics.update(Vector2.ONE)

func bounce() -> void:
	AudioManager.play_sound(AudioManager.bouncepad, 0.2)
	scale_dynamics.set_value(Vector2.ONE + Vector2(0.4, -0.8))
	var particles := particles_scene.instantiate() as CPUParticles2D
	particles.global_position = sprite.global_position
	particles.finished.connect(particles.queue_free)
	particles.emitting = true
	RoomManager.current_room.add_child(particles)
