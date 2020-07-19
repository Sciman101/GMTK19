extends KinematicBody2D

const MOVE_SPEED = 400

export var is_head : bool  = false

var motion : Vector2
var length : int

var initial_motion : Vector2
var initial_position : Vector2
var front = null
var head = null
var tail = null
var index : int = 0

var stun : float = 0

var life : float = 0.1

onready var sprite = $Sprite

signal do_stun

func _ready():
	$KillBox.connect("body_entered",self,"on_touch")

func start_worm():
	#life *= 2
	head = self
	front = self
	#Randomize initial vars
	motion = Vector2.RIGHT.rotated(rand_range(0,PI*2)) * MOVE_SPEED
	initial_motion = motion
	initial_position = position
	length = randi()%9+4+(Global.player.score/1000)
	
	sprite.region_rect.position.x += 48
	#position -= motion * 0.02
	
	make_segment()

func make_segment():
	
	if length > 0:
		#Wait
		yield(get_tree().create_timer(0.05),"timeout")
		
		#Create new segment
		var segment = Global.mob_worm.instance()
		get_parent().add_child(segment)
		segment.position = initial_position
		segment.initial_position = initial_position
		segment.motion = initial_motion
		segment.initial_motion = initial_motion
		segment.length = length - 1
		segment.head = self
		tail = segment
		segment.front = front
		segment.index = index + 1
		
		segment.z_index = -index
		
		segment.make_segment()

func hurt(amount:float):
	life -= amount
	if life <= 0:
		Global.player.combo += 1
		on_kill()
	else:
		if is_head:
			do_stun()
		elif front != null and is_instance_valid(front):
			if front.has_method("do_stun"):
				front.do_stun()
		else:
			on_kill()
	return true

#Propegate through the chain and set stun
func do_stun():
	stun = 0.5
	if tail: tail.do_stun()

#Called when we die
func on_kill():
	if is_instance_valid(head) and head.get("tail"):
		head.tail = null
	if tail:
		tail.on_kill()
	if is_head:
		Global.spawn_new_mob()
	Global.cam_shake += 2.5
	queue_free()

func on_touch(body:PhysicsBody2D):
	if body and body.is_in_group("Player"):
		body.kill("Giant Worm")

func _physics_process(delta):
	
	move_and_slide(motion * (1-stun),Vector2.DOWN)
	
	if is_on_wall(): motion.x *= -1
	if is_on_ceiling() or is_on_floor(): motion.y *= -1
	
	if is_head:
		sprite.rotation = motion.angle()
	
	if stun > 0:
		stun -= delta
		stun = max(stun,0)