extends Node2D

class_name FishConnectorOverlay

const EXPECTED_POINT_COUNT := 5
const EDGES: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 2),
	Vector2i(2, 3),
	Vector2i(3, 4),
]

@onready var head_to_upper: Node2D = $HeadToUpper
@onready var upper_to_lower: Node2D = $UpperToLower
@onready var lower_to_end: Node2D = $LowerToEnd
@onready var end_to_tail: Node2D = $EndToTail
@onready var pivots: Array[Node2D] = [
	head_to_upper,
	upper_to_lower,
	lower_to_end,
	end_to_tail,
]

var rest_lengths: Array[float] = []
var rest_angles: Array[float] = []


func set_rest_points(points: Array[Vector2]) -> void:
	if points.size() != EXPECTED_POINT_COUNT:
		push_error("FishConnectorOverlay requires exactly five rest points")
		return

	rest_lengths.clear()
	rest_angles.clear()
	for edge in EDGES:
		var rest_segment := points[edge.y] - points[edge.x]
		rest_lengths.append(rest_segment.length())
		rest_angles.append(rest_segment.angle())


func set_points(points: Array[Vector2]) -> void:
	if points.size() != EXPECTED_POINT_COUNT:
		push_error("FishConnectorOverlay requires exactly five current points")
		return
	if rest_lengths.size() != EDGES.size() or rest_angles.size() != EDGES.size():
		push_error("FishConnectorOverlay rest points must be set before current points")
		return

	for index in range(EDGES.size()):
		var edge := EDGES[index]
		var pivot := pivots[index]
		var current_segment := points[edge.y] - points[edge.x]
		var current_length := current_segment.length()
		var current_angle := rest_angles[index]
		if current_length > 0.0001:
			current_angle = current_segment.angle()
		pivot.position = (points[edge.x] + points[edge.y]) * 0.5
		pivot.rotation = wrapf(current_angle - rest_angles[index], -PI, PI)
		pivot.scale = Vector2(current_length / rest_lengths[index], 1.0)
