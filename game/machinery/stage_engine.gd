class_name StageEngine
extends Node

enum StageState {
	IDLE,
	QUEUED,
	STARTED
}

const STAGE_COUNT: int = 5;

signal stage_start;
signal stage_end;

var cutscene_engine: CutsceneEngine;
var stage_cutscenes = [
	Cutscenes.test,
	Cutscenes.test,
	Cutscenes.test,
];

@export var player: Node2D;

var stage: int = 0;
var stage_state = StageState.IDLE;

func start_stage():
	stage_state = StageState.QUEUED;
	if stage < len(stage_cutscenes):
		Services.find(CutsceneEngine).play(stage_cutscenes[stage]);
	
func end_stage():
	stage_end.emit();
	stage += 1;
	stage_state = StageState.IDLE;
	
func is_idle():
	return stage_state == StageState.IDLE;
	
func is_stage_started():
	return stage_state == StageState.STARTED;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Services.register(StageEngine, self);
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if stage_state == StageState.QUEUED:
		if not Services.find(CutsceneEngine).is_playing():
			stage_state = StageState.STARTED;
			stage_start.emit();
