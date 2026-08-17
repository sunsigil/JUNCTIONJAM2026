extends Node2D

@export_category("Floating Movement")
@export var horizontal_range: float = 700.0
@export var horizontal_speed: float = 0.45
@export var bob_height: float = 20.0
@export var bob_speed: float = 1.3
@export_range(-TAU, TAU, 0.01) var phase_offset: float = 0.0

@export_category("Entry Slide")
@export var entry_duration: float = 2.19
@export var entry_offscreen_x: float = 1150.0

var movement_origin: Vector2 = Vector2.ZERO
var movement_time: float = 0.0
var entry_offset: Vector2 = Vector2.ZERO
var entry_elapsed: float = 0.0
var entry_active: bool = false


func _ready() -> void:
	movement_origin = position


func begin_entry() -> void:
	var side := 1.0 if movement_origin.x >= 0.0 else -1.0
	entry_offset = Vector2(side * entry_offscreen_x - movement_origin.x, 0.0)
	entry_elapsed = 0.0
	entry_active = true
	# Place it off-screen immediately; show() can land between physics frames
	# and would otherwise flash the prop at its resting spot for one frame.
	_apply_position()


func _get_entry_offset() -> Vector2:
	if not entry_active:
		return Vector2.ZERO
	var safe_duration := maxf(entry_duration, 0.001)
	var entry_progress := clampf(entry_elapsed / safe_duration, 0.0, 1.0)
	return entry_offset * (1.0 - Curves.ease_out_quad(entry_progress))


func _apply_position() -> void:
	var horizontal_phase := movement_time * horizontal_speed + phase_offset
	var vertical_phase := movement_time * bob_speed + phase_offset
	position = movement_origin + Vector2(
		sin(horizontal_phase) * horizontal_range,
		sin(vertical_phase) * bob_height
	) + _get_entry_offset()


func _physics_process(delta: float) -> void:
	movement_time += delta
	if entry_active:
		entry_elapsed += delta
		if entry_elapsed >= entry_duration:
			entry_active = false
	_apply_position()
