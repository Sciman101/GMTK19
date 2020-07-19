extends Area2D

const MOVE_SPEED = 200

var start_pos : Vector2

var target : Vector2
var motion : Vector2
var is_moving : bool
var rot_speed : float

onready var sprite = $Sprite

signal finished

func _ready():
	start_pos = position
	connect("body_entered",self,"_on_body_enter")

#Called when something enters us
func _on_body_enter(body:PhysicsBody2D):
	if body.is_in_group("Player"):
		body.kill("Fortification Golem")

func _physics_process(delta):
	if is_moving:
		position += motion * delta
		rotation += delta * rot_speed
		if position.distance_squared_to(target) < 16:
			position = target
			rotation = 0
			is_moving = false
			emit_signal("finished")

func set_target(target:Vector2):
	self.target = target + start_pos
	var speed = MOVE_SPEED * rand_range(0.8,1.2)
	self.motion = (self.target-position).normalized() * speed
	self.is_moving = true
	
	self.rot_speed = (PI*2)/max(1,self.target.distance_to(position)/speed) * (1 if randf() > 0.5 else -1)

func reset():
	is_moving = false
	sprite.rotation = 0
	position = start_pos