extends Node2D

signal state_changed(state_name: String)
signal nibble_started(lure: Node2D)

enum State {
	SWIM,
	CURIOUS,
	NIBBLE,
}

const INITIAL_POINTS: Array[Vector2] = [
	Vector2(-160.0, 0.0),
	Vector2(-78.5, 0.0),
	Vector2(1.0, 0.0),
	Vector2(59.5, 0.0),
	Vector2(149.5, 0.0),
]
const SEGMENT_LENGTHS: Array[float] = [81.5, 79.5, 58.5, 90.0]
const SHAPE_LENGTHS: Array[float] = [161.0, 138.0, 148.5]
const PIECE_ROTATION_OFFSETS: Array[float] = [
	-PI,
	-PI,
	-PI,
	-PI,
	-PI,
]
const SWIM_COLOR := Color("4bb8de")
const CURIOUS_COLOR := Color("f4d35e")
const NIBBLE_COLOR := Color("f2a65a")
const REQUIRED_LURE_METHODS: Array[StringName] = [
	&"is_fish_on",
	&"start_fish_on",
	&"fail_fish_on",
]

@export_category("PBD")
@export_range(1, 24, 1) var solver_iterations: int = 8
@export_range(0.0, 1.0, 0.01) var damping: float = 0.92
@export_range(0.0, 1.0, 0.01) var shape_stiffness: float = 0.55
@export var wake_strength: float = 120.0

@export_category("PBD Debug")
@export var show_debug_color: bool = false:
	set(value):
		show_debug_color = value
		if is_node_ready():
			_apply_debug_color()
@export var show_pbd_debug: bool = false:
	set(value):
		show_pbd_debug = value
		if is_node_ready():
			_sync_pbd_debug_overlay()

@export_category("Swim Movement")
@export var swim_range: Vector2 = Vector2(620.0, 220.0)
@export var swim_speed: float = 0.55
@export var nibble_swim_speed_scale: float = 0.3
@export var side_to_side_duration: float = 7.0
@export var vertical_swim_duration: float = 4.0
@export var turn_speed: float = 4.0

@export_category("Lure Curiosity")
@export var curiosity_radius: float = 420.0
@export var escape_radius: float = 560.0
@export var curious_speed: float = 220.0
@export var curious_steering: float = 4.0
@export var curious_curve_strength: float = 80.0
@export var curious_curve_frequency: float = 1.25
@export var nibble_reach_distance: float = 70.0
@export var curiosity_cooldown: float = 1.5

@export_category("Debug State Cycle")
@export var auto_cycle_states: bool = false
@export var swim_demo_duration: float = 2.4
@export var nibble_duration: float = 0.8
@export var swim_frequency: float = 0.65
@export var swim_amplitude: float = 14.0
@export_range(1, 8, 1) var nibble_pulse_cycles: int = 2
@export var nibble_distance: float = 12.0

@onready var artwork: Node2D = $Artwork
@onready var pieces_root: Node2D = $Artwork/Pieces
@onready var head: Node2D = $Artwork/Pieces/Head
@onready var upper_body: Node2D = $Artwork/Pieces/UpperBody
@onready var lower_body: Node2D = $Artwork/Pieces/LowerBody
@onready var body_end: Node2D = $Artwork/Pieces/BodyEnd
@onready var tail: Node2D = $Artwork/Pieces/Tail
@onready var connector: FishConnectorOverlay = $Artwork/ConnectorOverlay
@onready var pbd_debug_overlay: PBDDebugOverlay = $PBDDebugOverlay

var points: Array[Vector2] = []
var previous_points: Array[Vector2] = []
var pieces: Array[Node2D] = []
var state: State = State.SWIM
var state_origin: Vector2 = INITIAL_POINTS[0]
var state_elapsed: float = 0.0
var motion_time: float = 0.0
var swim_center: Vector2 = Vector2.ZERO
var swim_phase: float = 0.0
var side_to_side_elapsed: float = 0.0
var vertical_swim_phase: float = 0.0
var vertical_swim_active: bool = false
var target_lure: Node2D
var curious_velocity: Vector2 = Vector2.ZERO
var curiosity_cooldown_remaining: float = 0.0


func _ready() -> void:
	pieces = [head, upper_body, lower_body, body_end, tail]
	connector.set_rest_points(INITIAL_POINTS)
	swim_center = position
	_reset_points()
	_sync_pbd_debug_overlay()
	_apply_debug_color()
	_update_piece_transforms()
	state_changed.emit(get_state_name())


func _physics_process(delta: float) -> void:
	if state == State.SWIM:
		motion_time += delta
	state_elapsed += delta
	_update_behavior(delta)

	_integrate_points(delta)
	previous_points[0] = points[0]
	points[0] = _get_head_target()
	_solve_distance_constraints()
	_update_piece_transforms()


func start_nibble() -> void:
	_set_state(State.NIBBLE)


func get_state_name() -> String:
	match state:
		State.CURIOUS:
			return "curious"
		State.NIBBLE:
			return "nibble"
		_:
			return "swim"


func _update_behavior(delta: float) -> void:
	match state:
		State.SWIM:
			_update_swim_movement(delta)
			curiosity_cooldown_remaining = maxf(
				curiosity_cooldown_remaining - delta,
				0.0
			)
			if is_zero_approx(curiosity_cooldown_remaining):
				_try_start_curiosity()
		State.CURIOUS:
			_update_curiosity(delta)
		State.NIBBLE:
			_update_nibble_movement(delta)


func _try_start_curiosity() -> void:
	var nearest_lure: Node2D
	var nearest_distance := INF
	for candidate in get_tree().get_nodes_in_group("lure"):
		if not candidate is Node2D:
			continue
		var lure := candidate as Node2D
		if not _has_lure_interface(lure):
			continue
		var fisher := lure.get_parent() as Fisher
		if fisher == null or fisher.state != Fisher.State.LURING:
			continue
		if bool(lure.call("is_fish_on")):
			continue

		var distance := global_position.distance_to(lure.global_position)
		if distance <= curiosity_radius and distance < nearest_distance:
			nearest_lure = lure
			nearest_distance = distance

	if nearest_lure == null:
		return

	target_lure = nearest_lure
	curious_velocity = Vector2.ZERO
	_set_state(State.CURIOUS)


func _has_lure_interface(lure: Node2D) -> bool:
	for method in REQUIRED_LURE_METHODS:
		if not lure.has_method(method):
			return false
	return true


func _update_curiosity(delta: float) -> void:
	if not is_instance_valid(target_lure):
		_return_to_swim()
		return
	if not _has_lure_interface(target_lure):
		_return_to_swim()
		return
	var fisher := target_lure.get_parent() as Fisher
	if fisher == null or fisher.state != Fisher.State.LURING:
		_return_to_swim()
		return
	if bool(target_lure.call("is_fish_on")) or _is_lure_beyond_escape(target_lure):
		_return_to_swim()
		return
	if _get_world_head_position().distance_to(target_lure.global_position) <= nibble_reach_distance:
		_start_lure_nibble()
		return

	var to_lure := target_lure.global_position - global_position
	if to_lure.is_zero_approx():
		_start_lure_nibble()
		return

	var direction := to_lure.normalized()
	var curve_phase := state_elapsed * TAU * curious_curve_frequency
	var curve_velocity := direction.orthogonal() * sin(curve_phase) * curious_curve_strength
	var desired_velocity := direction * curious_speed + curve_velocity
	var steering_weight := clampf(curious_steering * delta, 0.0, 1.0)
	curious_velocity = curious_velocity.lerp(desired_velocity, steering_weight)
	global_position += curious_velocity * delta

	if not curious_velocity.is_zero_approx():
		var turn_weight := clampf(turn_speed * delta, 0.0, 1.0)
		var target_heading := curious_velocity.angle() + PI
		rotation = lerp_angle(rotation, target_heading, turn_weight)

	if _get_world_head_position().distance_to(target_lure.global_position) <= nibble_reach_distance:
		_start_lure_nibble()


func _start_lure_nibble() -> void:
	var lure := target_lure
	_set_state(State.NIBBLE)
	nibble_started.emit(target_lure)
	if not is_instance_valid(lure) or not bool(lure.call("start_fish_on", self)):
		_return_to_swim()


func _update_nibble_movement(_delta: float) -> void:
	if not is_instance_valid(target_lure):
		_return_to_swim()
		return
	if not _has_lure_interface(target_lure):
		_return_to_swim()
		return
	if not bool(target_lure.call("is_fish_on")):
		_return_to_swim()
		return

	var lure := target_lure
	var fisher := lure.get_parent() as Fisher
	if fisher == null or fisher.state != Fisher.State.FIGHTING or _is_lure_beyond_escape(lure):
		target_lure = null
		curious_velocity = Vector2.ZERO
		lure.call("fail_fish_on")
		return

	var hook_body := lure as CharacterBody2D
	if hook_body != null:
		_anchor_to_hook(hook_body)

func sync_to_hook(hook_body: CharacterBody2D, delta: float) -> void:
	if state != State.NIBBLE or target_lure != hook_body:
		return
	if not hook_body.velocity.is_zero_approx():
		var target_heading := hook_body.velocity.angle() + PI
		var turn_weight := 1.0 - exp(-turn_speed * delta)
		rotation = lerp_angle(rotation, target_heading, turn_weight)
	_anchor_to_hook(hook_body)


func _anchor_to_hook(hook_body: CharacterBody2D) -> void:
	var target_head_offset := to_global(_get_head_target()) - global_position
	global_position = hook_body.global_position - target_head_offset


func _is_lure_beyond_escape(lure: Node2D) -> bool:
	if global_position.distance_to(lure.global_position) > escape_radius:
		return true
	return _get_world_head_position().distance_to(lure.global_position) > escape_radius


func _get_world_head_position() -> Vector2:
	if points.is_empty():
		return global_position
	return to_global(points[0])


func _return_to_swim() -> void:
	_set_state(State.SWIM)
	swim_center = position
	swim_phase = 0.0
	side_to_side_elapsed = 0.0
	vertical_swim_phase = 0.0
	vertical_swim_active = false
	motion_time = 0.0
	target_lure = null
	curious_velocity = Vector2.ZERO
	curiosity_cooldown_remaining = curiosity_cooldown


func _reset_points() -> void:
	points.clear()
	previous_points.clear()
	for initial_point in INITIAL_POINTS:
		points.append(initial_point)
		previous_points.append(initial_point)


func _integrate_points(delta: float) -> void:
	for index in range(1, points.size()):
		var current_position := points[index]
		var velocity := (points[index] - previous_points[index]) * damping
		var wake_phase := motion_time * TAU - float(index) * 0.7
		var wake := Vector2(0.0, sin(wake_phase) * wake_strength * delta * delta)
		previous_points[index] = current_position
		points[index] = current_position + velocity + wake


func _solve_distance_constraints() -> void:
	var head_target := points[0]
	var shape_iteration_stiffness := _get_shape_iteration_stiffness()
	for _iteration in range(solver_iterations):
		points[0] = head_target
		for index in range(SEGMENT_LENGTHS.size()):
			_solve_constraint(index, index + 1, SEGMENT_LENGTHS[index], 1.0)
		for index in range(SHAPE_LENGTHS.size()):
			_solve_constraint(index, index + 2, SHAPE_LENGTHS[index], shape_iteration_stiffness)
	points[0] = head_target


func _get_shape_iteration_stiffness() -> float:
	var safe_iterations := maxi(solver_iterations, 1)
	return 1.0 - pow(1.0 - shape_stiffness, 1.0 / float(safe_iterations))

func _solve_constraint(
		first_index: int,
		second_index: int,
		rest_length: float,
		stiffness: float
) -> void:
	var offset := points[second_index] - points[first_index]
	var distance := offset.length()
	if distance <= 0.0001:
		return

	var correction := offset * ((distance - rest_length) / distance) * stiffness
	if first_index == 0:
		points[second_index] -= correction
	else:
		points[first_index] += correction * 0.5
		points[second_index] -= correction * 0.5


func _update_swim_movement(delta: float) -> void:
	var speed_scale := nibble_swim_speed_scale if state == State.NIBBLE else 1.0
	var movement_delta := delta * speed_scale
	swim_phase = fmod(swim_phase + movement_delta * swim_speed, TAU)

	if vertical_swim_active:
		var safe_vertical_duration := maxf(vertical_swim_duration, 0.001)
		vertical_swim_phase += movement_delta * TAU / safe_vertical_duration
		if vertical_swim_phase >= TAU:
			vertical_swim_active = false
			vertical_swim_phase = 0.0
			side_to_side_elapsed = 0.0
	else:
		side_to_side_elapsed += movement_delta
		if side_to_side_elapsed >= side_to_side_duration:
			vertical_swim_active = true
			vertical_swim_phase = 0.0

	position = swim_center + _get_swim_offset()
	var tangent := _get_swim_tangent()
	if not tangent.is_zero_approx():
		var turn_weight := clampf(turn_speed * delta, 0.0, 1.0)
		var target_heading := tangent.angle() + PI
		rotation = lerp_angle(rotation, target_heading, turn_weight)


func _get_swim_offset() -> Vector2:
	var vertical_offset := 0.0
	if vertical_swim_active:
		vertical_offset = sin(vertical_swim_phase) * swim_range.y
	return Vector2(sin(swim_phase) * swim_range.x, vertical_offset)


func _get_swim_tangent() -> Vector2:
	var horizontal_velocity := cos(swim_phase) * swim_range.x * swim_speed
	var vertical_velocity := 0.0
	if vertical_swim_active:
		var safe_vertical_duration := maxf(vertical_swim_duration, 0.001)
		vertical_velocity = cos(vertical_swim_phase) * swim_range.y * TAU / safe_vertical_duration
	return Vector2(horizontal_velocity, vertical_velocity)


func _get_head_target() -> Vector2:
	if state == State.NIBBLE:
		var pulse := _get_nibble_pulse()
		return state_origin + Vector2(pulse * nibble_distance, pulse * 2.0)

	var swim_wave := sin(motion_time * TAU * swim_frequency)
	return INITIAL_POINTS[0] + Vector2(0.0, swim_wave * swim_amplitude)


func _get_nibble_pulse() -> float:
	var safe_duration := maxf(nibble_duration, 0.001)
	var nibble_progress := state_elapsed / safe_duration
	return sin(nibble_progress * TAU * float(nibble_pulse_cycles))


func _update_piece_transforms() -> void:
	for index in range(pieces.size()):
		pieces[index].position = points[index]
		var facing := points[0] - points[1] if index == 0 else points[index - 1] - points[index]
		if not facing.is_zero_approx():
			pieces[index].rotation = facing.angle() + PIECE_ROTATION_OFFSETS[index]
	connector.set_points(points)
	_sync_pbd_debug_overlay()


func _sync_pbd_debug_overlay() -> void:
	pbd_debug_overlay.visible = show_pbd_debug
	if show_pbd_debug:
		pbd_debug_overlay.set_debug_points(points.duplicate())


func _update_nibble_timeout() -> void:
	if state == State.NIBBLE and state_elapsed >= nibble_duration:
		_set_state(State.SWIM)


func _update_debug_state_cycle() -> void:
	if state == State.SWIM and state_elapsed >= swim_demo_duration:
		start_nibble()


func _set_state(next_state: State) -> void:
	if state == next_state:
		return

	state_origin = _get_head_target()
	state_elapsed = 0.0
	state = next_state
	_apply_debug_color()
	state_changed.emit(get_state_name())


func _apply_debug_color() -> void:
	if not show_debug_color:
		artwork.modulate = Color.WHITE
		return

	var debug_color := SWIM_COLOR
	if state == State.CURIOUS:
		debug_color = CURIOUS_COLOR
	elif state == State.NIBBLE:
		debug_color = NIBBLE_COLOR
	artwork.modulate = debug_color
