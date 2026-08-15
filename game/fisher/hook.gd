extends CharacterBody2D
var _display: bool;
func display():
	_display = true;

@export
var radius: float = 50;

@export
var speed: float = 600;
@export
var heading_weight: float = 2;
@export
var heading_delay: float = 1;
@export
var velocity_delay: float = 0.1;

var buffered_input: Vector2;
var input: Vector2;
var input_last: Vector2;
var input_delta: Vector2;
var input_weight: Vector2;
var weight_time: float;
var heading: Vector2;
	
func move(dir: Vector2):
	buffered_input = dir;

func _ready() -> void:
	pass;

func _process(delta):
	input_last = input;
	input = buffered_input;
	input_delta = input - input_last;
	
	heading = input.normalized();
	if input_delta != Vector2.ZERO:
		input_weight = abs(input_delta) * heading * heading_weight;
		weight_time = 0;
	if weight_time <= heading_delay:
		heading += input_weight;
		input_weight = lerp(input_weight, Vector2.ZERO, weight_time/heading_delay);
		weight_time += delta;
	velocity = lerp(velocity, heading*speed, delta/velocity_delay);
	move_and_slide();
	
	queue_redraw();
	
func _draw():
	if not _display:
		return;
	_display = false;
		
	draw_circle(position, radius, Color.WHITE, false);
	
	var scale_factor = 200;
	draw_line(position, input.rotated(-rotation) * scale_factor, Color.BLUE);
	draw_line(position, heading.rotated(-rotation) * scale_factor, Color.RED);
	draw_line(position, velocity.normalized().rotated(-rotation) * scale_factor, Color.GREEN);
