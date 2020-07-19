extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var start : bool = false

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
    	OS.window_fullscreen = !OS.window_fullscreen
	elif event.is_action_pressed("fire") and not start:
		start = true
		$AnimationPlayer.play("Outro")

func goto_game():
	Global.start_game()
	queue_free()