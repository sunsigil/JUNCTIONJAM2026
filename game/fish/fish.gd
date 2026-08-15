extends Node2D

signal state_changed(state_name: String)

enum State {
	SWIM,
	NIBBLE,
}

const INITIAL_POINTS: Array[Vector2] = [
	Vector2(64.0, 0.0),
	Vector2(30.0, 0.0),
	Vector2(-4.0, 0.0),
	Vector2(-36.0, 0.0),
	Vector2(-64.0, 0.0),
]
const SEGMENT_LENGTHS: Array[float] = [34.0, 34.0, 32.0, 28.0]
const SWIM_COLOR := Color("4bb8de")
const NIBBLE_COLOR := Color("f2a65a")

@export_category("PBD")
@export_range(1, 24, 1) var solver_iterations: int = 8
@export_range(0.0, 1.0, 0.01) var damping: float = 0.92
@export var wake_strength: float = 90.0

@export_category("Debug State Cycle")
@export var auto_cycle_states: bool = true
@export var swim_demo_duration: float = 2.4
@export var nibble_duration: float = 0.8
@export var swim_frequency: float = 0.65
@export var swim_amplitude: float = 14.0
@export_range(1, 8, 1) var nibble_pulse_cycles: int = 2
@export var nibble_distance: float = 12.0

@onready var head: Polygon2D = $Pieces/Head
@onready var upper_body: Polygon2D = $Pieces/UpperBody
@onready var lower_body: Polygon2D = $Pieces/LowerBody
@onready var body_end: Polygon2D = $Pieces/BodyEnd
@onready var tail: Polygon2D = $Pieces/Tail

var points: Array[Vector2] = []
var previous_points: Array[Vector2] = []
var pieces: Array[Polygon2D] = []
var state: State = State.SWIM
var state_origin: Vector2 = INITIAL_POINTS[0]
var state_elapsed: float = 0.0
var motion_time: float = 0.0


func _ready() -> void:
	pieces = [head, upper_body, lower_body, body_end, tail]
	_reset_points()
	_apply_debug_color()
	_update_piece_transforms()
	state_changed.emit(get_state_name())


func _physics_process(delta: float) -> void:
	if state == State.SWIM:
		motion_time += delta
	state_elapsed += delta
	_update_nibble_timeout()
	if auto_cycle_states:
		_update_debug_state_cycle()

	_integrate_points(delta)
	previous_points[0] = points[0]
	points[0] = _get_head_target()
	_solve_distance_constraints()
	_update_piece_transforms()


func start_nibble() -> void:
	_set_state(State.NIBBLE)


func get_state_name() -> String:
	return "nibble" if state == State.NIBBLE else "swim"


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
	for _iteration in range(solver_iterations):
		points[0] = head_target
		for index in range(SEGMENT_LENGTHS.size()):
			var next_index := index + 1
			var offset := points[next_index] - points[index]
			var distance := offset.length()
			if distance <= 0.0001:
				continue

			var correction := offset * ((distance - SEGMENT_LENGTHS[index]) / distance)
			if index == 0:
				points[next_index] -= correction
			else:
				points[index] += correction * 0.5
				points[next_index] -= correction * 0.5


func _get_head_target() -> Vector2:
	if state == State.NIBBLE:
		var safe_duration := maxf(nibble_duration, 0.001)
		var nibble_progress := clampf(state_elapsed / safe_duration, 0.0, 1.0)
		var pulse := sin(nibble_progress * TAU * float(nibble_pulse_cycles))
		return state_origin + Vector2(pulse * nibble_distance, pulse * 2.0)

	var swim_wave := sin(motion_time * TAU * swim_frequency)
	return INITIAL_POINTS[0] + Vector2(0.0, swim_wave * swim_amplitude)


func _update_piece_transforms() -> void:
	for index in range(pieces.size()):
		pieces[index].position = points[index]
		var facing := points[0] - points[1] if index == 0 else points[index - 1] - points[index]
		if not facing.is_zero_approx():
			pieces[index].rotation = facing.angle()


func _update_nibble_timeout() -> void:
	if state == State.NIBBLE and state_elapsed >= nibble_duration:
		_set_state(State.SWIM)


func _update_debug_state_cycle() -> void:
	if state == State.SWIM and state_elapsed >= swim_demo_duration:
		start_nibble()


func _set_state(next_state: State) -> void:
	state_origin = _get_head_target()
	state_elapsed = 0.0
	if state == next_state:
		return

	state = next_state
	_apply_debug_color()
	state_changed.emit(get_state_name())


func _apply_debug_color() -> void:
	var debug_color := NIBBLE_COLOR if state == State.NIBBLE else SWIM_COLOR
	for piece in pieces:
		piece.color = debug_color
