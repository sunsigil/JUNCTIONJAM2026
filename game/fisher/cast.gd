class_name Cast;

var owner: Node;
var target_t: float;
var t: float;
var grade: Enums.Grade;

func make_grade(t: float):
	if t > 1.15:
		return Enums.Grade.C;
	if t > 1.05:
		return Enums.Grade.B;
	if t > 0.975:
		return Enums.Grade.SSS;
	if t > 0.95:
		return Enums.Grade.SS;
	if t > 0.925:
		return Enums.Grade.S;
	if t > 0.875:
		return Enums.Grade.A;
	if t > 0.8:
		return Enums.Grade.B;
	else:
		return Enums.Grade.C;

func _init(_owner, _target_t, _t):
	owner = _owner;
	target_t = _target_t;
	t = _t;
	grade = Enums.Grade.NONE;
	
func _to_string() -> String:
	if grade == Enums.Grade.NONE:
		return "Cast (Pending): {0}/{1}, by {2}".format([t, target_t, owner]);
	else:
		return "Cast ({0}): {1}/{2}, by {3}".format([Enums.Grade.keys()[grade], t, target_t, owner]);
	
func finalize():
	var error = abs(t-target_t);
	grade = make_grade(1.0-error);
