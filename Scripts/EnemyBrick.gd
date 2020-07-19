extends StaticBody2D

var segments = []
onready var animator = $Segments/EnemyBrickSegmentMM/EyeAnimator
onready var audio = $Audio

var moving_chunks : int = 0
var new_position : Vector2

var life : float = 1

func _ready():
	segments = $Segments.get_children()
	animator.play("Blink")
	
	#Connect
	for segment in segments:
		segment.connect("finished",self,"on_chunk_done")

func disassemble():
	$CollisionShape2D.disabled = true
	moving_chunks = 9
	
	Global.cam_shake += 6
	
	new_position = Global.player.position
	new_position = (new_position / 48).round()*48
	for segment in segments:
		segment.set_target(new_position - position)
		audio.play()
		yield(get_tree().create_timer(0.25),"timeout")

func hurt(amount:float):
	if moving_chunks == 0:
		life -= amount
		if life <= 0:
			Global.player.combo += 1
			Global.cam_shake += 10
			queue_free()
			Global.spawn_new_mob()
		return true
	else:
		return false

func on_chunk_done():
	moving_chunks -= 1
	
	if moving_chunks <= 0:
		for segment in segments:
			segment.reset()
		$CollisionShape2D.disabled = false
		position = new_position
		animator.play("Blink")