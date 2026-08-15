extends Node;

func ease_out_quad(t: float):
	return 1 - (1 - t) * (1 - t);
