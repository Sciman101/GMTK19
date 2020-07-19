extends KinematicBody2D

const BASE_SPEED = 800

onready var collision : CollisionShape2D = $CollisionShape2D
onready var trail : Particles2D = $Particles/Trail
onready var sparks : Particles2D = $Particles/Sparks
onready var gore : Particles2D = $Particles/Gore

var motion : Vector2 = Vector2.ZERO #Define motion vector
var is_moving : bool = false #Is the sawblade moving?
var stuck_in = null #What enemy are we stuck in?
var damage_dealt : float = 0 #How much damage have we done to the current enemy?
var damage_number_instance = null

var sharpness : float = 1

var _owner

func _ready() -> void:
	visible = false
	
	show_gore(false)
	
	#Connect signals
	$ImpactRadius.connect("body_entered",self,"_on_impact_enter")
	$ImpactRadius.connect("body_exited",self,"_on_impact_exit")

func show_gore(show):
	if show:
		gore.emitting = true
		gore.rotation = (-motion).angle()
	else:
		gore.emitting = false

#Called when we hit something
func _on_impact_enter(other:PhysicsBody2D) -> void:
	#Check if we've hit a valid target
	if is_moving:
		if other and other.has_method("hurt") and other.hurt(0):
			if other != _owner :
				stuck_in = other
				show_gore(true)
				
				#Create damage numbers
				if damage_number_instance == null:
					damage_number_instance = Global.damage_num.instance()
					get_parent().add_child(damage_number_instance)

#Called when we leave something
func _on_impact_exit(other:PhysicsBody2D) -> void:
	if stuck_in != null:
		stuck_in = null
		show_gore(false)
		
		#Remove damage numbers
		damage_number_instance.delete()
		damage_number_instance = null
		
		damage_dealt = 0

#Loop
func _physics_process(delta:float) -> void:
	
	if is_moving:
		
		var multiplier = 1
		if stuck_in != null:
			#Update damage numbers
			var dmg = delta*sharpness
			#Hurt enemy
			if stuck_in.has_method("hurt"):
				if stuck_in.hurt(dmg):
					
					multiplier = 0.1
					Global.cam_shake += .9
					
					damage_dealt += dmg
					_owner.score += int(dmg*1000)
					damage_number_instance.get_node("Label").text = String(round(damage_dealt*1000))
					
					damage_number_instance.position = position
				else:
					show_gore(false)
					_on_impact_exit(null)
		else:
			sharpness = max(sharpness-delta*0.1,0.05)
			if sharpness < 0.25:
				trail.emitting = false
		
		move_and_slide(motion*multiplier,Vector2.DOWN)
		
		if is_on_wall(): 
			motion.x *= -1
			on_impact()
		if is_on_ceiling() or is_on_floor(): 
			motion.y *= -1
			on_impact()

#Called when we hit a wall
func on_impact():
	sparks.rotation = motion.angle()
	sparks.restart()
	sparks.emitting = true
	Global.cam_shake += 1
	
	$ImpactPlayer.play()

#Launch the blade
func launch(position:Vector2,direction:Vector2) -> void:
	global_position = position
	motion = direction * BASE_SPEED
	
	trail.emitting = true
	trail.restart()
	sparks.restart()
	
	sharpness = 1
	
	is_moving = true
	visible = true
	collision.disabled = false
	
	show_gore(false)

#Pick up the spear
func pickup() -> void:
	is_moving = false
	stuck_in = null
	visible = false
	damage_dealt = 0
	collision.set_deferred("disabled",true)
	trail.emitting = false
	
	show_gore(false)