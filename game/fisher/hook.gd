class_name Hook
extends CharacterBody2D
var _display: bool;
func display():
	_display = true;

enum TargetState {
	IDLE,
	RETARGET
};

const radius: float = 40;
const orbit_dist: float = 60; 

const speed: float = 800;
const heading_weight: float = 2;
const heading_delay: float = 1;
const velocity_delay: float = 0.1;

const min_retarget_dist = 0.15;
const max_retarget_dist = 0.75;
const turn_prob: float = 0.5;
const min_retarget_wait: float = 1.5;
const max_retarget_wait: float = 3.5;
const min_retarget_speed: float = 1.0;
const max_retarget_speed: float = 3.0;

const reticle_tolerance: float = 0.1;
const progress_grow: float = 1.0/6.0;
const progress_decay: float = 1.0/16.0;

var buffered_input: Vector2;
var input: Vector2;
var input_last: Vector2;
var input_delta: Vector2;
var input_weight: Vector2;
var weight_time: float;
var heading: Vector2;

var is_targeting: bool;
var reticle_angle: float;
var reticle_uptime: float;
var reticle_downtime: float;

var target_angle: float;
var retarget_angle: float;
var retarget_dir: float = 1.0;

var retarget_speed: float;
var retarget_timer: Timer;
var target_state: TargetState;

var progress = 0.0;
var on_time: float;
var off_time: float;
var hit_count: int;

var health = 1.0;
var attack_queue: Array[Attack];
var hitstop: Timer;
var hurt_cooldown: Timer;
var attached_fish: Node2D;


func start_fish_on(fish: Node2D) -> bool:
	var fisher := get_parent() as Fisher;
	if fisher == null or fisher.state != Fisher.State.LURING:
		return false;
	if not is_instance_valid(fish) or is_fish_on():
		return false;

	attached_fish = fish;
	attack_queue.clear();
	_reset_minigame_counters();
	fisher.register_bite();
	return true;


func is_fish_on() -> bool:
	return is_instance_valid(attached_fish);


func stop_fish_on() -> void:
	attached_fish = null;
	attack_queue.clear();
	_reset_minigame_counters();


func fail_fish_on() -> void:
	stop_fish_on();
	Services.find(StageEngine).lose();


func _reset_minigame_counters() -> void:
	is_targeting = false;
	progress = 0.0;
	reticle_angle = 0.5;
	reticle_uptime = 0.0;
	reticle_downtime = 0.0;
	on_time = 0.0;
	off_time = 0.0;
	hit_count = 0;
	
func move(dir: Vector2):
	buffered_input = dir;

func start_struggle():
	is_targeting = true;

func retarget():
	retarget_dir = -1 if randf() < turn_prob else 1;
	var dist = randf_range(min_retarget_dist, max_retarget_dist);
	var offset = retarget_dir * dist;
	if target_angle + offset < 0 or target_angle + offset > 1:
		retarget_dir *= -1;
		offset *= -1;
	retarget_angle = target_angle + offset;
	retarget_angle = clamp(retarget_angle, 0, 1);

	retarget_speed = randf_range(min_retarget_speed, max_retarget_speed);
	retarget_timer.wait_time = randf_range(min_retarget_wait, max_retarget_wait);
	retarget_timer.start();

func queue_attack(attack: Attack):
	if not is_fish_on():
		return;
	attack_queue.append(attack);	

func get_style():
	var coverage = on_time / off_time;
	var total_time = on_time + off_time;
	var avoidance = total_time / (hit_count * 3.0);
	return (coverage + avoidance) / 2.0;

func _ready() -> void:
	retarget_timer = get_node("retarget");
	hurt_cooldown = get_node("hurt_cooldown");

	global_position = Vector2(0, 0);

	retarget();

func _movement(delta):
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

func _targeting(delta):
	match target_state:
		TargetState.IDLE:
			if retarget_timer.time_left < delta:
				target_state = TargetState.RETARGET;
		TargetState.RETARGET:
			var dt = retarget_dir * retarget_speed * delta;
			if abs(retarget_angle-target_angle) < abs(dt):
				retarget();
				target_state = TargetState.IDLE;
			else:
				target_angle += dt;
	
	if Input.is_action_just_pressed("game_action"):
		reticle_angle += 0.15 * delta;
	elif Input.is_action_pressed("game_action"):
		reticle_downtime = 0;
		reticle_uptime += delta;
		var rise = 0.75 + Curves.ease_in_cubic(reticle_uptime);
		reticle_angle += rise * delta;
	else:
		reticle_uptime = 0;
		reticle_downtime += delta;
		var fall = 0.45 + Curves.ease_in_cubic(reticle_downtime) * 3.0;
		reticle_angle -= fall * delta;
	reticle_angle = clamp(reticle_angle, 0+reticle_tolerance/2, 1-reticle_tolerance/2);

	var error = abs(reticle_angle - target_angle);
	if error <= reticle_tolerance:
		progress += delta * progress_grow
		on_time += delta;
	else:
		if progress <= 0.25:
			progress -= delta * progress_decay * 0.75;
		else:
			progress -= delta * progress_decay;
		off_time += delta;
	progress = clamp(progress, 0, 1);

func _handle_attacks():
	if attack_queue.is_empty():
		return;
	if not hurt_cooldown.is_stopped():
		return;
	
	while not attack_queue.is_empty():
		var attack = attack_queue.front();
		health -= attack.damage;
		attack_queue.pop_front();
		
	Services.find(EffectEngine).major_hitstop();

	if health <= 0:
		Services.find(StageEngine).lose();
	
	hurt_cooldown.start();
	await hurt_cooldown.timeout;
	hurt_cooldown.stop();

func _process(delta):
	_movement(delta);
	if is_targeting and is_fish_on():
		_targeting(delta);
		_handle_attacks();

	queue_redraw();

const base_gizmo_angle = PI/2.0;
const gizmo_arc = PI;
const health_colour = Color.RED;
const progress_colour = Color.GREEN;
const cursor_colour = Color.ALICE_BLUE;

func _make_gizmo_polar(t, r):
	t = base_gizmo_angle + gizmo_arc * t;
	var x = r*cos(t);
	var y = r*sin(t);
	return Vector2(x, y);
	
func _draw():
	if not _display:
		return;
	_display = false;
		
	draw_circle(Vector2.ZERO, radius, Color.WHITE, false);
	draw_line(Vector2.ZERO, to_local(get_parent().position), Color.WHITE);
	if not is_fish_on():
		return;
	
	if not is_targeting:
		return;
		
	var R = radius + orbit_dist;
	draw_arc(Vector2.ZERO, R, base_gizmo_angle, base_gizmo_angle+gizmo_arc, 64, Color.WHITE, 1);
	var R_health = lerp(radius, R, 0.33);
	draw_arc(Vector2.ZERO, R_health, base_gizmo_angle, base_gizmo_angle+gizmo_arc*health, 64, Color.RED, 2);
	var R_progress = lerp(radius, R, 0.66);
	draw_arc(Vector2.ZERO, R_progress, base_gizmo_angle, base_gizmo_angle+gizmo_arc*progress, 64, progress_colour, 2);

	var target_point = _make_gizmo_polar(target_angle, R);
	draw_circle(target_point, 8, progress_colour);

	var reticle_t = base_gizmo_angle + gizmo_arc * reticle_angle;
	draw_arc(Vector2.ZERO, R, reticle_t-reticle_tolerance, reticle_t+reticle_tolerance, 64, cursor_colour, 8);
