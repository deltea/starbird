class_name Mushroom extends Bouncepad

func bounce() -> void:
	AudioManager.play_sound(AudioManager.mushroom, 0.2)
	scale_dynamics.set_value(Vector2.ONE + Vector2(0.4, -0.8))
	var particles := particles_scene.instantiate() as CPUParticles2D
	particles.global_position = sprite.global_position
	particles.finished.connect(particles.queue_free)
	particles.emitting = true
	RoomManager.current_room.add_child(particles)
