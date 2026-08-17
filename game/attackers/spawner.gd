extends Node2D

@export var stage_groups: Array[Node2D];

func _on_combat_start():
	if Progress.stage < len(stage_groups):
		var group: Node2D = stage_groups[Progress.stage];
		group.process_mode = Node.PROCESS_MODE_INHERIT;
		group.show();
	
func _ready():
	Services.find(StageEngine).combat_start.connect(_on_combat_start);
	for group in stage_groups:
		group.process_mode = Node.PROCESS_MODE_DISABLED;
		group.hide();