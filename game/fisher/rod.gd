extends Node2D

var _display: bool;
func display():
	_display = true;

var casts: Array[Cast] = [];
var current_cast: Cast = null;

var underway: bool = false;
var cast_t: float = 0;

func prepare_cast():
	current_cast = Cast.new(self, 0.5 + randf()*0.5, 0);

func start_cast():
	underway = true;
	cast_t = 0;

func tick_cast(delta: float):
	cast_t += delta;
	current_cast.t = Curves.ease_out_quad(cast_t);

func finish_cast():
	current_cast.finalize();
	print(current_cast);
	casts.append(current_cast);
	current_cast = null;
	
func is_ready() -> bool:
	return current_cast != null;
	
func is_casting() -> bool:
	return underway;
	
func get_last_cast() -> Cast:
	if len(casts) == 0:
		return null;
	return casts[-1];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:		
	queue_redraw();

func _draw():
	if not _display:
		return;
	_display = false;
		
	var w = 100;
	var h = 20;
	var x0 = position.x;
	var y0 = position.y;
	draw_rect(Rect2(x0, y0, w, h), Color.CADET_BLUE);
	
	if not is_ready():
		return;	
	var tw = w * current_cast.target_t;
	draw_rect(Rect2(x0, y0, tw, h), Color.SEA_GREEN);
	
	if not is_casting():
		return;
	var cw = w * current_cast.t;
	draw_rect(Rect2(x0, y0, cw, h), Color.GREEN_YELLOW);
