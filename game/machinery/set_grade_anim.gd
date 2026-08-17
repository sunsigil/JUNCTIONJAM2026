extends Node

var grade: AnimatedSprite2D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grade = get_node("grade");
	var anim: SpriteFrames = Cutscenes.get_grade_anim(Progress.grade);
	grade.sprite_frames = anim;
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
