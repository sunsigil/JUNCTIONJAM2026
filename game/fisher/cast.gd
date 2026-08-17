class_name Cast;

var owner: Node;
var target_t: float;
var t: float;
var overshoot_t: float;
var error: float;
var finalized = true;

func _init(_owner, _target_t, _t):
	owner = _owner;
	target_t = _target_t;
	t = _t;
	finalized = false;
	
func finalize():
	error = abs(t-target_t);
	error += overshoot_t;
	finalized = true;
