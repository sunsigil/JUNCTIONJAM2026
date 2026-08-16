extends CharacterBody2D;

var shooter;
var attack_cooldown;
var sprite: AnimatedSprite2D;
var player: Node2D = null;

func target_vector():
	return player.global_position - global_position;
func target_distance():
	return target_vector().length();

func is_attacking():
	return false;

func should_attack():
	if is_attacking():
		return false;
	if not attack_cooldown.is_stopped():
		return false;
	return true;

func attack():
	if not should_attack():
		return;

	var trajectory = target_vector();
	shooter.shoot(trajectory);
			
	attack_cooldown.start();
	await attack_cooldown.timeout;
	attack_cooldown.stop();


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shooter = get_node("shooter");
	attack_cooldown = get_node("attack_cooldown");
	#sprite = get_node("AnimatedSprite2D");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player").get_node("hook");

func _physics_process(delta: float) -> void:
	if player == null:
		return;
	attack();
	if is_attacking():
		velocity = Vector2.ZERO;
	move_and_slide();
