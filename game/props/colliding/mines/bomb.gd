extends Node2D

@export var horizontal_range: float = 700.0
@export var horizontal_speed: float = 0.45
@export var bob_height: float = 20.0
@export var bob_speed: float = 1.3
@export var rotation_speed: float = 0.3

@onready var visual: Node2D = $Visual



var origin: Vector2 = Vector2.ZERO
var movement_time: float = 0.0


func _ready() -> void:
	origin = position


func _physics_process(delta: float) -> void:
	movement_time += delta
	var horizontal_offset := sin(movement_time * horizontal_speed) * horizontal_range
	var vertical_offset := sin(movement_time * bob_speed) * bob_height
	position = origin + Vector2(horizontal_offset, vertical_offset)
	visual.rotation += rotation_speed * delta
