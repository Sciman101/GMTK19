extends Node2D

var rise : float = 0

func delete():
	rise = 50
	if get_tree():
		yield(get_tree().create_timer(1),"timeout")
	queue_free()

func _process(delta):
	position += Vector2.UP * rise * delta