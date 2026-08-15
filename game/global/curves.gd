extends Node;

func ease_out_quad(t: float):
	return 1 - (1 - t) * (1 - t);

func breathe(a, b, t: float):
	a = float(a);
	b = float(b);
	t = float(t);
	t = 0.5 * (sin(t) + 1.0);
	return lerp(a, b, t);
