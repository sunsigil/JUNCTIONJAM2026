extends Node

static var escape_1_frames: Array[Texture2D] = [
	preload("res://artwork/cg/escape1/static/1.png"),
	preload("res://artwork/cg/escape1/static/2.png"),
	preload("res://artwork/cg/escape1/static/3.png"),
]

static var escape_1: Array[CutsceneEngine.CutsceneCommand] = [
	CutsceneEngine.SET_BACKGROUND_COLOUR(Color.WHITE),
	CutsceneEngine.SET_BACKGROUND(escape_1_frames[0]),
	CutsceneEngine.SET_TEXT(""),
	CutsceneEngine.SET_BACKGROUND(escape_1_frames[1]),
	CutsceneEngine.SET_TEXT(""),
	CutsceneEngine.SET_BACKGROUND(escape_1_frames[2]),
	CutsceneEngine.SET_TEXT(""),
];

static var cutscenes = [
	escape_1
];

static var grade_anims: Array[SpriteFrames] = [
	preload("res://artwork/grade/c.tres"),
	preload("res://artwork/grade/b.tres"),
	preload("res://artwork/grade/a.tres"),
	preload("res://artwork/grade/s.tres"),
];
static func get_grade_anim(grade: Enums.Grade) -> SpriteFrames:
	var idx: int = int(grade);
	idx = clamp(idx, 0, len(grade_anims)-1);
	return grade_anims[idx];
