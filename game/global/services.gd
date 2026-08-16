extends Node

var cutscene_engine: CutsceneEngine;
var stage_engine: StageEngine;

var map = {};

func register(type: GDScript, node: Node):
	map[type] = node;
	
func find(type: GDScript):
	return map[type] if type in map else null;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
