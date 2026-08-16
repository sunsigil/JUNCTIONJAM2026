class_name Attack;

var owner: Node2D;
var start: Vector2;
var direction: Vector2;
var damage: float;

func _init(_owner, _start, _direction, _damage):
	owner = _owner;
	start = _start;
	direction = _direction.normalized();
	damage = _damage;
