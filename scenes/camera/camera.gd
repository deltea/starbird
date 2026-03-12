class_name Camera extends Camera2D

@export var follow: Node2D
@export var bounds: Polygon2D
@export var rotation_speed = 5.0
@export var impact_rotation = 5.0
@export var shake_damping_speed = 2.0

@onready var rot_dynamics: DynamicsSolver = Dynamics.create_dynamics(rotation_speed, 0.8, 10.0)

var shake_duration = 0;
var shake_magnitude = 0;
var original_pos = Vector2.ZERO;
var target_zoom = Vector2.ONE
var target_pos
var is_constrained = true

func _enter_tree() -> void:
	RoomManager.current_room.camera = self

func _ready() -> void:
	original_pos = offset
	target_pos = global_position

	reset_smoothing()

func _process(dt: float) -> void:
	rotation_degrees = rot_dynamics.update(0.0)

	if follow:
		target_pos = follow.global_position

	if is_constrained:
		target_pos = constrain_camera(target_pos)
	global_position = global_position.lerp(target_pos, 10.0 * dt)

	if shake_duration > 0:
		offset = original_pos + Vector2.from_angle(randf_range(0, PI*2)) * shake_magnitude
		shake_duration -= dt * shake_damping_speed
	else:
		shake_duration = 0
		offset = original_pos

func shake(duration: float, magnitude: float):
	shake_duration = duration
	shake_magnitude = magnitude

func impact(dir: float = 0):
	if dir == 0:
		rot_dynamics.set_value((1 if randf() > 0.5 else -1) * impact_rotation)
	else:
		rot_dynamics.set_value(impact_rotation * dir)

func get_half_view_size() -> Vector2:
	var viewport_size := get_viewport_rect().size
	return (viewport_size * 0.5) * zoom

func all_corners_inside(center_world: Vector2) -> bool:
	if not bounds:
		return true

	var half_size := get_half_view_size()
	var corners := [
		center_world + Vector2(-half_size.x, -half_size.y),
		center_world + Vector2(half_size.x, -half_size.y),
		center_world + Vector2(half_size.x, half_size.y),
		center_world + Vector2(-half_size.x, half_size.y),
	]

	for corner_world in corners:
		var corner_local: Vector2 = corner_world - bounds.global_position
		if not Geometry2D.is_point_in_polygon(corner_local, bounds.polygon):
			return false

	return true

func constrain_camera(desired_center_world: Vector2) -> Vector2:
	if not bounds:
		return desired_center_world

	if all_corners_inside(desired_center_world):
		return desired_center_world

	var corrected := desired_center_world
	var half_size := get_half_view_size()
	var corner_offsets := [
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(half_size.x, half_size.y),
		Vector2(-half_size.x, half_size.y),
	]

	for _i in range(10):
		var correction := Vector2.ZERO
		var outside_count := 0

		for corner_offset in corner_offsets:
			var corner_world: Vector2 = corrected + corner_offset
			var corner_local: Vector2 = corner_world - bounds.global_position
			if Geometry2D.is_point_in_polygon(corner_local, bounds.polygon):
				continue

			var closest_local: Vector2 = bounds.closest_point_on_polygon(corner_local, bounds.polygon)
			correction += (closest_local - corner_local)
			outside_count += 1

		if outside_count == 0:
			break

		corrected += correction / float(outside_count)

	return corrected
