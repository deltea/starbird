extends Room

const countdown_rot = 10.0

@onready var time_label: RichTextLabel = $CanvasLayer/TimeLabel
@onready var countdown: Control = $CanvasLayer/Countdown
@onready var countdown_label: Label = $CanvasLayer/Countdown/CountdownLabel
@onready var countdown_background: ColorRect = $CanvasLayer/Countdown/CountdownBackground
@onready var countdown_scale_dynamics: DynamicsSolverVector = Dynamics.create_dynamics_vector(3.0, 0.15, 10.0)
@onready var countdown_rot_dynamics: DynamicsSolver = Dynamics.create_dynamics(3.0, 0.5, 10.0)

var player: Player

var is_completed = false
var countdown_scale_target = Vector2.ONE
var countdown_rot_target = 360.0
var stars_collected = 0

func _ready() -> void:
	get_tree().paused = true
	player.can_move = false

	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(countdown_rot)
	countdown_rot_target = 360.0 - countdown_rot
	countdown_label.text = "3"

	await Clock.wait(0.6)
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(-countdown_rot)
	countdown_rot_target = 360.0 + countdown_rot
	countdown_label.text = "2"

	await Clock.wait(0.6)
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(countdown_rot)
	countdown_rot_target = 360.0 - countdown_rot
	countdown_label.text = "1"

	await Clock.wait(0.6)
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(-countdown_rot)
	countdown_rot_target = 360.0 + countdown_rot
	countdown_label.text = "GO!"

	await Clock.wait(0.4)
	get_tree().paused = false
	player.can_move = true

	await Clock.wait(0.4)
	countdown_scale_target = Vector2.ZERO
	await Clock.wait(0.1)
	countdown.visible = false

func complete():
	is_completed = true
	await Clock.wait(1.0)
	PaletteFilter.set_brightness(0.25)
	$CompleteCanvas.visible = true
	$CompleteCanvas/SubViewportContainer/SubViewport/AnimationPlayer.play("complete")

func _process(dt: float) -> void:
	countdown.scale = countdown_scale_dynamics.update(countdown_scale_target)
	countdown_label.rotation_degrees = countdown_rot_dynamics.update(countdown_rot_target)
	countdown_background.rotation_degrees = Clock.time * 200.0

	if not is_completed:
		time_label.text = "[wave]%.2f[/wave]" % Clock.time
