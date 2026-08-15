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
	
func rod_logic(delta):
	if rod.is_casting():
		if Input.is_action_pressed("game_action"):
			rod.tick_cast(delta);
		else:
			rod.finish_cast();
			state = State.LURING;
	elif rod.is_ready():
		if Input.is_action_just_pressed("game_action"):
			rod.start_cast();
	else:
		if Input.is_action_just_released("game_action"):
			rod.prepare_cast();
	
	rod.display();
			
func hook_logic():
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
	
	hook.display();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		State.IDLE:
			state = State.CASTING;
		State.CASTING:
			rod_logic(delta);
		State.LURING:
			hook_logic();
