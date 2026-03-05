class_name Collectable extends Area2D

@onready var sprite: Star2D = $Star2D

@onready var scale_dynamics: DynamicsSolverVector = Dynamics.create_dynamics_vector(0.8, 0.2, 2.0);
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var particles: CPUParticles2D = $Particles

var rot_speed = 1.5
var target_scale = Vector2.ONE

func _process(dt: float) -> void:
	sprite.rotation += dt * rot_speed
	sprite.position.y = sin(Clock.time * 2.0) * 4.0
	sprite.scale = scale_dynamics.update(target_scale)
	# bug: make the particles scale with the star and not disappear
	particles.scale = sprite.scale
	# sprite.scale = Vector2.ONE * (1.0 + sin(Clock.time * 2.0) * 0.08)

	if sprite.scale <= Vector2.ZERO:
		queue_free()

func collect():
	collider.set_deferred("disabled", true)
	rot_speed = 5.0
	scale_dynamics.set_value(Vector2.ONE * 1.5)
	target_scale = Vector2.ZERO
	RoomManager.current_room.stars_collected += 1

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collect()
