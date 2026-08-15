extends Camera2D

@export
var target: Node2D;

var shake_range: float;
var shake_duration: float;
var shake_time: float;

func start_shake(range, duration):
	shake_range = range;
	shake_duration = duration;
	shake_time = 0;
func tick_shake(delta):
	var range = lerp(shake_range, 0.0, shake_time/shake_duration);
	offset = Vector2(
		randf_range(-range, range),
		randf_range(-range, range)
	);
	shake_time += delta;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;
	
func _physics_process(delta: float) -> void:
	if shake_time < shake_duration:
		tick_shake(delta);
	if target == null:
		return;
	position = lerp(position, target.position, 6 * delta);
