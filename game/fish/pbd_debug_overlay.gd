extends Node2D
class_name PBDDebugOverlay

const EXPECTED_POINT_COUNT := 5
const CHAIN_EDGES: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 2), Vector2i(2, 3), Vector2i(3, 4)]
const SHAPE_EDGES: Array[Vector2i] = [Vector2i(0, 2), Vector2i(1, 3), Vector2i(2, 4)]

@export var chain_color: Color = Color("b7ef42")
@export var shape_color: Color = Color("ff9f1c")
@export var node_color: Color = Color("f5f7e8")
@export var pinned_node_color: Color = Color("ff4f40")
@export var node_outline_color: Color = Color("152026")
@export var chain_width: float = 3.0
@export var shape_width: float = 2.0
@export var node_radius: float = 5.0
@export var node_outline_width: float = 2.0

var debug_points: Array[Vector2] = []


func set_debug_points(next_points: Array[Vector2]) -> void:
	debug_points = next_points.duplicate()
	queue_redraw()


func _draw() -> void:
	if debug_points.size() != EXPECTED_POINT_COUNT:
		return
	for edge in CHAIN_EDGES:
		draw_line(debug_points[edge.x], debug_points[edge.y], chain_color, chain_width, true)
	for edge in SHAPE_EDGES:
		draw_dashed_line(debug_points[edge.x], debug_points[edge.y], shape_color, shape_width, 6.0, true, true)
	for index in range(debug_points.size()):
		draw_circle(debug_points[index], node_radius + node_outline_width, node_outline_color)
		var fill_color := pinned_node_color if index == 0 else node_color
		draw_circle(debug_points[index], node_radius, fill_color)
