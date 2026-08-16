extends "res://props/floating_prop.gd"

@export var rotation_speed: float = 0.3

@onready var visual: Node2D = $Visual


func _physics_process(delta: float) -> void:
	super(delta)
	visual.rotation += rotation_speed * delta
