class_name StageGroup
extends Node2D

func _apply_active_state() -> void:

	var active = is_visible_in_tree();
	for node in find_children("*", "Node", true, false):
		node.set_process(active);
		node.set_physics_process(active);
		if node is Area2D:
			node.monitoring = active;
		if active and node.has_method("begin_entry"):
			node.call("begin_entry");

func _ready() -> void:
	visibility_changed.connect(_apply_active_state);
	_apply_active_state();
