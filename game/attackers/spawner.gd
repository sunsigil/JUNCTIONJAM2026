extends Node2D

@export var stage_groups: Array[Node2D];

func _on_combat_start():
	var group: Node2D = stage_groups[Progress.stage];
	group.set_process(true);
	group.show();
	
func _ready():
	Services.find(StageEngine).combat_start.connect(_on_combat_start);
	for group in stage_groups:
		group.set_process(false);
		group.hide();
