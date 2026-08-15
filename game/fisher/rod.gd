extends Node2D

var casts: Array[Cast] = [];
var current_cast: Cast = null;
var cast_t: float = 0;

func start_cast():
	current_cast = Cast.new(self, 0.5 + randf()*0.5, 0);
	cast_t = 0;

func tick_cast(delta: float):
	cast_t += delta;
	current_cast.t = Curves.ease_out_quad(cast_t);

func finish_cast():
	current_cast.finalize();
	print(current_cast);
	casts.append(current_cast);
	current_cast = null;
	
func is_casting() -> bool:
	return current_cast != null;
	
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
	var w = 100;
	var h = 20;
	var x0 = position.x;
	var y0 = position.y;
	draw_rect(Rect2(x0, y0, w, h), Color.CADET_BLUE);
	
	if current_cast == null:
		return;
		
	var tw = w * current_cast.target_t;
	var cw = w * current_cast.t;
	draw_rect(Rect2(x0, y0, tw, h), Color.SEA_GREEN);
	draw_rect(Rect2(x0, y0, cw, h), Color.GREEN_YELLOW);
		
