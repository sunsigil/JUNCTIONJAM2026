class_name Cast;

var owner: Node2D;
var target_t: float;
var t: float;

var grade: Enums.GRADE;

func make_grade(t: float):
	if t > 1.15:
		return Enums.GRADE.C;
	if t > 1.05:
		return Enums.GRADE.B;
	if t > 0.975:
		return Enums.GRADE.SSS;
	if t > 0.95:
		return Enums.GRADE.SS;
	if t > 0.925:
		return Enums.GRADE.S;
	if t > 0.875:
		return Enums.GRADE.A;
	if t > 0.8:
		return Enums.GRADE.B;
	else:
		return Enums.GRADE.C;

func _init(_owner, _target_t, _t):
	owner = _owner;
	target_t = _target_t;
	t = _t;
	grade = Enums.GRADE.NONE;
	
func finalize():
	var error = abs(t-target_t);
	grade = make_grade(1.0-error);
