class_name HazardSpawner
extends StageGroup

@export var min_per_type: int = 1;

#   mean = 3 * (1*0.45 + 2*0.45 + 3*0.10) = 4.95
#   P(3) = 0.45^3 = 9.1%   (floor, every type rolls 1)
#   P(9) = 0.10^3 = 0.1%   (ceiling, every type rolls 3)
@export var count_weights: PackedFloat32Array = PackedFloat32Array([0.45, 0.45, 0.10]);

@export_category("Placement")
@export var spawn_area: Rect2 = Rect2(-780, 150, 1560, 330);
@export var min_separation: float = 170.0;
@export var min_drift: float = 120.0;
@export var max_drift: float = 260.0;

const placement_attempts: int = 12;

var placed_positions: Array[Vector2] = [];
var has_spawned: bool = false;

func roll_count() -> int:
	var roll = randf();
	var cumulative = 0.0;
	for index in range(count_weights.size()):
		cumulative += count_weights[index];
		if roll < cumulative:
			return min_per_type + index;
	return min_per_type + count_weights.size() - 1;


func _pick_position() -> Vector2:
	var best = Vector2.ZERO;
	var best_clearance = -1.0;
	for _attempt in range(placement_attempts):
		var candidate = Vector2(
			randf_range(spawn_area.position.x, spawn_area.end.x),
			randf_range(spawn_area.position.y, spawn_area.end.y)
		);
		var clearance = INF;
		for taken in placed_positions:
			clearance = min(clearance, candidate.distance_to(taken));
		if clearance >= min_separation:
			return candidate;
		if clearance > best_clearance:
			best_clearance = clearance;
			best = candidate;
	return best;

func _configure(hazard: Node) -> void:
	var spawn_position = _pick_position();
	placed_positions.append(spawn_position);
	hazard.position = spawn_position;

	if "movement_origin" in hazard:
		hazard.movement_origin = spawn_position;
	if "phase_offset" in hazard:
		hazard.phase_offset = randf_range(0.0, TAU);
	if "horizontal_range" in hazard:
		hazard.horizontal_range = randf_range(min_drift, max_drift);


func _spawn_hazards() -> void:
	placed_positions.clear();
	for template in get_children():
		var extra_copies = roll_count() - 1;
		_configure(template);
		for _index in range(extra_copies):
			var copy = template.duplicate();
			_configure(copy);
			add_child(copy);

func begin_entry() -> void:
	_apply_active_state();

func _apply_active_state() -> void:
	if is_visible_in_tree() and not has_spawned:
		has_spawned = true;
		_spawn_hazards();
	super();
