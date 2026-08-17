class_name Fisher
extends Node

enum State
{
	IDLE,
	CASTING,
	LURING,
	FIGHTING
};

var rod: Node2D;
var hook: Node2D;

var state: State = State.IDLE;
var style = 0.0;

func register_bite():
	state = State.FIGHTING;
	Services.find(StageEngine).start_combat();
	hook.start_struggle();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	rod = get_node("rod");
	hook = get_node("hook");
	
func _rod_logic(delta):
	if rod.current_cast != null and rod.current_cast.finalized:
		if Input.is_action_just_pressed("game_action"):
			state = State.LURING;
	elif rod.is_casting():
		if Input.is_action_pressed("game_action"):
			rod.tick_cast(delta);
		else:
			rod.finish_cast();
	elif rod.is_ready():
		if Input.is_action_just_pressed("game_action"):
			rod.start_cast();
	else:
		rod.prepare_cast();
	
	rod.display();
			
func _hook_logic():
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
			_rod_logic(delta);
		State.LURING:
			_hook_logic();
		State.FIGHTING:
			_hook_logic();

			if hook.progress >= 1.0:
				var factors = [
					 rod.get_style(),
					 hook.get_style()
				];
				var weights = [
					0.25,
					1.0
				];

				var total_style = 0;
				var total_weight = 0;
				for i in factors.size():
					var factor = factors[i];
					var weight = weights[i];
					total_style += factor * weight;
					total_weight += weight;

				var style = total_style/total_weight;
				var grade = Enums.make_grade(style);
				Services.find(StageEngine).end_stage(grade);

			if hook.health <= 0.0:
				Services.find(StageEngine).lose();
