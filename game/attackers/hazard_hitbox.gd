class_name HazardHitbox
extends Area2D

@export
var damage: float = 0.1;

signal landed(body);

func _collide(body):
	if not body.has_method("queue_attack"):
		return;

	var attack = Attack.new(
		get_parent(),
		global_position, body.global_position - global_position,
		damage
	);
	body.queue_attack(attack);
	landed.emit(body);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_collide);
