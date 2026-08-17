class_name StageEngine
extends Node

const cutscene_scene = preload("res://machinery/cutscene_engine.tscn");
const interstage_scene = preload("res://machinery/interstage_menu.tscn");
const win_scene = preload("res://win_menu.tscn");
const lose_scene = preload("res://lose_menu.tscn");

signal combat_start;

func start_stage():
	get_tree().change_scene_to_packed(cutscene_scene);
	
func end_stage():
	Progress.stage += 1;
	if Progress.stage >= Progress.STAGE_COUNT:
		Progress.stage = 0;
		get_tree().change_scene_to_packed(win_scene);
	else:
		get_tree().change_scene_to_packed(interstage_scene);

func start_combat():
	combat_start.emit();

func lose():
	get_tree().change_scene_to_packed(lose_scene);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Services.register(StageEngine, self);
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;
