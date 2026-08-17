extends Node

@export var song: AudioStreamWAV = preload("res://audio/fish_waiting.wav");

var player: AudioStreamPlayer2D;

func _on_finished(player):
	player.play();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("player");
	player.finished.connect(_on_finished.bind(player));

	player.stream = song;
	player.play();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
