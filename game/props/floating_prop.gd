extends Node2D

@export_category("Floating Movement")
@export var horizontal_range: float = 700.0
@export var horizontal_speed: float = 0.45
@export var bob_height: float = 20.0
@export var bob_speed: float = 1.3
@export_range(-TAU, TAU, 0.01) var phase_offset: float = 0.0

var movement_origin: Vector2 = Vector2.ZERO
var movement_time: float = 0.0


func _ready() -> void:
	movement_origin = position


func _physics_process(delta: float) -> void:
	movement_time += delta
	var horizontal_phase := movement_time * horizontal_speed + phase_offset
	var vertical_phase := movement_time * bob_speed + phase_offset
	position = movement_origin + Vector2(
		sin(horizontal_phase) * horizontal_range,
		sin(vertical_phase) * bob_height
	)
