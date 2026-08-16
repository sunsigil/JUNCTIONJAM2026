extends Node2D

@export 
var damage: float;
@export
var speed: float;
var hitbox: Area2D;
var sprite: AnimatedSprite2D;

var sender;
var trajectory;
var mask: int;
var dead;

func _collide(body):
	print("Colliding with ", body);
	if body is CharacterBody2D:
		if is_instance_valid(sender):
			var attack = Attack.new(
				sender.get_parent(),
				sender.global_position, trajectory,
				damage
			);
			body.queue_attack(attack);
			sender.landed.emit(body);
	dead = true;
	#sprite.stop();
	#sprite.play("burst");
	#await sprite.animation_finished;
	queue_free();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox = get_node("hitbox");
	hitbox.body_entered.connect(_collide);
	#sprite = get_node("AnimatedSprite2D");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hitbox.collision_mask = mask;
	pass

func _physics_process(delta):
	if !dead:
		position += trajectory * speed * delta;
