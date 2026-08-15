extends Node

enum State
{
	IDLE,
	CASTING,
	LURING
};

var rod: Node2D;
var hook: Node2D;

var state: State = State.IDLE;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rod = get_node("rod");
	hook = get_node("hook");
	
func rod_input(delta):
	if rod.is_casting():
		if Input.is_action_pressed("game_action"):
			rod.tick_cast(delta);
		else:
			rod.finish_cast();
			state = State.LURING;
	else:
		if Input.is_action_just_pressed("game_action"):
			rod.start_cast();
			
func hook_input():
	var input = Vector2.ZERO;
	if Input.is_action_pressed("game_right"):
		input.x += 1;
	if Input.is_action_pressed("game_up"):
		input.y -= 1;
	if Input.is_action_pressed("game_left"):
		input.x -= 1;
	if Input.is_action_pressed("game_down"):
		input.y += 1;
	hook.move(input);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		State.IDLE:
			state = State.CASTING;
		State.CASTING:
			rod_input(delta);
		State.LURING:
			hook_input();
		
