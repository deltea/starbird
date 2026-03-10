class_name Player extends CharacterBody2D

const win_star_scene = preload("res://scenes/win-star/win_star.tscn")
const jump_particles_scene = preload("res://scenes/particles/jump_particles.tscn")

@export_category("Movement")
@export var max_speed = 150.0
@export var jump_velocity = 280.0
@export var gravity = 1000.0
@export var fall_gravity = 1400.0
@export var wall_fall_velocity = 80.0
@export var acceleration = 50.0
@export var deceleration = 30.0
@export var coyote_time = 0.15
@export var buffer_time = 0.15
@export var jump_cut_multiplier = 0.5
@export var bounce_velocity = 400.0
@export var dash_velocity = 400.0
@export var down_dash_velocity = 420.0
@export var wall_jump_x_multiplier = 1.2
@export var wall_jump_control_lock_time = 0.08

@export_category("Animation")
@export var squash = 0.6
@export var stretch = 0.4

@onready var sprite: AnimatedSprite2D = $AnimatedSprite
@onready var walk_particles: CPUParticles2D = $WalkParticles
@onready var dash_particles: CPUParticles2D = $DashParticles
@onready var dash_timer: Timer = $DashTimer
@onready var break_area: Area2D = $BreakArea

var jumped = false
var coyote_timer = 0.0
var buffer_timer = buffer_time
var can_move = true
var target_scale = Vector2.ONE;
var target_rot = 0.0;
var is_dashing = false
var is_horizontal_dashing = false
var can_dash = true
var original_particles_x
var wall_jump_lock_timer = 0.0
var wall_jump_target_velocity_x = 0.0
var just_dashed = false

@onready var scale_dynamics: DynamicsSolverVector = Dynamics.create_dynamics_vector(2.0, 0.5, 2.0);
@onready var rot_dynamics: DynamicsSolver = Dynamics.create_dynamics(10.0, 0.8, 10.0);

func _enter_tree() -> void:
	RoomManager.current_room.player = self

func _ready() -> void:
	original_particles_x = walk_particles.position.x

func _process(_dt: float) -> void:
	sprite.scale = scale_dynamics.update(target_scale);
	sprite.rotation_degrees = rot_dynamics.update(target_rot)
	dash_particles.emitting = is_dashing

func _physics_process(delta: float) -> void:
	if can_move: movement(delta)

	var was_on_floor = is_on_floor()
	move_and_slide()

	if not was_on_floor and is_on_floor():
		scale_dynamics.set_value(Vector2.ONE + Vector2(squash, -squash))
		jumped = false
	elif was_on_floor and not is_on_floor() and not jumped:
		coyote_timer = 0.0

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		can_dash = true
		if is_dashing and not is_horizontal_dashing:
			is_dashing = false
			just_dashed = true
			sprite.stop()
			if collision.get_collider() is Bouncepad:
				collision.get_collider().bounce()
				velocity.y = -bounce_velocity
				RoomManager.current_room.camera.impact()
			# else:
			# 	velocity.y = -100.0

func movement(delta: float):
	coyote_timer += delta
	buffer_timer += delta
	if wall_jump_lock_timer > 0.0:
		wall_jump_lock_timer = max(0.0, wall_jump_lock_timer - delta)

	if just_dashed and velocity.y >= 0.0:
		just_dashed = false

	var x_input := Input.get_axis("left", "right")

	if not is_on_floor() and not is_dashing:
		if velocity.y > 0:
			if is_on_wall() and x_input:
				velocity.y = wall_fall_velocity
			else:
				velocity.y += fall_gravity * delta
		else:
			velocity.y += gravity * delta

	if not is_dashing:
		if x_input:
			if wall_jump_lock_timer > 0.0:
				velocity.x = move_toward(velocity.x, wall_jump_target_velocity_x, acceleration * 0.5)
			else:
				velocity.x = move_toward(velocity.x, x_input * max_speed, acceleration)
			sprite.flip_h = x_input < 0
		else:
			if wall_jump_lock_timer > 0.0:
				velocity.x = move_toward(velocity.x, wall_jump_target_velocity_x, deceleration * 0.5)
			else:
				velocity.x = move_toward(velocity.x, 0.0, deceleration)

	if x_input and not is_dashing:
		if is_on_floor():
			# target_rot = sin(Clock.time * 20.0) * 15.0
			target_rot = velocity.x / max_speed * 15.0
			sprite.play("walk")
			walk_particles.emitting = true
			walk_particles.position.x = original_particles_x * x_input
		else:
			target_rot = velocity.x / max_speed * 15.0
			walk_particles.emitting = false
			sprite.play("idle")
	else:
		sprite.play("idle")
		target_rot = 0.0
		walk_particles.emitting = false

	# normal jumping
	if not jumped:
		# buffer jump check
		if Input.is_action_just_pressed("jump") or buffer_timer < buffer_time:
			# coyote jump check
			if is_on_floor() or coyote_timer < coyote_time:
				velocity.y = -jump_velocity
				scale_dynamics.set_value(Vector2.ONE + Vector2(-stretch, stretch))
				rot_dynamics.set_value(sprite.rotation_degrees)
				jumped = true
				spawn_jump_particles()

	# wall jumping
	if Input.is_action_just_pressed("jump") and is_on_wall() and not is_on_floor() and x_input:
		velocity.y = -jump_velocity
		velocity.x = -x_input * max_speed * wall_jump_x_multiplier
		wall_jump_target_velocity_x = velocity.x
		wall_jump_lock_timer = wall_jump_control_lock_time
		scale_dynamics.set_value(Vector2.ONE + Vector2(-stretch, stretch))
		rot_dynamics.set_value(sprite.rotation_degrees)
		jumped = true

	# variable jump height
	if Input.is_action_just_released("jump") and velocity.y < 0.0 and not just_dashed:
		velocity.y *= jump_cut_multiplier

	# buffer jump
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		buffer_timer = 0.0

	# dashing
	if Input.is_action_just_pressed("dash") and not is_dashing and can_dash:
		dash(x_input)

func dash(x_input: float):
	can_dash = false

	for body in break_area.get_overlapping_bodies():
		if body is Breakable:
			break_breakable(body)

	if Input.is_action_pressed("down") and not is_on_floor():
		dash_down()
	elif x_input:
		dash_horizontal(x_input)

func dash_horizontal(x_input: float):
	dash_timer.start()
	is_dashing = true
	is_horizontal_dashing = true
	velocity.x = x_input * dash_velocity
	velocity.y = 0.0
	scale_dynamics.set_value(Vector2.ONE + Vector2(stretch, -stretch))
	RoomManager.current_room.camera.shake(0.15, 2.0)

func dash_down():
	sprite.play("dash_down")
	is_dashing = true
	velocity.y = down_dash_velocity
	scale_dynamics.set_value(Vector2.ONE + Vector2(-stretch, stretch))
	RoomManager.current_room.camera.shake(0.15, 2.0)

func win():
	sprite.play("win")
	can_move = false
	velocity = Vector2.ZERO
	z_index = 20
	walk_particles.visible = false
	dash_particles.visible = false
	RoomManager.current_room.camera.shake(0.25, 4.0)
	var win_star := win_star_scene.instantiate() as WinStar
	win_star.position = position
	RoomManager.current_room.add_child(win_star)
	get_tree().paused = true
	RoomManager.current_room.complete()

func spawn_jump_particles():
	var particles = jump_particles_scene.instantiate() as CPUParticles2D
	particles.position = walk_particles.global_position
	RoomManager.current_room.add_child(particles)
	particles.connect("finished", particles.queue_free)
	particles.emitting = true

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	is_horizontal_dashing = false
	sprite.stop()

func break_breakable(breakable: Breakable) -> void:
	RoomManager.current_room.camera.impact()
	# Clock.hitstop(0.08)
	breakable.on_break()

func _on_break_area_body_entered(body: Node2D) -> void:
	if body is Breakable and is_dashing:
		break_breakable(body)
