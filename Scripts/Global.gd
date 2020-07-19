extends Node

onready var mob_worm = preload("res://Scenes/Enemies/EnemyWorm.tscn")
onready var mob_brick = preload("res://Scenes/Enemies/EnemyBrick.tscn")
onready var mob_weird = preload("res://Scenes/Enemies/EnemyWeird.tscn")

onready var damage_num = preload("res://Scenes/DamageNumber.tscn")
onready var spawn_portal = preload("res://Scenes/SpawnPortal.tscn")

onready var camera : Camera2D
onready var player

var cam_shake:float = 0

var savegame = File.new()
var save_path = "user://player.info"
var save_data = {"highscore":0}

#Save management
func create_save():
	savegame.open(save_path,File.WRITE)
	savegame.store_var(save_data)
	savegame.close()

func save_write(score):
	save_data["highscore"] = score #data to save
	savegame.open(save_path, File.WRITE) #open file to write
	savegame.store_var(save_data) #store the data
	savegame.close() # close the file

func read_savegame():
	savegame.open(save_path, File.READ) #open the file
	save_data = savegame.get_var() #get the value
	savegame.close() #close the file

func _ready():
	if not savegame.file_exists(save_path):
		create_save()
	else:
		read_savegame()

func start_game():
	camera = $"../Main/Camera2D"
	player = $"../Main/Player"
	$Timer.connect("timeout",self,"spawn_new_mob")
	spawn_new_mob()

func _process(delta):
	if cam_shake > 0:
		cam_shake -= delta*50
		cam_shake = max(cam_shake,0)
		
		camera.offset = Vector2(rand_range(-cam_shake,cam_shake),rand_range(-cam_shake,cam_shake))

#Spawn a new mob
func spawn_new_mob():
	var portal = spawn_portal.instance()
	
	var size = get_viewport().size
	portal.position = Vector2(rand_range(120,1080),rand_range(80,560))
	$"../Main".add_child(portal)

#Get a random mob
func random_mob():
	var index = randi() % 6
	match index:
		0: return mob_worm
		1: return mob_worm
		2: return mob_worm
		
		3: return mob_brick
		4: return mob_brick
		
		5: return mob_weird
		
		_: return mob_worm

func restart():
	get_tree().reload_current_scene()
	yield(get_tree(),"idle_frame")
	camera = $"../Main/Camera2D"
	player = $"../Main/Player"
	$"../Main/Title".queue_free()
	cam_shake = 0
	$Timer.start()
	spawn_new_mob()