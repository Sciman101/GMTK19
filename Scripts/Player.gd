extends KinematicBody2D

const MOVE_SPEED = 500
const TURN_DAMP = 0.5
const PICKUP_RADIUS = 72*72

onready var camera = $"../Camera2D"
onready var my_blade = $"Sawblade Projectile"
onready var blade_sprite : Sprite = $"Sawblade"
onready var animation = $AnimationPlayer
onready var score_label = $"../UIOffset/UI/Score"
onready var combo_label = $"../UIOffset/UI/Combo"

var motion : Vector2 = Vector2.ZERO
var has_blade : bool = true

var score : int = 0 setget set_score
var combo : int = 0 setget set_combo
var damage_during_combo : int = 0

var dead : bool = false #Are we dead?

#Unparent blade from self
func _ready() -> void:
	my_blade._owner = self
	remove_child(my_blade)
	get_parent().call_deferred("add_child",my_blade)

func set_score(sc:int):
	damage_during_combo += sc - score
	score = sc
	score_label.text = "SCORE: " + String(score).pad_zeros(8)

func set_combo(c:int):
	combo = c
	combo_label.visible = combo >= 2
	combo_label.text = "COMBO: " + String(combo)

#Called when hurt
func kill(killed_by):
	if not dead:
		dead = true
		#Pickup saw
		has_blade = true
		blade_sprite.visible = true
		my_blade.pickup()
		$"../DeathScreenOffset".visible = true
		visible = false
		
		var highscore = Global.save_data["highscore"]
		if highscore < score:
			highscore = score
			Global.save_write(highscore)
		
		#Set score
		$"../DeathScreenOffset/DeathScreen/CenterContainer/GameEnd".text = "GAME OVER\nKILLED BY: %s\nSCORE:%d\nBEST:%d\n\nClick to restart" % [killed_by, score, highscore]
	#Global.restart()
	
#Check for mouse click
func _process(delta:float) -> void:
	
	if dead:
		if Input.is_action_just_pressed("fire"):
			Global.restart()
		return
	
	if Input.is_action_just_pressed("fire"):
		if has_blade: #Throw
			
			my_blade.launch(blade_sprite.global_position,Vector2.RIGHT.rotated(rotation))
			blade_sprite.visible = false
			
			has_blade = false
			
		else: #Grab
			
			#Get distance to saw
			var dist = global_position.distance_squared_to(my_blade.global_position)
			if dist <= PICKUP_RADIUS:
				#Pickup saw
				has_blade = true
				blade_sprite.visible = true
				my_blade.pickup()
				
				if combo > 2:
					set_score(score+(combo/2)*damage_during_combo)
				damage_during_combo = 0
				set_combo(0)

#Move and turn
func _physics_process(delta:float) -> void:
	
	if dead: return
	
	#WASD movement
	var hor = Input.get_action_strength("right") - Input.get_action_strength("left")
	var ver = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	var mov = Vector2(hor,ver).normalized()
	motion = lerp(motion,mov*MOVE_SPEED,delta*50)
	animation.advance(delta*mov.length_squared())
	
	move_and_slide(motion)
	
	#Point at mouse
	rotation += get_local_mouse_position().angle() * TURN_DAMP