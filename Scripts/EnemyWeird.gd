extends KinematicBody2D

onready var animation : AnimationPlayer = $AnimationPlayer
onready var shards : Particles2D = $Shards

var is_moving : bool = false
var motion : Vector2
var charge : float = 0
var life : float = 2

func _ready():
	$KillBox.connect("body_entered",self,"on_touch")

func on_touch(body:PhysicsBody2D):
	if body and body.is_in_group("Player"):
		body.kill("Arcane Construct")

func hurt(amount:float):
	life -= amount
	if life <= 0:
		queue_free()
		Global.cam_shake += 10
		Global.player.combo+=1
		Global.spawn_new_mob()
	return true

func _process(delta):
	animation.advance(delta*charge)

func _physics_process(delta):
	if is_moving:
		move_and_slide(motion,Vector2.DOWN)
		
		if is_on_wall(): 
			motion.x *= -1
			Global.cam_shake += 8
		if is_on_ceiling() or is_on_floor(): 
			motion.y *= -1
			Global.cam_shake += 8
		
		motion *= 0.99
		if motion.length_squared() <= 1024:
			motion = Vector2.ZERO
			is_moving = false
			shards.emitting = false
			charge = 0
	else:
		charge += delta
		if charge >= 4:
			shards.emitting = true
			is_moving = true
			motion = (Global.player.position - position) * 2