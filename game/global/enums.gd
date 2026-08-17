extends Node

enum Grade {
	NONE,
	C,
	B,
	A,
	S
};

func make_grade(t: float):
	t = clamp(t, 0, 1);
	if t > 0.975:
		return Enums.Grade.S;
	if t > 0.95:
		return Enums.Grade.A;
	if t > 0.85:
		return Enums.Grade.B;
	else:
		return Enums.Grade.C;
