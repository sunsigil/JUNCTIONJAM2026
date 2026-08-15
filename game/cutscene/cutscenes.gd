class_name Cutscenes

static var test_bgs = [
	preload("res://test/img_cutsc_0.png"),
	preload("res://test/img_cutsc_1.png"),
	preload("res://test/img_cutsc_2.png"),
];
static var test_ports = [
	preload("res://test/portrait_0.png"),
	preload("res://test/portrait_1.png"),
]

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
