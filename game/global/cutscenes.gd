extends Node

static var test_bgs = [
	preload("res://test/img_cutsc_0.png"),
	preload("res://test/img_cutsc_1.png"),
	preload("res://test/img_cutsc_2.png"),
];
static var test_ports = [
	preload("res://test/portrait_0.png"),
	preload("res://test/portrait_1.png"),
]

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

static var test: Array[CutsceneEngine.CutsceneCommand] = [
	CutsceneEngine.SET_BACKGROUND_COLOUR(Color.WHITE),
	CutsceneEngine.SET_PORTRAIT([0, test_ports[0]]),
	CutsceneEngine.SET_PORTRAIT([1, test_ports[1]]),
	CutsceneEngine.SET_TEXT("Hello, world!"),
	CutsceneEngine.SET_TEXT("Okay, goodbye."),
	CutsceneEngine.SET_BACKGROUND(test_bgs[0]),
	CutsceneEngine.SET_TEXT(""),
	CutsceneEngine.SET_BACKGROUND(test_bgs[1]),
	CutsceneEngine.SET_TEXT(""),
	CutsceneEngine.SET_BACKGROUND(test_bgs[2]),
	CutsceneEngine.SET_TEXT(""),
];

static var cutscenes = [
	test
];
