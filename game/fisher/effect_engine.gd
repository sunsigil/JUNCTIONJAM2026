extends Node

var camera: Camera2D;
var hitstop: Timer;

func start_hitstop(slow, slow_time, shake, shake_time):
	if slow_time > 0:
		Engine.time_scale = slow;
		hitstop.wait_time = slow_time;
		hitstop.start();
		await hitstop.timeout;
	Engine.time_scale = 1;
	camera.start_shake(shake, shake_time);
func major_hitstop_callback():
	start_hitstop(0, 0.1, 20, 0.15);
func minor_hitstop_callback():
	start_hitstop(0, 0.05, 10, 0.005);
func hurtstop_callback():
	start_hitstop(0.5, 0.25, 10, 0.25);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
