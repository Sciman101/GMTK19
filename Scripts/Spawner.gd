extends Node2D

onready var mob_brick = preload("res://Scenes/Enemies/EnemyBrick.tscn")

#Spawns a random monster at the location
func spawn() -> void:
	
	var mob = Global.random_mob().instance()
	get_parent().add_child(mob)
	mob.position = position
	
	if mob.has_method("start_worm"):
		mob.is_head = true
		mob.start_worm()
	
	$Tween.interpolate_property(mob,"scale",Vector2.ZERO,Vector2.ONE,0.2,Tween.TRANS_EXPO,Tween.EASE_OUT)
	$Tween.start()