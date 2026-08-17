class_name CutsceneEngine
extends Node2D

enum CutsceneOp
{
	SET_BACKGROUND_COLOUR,
	SET_BACKGROUND,
	SET_PORTRAIT,
	SET_TEXT
};

class CutsceneCommand:
	var op;
	var arg;
	
	func _init(_op, _arg) -> void:
		op = _op;
		arg = _arg;

static func SET_BACKGROUND_COLOUR(_arg):
	return CutsceneCommand.new(CutsceneOp.SET_BACKGROUND_COLOUR, _arg);
static func SET_BACKGROUND(_arg):
	return CutsceneCommand.new(CutsceneOp.SET_BACKGROUND, _arg);
static func SET_PORTRAIT(_arg):
	return CutsceneCommand.new(CutsceneOp.SET_PORTRAIT, _arg);
static func SET_TEXT(_arg):
	return CutsceneCommand.new(CutsceneOp.SET_TEXT, _arg);

var background_colour: Color;
var background: Texture2D;
var portraits: Array[Texture2D];
var text: String;
	
var cutscene: Array[CutsceneCommand];
var command_idx: int = 0;
	
func clear():
	background_colour = Color.WHITE;
	background = null;
	portraits = [null, null];
	text = "";
	
func play(_cutscene: Array[CutsceneCommand]):
	clear();
	cutscene = _cutscene.duplicate();
	command_idx = 0;
	
func execute_command(cmd: CutsceneCommand):
	match cmd.op:
		CutsceneOp.SET_BACKGROUND_COLOUR:
			background_colour = cmd.arg;
		CutsceneOp.SET_BACKGROUND:
			background = cmd.arg;
		CutsceneOp.SET_PORTRAIT:
			var idx = cmd.arg[0];
			var img = cmd.arg[1];
			portraits[idx] = img;
		CutsceneOp.SET_TEXT:
			text = cmd.arg;
			
func progress():
	command_idx += 1;
	if command_idx >= len(cutscene):
		cutscene = [];
		get_tree().change_scene_to_file("res://pond.tscn");
	
var background_rect: ColorRect;
var background_node: Sprite2D;
var portrait_nodes: Array[Sprite2D];
var text_node: Label;

func refresh():
	background_rect.color = background_colour;
	background_node.texture = background;
	portrait_nodes[0].texture = portraits[0];
	portrait_nodes[1].texture = portraits[1];
	text_node.text = text;

func _ready():
	Services.register(CutsceneEngine, self);
	
	background_rect = get_node("background_colour");
	background_node = get_node("background");
	portrait_nodes = [
		get_node("portrait_0"),
		get_node("portrait_1")
	];
	text_node = get_node("text");
	
	clear();
	refresh();

	play(Cutscenes.cutscenes[Progress.stage-1]);
	
func _process(delta: float) -> void:
	refresh();
		
	var cmd = cutscene[command_idx];
	execute_command(cmd);
	if cmd.op == CutsceneOp.SET_TEXT:
		if Input.is_action_just_pressed("game_action"):
			progress();
	else:
		progress();
	
