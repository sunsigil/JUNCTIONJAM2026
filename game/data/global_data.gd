extends Node2D

var player: Node;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func poll_player():
	var players = get_tree().get_nodes_in_group("player");
	if len(players) == 0:
		player = null;
		return;
	player = players[0];

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == null:
		poll_player();
		if player != null:
			print("Registered player");
