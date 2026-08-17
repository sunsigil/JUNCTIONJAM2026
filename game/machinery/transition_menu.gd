extends Node

@export var scene: PackedScene;
@export var prompt: String;
@export var post_prompt: String;

@export var await_animations: Array[AnimatedSprite2D];

var trigger = false;
var t: float = 0;

var image_node: Node2D;
var text_node: Label;

var awaiting: bool;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	image_node = get_node("image");
	text_node = get_node("text");

	for anim in await_animations:
		anim.pause();
		anim.hide();
	awaiting = true;
	for anim in await_animations:
		anim.show();
		anim.play();
		await anim.animation_finished;
	awaiting = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if awaiting:
		return;

	if Input.is_action_just_pressed("game_action"):
		trigger = true;
		
	if trigger:
		image_node.modulate.a = 1.0-t*1.5;
		text_node.text = post_prompt;
		text_node.modulate.a = image_node.modulate.a;
		t += delta;
	else:
		text_node.text = prompt;
		text_node.scale = Vector2.ONE * Curves.breathe(0.75, 1, Time.get_ticks_msec()/1000.0);
		
	if t >= 1.0:
		get_tree().change_scene_to_packed(scene);
