extends Node2D
var _display: bool;
func display():
	_display = true;

@export
var width: float = 400;
@export
var height: float = 50;

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
	if cast_t > 1.01:
		current_cast.overshoot_t += delta;
	cast_t = clamp(cast_t, 0, 1);
	current_cast.t = Curves.ease_out_quad(cast_t);

func finish_cast():
	current_cast.finalize();
	casts.append(current_cast);
	
func is_ready() -> bool:
	return current_cast != null;
	
func is_casting() -> bool:
	return underway;
	
func get_last_cast() -> Cast:
	if len(casts) == 0:
		return null;
	return casts[-1];

func get_style():
	return get_last_cast().grade;

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
		
	var x0 = position.x-width/2;
	var y0 = position.y-height/2;
	draw_rect(Rect2(x0, y0, width, height), Color.CADET_BLUE);
	
	if not is_ready():
		draw_string(ThemeDB.fallback_font, Vector2(x0, y0), "SPACE TO FILL");
		return;
	var tw = width * current_cast.target_t;
	draw_rect(Rect2(x0, y0, tw, height), Color.SEA_GREEN);
	
	if current_cast.grade == Enums.Grade.NONE:
		draw_string(ThemeDB.fallback_font, Vector2(x0, y0), "FILL TO THE GREEN BAR");
	else:
		draw_string(ThemeDB.fallback_font, Vector2(x0, y0), "SPACE TO PROCEED");
	var cw = width * current_cast.t;
	draw_rect(Rect2(x0, y0, cw, height), Color.GREEN_YELLOW);
