extends Node2D

enum LifeStatus {
	ALIVE,
	DEAD
};
var status: LifeStatus = LifeStatus.ALIVE;
signal hurt(damage);
signal death;

@export
var max_health: float = 100;
var health: float;
var damage_queue: Array[float] = [];

func queue_damage(damage):
	damage_queue.append(damage);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match status:
		LifeStatus.ALIVE:
			var total = 0;
			while not damage_queue.is_empty():
				var damage = damage_queue.front();
				health -= damage;
				total += damage;
				damage_queue.pop_front();
			if total > 0:
				hurt.emit(total);
			if health <= 0:
				status = LifeStatus.DEAD;
				death.emit();
		LifeStatus.DEAD:
			pass;
