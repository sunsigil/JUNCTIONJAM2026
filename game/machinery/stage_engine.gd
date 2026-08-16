class_name StageEngine
extends Node

enum StageState {
	IDLE,
	QUEUED,
	STARTED
}

const STAGE_COUNT: int = 3;

signal stage_start;
signal stage_end;

var player_resource = preload("res://fisher/fisher.tscn");
var player_instance;

var stage_cutscenes = [
	Cutscenes.test,
	Cutscenes.test,
	Cutscenes.test,
];

var win_scene = preload("res://win_menu.tscn");
var lose_scene = preload("res://lose_menu.tscn");

var stage: int = 0;
var stage_state = StageState.IDLE;

func start_stage():
	stage_state = StageState.QUEUED;
	if stage < len(stage_cutscenes):
		Services.find(CutsceneEngine).play(stage_cutscenes[stage]);
	if stage >= STAGE_COUNT:
		get_tree().change_scene_to_packed(win_scene);
	
func end_stage():
	player_instance.queue_free();
	stage_end.emit();
	stage += 1;
	stage_state = StageState.IDLE;

func lose():
	player_instance.queue_free();
	get_tree().change_scene_to_packed(lose_scene);
	
func is_idle():
	return stage_state == StageState.IDLE;
	
func is_stage_started():
	return stage_state == StageState.STARTED;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Services.register(StageEngine, self);
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stage_state == StageState.IDLE:
		start_stage();
		return;
			
	if stage_state == StageState.QUEUED:
		if not Services.find(CutsceneEngine).is_playing():	
			player_instance = player_resource.instantiate();
			get_tree().root.add_child(player_instance);
			
			stage_state = StageState.STARTED;
			stage_start.emit();
