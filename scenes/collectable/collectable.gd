class_name Collectable extends Area2D

@onready var sprite: Star2D = $Star2D

@onready var scale_dynamics: DynamicsSolverVector = Dynamics.create_dynamics_vector(0.8, 0.2, 2.0);
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var particles: CPUParticles2D = $Particles

var rot_speed = 50.0
var target_scale = Vector2.ONE
var target_rot = 0.0
var target_pos: Vector2
var is_collected = false

func _ready() -> void:
	target_pos = position

func _process(dt: float) -> void:
	target_rot += dt * rot_speed
	sprite.rotation_degrees = lerp(sprite.rotation_degrees, target_rot, dt * 4.0)
	if not is_collected:
		sprite.position.y = sin(Clock.time * 2.0) * 4.0
		sprite.scale = scale_dynamics.update(target_scale)
	particles.scale = sprite.scale
	global_position = global_position.lerp(target_pos, dt * 4.0)

func collect():
	AudioManager.play_sound(AudioManager.star)
	is_collected = true
	collider.set_deferred("disabled", true)
	target_rot += 360.0
	rot_speed = 160.0
	scale_dynamics.set_value(Vector2.ONE * 1.5)
	sprite.position.y = 0.0
	sprite.scale = Vector2.ONE
	z_index = 20
	RoomManager.current_room.collect_star(self)
	particles.emitting = false
	await Clock.wait(0.75)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collect()
